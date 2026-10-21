import 'dart:async';
import 'dart:io';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/common.dart';
import 'package:fl_clash/providers/action.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/haptics.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// What a bug report needs to know about the build and where it runs.
String _diagnostics() {
  final info = globalState.packageInfo;
  return [
    'FlClash ${info.version} (${info.buildNumber})',
    'env: ${kDebugMode ? 'debug' : globalState.appEnv}',
    'platform: ${Platform.operatingSystem} ${Platform.operatingSystemVersion}',
    'locale: ${Platform.localeName}',
  ].join('\n');
}

class DeveloperView extends ConsumerWidget {
  const DeveloperView({super.key});

  Widget _getDeveloperList(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    return GroupedSection(
      header: appLocalizations.options,
      children: [
        GroupedRow(
          title: appLocalizations.messageTest,
          onTap: () {
            for (final level in MessageLevel.values) {
              context.showNotifier(
                '${level.name}: ${appLocalizations.messageTestTip}',
                level: level,
              );
            }
          },
        ),
        GroupedRow(
          title: appLocalizations.logsTest,
          onTap: () {
            for (int i = 0; i < 1000; i++) {
              ref
                  .read(logsProvider.notifier)
                  .add(
                    Log.app(
                      '[$i]${generateRandomString(maxLength: 200, minLength: 20)}',
                    ),
                  );
            }
          },
        ),
        GroupedRow(
          title: appLocalizations.dialogTest,
          onTap: () => unawaited(
            dialogs.showMessage(
              message: TextSpan(text: appLocalizations.dialogTestTip),
            ),
          ),
        ),
        GroupedRow(
          title: appLocalizations.hapticTest,
          onTap: () {
            selectionHaptic(context);
            Timer(const Duration(milliseconds: 400), () {
              if (context.mounted) {
                toggleHaptic(context);
              }
            });
          },
        ),
        GroupedRow(
          title: appLocalizations.emptyStatesTest,
          chevron: true,
          onTap: () => BaseNavigator.push(context, const EmptyStatesView()),
        ),
        GroupedRow(
          title: appLocalizations.copyDiagnostics,
          onTap: () async {
            await Clipboard.setData(ClipboardData(text: _diagnostics()));
            if (context.mounted) {
              context.showNotifier(
                appLocalizations.copySuccess,
                level: MessageLevel.success,
              );
            }
          },
        ),
        if (globalState.canCrashCore)
          GroupedRow(
            title: appLocalizations.crashTest,
            onTap: () async {
              final coreAction = ref.read(coreActionProvider.notifier);
              final res = await dialogs.showMessage(
                message: TextSpan(text: appLocalizations.confirmForceCrashCore),
                destructive: true,
              );
              if (res != true) {
                return;
              }
              unawaited(coreAction.crash());
            },
          ),
        GroupedRow(
          title: appLocalizations.clearData,
          onTap: () async {
            final storeAction = ref.read(storeActionProvider.notifier);
            final res = await dialogs.showMessage(
              message: TextSpan(text: appLocalizations.confirmClearAllData),
              destructive: true,
            );
            if (res != true) {
              return;
            }
            await storeAction.handleClear();
          },
        ),
        GroupedRow(
          title: appLocalizations.pruneCache,
          onTap: () async {
            await ref.read(storeActionProvider.notifier).shakingStore();
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context, ref) {
    final appLocalizations = context.appLocalizations;
    final enable = ref.watch(
      appSettingProvider.select((state) => state.developerMode),
    );
    return GroupedPage(
      title: appLocalizations.developerMode,
      onBack: () => Navigator.of(context).maybePop(),
      body: GroupedBody(
        children: [
          GroupedSection(
            children: [
              GroupedRow(
                title: appLocalizations.developerMode,
                trailing: GroupedSwitch(
                  value: enable,
                  onChanged: (value) => ref
                      .read(appSettingProvider.notifier)
                      .update((state) => state.copyWith(developerMode: value)),
                ),
              ),
            ],
          ),
          const SizedBox(height: groupedSectionGap),
          _getDeveloperList(context, ref),
        ],
      ),
    );
  }
}

/// Every empty-state illustration with its name, to look them over at once.
class EmptyStatesView extends StatelessWidget {
  const EmptyStatesView({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = GroupedPalette.of(context);
    return GroupedPage(
      title: context.appLocalizations.emptyStatesTest,
      onBack: () => Navigator.of(context).maybePop(),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          groupedPageInset,
          13,
          groupedPageInset,
          20 + BottomInsetScope.of(context),
        ),
        children: [
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 16,
            children: [
              for (final type in NullStatusIllustration.values)
                SizedBox(
                  width: 96,
                  child: Column(
                    children: [
                      EmptyIllustration(type: type, dimension: 72),
                      Text(
                        type.name,
                        style: palette.caption,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
