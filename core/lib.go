//go:build android && cgo

package main

/*
#include <stdlib.h>
*/
import "C"

import (
	"context"
	"core/logx"
	"core/platform"
	"encoding/json"
	"errors"
	"fmt"
	"net"
	"os"
	"strconv"
	"strings"
	"sync"
	"sync/atomic"
	"syscall"
	"time"
	"unsafe"

	"github.com/xtls/xray-core/core"
	"github.com/xtls/xray-core/features/inbound"
	"github.com/xtls/xray-core/infra/conf"
	"github.com/xtls/xray-core/transport/internet"
)

var (
	eventListenerLock sync.RWMutex
	eventListener     unsafe.Pointer
)

const (
	tunInboundTag = "tun-in"
	tunMTU        = 9000
	tunFdEnv      = "XRAY_TUN_FD"
)

// TunHandler owns the descriptor the VpnService handed over and the callback
// that protects sockets from it. Xray reads the descriptor from the
// environment when its tun inbound is built, so the inbound is attached to the
// running instance, and again after every restart of it.
type TunHandler struct {
	callback unsafe.Pointer
	fd       int
	address  []string

	mu sync.RWMutex
}

func tunInboundConfig(address []string) (*core.InboundHandlerConfig, error) {
	settings, err := json.Marshal(map[string]any{
		"name":    "tun0",
		"mtu":     tunMTU,
		"gateway": address,
	})
	if err != nil {
		return nil, err
	}
	raw := json.RawMessage(settings)
	detour := &conf.InboundDetourConfig{Tag: tunInboundTag, Protocol: "tun", Settings: &raw}
	return detour.Build()
}

func (th *TunHandler) attach(instance *core.Instance) error {
	th.mu.RLock()
	fd, address := th.fd, th.address
	th.mu.RUnlock()
	if err := os.Setenv(tunFdEnv, strconv.Itoa(fd)); err != nil {
		return err
	}
	inboundConfig, err := tunInboundConfig(address)
	if err != nil {
		return err
	}
	return core.AddInboundHandler(instance, inboundConfig)
}

func (th *TunHandler) detach(instance *core.Instance) {
	manager, _ := instance.GetFeature(inbound.ManagerType()).(inbound.Manager)
	if manager == nil {
		return
	}
	if err := manager.RemoveHandler(context.Background(), tunInboundTag); err != nil {
		logx.Warnf("[TUN] remove inbound: %v", err)
	}
}

func (th *TunHandler) release() {
	th.mu.Lock()
	defer th.mu.Unlock()
	if th.fd > 0 {
		_ = syscall.Close(th.fd)
		th.fd = 0
	}
	if th.callback != nil {
		releaseObject(th.callback)
		th.callback = nil
	}
}

// protectFailing tracks whether the last protect call was refused, so a stuck
// VpnService produces one log line rather than one per connection.
var protectFailing atomic.Bool

func (th *TunHandler) handleProtect(fd int) error {
	th.mu.RLock()
	defer th.mu.RUnlock()

	if th.callback == nil {
		// The tun routes are already live at this point (Android establishes
		// them before it hands the fd over), so an unprotected socket would be
		// routed straight back into the tunnel and hang until it times out.
		// Failing it here costs nothing and is at least visible.
		return errTunNotReady
	}

	if !protect(th.callback, fd) {
		if protectFailing.CompareAndSwap(false, true) {
			logError("VpnService.protect refused a socket; connections would loop back into the tunnel")
		}
		return errProtectRefused
	}

	if protectFailing.CompareAndSwap(true, false) {
		logx.Infof("[TUN] VpnService.protect recovered")
	}
	return nil
}

var (
	installHooksOnce sync.Once
	activeTunHandler atomic.Pointer[TunHandler]
)

