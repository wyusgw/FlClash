import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/widgets/grouped_list.dart';
import 'package:fl_clash/widgets/text_menu.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
                      child: DialogButton(
                        label: cancelText,
                        color: palette.hover,
                        foreground: palette.label,
                        onPressed: () => Navigator.of(context).pop(false),
                      ),
                    ),
                  Expanded(
                    child: DialogButton(
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

/// A button of an iOS-style dialog: a filled bar in [color] with its label in
/// [foreground].
class DialogButton extends StatelessWidget {
  const DialogButton({
    super.key,
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

/// A dialog that asks for one of [options], after an iOS action sheet: the
/// [title] over a column of lines parted by hairlines and a Cancel under them.
/// It pops the option tapped, or nothing on Cancel.
class ChoiceDialog<T> extends StatelessWidget {
  const ChoiceDialog({
    super.key,
    required this.title,
    required this.options,
    required this.labelOf,
    this.value,
  });

  static const _width = 280.0;

  final String title;
  final List<T> options;
  final String Function(T option) labelOf;

  /// The option marked as the current one.
  final T? value;

  @override
  Widget build(BuildContext context) {
    final palette = GroupedPalette.of(context);
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
              Text(
                title,
                textAlign: TextAlign.center,
                style: palette.rowTitle.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      for (final (index, option) in options.indexed) ...[
                        if (index > 0) const GroupedHairline(inset: 0),
                        _ChoiceLine(
                          label: labelOf(option),
                          selected: option == value,
                          onTap: () => Navigator.of(context).pop(option),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              DialogButton(
                label: context.appLocalizations.cancel,
                color: palette.hover,
                foreground: palette.label,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChoiceLine extends StatelessWidget {
  const _ChoiceLine({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = GroupedPalette.of(context);
    return InkWell(
      onTap: onTap,
      highlightColor: palette.hover,
      splashColor: Colors.transparent,
      child: SizedBox(
        height: groupedRowHeight,
        child: Row(
          children: [
            const SizedBox(width: 24),
            Expanded(
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: palette.rowTitle.copyWith(color: palette.accent),
              ),
            ),
            SizedBox(
              width: 24,
              child: selected
                  ? GlyphIcon(AppGlyphs.check, size: 18, color: palette.accent)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
