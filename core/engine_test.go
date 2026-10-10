package main

import (
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"os"
	"path/filepath"
	"regexp"
	"slices"
	"strings"
	"testing"
	"time"
)

func probeServer(t *testing.T, handler http.HandlerFunc) *httptest.Server {
	t.Helper()
	server := httptest.NewServer(handler)
	t.Cleanup(server.Close)
	return server
}

const groupedConfig = `{
  "outbounds": [
    {"tag": "node-a", "protocol": "freedom"},
    {"tag": "node-b", "protocol": "freedom"},
    {"tag": "direct", "protocol": "freedom"}
  ],
  "routing": {
    "balancers": [
      {"tag": "PROXY", "selector": ["node-"], "strategy": {"type": "random"}}
    ],
    "rules": [{"type": "field", "network": "tcp,udp", "balancerTag": "PROXY"}]
  }
}`

func resetEngineState() {
	configMu.Lock()
	isRunning.Store(false)
	stopEngineLocked()
	lastConfig, lastMeta = nil, nil
	isInit.Store(false)
	configMu.Unlock()

	selectMu.Lock()
	selected = map[string]string{}
	selectMu.Unlock()
	currentRoute = routeTracker{}
	sampleMu.Lock()
	samples = map[bool]trafficSample{}
	sampleMu.Unlock()
}

// startEngine applies config as the host would: written to the home directory,
// then set up with the listeners running.
func startEngine(t *testing.T, config string) {
	t.Helper()
	startEngineIn(t, t.TempDir(), config)
}

func startEngineIn(t *testing.T, dir, config string) {
	t.Helper()
	resetEngineState()
	if err := os.WriteFile(filepath.Join(dir, configFileName), []byte(config), 0o600); err != nil {
		t.Fatal(err)
	}
	if !handleInitCore(&InitParams{HomeDir: dir}) {
		t.Fatal("handleInitCore failed")
	}
	isRunning.Store(true)
	if message := handleSetupConfig(defaultSetupParams()); message != "" {
		t.Fatalf("setup failed: %s", message)
	}
	t.Cleanup(resetEngineState)
}

func withProbeProxies(t *testing.T, names ...string) {
	t.Helper()
	outbounds := make([]map[string]string, 0, len(names))
	for _, name := range names {
		outbounds = append(outbounds, map[string]string{"tag": name, "protocol": "freedom"})
	}
	config, err := json.Marshal(map[string]any{"outbounds": outbounds})
	if err != nil {
		t.Fatal(err)
	}
	startEngine(t, string(config))
}

func TestNormalizeConfigAddsTheTrafficCounters(t *testing.T) {
	normalized, _, err := normalizeConfig([]byte(`{"outbounds":[]}`))
	if err != nil {
		t.Fatal(err)
	}
	var document map[string]any
	if err := json.Unmarshal(normalized, &document); err != nil {
		t.Fatal(err)
	}
	if _, ok := document["stats"]; !ok {
		t.Error("stats section missing")
	}
	system := document["policy"].(map[string]any)["system"].(map[string]any)
	if system["statsOutboundUplink"] != true || system["statsOutboundDownlink"] != true {
		t.Errorf("policy.system = %v, want outbound counters on", system)
	}
}

func TestNormalizeConfigKeepsThePolicyTheHostWrote(t *testing.T) {
	normalized, _, err := normalizeConfig([]byte(
		`{"policy":{"levels":{"0":{"handshake":4}},"system":{"statsInboundUplink":true}}}`,
	))
	if err != nil {
		t.Fatal(err)
	}
	policy := map[string]any{}
	if err := json.Unmarshal(normalized, &struct {
		Policy *map[string]any `json:"policy"`
	}{&policy}); err != nil {
		t.Fatal(err)
	}
	if _, ok := policy["levels"]; !ok {
		t.Error("levels dropped")
	}
	if policy["system"].(map[string]any)["statsInboundUplink"] != true {
		t.Error("existing system flag dropped")
	}
}

