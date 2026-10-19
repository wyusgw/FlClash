# User guide

**English** · [简体中文](user-guide.zh-CN.md)

This guide walks through FlClash from the first launch to the settings you will touch most. Screens are named by the
labels the app shows in English; the other languages follow the same layout. To install the app, see
[Download](../README.md#download).

The app has four tabs: **Home**, **Profiles**, **Data** and **Settings**. On a phone they sit at the bottom, on a
desktop they sit in the sidebar.

## Add servers

FlClash needs at least one server before it can connect. Open **Data → Add profile** (or **Add profile** on the empty
Home tab) and choose how to add it:

| Type | What to give it |
| --- | --- |
| Subscribe | A subscription URL, or an Xray JSON config |
| QR code | Scan a code, or pick an image holding one |
| File | A file with share links, a base64 list, or an Xray config |

You can also add a single server by hand: **Home → Add node** opens a form for the protocol you pick (VLESS, VMess,
Trojan, Shadowsocks, Hysteria and Hysteria2, TUIC, AnyTLS, SOCKS, HTTP and Mieru), and **Paste** imports a share
link that is on the clipboard.

A link in this form imports a subscription from a browser or another app. The `clashmeta://` and `flclash://` schemes
work the same way:

```text
clash://install-config?url=<URL-encoded subscription link>
```

Under **Data → Server nodes**:

- **Overwrite existing** replaces a server of the same name instead of keeping both.
- **Auto rename** numbers a duplicate name so every server stays listed.
- **Export file** saves your servers, and **Delete all nodes** clears them.

## Connect and pick a server

The **Home** tab lists your servers under each subscription. Tap a subscription to fold or expand its nodes, and tap a
node to use it. The proxy switch on this tab starts and stops the proxy.

**Global routing** decides what goes through the proxy:

| Mode | Effect |
| --- | --- |
| Rule | Traffic follows the routing rules; what no rule matches goes through the proxy |
| Global | All traffic goes through the proxy |
| Direct | Nothing goes through the proxy |

**Connectivity test** measures the delay of the nodes. **Delay test method** picks how: *TCP* times a connection to
the server, and *CONNECT* sends a request through the server and so measures the whole path. The test also works while
the proxy is off.

## Routing rules

The **Profiles** tab holds rule configs. The built-in one sends mainland China domains and addresses direct and the rest
through the proxy. A dot marks the default config and a check marks the one in use.

- **Add rule set** (the plus button) starts an empty config. Leave the URL empty to fill it by hand, or give it a URL
  or a file that holds Xray routing rules: a whole config, its `routing` object, or the rule list.
- Inside a config, the plus button adds a rule: pick **Match** (domain suffix, full domain, keyword, regular
  expression, GeoSite, IP-CIDR, GeoIP or port), type the values separated by commas, and pick the **Policy**
  (proxy, direct or block). Rules are checked from the top.
- **Test rules** tells you which rule a domain or an IP address would hit.
- **Restore default config** puts the built-in rules back.

Rules apply in Rule mode only.

## DNS

**Settings → DNS** has two modes. **Auto** uses the default servers. **Manual** lets you edit two lists, one for
traffic that goes through the proxy and one for traffic that goes direct. The first server of a list is asked first.

| List | Default |
| --- | --- |
| Proxy DNS | `1.1.1.1`, `8.8.8.8` |
| Direct DNS | `223.5.5.5`, `119.29.29.29` |

A server is an IP address (with an optional port), `localhost`, or a URL such as `https://dns.google/dns-query`,
`tcp://8.8.8.8:53` or `quic+local://dns.alidns.com`. Nothing is applied until you tap **Save**.

## System proxy, TUN and the network

Under **Settings → Network**:

- **System proxy** points the operating system's proxy settings at FlClash. It is not applied while authentication is on.
- **TUN** captures all traffic through a virtual network adapter. It is only effective in administrator mode.

Under **Settings → General**, the **Inbound** group has the **Mixed port** the proxy listens on, **Allow LAN** to let other
devices on your network use it, and **Authentication** to put a user name and password on it. **Log level** is there too.

On Android, **Settings → Access control** chooses which apps use the VPN: a whitelist (only the apps you select) or a
blacklist (all apps but the ones you select).

## Network detection and statistics

**Data → Network detection** shows the address your traffic leaves from. Tap it for details: the kind of network, the
organization, and a purity score from 0 to 100. The score is worked out from the type of network (residential and
mobile rate highest, data centers lower) and from the proxy, VPN, Tor and abuse flags raised against the address, so
treat it as a rough guide. On a phone, pull the page down to look it up again. **Hide IP** masks the address.

**Data → Statistics** shows traffic statistics.

## Logs

**Data → Logs** lists what the core reports, newest at the bottom. Tap a level to filter by it, search to narrow the
list, and use the export button to save the log to a file. **Settings → General → Log level** sets how much is
recorded.

## Hotkeys

On desktop, **Settings → Hotkey management** binds global hotkeys that work while the window is hidden. Tap an action
and press the combination you want, or tap the cross to clear it.

New installs start with these:

| Action | macOS and Linux | Windows |
| --- | --- | --- |
| Show/Hide | Ctrl+Alt+V | Ctrl+Alt+Shift+V |
| Start/Stop | Ctrl+Alt+S | Ctrl+Alt+Shift+S |
| Switch mode | Ctrl+Alt+M | Ctrl+Alt+Shift+M |
| Rule mode / Global mode / Direct mode | Ctrl+Alt+R / G / I | Ctrl+Alt+Shift+R / G / I |
| System proxy | Ctrl+Alt+P | Ctrl+Alt+Shift+P |
| Test all delays | Ctrl+Alt+D | Ctrl+Alt+Shift+D |
| TUN | Ctrl+Alt+T | Ctrl+Alt+Shift+T |
| Update profiles | Ctrl+Alt+U | Ctrl+Alt+Shift+U |
| Copy environment variables | Ctrl+Alt+C | Ctrl+Alt+Shift+C |
| Toggle speed view | Ctrl+Alt+F | Ctrl+Alt+Shift+F |
| Exit | Ctrl+Alt+E | Ctrl+Alt+Shift+E |

On macOS, Ctrl is the Control key and Alt is Option. Windows adds Shift because it reads AltGr as Ctrl+Alt. **Reset
hotkeys** at the bottom of the page puts the defaults back.

## Backup and restore

**Data → Backup and restore** saves your data to a WebDAV server or a local file. Bind a WebDAV account first. **Restore
strategy** chooses between restoring profiles only and restoring all data.

## Startup, the tray and updates

- **Settings → General** covers **Auto launch**, **Silent launch** (start without showing the window) and **Auto run**
  (run automatically when the app opens). **On demand** configures the app's running state for specific scenarios.
- On macOS the menu bar shows the speed, and the menu has the same entries as the tray on the other desktops. **Toggle
  speed view** in the menu shows or hides the speed.
- **Auto check for updates** looks for a new release when the app starts, and **Settings → About → Check for updates**
  does it on request. The download page at <https://wyusgw.github.io/FlClash/> picks the right installer for your system.

## Troubleshooting

- **A server that is given by name does not connect, but the same server by IP does.** Use the latest release: the core
  resolves server names through its own DNS, which older builds skipped.
- **Nothing connects after you turn TUN on.** Run FlClash with administrator rights, and check that no other VPN or
  proxy tool is capturing traffic at the same time.
- **Other devices cannot use the proxy.** Turn on **Allow LAN**, and allow the **Mixed port** through the firewall.
- **Connections fail or the VPN misbehaves.** **Settings → Reset → Reset core settings** restores the core, network and
  VPN settings to their defaults.
- **Something is wrong and you need to report it.** Export the log from **Data → Logs** and attach it to an issue on
  [GitHub](https://github.com/wyusgw/FlClash/issues).
