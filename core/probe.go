package main

import (
	"bytes"
	"context"
	"errors"
	"fmt"
	"io"
	"net"
	"net/http"
	"sync"
	"time"
)

const (
	probeConcurrency    = 8
	defaultProbeTimeout = 10 * time.Second
	probeErrorTimeout   = "timeout"
	probeErrorFailed    = "failed"

	probeScanChunk   = 32 * 1024
	probeScanOverlap = 256
)

var probeSlots = make(chan struct{}, probeConcurrency)

// probeDialer opens one connection per dial, either pinned to an outbound or
// routed by the rules like any inbound connection, and keeps the route of the
// most recent one, which after redirects is the one that produced the final
// response.
type probeDialer struct {
	running *engine
	tag     string

	mu    sync.Mutex
	route *probeRoute
}

type probeRoute struct {
	chains      []string
	rule        string
	rulePayload string
}

func (d *probeDialer) dial(ctx context.Context, _ string, address string) (net.Conn, error) {
	conn, destination, err := dialThrough(ctx, d.running, d.tag, address)
	if err != nil {
		return nil, err
	}
	route := &probeRoute{chains: []string{d.tag}}
	if d.tag == "" {
		route = routeOf(d.running, destination)
	}
	d.mu.Lock()
	d.route = route
	d.mu.Unlock()
	return conn, nil
}

func (d *probeDialer) lastRoute() *probeRoute {
	d.mu.Lock()
	defer d.mu.Unlock()
	return d.route
}

func probeTimeout(millis int64) time.Duration {
	if millis <= 0 {
		return defaultProbeTimeout
	}
	return time.Duration(millis) * time.Millisecond
}

func probeErrorKind(err error) string {
	var netErr net.Error
	if errors.Is(err, context.DeadlineExceeded) || (errors.As(err, &netErr) && netErr.Timeout()) {
		return probeErrorTimeout
	}
	return probeErrorFailed
}

type probeRequest struct {
	method    string
	url       string
	proxyName string
	headers   map[string]string
	body      []byte
	timeout   time.Duration
	maxBody   int64

	// A followed redirect loses the Location that Netflix names its region in.
	noRedirect bool

	// until sees the latest chunk and probeScanOverlap bytes before it.
	until func(tail string) bool
}

func handleProbe(params *ProbeParams) *ProbeResult {
	return runProbe(context.Background(), probeRequest{
		method:    http.MethodGet,
		url:       params.Url,
		proxyName: params.ProxyName,
		headers:   params.Headers,
		timeout:   probeTimeout(params.Timeout),
		maxBody:   params.MaxBody,
	})
}

// runProbe returns nil when the request never got a slot before its deadline.
func runProbe(parent context.Context, req probeRequest) *ProbeResult {
	result := &ProbeResult{Url: req.url, Chains: []string{}}
	result.CoreEpoch, result.PicksVersion = routeStamp()
	fail := func(err error) *ProbeResult {
		result.Error = probeErrorKind(err)
		result.Message = err.Error()
		return result
	}

	running := currentEngine.Load()
	if running == nil {
		return fail(errConfigNotApplied)
	}
	dialer := &probeDialer{running: running}
	if req.proxyName != "" {
		tag, ok := resolveOutboundTag(running, req.proxyName)
		if !ok {
			return fail(fmt.Errorf("proxy %q is not part of the applied config", req.proxyName))
		}
		dialer.tag = tag
	}

	timeout := req.timeout
	if timeout <= 0 {
		timeout = defaultProbeTimeout
	}
	queueCtx, cancelQueue := context.WithTimeout(parent, timeout)
	granted := acquireSlot(queueCtx, probeSlots)
	cancelQueue()
	if !granted {
		return nil
	}
	defer func() { <-probeSlots }()

	ctx, cancel := context.WithTimeout(parent, timeout)
	defer cancel()

	var body io.Reader
	if len(req.body) > 0 {
		body = bytes.NewReader(req.body)
	}
	method := req.method
	if method == "" {
		method = http.MethodGet
	}
	request, err := http.NewRequestWithContext(ctx, method, req.url, body)
	if err != nil {
		return fail(err)
	}
	for name, value := range req.headers {
		request.Header.Set(name, value)
	}
	client, closeIdle := newHTTPClient(dialer.dial, timeout)
	defer closeIdle()
	if req.noRedirect {
		client.CheckRedirect = func(*http.Request, []*http.Request) error {
			return http.ErrUseLastResponse
		}
	}

	start := time.Now()
	response, err := client.Do(request)
	if err != nil {
		return fail(err)
	}
	defer func() {
		_ = response.Body.Close()
	}()
	result.Delay = time.Since(start).Milliseconds()
	result.StatusCode = response.StatusCode
	result.header = response.Header
	result.Url = response.Request.URL.String()
	if route := dialer.lastRoute(); route != nil {
		result.Chains = route.chains
		result.Rule = route.rule
		result.RulePayload = route.rulePayload
	}
	if req.maxBody > 0 {
		result.Body = readProbeBody(response.Body, req.maxBody, req.until)
	}
	return result
}

func readProbeBody(body io.Reader, maxBody int64, until func(string) bool) string {
	limited := io.LimitReader(body, maxBody)
	if until == nil {
		payload, _ := io.ReadAll(limited)
		return string(payload)
	}
	var buffer bytes.Buffer
	chunk := make([]byte, probeScanChunk)
	for {
		n, err := limited.Read(chunk)
		if n > 0 {
			start := max(0, buffer.Len()-probeScanOverlap)
			buffer.Write(chunk[:n])
			if until(string(buffer.Bytes()[start:])) {
				break
			}
		}
		if err != nil {
			break
		}
	}
	return buffer.String()
}

func acquireSlot(ctx context.Context, slots chan struct{}) bool {
	if ctx.Err() != nil {
		return false
	}
	select {
	case slots <- struct{}{}:
		return true
	case <-ctx.Done():
		return false
	}
}

// A group name pins to the member the host selected, or its first member.
func resolveOutboundTag(running *engine, name string) (string, bool) {
	if _, ok := running.meta.outbound(name); ok {
		return name, true
	}
	balancer, ok := running.meta.balancer(name)
	if !ok {
		return "", false
	}
	selectMu.Lock()
	choice := selected[name]
	selectMu.Unlock()
	if choice != "" {
		return choice, true
	}
	members := running.meta.members(balancer)
	if len(members) == 0 {
		return "", false
	}
	return members[0], true
}