func TestNormalizeConfigRejectsMalformedJson(t *testing.T) {
	if _, _, err := normalizeConfig([]byte(`{`)); err == nil {
		t.Fatal("normalizeConfig accepted malformed JSON")
	}
}

func TestBalancerMembersFollowTheSelectorPrefixes(t *testing.T) {
	_, meta, err := normalizeConfig([]byte(groupedConfig))
	if err != nil {
		t.Fatal(err)
	}
	balancer, ok := meta.balancer("PROXY")
	if !ok {
		t.Fatal("PROXY balancer not parsed")
	}
	if got := meta.members(balancer); !slices.Equal(got, []string{"node-a", "node-b"}) {
		t.Errorf("members = %v, want [node-a node-b]", got)
	}
}

func TestIsProxyExcludesDirectAndBlockOutbounds(t *testing.T) {
	meta := &configMeta{outbounds: []outboundMeta{
		{Tag: "a", Protocol: "vless"},
		{Tag: "d", Protocol: "freedom"},
		{Tag: "b", Protocol: "blackhole"},
	}}
	for tag, want := range map[string]bool{"a": true, "d": false, "b": false, "missing": false} {
		if got := meta.isProxy(tag); got != want {
			t.Errorf("isProxy(%s) = %v, want %v", tag, got, want)
		}
	}
}

func TestHandleGetProxiesListsNodesAndGroups(t *testing.T) {
	startEngine(t, groupedConfig)

	data := handleGetProxies()

	if !slices.Equal(data.All, []string{"PROXY"}) {
		t.Errorf("all = %v, want [PROXY]", data.All)
	}
	group, ok := data.Proxies["PROXY"].(groupView)
	if !ok {
		t.Fatalf("PROXY is %T, want groupView", data.Proxies["PROXY"])
	}
	if group.Type != "Selector" || !slices.Equal(group.All, []string{"node-a", "node-b"}) || group.Now != "" {
		t.Errorf("group = %+v", group)
	}
	if node, ok := data.Proxies["node-a"].(nodeView); !ok || node.Type != "freedom" {
		t.Errorf("node-a = %#v", data.Proxies["node-a"])
	}
}

func TestHandleGetProxiesIsEmptyBeforeAnApply(t *testing.T) {
	resetEngineState()
	data := handleGetProxies()
	if len(data.All) != 0 || len(data.Proxies) != 0 {
		t.Errorf("data = %+v, want empty", data)
	}
}

func TestHandleChangeProxyReportsWhetherThePickMoved(t *testing.T) {
	startEngine(t, groupedConfig)
	_, firstVersion := routeStamp()

	first := handleChangeProxy(&ChangeProxyParams{GroupName: "PROXY", ProxyName: "node-b"})
	again := handleChangeProxy(&ChangeProxyParams{GroupName: "PROXY", ProxyName: "node-b"})

	if first.Message != "" || !first.Changed {
		t.Errorf("first = %+v, want a change", first)
	}
	if again.Message != "" || again.Changed {
		t.Errorf("again = %+v, want no change", again)
	}
	if now := handleGetProxies().Proxies["PROXY"].(groupView).Now; now != "node-b" {
		t.Errorf("now = %q, want node-b", now)
	}
	if _, version := routeStamp(); version != firstVersion+1 {
		t.Errorf("picks version = %d, want %d", version, firstVersion+1)
	}
}

func TestHandleChangeProxyRejectsWhatIsNotInTheConfig(t *testing.T) {
	startEngine(t, groupedConfig)

	if got := handleChangeProxy(&ChangeProxyParams{GroupName: "missing", ProxyName: "node-a"}); got.Message != errGroupNotFound.Error() {
		t.Errorf("unknown group: %+v", got)
	}
	if got := handleChangeProxy(&ChangeProxyParams{GroupName: "PROXY", ProxyName: "direct"}); got.Message != errNotInGroup.Error() {
		t.Errorf("non-member: %+v", got)
	}
}

