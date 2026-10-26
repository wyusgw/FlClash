package main

import (
	"bytes"
	"context"
	"crypto/rand"
	"errors"
	"net"
	"net/netip"
	"os"
	"slices"
	"sync/atomic"
	"syscall"
	"time"

	"github.com/xtls/xray-core/transport/internet"
	"golang.org/x/net/icmp"
	"golang.org/x/net/ipv4"
	"golang.org/x/net/ipv6"
)

const (
	icmpPayloadSize  = 16
	icmpProtocolIPv4 = 1
	icmpProtocolIPv6 = 58
)

type IcmpPingParams struct {
	Host    string `json:"host"`
	Timeout int64  `json:"timeout"`
}

var icmpSequence atomic.Uint32

// handleIcmpPing returns the milliseconds one echo request to host takes to be
// answered, or -1 when the host does not resolve, the ping cannot be sent, or
// no reply arrives within the timeout. Many servers drop ICMP, so -1 does not
// mean the node is down.
func handleIcmpPing(params *IcmpPingParams) int64 {
	timeout := delayTestTimeout(params.Timeout)
	deadline := time.Now().Add(timeout)
	ip, err := resolveIcmpTarget(params.Host, deadline)
	if err != nil {
		return -1
	}
	elapsed, err := icmpEcho(ip, deadline)
	if err != nil {
		return -1
	}
	return min(max(elapsed.Milliseconds(), 1), timeout.Milliseconds())
}

// resolveIcmpTarget prefers an IPv4 address, which more networks route.
func resolveIcmpTarget(host string, deadline time.Time) (netip.Addr, error) {
	if ip, err := netip.ParseAddr(host); err == nil {
		return ip.Unmap(), nil
	}
	ctx, cancel := context.WithDeadline(context.Background(), deadline)
	defer cancel()
	ips, err := net.DefaultResolver.LookupNetIP(ctx, "ip", host)
	if err != nil {
		return netip.Addr{}, err
	}
	if len(ips) == 0 {
		return netip.Addr{}, errors.New("no address")
	}
	for _, ip := range ips {
		if ip.Unmap().Is4() {
			return ip.Unmap(), nil
		}
	}
	return ips[0], nil
}

// applyDialerControllers runs the socket through the controllers Xray runs its
// own dials through, so the ping leaves the way the proxy's connections do:
// protected from the VpnService on Android, and bound to the physical
// interface while a desktop TUN is up. Inside the tunnel the TUN would answer
// the echo itself.
func applyDialerControllers(conn net.PacketConn, ip netip.Addr) error {
	sc, ok := conn.(syscall.Conn)
	if !ok {
		return nil
	}
	raw, err := sc.SyscallConn()
	if err != nil {
		return err
	}
	network := "udp4"
	if ip.Is6() {
		network = "udp6"
	}
	address := netip.AddrPortFrom(ip, 0).String()
	internet.ControllersLock.Lock()
	controllers := slices.Clone(internet.Controllers)
	internet.ControllersLock.Unlock()
	for _, ctl := range controllers {
		if err := ctl(network, address, raw); err != nil {
			return err
		}
	}
	return nil
}

// echoOver sends one echo request on conn and waits for its reply, told from
// other traffic on the socket by its source, sequence and payload; the
// identifier is not compared, since Linux rewrites it on datagram sockets.
func echoOver(conn net.PacketConn, dst net.Addr, ip netip.Addr, deadline time.Time) (time.Duration, error) {
	token := make([]byte, icmpPayloadSize)
	_, _ = rand.Read(token)
	sequence := int(icmpSequence.Add(1) & 0xffff)

	var request, reply icmp.Type = ipv4.ICMPTypeEcho, ipv4.ICMPTypeEchoReply
	protocol := icmpProtocolIPv4
	if ip.Is6() {
		request, reply = ipv6.ICMPTypeEchoRequest, ipv6.ICMPTypeEchoReply
		protocol = icmpProtocolIPv6
	}
	// The kernel fills in the ICMPv6 checksum, which covers a pseudo header
	// only it knows the source of.
	message, err := (&icmp.Message{
		Type: request,
		Body: &icmp.Echo{ID: os.Getpid() & 0xffff, Seq: sequence, Data: token},
	}).Marshal(nil)
	if err != nil {
		return 0, err
	}
	if err := conn.SetDeadline(deadline); err != nil {
		return 0, err
	}

	start := time.Now()
	if _, err := conn.WriteTo(message, dst); err != nil {
		return 0, err
	}
	buffer := make([]byte, 1500)
	for {
		n, from, err := conn.ReadFrom(buffer)
		if err != nil {
			return 0, err
		}
		if addrOf(from) != ip {
			continue
		}
		parsed, err := icmp.ParseMessage(protocol, stripIPv4Header(buffer[:n]))
		if err != nil || parsed.Type != reply {
			continue
		}
		echo, ok := parsed.Body.(*icmp.Echo)
		if ok && echo.Seq == sequence && bytes.Equal(echo.Data, token) {
			return time.Since(start), nil
		}
	}
}

func addrOf(addr net.Addr) netip.Addr {
	var ip net.IP
	switch addr := addr.(type) {
	case *net.UDPAddr:
		ip = addr.IP
	case *net.IPAddr:
		ip = addr.IP
	}
	parsed, _ := netip.AddrFromSlice(ip)
	return parsed.Unmap()
}

// stripIPv4Header drops the IPv4 header that raw sockets, and datagram ones on
// macOS, hand back in front of the ICMP message. An ICMP message never starts
// with a version nibble of 4: an echo reply's type is 0.
func stripIPv4Header(packet []byte) []byte {
	if len(packet) < 20 || packet[0]>>4 != 4 {
		return packet
	}
	headerLength := int(packet[0]&0x0f) * 4
	if headerLength < 20 || headerLength > len(packet) {
		return packet
	}
	return packet[headerLength:]
}
