// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  static String m0(count, skipped) =>
      "${count} to add, ${skipped} skipped as existing";

  static String m1(appName) =>
      "If enabled, ${appName} tries to recognize a proxy server URL in the clipboard as soon as the app opens and offers to import it.\n\nIf not enabled, a dedicated paste button appears on the home screen; tap it to paste and import the clipboard content by hand.";

  static String m2(code) =>
      "Windows refused to run FlClashCore.exe (error ${code}). An app control policy such as Smart App Control or AppLocker blocks unsigned programs; allow FlClash in that policy or turn it off, then try again.";

  static String m3(name) =>
      "The app failed to finish launching twice in a row. To break the loop, the profile ${name} has been deselected and automatic setup was skipped. You can select it again at any time.";

  static String m4(url) => "Do you want to create a profile from ${url}?";

  static String m5(count) =>
      "${Intl.plural(count, one: '1 day ago', other: '${count} days ago')}";

  static String m6(label) => "Are you sure you want to delete this ${label}?";

  static String m7(label) => "${label} details";

  static String m8(label) => "${label} cannot be empty";

  static String m9(label) => "${label} already exists";

  static String m10(action) => "Moved from “${action}”";

  static String m11(modifiers) => "Include at least one of ${modifiers}";

  static String m12(count) =>
      "${Intl.plural(count, one: '1 hour ago', other: '${count} hours ago')}";

  static String m13(count) => "Import this color scheme (${count} colors)?";

  static String m14(count) =>
      "Import ${count} server node(s) from the clipboard?";

  static String m15(line, message) => "Line ${line}: ${message}";

  static String m16(appName) =>
      "1. Open System Settings > Privacy & Security\n2. Choose Location Services\n3. Find and check ${appName} in the list\n\nWhen you are done, return to the app to continue. Thank you for your cooperation.";

  static String m17(label, max) => "${label} must be at most ${max} characters";

  static String m18(size) => "Released ${size}";

  static String m19(count) =>
      "${Intl.plural(count, one: '1 minute ago', other: '${count} minutes ago')}";

  static String m20(count) =>
      "${Intl.plural(count, one: '1 month ago', other: '${count} months ago')}";

  static String m21(detail) => "Network request failed: ${detail}";

  static String m22(label) => "No ${label} yet";

  static String m23(label) => "${label} must be a number";

  static String m24(appName) => "Open ${appName}";

  static String m25(label) => "${label} must be between 1024 and 49151";

  static String m26(count) => "Rules: ${count}";

  static String m27(appName) => "${appName} (Safe mode)";

  static String m28(count) => "${count} selected";

  static String m29(time) => "Checked at ${time}";

  static String m30(label) => "${label} must be a single item";

  static String m31(label) => "${label} must be a URL";

  static String m32(count) =>
      "${Intl.plural(count, one: '1 year ago', other: '${count} years ago')}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "about": MessageLookupByLibrary.simpleMessage("About"),
    "accessControl": MessageLookupByLibrary.simpleMessage("Access control"),
    "accessControlAllowDesc": MessageLookupByLibrary.simpleMessage(
      "Only selected apps go through the VPN",
    ),
    "accessControlDesc": MessageLookupByLibrary.simpleMessage(
      "Control which apps use the proxy",
    ),
    "accessControlDisabledDesc": MessageLookupByLibrary.simpleMessage(
      "App access control is disabled",
    ),
    "accessControlNotAllowDesc": MessageLookupByLibrary.simpleMessage(
      "Selected apps are excluded from the VPN",
    ),
    "accessControlSettings": MessageLookupByLibrary.simpleMessage(
      "Access control settings",
    ),
    "account": MessageLookupByLibrary.simpleMessage("Account"),
    "acknowledgements": MessageLookupByLibrary.simpleMessage(
      "Acknowledgements",
    ),
    "action": MessageLookupByLibrary.simpleMessage("Action"),
    "actionDelayTest": MessageLookupByLibrary.simpleMessage("Test all delays"),
    "actionDirectMode": MessageLookupByLibrary.simpleMessage("Direct mode"),
    "actionGlobalMode": MessageLookupByLibrary.simpleMessage("Global mode"),
    "actionMode": MessageLookupByLibrary.simpleMessage("Switch mode"),
    "actionProxy": MessageLookupByLibrary.simpleMessage("System proxy"),
    "actionRuleMode": MessageLookupByLibrary.simpleMessage("Rule mode"),
    "actionStart": MessageLookupByLibrary.simpleMessage("Start/Stop"),
    "actionTun": MessageLookupByLibrary.simpleMessage("TUN"),
    "actionUpdateProfiles": MessageLookupByLibrary.simpleMessage(
      "Update profiles",
    ),
    "actionView": MessageLookupByLibrary.simpleMessage("Show/Hide"),
    "add": MessageLookupByLibrary.simpleMessage("Add"),
    "addNode": MessageLookupByLibrary.simpleMessage("Add node"),
    "addProfile": MessageLookupByLibrary.simpleMessage("Add profile"),
    "addRule": MessageLookupByLibrary.simpleMessage("Add rule"),
    "addRuleSet": MessageLookupByLibrary.simpleMessage("Add rule set"),
    "addRuleSetDesc": MessageLookupByLibrary.simpleMessage(
      "Leave the URL empty to start with no rules and add them by hand. A file or a URL takes Xray routing rules: a whole config, its routing object, or the rule list.",
    ),
    "addServer": MessageLookupByLibrary.simpleMessage("Add Server"),
    "addSsid": MessageLookupByLibrary.simpleMessage("Add SSID"),
    "addSuccess": MessageLookupByLibrary.simpleMessage("Added successfully"),
    "addWidget": MessageLookupByLibrary.simpleMessage("Add widget"),
    "address": MessageLookupByLibrary.simpleMessage("Address"),
    "addressHelp": MessageLookupByLibrary.simpleMessage(
      "WebDAV server address",
    ),
    "addressTip": MessageLookupByLibrary.simpleMessage(
      "Please enter a valid WebDAV address",
    ),
    "advanced": MessageLookupByLibrary.simpleMessage("Advanced"),
    "algorithm": MessageLookupByLibrary.simpleMessage("Algorithm"),
    "allowBypass": MessageLookupByLibrary.simpleMessage(
      "Allow apps to bypass VPN",
    ),
    "allowInsecure": MessageLookupByLibrary.simpleMessage("Allow insecure"),
    "allowLan": MessageLookupByLibrary.simpleMessage("Allow LAN"),
    "answers": MessageLookupByLibrary.simpleMessage("Answers"),
    "app": MessageLookupByLibrary.simpleMessage("App"),
    "appAccessControl": MessageLookupByLibrary.simpleMessage(
      "App access control",
    ),
    "appIconDesign": MessageLookupByLibrary.simpleMessage("App icon design"),
    "appearance": MessageLookupByLibrary.simpleMessage("Appearance"),
    "archive": MessageLookupByLibrary.simpleMessage("Archive"),
    "archiveDesc": MessageLookupByLibrary.simpleMessage(
      "Each run of the core is kept here when it ends.",
    ),
    "archiveEmpty": MessageLookupByLibrary.simpleMessage(
      "Nothing archived yet",
    ),
    "archiveStats": MessageLookupByLibrary.simpleMessage("Keep an archive"),
    "authentication": MessageLookupByLibrary.simpleMessage("Authentication"),
    "authenticationDesc": MessageLookupByLibrary.simpleMessage(
      "Require credentials on the local proxy port to keep other local apps from using it",
    ),
    "authenticationSystemProxyDesc": MessageLookupByLibrary.simpleMessage(
      "Not applied while authentication is enabled",
    ),
    "authorize": MessageLookupByLibrary.simpleMessage("Authorize"),
    "authorized": MessageLookupByLibrary.simpleMessage("Authorized"),
    "auto": MessageLookupByLibrary.simpleMessage("Auto"),
    "autoCheckUpdate": MessageLookupByLibrary.simpleMessage(
      "Auto check for updates",
    ),
    "autoLaunch": MessageLookupByLibrary.simpleMessage("Auto launch"),
    "autoLaunchDesc": MessageLookupByLibrary.simpleMessage(
      "Launch automatically at system startup",
    ),
    "autoRenameNodes": MessageLookupByLibrary.simpleMessage("Auto rename"),
    "autoRenameNodesDesc": MessageLookupByLibrary.simpleMessage(
      "Add a number to the server name to avoid duplicates",
    ),
    "autoRun": MessageLookupByLibrary.simpleMessage("Auto run"),
    "autoRunDesc": MessageLookupByLibrary.simpleMessage(
      "Run automatically when the app opens",
    ),
    "autoSetSystemDns": MessageLookupByLibrary.simpleMessage(
      "Auto-set system DNS",
    ),
    "autoUpdate": MessageLookupByLibrary.simpleMessage("Auto update"),
    "autoUpdateInterval": MessageLookupByLibrary.simpleMessage(
      "Auto-update interval",
    ),
    "back": MessageLookupByLibrary.simpleMessage("Back"),
    "backup": MessageLookupByLibrary.simpleMessage("Backup"),
    "backupAndRestore": MessageLookupByLibrary.simpleMessage(
      "Backup and restore",
    ),
    "backupAndRestoreDesc": MessageLookupByLibrary.simpleMessage(
      "Sync data via WebDAV or files",
    ),
    "backupFromNewerVersion": MessageLookupByLibrary.simpleMessage(
      "This backup comes from a newer version of the app. Update the app before restoring it",
    ),
    "backupSuccess": MessageLookupByLibrary.simpleMessage("Backup successful"),
    "basicInfo": MessageLookupByLibrary.simpleMessage("Basic info"),
    "batchAdd": MessageLookupByLibrary.simpleMessage("Batch add"),
    "batchListInputTip": MessageLookupByLibrary.simpleMessage(
      "One item per line, or separated by commas",
    ),
    "batchMapInputTip": MessageLookupByLibrary.simpleMessage(
      "One entry per line: key, a space, then value",
    ),
    "batchPreviewTip": m0,
    "batteryOptimizationDesc": MessageLookupByLibrary.simpleMessage(
      "To keep the app running in the background, disable battery optimization for it. Tap to open settings.",
    ),
    "batteryOptimizationStatusTip": MessageLookupByLibrary.simpleMessage(
      "Due to system limitations, the battery optimization status cannot be read correctly while running",
    ),
    "behavior": MessageLookupByLibrary.simpleMessage("Behavior"),
    "bind": MessageLookupByLibrary.simpleMessage("Bind"),
    "blacklistMode": MessageLookupByLibrary.simpleMessage("Blacklist mode"),
    "builtInRules": MessageLookupByLibrary.simpleMessage("Built-in rules"),
    "bypassDomain": MessageLookupByLibrary.simpleMessage("Bypass domains"),
    "bypassDomainDesc": MessageLookupByLibrary.simpleMessage(
      "Only takes effect while the system proxy is enabled",
    ),
    "cache": MessageLookupByLibrary.simpleMessage("Cache"),
    "cacheCorrupt": MessageLookupByLibrary.simpleMessage(
      "The cache is corrupted. Clear it?",
    ),
    "cameraPermissionDesc": MessageLookupByLibrary.simpleMessage(
      "Allow camera access in system settings to scan QR codes, or choose a QR code image from the album.",
    ),
    "cameraPermissionRequired": MessageLookupByLibrary.simpleMessage(
      "Camera permission required",
    ),
    "cameraUnavailable": MessageLookupByLibrary.simpleMessage(
      "Camera unavailable",
    ),
    "cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
    "cancelSelectAll": MessageLookupByLibrary.simpleMessage("Deselect all"),
    "certSha256": MessageLookupByLibrary.simpleMessage("Certificate SHA256"),
    "changeProxyFailedTip": MessageLookupByLibrary.simpleMessage(
      "Failed to switch proxy; the previous selection has been restored",
    ),
    "changelogBreaking": MessageLookupByLibrary.simpleMessage(
      "Breaking changes",
    ),
    "changelogFeatures": MessageLookupByLibrary.simpleMessage("New features"),
    "changelogFixes": MessageLookupByLibrary.simpleMessage("Bug fixes"),
    "changelogPerformance": MessageLookupByLibrary.simpleMessage("Performance"),
    "changelogReverts": MessageLookupByLibrary.simpleMessage("Reverts"),
    "checkCertificate": MessageLookupByLibrary.simpleMessage(
      "Verify TLS certificates",
    ),
    "checkCertificateDesc": MessageLookupByLibrary.simpleMessage(
      "Reject untrusted certificates. Turning this off exposes subscriptions and backups to man-in-the-middle attacks",
    ),
    "checkUpdate": MessageLookupByLibrary.simpleMessage("Check for updates"),
    "checkUpdateError": MessageLookupByLibrary.simpleMessage(
      "The app is already up to date",
    ),
    "chooseType": MessageLookupByLibrary.simpleMessage("Choose a type"),
    "clearArchive": MessageLookupByLibrary.simpleMessage("Clear archive"),
    "clearData": MessageLookupByLibrary.simpleMessage("Clear data"),
    "clearSearch": MessageLookupByLibrary.simpleMessage("Clear search"),
    "clipboard": MessageLookupByLibrary.simpleMessage("Clipboard"),
    "clipboardDesc": m1,
    "clipboardExport": MessageLookupByLibrary.simpleMessage(
      "Export to clipboard",
    ),
    "clipboardImport": MessageLookupByLibrary.simpleMessage(
      "Import from clipboard",
    ),
    "clipboardNothingToImport": MessageLookupByLibrary.simpleMessage(
      "The clipboard holds no proxy server URL to import",
    ),
    "clipboardWriteFailed": MessageLookupByLibrary.simpleMessage(
      "Couldn\'t copy to the clipboard. The selection may be too large",
    ),
    "close": MessageLookupByLibrary.simpleMessage("Close"),
    "color": MessageLookupByLibrary.simpleMessage("Color"),
    "colorLinkInvalid": MessageLookupByLibrary.simpleMessage(
      "This color link could not be read",
    ),
    "colorSchemes": MessageLookupByLibrary.simpleMessage("Color schemes"),
    "colors": MessageLookupByLibrary.simpleMessage("Colors"),
    "columns": MessageLookupByLibrary.simpleMessage("Columns"),
    "compatible": MessageLookupByLibrary.simpleMessage("Compatibility mode"),
    "configureDns": MessageLookupByLibrary.simpleMessage("Configure DNS"),
    "confirm": MessageLookupByLibrary.simpleMessage("Confirm"),
    "confirmClearAllData": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to clear all data?",
    ),
    "confirmForceCrashCore": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to force crash the core?",
    ),
    "congestionControl": MessageLookupByLibrary.simpleMessage(
      "Congestion control",
    ),
    "connectDesc": MessageLookupByLibrary.simpleMessage(
      "Test a URL request through the proxy server.",
    ),
    "connected": MessageLookupByLibrary.simpleMessage("Connected"),
    "connectedTime": MessageLookupByLibrary.simpleMessage("Connected for"),
    "connecting": MessageLookupByLibrary.simpleMessage("Connecting…"),
    "connection": MessageLookupByLibrary.simpleMessage("Connection"),
    "connections": MessageLookupByLibrary.simpleMessage("Connections"),
    "connectivity": MessageLookupByLibrary.simpleMessage("Connectivity: "),
    "connectivityTest": MessageLookupByLibrary.simpleMessage(
      "Connectivity test",
    ),
    "content": MessageLookupByLibrary.simpleMessage("Content"),
    "contentScheme": MessageLookupByLibrary.simpleMessage("Content"),
    "copy": MessageLookupByLibrary.simpleMessage("Copy"),
    "copyAddress": MessageLookupByLibrary.simpleMessage("Copy address"),
    "copyColorLink": MessageLookupByLibrary.simpleMessage("Copy link"),
    "copyEnvVar": MessageLookupByLibrary.simpleMessage(
      "Copy environment variables",
    ),
    "copyJson": MessageLookupByLibrary.simpleMessage("Copy JSON"),
    "copyLink": MessageLookupByLibrary.simpleMessage("Copy link"),
    "copyName": MessageLookupByLibrary.simpleMessage("Copy name"),
    "copyScheme": MessageLookupByLibrary.simpleMessage(
      "Tap a scheme to copy it.",
    ),
    "copySuccess": MessageLookupByLibrary.simpleMessage("Copied successfully"),
    "core": MessageLookupByLibrary.simpleMessage("Core"),
    "coreBlockedByPolicyTip": m2,
    "coreBlockedBySmartAppControlTip": MessageLookupByLibrary.simpleMessage(
      "Windows Smart App Control blocked FlClashCore.exe because it is not signed. Open Windows Security → App & browser control → Smart App Control settings, choose Off, then start FlClash again. Smart App Control cannot be turned back on without reinstalling Windows.",
    ),
    "coreStatus": MessageLookupByLibrary.simpleMessage("Core status"),
    "country": MessageLookupByLibrary.simpleMessage("Region"),
    "crashDetected": MessageLookupByLibrary.simpleMessage("Crash detected"),
    "crashDetectedTip": m3,
    "crashTest": MessageLookupByLibrary.simpleMessage("Crash test"),
    "crashlytics": MessageLookupByLibrary.simpleMessage("Crash analytics"),
    "crashlyticsTip": MessageLookupByLibrary.simpleMessage(
      "When enabled, crash logs without sensitive information are uploaded automatically when the app crashes",
    ),
    "create": MessageLookupByLibrary.simpleMessage("Create"),
    "createProfileFromUrlTip": m4,
    "custom": MessageLookupByLibrary.simpleMessage("Custom"),
    "cut": MessageLookupByLibrary.simpleMessage("Cut"),
    "dark": MessageLookupByLibrary.simpleMessage("Dark"),
    "dashboard": MessageLookupByLibrary.simpleMessage("Dashboard"),
    "data": MessageLookupByLibrary.simpleMessage("Data"),
    "dataCollectionContent": MessageLookupByLibrary.simpleMessage(
      "This app uses Firebase Crashlytics to collect crash information to improve stability.\nThe collected data includes device information and crash details, and contains no personally sensitive data.\nYou can turn this off in settings.",
    ),
    "dataCollectionTip": MessageLookupByLibrary.simpleMessage(
      "Data collection notice",
    ),
    "databaseWriteFailedTip": MessageLookupByLibrary.simpleMessage(
      "Failed to save the change; it has been rolled back",
    ),
    "daysAgo": m5,
    "defaultText": MessageLookupByLibrary.simpleMessage("Default"),
    "delay": MessageLookupByLibrary.simpleMessage("Delay"),
    "delayTest": MessageLookupByLibrary.simpleMessage("Delay test"),
    "delayTestMethod": MessageLookupByLibrary.simpleMessage(
      "Delay test method",
    ),
    "delete": MessageLookupByLibrary.simpleMessage("Delete"),
    "deleteAllNodes": MessageLookupByLibrary.simpleMessage("Delete all nodes"),
    "deleteAllNodesTip": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to delete?",
    ),
    "deleteRuleSet": MessageLookupByLibrary.simpleMessage("Delete config"),
    "deleteSuccess": MessageLookupByLibrary.simpleMessage(
      "Deleted successfully",
    ),
    "deleteTip": m6,
    "desc": MessageLookupByLibrary.simpleMessage(
      "A multi-platform proxy client based on Xray-core, simple and easy to use, open-source and ad-free.",
    ),
    "destination": MessageLookupByLibrary.simpleMessage("Destination"),
    "details": m7,
    "detectionTip": MessageLookupByLibrary.simpleMessage(
      "Relies on a third-party API; for reference only",
    ),
    "developerMode": MessageLookupByLibrary.simpleMessage("Developer mode"),
    "developerModeEnableTip": MessageLookupByLibrary.simpleMessage(
      "Developer mode is enabled.",
    ),
    "direct": MessageLookupByLibrary.simpleMessage("Direct"),
    "directDns": MessageLookupByLibrary.simpleMessage("Direct DNS"),
    "directDnsDesc": MessageLookupByLibrary.simpleMessage(
      "Looks up mainland China domains and the nodes\' own addresses, asked directly. The first one is tried first.",
    ),
    "directModeDesc": MessageLookupByLibrary.simpleMessage(
      "Do not forward traffic through the proxy",
    ),
    "disabled": MessageLookupByLibrary.simpleMessage("Disabled"),
    "disconnected": MessageLookupByLibrary.simpleMessage("Disconnected"),
    "discoverNewVersion": MessageLookupByLibrary.simpleMessage(
      "New version found",
    ),
    "distribution": MessageLookupByLibrary.simpleMessage("Distribution"),
    "dnsHijacking": MessageLookupByLibrary.simpleMessage("DNS hijacking"),
    "dnsQueries": MessageLookupByLibrary.simpleMessage("DNS queries"),
    "dnsServer": MessageLookupByLibrary.simpleMessage("DNS server"),
    "dnsServerTip": MessageLookupByLibrary.simpleMessage(
      "Enter an IP address (port optional), localhost, or an address such as https://, tcp:// or quic+local://",
    ),
    "docked": MessageLookupByLibrary.simpleMessage("Docked"),
    "domain": MessageLookupByLibrary.simpleMessage("Domain"),
    "done": MessageLookupByLibrary.simpleMessage("Done"),
    "download": MessageLookupByLibrary.simpleMessage("Download"),
    "downloadSpeed": MessageLookupByLibrary.simpleMessage(
      "Download speed (Mbps)",
    ),
    "edit": MessageLookupByLibrary.simpleMessage("Edit"),
    "editPlainText": MessageLookupByLibrary.simpleMessage("Edit plain text"),
    "editRuleSet": MessageLookupByLibrary.simpleMessage("Edit config"),
    "editServer": MessageLookupByLibrary.simpleMessage("Edit server"),
    "editSsid": MessageLookupByLibrary.simpleMessage("Edit SSID"),
    "editorUnavailable": MessageLookupByLibrary.simpleMessage(
      "Editor unavailable",
    ),
    "emptyTip": m8,
    "en": MessageLookupByLibrary.simpleMessage("English"),
    "enabled": MessageLookupByLibrary.simpleMessage("Enabled"),
    "encryption": MessageLookupByLibrary.simpleMessage("Encryption"),
    "entries": MessageLookupByLibrary.simpleMessage(" entries"),
    "error": MessageLookupByLibrary.simpleMessage("Error"),
    "exclude": MessageLookupByLibrary.simpleMessage("Hide from recent tasks"),
    "excludeDesc": MessageLookupByLibrary.simpleMessage(
      "Hide the app from recent tasks while it is in the background",
    ),
    "excludeSsids": MessageLookupByLibrary.simpleMessage("Exclude SSIDs"),
    "excludeSsidsDesc": MessageLookupByLibrary.simpleMessage(
      "When connected to Wi-Fi with an excluded SSID, the app\'s running state switches automatically",
    ),
    "existsTip": m9,
    "exit": MessageLookupByLibrary.simpleMessage("Exit"),
    "exitFullScreen": MessageLookupByLibrary.simpleMessage("Exit full screen"),
    "expand": MessageLookupByLibrary.simpleMessage("Standard"),
    "expireTime": MessageLookupByLibrary.simpleMessage("Expiration time"),
    "exportFile": MessageLookupByLibrary.simpleMessage("Export file"),
    "exportLogs": MessageLookupByLibrary.simpleMessage("Export logs"),
    "exportSuccess": MessageLookupByLibrary.simpleMessage("Export successful"),
    "expressiveScheme": MessageLookupByLibrary.simpleMessage("Expressive"),
    "externalLink": MessageLookupByLibrary.simpleMessage("External link"),
    "extraLarge": MessageLookupByLibrary.simpleMessage("Extra large"),
    "fade": MessageLookupByLibrary.simpleMessage("Fade"),
    "feedback": MessageLookupByLibrary.simpleMessage("Feedback"),
    "feedbackDesc": MessageLookupByLibrary.simpleMessage(
      "FlClash is only a proxy tool and does not provide any proxy servers. For problems with a server or its subscription, contact your server provider.",
    ),
    "fidelityScheme": MessageLookupByLibrary.simpleMessage("Fidelity"),
    "file": MessageLookupByLibrary.simpleMessage("File"),
    "fileDesc": MessageLookupByLibrary.simpleMessage(
      "Upload a profile file directly",
    ),
    "filter": MessageLookupByLibrary.simpleMessage("Filter"),
    "fingerprint": MessageLookupByLibrary.simpleMessage("Fingerprint"),
    "flag": MessageLookupByLibrary.simpleMessage("Flag"),
    "floating": MessageLookupByLibrary.simpleMessage("Floating"),
    "flow": MessageLookupByLibrary.simpleMessage("Flow"),
    "followSystem": MessageLookupByLibrary.simpleMessage("Follow system"),
    "fontFamily": MessageLookupByLibrary.simpleMessage("Font family"),
    "fontSize": MessageLookupByLibrary.simpleMessage("Size"),
    "forceRestartCoreTip": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to force restart the core?",
    ),
    "format": MessageLookupByLibrary.simpleMessage("Format"),
    "fragment": MessageLookupByLibrary.simpleMessage("Fragment"),
    "fruitSaladScheme": MessageLookupByLibrary.simpleMessage("Fruit salad"),
    "general": MessageLookupByLibrary.simpleMessage("General"),
    "geoRegion": MessageLookupByLibrary.simpleMessage(
      "Look up server countries",
    ),
    "geoRegionDesc": MessageLookupByLibrary.simpleMessage(
      "Asks a GeoIP service which country a server is in, to show its flag. The server address is sent to that service.",
    ),
    "global": MessageLookupByLibrary.simpleMessage("Global"),
    "globalModeDesc": MessageLookupByLibrary.simpleMessage(
      "Forward all traffic through the proxy",
    ),
    "globalRouting": MessageLookupByLibrary.simpleMessage("Global routing"),
    "go": MessageLookupByLibrary.simpleMessage("Go"),
    "goDownload": MessageLookupByLibrary.simpleMessage("Download"),
    "handshake": MessageLookupByLibrary.simpleMessage("Handshake"),
    "hapticFeedback": MessageLookupByLibrary.simpleMessage("Haptic feedback"),
    "hapticFeedbackDesc": MessageLookupByLibrary.simpleMessage(
      "Vibrates when you turn the proxy on or off, switch pages from the bottom bar or drag the scrollbar",
    ),
    "headerType": MessageLookupByLibrary.simpleMessage("Header type"),
    "helperCorruptTip": MessageLookupByLibrary.simpleMessage(
      "Helper service unavailable; TUN mode cannot be enabled. Reinstall FlClash to restore it.",
    ),
    "hideIp": MessageLookupByLibrary.simpleMessage("Hide IP"),
    "hidePassword": MessageLookupByLibrary.simpleMessage("Hide password"),
    "hideTimeoutProxies": MessageLookupByLibrary.simpleMessage(
      "Hide timed-out nodes",
    ),
    "hideTimeoutProxiesDesc": MessageLookupByLibrary.simpleMessage(
      "Leave out nodes whose last delay test timed out",
    ),
    "home": MessageLookupByLibrary.simpleMessage("Home"),
    "host": MessageLookupByLibrary.simpleMessage("Host"),
    "hotkeyDesc": MessageLookupByLibrary.simpleMessage(
      "Global hotkeys work even while the window is hidden. Tap an action to record its key combination.",
    ),
    "hotkeyManagement": MessageLookupByLibrary.simpleMessage(
      "Hotkey management",
    ),
    "hotkeyMovedFrom": m10,
    "hotkeyNeedsModifier": m11,
    "hotkeyNotSet": MessageLookupByLibrary.simpleMessage("Not set"),
    "hotkeyUnavailable": MessageLookupByLibrary.simpleMessage(
      "Not registered, it may be taken by another app",
    ),
    "hours": MessageLookupByLibrary.simpleMessage("hours"),
    "hoursAgo": m12,
    "icon": MessageLookupByLibrary.simpleMessage("Icon"),
    "iconRecords": MessageLookupByLibrary.simpleMessage("Icon records"),
    "iconStyle": MessageLookupByLibrary.simpleMessage("Icon style"),
    "iconStyleFilled": MessageLookupByLibrary.simpleMessage("Filled"),
    "iconStyleHidden": MessageLookupByLibrary.simpleMessage("Hidden"),
    "iconStylePlain": MessageLookupByLibrary.simpleMessage("Plain"),
    "iconUrl": MessageLookupByLibrary.simpleMessage("Icon URL"),
    "ignoreBatteryOptimization": MessageLookupByLibrary.simpleMessage(
      "Ignore battery optimization",
    ),
    "import": MessageLookupByLibrary.simpleMessage("Import"),
    "importColorsTip": m13,
    "importEllipsis": MessageLookupByLibrary.simpleMessage("Import…"),
    "importFile": MessageLookupByLibrary.simpleMessage("Import from file"),
    "importFromURL": MessageLookupByLibrary.simpleMessage("Import from URL"),
    "importNodesFromClipboardTip": m14,
    "inbound": MessageLookupByLibrary.simpleMessage("Inbound"),
    "infiniteTime": MessageLookupByLibrary.simpleMessage("Never expires"),
    "init": MessageLookupByLibrary.simpleMessage("Init"),
    "installedAppsPermissionDeniedMessage": MessageLookupByLibrary.simpleMessage(
      "The app list permission was denied, so installed apps cannot be listed. Please grant it manually in system settings.",
    ),
    "installedAppsPermissionDesc": MessageLookupByLibrary.simpleMessage(
      "This system hides the installed app list until the permission is granted. Authorize it to configure the per-app proxy.",
    ),
    "installedAppsPermissionRequired": MessageLookupByLibrary.simpleMessage(
      "App list permission required",
    ),
    "intelligentSelected": MessageLookupByLibrary.simpleMessage(
      "Smart selection",
    ),
    "internet": MessageLookupByLibrary.simpleMessage("Internet"),
    "interval": MessageLookupByLibrary.simpleMessage("Interval"),
    "intranetIP": MessageLookupByLibrary.simpleMessage("Intranet IP"),
    "invalidBackupFile": MessageLookupByLibrary.simpleMessage(
      "Invalid backup file",
    ),
    "invalidProfileQrcode": MessageLookupByLibrary.simpleMessage(
      "This QR code doesn\'t contain a profile link",
    ),
    "ipAddress": MessageLookupByLibrary.simpleMessage("IP address"),
    "ipAsn": MessageLookupByLibrary.simpleMessage("ASN"),
    "ipFlagAbuser": MessageLookupByLibrary.simpleMessage("Abuse history"),
    "ipFlagProxy": MessageLookupByLibrary.simpleMessage("Proxy"),
    "ipFlagTor": MessageLookupByLibrary.simpleMessage("Tor"),
    "ipFlagVpn": MessageLookupByLibrary.simpleMessage("VPN"),
    "ipFlags": MessageLookupByLibrary.simpleMessage("Flags"),
    "ipOrganization": MessageLookupByLibrary.simpleMessage("Organization"),
    "ipQualityFailed": MessageLookupByLibrary.simpleMessage(
      "Couldn\'t determine the IP type",
    ),
    "ipQualityGood": MessageLookupByLibrary.simpleMessage("Good"),
    "ipQualityLevel": MessageLookupByLibrary.simpleMessage("Level"),
    "ipQualityNormal": MessageLookupByLibrary.simpleMessage("Normal"),
    "ipQualityRetry": MessageLookupByLibrary.simpleMessage("Check again"),
    "ipQualityRisky": MessageLookupByLibrary.simpleMessage("Risky"),
    "ipQualitySource": MessageLookupByLibrary.simpleMessage("Answered by"),
    "ipQualitySources": MessageLookupByLibrary.simpleMessage("Sources"),
    "ipSourceIpMismatch": MessageLookupByLibrary.simpleMessage(
      "Different outbound IP",
    ),
    "ipSourceNoType": MessageLookupByLibrary.simpleMessage("No type"),
    "ipSourceRateLimited": MessageLookupByLibrary.simpleMessage("Rate limited"),
    "ipType": MessageLookupByLibrary.simpleMessage("Type"),
    "ipTypeBusiness": MessageLookupByLibrary.simpleMessage("Business"),
    "ipTypeHosting": MessageLookupByLibrary.simpleMessage("Data center"),
    "ipTypeMobile": MessageLookupByLibrary.simpleMessage("Mobile network"),
    "ipTypeResidential": MessageLookupByLibrary.simpleMessage("Residential"),
    "ipv6Desc": MessageLookupByLibrary.simpleMessage(
      "When enabled, IPv6 traffic can be received",
    ),
    "ipv6InboundDesc": MessageLookupByLibrary.simpleMessage(
      "Allow IPv6 inbound",
    ),
    "ja": MessageLookupByLibrary.simpleMessage("Japanese"),
    "justNow": MessageLookupByLibrary.simpleMessage("Just now"),
    "key": MessageLookupByLibrary.simpleMessage("Key"),
    "language": MessageLookupByLibrary.simpleMessage("Language"),
    "large": MessageLookupByLibrary.simpleMessage("Large"),
    "lastUpdated": MessageLookupByLibrary.simpleMessage("Last updated"),
    "launchInterrupted": MessageLookupByLibrary.simpleMessage(
      "Launch did not finish",
    ),
    "launchInterruptedTip": MessageLookupByLibrary.simpleMessage(
      "The app exited unexpectedly while it was starting up last time. Automatic setup was skipped for this launch; you can start it manually to retry.",
    ),
    "layout": MessageLookupByLibrary.simpleMessage("Layout"),
    "light": MessageLookupByLibrary.simpleMessage("Light"),
    "lineIssueTip": m15,
    "lineWrap": MessageLookupByLibrary.simpleMessage("Word wrap"),
    "list": MessageLookupByLibrary.simpleMessage("List"),
    "listen": MessageLookupByLibrary.simpleMessage("Listen"),
    "loading": MessageLookupByLibrary.simpleMessage("Loading…"),
    "local": MessageLookupByLibrary.simpleMessage("Local"),
    "localFiles": MessageLookupByLibrary.simpleMessage("Local files"),
    "localNetworkDeniedTip": MessageLookupByLibrary.simpleMessage(
      "Local network permission denied: using the gvisor stack, LAN is unreachable.",
    ),
    "localProfile": MessageLookupByLibrary.simpleMessage("Local servers"),
    "locationPermission": MessageLookupByLibrary.simpleMessage(
      "Location permission",
    ),
    "locationPermissionDeniedMessage": MessageLookupByLibrary.simpleMessage(
      "Location permission was denied, so the current Wi-Fi name cannot be read. Please enable location permission manually in system settings.",
    ),
    "locationPermissionDesc": MessageLookupByLibrary.simpleMessage(
      "The system requires location permission to read the Wi-Fi name. On Android choose \"Allow all the time\", otherwise the Wi-Fi name cannot be read while the app is in the background.",
    ),
    "locationPermissionGuide": m16,
    "locationPermissionRequired": MessageLookupByLibrary.simpleMessage(
      "Location permission required",
    ),
    "log": MessageLookupByLibrary.simpleMessage("Log"),
    "logLevel": MessageLookupByLibrary.simpleMessage("Log level"),
    "logcat": MessageLookupByLibrary.simpleMessage("Logcat"),
    "logcatDesc": MessageLookupByLibrary.simpleMessage(
      "Disabling hides the log entry point",
    ),
    "logs": MessageLookupByLibrary.simpleMessage("Logs"),
    "logsAndDiagnostics": MessageLookupByLibrary.simpleMessage(
      "Logs and diagnostics",
    ),
    "logsTest": MessageLookupByLibrary.simpleMessage("Logs test"),
    "loopback": MessageLookupByLibrary.simpleMessage("UWP loopback exemption"),
    "loose": MessageLookupByLibrary.simpleMessage("Loose"),
    "manual": MessageLookupByLibrary.simpleMessage("Manual"),
    "matchDomain": MessageLookupByLibrary.simpleMessage("Full domain"),
    "matchDomainSuffix": MessageLookupByLibrary.simpleMessage("Domain suffix"),
    "matchKeyword": MessageLookupByLibrary.simpleMessage("Domain keyword"),
    "matchRegexp": MessageLookupByLibrary.simpleMessage("Domain regex"),
    "maxLengthTip": m17,
    "maximize": MessageLookupByLibrary.simpleMessage("Maximize"),
    "memoryAppResident": MessageLookupByLibrary.simpleMessage(
      "Resident memory",
    ),
    "memoryAppShared": MessageLookupByLibrary.simpleMessage("App & shared"),
    "memoryCoreHeapIdle": MessageLookupByLibrary.simpleMessage("Heap idle"),
    "memoryCoreHeapInuse": MessageLookupByLibrary.simpleMessage("Heap in use"),
    "memoryCoreNotRunning": MessageLookupByLibrary.simpleMessage(
      "Core is not running",
    ),
    "memoryCoreRuntime": MessageLookupByLibrary.simpleMessage(
      "Runtime overhead",
    ),
    "memoryCoreStack": MessageLookupByLibrary.simpleMessage("Goroutine stacks"),
    "memoryEstimateDesc": MessageLookupByLibrary.simpleMessage(
      "Estimated from process resident memory; it may differ from what the system reports.",
    ),
    "memoryEstimateSharedDesc": MessageLookupByLibrary.simpleMessage(
      "The Core runs inside the app process. Its share is estimated from runtime stats, and the rest counts as app and shared memory.",
    ),
    "memoryInfo": MessageLookupByLibrary.simpleMessage("Memory info"),
    "memoryReleased": MessageLookupByLibrary.simpleMessage("Memory released"),
    "memoryReleasedSize": m18,
    "menuBar": MessageLookupByLibrary.simpleMessage("Menu bar"),
    "menuBarEmbedded": MessageLookupByLibrary.simpleMessage("Embedded"),
    "menuBarStandalone": MessageLookupByLibrary.simpleMessage("Standalone"),
    "messageTest": MessageLookupByLibrary.simpleMessage("Message test"),
    "messageTestTip": MessageLookupByLibrary.simpleMessage(
      "This is a message.",
    ),
    "min": MessageLookupByLibrary.simpleMessage("Minimal"),
    "minimize": MessageLookupByLibrary.simpleMessage("Minimize"),
    "minimizeOnExit": MessageLookupByLibrary.simpleMessage("Minimize on exit"),
    "minutesAgo": m19,
    "mixedPort": MessageLookupByLibrary.simpleMessage("Mixed port"),
    "mode": MessageLookupByLibrary.simpleMessage("Mode"),
    "monochromeScheme": MessageLookupByLibrary.simpleMessage("Monochrome"),
    "monthsAgo": m20,
    "more": MessageLookupByLibrary.simpleMessage("More"),
    "multiMode": MessageLookupByLibrary.simpleMessage("Multi mode"),
    "multiplexing": MessageLookupByLibrary.simpleMessage("Multiplexing"),
    "name": MessageLookupByLibrary.simpleMessage("Name"),
    "navigationBarStyle": MessageLookupByLibrary.simpleMessage("Bottom bar"),
    "network": MessageLookupByLibrary.simpleMessage("Network"),
    "networkAccessDeniedError": MessageLookupByLibrary.simpleMessage(
      "The server denied access. The link may have expired, or the credentials are wrong",
    ),
    "networkBadResponseError": MessageLookupByLibrary.simpleMessage(
      "The server rejected the request",
    ),
    "networkCancelledError": MessageLookupByLibrary.simpleMessage(
      "The request was cancelled",
    ),
    "networkConnectionError": MessageLookupByLibrary.simpleMessage(
      "Couldn\'t connect to the server. Check your network connection or proxy settings",
    ),
    "networkDetection": MessageLookupByLibrary.simpleMessage(
      "Network detection",
    ),
    "networkHostLookupError": MessageLookupByLibrary.simpleMessage(
      "Couldn\'t resolve the server address. Check that the URL is correct and DNS is working",
    ),
    "networkNotFoundError": MessageLookupByLibrary.simpleMessage(
      "Nothing was found at this address. Check that the URL is correct",
    ),
    "networkRateLimitedError": MessageLookupByLibrary.simpleMessage(
      "Too many requests. Wait a moment and try again",
    ),
    "networkRequestFailed": m21,
    "networkServerError": MessageLookupByLibrary.simpleMessage(
      "The server ran into a problem. Try again later",
    ),
    "networkSpeed": MessageLookupByLibrary.simpleMessage("Network speed"),
    "networkTimeoutError": MessageLookupByLibrary.simpleMessage(
      "The request timed out. Check your network or proxy, then try again",
    ),
    "networkTlsError": MessageLookupByLibrary.simpleMessage(
      "Secure connection failed. The server\'s certificate may be invalid, or the connection is being intercepted",
    ),
    "networkType": MessageLookupByLibrary.simpleMessage("Network type"),
    "neutralScheme": MessageLookupByLibrary.simpleMessage("Neutral"),
    "nextMatch": MessageLookupByLibrary.simpleMessage("Next match"),
    "no": MessageLookupByLibrary.simpleMessage("No"),
    "noData": MessageLookupByLibrary.simpleMessage("No data"),
    "noInfo": MessageLookupByLibrary.simpleMessage("No info"),
    "noLongerRemind": MessageLookupByLibrary.simpleMessage(
      "Don\'t remind me again",
    ),
    "noNetwork": MessageLookupByLibrary.simpleMessage("No network"),
    "noNetworkApp": MessageLookupByLibrary.simpleMessage("No-network apps"),
    "noRules": MessageLookupByLibrary.simpleMessage("No rules yet"),
    "noSearchResults": MessageLookupByLibrary.simpleMessage(
      "No matching results",
    ),
    "noUsableNodes": MessageLookupByLibrary.simpleMessage(
      "No usable nodes were found. Check that the link or file is correct, or contact your service provider.",
    ),
    "nodeInvalid": MessageLookupByLibrary.simpleMessage(
      "These values do not make a usable server.",
    ),
    "none": MessageLookupByLibrary.simpleMessage("None"),
    "notConnected": MessageLookupByLibrary.simpleMessage("Not connected"),
    "notSelectedTip": MessageLookupByLibrary.simpleMessage(
      "The current proxy group cannot be selected",
    ),
    "nullProfileDesc": MessageLookupByLibrary.simpleMessage(
      "Add a profile to get started",
    ),
    "nullTip": m22,
    "numberTip": m23,
    "obfsPassword": MessageLookupByLibrary.simpleMessage(
      "Obfuscation password",
    ),
    "off": MessageLookupByLibrary.simpleMessage("Off"),
    "on": MessageLookupByLibrary.simpleMessage("On"),
    "onDemand": MessageLookupByLibrary.simpleMessage("On demand"),
    "onDemandDesc": MessageLookupByLibrary.simpleMessage(
      "Configure the app\'s running state for specific scenarios",
    ),
    "onlyStatisticsProxy": MessageLookupByLibrary.simpleMessage(
      "Only count proxy traffic",
    ),
    "openApp": m24,
    "optional": MessageLookupByLibrary.simpleMessage("Optional"),
    "options": MessageLookupByLibrary.simpleMessage("Options"),
    "other": MessageLookupByLibrary.simpleMessage("Other"),
    "outboundMode": MessageLookupByLibrary.simpleMessage("Outbound mode"),
    "override": MessageLookupByLibrary.simpleMessage("Override"),
    "overwriteExisting": MessageLookupByLibrary.simpleMessage(
      "Overwrite existing",
    ),
    "overwriteExistingDesc": MessageLookupByLibrary.simpleMessage(
      "Replace the existing server when the name matches",
    ),
    "palette": MessageLookupByLibrary.simpleMessage("Palette"),
    "password": MessageLookupByLibrary.simpleMessage("Password"),
    "paste": MessageLookupByLibrary.simpleMessage("Paste"),
    "path": MessageLookupByLibrary.simpleMessage("Path"),
    "permissions": MessageLookupByLibrary.simpleMessage("Permissions"),
    "pickFromAlbum": MessageLookupByLibrary.simpleMessage("Choose from album"),
    "pinWindow": MessageLookupByLibrary.simpleMessage("Pin window"),
    "pleaseBindWebDAV": MessageLookupByLibrary.simpleMessage(
      "Please bind WebDAV",
    ),
    "pleaseUploadValidQrcode": MessageLookupByLibrary.simpleMessage(
      "Please upload a valid QR code",
    ),
    "policyBlock": MessageLookupByLibrary.simpleMessage("Reject"),
    "policyDirect": MessageLookupByLibrary.simpleMessage("Direct"),
    "policyProxy": MessageLookupByLibrary.simpleMessage("Proxy"),
    "port": MessageLookupByLibrary.simpleMessage("Port"),
    "portHopping": MessageLookupByLibrary.simpleMessage("Port hopping"),
    "portTip": m25,
    "prerequisites": MessageLookupByLibrary.simpleMessage("Prerequisites"),
    "pressKeyboard": MessageLookupByLibrary.simpleMessage(
      "Press a key combination",
    ),
    "preview": MessageLookupByLibrary.simpleMessage("Preview"),
    "previousMatch": MessageLookupByLibrary.simpleMessage("Previous match"),
    "process": MessageLookupByLibrary.simpleMessage("Process"),
    "profile": MessageLookupByLibrary.simpleMessage("Profile"),
    "profileAutoUpdateIntervalInvalidValidationDesc":
        MessageLookupByLibrary.simpleMessage("Please enter a valid interval"),
    "profileAutoUpdateIntervalNullValidationDesc":
        MessageLookupByLibrary.simpleMessage(
          "Please enter the auto-update interval",
        ),
    "profileInUseTip": MessageLookupByLibrary.simpleMessage(
      "A check mark marks the profile in use.",
    ),
    "profileNameNullValidationDesc": MessageLookupByLibrary.simpleMessage(
      "Please enter the profile name",
    ),
    "profileType": MessageLookupByLibrary.simpleMessage("Type"),
    "profileUrlInvalidValidationDesc": MessageLookupByLibrary.simpleMessage(
      "Please enter a valid profile URL",
    ),
    "profileUrlNullValidationDesc": MessageLookupByLibrary.simpleMessage(
      "Please enter the profile URL",
    ),
    "profiles": MessageLookupByLibrary.simpleMessage("Profiles"),
    "profilesSort": MessageLookupByLibrary.simpleMessage("Sort profiles"),
    "project": MessageLookupByLibrary.simpleMessage("Project"),
    "providers": MessageLookupByLibrary.simpleMessage("External resources"),
    "proxies": MessageLookupByLibrary.simpleMessage("Proxies"),
    "proxyDns": MessageLookupByLibrary.simpleMessage("Proxy DNS"),
    "proxyDnsDesc": MessageLookupByLibrary.simpleMessage(
      "Looks up domains that go through the proxy, asked through the node. The first one is tried first.",
    ),
    "proxyGroup": MessageLookupByLibrary.simpleMessage("Proxy group"),
    "proxyNode": MessageLookupByLibrary.simpleMessage("Proxy node"),
    "proxyProviders": MessageLookupByLibrary.simpleMessage("Proxy providers"),
    "proxyVia": MessageLookupByLibrary.simpleMessage("Proxy via"),
    "pruneCache": MessageLookupByLibrary.simpleMessage("Prune cache"),
    "publicKey": MessageLookupByLibrary.simpleMessage("Public key"),
    "pureBlack": MessageLookupByLibrary.simpleMessage("Pure black"),
    "pureBlackMode": MessageLookupByLibrary.simpleMessage("Pure black mode"),
    "qrcode": MessageLookupByLibrary.simpleMessage("QR code"),
    "qrcodeDesc": MessageLookupByLibrary.simpleMessage(
      "Scan a QR code to obtain a profile",
    ),
    "quitFromMenuBar": MessageLookupByLibrary.simpleMessage(
      "Quit from menu bar",
    ),
    "rainbowScheme": MessageLookupByLibrary.simpleMessage("Rainbow"),
    "redo": MessageLookupByLibrary.simpleMessage("Redo"),
    "releaseMemory": MessageLookupByLibrary.simpleMessage("Release memory"),
    "releaseMemoryFailed": MessageLookupByLibrary.simpleMessage(
      "Failed to release memory",
    ),
    "remainingTraffic": MessageLookupByLibrary.simpleMessage(
      "Remaining traffic",
    ),
    "remote": MessageLookupByLibrary.simpleMessage("Remote"),
    "remove": MessageLookupByLibrary.simpleMessage("Remove"),
    "rename": MessageLookupByLibrary.simpleMessage("Rename"),
    "replace": MessageLookupByLibrary.simpleMessage("Replace"),
    "replaceAll": MessageLookupByLibrary.simpleMessage("Replace all"),
    "request": MessageLookupByLibrary.simpleMessage("Request"),
    "requests": MessageLookupByLibrary.simpleMessage("Requests"),
    "requestsAndUpdates": MessageLookupByLibrary.simpleMessage(
      "Requests and updates",
    ),
    "required": MessageLookupByLibrary.simpleMessage("Required"),
    "reset": MessageLookupByLibrary.simpleMessage("Reset"),
    "resetColors": MessageLookupByLibrary.simpleMessage("Reset colors"),
    "resetCoreSettings": MessageLookupByLibrary.simpleMessage(
      "Reset core settings",
    ),
    "resetCoreSettingsDesc": MessageLookupByLibrary.simpleMessage(
      "This restores the core, network and VPN settings to their defaults. It usually fixes connection failures and VPN problems.",
    ),
    "resetPageChangesTip": MessageLookupByLibrary.simpleMessage(
      "This page has changes. Are you sure you want to reset?",
    ),
    "resetStatistics": MessageLookupByLibrary.simpleMessage("Reset statistics"),
    "resetSuccess": MessageLookupByLibrary.simpleMessage("Reset successful"),
    "resetTip": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to reset?",
    ),
    "resetUserSettings": MessageLookupByLibrary.simpleMessage(
      "Reset user settings",
    ),
    "resetUserSettingsDesc": MessageLookupByLibrary.simpleMessage(
      "Erases every saved preference and profile to clear faults or unexpected behavior. The app exits when it is done.",
    ),
    "resources": MessageLookupByLibrary.simpleMessage("Resources"),
    "restart": MessageLookupByLibrary.simpleMessage("Restart"),
    "restartCoreTip": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to restart the core?",
    ),
    "restore": MessageLookupByLibrary.simpleMessage("Restore"),
    "restoreAllData": MessageLookupByLibrary.simpleMessage("Restore all data"),
    "restoreDefaultRules": MessageLookupByLibrary.simpleMessage(
      "Restore default config",
    ),
    "restoreOnlyConfig": MessageLookupByLibrary.simpleMessage(
      "Restore profiles only",
    ),
    "restoreStrategy": MessageLookupByLibrary.simpleMessage("Restore strategy"),
    "restoreStrategyCompatible": MessageLookupByLibrary.simpleMessage(
      "Compatible",
    ),
    "restoreStrategyOverride": MessageLookupByLibrary.simpleMessage("Override"),
    "restoreSuccess": MessageLookupByLibrary.simpleMessage(
      "Restore successful",
    ),
    "retry": MessageLookupByLibrary.simpleMessage("Retry"),
    "routeAddress": MessageLookupByLibrary.simpleMessage("Route addresses"),
    "routeMode": MessageLookupByLibrary.simpleMessage("Route mode"),
    "routeModeBypassPrivate": MessageLookupByLibrary.simpleMessage(
      "Bypass private addresses",
    ),
    "routeModeConfig": MessageLookupByLibrary.simpleMessage("Use config"),
    "ru": MessageLookupByLibrary.simpleMessage("Russian"),
    "rule": MessageLookupByLibrary.simpleMessage("Rule"),
    "ruleCount": m26,
    "ruleMatch": MessageLookupByLibrary.simpleMessage("Match"),
    "ruleModeDesc": MessageLookupByLibrary.simpleMessage(
      "Forward traffic by the routing rules",
    ),
    "rulePolicy": MessageLookupByLibrary.simpleMessage("Policy"),
    "ruleProviders": MessageLookupByLibrary.simpleMessage("Rule providers"),
    "ruleSets": MessageLookupByLibrary.simpleMessage("Rule sets"),
    "ruleValue": MessageLookupByLibrary.simpleMessage("Value"),
    "ruleValueHint": MessageLookupByLibrary.simpleMessage(
      "Separate several with commas",
    ),
    "rules": MessageLookupByLibrary.simpleMessage("Rules"),
    "rulesFooter": MessageLookupByLibrary.simpleMessage(
      "Rules apply in rule mode. Traffic no rule matches goes through the proxy.",
    ),
    "rulesInvalid": MessageLookupByLibrary.simpleMessage(
      "No Xray routing rules found",
    ),
    "rulesLegend": MessageLookupByLibrary.simpleMessage(
      "A dot marks the default config; a check marks the one in use.",
    ),
    "runTime": MessageLookupByLibrary.simpleMessage("Run time"),
    "safeMode": MessageLookupByLibrary.simpleMessage("Safe mode"),
    "safeModeAppTitle": m27,
    "save": MessageLookupByLibrary.simpleMessage("Save"),
    "saveChanges": MessageLookupByLibrary.simpleMessage("Save the changes?"),
    "saveSuccess": MessageLookupByLibrary.simpleMessage("Saved successfully"),
    "schemeAdd": MessageLookupByLibrary.simpleMessage("Add a server"),
    "schemeRoute": MessageLookupByLibrary.simpleMessage("Switch routing"),
    "schemeServer": MessageLookupByLibrary.simpleMessage("Switch server"),
    "schemeStart": MessageLookupByLibrary.simpleMessage("Start the VPN tunnel"),
    "schemeStop": MessageLookupByLibrary.simpleMessage("Stop the VPN tunnel"),
    "schemeToggle": MessageLookupByLibrary.simpleMessage(
      "Toggle the VPN tunnel",
    ),
    "schemeUpdateProfiles": MessageLookupByLibrary.simpleMessage(
      "Update subscriptions",
    ),
    "script": MessageLookupByLibrary.simpleMessage("Script"),
    "scrollToSelected": MessageLookupByLibrary.simpleMessage(
      "Scroll to selected",
    ),
    "search": MessageLookupByLibrary.simpleMessage("Search"),
    "seconds": MessageLookupByLibrary.simpleMessage("seconds"),
    "security": MessageLookupByLibrary.simpleMessage("Security"),
    "selectAll": MessageLookupByLibrary.simpleMessage("Select all"),
    "selected": MessageLookupByLibrary.simpleMessage("Selected"),
    "selectedCountTitle": m28,
    "server": MessageLookupByLibrary.simpleMessage("Server"),
    "serverName": MessageLookupByLibrary.simpleMessage("Server name (SNI)"),
    "serverNodes": MessageLookupByLibrary.simpleMessage("Server nodes"),
    "serviceAvailable": MessageLookupByLibrary.simpleMessage("Available"),
    "serviceBlocked": MessageLookupByLibrary.simpleMessage("Blocked"),
    "serviceCheck": MessageLookupByLibrary.simpleMessage("Check"),
    "serviceCheckAll": MessageLookupByLibrary.simpleMessage("Check all"),
    "serviceCheckedAt": m29,
    "serviceComingSoon": MessageLookupByLibrary.simpleMessage("Coming soon"),
    "serviceDisallowedIsp": MessageLookupByLibrary.simpleMessage(
      "Disallowed ISP",
    ),
    "serviceFailed": MessageLookupByLibrary.simpleMessage("Check failed"),
    "serviceManage": MessageLookupByLibrary.simpleMessage("Manage services"),
    "serviceName": MessageLookupByLibrary.simpleMessage("Service name"),
    "serviceOriginalsOnly": MessageLookupByLibrary.simpleMessage(
      "Originals only",
    ),
    "servicePending": MessageLookupByLibrary.simpleMessage("Not checked"),
    "serviceRestricted": MessageLookupByLibrary.simpleMessage(
      "Access restricted",
    ),
    "serviceStatus": MessageLookupByLibrary.simpleMessage("Service status"),
    "serviceUnavailable": MessageLookupByLibrary.simpleMessage("Unavailable"),
    "serviceUnsupportedRegion": MessageLookupByLibrary.simpleMessage(
      "Region not supported",
    ),
    "settings": MessageLookupByLibrary.simpleMessage("Settings"),
    "shortId": MessageLookupByLibrary.simpleMessage("Short ID"),
    "show": MessageLookupByLibrary.simpleMessage("Show"),
    "showLess": MessageLookupByLibrary.simpleMessage("Collapse"),
    "showMore": MessageLookupByLibrary.simpleMessage("Expand"),
    "showNotificationStopAction": MessageLookupByLibrary.simpleMessage(
      "Stop button in notification",
    ),
    "showPassword": MessageLookupByLibrary.simpleMessage("Show password"),
    "shrink": MessageLookupByLibrary.simpleMessage("Compact"),
    "sidebar": MessageLookupByLibrary.simpleMessage("Sidebar"),
    "sidebarBlur": MessageLookupByLibrary.simpleMessage("Sidebar blur"),
    "sidebarBlurDesc": MessageLookupByLibrary.simpleMessage(
      "Show the blurred desktop behind the window through the sidebar",
    ),
    "silentLaunch": MessageLookupByLibrary.simpleMessage("Silent launch"),
    "silentLaunchDesc": MessageLookupByLibrary.simpleMessage(
      "Start without showing the window",
    ),
    "singleAdd": MessageLookupByLibrary.simpleMessage("Single add"),
    "singleValueTip": m30,
    "size": MessageLookupByLibrary.simpleMessage("Size"),
    "slide": MessageLookupByLibrary.simpleMessage("Slide"),
    "sort": MessageLookupByLibrary.simpleMessage("Sort"),
    "source": MessageLookupByLibrary.simpleMessage("Source"),
    "speedStatistics": MessageLookupByLibrary.simpleMessage("Speed statistics"),
    "ssidsEmpty": MessageLookupByLibrary.simpleMessage("SSIDs are empty"),
    "standard": MessageLookupByLibrary.simpleMessage("Standard"),
    "starOnGithub": MessageLookupByLibrary.simpleMessage("Star on GitHub"),
    "start": MessageLookupByLibrary.simpleMessage("Start"),
    "startTime": MessageLookupByLibrary.simpleMessage("Start time"),
    "startVpn": MessageLookupByLibrary.simpleMessage("Starting VPN…"),
    "startupAndBackground": MessageLookupByLibrary.simpleMessage(
      "Startup and background",
    ),
    "statistics": MessageLookupByLibrary.simpleMessage("Statistics"),
    "status": MessageLookupByLibrary.simpleMessage("Status"),
    "stop": MessageLookupByLibrary.simpleMessage("Stop"),
    "stopVpn": MessageLookupByLibrary.simpleMessage("Stopping VPN…"),
    "strategy": MessageLookupByLibrary.simpleMessage("Strategy"),
    "style": MessageLookupByLibrary.simpleMessage("Style"),
    "subRule": MessageLookupByLibrary.simpleMessage("Sub-rule"),
    "submit": MessageLookupByLibrary.simpleMessage("Submit"),
    "subscribe": MessageLookupByLibrary.simpleMessage("Subscribe"),
    "subscribeDesc": MessageLookupByLibrary.simpleMessage(
      "Subscription URL or Xray JSON",
    ),
    "subscriptionFoldTip": MessageLookupByLibrary.simpleMessage(
      "Tap a subscription to fold or expand its nodes.",
    ),
    "subscriptionInfo": MessageLookupByLibrary.simpleMessage(
      "Subscription info",
    ),
    "subscriptionUrlError": MessageLookupByLibrary.simpleMessage(
      "There was a problem with the server URL. Please try again later. If the problem persists, turn off the VPN and try again, or contact your proxy service provider.",
    ),
    "suspended": MessageLookupByLibrary.simpleMessage("Suspended…"),
    "switchProfile": MessageLookupByLibrary.simpleMessage("Switch profile"),
    "sync": MessageLookupByLibrary.simpleMessage("Sync"),
    "system": MessageLookupByLibrary.simpleMessage("System"),
    "systemApp": MessageLookupByLibrary.simpleMessage("System apps"),
    "systemProxy": MessageLookupByLibrary.simpleMessage("System proxy"),
    "tab": MessageLookupByLibrary.simpleMessage("Tab"),
    "tabAnimation": MessageLookupByLibrary.simpleMessage("Tab animation"),
    "tapToAuthorize": MessageLookupByLibrary.simpleMessage("Tap to authorize"),
    "tcpFastOpen": MessageLookupByLibrary.simpleMessage("TCP Fast Open"),
    "test": MessageLookupByLibrary.simpleMessage("Test"),
    "testRules": MessageLookupByLibrary.simpleMessage("Test rules"),
    "testRulesGeoNote": MessageLookupByLibrary.simpleMessage(
      "GeoSite and GeoIP entries can only be checked by the core, so they are skipped here.",
    ),
    "testRulesHint": MessageLookupByLibrary.simpleMessage("Domain or IP"),
    "testRulesMatched": MessageLookupByLibrary.simpleMessage("Matched rule"),
    "testRulesNoMatch": MessageLookupByLibrary.simpleMessage(
      "No rule matches, so it goes through the proxy",
    ),
    "testUrl": MessageLookupByLibrary.simpleMessage("Test URL"),
    "testUrlDesc": MessageLookupByLibrary.simpleMessage("The URL to test."),
    "textScale": MessageLookupByLibrary.simpleMessage("Text scaling"),
    "textScalePreview": MessageLookupByLibrary.simpleMessage(
      "Text in the app will look like this",
    ),
    "theme": MessageLookupByLibrary.simpleMessage("Theme"),
    "themeColor": MessageLookupByLibrary.simpleMessage("Theme color"),
    "themeDesc": MessageLookupByLibrary.simpleMessage(
      "Set dark mode and adjust colors",
    ),
    "themeMode": MessageLookupByLibrary.simpleMessage("Theme mode"),
    "tight": MessageLookupByLibrary.simpleMessage("Tight"),
    "time": MessageLookupByLibrary.simpleMessage("Time"),
    "timeout": MessageLookupByLibrary.simpleMessage("Timeout"),
    "timeoutDesc": MessageLookupByLibrary.simpleMessage(
      "If the test does not finish before the timeout, it is given up.",
    ),
    "tip": MessageLookupByLibrary.simpleMessage("Tip"),
    "toggle": MessageLookupByLibrary.simpleMessage("Toggle"),
    "toggleSpeedView": MessageLookupByLibrary.simpleMessage(
      "Toggle speed view",
    ),
    "tolerance": MessageLookupByLibrary.simpleMessage("Tolerance"),
    "tonalSpotScheme": MessageLookupByLibrary.simpleMessage("Tonal spot"),
    "tools": MessageLookupByLibrary.simpleMessage("Tools"),
    "torch": MessageLookupByLibrary.simpleMessage("Flashlight"),
    "total": MessageLookupByLibrary.simpleMessage("Total"),
    "totalTraffic": MessageLookupByLibrary.simpleMessage("Total traffic"),
    "traffic": MessageLookupByLibrary.simpleMessage("Traffic"),
    "trafficAll": MessageLookupByLibrary.simpleMessage("All"),
    "trafficProxy": MessageLookupByLibrary.simpleMessage("Proxy"),
    "trafficUsage": MessageLookupByLibrary.simpleMessage("Traffic usage"),
    "transportMethod": MessageLookupByLibrary.simpleMessage("Transport"),
    "transportMode": MessageLookupByLibrary.simpleMessage("Transport"),
    "tun": MessageLookupByLibrary.simpleMessage("TUN"),
    "tunDesc": MessageLookupByLibrary.simpleMessage(
      "Only effective in administrator mode",
    ),
    "tunnel": MessageLookupByLibrary.simpleMessage("Tunnel"),
    "turnOff": MessageLookupByLibrary.simpleMessage("Turn off"),
    "turnOn": MessageLookupByLibrary.simpleMessage("Turn on"),
    "udpRelay": MessageLookupByLibrary.simpleMessage("UDP relay"),
    "undo": MessageLookupByLibrary.simpleMessage("Undo"),
    "unknown": MessageLookupByLibrary.simpleMessage("Unknown"),
    "unknownNetworkError": MessageLookupByLibrary.simpleMessage(
      "Unknown network error",
    ),
    "unmaximize": MessageLookupByLibrary.simpleMessage("Restore down"),
    "unnamed": MessageLookupByLibrary.simpleMessage("Unnamed"),
    "unpinWindow": MessageLookupByLibrary.simpleMessage("Unpin window"),
    "update": MessageLookupByLibrary.simpleMessage("Update"),
    "updateAll": MessageLookupByLibrary.simpleMessage("Update all"),
    "updateSuccess": MessageLookupByLibrary.simpleMessage(
      "Updated successfully",
    ),
    "uploadSpeed": MessageLookupByLibrary.simpleMessage("Upload speed (Mbps)"),
    "url": MessageLookupByLibrary.simpleMessage("URL"),
    "urlDesc": MessageLookupByLibrary.simpleMessage(
      "Obtain a profile from a URL",
    ),
    "urlSchemes": MessageLookupByLibrary.simpleMessage("URL Schemes"),
    "urlTestSettings": MessageLookupByLibrary.simpleMessage(
      "URL test settings",
    ),
    "urlTip": m31,
    "usedDownloadTraffic": MessageLookupByLibrary.simpleMessage(
      "Download used",
    ),
    "usedTraffic": MessageLookupByLibrary.simpleMessage("Used traffic"),
    "usedUploadTraffic": MessageLookupByLibrary.simpleMessage("Upload used"),
    "userAgent": MessageLookupByLibrary.simpleMessage("User-Agent"),
    "username": MessageLookupByLibrary.simpleMessage("Username"),
    "uuid": MessageLookupByLibrary.simpleMessage("UUID"),
    "value": MessageLookupByLibrary.simpleMessage("Value"),
    "version": MessageLookupByLibrary.simpleMessage("Version"),
    "vibrantScheme": MessageLookupByLibrary.simpleMessage("Vibrant"),
    "view": MessageLookupByLibrary.simpleMessage("View"),
    "vpnConfigChangeDetected": MessageLookupByLibrary.simpleMessage(
      "VPN-related configuration change detected",
    ),
    "vpnEnableDesc": MessageLookupByLibrary.simpleMessage(
      "Route all system traffic through VpnService automatically",
    ),
    "vpnTip": MessageLookupByLibrary.simpleMessage(
      "Changes take effect after restarting the VPN",
    ),
    "webDAVConfiguration": MessageLookupByLibrary.simpleMessage(
      "WebDAV configuration",
    ),
    "whitelistMode": MessageLookupByLibrary.simpleMessage("Whitelist mode"),
    "yearsAgo": m32,
    "zhCN": MessageLookupByLibrary.simpleMessage("Simplified Chinese"),
  };
}