func TestHandleChangeProxyClearsASelection(t *testing.T) {
	startEngine(t, groupedConfig)
	handleChangeProxy(&ChangeProxyParams{GroupName: "PROXY", ProxyName: "node-a"})

	cleared := handleChangeProxy(&ChangeProxyParams{GroupName: "PROXY"})

	if cleared.Message != "" || !cleared.Changed {
		t.Errorf("cleared = %+v", cleared)
	}
	if now := handleGetProxies().Proxies["PROXY"].(groupView).Now; now != "" {
		t.Errorf("now = %q, want none", now)
	}
}

func TestSelectionSurvivesAReapplyAndARestart(t *testing.T) {
	startEngine(t, groupedConfig)
	handleChangeProxy(&ChangeProxyParams{GroupName: "PROXY", ProxyName: "node-b"})

	if message := handleSetupConfig(&SetupParams{
		SelectedMap: map[string]string{"PROXY": "node-b"},
	}); message != "" {
		t.Fatal(message)
	}
	if now := handleGetProxies().Proxies["PROXY"].(groupView).Now; now != "node-b" {
		t.Errorf("after reapply now = %q, want node-b", now)
	}

	handleStopListener()
	if !handleStartListener() {
		t.Fatal("listeners did not come back")
	}
	if now := handleGetProxies().Proxies["PROXY"].(groupView).Now; now != "node-b" {
		t.Errorf("after restart now = %q, want node-b", now)
	}
}

func TestReapplyDropsASelectionTheNewConfigNoLongerHas(t *testing.T) {
	startEngine(t, groupedConfig)
	handleChangeProxy(&ChangeProxyParams{GroupName: "PROXY", ProxyName: "node-b"})
	next := strings.Replace(groupedConfig, `{"tag": "node-b", "protocol": "freedom"},`, "", 1)
	if err := os.WriteFile(configPath(), []byte(next), 0o600); err != nil {
		t.Fatal(err)
	}

	if message := handleSetupConfig(&SetupParams{SelectedMap: map[string]string{"PROXY": "node-b"}}); message != "" {
		t.Fatal(message)
	}

	if now := handleGetProxies().Proxies["PROXY"].(groupView).Now; now != "" {
		t.Errorf("now = %q, want the stale selection dropped", now)
	}
}

func TestStopListenerClosesTheEngineAndStartBringsItBack(t *testing.T) {
	startEngine(t, groupedConfig)

	handleStopListener()
	if currentEngine.Load() != nil {
		t.Fatal("engine still published after stopListener")
	}
	if len(handleGetProxies().All) != 0 {
		t.Error("groups listed with the engine stopped")
	}

	if !handleStartListener() || currentEngine.Load() == nil {
		t.Fatal("startListener did not rebuild the engine")
	}
}

func TestSetupWithoutListenersDoesNotStartTheEngine(t *testing.T) {
	resetEngineState()
	dir := t.TempDir()
	if err := os.WriteFile(filepath.Join(dir, configFileName), []byte(groupedConfig), 0o600); err != nil {
		t.Fatal(err)
	}
	t.Cleanup(resetEngineState)
	handleInitCore(&InitParams{HomeDir: dir})

	if message := handleSetupConfig(defaultSetupParams()); message != "" {
		t.Fatal(message)
	}

	if currentEngine.Load() != nil {
		t.Error("engine started although the listeners are off")
	}
}

func TestSetupReportsABrokenConfigAndKeepsTheRunningEngine(t *testing.T) {
	startEngine(t, groupedConfig)
	running := currentEngine.Load()
	if err := os.WriteFile(configPath(), []byte(`{"outbounds":[{"tag":"x","protocol":"nope"}]}`), 0o600); err != nil {
		t.Fatal(err)
	}

	message := handleSetupConfig(defaultSetupParams())

	if message == "" {
		t.Fatal("setup accepted an unknown protocol")
	}
	if currentEngine.Load() != running {
		t.Error("a failed apply replaced the running engine")
	}
}

