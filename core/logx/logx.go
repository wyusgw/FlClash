package logx

import (
	"fmt"

	xlog "github.com/xtls/xray-core/common/log"
)

func record(severity xlog.Severity, format string, args ...any) {
	xlog.Record(&xlog.GeneralMessage{
		Severity: severity,
		Content:  fmt.Sprintf(format, args...),
	})
}

func Debugf(format string, args ...any) { record(xlog.Severity_Debug, format, args...) }
func Infof(format string, args ...any)  { record(xlog.Severity_Info, format, args...) }
func Warnf(format string, args ...any)  { record(xlog.Severity_Warning, format, args...) }
func Errorf(format string, args ...any) { record(xlog.Severity_Error, format, args...) }
