package main

import (
	"bytes"
	"context"
	"encoding/json"
	"os"
	"runtime"
	"runtime/debug"
	"sync/atomic"
	"time"

	"core/logx"

	"github.com/xtls/xray-core/infra/conf"
	"github.com/xtls/xray-core/infra/conf/serial"
)

func handleInitCore(params *InitParams) bool {
	configMu.Lock()
	defer configMu.Unlock()
	sdkVersion.Store(int32(params.Version))
	homeDir = params.HomeDir
	setAssetLocation(params.HomeDir)
	initOwnership(params.HomeDir)
	isInit.Store(true)
	return true
}

func handleStartListener() bool {
	configMu.Lock()
	defer configMu.Unlock()
	isRunning.Store(true)
	if currentEngine.Load() == nil && lastConfig != nil {
		if err := startEngineLocked(); err != nil {
			isRunning.Store(false)
			logError("start listeners: %v", err)
			return false
		}
	}
	return true
}

func handleStopListener() bool {
	configMu.Lock()
	defer configMu.Unlock()
	isRunning.Store(false)
	stopEngineLocked()
	return true
}

func handleGetIsInit() bool {
	return isInit.Load()
}

func handleForceGC() {
	logx.Infof("[APP] request force GC")
	runtime.GC()
	if runtime.GOOS == "android" {
		debug.FreeOSMemory()
	}
}

func handleShutdown() bool {
	handleStopLog()
	stopRouteWatch()

	configMu.Lock()
	isRunning.Store(false)
	stopEngineLocked()
	lastConfig, lastMeta = nil, nil
	isInit.Store(false)
	configMu.Unlock()

	handleForceGC()
	return true
}

func handleValidateConfig(path string) string {
	buf, err := os.ReadFile(path)
	if err != nil {
		return err.Error()
	}
	if _, err = serial.LoadJSONConfig(bytes.NewReader(buf)); err != nil {
		return err.Error()
	}
	return ""
}

// Checks each outbound on its own; what spans outbounds, such as a duplicate
// tag, is left to the load itself.
func handleValidateProxies(mappings []map[string]any) []string {
	results := make([]string, len(mappings))
	for i, mapping := range mappings {
		data, err := json.Marshal(mapping)
		if err == nil {
			outbound := &conf.OutboundDetourConfig{}
			if err = json.Unmarshal(data, outbound); err == nil {
				_, err = outbound.Build()
			}
		}
		if err != nil {
			results[i] = err.Error()
		}
	}
	return results
}

func delayTestTimeout(milliseconds int64) time.Duration {
	if milliseconds <= 0 {
		return defaultDelayTestTimeout
	}
	return time.Duration(milliseconds) * time.Millisecond
}

var missingDelayTestProxyAt atomic.Int64

// A delay test against a tag the engine does not know is what a failed apply
// looks like from the outside: the profile still lists every node and every one
// of them reports Timeout. Say so, once a second rather than once per node.
func reportMissingDelayTestProxy(name string) {
	now := time.Now().UnixNano()
	last := missingDelayTestProxyAt.Load()
	if last != 0 && now-last < int64(time.Second) {
		return
	}
	if !missingDelayTestProxyAt.CompareAndSwap(last, now) {
		return
	}
	logError("delay test: %q is not part of the applied config", name)
}

func handleTestDelay(params *TestDelayParams) *Delay {
	url := params.TestUrl
	if url == "" {
		url = currentTestURL()
	}
	delayData := &Delay{
		Name:  params.ProxyName,
		Url:   url,
		Value: -1,
	}

	running := engineForProbes()
	if running == nil {
		return delayData
	}
	if _, ok := running.meta.outbound(params.ProxyName); !ok {
		reportMissingDelayTestProxy(params.ProxyName)
		return delayData
	}

	timeout := delayTestTimeout(params.Timeout)

	// Queueing for a slot and probing the node each get the full timeout.
	// Sharing one deadline meant a node that waited behind a saturated
	// semaphore had little left to connect, so a bulk test of a large
	// subscription reported Timeout for whatever sat at the back of the queue.
	queueCtx, cancelQueue := context.WithTimeout(context.Background(), timeout)
	granted := acquireDelayTestSlot(queueCtx)
	cancelQueue()
	if !granted {
		return nil
	}
	defer releaseDelayTestSlot()

	ctx, cancel := context.WithTimeout(context.Background(), timeout)
	defer cancel()

	elapsed, err := timedGet(ctx, running, params.ProxyName, url)
	if err != nil {
		return delayData
	}
	delayData.Value = max(int32(elapsed.Milliseconds()), 1)
	return delayData
}

// HeapIdle still counts spans the runtime has already handed back to the OS,
// so the retained-but-unused figure subtracts HeapReleased.
func handleGetMemoryStats() MemoryStats {
	var stats runtime.MemStats
	runtime.ReadMemStats(&stats)
	return MemoryStats{
		Rss:          processRss(&stats),
		HeapInuse:    stats.HeapInuse,
		HeapIdle:     stats.HeapIdle - stats.HeapReleased,
		StackInuse:   stats.StackInuse,
		RuntimeOther: stats.MSpanInuse + stats.MCacheInuse + stats.BuckHashSys + stats.GCSys + stats.OtherSys,
	}
}

func handleCrash() {
	panic("handle invoke crash")
}

func handleSetupConfig(params *SetupParams) string {
	if !isInit.Load() {
		return "not initialized"
	}
	if err := setupConfig(params); err != nil {
		return err.Error()
	}
	return ""
}
