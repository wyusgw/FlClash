import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/action.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/profiles/add.dart';
import 'package:fl_clash/views/profiles/region.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/glyph_finders.dart';
import '../helpers/test_app.dart';

class _RecordingProfilesAction extends ProfilesAction {
  final added = <({String url, String? label})>[];
  final nodes = <Map<String, dynamic>>[];
  var files = 0;
  var tags = <String>[];

  @override
  Profile manualNodeProfile() => Profile.normal(label: 'mine');

  @override
  Future<List<String>> readNodeTags(Profile profile) async => tags;

  @override
  Future<void> addManualNode(Map<String, dynamic> outbound) async {
    nodes.add(outbound);
  }

  @override
  Future<void> addProfileFormURL(String url, {String? label}) async {
    added.add((url: url, label: label));
  }

  @override
  Future<void> addProfileFormFile() async {
    files++;
  }
}

void main() {
  late ProviderContainer container;

  Future<void> openPage(
    WidgetTester tester, {
    bool geoRegion = false,
    List<String> tags = const [],
  }) async {
    const size = Size(1000, 900);
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    container = ProviderContainer(
      overrides: [
        profilesActionProvider.overrideWith(_RecordingProfilesAction.new),
        nodeGeoRegionProvider('8.8.8.8').overrideWith((_) async => 'US'),
      ],
    );
    container.listen(appSettingProvider, (_, _) {});
    // The hosts typed here are not worth a real lookup.
    container
        .read(appSettingProvider.notifier)
        .update((state) => state.copyWith(geoRegion: geoRegion));
    addTearDown(container.dispose);
    globalState.container = container;
    container.read(viewSizeProvider.notifier).update((_) => size);
    (container.read(profilesActionProvider.notifier)
                as _RecordingProfilesAction)
            .tags =
        tags;
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(
          child: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => showAddProfilePage(context),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  _RecordingProfilesAction action() =>
      container.read(profilesActionProvider.notifier)
          as _RecordingProfilesAction;

  Finder field(String label) => find.descendant(
    of: find.ancestor(of: find.text(label), matching: find.byType(Row)).first,
    matching: find.byType(TextField),
  );

  testWidgets('shows the type, the two fields and the other ways in', (
    tester,
  ) async {
    await openPage(tester);
    final l10n = currentAppLocalizations;

    expect(find.byType(AddProfileView), findsOneWidget);
    expect(find.text(l10n.profileType), findsOneWidget);
    expect(find.text(l10n.subscribe), findsOneWidget);
    expect(find.text(l10n.url), findsOneWidget);
    expect(find.text(l10n.name), findsOneWidget);
    expect(find.text(l10n.qrcode), findsOneWidget);
    expect(find.text(l10n.file), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('saving waits for an address that is a URL', (tester) async {
    await openPage(tester);
    final l10n = currentAppLocalizations;

    await tester.tap(find.text(l10n.save));
    await tester.pump();
    expect(find.byType(AddProfileView), findsOneWidget);
    expect(action().added, isEmpty);

    await tester.enterText(field(l10n.url), 'not a url');
    await tester.pump();
    await tester.tap(find.text(l10n.save));
    await tester.pump();
    expect(action().added, isEmpty);

    await tester.enterText(field(l10n.url), 'https://example.com/sub');
    await tester.pump();
    await tester.tap(find.text(l10n.save));
    await tester.pumpAndSettle();

    expect(action().added, [(url: 'https://example.com/sub', label: null)]);
    expect(find.byType(AddProfileView), findsNothing);
  });

  testWidgets('the name is passed along when one is given', (tester) async {
    await openPage(tester);
    final l10n = currentAppLocalizations;

    await tester.enterText(field(l10n.url), 'https://example.com/sub');
    await tester.enterText(field(l10n.name), '  My servers ');
    await tester.pump();
    await tester.tap(find.text(l10n.save));
    await tester.pumpAndSettle();

    expect(action().added, [
      (url: 'https://example.com/sub', label: 'My servers'),
    ]);
  });

  testWidgets('the file row hands over to the file picker and closes', (
    tester,
  ) async {
    await openPage(tester);

    await tester.tap(find.text(currentAppLocalizations.file));
    await tester.pumpAndSettle();

    expect(action().files, 1);
    expect(find.byType(AddProfileView), findsNothing);
  });

  testWidgets('the type row opens a page with the subscription checked', (
    tester,
  ) async {
    await openPage(tester);

    await tester.tap(find.text(currentAppLocalizations.profileType));
    await tester.pumpAndSettle();

    expect(find.byType(ProfileTypeView), findsOneWidget);
    expect(find.byGlyph(AppGlyphs.check), findsOneWidget);
    expect(find.text(currentAppLocalizations.subscribeDesc), findsOneWidget);

    await tester.tap(find.byTooltip(currentAppLocalizations.back));
    await tester.pumpAndSettle();

    expect(find.byType(ProfileTypeView), findsNothing);
    expect(find.byType(AddProfileView), findsOneWidget);
  });

  group('typing a server in', () {
    Future<void> pickKind(WidgetTester tester, String label) async {
      await tester.tap(find.text(currentAppLocalizations.profileType));
      await tester.pumpAndSettle();
      await tester.tap(find.text(label));
      await tester.pumpAndSettle();
    }

    Finder fieldOf(String key) => find.descendant(
      of: find.byKey(ValueKey('field.$key')),
      matching: find.byType(TextField),
    );

    testWidgets('the type page lists the subscription and every protocol', (
      tester,
    ) async {
      await openPage(tester);

      await tester.tap(find.text(currentAppLocalizations.profileType));
      await tester.pumpAndSettle();

      expect(find.text(currentAppLocalizations.subscribe), findsOneWidget);
      expect(find.text(currentAppLocalizations.chooseType), findsOneWidget);
      for (final kind in NodeKind.values) {
        expect(find.text(nodeKindLabel(kind)), findsOneWidget);
      }
      expect(find.byGlyph(AppGlyphs.check), findsOneWidget);
    });

    testWidgets('picking a protocol shows its fields and the page leaves', (
      tester,
    ) async {
      await openPage(tester);

      await pickKind(tester, 'Shadowsocks');

      expect(find.byType(ProfileTypeView), findsNothing);
      expect(find.text(currentAppLocalizations.url), findsNothing);
      expect(find.text(currentAppLocalizations.address), findsOneWidget);
      expect(find.text(currentAppLocalizations.port), findsOneWidget);
      expect(find.text(currentAppLocalizations.password), findsOneWidget);
      expect(find.text(currentAppLocalizations.algorithm), findsOneWidget);
      expect(find.text('aes-256-gcm'), findsOneWidget);
      expect(find.text('Shadowsocks'), findsOneWidget);
    });

    testWidgets('each protocol asks for its own fields', (tester) async {
      await openPage(tester);
      final l10n = currentAppLocalizations;
      Finder group(String name) => find.byKey(ValueKey('group.$name'));

      await pickKind(tester, 'VMess');
      expect(find.text(l10n.uuid), findsOneWidget);
      expect(group('transport'), findsOneWidget);
      expect(group('tls'), findsOneWidget);
      expect(find.text(l10n.network), findsNothing);
      expect(find.text(l10n.serverName), findsNothing);
      expect(find.text(l10n.multiplexing), findsOneWidget);
      expect(find.text(l10n.tcpFastOpen), findsOneWidget);

      await pickKind(tester, 'VLESS');
      expect(find.text(l10n.encryption), findsOneWidget);
      expect(find.text(l10n.flow), findsOneWidget);

      await pickKind(tester, 'TUIC');
      expect(find.text(l10n.congestionControl), findsOneWidget);
      expect(find.text(l10n.udpRelay), findsOneWidget);
      expect(group('transport'), findsNothing);
      expect(group('tls'), findsOneWidget);

      await pickKind(tester, 'Hysteria');
      expect(find.text(l10n.uploadSpeed), findsOneWidget);
      expect(find.text(l10n.downloadSpeed), findsOneWidget);

      await pickKind(tester, 'Hysteria2');
      expect(find.text(l10n.obfsPassword), findsOneWidget);
      expect(find.text(l10n.portHopping), findsOneWidget);
      expect(find.text(l10n.uploadSpeed), findsNothing);

      await pickKind(tester, 'Mieru');
      expect(find.text(l10n.username), findsOneWidget);
      expect(find.text(l10n.transportMode), findsOneWidget);
      expect(find.text(l10n.multiplexing), findsOneWidget);
      expect(find.text(l10n.handshake), findsOneWidget);
      expect(find.text('MTU'), findsOneWidget);
      expect(group('tls'), findsNothing);

      await pickKind(tester, 'Socks5');
      expect(find.text(l10n.username), findsOneWidget);
      expect(group('tls'), findsOneWidget);
      expect(find.text(l10n.serverName), findsNothing);
      expect(find.text(l10n.proxyVia), findsNothing);
    });

    testWidgets('socks5 saves with only an address and a port', (tester) async {
      await openPage(tester);
      await pickKind(tester, 'Socks5');

      await tester.enterText(fieldOf('address'), '10.0.0.2');
      await tester.enterText(fieldOf('port'), '1080');
      await tester.pump();
      await tester.tap(find.text(currentAppLocalizations.save));
      await tester.pumpAndSettle();

      final outbound = action().nodes.single;
      expect(outbound['protocol'], 'socks');
      expect((outbound['settings'] as Map)['port'], 1080);
    });

    testWidgets('the transport and TLS pages show what their choice needs', (
      tester,
    ) async {
      await openPage(tester);
      final l10n = currentAppLocalizations;
      await pickKind(tester, 'VLESS');

      await tester.tap(find.byKey(const ValueKey('group.tls')));
      await tester.pumpAndSettle();
      expect(find.text(l10n.publicKey), findsNothing);
      expect(find.text(l10n.allowInsecure), findsOneWidget);
      expect(find.text('ECH'), findsOneWidget);

      await tester.tap(find.text(l10n.security));
      await tester.pumpAndSettle();
      await tester.tap(find.text('REALITY'));
      await tester.pumpAndSettle();
      expect(find.text(l10n.publicKey), findsOneWidget);
      expect(find.text(l10n.shortId), findsOneWidget);
      expect(find.text('ECH'), findsNothing);

      await tester.tap(find.byTooltip(l10n.back));
      await tester.pumpAndSettle();
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('group.tls')),
          matching: find.text('REALITY'),
        ),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const ValueKey('group.transport')));
      await tester.pumpAndSettle();
      expect(find.text(l10n.path), findsNothing);
      await tester.tap(find.text(l10n.network));
      await tester.pumpAndSettle();
      await tester.tap(find.text('ws'));
      await tester.pumpAndSettle();
      expect(find.text(l10n.path), findsOneWidget);
    });

    testWidgets('what the TLS page sets is saved with the server', (
      tester,
    ) async {
      await openPage(tester);
      final l10n = currentAppLocalizations;
      await pickKind(tester, 'VLESS');
      await tester.enterText(fieldOf('address'), 'node.example.com');
      await tester.enterText(fieldOf('port'), '443');
      await tester.enterText(fieldOf('uuid'), 'id');

      await tester.tap(find.byKey(const ValueKey('group.tls')));
      await tester.pumpAndSettle();
      await tester.enterText(fieldOf('sni'), 'sni.example.com');
      await tester.tap(find.text(l10n.fingerprint));
      await tester.pumpAndSettle();
      await tester.tap(find.text('firefox'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip(l10n.back));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.save));
      await tester.pumpAndSettle();

      final stream = action().nodes.single['streamSettings'] as Map;
      expect(stream['tlsSettings'], {
        'serverName': 'sni.example.com',
        'fingerprint': 'firefox',
      });
    });

    testWidgets('a server can be reached through another node', (tester) async {
      await openPage(tester, tags: ['relay']);
      final l10n = currentAppLocalizations;
      await pickKind(tester, 'Shadowsocks');
      await tester.enterText(fieldOf('address'), 'node.example.com');
      await tester.enterText(fieldOf('port'), '8388');
      await tester.enterText(fieldOf('password'), 'pw');

      await tester.tap(find.text(l10n.proxyVia));
      await tester.pumpAndSettle();
      expect(find.text(l10n.off), findsOneWidget);
      await tester.tap(find.text('relay'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.save));
      await tester.pumpAndSettle();

      final stream = action().nodes.single['streamSettings'] as Map;
      expect(stream['sockopt'], {'dialerProxy': 'relay'});
    });

    testWidgets('saving waits for the required fields and a real port', (
      tester,
    ) async {
      await openPage(tester);
      final l10n = currentAppLocalizations;
      await pickKind(tester, 'Shadowsocks');

      await tester.tap(find.text(l10n.save));
      await tester.pump();
      expect(find.byType(AddProfileView), findsOneWidget);

      await tester.enterText(fieldOf('address'), 'node.example.com');
      await tester.enterText(fieldOf('port'), '70000');
      await tester.enterText(fieldOf('password'), 'secret');
      await tester.pump();
      await tester.tap(find.text(l10n.save));
      await tester.pump();
      expect(find.byType(AddProfileView), findsOneWidget);
      expect(action().nodes, isEmpty);

      await tester.enterText(fieldOf('port'), '8388');
      await tester.pump();
      await tester.tap(find.text(l10n.save));
      await tester.pumpAndSettle();

      expect(find.byType(AddProfileView), findsNothing);
      expect(action().nodes, hasLength(1));
    });

    testWidgets('the saved server is the outbound of the typed values', (
      tester,
    ) async {
      await openPage(tester);
      final l10n = currentAppLocalizations;
      await pickKind(tester, 'Trojan');

      await tester.enterText(fieldOf('address'), 'tj.example.com');
      await tester.enterText(fieldOf('port'), '443');
      await tester.enterText(fieldOf('password'), 'pw');
      await tester.enterText(fieldOf('remark'), 'My trojan');
      await tester.pump();
      await tester.tap(find.text(l10n.save));
      await tester.pumpAndSettle();

      final outbound = action().nodes.single;
      expect(outbound['protocol'], 'trojan');
      expect(outbound['tag'], 'My trojan');
      expect((outbound['settings'] as Map)['address'], 'tj.example.com');
      expect((outbound['settings'] as Map)['port'], 443);
    });

    testWidgets('a secret stays hidden until the eye is pressed', (
      tester,
    ) async {
      await openPage(tester);
      await pickKind(tester, 'Shadowsocks');

      TextField password() => tester.widget<TextField>(fieldOf('password'));
      expect(password().obscureText, isTrue);

      await tester.tap(find.byGlyph(AppGlyphs.eye));
      await tester.pump();

      expect(password().obscureText, isFalse);
    });

    testWidgets('going back to the subscription brings its fields back', (
      tester,
    ) async {
      await openPage(tester);
      await pickKind(tester, 'AnyTLS');
      expect(find.text(currentAppLocalizations.password), findsOneWidget);

      await pickKind(tester, currentAppLocalizations.subscribe);

      expect(find.text(currentAppLocalizations.url), findsOneWidget);
      expect(find.text(currentAppLocalizations.password), findsNothing);
    });

    testWidgets('the flag beside the address picks the country by hand', (
      tester,
    ) async {
      final l10n = currentAppLocalizations;
      await openPage(tester);
      await pickKind(tester, 'Trojan');
      await tester.enterText(fieldOf('address'), 'tj.example.com');
      await tester.enterText(fieldOf('port'), '443');
      await tester.enterText(fieldOf('password'), 'pw');

      await tester.tap(find.byKey(const ValueKey('field.region')));
      await tester.pumpAndSettle();
      expect(find.byType(RegionView), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'japan');
      await tester.pump();
      await tester.tap(find.text('JP'));
      await tester.pumpAndSettle();

      await tester.tap(find.text(l10n.save));
      await tester.pumpAndSettle();

      expect(action().nodes.single['region'], 'JP');
    });

    testWidgets('the country the name points at is checked in the picker', (
      tester,
    ) async {
      await openPage(tester);
      await pickKind(tester, 'Trojan');
      await tester.enterText(fieldOf('remark'), '日本 01');
      await tester.pump();

      await tester.tap(find.byKey(const ValueKey('field.region')));
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.widgetWithText(GroupedRow, 'JP'),
          matching: find.byGlyph(AppGlyphs.check),
        ),
        findsOneWidget,
      );
    });

    testWidgets('picking the same country again leaves it to the address', (
      tester,
    ) async {
      final l10n = currentAppLocalizations;
      await openPage(tester);
      await pickKind(tester, 'Trojan');
      await tester.enterText(fieldOf('address'), 'tj.example.com');
      await tester.enterText(fieldOf('port'), '443');
      await tester.enterText(fieldOf('password'), 'pw');

      for (var i = 0; i < 2; i++) {
        await tester.tap(find.byKey(const ValueKey('field.region')));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField), 'japan');
        await tester.pump();
        await tester.tap(find.text('JP'));
        await tester.pumpAndSettle();
      }

      await tester.tap(find.text(l10n.save));
      await tester.pumpAndSettle();

      expect(action().nodes.single.containsKey('region'), isFalse);
    });

    testWidgets(
      'the flag follows where the typed address is, once typing stops',
      (tester) async {
        await openPage(tester, geoRegion: true);
        await pickKind(tester, 'Trojan');

        await tester.enterText(fieldOf('address'), '8.8.8.8');
        await tester.pump();
        expect(
          tester.widget<RegionFlag>(find.byType(RegionFlag)).code,
          isNull,
          reason: 'not asked while the address is still being typed',
        );

        await tester.pump(const Duration(milliseconds: 900));
        await tester.pump();
        expect(tester.widget<RegionFlag>(find.byType(RegionFlag)).code, 'US');
      },
    );
  });
}
