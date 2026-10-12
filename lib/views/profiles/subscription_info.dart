import 'dart:math' show max;

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';

/// What a subscription reports about its traffic and expiry: the upload and
/// download used, the total and what is left, and when it ends.
class SubscriptionInfoPage extends StatelessWidget {
  const SubscriptionInfoPage({super.key, required this.subscriptionInfo});

  final SubscriptionInfo subscriptionInfo;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final info = subscriptionInfo;
    final used = info.upload + info.download;
    final expire = info.expire != 0
        ? DateTime.fromMillisecondsSinceEpoch(info.expire * 1000).show
        : appLocalizations.infiniteTime;
    return GroupedPage(
      title: appLocalizations.subscriptionInfo,
      onBack: () => Navigator.of(context).maybePop(),
      body: GroupedBody(
        children: [
          GroupedSection(
            header: appLocalizations.trafficUsage,
            children: [
              GroupedRow(
                title: appLocalizations.usedUploadTraffic,
                value: info.upload.traffic.show,
              ),
              GroupedRow(
                title: appLocalizations.usedDownloadTraffic,
                value: info.download.traffic.show,
              ),
              GroupedRow(
                title: appLocalizations.usedTraffic,
                value: used.traffic.show,
              ),
              GroupedRow(
                title: appLocalizations.totalTraffic,
                value: info.total.traffic.show,
              ),
              GroupedRow(
                title: appLocalizations.remainingTraffic,
                value: max(0, info.total - used).traffic.show,
              ),
            ],
          ),
          const SizedBox(height: groupedSectionGap),
          GroupedSection(
            children: [
              GroupedRow(title: appLocalizations.expireTime, value: expire),
            ],
          ),
        ],
      ),
    );
  }
}
