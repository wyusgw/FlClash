import AVFoundation
import Cocoa
import FlutterMacOS

struct PluginError: Error {
    let code: String
    let message: String?
}

public extension NSWindow {
    private static var hiddenAtLaunchKey = false

    // MainFlutterWindow.order(_:relativeTo:) calls this on every order call;
    // only the first one should hide the still-being-configured window.
    private var hiddenAtLaunchConfigured: Bool {
        get { objc_getAssociatedObject(self, &Self.hiddenAtLaunchKey) as? Bool ?? false }
        set { objc_setAssociatedObject(self, &Self.hiddenAtLaunchKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    func hiddenWindowAtLaunch() {
        if !hiddenAtLaunchConfigured {
            setIsVisible(false)
            hiddenAtLaunchConfigured = true
        }
    }
}

public class WindowPlugin: NSObject, FlutterPlugin {
    public static var instance: WindowPlugin?

    private var channel: FlutterMethodChannel?
    private var lifecycle: FlutterBasicMessageChannel?
    private var registrar: FlutterPluginRegistrar?
    private let controller = WindowController()
    private lazy var handlers: [String: (Arguments) throws -> Any?] = makeHandlers()
    private var active = NSApp.isActive
    private var reportedHidden = false
    private var chosenMenuItem: Int?
    private var speechText: String?
    private let speaker = AVSpeechSynthesizer()

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "window", binaryMessenger: registrar.messenger)
        let plugin = WindowPlugin()
        plugin.registrar = registrar
        plugin.channel = channel
        plugin.lifecycle = FlutterBasicMessageChannel(
            name: "flutter/lifecycle",
            binaryMessenger: registrar.messenger,
            codec: FlutterStringCodec.sharedInstance()
        )
        for name in [NSApplication.willBecomeActiveNotification, NSApplication.willResignActiveNotification] {
            NotificationCenter.default.addObserver(
                plugin, selector: #selector(applicationActivityChanged), name: name, object: nil
            )
        }
        WindowPlugin.instance = plugin
        registrar.addMethodCallDelegate(plugin, channel: channel)
    }

    public override init() {
        super.init()
        controller.onEvent = { [weak self] name in
            self?.emit(name)
        }
        controller.onBecameVisible = { [weak self] in
            self?.windowBecameVisible()
        }
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let arguments = Arguments((call.arguments as? [String: Any]) ?? [:])
        guard let handler = handlers[call.method] else {
            result(FlutterMethodNotImplemented)
            return
        }
        do {
            result(try handler(arguments))
        } catch let error as ArgumentError {
            result(FlutterError(code: "bad_args", message: "\(call.method): \(error.key)", details: nil))
        } catch let error as PluginError {
            result(FlutterError(code: error.code, message: error.message, details: nil))
        } catch {
            result(FlutterError(code: "unsupported", message: "\(error)", details: nil))
        }
    }

    /// Forwarded from `applicationShouldTerminate` so Dart can run shutdown work first.
    public func handleShouldTerminate() {
        emit("should-terminate")
    }

    /// Forwarded from `applicationShouldHandleReopen` (Dock reopen / second launch).
    public func handleReopen() {
        emit("activate")
    }

    // The engine resumes on activation if any app window is visible, and the status item's always is.
    @objc private func applicationActivityChanged(_ notification: Notification) {
        active = notification.name == NSApplication.willBecomeActiveNotification
        DispatchQueue.main.async { [weak self] in
            guard let self, (try? self.controller.isVisible()) == false else { return }
            self.reportedHidden = true
            self.lifecycle?.sendMessage("AppLifecycleState.hidden")
        }
    }

    // Back without another activation change, the window would wait on an occlusion notification macOS may not post.
    private func windowBecameVisible() {
        guard reportedHidden else { return }
        reportedHidden = false
        lifecycle?.sendMessage(active ? "AppLifecycleState.resumed" : "AppLifecycleState.inactive")
    }

    /// Pops the system's text menu at a point of the Flutter view, given from
    /// its top left, and answers with the index of the entry chosen, or nil.
    /// Its titles and the Spelling, Substitutions and Speech submenus are the
    /// ones AppKit gives a text view; Cut, Copy and Paste act on what Flutter
    /// holds, and only Speech works of the submenus.
    private func showTextMenu(
        x: Double, y: Double, entries: [[String: Any]], speech: String?
    ) throws -> Int? {
        guard let view = registrar?.view else {
            throw PluginError(code: "not_initialized", message: "no Flutter view")
        }
        chosenMenuItem = nil
        speechText = speech
        let template = NSTextView.defaultMenu
        let menu = NSMenu()
        menu.autoenablesItems = false

        func systemTitle(_ selector: String) -> String? {
            template?.items.first { $0.action == NSSelectorFromString(selector) }?.title
        }
        let selectors = ["cut": "cut:", "copy": "copy:", "paste": "paste:"]
        for (index, entry) in entries.enumerated() {
            guard let id = entry["id"] as? String, let selector = selectors[id] else { continue }
            let title = systemTitle(selector) ?? entry["label"] as? String ?? id
            let item = NSMenuItem(title: title, action: #selector(textMenuItemChosen(_:)), keyEquivalent: "")
            item.target = self
            item.tag = index
            item.isEnabled = entry["enabled"] as? Bool ?? true
            menu.addItem(item)
        }

        menu.addItem(NSMenuItem.separator())
        for probe in ["checkSpelling:", "orderFrontSubstitutionsPanel:", "startSpeaking:"] {
            guard let source = template?.items.first(where: { item in
                item.submenu?.items.contains { $0.action == NSSelectorFromString(probe) } == true
            }) else { continue }
            let item = source.copy() as! NSMenuItem
            item.isEnabled = true
            if probe == "startSpeaking:" {
                wireSpeech(item.submenu)
            } else {
                disable(item.submenu)
            }
            menu.addItem(item)
        }

        let point = NSPoint(x: x, y: view.isFlipped ? y : view.bounds.height - y)
        menu.popUp(positioning: nil, at: point, in: view)
        return chosenMenuItem
    }

    // What the field cannot do shows greyed, as the system shows what a view
    // does not answer to.
    private func disable(_ menu: NSMenu?) {
        guard let menu else { return }
        menu.autoenablesItems = false
        for item in menu.items {
            item.isEnabled = false
            disable(item.submenu)
        }
    }

    private func wireSpeech(_ menu: NSMenu?) {
        guard let menu else { return }
        menu.autoenablesItems = false
        for item in menu.items {
            switch item.action.map(NSStringFromSelector) {
            case "startSpeaking:":
                item.target = self
                item.action = #selector(startSpeaking(_:))
                item.isEnabled = !(speechText ?? "").isEmpty
            case "stopSpeaking:":
                item.target = self
                item.action = #selector(stopSpeaking(_:))
                item.isEnabled = speaker.isSpeaking
            default:
                item.isEnabled = false
            }
        }
    }

    @objc private func startSpeaking(_ sender: NSMenuItem) {
        guard let text = speechText, !text.isEmpty else { return }
        speaker.stopSpeaking(at: .immediate)
        speaker.speak(AVSpeechUtterance(string: text))
    }

    @objc private func stopSpeaking(_ sender: NSMenuItem) {
        speaker.stopSpeaking(at: .immediate)
    }

    @objc private func textMenuItemChosen(_ sender: NSMenuItem) {
        chosenMenuItem = sender.tag
    }

    private func emit(_ name: String) {
        channel?.invokeMethod("onEvent", arguments: ["name": name])
    }

    private func makeHandlers() -> [String: (Arguments) throws -> Any?] {
        let controller = self.controller

        var handlers: [String: (Arguments) throws -> Any?] = [
            "show": { args in try controller.show(inactive: args.bool("inactive")); return nil },
            "hide": { _ in try controller.hide(); return nil },
            "isVisible": { _ in try controller.isVisible() },
            "focus": { _ in try controller.focus(); return nil },
            "close": { _ in try controller.close(); return nil },
            "setPreventClose": { args in try controller.setPreventClose(args.bool("value")); return nil },
            "isMaximized": { _ in try controller.isMaximized() },
            "maximize": { _ in try controller.maximize(); return nil },
            "unmaximize": { _ in try controller.unmaximize(); return nil },
            "isMinimized": { _ in try controller.isMinimized() },
            "minimize": { _ in try controller.minimize(); return nil },
            "restore": { _ in try controller.restore(); return nil },
            "isFullScreen": { _ in try controller.isFullScreen() },
            "setFullScreen": { args in try controller.setFullScreen(args.bool("value")); return nil },
            "getBounds": { _ in try controller.getBounds() },
            "setBounds": { args in
                try controller.setBounds(
                    x: args.optionalDouble("x"),
                    y: args.optionalDouble("y"),
                    width: args.optionalDouble("width"),
                    height: args.optionalDouble("height")
                )
                return nil
            },
            "isPositionSupported": { _ in try controller.isPositionSupported() },
            "setMinimumSize": { args in
                try controller.setMinimumSize(width: args.double("width"), height: args.double("height"))
                return nil
            },
            "isAlwaysOnTop": { _ in try controller.isAlwaysOnTop() },
            "setAlwaysOnTop": { args in try controller.setAlwaysOnTop(args.bool("value")); return nil },
            "setTitleBarStyle": { args in
                try controller.setTitleBarStyle(
                    style: args.string("style"),
                    windowButtonVisibility: args.bool("windowButtonVisibility")
                )
                return nil
            },
            "setSkipTaskbar": { args in try controller.setSkipTaskbar(args.bool("value")); return nil },
            "setRoundedCorners": { args in
                try controller.setRoundedCorners(args.bool("value"))
                return nil
            },
            "isEffectSupported": { args in
                guard let effect = WindowEffect(rawValue: try args.string("effect")) else {
                    throw ArgumentError(key: "effect")
                }
                return try controller.isEffectSupported(effect)
            },
            "setEffect": { args in
                guard let effect = WindowEffect(rawValue: try args.string("effect")) else {
                    throw ArgumentError(key: "effect")
                }
                guard WindowEffectView.isSupported(effect) else {
                    throw PluginError(code: "unsupported", message: "effect \(effect.rawValue) is not supported")
                }
                let tint = try args.optionalInt("tint")
                let appearance = try WindowEffectView.appearance(brightness: try args.optionalString("brightness"))
                try controller.setEffect(effect, tint: tint.map { NSColor(argb: $0) }, appearance: appearance)
                return nil
            },
            "startDragging": { _ in try controller.startDragging(); return nil }
        ]

        handlers["showTextMenu"] = { [weak self] args in
            guard let self else { return nil }
            return try self.showTextMenu(
                x: args.double("x"),
                y: args.double("y"),
                entries: args.mapList("items"),
                speech: try args.optionalString("speech")
            )
        }

        handlers["ensureInitialized"] = { [weak self] _ in
            guard let self, let window = self.registrar?.view?.window else {
                throw PluginError(code: "not_initialized", message: "no window for the Flutter view")
            }
            controller.ensureInitialized(with: window)
            return nil
        }

        return handlers
    }
}
