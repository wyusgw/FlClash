import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/common.dart';
import 'package:fl_clash/providers/action.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
        if (globalState.canCrashCore)
          GroupedRow(
            title: appLocalizations.crashTest,
            onTap: () async {
              final coreAction = ref.read(coreActionProvider.notifier);
              final res = await dialogs.showMessage(
                message: TextSpan(text: appLocalizations.confirmForceCrashCore),
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
