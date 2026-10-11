package main

import "sync"

type routeTracker struct {
	mu       sync.Mutex
	epoch    uint64
	watched  bool
	watchSeq uint64
}

var (
	currentRoute routeTracker

	publishRoute = func(state RouteState) {
		sendMessage(Message{Type: RouteChangedMessage, Data: state})
	}
)

// A node is chosen by the config the host writes, so a route only ever changes
// with the epoch; the picks stay empty for the host's freshness check.
func routeStateLocked() RouteState {
	return RouteState{CoreEpoch: currentRoute.epoch, Picks: map[string]string{}}
}

func routeState() RouteState {
	currentRoute.mu.Lock()
	defer currentRoute.mu.Unlock()
	return routeStateLocked()
}

func routeStamp() (epoch, picksVersion uint64) {
	currentRoute.mu.Lock()
	defer currentRoute.mu.Unlock()
	return currentRoute.epoch, 0
}

func bumpRouteEpoch() {
	currentRoute.mu.Lock()
	currentRoute.epoch++
	state := routeStateLocked()
	watched := currentRoute.watched
	currentRoute.mu.Unlock()

	if watched {
		publishRoute(state)
	}
}

func handleWatchRoute(watch bool, seq uint64) RouteState {
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