func TestSetupRequiresInit(t *testing.T) {
	resetEngineState()
	if got := handleSetupConfig(defaultSetupParams()); got != "not initialized" {
		t.Errorf("got %q", got)
	}
}

func TestHandleValidateConfig(t *testing.T) {
	dir := t.TempDir()
	good := filepath.Join(dir, "good.json")
	bad := filepath.Join(dir, "bad.json")
	_ = os.WriteFile(good, []byte(groupedConfig), 0o600)
	_ = os.WriteFile(bad, []byte(`{"outbounds":[{"protocol":"vless","settings":{}}]}`), 0o600)

	if got := handleValidateConfig(good); got != "" {
		t.Errorf("valid config reported %q", got)
	}
	if got := handleValidateConfig(bad); got == "" {
		t.Error("invalid config accepted")
	}
	if got := handleValidateConfig(filepath.Join(dir, "missing.json")); got == "" {
		t.Error("missing file accepted")
	}
}

func TestHandleValidateProxiesReportsEachOutboundInPlace(t *testing.T) {
	results := handleValidateProxies([]map[string]any{
		{"tag": "ok", "protocol": "freedom"},
		{"tag": "bad", "protocol": "vless", "settings": map[string]any{}},
	})

	if len(results) != 2 {
		t.Fatalf("results = %v", results)
	}
	if results[0] != "" {
		t.Errorf("valid outbound reported %q", results[0])
	}
	if results[1] == "" {
		t.Error("vless outbound without a server accepted")
	}
}

func TestHandleTestDelayMeasuresThroughTheNode(t *testing.T) {
	server := probeServer(t, func(w http.ResponseWriter, _ *http.Request) {
		w.WriteHeader(http.StatusNoContent)
	})
	withProbeProxies(t, "node-a")

	delay := handleTestDelay(&TestDelayParams{ProxyName: "node-a", TestUrl: server.URL, Timeout: 3000})

	if delay == nil || delay.Value < 1 {
		t.Fatalf("delay = %+v, want a positive measurement", delay)
	}
	if delay.Name != "node-a" || delay.Url != server.URL {
		t.Errorf("delay = %+v", delay)
	}
}

func TestHandleTestDelayReportsTimeoutForADeadNode(t *testing.T) {
	server := probeServer(t, func(w http.ResponseWriter, _ *http.Request) {
		time.Sleep(time.Second)
	})
	withProbeProxies(t, "node-a")

	delay := handleTestDelay(&TestDelayParams{ProxyName: "node-a", TestUrl: server.URL, Timeout: 100})

	if delay == nil || delay.Value != -1 {
		t.Errorf("delay = %+v, want -1", delay)
	}
}

func TestHandleTestDelayRejectsAnUnknownProxyWithoutWaitingForASlot(t *testing.T) {
	withProbeProxies(t, "node-a")
	for i := 0; i < delayTestConcurrency; i++ {
		delayTestSlots <- struct{}{}
	}
	t.Cleanup(func() {
		for i := 0; i < delayTestConcurrency; i++ {
			<-delayTestSlots
		}
	})

	started := time.Now()
	delay := handleTestDelay(&TestDelayParams{ProxyName: "missing", Timeout: 5000})

	if delay == nil || delay.Value != -1 {
		t.Fatalf("delay = %+v, want -1", delay)
	}
	if time.Since(started) > time.Second {
		t.Error("an unknown node queued for a slot")
	}
}

func TestHandleTestDelayWithoutAnEngine(t *testing.T) {
	resetEngineState()
	delay := handleTestDelay(&TestDelayParams{ProxyName: "node-a"})
	if delay == nil || delay.Value != -1 {
		t.Errorf("delay = %+v, want -1", delay)
	}
}

