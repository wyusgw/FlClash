import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:super_sliver_list/super_sliver_list.dart';

class LogListController extends ValueNotifier<LogsState> {
  LogListController() : super(const LogsState());

  void search(String query) {
    value = value.copyWith(query: query);
  }

  void updateKeywords(List<String> keywords) {
    value = value.copyWith(keywords: keywords);
  }

  void setLogs(List<Log> logs) {
    if (identical(logs, value.logs)) {
      return;
    }
    value = value.copyWith(
      logs: value.autoScrollToEnd
          ? logs
          : retainTrimmedHead(value.logs, logs, pausedMaxLogsLength),
    );
  }

  void setAutoScrollToEnd(bool autoScrollToEnd) {
    value = value.copyWith(autoScrollToEnd: autoScrollToEnd);
  }

  void resumeAutoScrollToEnd(List<Log> logs) {
    value = value.copyWith(autoScrollToEnd: true, logs: logs);
  }
}

class LogsView extends ConsumerStatefulWidget {
  const LogsView({super.key});

  @override
  ConsumerState<LogsView> createState() => _LogsViewState();
}

class _LogsViewState extends ConsumerState<LogsView>
    with RouteMotionHoldMixin<LogsView> {
  final _listController = LogListController();
  final _searchController = TextEditingController();
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController(initialScrollOffset: double.maxFinite);
    _listController.setLogs(ref.read(logsProvider).list);
    ref.listenManual(logsProvider.select((state) => state.revision), (_, _) {
      updateLogsThrottler();
    });
  }

  @override
  void dispose() {
    _listController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _handleExport() async {
    final appLocalizations = context.appLocalizations;
    final res = await globalState.safeRun<bool>(() async {
      return ref.read(logsProvider.notifier).exportLogs();
    }, title: appLocalizations.exportLogs);
    if (res != true) return;
    dialogs.showNotifier(
      appLocalizations.exportSuccess,
      level: MessageLevel.success,
    );
  }

  void _addKeyword(String keyword) {
    final keywords = _listController.value.keywords;
    if (keywords.contains(keyword)) {
      return;
    }
    _listController.updateKeywords([...keywords, keyword]);
  }

  void _removeKeyword(String keyword) {
    _listController.updateKeywords([
      for (final item in _listController.value.keywords)
        if (item != keyword) item,
    ]);
  }

  void updateLogsThrottler() {
    throttler.call(FunctionTag.logs, () {
      if (!mounted) {
        return;
      }
      updateWhenRouteSettled(
        () => _listController.setLogs(ref.read(logsProvider).list),
      );
    }, duration: renderThrottleDuration);
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return GroupedPage(
      title: appLocalizations.logs,
      onBack: () => Navigator.of(context).maybePop(),
      trailing: GroupedBarAction(
        glyph: AppGlyphs.export,
        tooltip: appLocalizations.exportLogs,
        onPressed: _handleExport,
      ),
      body: ValueListenableBuilder<LogsState>(
        valueListenable: _listController,
        builder: (context, state, _) {
          final logs = state.list;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  groupedPageInset,
                  13,
                  groupedPageInset,
                  10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 8,
                  children: [
                    GroupedSearchField(
                      controller: _searchController,
                      hint: appLocalizations.search,
                      clearTooltip: appLocalizations.clearSearch,
                      onChanged: _listController.search,
                    ),
                    if (state.keywords.isNotEmpty)
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          for (final keyword in state.keywords)
                            _KeywordChip(
                              label: keyword,
                              onDeleted: () => _removeKeyword(keyword),
                            ),
                        ],
                      ),
                  ],
                ),
              ),
              Expanded(
                child: NullStatusSwitcher(
                  isEmpty: logs.isEmpty,
                  isSearching: state.isSearching,
                  nullStatus: NullStatus(
                    illustration: NullStatusIllustration.logs,
                    label: appLocalizations.nullTip(appLocalizations.logs),
                  ),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        groupedPageInset,
                        0,
                        groupedPageInset,
                        20 + BottomInsetScope.of(context),
                      ),
                      child: GroupedCard(
                        child: FloatingScrollbar(
                          controller: _scrollController,
                          hintBuilder: (fraction) {
                            final index = (fraction * (logs.length - 1))
                                .round();
                            return logs[index].dateTime;
                          },
                          child: ScrollToEndBox(
                            onCancelToEnd: () {
                              _listController.setAutoScrollToEnd(false);
                            },
                            onResumeToEnd: () {
                              _listController.resumeAutoScrollToEnd(
                                ref.read(logsProvider).list,
                              );
                            },
                            controller: _scrollController,
                            enable: state.autoScrollToEnd,
                            dataSource: logs,
                            child: SuperListView.separated(
                              physics: const NextClampingScrollPhysics(),
                              reverse: true,
                              shrinkWrap: true,
                              controller: _scrollController,
                              itemCount: logs.length,
                              separatorBuilder: (_, _) =>
                                  const GroupedHairline(inset: 0),
                              itemBuilder: (_, index) {
                                return LogItem(
                                  log: logs[index],
                                  onClick: _addKeyword,
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _KeywordChip extends StatelessWidget {
  const _KeywordChip({required this.label, required this.onDeleted});

  final String label;
  final VoidCallback onDeleted;

  @override
  Widget build(BuildContext context) {
    final palette = GroupedPalette.of(context);
    return InkWell(
      onTap: onDeleted,
      customBorder: AppShape.full,
      child: DecoratedBox(
        decoration: ShapeDecoration(color: palette.fill, shape: AppShape.full),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 4, 6, 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 4,
            children: [
              Text(label, style: palette.rowValue),
              GlyphIcon(AppGlyphs.close, size: 13, color: palette.secondary),
            ],
          ),
        ),
      ),
    );
  }
}

class LogItem extends StatelessWidget {
  final Log log;
  final Function(String)? onClick;

  const LogItem({super.key, required this.log, this.onClick});

  @override
  Widget build(BuildContext context) {
    final tone = switch (log.logLevel) {
      LogLevel.warning => RecordTone.warning,
      LogLevel.error => RecordTone.error,
      LogLevel.info => RecordTone.neutral,
      LogLevel.debug || LogLevel.silent => RecordTone.muted,
    };
    final payload = LogPayload.parse(log.payload);
    return RecordListItem(
      tone: tone,
      onTap: () {},
      header: RecordHeader(
        children: [
          RecordTimestamp(log.dateTime),
          RecordLabel(
            label: log.logLevel.name,
            tone: tone,
            onPressed: () => onClick?.call(log.logLevel.name),
          ),
        ],
      ),
      body: _LogBody(payload: payload, errorColor: tone.accentColor(context)),
    );
  }
}

class _LogBody extends StatelessWidget {
  final LogPayload payload;
  final Color? errorColor;

  const _LogBody({required this.payload, this.errorColor});

  String get _sourceText => [
    payload.tag,
    if (payload.route case final route?) ...[route.source, route.sourceDetail],
  ].where((text) => text.isNotEmpty).join('  ·  ');

  @override
  Widget build(BuildContext context) {
    final styles = RecordTextStyles.of(context);
    final route = payload.route;
    if (route == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SelectableText(payload.message, style: styles.primary),
          if (payload.tag.isNotEmpty) Text(payload.tag, style: styles.muted),
        ],
      );
    }
    return SelectableText.rich(
      TextSpan(
        children: [
          TextSpan(
            text: route.destination,
            style: styles.primary?.copyWith(fontWeight: FontWeight.w500),
          ),
          if (route.error.isNotEmpty)
            TextSpan(
              text: '\n${route.error}',
              style: styles.secondary?.copyWith(color: errorColor),
            ),
          const TextSpan(text: '\n'),
          if (route.rule.isNotEmpty) ...[
            TextSpan(text: route.rule, style: styles.secondary),
            TextSpan(text: ' \u2192 ', style: styles.muted?.toJetBrainsMono),
          ],
          TextSpan(
            text: route.proxy,
            style: styles.secondary?.copyWith(
              color: context.colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
          TextSpan(text: '\n$_sourceText', style: styles.muted),
        ],
      ),
    );
  }
}
