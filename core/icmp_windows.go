//go:build windows

package main

import (
	"encoding/binary"
	"fmt"
	"net"
	"net/netip"
	"time"
	"unsafe"

	"golang.org/x/sys/windows"
)

var (
	iphlpapi            = windows.NewLazySystemDLL("iphlpapi.dll")
	procIcmpCreateFile  = iphlpapi.NewProc("IcmpCreateFile")
	procIcmp6CreateFile = iphlpapi.NewProc("Icmp6CreateFile")
	procIcmpCloseHandle = iphlpapi.NewProc("IcmpCloseHandle")
	procIcmpSendEcho    = iphlpapi.NewProc("IcmpSendEcho")
	procIcmp6SendEcho2  = iphlpapi.NewProc("Icmp6SendEcho2")
)

// icmpEcho pings from a raw socket when the Core runs elevated, as it does
// under the helper with a TUN up, where the socket can be bound to the
// physical interface; otherwise through the ICMP API, which needs no
// privileges but cannot be bound.
func icmpEcho(ip netip.Addr, deadline time.Time) (time.Duration, error) {
	network := "ip4:icmp"
	if ip.Is6() {
		network = "ip6:ipv6-icmp"
	}
	conn, err := net.ListenPacket(network, "")
	if err != nil {
		return icmpSendEcho(ip, deadline)
	}
	defer conn.Close()
	if err := applyDialerControllers(conn, ip); err != nil {
		return 0, err
	}
	return echoOver(conn, &net.IPAddr{IP: ip.AsSlice()}, ip, deadline)
}

func icmpSendEcho(ip netip.Addr, deadline time.Time) (time.Duration, error) {
	timeout := time.Until(deadline).Milliseconds()
	if timeout <= 0 {
		return 0, windows.ERROR_TIMEOUT
	}
	create := procIcmpCreateFile
	if ip.Is6() {
		create = procIcmp6CreateFile
	}
	handle, _, err := create.Call()
	if windows.Handle(handle) == windows.InvalidHandle {
		return 0, err
	}
	defer procIcmpCloseHandle.Call(handle)

	payload := make([]byte, icmpPayloadSize)
	// Room for the reply structure, the echoed payload and an ICMP error.
	reply := make([]byte, 128+len(payload))
	start := time.Now()
	var count uintptr
	// ICMP_ECHO_REPLY puts Status after the 4-byte address; ICMPV6_ECHO_REPLY
	// after the packed 26-byte IPV6_ADDRESS_EX, aligned to 4.
	statusOffset := 4
	if ip.Is4() {
		address := ip.As4()
		count, _, err = procIcmpSendEcho.Call(
			handle,
			uintptr(*(*uint32)(unsafe.Pointer(&address[0]))),
			uintptr(unsafe.Pointer(&payload[0])),
			uintptr(len(payload)),
			0,
			uintptr(unsafe.Pointer(&reply[0])),
			uintptr(len(reply)),
			uintptr(timeout),
		)
	} else {
		statusOffset = 28
		source := windows.RawSockaddrInet6{Family: windows.AF_INET6}
		destination := windows.RawSockaddrInet6{Family: windows.AF_INET6, Addr: ip.As16()}
		count, _, err = procIcmp6SendEcho2.Call(
			handle,
			0,
			0,
			0,
			uintptr(unsafe.Pointer(&source)),
			uintptr(unsafe.Pointer(&destination)),
			uintptr(unsafe.Pointer(&payload[0])),
			uintptr(len(payload)),
			0,
			uintptr(unsafe.Pointer(&reply[0])),
			uintptr(len(reply)),
			uintptr(timeout),
		)
	}
	elapsed := time.Since(start)
	if count == 0 {
		return 0, err
	}
	if status := binary.LittleEndian.Uint32(reply[statusOffset:]); status != 0 {
		return 0, fmt.Errorf("icmp status %d", status)
	}
	return elapsed, nil
}
