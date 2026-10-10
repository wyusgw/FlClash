package main

import (
	"maps"
	"sync"
)

type routeTracker struct {
	mu           sync.Mutex
	epoch        uint64
	picksVersion uint64
	picks        map[string]string
	watched      bool
	watchSeq     uint64
}

var (
	currentRoute routeTracker

	publishRoute = func(state RouteState) {
		sendMessage(Message{Type: RouteChangedMessage, Data: state})
	}
)

func routeStateLocked() RouteState {
	picks := currentRoute.picks
	if picks == nil {
		picks = map[string]string{}
	}
	return RouteState{
		CoreEpoch:    currentRoute.epoch,
		PicksVersion: currentRoute.picksVersion,
		Picks:        maps.Clone(picks),
	}
}

func routeState() RouteState {
	currentRoute.mu.Lock()
	defer currentRoute.mu.Unlock()
	return routeStateLocked()
}

func routeStamp() (epoch, picksVersion uint64) {
	currentRoute.mu.Lock()
	defer currentRoute.mu.Unlock()
	return currentRoute.epoch, currentRoute.picksVersion
}

// A balancer's own pick is not readable, so a group's pick is the host's
// selection; a group the host has not pinned reports nothing.
func readPicks() map[string]string {
	picks := map[string]string{}
	running := currentEngine.Load()
	if running == nil {
		return picks
	}
	for _, balancer := range running.meta.balancers {
		picks[balancer.Tag] = selected[balancer.Tag]
	}
	return picks
}

// The caller holds selectMu.
func refreshRouteLocked(structural bool) {
	picks := readPicks()

	currentRoute.mu.Lock()
	if structural {
		currentRoute.epoch++
	}
	changed := structural
	if !maps.Equal(picks, currentRoute.picks) {
		currentRoute.picks = picks
		currentRoute.picksVersion++
		changed = true
	}
	state := routeStateLocked()
	watched := currentRoute.watched
	currentRoute.mu.Unlock()

	if changed && watched {
		publishRoute(state)
	}
}

func refreshRoute() {
	selectMu.Lock()
	defer selectMu.Unlock()
	refreshRouteLocked(false)
}

func bumpRouteEpoch() {
	selectMu.Lock()
	defer selectMu.Unlock()
	refreshRouteLocked(true)
}

func handleWatchRoute(watch bool, seq uint64) RouteState {
	refreshRoute()

	currentRoute.mu.Lock()
	defer currentRoute.mu.Unlock()
	if seq < currentRoute.watchSeq {
		return routeStateLocked()
	}
	currentRoute.watchSeq = seq
	currentRoute.watched = watch
	return routeStateLocked()
}

// The stop takes its own place in the call order: a watch dispatched before
// it, the newest one included, may still be waiting to run.
func stopRouteWatch() {
	currentRoute.mu.Lock()
	defer currentRoute.mu.Unlock()
	currentRoute.watchSeq = max(currentRoute.watchSeq, methodCallSeq.Add(1))
	currentRoute.watched = false
}