func TestTrafficCountsBytesThroughAnOutbound(t *testing.T) {
	server := probeServer(t, func(w http.ResponseWriter, _ *http.Request) {
		_, _ = w.Write([]byte(strings.Repeat("x", 4096)))
	})
	withProbeProxies(t, "node-a")

	result := handleProbe(&ProbeParams{Url: server.URL, ProxyName: "node-a", Timeout: 3000, MaxBody: 8192})
	if result == nil || result.Error != "" {
		t.Fatalf("probe = %+v", result)
	}

	up, down := totals(false)
	if up <= 0 || down < 4096 {
		t.Errorf("totals = up %d down %d, want the request and the 4 KiB body", up, down)
	}
	if proxiedUp, proxiedDown := totals(true); proxiedUp != 0 || proxiedDown != 0 {
		t.Errorf("proxied totals = %d/%d, want freedom excluded", proxiedUp, proxiedDown)
	}

	handleResetTraffic()
	if up, down := totals(false); up != 0 || down != 0 {
		t.Errorf("after reset totals = %d/%d", up, down)
	}
}

func TestHandleGetTrafficReturnsARateFromTwoSamples(t *testing.T) {
	withProbeProxies(t, "node-a")
	if first := handleGetTraffic(false); first != (Traffic{}) {
		t.Errorf("first sample = %+v, want zero", first)
	}
	time.Sleep(20 * time.Millisecond)
	if second := handleGetTraffic(false); second.Up < 0 || second.Down < 0 {
		t.Errorf("second sample = %+v", second)
	}
}

func TestHandleProbePinsTheNamedProxy(t *testing.T) {
	var userAgent string
	server := probeServer(t, func(w http.ResponseWriter, r *http.Request) {
		userAgent = r.UserAgent()
		w.WriteHeader(http.StatusForbidden)
		_, _ = w.Write([]byte("ip=203.0.113.7\nloc=US\n"))
	})
	withProbeProxies(t, "node-a")

	result := handleProbe(&ProbeParams{
		Url:       server.URL + "/trace",
		ProxyName: "node-a",
		Headers:   map[string]string{"User-Agent": "probe-test"},
		Timeout:   2000,
		MaxBody:   1024,
	})

	if result == nil || result.Error != "" {
		t.Fatalf("result = %+v", result)
	}
	if result.StatusCode != http.StatusForbidden || result.Body != "ip=203.0.113.7\nloc=US\n" {
		t.Errorf("status %d body %q", result.StatusCode, result.Body)
	}
	if !slices.Equal(result.Chains, []string{"node-a"}) {
		t.Errorf("chains = %v, want [node-a]", result.Chains)
	}
	if userAgent != "probe-test" {
		t.Errorf("user agent = %q", userAgent)
	}
}

func TestHandleProbeResolvesAGroupToItsSelection(t *testing.T) {
	server := probeServer(t, func(w http.ResponseWriter, _ *http.Request) {})
	startEngine(t, groupedConfig)
	handleChangeProxy(&ChangeProxyParams{GroupName: "PROXY", ProxyName: "node-b"})

	result := handleProbe(&ProbeParams{Url: server.URL, ProxyName: "PROXY", Timeout: 2000})

	if result == nil || result.Error != "" {
		t.Fatalf("result = %+v", result)
	}
	if !slices.Equal(result.Chains, []string{"node-b"}) {
		t.Errorf("chains = %v, want [node-b]", result.Chains)
	}
}

func TestHandleProbeRoutedByTheRulesEndsAtTheSelectedNode(t *testing.T) {
	server := probeServer(t, func(w http.ResponseWriter, _ *http.Request) {})
	startEngine(t, groupedConfig)
	handleChangeProxy(&ChangeProxyParams{GroupName: "PROXY", ProxyName: "node-a"})

	result := handleProbe(&ProbeParams{Url: server.URL, Timeout: 2000})

	if result == nil || result.Error != "" {
		t.Fatalf("result = %+v", result)
	}
	if len(result.Chains) == 0 || result.Chains[len(result.Chains)-1] != "node-a" {
		t.Errorf("chains = %v, want the route to end at the selected node", result.Chains)
	}
}