func installHooks() {
	installHooksOnce.Do(func() {
		err := internet.RegisterDialerController(func(network, address string, conn syscall.RawConn) error {
			if platform.ShouldBlockConnection() {
				return errBlocked
			}
			th := activeTunHandler.Load()
			if th == nil {
				return nil
			}
			var protectErr error
			if err := conn.Control(func(fd uintptr) {
				protectErr = th.handleProtect(int(fd))
			}); err != nil {
				return err
			}
			return protectErr
		})
		if err != nil {
			logError("install socket protection: %v", err)
		}
	})
}

var (
	tunLock           sync.Mutex
	errBlocked        = errors.New("blocked: the process is out of file descriptors")
	errTunNotReady    = errors.New("blocked: the tun listener is not ready")
	errProtectRefused = errors.New("blocked: VpnService.protect refused the socket")
	tunHandler        *TunHandler
)

func handleStopTun() {
	tunLock.Lock()
	defer tunLock.Unlock()
	stopTunLocked()
}

func stopTunLocked() {
	if tunHandler == nil {
		return
	}
	configMu.Lock()
	afterEngineStart = nil
	if running := currentEngine.Load(); running != nil {
		tunHandler.detach(running.instance)
	}
	configMu.Unlock()
	activeTunHandler.CompareAndSwap(tunHandler, nil)
	tunHandler.release()
	tunHandler = nil
}

func parseTunAddresses(address string) []string {
	var prefixes []string
	for _, a := range strings.Split(address, ",") {
		if a = strings.TrimSpace(a); a != "" {
			prefixes = append(prefixes, a)
		}
	}
	return prefixes
}

// handleStartTun takes ownership of fd. The stack and dns arguments belong to
// the interface the host speaks; Xray has a single stack and takes its DNS
// from the config.
func handleStartTun(callback unsafe.Pointer, fd int, address string) bool {
	tunLock.Lock()
	defer tunLock.Unlock()
	stopTunLocked()
	if fd == 0 {
		if callback != nil {
			releaseObject(callback)
		}
		logError("startTun was handed no tun descriptor")
		return false
	}
	dupFd, err := syscall.Dup(fd)
	_ = syscall.Close(fd)
	if err != nil {
		if callback != nil {
			releaseObject(callback)
		}
		logError("TUN: %v", err)
		return false
	}
	handler := &TunHandler{callback: callback, fd: dupFd, address: parseTunAddresses(address)}
	installHooks()
	activeTunHandler.Store(handler)
	tunHandler = handler

	configMu.Lock()
	afterEngineStart = handler.attach
	if running := currentEngine.Load(); running != nil {
		err = handler.attach(running.instance)
	}
	configMu.Unlock()
	if err != nil {
		logError("TUN: %v", err)
		afterEngineStart = nil
		activeTunHandler.CompareAndSwap(handler, nil)
		handler.release()
		tunHandler = nil
		return false
	}
	return true
}

var (
	dnsUpdateMu  sync.Mutex
	dnsUpdateSeq atomic.Uint64
)

// Go's resolver has no resolv.conf to read on Android, so the host hands over
// the system servers and every lookup the core makes for itself goes to them.
func handleUpdateDns(value string) {
	var servers []string
	if value != "" {
		servers = strings.Split(value, ",")
	}
	seq := dnsUpdateSeq.Add(1)
	safeGoDetached("updateDns", func() {
		dnsUpdateMu.Lock()
		defer dnsUpdateMu.Unlock()
		if seq != dnsUpdateSeq.Load() {
			return
		}
		logx.Infof("[DNS] updateDns %s", value)
		if len(servers) == 0 {
			net.DefaultResolver = &net.Resolver{}
			return
		}
		dialer := &net.Dialer{
			Timeout: 5 * time.Second,
			Control: func(network, address string, conn syscall.RawConn) error {
				th := activeTunHandler.Load()
				if th == nil {
					return nil
				}
				var protectErr error
				if err := conn.Control(func(fd uintptr) { protectErr = th.handleProtect(int(fd)) }); err != nil {
					return err
				}
				return protectErr
			},
		}
		net.DefaultResolver = &net.Resolver{
			PreferGo: true,
			Dial: func(ctx context.Context, network, _ string) (net.Conn, error) {
				server := strings.TrimSpace(servers[0])
				return dialer.DialContext(ctx, network, net.JoinHostPort(server, "53"))
			},
		}
	})
}

