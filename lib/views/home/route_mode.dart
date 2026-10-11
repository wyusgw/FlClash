import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

/// The page behind the home page's routing row: one choice among the modes,
/// each with a line saying where its traffic goes.
class RouteModeView extends ConsumerWidget {
  const RouteModeView({super.key});

  String _describe(AppLocalizations appLocalizations, Mode mode) {
    return switch (mode) {
      Mode.rule => appLocalizations.ruleModeDesc,
      Mode.global => appLocalizations.globalModeDesc,
      Mode.direct => appLocalizations.directModeDesc,
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final palette = GroupedPalette.of(context);
    final mode = ref.watch(coreSettingProvider.select((state) => state.mode));
    return GroupedPage(
      title: appLocalizations.globalRouting,
      onBack: () => Navigator.of(context).maybePop(),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          groupedPageInset,
          13,
          groupedPageInset,
          20,
        ),
        children: [
          GroupedSection(
            header: appLocalizations.globalRouting,
            children: [
              for (final item in Mode.values)
                GroupedRow(
                  key: ValueKey(item),
                  title: item.label,
                  subtitle: _describe(appLocalizations, item),
                  trailing: item == mode
                      ? GlyphIcon(
                          AppGlyphs.check,
                          size: 18,
                          color: palette.icon,
                        )
                      : null,
                  onTap: () =>
                      ref.read(setupActionProvider.notifier).changeMode(item),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
