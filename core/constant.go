package main

import "net/http"

type InitParams struct {
	HomeDir string `json:"home-dir"`
	Version int    `json:"version"`
}

type SetupParams struct {
	TestURL  string `json:"test-url"`
	LogLevel string `json:"log-level"`
}

type RouteState struct {
	CoreEpoch    uint64            `json:"core-epoch"`
	PicksVersion uint64            `json:"picks-version"`
	Picks        map[string]string `json:"picks"`
}

type TestDelayParams struct {
	ProxyName string `json:"proxy-name"`
	TestUrl   string `json:"test-url"`
	Timeout   int64  `json:"timeout"`
}

type ProbeParams struct {
	Url       string            `json:"url"`
	ProxyName string            `json:"proxy-name"`
	Headers   map[string]string `json:"headers"`
	Timeout   int64             `json:"timeout"`
	MaxBody   int64             `json:"max-body"`
}

type ProbeResult struct {
	StatusCode  int      `json:"status-code"`
	Delay       int64    `json:"delay"`
	Body        string   `json:"body"`
	Url         string   `json:"url"`
	Chains      []string `json:"chains"`
	Rule        string   `json:"rule"`
	RulePayload string   `json:"rule-payload"`
	Error       string   `json:"error,omitempty"`
	Message     string   `json:"message,omitempty"`

	CoreEpoch    uint64 `json:"core-epoch"`
	PicksVersion uint64 `json:"picks-version"`

	// Unexported, so it never reaches Dart: only the in-core checks read
	// response headers, and ProbeResult is the shape the Dart side decodes.
	header http.Header
}

type Traffic struct {
	Up   int64 `json:"up"`
	Down int64 `json:"down"`
}

type MemoryStats struct {
	Rss          uint64 `json:"rss"`
	HeapInuse    uint64 `json:"heapInuse"`
	HeapIdle     uint64 `json:"heapIdle"`
	StackInuse   uint64 `json:"stackInuse"`
	RuntimeOther uint64 `json:"runtimeOther"`
}

const (
	messageMethod         CoreMethod = "message"
	initCoreMethod        CoreMethod = "initCore"
	getIsInitMethod       CoreMethod = "getIsInit"
	forceGcMethod         CoreMethod = "forceGc"
	shutdownMethod        CoreMethod = "shutdown"
	validateConfigMethod  CoreMethod = "validateConfig"
	validateProxiesMethod CoreMethod = "validateProxies"
	setupConfigMethod     CoreMethod = "setupConfig"
	getTrafficMethod      CoreMethod = "getTraffic"
	getTotalTrafficMethod CoreMethod = "getTotalTraffic"
	resetTrafficMethod    CoreMethod = "resetTraffic"
	asyncTestDelayMethod  CoreMethod = "asyncTestDelay"
	probeMethod           CoreMethod = "probe"
	outboundIpMethod      CoreMethod = "outboundIp"
	serviceCheckMethod    CoreMethod = "serviceCheck"
	getMemoryStatsMethod  CoreMethod = "getMemoryStats"
	startLogMethod        CoreMethod = "startLog"
	stopLogMethod         CoreMethod = "stopLog"
	startListenerMethod   CoreMethod = "startListener"
	stopListenerMethod    CoreMethod = "stopListener"
	updateDnsMethod       CoreMethod = "updateDns"
	crashMethod           CoreMethod = "crash"
	watchRouteMethod      CoreMethod = "watchRoute"
)

type CoreMethod string

type MessageType string

type Delay struct {
	Url   string `json:"url"`
	Name  string `json:"name"`
	Value int32  `json:"value"`
}

type Message struct {
	Type MessageType `json:"type"`
	Data any         `json:"data"`
}

const (
	LogMessage   MessageType = "log"
	DelayMessage MessageType = "delay"
	// Named after the Dart enum value, which is how CoreEvent.fromJson decodes it.
	RouteChangedMessage MessageType = "routeChanged"
)

type logEvent struct {
	LogLevel string `json:"LogLevel"`
	Payload  string `json:"Payload"`
}
