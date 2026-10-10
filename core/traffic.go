package main

import (
	"strings"
	"sync"
	"time"

	"github.com/xtls/xray-core/features/stats"
)

const (
	outboundCounterPrefix = "outbound>>>"
	uplinkSuffix          = ">>>traffic>>>uplink"
	downlinkSuffix        = ">>>traffic>>>downlink"
)

func statsOf(running *engine) stats.Manager {
	manager, _ := running.instance.GetFeature(stats.ManagerType()).(stats.Manager)
	return manager
}

// totals sums the outbound counters. Xray counts per outbound tag, so only the
// tags the config marks as proxies make up the "proxied" figure.
func totals(onlyProxy bool) (up, down int64) {
	running := currentEngine.Load()
	if running == nil {
		return 0, 0
	}
	manager := statsOf(running)
	if manager == nil {
		return 0, 0
	}
	manager.VisitCounters(func(name string, counter stats.Counter) bool {
		if !strings.HasPrefix(name, outboundCounterPrefix) {
			return true
		}
		rest := name[len(outboundCounterPrefix):]
		var tag string
		var isUp bool
		switch {
		case strings.HasSuffix(rest, uplinkSuffix):
			tag, isUp = strings.TrimSuffix(rest, uplinkSuffix), true
		case strings.HasSuffix(rest, downlinkSuffix):
			tag = strings.TrimSuffix(rest, downlinkSuffix)
		default:
			return true
		}
		if onlyProxy && !running.meta.isProxy(tag) {
			return true
		}
		if isUp {
			up += counter.Value()
		} else {
			down += counter.Value()
		}
		return true
	})
	return up, down
}

type trafficSample struct {
	at       time.Time
	up, down int64
}

var (
	sampleMu sync.Mutex
	samples  = map[bool]trafficSample{}
)

// Xray exposes only running totals, so the per-second rate is the difference
// between two calls.
func handleGetTraffic(onlyProxy bool) Traffic {
	up, down := totals(onlyProxy)
	now := time.Now()

	sampleMu.Lock()
	defer sampleMu.Unlock()
	previous, seen := samples[onlyProxy]
	samples[onlyProxy] = trafficSample{at: now, up: up, down: down}
	if !seen {
		return Traffic{}
	}
	elapsed := now.Sub(previous.at).Seconds()
	if elapsed <= 0 || up < previous.up || down < previous.down {
		return Traffic{}
	}
	return Traffic{
		Up:   int64(float64(up-previous.up) / elapsed),
		Down: int64(float64(down-previous.down) / elapsed),
	}
}

func handleGetTotalTraffic(onlyProxy bool) Traffic {
	up, down := totals(onlyProxy)
	return Traffic{Up: up, Down: down}
}

func handleResetTraffic() {
	running := currentEngine.Load()
	if running == nil {
		return
	}
	if manager := statsOf(running); manager != nil {
		manager.VisitCounters(func(_ string, counter stats.Counter) bool {
			counter.Set(0)
			return true
		})
	}
	sampleMu.Lock()
	samples = map[bool]trafficSample{}
	sampleMu.Unlock()
}
