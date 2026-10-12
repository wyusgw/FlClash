import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';

import 'clipboard_import.dart';
import 'print.dart';
import 'protocol.dart';
import 'string.dart';

typedef InstallConfigCallBack = void Function(String url);

/// A link that carries a set of colors rather than a profile.
typedef ColorLinkCallBack = void Function(Uri uri);

/// What a link with no payload asks the app to do.
enum AppLinkAction {
  start,
  stop,
  toggle,
  connectivityTest,
  updateProfiles,
  routeRule,
  routeGlobal,
  routeDirect,
}

typedef ActionLinkCallBack = void Function(AppLinkAction action);

/// A link that names the server to switch to.
typedef ServerLinkCallBack = void Function(String name);

/// A link that adds servers by their share links.
typedef NodesLinkCallBack = void Function(ClipboardNodes nodes);

/// Where each action sits after the scheme, as `scheme://<path>`.
const appLinkPaths = {
  AppLinkAction.start: 'start',
  AppLinkAction.stop: 'stop',
  AppLinkAction.toggle: 'toggle',
  AppLinkAction.connectivityTest: 'connectivity-test',
  AppLinkAction.updateProfiles: 'update-subs',
  AppLinkAction.routeRule: 'route/rule',
  AppLinkAction.routeGlobal: 'route/global',
  AppLinkAction.routeDirect: 'route/direct',
};

/// `scheme://server/<name>` switches to the server called `<name>`.
const serverLinkPath = 'server';

String? _serverLinkName(Uri uri) {
  if (uri.host != serverLinkPath || uri.pathSegments.length != 1) {
    return null;
  }
  final name = uri.pathSegments.single.trim();
  return name.isEmpty ? null : name;
}

/// `scheme://add/<link>` adds the subscription or the share link `<link>`.
const addLinkPath = 'add';

AppLinkAction? appLinkActionOf(Uri uri) {
  final path = [uri.host, ...uri.pathSegments].where((e) => e.isNotEmpty);
  final key = path.join('/');
  for (final entry in appLinkPaths.entries) {
    if (entry.value == key) {
      return entry.key;
    }
  }
  return null;
}

String? profileUrlFromQrCodes(Iterable<String?> values) {
  for (final value in values) {
    final text = value?.trim();
    if (text == null || text.isEmpty) {
      continue;
    }
    if (text.isUrl) {
      return text;
    }
    final uri = Uri.tryParse(text);
    if (uri == null || !protocolSchemes.contains(uri.scheme)) {
      continue;
    }
    final url = _installConfigUrl(uri)?.trim();
    if (url != null && url.isUrl) {
      return url;
    }
  }
  return null;
}

String? _installConfigUrl(Uri uri) {
  return uri.host == 'install-config' ? uri.queryParameters['url'] : null;
}

/// What follows `scheme://add/`, written raw or percent-encoded.
ClipboardImport? _addLinkImport(Uri uri) {
  if (uri.host != addLinkPath) {
    return null;
  }
  final raw = uri.toString();
  const marker = '://$addLinkPath/';
  final tail = raw.substring(raw.indexOf(marker) + marker.length);
  final direct = parseClipboardImport(tail);
  if (direct != null) {
    return direct;
  }
  try {
    return parseClipboardImport(Uri.decodeFull(tail));
  } on ArgumentError {
    return null;
  }
}

class LinkManager {
  static LinkManager? _instance;
  StreamSubscription? subscription;
  Uri? _pendingUri;

  LinkManager._internal();

  @visibleForTesting
  Stream<Uri> Function() uriLinkStream = () => AppLinks().uriLinkStream;

  /// Linux argv: the gtk plugin hooks GApplication too late to see it.
  void seedInitialLink(List<String> args) {
    for (final arg in args) {
      final uri = Uri.tryParse(arg);
      if (uri != null && protocolSchemes.contains(uri.scheme)) {
        _pendingUri = uri;
        return;
      }
    }
  }

  Future<void> initAppLinksListen(
    Function(String url) installConfigCallBack, {
    ColorLinkCallBack? colorCallBack,
    ActionLinkCallBack? actionCallBack,
    NodesLinkCallBack? nodesCallBack,
    ServerLinkCallBack? serverCallBack,
  }) async {
    commonPrint.log('initAppLinksListen');
    destroy();
    subscription = uriLinkStream().listen((uri) {
      _handle(
        uri,
        installConfigCallBack,
        colorCallBack,
        actionCallBack,
        nodesCallBack,
        serverCallBack,
      );
    });
    final pending = _pendingUri;
    _pendingUri = null;
    if (pending != null) {
      _handle(
        pending,
        installConfigCallBack,
        colorCallBack,
        actionCallBack,
        nodesCallBack,
        serverCallBack,
      );
    }
  }

  void _handle(
    Uri uri,
    Function(String url) installConfigCallBack,
    ColorLinkCallBack? colorCallBack,
    ActionLinkCallBack? actionCallBack,
    NodesLinkCallBack? nodesCallBack,
    ServerLinkCallBack? serverCallBack,
  ) {
    commonPrint.log('onAppLink: $uri');
    if (uri.host == 'color') {
      colorCallBack?.call(uri);
      return;
    }
    final action = appLinkActionOf(uri);
    if (action != null) {
      actionCallBack?.call(action);
      return;
    }
    final server = _serverLinkName(uri);
    if (server != null) {
      serverCallBack?.call(server);
      return;
    }
    final added = _addLinkImport(uri);
    switch (added) {
      case ClipboardSubscription(:final url):
        installConfigCallBack(url);
        return;
      case ClipboardNodes():
        nodesCallBack?.call(added);
        return;
      case null:
        break;
    }
    final url = _installConfigUrl(uri);
    if (url != null) {
      installConfigCallBack(url);
    }
  }

  void destroy() {
    if (subscription != null) {
      subscription?.cancel();
      subscription = null;
    }
  }

  factory LinkManager() {
    _instance ??= LinkManager._internal();
    return _instance!;
  }
}

final linkManager = LinkManager();
