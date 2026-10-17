import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/common/share_link.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/action.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

/// What a node is handed out as, its share link or its outbound as JSON;
/// null when the node is no longer in [profile].
Future<String?> _shareText(WidgetRef ref, Profile profile, Proxy node) async {
  final outbound = await ref
      .read(profilesActionProvider.notifier)
      .readNodeOutbound(profile, node.name);
  return outbound == null ? null : nodeShareText(outbound);
}

Future<void> copyNode(
  BuildContext context,
  WidgetRef ref,
  Profile profile,
  Proxy node,
) async {
  final text = await _shareText(ref, profile, node);
  if (text == null) return;
  await Clipboard.setData(ClipboardData(text: text));
  if (context.mounted) {
    context.showNotifier(
      context.appLocalizations.copySuccess,
      level: MessageLevel.success,
    );
  }
}

Future<void> showNodeQrCode(
  BuildContext context,
  WidgetRef ref,
  Profile profile,
  Proxy node,
) async {
  final text = await _shareText(ref, profile, node);
  if (text == null || !context.mounted) return;
  await BaseNavigator.push(
    context,
    _NodeQrCodeView(name: node.name, text: text),
  );
}

/// Asks first, then removes the node from its profile.
Future<void> deleteNode(
  BuildContext context,
  WidgetRef ref,
  Profile profile,
  Proxy node,
) async {
  final appLocalizations = context.appLocalizations;
  final res = await dialogs.showMessage(
    title: node.name,
    message: TextSpan(
      text: appLocalizations.deleteTip(appLocalizations.server),
    ),
    destructive: true,
  );
  if (res != true) return;
  await ref
      .read(profilesActionProvider.notifier)
      .deleteNode(profile, node.name);
}

/// A node's share link as a QR code another device can scan, with the text
/// under it.
class _NodeQrCodeView extends StatelessWidget {
  const _NodeQrCodeView({required this.name, required this.text});

  final String name;
  final String text;

  @override
  Widget build(BuildContext context) {
    final palette = GroupedPalette.of(context);
    return GroupedPage(
      title: name,
      onBack: () => Navigator.of(context).maybePop(),
      body: GroupedBody(
        children: [
          Center(
            child: ClipRSuperellipse(
              borderRadius: AppRadius.lg,
              child: QrCodeView(data: text, size: 260),
            ),
          ),
          const SizedBox(height: 16),
          SelectableText(
            text,
            textAlign: TextAlign.center,
            style: palette.caption,
          ),
        ],
      ),
    );
  }
}
