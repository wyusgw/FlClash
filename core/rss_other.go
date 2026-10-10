//go:build !(linux || android)

package main

import "runtime"

// Only Linux exposes the resident size without cgo; elsewhere the memory the
// runtime holds from the OS is the closest figure.
func processRss(stats *runtime.MemStats) uint64 {
	return stats.Sys - stats.HeapReleased
}
