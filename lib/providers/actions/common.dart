part of '../action.dart';

@Riverpod(keepAlive: true)
class CommonAction extends _$CommonAction {
  CoreController get _core => ref.read(coreHandlerProvider);
  bool _isUpdatingTraffic = false;

  @override
  void build() {}

  void toggleRunning() => _changeRunning(!ref.read(isStartProvider));

  void start() {
    if (!ref.read(isStartProvider)) {
      _changeRunning(true);
    }
  }

  void stop() {
    if (ref.read(isStartProvider)) {
      _changeRunning(false);
    }
  }

  void _changeRunning(bool running) {
    unawaited(
      globalState.safeRun(
        () => ref
            .read(setupActionProvider.notifier)
            .setRunning(
              running,
              initialize: running && !ref.read(initProvider),
            ),
      ),
    );
  }

  void updateSpeedStatistics() {
    ref
        .read(appSettingProvider.notifier)
        .update((state) => state.copyWith(showTrayTitle: !state.showTrayTitle));
  }

  void updateMode() {
    ref.read(coreSettingProvider.notifier).update((state) {
      final index = Mode.values.indexWhere((item) => item == state.mode);
      if (index == -1) return state;
      final nextIndex = index + 1 > Mode.values.length - 1 ? 0 : index + 1;
      return state.copyWith(mode: Mode.values[nextIndex]);
    });
  }

  Future<void> updateTraffic() async {
    if (_isUpdatingTraffic) {
      return;
    }
    _isUpdatingTraffic = true;
    try {
      final onlyStatisticsProxy = ref.read(
        appSettingProvider.select((state) => state.onlyStatisticsProxy),
      );
      final [traffic, totalTraffic, otherTraffic] = await Future.wait([
        _readTraffic(() => _core.getTraffic(onlyStatisticsProxy)),
        _readTraffic(() => _core.getTotalTraffic(onlyStatisticsProxy)),
        _readTraffic(() => _core.getTotalTraffic(!onlyStatisticsProxy)),
      ]);
      if (traffic != null) {
        ref.read(trafficsProvider.notifier).addTraffic(traffic);
      }
      if (totalTraffic != null) {
        ref.read(totalTrafficProvider.notifier).value = totalTraffic;
      }
      if (totalTraffic != null && otherTraffic != null) {
        ref.read(statsSnapshotProvider.notifier).value = onlyStatisticsProxy
            ? TrafficStats(all: otherTraffic, proxy: totalTraffic)
            : TrafficStats(all: totalTraffic, proxy: otherTraffic);
      }
    } finally {
      _isUpdatingTraffic = false;
    }
  }

  Future<void> loadStatsArchive() async {
    ref.read(statsRecordsProvider.notifier).value = await const StatsArchive()
        .load();
  }

  /// Keeps the run that is ending, when archiving is on and it carried
  /// something. Called before the counters are cleared.
  Future<void> archiveSession() async {
    final runTime = ref.read(runTimeProvider);
    final stats = ref.read(statsSnapshotProvider);
    if (!ref.read(appSettingProvider).archiveStats ||
        runTime == null ||
        stats.all.up + stats.all.down <= 0) {
      return;
    }
    final end = DateTime.now();
    final record = StatsRecord(
      start: end.subtract(Duration(milliseconds: runTime)),
      end: end,
      stats: stats,
    );
    final records = [record, ...await const StatsArchive().load()];
    ref.read(statsRecordsProvider.notifier).value = records;
    await const StatsArchive().save(records);
  }

  Future<void> removeStatsRecords(Iterable<StatsRecord> removed) async {
    final gone = removed.toSet();
    final records = [
      for (final record in await const StatsArchive().load())
        if (!gone.any((item) => item.start == record.start)) record,
    ];
    ref.read(statsRecordsProvider.notifier).value = records;
    await const StatsArchive().save(records);
  }

  void resetStatistics() {
    _core.resetTraffic();
    ref.read(statsSnapshotProvider.notifier).value = const TrafficStats();
    ref.read(totalTrafficProvider.notifier).value = const Traffic();
  }

  Future<Traffic?> _readTraffic(Future<Traffic> Function() request) async {
    try {
      return await request();
    } catch (error) {
      commonPrint.log(
        'updateTraffic error: $error',
        logLevel: coreFailureLogLevel(error),
      );
      return null;
    }
  }

  Future<bool> autoCheckUpdate() async {
    if (!ref.read(appSettingProvider).autoCheckUpdate) return false;
    final res = await request.checkForUpdate();
    await checkUpdateResultHandle(data: res);
    return res != null;
  }

  TextSpan _releaseSpan(BuildContext context, String tagName, String? body) {
    final textTheme = context.textTheme;
    final version = parseReleaseChangelog(body);
    return TextSpan(
      text: '$tagName \n',
      style: textTheme.headlineSmall,
      children: version == null
          ? [
              TextSpan(text: '\n', style: textTheme.bodyMedium),
              for (final submit in parseReleaseBody(body))
                TextSpan(text: '- $submit \n', style: textTheme.bodyMedium),
            ]
          : _changelogSpans(context, version),
    );
  }

  List<TextSpan> _changelogSpans(
    BuildContext context,
    ChangelogVersion version,
  ) {
    final textTheme = context.textTheme;
    return [
      for (final group in version.visibleGroups) ...[
        TextSpan(
          text:
              '\n${changelogGroupTitle(currentAppLocalizations, group.type)}\n',
          style: textTheme.labelLarge?.copyWith(
            color: group.type == ChangelogType.breaking
                ? context.colorScheme.error
                : context.colorScheme.primary,
          ),
        ),
        for (final entry in group.entries)
          TextSpan(text: '• ${entry.text}\n', style: textTheme.bodyMedium),
      ],
    ];
  }

  Future<void> checkUpdateResultHandle({
    Map<String, dynamic>? data,
    bool isUser = false,
  }) async {
    if (data != null) {
      final context = globalState.navigatorKey.currentContext!;
      final res = await dialogs.showMessage(
        title: currentAppLocalizations.discoverNewVersion,
        message: _releaseSpan(
          context,
          data['tag_name'] as String,
          data['body'] as String?,
        ),
        confirmText: currentAppLocalizations.goDownload,
        cancelText: isUser ? null : currentAppLocalizations.noLongerRemind,
      );
      if (res == true) {
        unawaited(
          launchUrl(
            Uri.parse('https://github.com/$repository/releases/latest'),
          ),
        );
      } else if (!isUser && res == false) {
        ref
            .read(appSettingProvider.notifier)
            .update((state) => state.copyWith(autoCheckUpdate: false));
      }
    } else if (isUser) {
      unawaited(
        dialogs.showMessage(
          title: currentAppLocalizations.checkUpdate,
          message: TextSpan(text: currentAppLocalizations.checkUpdateError),
        ),
      );
    }
  }
}
