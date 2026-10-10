//go:build linux || android

package main

import (
	"os"
	"runtime"
	"strconv"
	"strings"
)

func processRss(stats *runtime.MemStats) uint64 {
	data, err := os.ReadFile("/proc/self/statm")
	if err != nil {
		return stats.Sys - stats.HeapReleased
	}
	fields := strings.Fields(string(data))
	if len(fields) < 2 {
		return stats.Sys - stats.HeapReleased
	}
	pages, err := strconv.ParseUint(fields[1], 10, 64)
	if err != nil {
		return stats.Sys - stats.HeapReleased
	}
	return pages * uint64(os.Getpagesize())
}