func (response MethodResponse) send() {
	data, err := response.JSON()
	if err != nil {
		logError("MethodResponse marshal error: id=%s err=%v", response.ID, err)
		releaseObject(response.callback)
		return
	}
	invokeResult(response.callback, string(data))
	releaseObject(response.callback)
}

func init() {
	registerMethod(updateDnsMethod, withArguments(func(value *string, response MethodResponse) {
		handleUpdateDns(*value)
		response.success(true)
	}))
}

//export invokeMethod
func invokeMethod(callback unsafe.Pointer, paramsChar *C.char) {
	params := takeCString(paramsChar)
	call := &MethodCall{}
	if err := json.Unmarshal([]byte(params), call); err != nil {
		newMethodResponse("", callback).failure("invalid_method_call", err.Error(), nil)
		return
	}
	dispatchMethodCall(call, newMethodResponse(call.ID, callback))
}

//export startTUN
func startTUN(callback unsafe.Pointer, fd C.int, stackChar, addressChar, dnsChar *C.char) bool {
	_ = takeCString(stackChar)
	_ = takeCString(dnsChar)
	if !isRunning.Load() {
		handleStartListener()
	}
	return handleStartTun(callback, int(fd), takeCString(addressChar))
}

//export quickSetup
func quickSetup(callback unsafe.Pointer, initParamsChar *C.char, setupParamsChar *C.char) {
	go func() {
		defer releaseObject(callback)
		defer func() {
			if r := recover(); r != nil {
				logError("panic in quickSetup: %v\n%s", r, stackTrace())
				invokeResult(callback, fmt.Sprintf("internal panic: %v", r))
			}
		}()
		initParamsString := takeCString(initParamsChar)
		setupParamsString := takeCString(setupParamsChar)
		initParams := InitParams{}
		if err := json.Unmarshal([]byte(initParamsString), &initParams); err != nil || !handleInitCore(&initParams) {
			invokeResult(callback, "init failed")
			return
		}
		setupParams := defaultSetupParams()
		if err := UnmarshalJson([]byte(setupParamsString), setupParams); err != nil {
			invokeResult(callback, err.Error())
			return
		}
		isRunning.Store(true)
		invokeResult(callback, handleSetupConfig(setupParams))
	}()
}

// The listener goes away with the Flutter engine, which never gets to release
// the route watch it held, while the service and this core run on.
//
//export setEventListener
func setEventListener(listener unsafe.Pointer) {
	eventListenerLock.Lock()
	if eventListener != nil {
		releaseObject(eventListener)
	}
	eventListener = listener
	eventListenerLock.Unlock()
	if listener == nil {
		stopRouteWatch()
	}
}

func hasEventListener() bool {
	eventListenerLock.RLock()
	defer eventListenerLock.RUnlock()
	return eventListener != nil
}

//export getTotalTraffic
func getTotalTraffic(onlyStatisticsProxy bool) *C.char {
	return C.CString(marshalResult(handleGetTotalTraffic(onlyStatisticsProxy)))
}

//export getTraffic
func getTraffic(onlyStatisticsProxy bool) *C.char {
	return C.CString(marshalResult(handleGetTraffic(onlyStatisticsProxy)))
}

func marshalResult(value any) string {
	data, err := json.Marshal(value)
	if err != nil {
		logError("Result marshal error: %v", err)
		return ""
	}
	return string(data)
}

func deliverEvent(data []byte) {
	eventListenerLock.RLock()
	defer eventListenerLock.RUnlock()
	if eventListener == nil {
		return
	}
	invokeResult(eventListener, string(data))
}

//export stopTun
func stopTun() {
	handleStopTun()
	if isRunning.Load() {
		handleStopListener()
	}
}

//export forceGC
func forceGC() {
	handleForceGC()
}

//export updateDns
func updateDns(s *C.char) {
	handleUpdateDns(takeCString(s))
}
