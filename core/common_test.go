package main

import (
	"encoding/json"
	"go/ast"
	"go/parser"
	"go/token"
	"os"
	"regexp"
	"strconv"
	"testing"
)

func TestDefaultSetupParams(t *testing.T) {
	params := defaultSetupParams()

	if params.TestURL != "https://www.gstatic.com/generate_204" {
		t.Errorf("TestURL = %s, want the gstatic generate_204 probe", params.TestURL)
	}
}

func TestDefaultSetupParamsSurvivesPartialDecode(t *testing.T) {
	params := defaultSetupParams()

	if err := json.Unmarshal([]byte(`{"log-level":"debug"}`), params); err != nil {
		t.Fatalf("decode error: %v", err)
	}

	if params.TestURL != "https://www.gstatic.com/generate_204" {
		t.Errorf("TestURL = %s, want the default to survive a partial payload", params.TestURL)
	}
	if params.LogLevel != "debug" {
		t.Errorf("LogLevel = %s, want the decoded debug", params.LogLevel)
	}
}

func TestUnmarshalJsonPreservesLargeIntegers(t *testing.T) {
	target := map[string]any{}

	if err := UnmarshalJson([]byte(`{"id":9007199254740993}`), &target); err != nil {
		t.Fatalf("UnmarshalJson error: %v", err)
	}

	number, ok := target["id"].(json.Number)
	if !ok {
		t.Fatalf("id decoded as %T, want json.Number so int64 precision survives", target["id"])
	}
	value, err := number.Int64()
	if err != nil {
		t.Fatalf("Int64() error: %v", err)
	}
	if value != 9007199254740993 {
		t.Errorf("id = %d, want 9007199254740993", value)
	}
}

func TestUnmarshalJsonReportsInvalidPayload(t *testing.T) {
	target := map[string]any{}

	if err := UnmarshalJson([]byte(`{`), &target); err == nil {
		t.Fatal("UnmarshalJson accepted malformed JSON")
	}
}

func TestMethodCallDecodeArgumentsRejectsEmptyPayload(t *testing.T) {
	tests := map[string]json.RawMessage{
		"empty": nil,
		"null":  json.RawMessage("null"),
	}

	for name, arguments := range tests {
		t.Run(name, func(t *testing.T) {
			call := MethodCall{Method: validateConfigMethod, Arguments: arguments}
			target := ""

			err := call.decodeArguments(&target)

			if err == nil {
				t.Fatal("decodeArguments accepted a missing payload")
			}
			if err.Error() != "missing arguments" {
				t.Errorf("error = %v, want \"missing arguments\"", err)
			}
		})
	}
}

func TestMethodCallDecodeArgumentsAcceptsScalar(t *testing.T) {
	call := MethodCall{
		Method:    validateConfigMethod,
		Arguments: json.RawMessage(`"/tmp/config.yaml"`),
	}
	target := ""

	if err := call.decodeArguments(&target); err != nil {
		t.Fatalf("decodeArguments error: %v", err)
	}
	if target != "/tmp/config.yaml" {
		t.Errorf("target = %s, want /tmp/config.yaml", target)
	}
}

func coreMethodConstants(t *testing.T) []CoreMethod {
	t.Helper()
	fileSet := token.NewFileSet()
	file, err := parser.ParseFile(fileSet, "constant.go", nil, 0)
	if err != nil {
		t.Fatalf("parse constant.go: %v", err)
	}

	var methods []CoreMethod
	ast.Inspect(file, func(node ast.Node) bool {
		spec, ok := node.(*ast.ValueSpec)
		if !ok {
			return true
		}
		typeName, ok := spec.Type.(*ast.Ident)
		if !ok || typeName.Name != "CoreMethod" {
			return true
		}
		for _, value := range spec.Values {
			literal, ok := value.(*ast.BasicLit)
			if !ok || literal.Kind != token.STRING {
				continue
			}
			unquoted, err := strconv.Unquote(literal.Value)
			if err != nil {
				t.Fatalf("unquote %s: %v", literal.Value, err)
			}
			methods = append(methods, CoreMethod(unquoted))
		}
		return true
	})

	if len(methods) == 0 {
		t.Fatal("found no CoreMethod constants; the parser lost track of constant.go")
	}
	return methods
}

func TestEveryCoreMethodConstantIsDispatchable(t *testing.T) {
	notDispatched := map[CoreMethod]string{
		messageMethod:   "core-to-host event envelope, never received",
		crashMethod:     "handled ahead of the table so it bypasses panic recovery",
		updateDnsMethod: "registered by the cgo build only",
	}

	for _, method := range coreMethodConstants(t) {
		if reason, expected := notDispatched[method]; expected {
			if _, exists := methodHandlers[method]; exists {
				t.Errorf("method %s has a handler but is documented as %s", method, reason)
			}
			continue
		}
		if _, exists := methodHandlers[method]; !exists {
			t.Errorf("method %s has no handler and would answer not_implemented", method)
		}
	}
}

func TestRegisterMethodRejectsADuplicate(t *testing.T) {
	defer func() {
		if recover() == nil {
			t.Error("registerMethod accepted a second handler for an already routed method")
		}
	}()

	registerMethod(getTrafficMethod, withoutArguments(func(response MethodResponse) {}))
}

// The Dart enum is the host's list of calls; every one of them has to reach a
// handler here, or the host's request would answer not_implemented.
func TestEveryHostMethodIsKnownToTheCore(t *testing.T) {
	source, err := os.ReadFile("../lib/core/method.dart")
	if err != nil {
		t.Fatal(err)
	}
	block := regexp.MustCompile(`(?s)enum CoreMethod \{(.*?)\}`).FindSubmatch(source)
	if block == nil {
		t.Fatal("CoreMethod enum not found in method.dart")
	}
	host := map[CoreMethod]bool{}
	for _, name := range regexp.MustCompile(`\w+`).FindAllString(string(block[1]), -1) {
		host[CoreMethod(name)] = true
	}

	core := map[CoreMethod]bool{}
	for _, method := range coreMethodConstants(t) {
		core[method] = true
	}
	for method := range host {
		if !core[method] {
			t.Errorf("host method %s has no constant in the core", method)
		}
	}
	for method := range core {
		if !host[method] {
			t.Errorf("core method %s is unknown to the host", method)
		}
	}
}
