package main

import (
	"encoding/json"
	"net"
	"os"
	"path/filepath"
	"testing"
)

// The Dart side writes these files (test/common/xray_config_test.dart); loading
// them here is what proves the engine accepts what the host generates.
const fixtureDir = "../test/fixtures/xray"

func readFixture(t *testing.T, name string) []byte {
	t.Helper()
	data, err := os.ReadFile(filepath.Join(fixtureDir, name))
	if err != nil {
		t.Fatal(err)
	}
	return data
}

// homeWithGeoData is the home directory the host prepares: the engine reads
// geoip.dat and geosite.dat from it.
func homeWithGeoData(t *testing.T) string {
	t.Helper()
	home := t.TempDir()
	for _, name := range []string{"geoip.dat", "geosite.dat"} {
		source, err := filepath.Abs(filepath.Join("../assets/data", name))
		if err != nil {
			t.Fatal(err)
		}
		if err := os.Symlink(source, filepath.Join(home, name)); err != nil {
			t.Fatal(err)
		}
	}
	return home
}

func TestEveryGeneratedOutboundIsAccepted(t *testing.T) {
	var document struct {
		Outbounds []map[string]any `json:"outbounds"`
	}
	if err := json.Unmarshal(readFixture(t, "outbounds.json"), &document); err != nil {
		t.Fatal(err)
	}
	if len(document.Outbounds) < 7 {
		t.Fatalf("fixture holds %d outbounds, want one per protocol", len(document.Outbounds))
	}

	for i, message := range handleValidateProxies(document.Outbounds) {
		if message != "" {
			t.Errorf("outbound %v: %s", document.Outbounds[i]["tag"], message)
		}
	}
}

func TestEveryGeneratedConfigBuildsAnInstance(t *testing.T) {
	setAssetLocation(homeWithGeoData(t))
	files, err := filepath.Glob(filepath.Join(fixtureDir, "config_*.json"))
	if err != nil || len(files) == 0 {
		t.Fatalf("no config fixtures: %v", err)
	}

	for _, file := range files {
		name := filepath.Base(file)
		t.Run(name, func(t *testing.T) {
			data := readFixture(t, name)
			normalized, _, err := normalizeConfig(data)
			if err != nil {
				t.Fatal(err)
			}
			instance, err := buildInstance(normalized)
			if err != nil {
				t.Fatalf("engine refused the generated config: %v", err)
			}
			_ = instance.Close()
		})
	}
}

// The generated config listens on the user's proxy port, which a test must not
// take from the app that may be running next to it.
func withFreePort(t *testing.T, config []byte) string {
	t.Helper()
	listener, err := net.Listen("tcp", "127.0.0.1:0")
	if err != nil {
		t.Fatal(err)
	}
	port := listener.Addr().(*net.TCPAddr).Port
	_ = listener.Close()

	var document map[string]any
	if err := json.Unmarshal(config, &document); err != nil {
		t.Fatal(err)
	}
	for _, inbound := range document["inbounds"].([]any) {
		inbound.(map[string]any)["port"] = port
	}
	data, err := json.Marshal(document)
	if err != nil {
		t.Fatal(err)
	}
	return string(data)
}
