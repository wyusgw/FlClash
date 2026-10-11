import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

/// The glyph that stands for a delay test method on the home page's row.
Glyph delayMethodGlyph(DelayTestMethod method) => switch (method) {
  DelayTestMethod.tcp => AppGlyphs.circleT,
  DelayTestMethod.url => AppGlyphs.circleC,
};

String delayMethodLabel(DelayTestMethod method) => switch (method) {
  DelayTestMethod.tcp => 'TCP',
  DelayTestMethod.url => 'CONNECT',
};

/// How latency is measured: one of the methods, and the way into the settings
/// of the URL request.
class DelayMethodView extends ConsumerWidget {
  const DelayMethodView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final palette = GroupedPalette.of(context);
    final method = ref.watch(
      appSettingProvider.select((state) => state.delayTestMethod),
    );
    return GroupedPage(
      title: appLocalizations.connectivityTest,
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
              for (final item in DelayTestMethod.values)
                GroupedRow(
                  key: ValueKey(item),
                  title: delayMethodLabel(item),
                  subtitle: item == DelayTestMethod.url
                      ? appLocalizations.connectDesc
                      : null,
                  trailing: item == method
                      ? GlyphIcon(
                          AppGlyphs.check,
                          size: 18,
                          color: palette.icon,
                        )
                      : null,
                  onTap: () => ref
                      .read(appSettingProvider.notifier)
                      .update((state) => state.copyWith(delayTestMethod: item)),
                ),
            ],
          ),
          const SizedBox(height: groupedSectionGap),
          GroupedSection(
            children: [
              GroupedRow(
                title: appLocalizations.urlTestSettings,
                chevron: true,
                onTap: () =>
                    BaseNavigator.push(context, const UrlTestSettingsView()),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// The two numbers a URL request is tested with: how long to wait and where to
/// ask. A value that is not valid is kept in the field but not stored.
class UrlTestSettingsView extends ConsumerStatefulWidget {
  const UrlTestSettingsView({super.key});

  @override
  ConsumerState<UrlTestSettingsView> createState() =>
      _UrlTestSettingsViewState();
}

class _UrlTestSettingsViewState extends ConsumerState<UrlTestSettingsView> {
  late final _timeout = TextEditingController(
    text: '${ref.read(appSettingProvider).delayTestTimeoutSeconds}',
  );
  late final _url = TextEditingController(
    text: ref.read(appSettingProvider).testUrl,
  );

  @override
  void dispose() {
    _timeout.dispose();
    _url.dispose();
    super.dispose();
  }

  void _storeTimeout(String value) {
    final seconds = int.tryParse(value);
    if (seconds == null ||
        seconds < minDelayTestTimeoutSeconds ||
        seconds > maxDelayTestTimeoutSeconds) {
      return;
    }
    ref
        .read(appSettingProvider.notifier)
        .update((state) => state.copyWith(delayTestTimeoutSeconds: seconds));
  }

  void _storeUrl(String value) {
    final url = value.trim();
    if (!url.isUrl) {
      return;
    }
    ref
        .read(appSettingProvider.notifier)
        .update((state) => state.copyWith(testUrl: url));
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return GroupedPage(
      title: appLocalizations.urlTestSettings,
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
            footer: appLocalizations.timeoutDesc,
            children: [
              GroupedFieldRow(
                label: appLocalizations.timeout,
                hint: '$defaultDelayTestTimeoutSeconds',
                suffix: 's',
                controller: _timeout,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: _storeTimeout,
              ),
            ],
          ),
          const SizedBox(height: groupedSectionGap),
          GroupedSection(
            footer: appLocalizations.testUrlDesc,
            children: [
              GroupedFieldRow(
                label: appLocalizations.testUrl,
                hint: defaultTestUrl,
                controller: _url,
                keyboardType: TextInputType.url,
                inputFormatters: TextInputLimits.limit(TextInputLimits.url),
                onChanged: _storeUrl,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
