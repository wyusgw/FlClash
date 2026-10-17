import 'dart:math';

import 'package:fl_clash/common/system.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/common/shape.dart';
import 'package:fl_clash/widgets/grouped_list.dart';
import 'package:fl_clash/widgets/text_menu.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CommonDialog extends ConsumerWidget {
  final String title;
  final Widget? trailing;
  final Widget? child;
  final List<Widget>? actions;
  final EdgeInsets? padding;
  final bool overrideScroll;
  final Color? backgroundColor;

  const CommonDialog({
    super.key,
    required this.title,
    this.trailing,
    this.actions,
    this.child,
    this.padding,
    this.overrideScroll = false,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context, ref) {
    final size = ref.watch(viewSizeProvider);
    return AlertDialog(
      title: trailing == null
          ? Text(title)
          : Row(
              children: [
                Expanded(child: Text(title)),
                trailing!,
              ],
            ),
      actions: actions,
      actionsPadding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
      contentPadding: padding,
      backgroundColor: backgroundColor,
      content: Container(
        constraints: BoxConstraints(
          maxHeight: min(size.height - 40, 500),
          maxWidth: 300,
        ),
        width: size.width - 40,
        child: !overrideScroll ? SingleChildScrollView(child: child) : child,
      ),
    );
  }
}

class CommonModal extends ConsumerWidget {
  final Widget? child;

  const CommonModal({super.key, this.child});

  @override
  Widget build(BuildContext context, ref) {
    final size = ref.watch(viewSizeProvider);
    return Center(
      child: Container(
        width: size.width * 0.85,
        height: size.height * 0.85,
        decoration: const ShapeDecoration(shape: AppShape.xxl),
        clipBehavior: Clip.antiAlias,
        child: child,
      ),
    );
  }
}

/// A question with two answers: the app icon over [title] and [message], and
/// the answers side by side, the one that proceeds in the accent colour.
class ConfirmDialog extends StatelessWidget {
  const ConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    required this.confirmText,
    this.cancelText,
    this.destructive = false,
  });

  static const _width = 280.0;
  static const _icon = 56.0;

  final String title;
  final InlineSpan message;
  final String confirmText;

  /// Null where there is nothing to decline.
  final String? cancelText;

  /// For an answer that deletes or resets: it reads in red on the same grey as
  /// the other button instead of standing out in the accent colour.
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final palette = GroupedPalette.of(context);
    final cancelText = this.cancelText;
    return Dialog(
      backgroundColor: palette.bar,
      elevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      shape: AppShape.xxl,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _width),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (system.isDesktop) ...[
                Image.asset(
                  'assets/images/icon.png',
                  width: _icon,
                  height: _icon,
                ),
                const SizedBox(height: 14),
              ],
              Text(
                title,
                textAlign: TextAlign.center,
                style: palette.rowTitle.copyWith(fontSize: 15),
              ),
              const SizedBox(height: 8),
              Flexible(
                child: SingleChildScrollView(
                  child: SelectableText.rich(
                    TextSpan(
                      style: palette.rowTitle.copyWith(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                      ),
                      children: [message],
                    ),
                    textAlign: TextAlign.center,
                    contextMenuBuilder: systemTextContextMenu,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                spacing: 10,
                children: [
                  if (cancelText != null)
                    Expanded(
                      child: _DialogButton(
                        label: cancelText,
                        color: palette.hover,
                        foreground: palette.label,
                        onPressed: () => Navigator.of(context).pop(false),
                      ),
                    ),
                  Expanded(
                    child: _DialogButton(
                      label: confirmText,
                      color: destructive ? palette.hover : palette.accent,
                      foreground: destructive
                          ? groupedDanger
                          : const Color(0xFFFFFFFF),
                      onPressed: () => Navigator.of(context).pop(true),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DialogButton extends StatelessWidget {
  const _DialogButton({
    required this.label,
    required this.color,
    required this.foreground,
    required this.onPressed,
  });

  final String label;
  final Color color;
  final Color foreground;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    const shape = AppShape.sm;
    return Material(
      color: color,
      shape: shape,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        customBorder: shape,
        child: SizedBox(
          height: 34,
          child: Center(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GroupedPalette.of(
                context,
              ).rowTitle.copyWith(color: foreground),
            ),
          ),
        ),
      ),
    );
  }
}
