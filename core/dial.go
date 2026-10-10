package main

import (
	"context"
	"crypto/tls"
	"net"
	"net/http"
	"time"

	xnet "github.com/xtls/xray-core/common/net"
	"github.com/xtls/xray-core/common/session"
	"github.com/xtls/xray-core/core"
	"github.com/xtls/xray-core/features/routing"
	routingsession "github.com/xtls/xray-core/features/routing/session"
)

// dialThrough opens a connection through the engine. A non-empty tag pins it to
// that outbound; an empty one lets the routing rules decide.
func dialThrough(ctx context.Context, running *engine, tag, address string) (net.Conn, xnet.Destination, error) {
	host, port, err := net.SplitHostPort(address)
	if err != nil {
		return nil, xnet.Destination{}, err
	}
	number, err := xnet.PortFromString(port)
	if err != nil {
		return nil, xnet.Destination{}, err
	}
	destination := xnet.TCPDestination(xnet.ParseAddress(host), number)
	if tag != "" {
		ctx = session.SetForcedOutboundTagToContext(ctx, tag)
	}
	conn, err := core.Dial(ctx, running.instance, destination)
	return conn, destination, err
}

// routeOf names where the routing rules send a destination: the groups it
// passes through, then the outbound, and the rule that chose them.
func routeOf(running *engine, destination xnet.Destination) *probeRoute {
	router, _ := running.instance.GetFeature(routing.RouterType()).(routing.Router)
	if router == nil {
		return &probeRoute{}
	}
	ctx := session.ContextWithOutbounds(context.Background(), []*session.Outbound{{Target: destination}})
	route, err := router.PickRoute(routingsession.AsRoutingContext(ctx))
	if err != nil {
		return &probeRoute{}
	}
	chains := append([]string(nil), route.GetOutboundGroupTags()...)
	if tag := route.GetOutboundTag(); tag != "" {
		chains = append(chains, tag)
	}
	return &probeRoute{chains: chains, rule: route.GetRuleTag()}
}

func newHTTPClient(dial func(ctx context.Context, network, address string) (net.Conn, error), timeout time.Duration) (*http.Client, func()) {
	transport := &http.Transport{
		DialContext:         dial,
		TLSClientConfig:     &tls.Config{},
		TLSHandshakeTimeout: timeout,
		MaxIdleConns:        1,
		IdleConnTimeout:     timeout,
	}
	return &http.Client{Transport: transport}, transport.CloseIdleConnections
}

// timedGet measures a GET through one outbound, up to the response headers.
func timedGet(ctx context.Context, running *engine, tag, url string) (time.Duration, error) {
	client, closeIdle := newHTTPClient(func(ctx context.Context, _ string, address string) (net.Conn, error) {
		conn, _, err := dialThrough(ctx, running, tag, address)
		return conn, err
	}, defaultDelayTestTimeout)
	defer closeIdle()
	request, err := http.NewRequestWithContext(ctx, http.MethodGet, url, nil)
	if err != nil {
		return 0, err
	}
	start := time.Now()
	response, err := client.Do(request)
	if err != nil {
		return 0, err
	}
	_ = response.Body.Close()
	return time.Since(start), nil
}