func TestHandleProbeRejectsAnUnknownProxyWithoutWaitingForASlot(t *testing.T) {
	withProbeProxies(t, "node-a")
	for i := 0; i < probeConcurrency; i++ {
		probeSlots <- struct{}{}
	}
	t.Cleanup(func() {
		for i := 0; i < probeConcurrency; i++ {
			<-probeSlots
		}
	})

	started := time.Now()
	result := handleProbe(&ProbeParams{Url: "http://127.0.0.1:1/", ProxyName: "missing", Timeout: 5000})

	if result == nil || result.Error != probeErrorFailed {
		t.Fatalf("result = %+v, want a failure", result)
	}
	if time.Since(started) > time.Second {
		t.Error("an unknown proxy queued for a slot")
	}
}

func TestHandleProbeFollowsRedirectsAndCapsTheBody(t *testing.T) {
	final := probeServer(t, func(w http.ResponseWriter, _ *http.Request) {
		_, _ = w.Write([]byte(strings.Repeat("a", 100)))
	})
	redirect := probeServer(t, func(w http.ResponseWriter, r *http.Request) {
		http.Redirect(w, r, final.URL+"/final", http.StatusFound)
	})
	withProbeProxies(t, "node-a")

	result := handleProbe(&ProbeParams{Url: redirect.URL, ProxyName: "node-a", Timeout: 2000, MaxBody: 10})

	if result == nil || result.Error != "" {
		t.Fatalf("result = %+v", result)
	}
	if result.Url != final.URL+"/final" {
		t.Errorf("url = %q, want the redirect target", result.Url)
	}
	if len(result.Body) != 10 {
		t.Errorf("body length = %d, want 10", len(result.Body))
	}
}

func TestHandleProbeReportsATimeout(t *testing.T) {
	server := probeServer(t, func(w http.ResponseWriter, _ *http.Request) {
		time.Sleep(time.Second)
	})
	withProbeProxies(t, "node-a")

	result := handleProbe(&ProbeParams{Url: server.URL, ProxyName: "node-a", Timeout: 100})

	if result == nil || result.Error != probeErrorTimeout {
		t.Errorf("result = %+v, want a timeout", result)
	}
}

func TestHandleProbeWithoutAnEngine(t *testing.T) {
	resetEngineState()
	result := handleProbe(&ProbeParams{Url: "http://127.0.0.1:1/", Timeout: 200})
	if result == nil || result.Error != probeErrorFailed {
		t.Errorf("result = %+v, want a failure", result)
	}
}

func TestProbeAnswersCarryTheRouteStamp(t *testing.T) {
	server := probeServer(t, func(w http.ResponseWriter, _ *http.Request) {})
	startEngine(t, groupedConfig)
	epoch, version := routeStamp()

	result := handleProbe(&ProbeParams{Url: server.URL, Timeout: 2000})

	if result.CoreEpoch != epoch || result.PicksVersion != version {
		t.Errorf("stamp = %d/%d, want %d/%d", result.CoreEpoch, result.PicksVersion, epoch, version)
	}
}

func TestRouteEpochFollowsStructuralChanges(t *testing.T) {
	startEngine(t, groupedConfig)
	epoch, _ := routeStamp()

	if message := handleSetupConfig(defaultSetupParams()); message != "" {
		t.Fatal(message)
	}

	if next, _ := routeStamp(); next != epoch+1 {
		t.Errorf("epoch = %d, want %d after an apply", next, epoch+1)
	}
	handleChangeProxy(&ChangeProxyParams{GroupName: "PROXY", ProxyName: "node-a"})
	if next, _ := routeStamp(); next != epoch+1 {
		t.Errorf("epoch = %d, a selection must not move it", next)
	}
}

