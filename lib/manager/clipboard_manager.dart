import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/providers/action.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

/// With the clipboard permission on, looks at what was copied as the app
/// opens and each time it comes back into view, and offers to import it. A
/// copy is asked about once, whatever the answer.
class ClipboardManager extends ConsumerStatefulWidget {
  final Widget child;

  const ClipboardManager({super.key, required this.child});

  @override
  ConsumerState<ClipboardManager> createState() => _ClipboardManagerState();
}

class _ClipboardManagerState extends ConsumerState<ClipboardManager> {
  String? _asked;

  @override
  void initState() {
    super.initState();
    ref.listenManual(appVisibleProvider, (_, visible) {
      if (visible) {
        unawaited(_offerImport());
      }
    }, fireImmediately: true);
    ref.listenManual(
      appSettingProvider.select((state) => state.clipboardDetection),
      (previous, enabled) {
        if (enabled && previous != true) {
          unawaited(_offerImport());
        }
      },
    );
  }

  Future<void> _offerImport() async {
    if (!ref.read(
      appSettingProvider.select((state) => state.clipboardDetection),
    )) {
      return;
    }
    final source = await readClipboardImport();
    if (source == null || !mounted || source.text == _asked) {
      return;
    }
    _asked = source.text;
    final appLocalizations = currentAppLocalizations;
    final message = switch (source) {
      ClipboardSubscription(:final url) => importUrlMessage(context, url),
      ClipboardNodes(:final outbounds) => TextSpan(
        text: appLocalizations.importNodesFromClipboardTip(outbounds.length),
      ),
    };
    final res = await dialogs.showMessage(
      title: appLocalizations.addProfile,
      message: message,
    );
    if (res != true || !mounted) {
      return;
    }
    unawaited(
      ref.read(profilesActionProvider.notifier).importFromClipboard(source),
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
