import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/views/about.dart';
import 'package:fl_clash/views/access.dart';
import 'package:fl_clash/views/config/on_demand.dart';
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
  }) {
    return GroupedRow(
      leading: GroupedIcon(glyph),
      title: title,
      chevron: true,
      onTap: () => BaseNavigator.push(context, page),
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
          trayMode: state.trayMode,
          showSidebar: state.showSidebar,
          clipboardDetection: state.clipboardDetection,
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
                title: appLocalizations.appearance,
                page: const ThemeView(),
              ),
              if (system.isDesktop)
                _open(
                  context,
                  glyph: AppGlyphs.keyboard,
                  title: appLocalizations.hotkeyManagement,
                  page: const HotKeyView(),
                ),
              if (appSetting.developerMode)
                _open(
                  context,
                  glyph: AppGlyphs.cpu,
                  title: appLocalizations.developerMode,
                  page: const DeveloperView(),
                ),
            ],
          ),
          const SizedBox(height: groupedSectionGap),
          GroupedSection(
            header: appLocalizations.tunnel,
            children: [
              _open(
                context,
                glyph: AppGlyphs.wifi,
                title: appLocalizations.onDemand,
                page: const OnDemandView(),
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
            header: appLocalizations.permissions,
            children: [
              GroupedRow(
                leading: const GroupedIcon(AppGlyphs.paste),
                title: appLocalizations.clipboard,
                value: appSetting.clipboardDetection
                    ? appLocalizations.on
                    : appLocalizations.off,
                chevron: true,
                onTap: () => BaseNavigator.push(context, const ClipboardView()),
              ),
            ],
          ),
          if (system.isDesktop) ...[
            const SizedBox(height: groupedSectionGap),
            GroupedSection(
              header: _platformName,
              children: [
                GroupedRow(
                  leading: const GroupedIcon(AppGlyphs.columnsTwo),
                  title: appLocalizations.sidebar,
                  value: appSetting.showSidebar
                      ? appLocalizations.on
                      : appLocalizations.off,
                  chevron: true,
                  onTap: () => BaseNavigator.push(context, const SidebarView()),
                ),
                if (system.isMacOS)
                  GroupedRow(
                    leading: const GroupedIcon(AppGlyphs.layoutTabs),
                    title: appLocalizations.menuBar,
                    value: _trayModeLabel(
                      appLocalizations,
                      appSetting.trayMode,
                    ),
                    chevron: true,
                    onTap: () =>
                        BaseNavigator.push(context, const MenuBarView()),
                  ),
              ],
            ),
          ],
          const SizedBox(height: groupedSectionGap),
          GroupedSection(
            header: appLocalizations.reset,
            children: [
              GroupedRow(
                leading: const GroupedIcon(AppGlyphs.reset),
                title: appLocalizations.reset,
                chevron: true,
                onTap: () => BaseNavigator.push(context, const ResetView()),
              ),
            ],
          ),
          const SizedBox(height: groupedSectionGap),
          GroupedSection(
            header: appLocalizations.about,
            children: [
              GroupedRow(
                leading: const GroupedIcon(AppGlyphs.info),
                title: appLocalizations.about,
                chevron: true,
                onTap: () => BaseNavigator.push(context, const AboutView()),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// The heading over the rows only a desktop window has, as its system is
/// written.
String get _platformName => system.isMacOS
    ? 'MACOS'
    : system.isWindows
    ? 'WINDOWS'
    : 'LINUX';

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

String _trayModeLabel(AppLocalizations appLocalizations, TrayMode mode) {
  return switch (mode) {
    TrayMode.embedded => appLocalizations.menuBarEmbedded,
    TrayMode.standalone => appLocalizations.menuBarStandalone,
    TrayMode.off => appLocalizations.off,
  };
}

/// How the app shows itself in the menu bar.
class MenuBarView extends ConsumerWidget {
  const MenuBarView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    return GroupedChoicePage<TrayMode>(
      title: appLocalizations.menuBar,
      choices: {
        for (final mode in TrayMode.values)
          mode: _trayModeLabel(appLocalizations, mode),
      },
      selected: ref.watch(appSettingProvider.select((state) => state.trayMode)),
      onSelected: (mode) => ref
          .read(appSettingProvider.notifier)
          .update((state) => state.copyWith(trayMode: mode)),
    );
  }
}

/// Whether the app looks at the clipboard as it opens, or leaves it to a paste
/// button on the home screen.
class ClipboardView extends StatelessWidget {
  const ClipboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return GroupedTogglePage(
      title: appLocalizations.clipboard,
      description: appLocalizations.clipboardDesc(appName),
      read: (ref) => ref.watch(
        appSettingProvider.select((state) => state.clipboardDetection),
      ),
      write: (ref, value) => ref
          .read(appSettingProvider.notifier)
          .update((state) => state.copyWith(clipboardDetection: value)),
    );
  }
}

/// Whether the window keeps its sidebar; without it the pages are reached
/// from the bar at the bottom, as in a narrow window.
class SidebarView extends ConsumerWidget {
  const SidebarView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    return GroupedChoicePage<bool>(
      title: appLocalizations.sidebar,
      choices: {true: appLocalizations.on, false: appLocalizations.off},
      selected: ref.watch(
        appSettingProvider.select((state) => state.showSidebar),
      ),
      onSelected: (show) {
        ref
            .read(appSettingProvider.notifier)
            .update((state) => state.copyWith(showSidebar: show));
        // Opened without a sidebar, this page covers the whole window; the
        // sidebar can only appear once it is out of the way.
        if (show) {
          Navigator.of(context).maybePop();
        }
      },
    );
  }
}

/// The two ways back to a clean start: the core settings alone, or everything
/// the app has saved.
class ResetView extends ConsumerWidget {
  const ResetView({super.key});

  Future<bool> _confirm(BuildContext context) async {
    final appLocalizations = context.appLocalizations;
    final res = await dialogs.showMessage(
      title: appLocalizations.confirm,
      message: TextSpan(text: appLocalizations.resetTip),
      confirmText: appLocalizations.reset,
      destructive: true,
    );
    return res == true;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    return GroupedPage(
      title: appLocalizations.reset,
      onBack: () => Navigator.of(context).maybePop(),
      body: GroupedBody(
        children: [
          GroupedSection(
            footer: appLocalizations.resetCoreSettingsDesc,
            children: [
              GroupedRow(
                title: appLocalizations.resetCoreSettings,
                chevron: true,
                onTap: () async {
                  if (!await _confirm(context)) {
                    return;
                  }
                  ref.read(storeActionProvider.notifier).resetCoreSettings();
                  dialogs.showNotifier(
                    appLocalizations.resetSuccess,
                    level: MessageLevel.success,
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: groupedSectionGap),
          GroupedSection(
            footer: appLocalizations.resetUserSettingsDesc,
            children: [
              GroupedRow(
                title: appLocalizations.resetUserSettings,
                chevron: true,
                onTap: () async {
                  if (!await _confirm(context)) {
                    return;
                  }
                  await ref.read(storeActionProvider.notifier).handleClear();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
