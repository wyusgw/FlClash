import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/views/profiles/subscription_info.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';

Future<void> _pump(WidgetTester tester, SubscriptionInfo info) async {
  await tester.pumpWidget(
    TestApp(child: SubscriptionInfoPage(subscriptionInfo: info)),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('lists upload, download, used, total, remaining and expiry', (
    tester,
  ) async {
    await _pump(
      tester,
      const SubscriptionInfo(
        upload: 1024,
        download: 2048,
        total: 1073741824,
        expire: 4102444800,
      ),
    );

    final l10n = AppLocalizations.current;
    for (final label in [
      l10n.trafficUsage,
      l10n.usedUploadTraffic,
      l10n.usedDownloadTraffic,
      l10n.usedTraffic,
      l10n.totalTraffic,
      l10n.remainingTraffic,
      l10n.expireTime,
    ]) {
      expect(find.text(label), findsOneWidget, reason: label);
    }
    expect(find.text(1024.traffic.show), findsOneWidget);
    expect(find.text(2048.traffic.show), findsOneWidget);
    expect(find.text(3072.traffic.show), findsOneWidget);
    expect(find.text(1073741824.traffic.show), findsOneWidget);
    expect(find.text((1073741824 - 3072).traffic.show), findsOneWidget);
    expect(
      find.text(DateTime.fromMillisecondsSinceEpoch(4102444800 * 1000).show),
      findsOneWidget,
    );
  });

  testWidgets('no expiry reads as never expiring', (tester) async {
    await _pump(
      tester,
      const SubscriptionInfo(upload: 1, download: 1, total: 1073741824),
    );

    expect(find.text(AppLocalizations.current.infiniteTime), findsOneWidget);
  });

  testWidgets('traffic used past the total leaves nothing remaining', (
    tester,
  ) async {
    await _pump(
      tester,
      const SubscriptionInfo(upload: 2048, download: 2048, total: 1024),
    );

    expect(find.text(0.traffic.show), findsOneWidget);
  });
}