func TestWatchRoutePublishesOnlyWhileWatched(t *testing.T) {
	startEngine(t, groupedConfig)
	var published []RouteState
	original := publishRoute
	publishRoute = func(state RouteState) { published = append(published, state) }
	t.Cleanup(func() { publishRoute = original })

	handleChangeProxy(&ChangeProxyParams{GroupName: "PROXY", ProxyName: "node-a"})
	if len(published) != 0 {
		t.Fatalf("published %d states while unwatched", len(published))
	}
	handleWatchRoute(true, methodCallSeq.Add(1))
	handleChangeProxy(&ChangeProxyParams{GroupName: "PROXY", ProxyName: "node-b"})
	if len(published) != 1 || published[0].Picks["PROXY"] != "node-b" {
		t.Errorf("published = %+v", published)
	}
}

func TestWatchRouteIgnoresAnOlderIntent(t *testing.T) {
	startEngine(t, groupedConfig)
	older := methodCallSeq.Add(1)
	newer := methodCallSeq.Add(1)

	handleWatchRoute(true, newer)
	handleWatchRoute(false, older)

	currentRoute.mu.Lock()
	watched := currentRoute.watched
	currentRoute.mu.Unlock()
	if !watched {
		t.Error("an older unwatch overrode a newer watch")
	}
}

func TestStopRouteWatchOutranksEarlierWatches(t *testing.T) {
	startEngine(t, groupedConfig)
	pending := methodCallSeq.Add(1)

	stopRouteWatch()
	handleWatchRoute(true, pending)

	currentRoute.mu.Lock()
	watched := currentRoute.watched
	currentRoute.mu.Unlock()
	if watched {
		t.Error("a watch dispatched before the stop re-armed the watch")
	}
}

func TestHandleShutdownTearsDownTheEngine(t *testing.T) {
	startEngine(t, groupedConfig)
	handleLogOn := logStreaming.Load()
	handleStartLog()

	handleShutdown()

	if currentEngine.Load() != nil || isRunning.Load() || isInit.Load() {
		t.Error("shutdown left the engine up")
	}
	if logStreaming.Load() != false && !handleLogOn {
		t.Error("shutdown left log streaming on")
	}
}

func TestHandleGetMemoryStatsReportsALiveRuntime(t *testing.T) {
	stats := handleGetMemoryStats()
	if stats.Rss == 0 || stats.HeapInuse == 0 {
		t.Errorf("stats = %+v, want live figures", stats)
	}
}

func TestLevelRank(t *testing.T) {
	for name, want := range map[string]int32{"debug": 4, "INFO": 3, "warning": 2, "error": 1, "silent": 0, "bogus": 3} {
		if got := levelRank(name); got != want {
			t.Errorf("levelRank(%q) = %d, want %d", name, got, want)
		}
	}
}

// The proxies page only lists a group whose type is one of the identifiers of
// the host's GroupType enum, so a type the core invents never shows.
func TestGroupTypeNamesMatchTheHostEnum(t *testing.T) {
	source, err := os.ReadFile("../lib/enum/enum.dart")
	if err != nil {
		t.Fatal(err)
	}
	block := regexp.MustCompile(`(?s)enum GroupType \{(.*?)\n  final String value;`).FindSubmatch(source)
	if block == nil {
		t.Fatal("GroupType enum not found in enum.dart")
	}
	identifiers := map[string]bool{}
	for _, match := range regexp.MustCompile(`\n  (\w+)\('`).FindAllSubmatch(block[1], -1) {
		identifiers[string(match[1])] = true
	}

	for strategy, want := range map[string]string{
		"":           "Selector",
		"random":     "Selector",
		"leastPing":  "URLTest",
		"leastLoad":  "URLTest",
		"roundRobin": "LoadBalance",
	} {
		balancer := balancerMeta{}
		balancer.Strategy.Type = strategy
		got := groupType(balancer)
		if got != want {
			t.Errorf("groupType(%q) = %q, want %q", strategy, got, want)
		}
		if !identifiers[got] {
			t.Errorf("%q is not a GroupType identifier in enum.dart (%v)", got, identifiers)
		}
	}
}
