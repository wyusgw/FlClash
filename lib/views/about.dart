import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@immutable
class Contributor {
  final String avatar;
  final String name;

  const Contributor({required this.avatar, required this.name});
}

const _heroLogoSize = 72.0;

class AboutView extends ConsumerWidget {
  const AboutView({super.key});

  static const _contributors = [
    Contributor(avatar: 'assets/images/avatar/june2.jpg', name: 'June2'),
    Contributor(avatar: 'assets/images/avatar/arue.jpg', name: 'Arue'),
  ];

  Future<void> _checkUpdate(BuildContext context, WidgetRef ref) async {
    if (ref.read(loadingProvider(LoadingTag.checkUpdate))) return;
    final commonAction = ref.read(commonActionProvider.notifier);
    final data = await globalState.loadingRun<Map<String, dynamic>?>(
      request.checkForUpdate,
      title: context.appLocalizations.checkUpdate,
      tag: LoadingTag.checkUpdate,
    );
    unawaited(commonAction.checkUpdateResultHandle(data: data, isUser: true));
  }

  Widget _link({
    required Glyph glyph,
    required String title,
    required String url,
  }) {
    return GroupedRow(
      leading: GroupedIcon(glyph),
      title: title,
      chevron: true,
      onTap: () => dialogs.openUrl(url),
    );
  }

  GroupedRow _credit(String name, String url) {
    return GroupedRow(
      title: name,
      chevron: true,
      onTap: () => dialogs.openUrl(url),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final palette = GroupedPalette.of(context);
    final isLoading = ref.watch(loadingProvider(LoadingTag.checkUpdate));
    final packageInfo = globalState.packageInfo;
    return GroupedPage(
      title: appLocalizations.about,
      onBack: () => Navigator.of(context).maybePop(),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          groupedPageInset,
          13,
          groupedPageInset,
          20 + BottomInsetScope.of(context),
        ),
        children: [
          _AboutHero(
            onEnterDeveloperMode: () {
              ref
                  .read(appSettingProvider.notifier)
                  .update((state) => state.copyWith(developerMode: true));
              context.showNotifier(
                appLocalizations.developerModeEnableTip,
                level: MessageLevel.success,
              );
            },
          ),
          const SizedBox(height: 16),
          GroupedSection(
            children: [
              GroupedRow(
                title: appLocalizations.version,
                value: '${packageInfo.version} (${packageInfo.buildNumber})',
              ),
              GroupedRow(
                leading: const GroupedIcon(AppGlyphs.sync),
                title: appLocalizations.checkUpdate,
                trailing: isLoading
                    ? SizedBox.square(
                        dimension: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: palette.secondary,
                        ),
                      )
                    : null,
                chevron: !isLoading,
                onTap: isLoading ? null : () => _checkUpdate(context, ref),
              ),
            ],
          ),
          const SizedBox(height: groupedSectionGap),
          GroupedSection(
            children: [
              _link(
                glyph: AppGlyphs.star,
                title: appLocalizations.starOnGithub,
                url: 'https://github.com/$repository',
              ),
              _link(
                glyph: AppGlyphs.send,
                title: 'Telegram',
                url: 'https://t.me/FlClash',
              ),
            ],
          ),
          const SizedBox(height: groupedSectionGap),
          GroupedSection(
            header: appLocalizations.feedback,
            footer: appLocalizations.feedbackDesc,
            children: [
              _link(
                glyph: AppGlyphs.compose,
                title: appLocalizations.feedback,
                url: 'https://github.com/$repository/issues',
              ),
            ],
          ),
          const SizedBox(height: groupedSectionGap),
          GroupedSection(
            header: appLocalizations.urlSchemes,
            children: [
              GroupedRow(
                title: appLocalizations.urlSchemes,
                chevron: true,
                onTap: () =>
                    BaseNavigator.push(context, const UrlSchemesView()),
              ),
            ],
          ),
          const SizedBox(height: groupedSectionGap),
          GroupedSection(
            header: appLocalizations.acknowledgements,
            footer: appLocalizations.appIconDesign,
            children: [
              _credit('FlClash', 'https://github.com/chen08209/FlClash'),
              _credit('Xray-core', 'https://github.com/XTLS/Xray-core'),
              for (final contributor in _contributors)
                GroupedRow(
                  leading: CircleAvatar(
                    radius: groupedLeadingSize / 2,
                    foregroundImage: AssetImage(contributor.avatar),
                  ),
                  title: contributor.name,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// The link schemes the app opens, each copied with a tap.
class UrlSchemesView extends StatelessWidget {
  const UrlSchemesView({super.key});

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return GroupedPage(
      title: appLocalizations.urlSchemes,
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
            footer: appLocalizations.copyScheme,
            children: [
              for (final scheme in protocolSchemes)
                GroupedRow(
                  title: '$scheme://',
                  onTap: () async {
                    await Clipboard.setData(ClipboardData(text: '$scheme://'));
                    if (context.mounted) {
                      context.showNotifier(
                        appLocalizations.copySuccess,
                        level: MessageLevel.success,
                      );
                    }
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AboutHero extends StatelessWidget {
  final VoidCallback onEnterDeveloperMode;

  const _AboutHero({required this.onEnterDeveloperMode});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Center(
        child: _DeveloperModeDetector(
          onEnterDeveloperMode: onEnterDeveloperMode,
          child: Image.asset(
            'assets/images/icon.png',
            width: _heroLogoSize,
            height: _heroLogoSize,
          ),
        ),
      ),
    );
  }
}

class _DeveloperModeDetector extends StatefulWidget {
  final Widget child;
  final VoidCallback onEnterDeveloperMode;

  const _DeveloperModeDetector({
    required this.child,
    required this.onEnterDeveloperMode,
  });

  @override
  State<_DeveloperModeDetector> createState() => _DeveloperModeDetectorState();
}

class _DeveloperModeDetectorState extends State<_DeveloperModeDetector> {
  int _counter = 0;
  Timer? _timer;

  void _handleTap() {
    _counter++;
    if (_counter >= 5) {
      widget.onEnterDeveloperMode();
      _resetCounter();
    } else {
      _timer?.cancel();
      _timer = Timer(const Duration(seconds: 1), _resetCounter);
    }
  }

  void _resetCounter() {
    _counter = 0;
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: _handleTap, child: widget.child);
  }
}
