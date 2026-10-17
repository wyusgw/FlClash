import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/config/dns.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/test_app.dart';

void main() {
  late ProviderContainer container;

  setUpAll(() async {
    await AppLocalizations.load(const Locale('en'));
  });

  Future<void> openPage(WidgetTester tester, {CoreConfig? config}) async {
    tester.view.physicalSize = const Size(900, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    container = ProviderContainer();
    addTearDown(container.dispose);
    container.listen(coreSettingProvider, (_, _) {});
    if (config != null) {
      container.read(coreSettingProvider.notifier).update((_) => config);
    }
    globalState.container = container;
    container.read(viewSizeProvider.notifier).value = const Size(900, 1400);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(child: DnsView()),
      ),
    );
    await tester.pumpAndSettle();
  }

  CoreConfig settings() => container.read(coreSettingProvider);

  Finder listOf(String name) => find.byKey(ValueKey('dns.$name'));

  group('validateDnsServer', () {
    test('takes the forms Xray builds a name server from', () {
      for (final server in [
        '1.1.1.1',
        '223.5.5.5:53',
        '2606:4700:4700::1111',
        '[2606:4700:4700::1111]:53',
        'localhost',
        'https://dns.google/dns-query',
        'https+local://doh.pub/dns-query',
        'h2c://dns.example.com/dns-query',
        'tcp://8.8.8.8:53',
        'tcp+local://119.29.29.29',
        'quic+local://dns.alidns.com',
      ]) {
        expect(
          validateDnsServer(server, AppLocalizations.current),
          isNull,
          reason: server,
        );
      }
    });

    test('refuses what Xray would not', () {
      expect(validateDnsServer('', AppLocalizations.current), isNotNull);
      for (final server in [
        'dns.google',
        'udp://1.1.1.1',
        'http://dns.google/dns-query',
        '1.1.1.1:99999',
        'https://',
      ]) {
        expect(
          validateDnsServer(server, AppLocalizations.current),
          isNotNull,
          reason: server,
        );
      }
    });
  });

  Finder save() => find.widgetWithText(InkResponse, 'Save');
  bool canSave(WidgetTester tester) =>
      tester.widget<InkResponse>(save()).onTap != null;

  testWidgets('default servers open as Automatic, with no lists', (
    tester,
  ) async {
    await openPage(tester);

    expect(find.text('Configure DNS'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('dns.mode.false')),
        matching: find.byType(GlyphIcon),
      ),
      findsOneWidget,
    );
    expect(listOf('proxy'), findsNothing);
    expect(canSave(tester), isFalse);
  });

  testWidgets('Manual shows both lists, and Save waits for a change', (
    tester,
  ) async {
    await openPage(tester);

    await tester.tap(find.text('Manual'));
    await tester.pumpAndSettle();

    for (final server in defaultProxyDnsServers) {
      expect(
        find.descendant(of: listOf('proxy'), matching: find.text(server)),
        findsOneWidget,
      );
    }
    for (final server in defaultDirectDnsServers) {
      expect(
        find.descendant(of: listOf('direct'), matching: find.text(server)),
        findsOneWidget,
      );
    }
    expect(canSave(tester), isFalse);
  });

  testWidgets('an added server is kept only once Save is tapped', (
    tester,
  ) async {
    await openPage(tester);
    await tester.tap(find.text('Manual'));
    await tester.pumpAndSettle();

    await tester.tap(
      find.descendant(of: listOf('proxy'), matching: find.text('Add Server')),
    );
    await tester.pumpAndSettle();
    await tester.enterText(
      find.descendant(of: listOf('proxy'), matching: find.byType(EditableText)),
      'https://dns.google/dns-query',
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(settings().proxyDns, defaultProxyDnsServers);
    expect(canSave(tester), isTrue);

    await tester.tap(save());
    await tester.pumpAndSettle();

    expect(settings().proxyDns, [
      ...defaultProxyDnsServers,
      'https://dns.google/dns-query',
    ]);
    expect(settings().directDns, defaultDirectDnsServers);
    expect(find.byType(DnsView), findsNothing);
  });

  testWidgets('an address Xray cannot use is not added', (tester) async {
    await openPage(tester);
    await tester.tap(find.text('Manual'));
    await tester.pumpAndSettle();

    await tester.tap(
      find.descendant(of: listOf('direct'), matching: find.text('Add Server')),
    );
    await tester.pumpAndSettle();
    await tester.enterText(
      find.descendant(
        of: listOf('direct'),
        matching: find.byType(EditableText),
      ),
      'dns.google',
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(find.text(AppLocalizations.current.dnsServerTip), findsOneWidget);
    expect(canSave(tester), isFalse);
  });

  testWidgets('the red minus brings up Delete, which removes the server', (
    tester,
  ) async {
    await openPage(
      tester,
      config: const CoreConfig(proxyDns: ['1.1.1.1', '9.9.9.9']),
    );

    await tester.tap(
      find.descendant(
        of: find.byKey(const ValueKey('dns.server.9.9.9.9')),
        matching: find.byTooltip('Delete'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byKey(const ValueKey('dns.server.9.9.9.9')),
        matching: find.widgetWithText(InkWell, 'Delete').last,
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(save());
    await tester.pumpAndSettle();

    expect(settings().proxyDns, ['1.1.1.1']);
  });

  testWidgets('a list left empty cannot be saved', (tester) async {
    await openPage(tester, config: const CoreConfig(proxyDns: ['1.1.1.1']));

    await tester.tap(
      find.descendant(
        of: find.byKey(const ValueKey('dns.server.1.1.1.1')),
        matching: find.byTooltip('Delete'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(InkWell, 'Delete').last);
    await tester.pumpAndSettle();

    expect(canSave(tester), isFalse);
  });

  testWidgets('going back to Automatic saves the defaults', (tester) async {
    await openPage(
      tester,
      config: const CoreConfig(
        proxyDns: ['9.9.9.9'],
        directDns: ['tcp+local://119.29.29.29'],
      ),
    );

    await tester.tap(find.text('Auto'));
    await tester.pumpAndSettle();
    await tester.tap(save());
    await tester.pumpAndSettle();

    expect(settings().proxyDns, defaultProxyDnsServers);
    expect(settings().directDns, defaultDirectDnsServers);
  });

  testWidgets('back leaves the settings as they were', (tester) async {
    await openPage(tester);
    await tester.tap(find.text('Manual'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byKey(const ValueKey('dns.server.1.1.1.1')),
        matching: find.byTooltip('Delete'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(InkWell, 'Delete').last);
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Cancel'));
    await tester.pumpAndSettle();

    expect(settings().proxyDns, defaultProxyDnsServers);
  });
}
