package main

import (
	"strings"
	"sync/atomic"

	xlog "github.com/xtls/xray-core/common/log"
)

// The severities Dart's LogLevel enum decodes.
func severityName(severity xlog.Severity) string {
	switch severity {
	case xlog.Severity_Error:
		return "error"
	case xlog.Severity_Warning:
		return "warning"
	case xlog.Severity_Debug:
		return "debug"
	default:
		return "info"
	}
}

// Higher means more verbose; "silent" admits nothing.
func levelRank(name string) int32 {
	switch strings.ToLower(name) {
	case "debug":
		return 4
	case "info":
		return 3
	case "warning", "warn":
		return 2
	case "error":
		return 1
	case "silent", "none":
		return 0
	default:
		return 3
	}
}

var (
	logLevel     atomic.Int32
	logStreaming atomic.Bool
)

func init() {
	logLevel.Store(levelRank("info"))
}

func setLogLevel(name string) {
	if name != "" {
		logLevel.Store(levelRank(name))
	}
}

// logForwarder is where an accepted log line goes; a test swaps it for a recorder.
var logForwarder = func(event logEvent) {
	sendMessage(Message{Type: LogMessage, Data: event})
}

type logHandler struct{}

func (logHandler) Handle(message xlog.Message) {
	content := message.String()
	if general, ok := message.(*xlog.GeneralMessage); ok {
		if int32(general.Severity) > logLevel.Load() {
			return
		}
		if debugStderr {
			println(content)
		}
		if logStreaming.Load() {
			logForwarder(logEvent{LogLevel: severityName(general.Severity), Payload: content})
		}
		return
	}
	if logLevel.Load() >= levelRank("info") && logStreaming.Load() {
		logForwarder(logEvent{LogLevel: "info", Payload: content})
	}
}

// Starting an Xray instance installs the log app's own handler, so ours goes in
// again after every start.
func installLogHandler() {
	xlog.RegisterHandler(logHandler{})
}

func handleStartLog() {
	logStreaming.Store(true)
}

func handleStopLog() {
	logStreaming.Store(false)
}
