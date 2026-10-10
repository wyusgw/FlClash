package main

import (
	b "bytes"
	"context"
	"encoding/json"
	"fmt"
	"os"
	"sync"
	"sync/atomic"
	"time"

	"core/logx"
)

const (
	delayTestConcurrency    = 50
	defaultTestURL          = "https://www.gstatic.com/generate_204"
	defaultDelayTestTimeout = 5 * time.Second
)

var (
	// configMu serialises everything that builds, starts or closes the engine;
	// readers on the hot paths go through currentEngine instead.
	configMu sync.Mutex

	// selectMu serialises proxy-group selection writes and the route state they
	// feed. Taking it under configMu fixes the order as configMu -> selectMu.
	selectMu sync.Mutex

	homeDir    string
	isInit     atomic.Bool
	isRunning  atomic.Bool
	sdkVersion atomic.Int32
	testURL    atomic.Pointer[string]

	delayTestSlots = make(chan struct{}, delayTestConcurrency)

	debugStderr = os.Getenv("FLCLASH_CORE_DEBUG") != ""
)

func defaultSetupParams() *SetupParams {
	return &SetupParams{
		TestURL:     defaultTestURL,
		SelectedMap: map[string]string{},
	}
}

func setTestURL(url string) {
	if url == "" {
		return
	}
	testURL.Store(&url)
}

func currentTestURL() string {
	if url := testURL.Load(); url != nil && *url != "" {
		return *url
	}
	return defaultTestURL
}

func acquireDelayTestSlot(ctx context.Context) bool {
	select {
	case delayTestSlots <- struct{}{}:
		return true
	case <-ctx.Done():
		return false
	}
}

func releaseDelayTestSlot() {
	<-delayTestSlots
}

func UnmarshalJson(data []byte, v any) error {
	decoder := json.NewDecoder(b.NewReader(data))
	decoder.UseNumber()
	return decoder.Decode(v)
}

func logError(format string, args ...any) {
	logx.Errorf(format, args...)
	if debugStderr {
		fmt.Fprintf(os.Stderr, "[ERROR] "+format+"\n", args...)
	}
}
