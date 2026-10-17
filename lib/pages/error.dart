import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/widgets/grouped_list.dart';
import 'package:fl_clash/widgets/ios_controls.dart';
import 'package:fl_clash/widgets/text_menu.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

/// What the app shows when it cannot start. It takes nothing from the app's
/// own localizations or providers, which may be the very thing that failed.
class InitErrorScreen extends StatefulWidget {
  final Object error;
  final StackTrace stack;

  const InitErrorScreen({super.key, required this.error, required this.stack});

  @override
  State<InitErrorScreen> createState() => _InitErrorScreenState();
}

class _InitErrorScreenState extends State<InitErrorScreen> {
  bool _copied = false;

  Future<void> _copyToClipboard() async {
    final text =
        '=== ERROR ===\n${widget.error}\n\n=== STACK TRACE ===\n${widget.stack}';
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) setState(() => _copied = true);
  }

  Widget _section(
    GroupedPalette palette,
    String header,
    String text,
    TextStyle style,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: groupedSectionGap),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              groupedRowPadding,
              0,
              groupedRowPadding,
              6,
            ),
            child: Text(header, style: palette.sectionLabel),
          ),
          GroupedCard(
            child: SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.all(groupedRowPadding),
                child: SelectableText(
                  text,
                  contextMenuBuilder: systemTextContextMenu,
                  style: style,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = GroupedPalette.of(context);
    return Material(
      color: palette.canvas,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: groupedBarHeight,
              child: Center(
                child: Text('Init Failed', style: palette.headline),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  groupedPageInset,
                  8,
                  groupedPageInset,
                  16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: groupedSectionGap),
                      child: Row(
                        spacing: 12,
                        children: [
                          const GlyphIcon(
                            AppGlyphs.warning,
                            size: 32,
                            color: groupedDanger,
                          ),
                          Expanded(
                            child: Text(
                              'The application encountered a critical error '
                              'during startup and cannot continue.',
                              style: palette.subhead,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _section(
                      palette,
                      'Error Details:',
                      widget.error.toString(),
                      palette.subhead.copyWith(color: groupedDanger),
                    ),
                    _section(
                      palette,
                      'Stack Trace:',
                      widget.stack.toString(),
                      palette.caption.copyWith(
                        fontFamily: 'monospace',
                        color: palette.label,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                groupedPageInset,
                8,
                groupedPageInset,
                16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                spacing: 10,
                children: [
                  IosButton(
                    label: 'Copy Details',
                    glyph: AppGlyphs.copy,
                    onPressed: _copyToClipboard,
                  ),
                  if (_copied)
                    Text(
                      'Error details copied to clipboard',
                      style: palette.caption,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
