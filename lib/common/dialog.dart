import 'dart:async';

import 'package:animations/animations.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

class Dialogs {
  Dialogs._();

  BuildContext get _context => rootNavigatorKey.currentContext!;

  Future<T?> showCommonDialog<T>({
    required Widget child,
    BuildContext? context,
    bool? dismissible,
  }) async {
    final host = context ?? _context;
    return showModal<T>(
      useRootNavigator: false,
      context: host,
      configuration: FadeScaleTransitionConfiguration(
        barrierColor: host.colorScheme.modalScrim,
        barrierDismissible: dismissible ?? true,
      ),
      builder: (_) => child,
    );
  }

  Future<bool?> showMessage({
    required InlineSpan message,
    BuildContext? context,
    String? title,
    String? confirmText,
    String? cancelText,
    bool cancelable = true,
    bool? dismissible,
    bool destructive = false,
    TextAlign messageAlign = TextAlign.center,
  }) async {
    return showCommonDialog<bool>(
      context: context,
      dismissible: dismissible,
      child: Builder(
        builder: (context) {
          final appLocalizations = context.appLocalizations;
          return ConfirmDialog(
            title: title ?? appLocalizations.tip,
            message: message,
            confirmText: confirmText ?? appLocalizations.confirm,
            cancelText: cancelable
                ? (cancelText ?? appLocalizations.cancel)
                : null,
            destructive: destructive,
            messageAlign: messageAlign,
          );
        },
      ),
    );
  }

  /// The notes of a release, set out like iOS's What's New: the version, then
  /// each group of changes under its name, lines starting at the leading edge.
  Future<bool?> showReleaseNotes({
    required String tagName,
    required String? body,
    required String confirmText,
    String? cancelText,
  }) {
    final palette = GroupedPalette.of(_context);
    final version = parseReleaseChangelog(body);
    final appLocalizations = currentAppLocalizations;
    return showMessage(
      title: appLocalizations.discoverNewVersion,
      message: TextSpan(
        text: '$tagName\n',
        style: palette.rowTitle.copyWith(fontWeight: FontWeight.w600),
        children: version == null
            ? [
                const TextSpan(text: '\n'),
                for (final line in parseReleaseBody(body))
                  TextSpan(text: '• $line\n'),
              ]
            : [
                for (final group in version.visibleGroups) ...[
                  TextSpan(
                    text:
                        '\n${changelogGroupTitle(appLocalizations, group.type)}\n',
                    style: palette.rowSubtitle.copyWith(
                      fontWeight: FontWeight.w600,
                      color: group.type == ChangelogType.breaking
                          ? groupedDanger
                          : palette.accent,
                    ),
                  ),
                  for (final entry in group.entries)
                    TextSpan(text: '• ${entry.text}\n'),
                ],
              ],
      ),
      confirmText: confirmText,
      cancelText: cancelText,
      messageAlign: TextAlign.start,
    );
  }

  void showNotifier(
    String text, {
    MessageLevel level = MessageLevel.info,
    MessageActionState? actionState,
  }) {
    rootNavigatorKey.currentContext?.showNotifier(
      text,
      level: level,
      actionState: actionState,
    );
  }

  Future<void> openUrl(String url) async {
    final res = await showMessage(
      message: TextSpan(text: url),
      title: currentAppLocalizations.externalLink,
      confirmText: currentAppLocalizations.go,
    );
    if (res != true) {
      return;
    }
    unawaited(launchUrl(Uri.parse(url)));
  }
}

/// The question asked before a subscription address is taken in, with the
/// address itself picked out.
InlineSpan importUrlMessage(BuildContext context, String url) {
  final parts = currentAppLocalizations.createProfileFromUrlTip(url).split(url);
  return TextSpan(
    children: [
      TextSpan(text: parts.first),
      TextSpan(
        text: url,
        style: TextStyle(
          color: context.colorScheme.primary,
          decoration: TextDecoration.underline,
          decorationColor: context.colorScheme.primary,
        ),
      ),
      if (parts.length > 1) TextSpan(text: parts.last),
    ],
  );
}

final dialogs = Dialogs._();
