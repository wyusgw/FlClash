package main

import (
	"bytes"
	"encoding/json"
	"errors"
	"fmt"
	"os"
	"path/filepath"
	"strings"
	"sync/atomic"

	"core/logx"

	"github.com/xtls/xray-core/core"
	"github.com/xtls/xray-core/features/routing"
	"github.com/xtls/xray-core/infra/conf/serial"
	_ "github.com/xtls/xray-core/main/distro/all"
)

const configFileName = "config.json"

var errConfigNotApplied = errors.New("config is not applied")

type outboundMeta struct {
	Tag      string `json:"tag"`
	Protocol string `json:"protocol"`
}

type balancerMeta struct {
	Tag      string   `json:"tag"`
	Selector []string `json:"selector"`
	Strategy struct {
		Type string `json:"type"`
	} `json:"strategy"`
}

// configMeta is what the host-facing calls need to know about a config without
// asking the running instance: Xray keeps no list of outbounds and balancers
// that it hands back with their members.
type configMeta struct {
	outbounds []outboundMeta
	balancers []balancerMeta
}

func parseConfigMeta(data []byte) (*configMeta, error) {
	var raw struct {
		Outbounds []outboundMeta `json:"outbounds"`
		Routing   struct {
			Balancers []balancerMeta `json:"balancers"`
		} `json:"routing"`
	}
	if err := json.Unmarshal(data, &raw); err != nil {
		return nil, err
	}
	return &configMeta{outbounds: raw.Outbounds, balancers: raw.Routing.Balancers}, nil
}

func (m *configMeta) outbound(tag string) (outboundMeta, bool) {
	for _, outbound := range m.outbounds {
		if outbound.Tag == tag {
			return outbound, true
		}
	}
	return outboundMeta{}, false
}

func (m *configMeta) balancer(tag string) (balancerMeta, bool) {
	for _, balancer := range m.balancers {
		if balancer.Tag == tag {
			return balancer, true
		}
	}
	return balancerMeta{}, false
}

// Xray selects a balancer's members by tag prefix.
func (m *configMeta) members(balancer balancerMeta) []string {
	members := []string{}
	for _, outbound := range m.outbounds {
		for _, prefix := range balancer.Selector {
			if strings.HasPrefix(outbound.Tag, prefix) {
				members = append(members, outbound.Tag)
				break
			}
		}
	}
	return members
}

// Traffic through freedom and blackhole outbounds is not proxied traffic.
func (m *configMeta) isProxy(tag string) bool {
	outbound, ok := m.outbound(tag)
	if !ok {
		return false
	}
	switch outbound.Protocol {
	case "freedom", "direct", "blackhole", "block", "dns", "loopback":
		return false
	}
	return true
}

type engine struct {
	instance *core.Instance
	meta     *configMeta
}

var (
	currentEngine atomic.Pointer[engine]

	// Guarded by configMu: the normalised config of the last successful setup,
	// kept so a stopped engine can be rebuilt without asking the host again.
	lastConfig []byte
	lastMeta   *configMeta

	// Guarded by selectMu: the host's choice per group, replayed onto every
	// instance because Xray forgets balancer overrides with the instance.
	selected = map[string]string{}

	// Set by the Android layer to put its TUN inbound back on a new instance.
	afterEngineStart func(*core.Instance) error
)

func configPath() string {
	return filepath.Join(homeDir, configFileName)
}

// normalizeConfig makes sure the counters the traffic calls read exist, so a
// config written by the host does not have to know about them.
func normalizeConfig(data []byte) ([]byte, *configMeta, error) {
	var document map[string]any
	if err := json.Unmarshal(data, &document); err != nil {
		return nil, nil, fmt.Errorf("invalid config: %w", err)
	}
	if _, ok := document["stats"]; !ok {
		document["stats"] = map[string]any{}
	}
	policy, _ := document["policy"].(map[string]any)
	if policy == nil {
		policy = map[string]any{}
	}
	system, _ := policy["system"].(map[string]any)
	if system == nil {
		system = map[string]any{}
	}
	system["statsOutboundUplink"] = true
	system["statsOutboundDownlink"] = true
	policy["system"] = system
	document["policy"] = policy
	normalized, err := json.Marshal(document)
	if err != nil {
		return nil, nil, err
	}
	meta, err := parseConfigMeta(normalized)
	if err != nil {
		return nil, nil, err
	}
	return normalized, meta, nil
}

func buildInstance(data []byte) (*core.Instance, error) {
	pbConfig, err := serial.LoadJSONConfig(bytes.NewReader(data))
	if err != nil {
		return nil, err
	}
	return core.New(pbConfig)
}

func routerOf(instance *core.Instance) routing.BalancerOverrider {
	overrider, _ := instance.GetFeature(routing.RouterType()).(routing.BalancerOverrider)
	return overrider
}

// startEngineLocked builds and starts an instance from lastConfig. The caller
// holds configMu.
func startEngineLocked() error {
	if lastConfig == nil {
		return errConfigNotApplied
	}
	instance, err := buildInstance(lastConfig)
	if err != nil {
		return err
	}
	if err := instance.Start(); err != nil {
		_ = instance.Close()
		return err
	}
	installLogHandler()
	if afterEngineStart != nil {
		if err := afterEngineStart(instance); err != nil {
			_ = instance.Close()
			return err
		}
	}
	currentEngine.Store(&engine{instance: instance, meta: lastMeta})
	replaySelections()
	return nil
}

func stopEngineLocked() {
	if running := currentEngine.Swap(nil); running != nil {
		if err := running.instance.Close(); err != nil {
			logx.Warnf("[APP] close instance: %v", err)
		}
	}
}

func replaySelections() {
	selectMu.Lock()
	defer selectMu.Unlock()
	running := currentEngine.Load()
	if running == nil {
		return
	}
	overrider := routerOf(running.instance)
	for group, proxy := range selected {
		balancer, ok := running.meta.balancer(group)
		if !ok || overrider == nil {
			delete(selected, group)
			continue
		}
		if !containsTag(running.meta.members(balancer), proxy) {
			delete(selected, group)
			continue
		}
		_ = overrider.SetOverrideTarget(group, proxy)
	}
}

func containsTag(tags []string, tag string) bool {
	for _, candidate := range tags {
		if candidate == tag {
			return true
		}
	}
	return false
}

// applyConfig reads the host's config, replaces the engine and, when the
// listeners are meant to be up, starts it.
func applyConfig(params *SetupParams) error {
	configMu.Lock()
	defer configMu.Unlock()

	setTestURL(params.TestURL)
	setLogLevel(params.LogLevel)
	data, err := os.ReadFile(configPath())
	if err != nil {
		return err
	}
	normalized, meta, err := normalizeConfig(data)
	if err != nil {
		return err
	}
	if _, err := serial.LoadJSONConfig(bytes.NewReader(normalized)); err != nil {
		return err
	}

	stopEngineLocked()
	lastConfig, lastMeta = normalized, meta

	selectMu.Lock()
	selected = map[string]string{}
	for group, proxy := range params.SelectedMap {
		selected[group] = proxy
	}
	selectMu.Unlock()

	if isRunning.Load() {
		if err := startEngineLocked(); err != nil {
			return err
		}
	}
	bumpRouteEpoch()
	return nil
}

var setupConfig = applyConfig

// Xray reads geoip.dat and geosite.dat from this directory.
func setAssetLocation(dir string) {
	_ = os.Setenv("XRAY_LOCATION_ASSET", dir)
}
