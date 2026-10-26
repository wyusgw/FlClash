package main

import (
	"bytes"
	"testing"
)

func TestStripIPv4Header(t *testing.T) {
	message := []byte{0, 0, 0xff, 0xff, 0, 1, 0, 1}
	header := make([]byte, 24)
	header[0] = 0x46 // IPv4, a 24-byte header with options
	if got := stripIPv4Header(append(header, message...)); !bytes.Equal(got, message) {
		t.Fatalf("with a header: got %v, want %v", got, message)
	}
	if got := stripIPv4Header(message); !bytes.Equal(got, message) {
		t.Fatalf("without a header: got %v, want %v", got, message)
	}
}

func TestIcmpPingLoopback(t *testing.T) {
	delay := handleIcmpPing(&IcmpPingParams{Host: "127.0.0.1", Timeout: 2000})
	if delay == -1 {
		// Linux outside net.ipv4.ping_group_range, without root.
		t.Skip("ICMP sockets are not permitted here")
	}
	if delay < 1 || delay > 2000 {
		t.Fatalf("delay = %d, want within 1..2000", delay)
	}
}

func TestIcmpPingUnresolvable(t *testing.T) {
	if delay := handleIcmpPing(&IcmpPingParams{Host: "host.invalid", Timeout: 2000}); delay != -1 {
		t.Fatalf("delay = %d, want -1", delay)
	}
}
