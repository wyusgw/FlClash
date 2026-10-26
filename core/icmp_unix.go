//go:build !windows

package main

import (
	"net"
	"net/netip"
	"os"
	"syscall"
	"time"
)

// icmpEcho pings from a datagram ICMP socket, which macOS, Android and Linux
// (within net.ipv4.ping_group_range) allow without privileges, and falls back
// to a raw socket when running as root.
func icmpEcho(ip netip.Addr, deadline time.Time) (time.Duration, error) {
	family, protocol := syscall.AF_INET, syscall.IPPROTO_ICMP
	if ip.Is6() {
		family, protocol = syscall.AF_INET6, syscall.IPPROTO_ICMPV6
	}
	var dst net.Addr = &net.UDPAddr{IP: ip.AsSlice()}
	fd, err := syscall.Socket(family, syscall.SOCK_DGRAM, protocol)
	if err != nil {
		dst = &net.IPAddr{IP: ip.AsSlice()}
		fd, err = syscall.Socket(family, syscall.SOCK_RAW, protocol)
	}
	if err != nil {
		return 0, err
	}
	syscall.CloseOnExec(fd)
	file := os.NewFile(uintptr(fd), "icmp")
	conn, err := net.FilePacketConn(file)
	_ = file.Close()
	if err != nil {
		return 0, err
	}
	defer conn.Close()
	if err := applyDialerControllers(conn, ip); err != nil {
		return 0, err
	}
	return echoOver(conn, dst, ip, deadline)
}
