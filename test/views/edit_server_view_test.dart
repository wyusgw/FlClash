import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/action.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/profiles/edit_server.dart';
import 'package:fl_clash/views/profiles/region.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/test_app.dart';

class _RecordingProfilesAction extends ProfilesAction {
  final replaced = <({String tag, Map<String, dynamic> outbound})>[];

  @override
  Future<void> replaceNode(
    Profile profile,
    String tag,
    Map<String, dynamic> outbound,
  ) async {
    replaced.add((tag: tag, outbound: outbound));
  }

  @override
  Future<List<String>> readNodeTags(Profile profile) async => [
    'Japan',
    'relay',
  ];
}

AppLocalizations get l10n => currentAppLocalizations;

void main() {
  late ProviderContainer container;

  late Map<String, dynamic> outbound;

  Future<void> openPage(
    WidgetTester tester, {
    Map<String, dynamic>? unformable,
  }) async {
    const size = Size(1000, 1200);
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    container = ProviderContainer(
      overrides: [
        profilesActionProvider.overrideWith(_RecordingProfilesAction.new),
      ],
    );
    addTearDown(container.dispose);
    globalState.container = container;
    container.read(viewSizeProvider.notifier).update((_) => size);

    outbound = buildNodeOutbound(NodeKind.shadowsocks, {
      ...nodeDefaults(NodeKind.shadowsocks),
      'address': '192.168.3.2',
      'port': '23333',
      'password': 'secret',
      'remark': 'Japan',
    })!;
    final form = nodeFormOf(outbound)!;
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(
          child: unformable != null
              ? EditNodeEndpointView(
                  profile: Profile.normal(label: 'mine'),
                  outbound: unformable,
                )
              : EditServerView(
                  profile: Profile.normal(label: 'mine'),
                  outbound: outbound,
                  kind: form.kind,
                  values: form.values,
                ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  _RecordingProfilesAction action() =>
      container.read(profilesActionProvider.notifier)
          as _RecordingProfilesAction;

  Finder fieldOf(String key) => find.descendant(
    of: find.byKey(ValueKey('field.$key')),
    matching: find.byType(TextField),
  );

  Finder save() => find.widgetWithText(InkResponse, l10n.save);

  testWidgets('shows the type, the stored values and the copy actions', (
    tester,
  ) async {
    await openPage(tester);

    expect(find.text(l10n.editServer), findsOneWidget);
    expect(find.text('Shadowsocks'), findsOneWidget);
    expect(
      tester.widget<TextField>(fieldOf('address')).controller!.text,
      '192.168.3.2',
    );
    expect(tester.widget<TextField>(fieldOf('port')).controller!.text, '23333');
    expect(
      tester.widget<TextField>(fieldOf('remark')).controller!.text,
      'Japan',
    );
    expect(find.text(l10n.copyJson), findsOneWidget);
    expect(find.text(l10n.copyLink), findsOneWidget);
  });

  testWidgets('saving waits for a change, then hands the node back', (
    tester,
  ) async {
    await openPage(tester);
    expect(tester.widget<InkResponse>(save()).onTap, isNull);

    await tester.enterText(fieldOf('port'), '24444');
    await tester.pump();
    expect(tester.widget<InkResponse>(save()).onTap, isNotNull);

    await tester.tap(find.text(l10n.save));
    await tester.pumpAndSettle();

    final replaced = action().replaced.single;
    expect(replaced.tag, 'Japan');
    expect((replaced.outbound['settings'] as Map)['port'], 24444);
    expect(replaced.outbound['tag'], 'Japan');
    expect(find.byType(EditServerView), findsNothing);
  });

  testWidgets('the flag beside the address changes only the country', (
    tester,
  ) async {
    await openPage(tester);
    expect(tester.widget<InkResponse>(save()).onTap, isNull);

    await tester.tap(find.byKey(const ValueKey('field.region')));
    await tester.pumpAndSettle();
    expect(find.byType(RegionView), findsOneWidget);
    await tester.enterText(find.byType(TextField).last, 'germany');
    await tester.pump();
    await tester.tap(find.text('DE'));
    await tester.pumpAndSettle();
    expect(tester.widget<InkResponse>(save()).onTap, isNotNull);

    await tester.tap(find.text(l10n.save));
    await tester.pumpAndSettle();

    final saved = action().replaced.single.outbound;
    expect(saved['region'], 'DE');
    expect((saved['settings'] as Map)['port'], 23333);
  });

  testWidgets('a form that is no longer complete cannot be saved', (
    tester,
  ) async {
    await openPage(tester);

    await tester.enterText(fieldOf('address'), '');
    await tester.pump();

    expect(tester.widget<InkResponse>(save()).onTap, isNull);
  });

  testWidgets('changing the protocol keeps the address and port', (
    tester,
  ) async {
    await openPage(tester);

    await tester.tap(find.text(l10n.profileType));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Trojan'));
    await tester.pumpAndSettle();

    expect(find.text('Trojan'), findsOneWidget);
    expect(
      tester.widget<TextField>(fieldOf('address')).controller!.text,
      '192.168.3.2',
    );
    expect(tester.widget<TextField>(fieldOf('port')).controller!.text, '23333');
    expect(find.text(l10n.algorithm), findsNothing);

    await tester.tap(find.text(l10n.save));
    await tester.pumpAndSettle();

    final saved = action().replaced.single.outbound;
    expect(saved['protocol'], 'trojan');
    expect((saved['settings'] as Map)['address'], '192.168.3.2');
  });

  testWidgets('copy JSON puts the stored node on the clipboard', (
    tester,
  ) async {
    await openPage(tester);
    String? copied;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copied = (call.arguments as Map)['text'] as String?;
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );

    await tester.tap(find.text(l10n.copyJson));
    await tester.pump();

    expect(copied, contains('"192.168.3.2"'));
    expect(copied, contains('"shadowsocks"'));
  });

  testWidgets('another node can carry it, but not the node itself', (
    tester,
  ) async {
    await openPage(tester);

    await tester.tap(find.text(l10n.proxyVia));
    await tester.pumpAndSettle();
    expect(find.text('relay'), findsOneWidget);
    expect(find.text('Japan'), findsNothing);
    await tester.tap(find.text('relay'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.save));
    await tester.pumpAndSettle();

    final saved = action().replaced.single.outbound;
    expect((saved['streamSettings'] as Map)['sockopt'], {
      'dialerProxy': 'relay',
    });
    expect(nodeFormOf(saved)?.values['dialerProxy'], 'relay');
  });

  testWidgets('the back arrow leaves without saving', (tester) async {
    await openPage(tester);

    await tester.enterText(fieldOf('port'), '1');
    await tester.tap(find.byTooltip(l10n.back));
    await tester.pumpAndSettle();

    expect(action().replaced, isEmpty);
  });

  group('a node the form cannot hold', () {
    final xhttp = {
      'tag': 'Tokyo',
      'protocol': 'vless',
      'settings': {'address': 'a.example.com', 'port': 443, 'id': 'id'},
      'streamSettings': {
        'network': 'xhttp',
        'xhttpSettings': {'path': '/x'},
      },
    };

    testWidgets('changes its name and server and keeps the rest', (
      tester,
    ) async {
      await openPage(tester, unformable: xhttp);
      expect(find.text('VLESS'), findsOneWidget);
      expect(find.text('XHTTP'), findsOneWidget);
      expect(
        tester.widget<TextField>(fieldOf('address')).controller!.text,
        'a.example.com',
      );
      expect(tester.widget<InkResponse>(save()).onTap, isNull);

      await tester.enterText(fieldOf('remark'), 'Osaka');
      await tester.enterText(fieldOf('address'), 'b.example.com');
      await tester.enterText(fieldOf('port'), '8443');
      await tester.pump();
      await tester.tap(find.text(l10n.save));
      await tester.pumpAndSettle();

      final replaced = action().replaced.single;
      expect(replaced.tag, 'Tokyo');
      expect(replaced.outbound['tag'], 'Osaka');
      expect(replaced.outbound['settings'], {
        'address': 'b.example.com',
        'port': 8443,
        'id': 'id',
      });
      expect(replaced.outbound['streamSettings'], xhttp['streamSettings']);
    });

    testWidgets('an empty name cannot be saved', (tester) async {
      await openPage(tester, unformable: xhttp);

      await tester.enterText(fieldOf('remark'), ' ');
      await tester.pump();

      expect(tester.widget<InkResponse>(save()).onTap, isNull);
    });
  });
}
