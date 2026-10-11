import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/views/about.dart';
import 'package:fl_clash/views/access.dart';
import 'package:fl_clash/views/config/general.dart';
import 'package:fl_clash/views/home/delay_test.dart';
import 'package:fl_clash/views/hotkey.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'developer.dart';
import 'theme.dart';

/// The settings page: the language, then the pages that hold the rest.
class ToolsView extends ConsumerWidget {
  const ToolsView({super.key});

  Widget _open(
    BuildContext context, {
    required Glyph glyph,
    required String title,
    required Widget page,
    bool full = false,
  }) {
    return GroupedRow(
      leading: GroupedIcon(glyph),
      title: title,
      chevron: true,
      onTap: () => showExtend(
        context,
        props: ExtendProps(forceFull: full),
        builder: (_) => page,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final appSetting = ref.watch(
      appSettingProvider.select(
        (state) => (
          locale: state.locale,
          developerMode: state.developerMode,
          delayTestMethod: state.delayTestMethod,
        ),
      ),
    );
    final locale = getLocaleForString(appSetting.locale);
    return GroupedPage(
      title: appLocalizations.settings,
      body: ListView(
        key: toolsStoreKey,
        padding: EdgeInsets.fromLTRB(
          groupedPageInset,
          13,
          groupedPageInset,
          20 + BottomInsetScope.of(context),
        ),
        children: [
          GroupedSection(
            children: [
              GroupedRow(
                leading: const GroupedIcon(AppGlyphs.language),
                title: appLocalizations.language,
                value: locale == null
                    ? appLocalizations.defaultText
                    : locale.label,
                chevron: true,
                onTap: () => BaseNavigator.push(context, const LanguageView()),
              ),
            ],
          ),
          const SizedBox(height: groupedSectionGap),
          GroupedSection(
            header: appLocalizations.advanced,
            children: [
              GroupedRow(
                leading: const GroupedIcon(AppGlyphs.speed),
                title: appLocalizations.delayTestMethod,
                value: delayMethodLabel(appSetting.delayTestMethod),
                chevron: true,
                onTap: () =>
                    BaseNavigator.push(context, const DelayMethodView()),
              ),
              _open(
                context,
                glyph: AppGlyphs.paintbrush,
                title: appLocalizations.theme,
                page: const ThemeView(),
              ),
              if (system.isDesktop)
                _open(
                  context,
                  glyph: AppGlyphs.keyboard,
                  title: appLocalizations.hotkeyManagement,
                  page: const HotKeyView(),
                ),
              if (system.isAndroid)
                _open(
                  context,
                  glyph: AppGlyphs.appsList,
                  title: appLocalizations.accessControl,
                  page: const AccessView(),
                ),
              _open(
                context,
                glyph: AppGlyphs.settings,
                title: appLocalizations.general,
                page: const GeneralView(),
              ),
            ],
          ),
          const SizedBox(height: groupedSectionGap),
          GroupedSection(
            header: appLocalizations.other,
            children: [
              if (appSetting.developerMode)
                _open(
                  context,
                  glyph: AppGlyphs.cpu,
                  title: appLocalizations.developerMode,
                  page: const DeveloperView(),
                ),
              _open(
                context,
                glyph: AppGlyphs.info,
                title: appLocalizations.about,
                page: const AboutView(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Every language the app has, with the one in use checked; the first entry
/// follows the system.
class LanguageView extends ConsumerWidget {
  const LanguageView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final palette = GroupedPalette.of(context);
    final current = getLocaleForString(
      ref.watch(appSettingProvider.select((state) => state.locale)),
    );
    Widget row(Locale? locale) {
      return GroupedRow(
        key: ValueKey(locale),
        title: locale == null ? appLocalizations.defaultText : locale.label,
        trailing: locale == current
            ? GlyphIcon(AppGlyphs.check, size: 18, color: palette.icon)
            : null,
        onTap: () => ref
            .read(appSettingProvider.notifier)
            .update((state) => state.copyWith(locale: locale?.toString())),
      );
    }

    return GroupedPage(
      title: appLocalizations.language,
      onBack: () => Navigator.of(context).maybePop(),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          groupedPageInset,
          13,
          groupedPageInset,
          20 + BottomInsetScope.of(context),
        ),
        children: [
          GroupedSection(
            children: [
              row(null),
              for (final locale in AppLocalizations.delegate.supportedLocales)
                row(locale),
            ],
          ),
        ],
      ),
    );
  }
}
