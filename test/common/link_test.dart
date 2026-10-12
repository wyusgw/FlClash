import 'dart:async';

import 'package:fl_clash/common/clipboard_import.dart';
import 'package:fl_clash/common/link.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late StreamController<Uri> links;
  late List<String> received;

  setUp(() {
    links = StreamController<Uri>.broadcast();
    received = [];
    linkManager.uriLinkStream = () => links.stream;
  });

  tearDown(() async {
    linkManager.destroy();
    await links.close();
  });

  Future<void> listen() async {
    await linkManager.initAppLinksListen(received.add);
  }

  Future<void> emit(String uri) async {
    links.add(Uri.parse(uri));
    await Future<void>.delayed(Duration.zero);
  }

  test('LinkManager is a singleton', () {
    expect(LinkManager(), same(linkManager));
  });

  test('an install-config link reports its url', () async {
    await listen();

    await emit('flclash://install-config?url=https://example.com/a.yaml');

    expect(received, ['https://example.com/a.yaml']);
  });

  test('an install-config link without a url is ignored', () async {
    await listen();

    await emit('flclash://install-config');

    expect(received, isEmpty);
  });

  test('a link for another host is ignored', () async {
    await listen();

    await emit('flclash://open-profile?url=https://example.com/a.yaml');

    expect(received, isEmpty);
  });

  group('links with no payload', () {
    late List<AppLinkAction> actions;

    setUp(() {
      actions = [];
    });

    Future<void> listenForActions() {
      return linkManager.initAppLinksListen(
        received.add,
        actionCallBack: actions.add,
      );
    }

    test('each action is answered at its own path', () async {
      await listenForActions();

      for (final entry in appLinkPaths.entries) {
        await emit('flclash://${entry.value}');
      }

      expect(actions, appLinkPaths.keys.toList());
      expect(received, isEmpty);
    });

    test('every registered scheme answers them', () async {
      await listenForActions();

      for (final scheme in ['clash', 'clashmeta', 'flclash']) {
        await emit('$scheme://toggle');
      }

      expect(actions, everyElement(AppLinkAction.toggle));
      expect(actions, hasLength(3));
    });

    test('an unknown route is ignored', () async {
      await listenForActions();

      await emit('flclash://route/scene');
      await emit('flclash://route');

      expect(actions, isEmpty);
    });
  });

  group('the server link', () {
    late List<String> servers;

    setUp(() {
      servers = [];
    });

    Future<void> listenForServers() {
      return linkManager.initAppLinksListen(
        received.add,
        serverCallBack: servers.add,
      );
    }

    test('names the server to switch to, decoded', () async {
      await listenForServers();

      await emit('flclash://server/%E6%97%A5%E6%9C%AC%2001');
      await emit('flclash://server/Tokyo');

      expect(servers, ['日本 01', 'Tokyo']);
      expect(received, isEmpty);
    });

    test('ignores a link with no name or more than one segment', () async {
      await listenForServers();

      await emit('flclash://server');
      await emit('flclash://server/');
      await emit('flclash://server/a/b');

      expect(servers, isEmpty);
    });
  });

  group('the add link', () {
    test('takes a raw url, query included', () async {
      await listen();

      await emit('flclash://add/https://example.com/sub?token=1&flag=a');

      expect(received, ['https://example.com/sub?token=1&flag=a']);
    });

    test('takes a percent-encoded url', () async {
      await listen();

      await emit('flclash://add/https%3A%2F%2Fexample.com%2Fsub%3Ftoken%3D1');

      expect(received, ['https://example.com/sub?token=1']);
    });

    test('takes a share link as a node', () async {
      final nodes = <ClipboardNodes>[];
      await linkManager.initAppLinksListen(
        received.add,
        nodesCallBack: nodes.add,
      );

      await emit('flclash://add/trojan://secret@example.org:443#Osaka');

      expect(received, isEmpty);
      expect(nodes.single.outbounds, hasLength(1));
    });

    test('ignores a payload that is not a url', () async {
      await listen();

      await emit('flclash://add/not-a-url');
      await emit('flclash://add');

      expect(received, isEmpty);
    });
  });

  test('listening again replaces the previous subscription', () async {
    await listen();
    final first = linkManager.subscription;

    await listen();

    expect(linkManager.subscription, isNot(same(first)));

    await emit('flclash://install-config?url=https://example.com/a.yaml');

    expect(received, ['https://example.com/a.yaml']);
  });

  test(
    'a seeded launch argument is delivered once a listener attaches',
    () async {
      linkManager.seedInitialLink([
        '--verbose',
        'flclash://install-config?url=https://example.com/a.yaml',
      ]);

      expect(received, isEmpty);

      await listen();

      expect(received, ['https://example.com/a.yaml']);

      await listen();

      expect(received, ['https://example.com/a.yaml']);
    },
  );

  test('launch arguments without a known scheme are ignored', () async {
    linkManager.seedInitialLink(['https://example.com/a.yaml', 'not a uri']);

    await listen();

    expect(received, isEmpty);
  });

  test('destroy stops delivery and is safe to repeat', () async {
    await listen();

    linkManager.destroy();
    linkManager.destroy();
    await emit('flclash://install-config?url=https://example.com/a.yaml');

    expect(linkManager.subscription, isNull);
    expect(received, isEmpty);
  });

  group('profileUrlFromQrCodes', () {
    test('accepts a bare url with surrounding whitespace', () {
      expect(
        profileUrlFromQrCodes([' https://example.com/sub?token=1\n']),
        'https://example.com/sub?token=1',
      );
    });

    test('unwraps the url of an install-config link for every scheme', () {
      for (final scheme in ['clash', 'clashmeta', 'flclash']) {
        expect(
          profileUrlFromQrCodes([
            '$scheme://install-config?url=https%3A%2F%2Fexample.com%2Fa.yaml',
          ]),
          'https://example.com/a.yaml',
        );
      }
    });

    test('rejects codes that carry no profile url', () {
      expect(
        profileUrlFromQrCodes([
          null,
          '',
          'plain text',
          'vmess://eyJhZGQiOiIxLjIuMy40In0=',
          'https://',
          'clash://install-config?url=not-a-url',
          'clash://open-profile?url=https://example.com/a.yaml',
          'other://install-config?url=https://example.com/a.yaml',
        ]),
        isNull,
      );
    });

    test('returns the first code that carries a profile url', () {
      expect(
        profileUrlFromQrCodes([
          'plain text',
          'flclash://install-config?url=https://example.com/first.yaml',
          'https://example.com/second.yaml',
        ]),
        'https://example.com/first.yaml',
      );
    });
  });

  group('color links', () {
    final colors = <Uri>[];

    setUp(colors.clear);

    Future<void> listenForColors() async {
      await linkManager.initAppLinksListen(
        received.add,
        colorCallBack: colors.add,
      );
    }

    test('a color link goes to the color callback only', () async {
      await listenForColors();

      await emit('flclash://color?v=1.0&dark.CanvasColor=000000');

      expect(colors.single.queryParameters['dark.CanvasColor'], '000000');
      expect(received, isEmpty);
    });

    test('a color link is dropped when nobody asked for colors', () async {
      await listen();

      await emit('flclash://color?v=1.0&dark.CanvasColor=000000');

      expect(received, isEmpty);
    });

    test('an install-config link still reaches the profile callback', () async {
      await listenForColors();

      await emit(
        'flclash://install-config?url=https%3A%2F%2Fexample.com%2Fsub',
      );

      expect(received.single, 'https://example.com/sub');
      expect(colors, isEmpty);
    });
  });
}
