import 'dart:math';

import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/views.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:super_sliver_list/super_sliver_list.dart';

import '../helpers/scrollbar.dart';
import '../helpers/test_app.dart';

void main() {
  const logCount = 200;

  late ProviderContainer container;

  List<Log> seedLogs() => List.generate(
    logCount,
    (i) => Log(payload: 'log $i', dateTime: '2024-01-01 12:00:$i'),
  );

  Future<void> pumpLogsView(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    container = ProviderContainer();
    addTearDown(container.dispose);
    globalState.container = container;

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(child: LogsView()),
      ),
    );
    final notifier = container.read(logsProvider.notifier);
    for (final log in seedLogs()) {
      notifier.add(log);
    }
    await tester.pump(const Duration(milliseconds: 301));
    await tester.pumpAndSettle();
  }

  const hintKey = ValueKey('scrollbarHintPill');

  Finder hintFinder() => find.byKey(hintKey);

  // The log items hold scrollables of their own, so the list's is the first
  // one below the list widget.
  Finder listScrollable() => find
      .descendant(
        of: find.byType(SuperListView),
        matching: find.byType(Scrollable),
      )
      .first;

  testWidgets('holding the scrollbar thumb floats the time hint beside it', (
    tester,
  ) async {
    await pumpLogsView(tester);
    expect(hintFinder(), findsNothing);

    final thumb = await revealScrollbarThumb(
      tester,
      scrollable: listScrollable(),
    );
    final gesture = await tester.startGesture(thumb);
    await gesture.moveBy(const Offset(0, -1));
    await tester.pump();

    expect(hintFinder(), findsOneWidget);
    final label = tester.widget<Text>(
      find.descendant(of: find.byKey(hintKey), matching: find.byType(Text)),
    );
    expect(seedLogs().map((log) => log.dateTime), contains(label.data));

    final scrollableRect = tester.getRect(listScrollable());
    // The minimum thumb length is 48, so at the newest end the thumb center
    // rests 24px below the track's top edge.
    final trackTop = scrollableRect.top;
    expect(tester.getCenter(find.byKey(hintKey)).dy, closeTo(trackTop + 24, 6));

    await gesture.moveBy(const Offset(0, 2000));
    await tester.pump();
    // Nothing floats over the foot, so the pill follows the thumb all the
    // way down and rests centred on it, the thumb being the track's share of
    // the content.
    final position = tester
        .widget<Scrollable>(listScrollable())
        .controller!
        .position;
    final underBar = trackTop - scrollableRect.top;
    final thumbExtent = max(
      48.0,
      (scrollableRect.bottom - trackTop) *
          (position.viewportDimension - underBar) /
          (position.maxScrollExtent + position.viewportDimension - underBar),
    );
    expect(
      tester.getCenter(find.byKey(hintKey)).dy,
      closeTo(scrollableRect.bottom - thumbExtent / 2, 2),
    );

    await gesture.up();
    // The pill outlives the gesture briefly so letting go and grabbing again
    // does not blink it.
    await tester.pump(const Duration(milliseconds: 100));
    expect(hintFinder(), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();
    expect(hintFinder(), findsNothing);
  });

  testWidgets('auto scroll-to-end on new logs keeps the hint hidden', (
    tester,
  ) async {
    await pumpLogsView(tester);
    expect(hintFinder(), findsNothing);

    container
        .read(logsProvider.notifier)
        .add(const Log(payload: 'log new', dateTime: '2024-01-01 12:00:new'));
    await tester.pump(const Duration(milliseconds: 301));
    await tester.pumpAndSettle();

    expect(hintFinder(), findsNothing);
  });

  testWidgets('the search field narrows the list and clears again', (
    tester,
  ) async {
    await pumpLogsView(tester);

    await tester.enterText(find.byType(TextField), 'log 19');
    await tester.pump(const Duration(milliseconds: 301));
    await tester.pumpAndSettle();
    Finder inList(String text) => find.descendant(
      of: find.byType(SuperListView),
      matching: find.text(text),
    );
    expect(inList('log 19'), findsOneWidget);
    expect(inList('log 5'), findsNothing);

    await tester.tap(find.byTooltip('Clear search'));
    await tester.pump(const Duration(milliseconds: 301));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      isEmpty,
    );
  });

  testWidgets('tapping a level adds a keyword chip and the chip removes it', (
    tester,
  ) async {
    await pumpLogsView(tester);
    container
        .read(logsProvider.notifier)
        .add(
          const Log(
            logLevel: LogLevel.error,
            payload: 'broken',
            dateTime: '2024-01-01 12:01:00',
          ),
        );
    await tester.pump(const Duration(milliseconds: 301));
    await tester.pumpAndSettle();

    await tester.tap(find.text('error'));
    await tester.pump(const Duration(milliseconds: 301));
    await tester.pumpAndSettle();
    expect(find.text('broken'), findsOneWidget);
    expect(find.text('log 5'), findsNothing);

    await tester.tap(find.widgetWithText(InkWell, 'error').first);
    await tester.pump(const Duration(milliseconds: 301));
    await tester.pumpAndSettle();
    expect(find.text('error'), findsOneWidget);
  });

  testWidgets('a one-line log is only as tall as its content', (tester) async {
    await tester.pumpWidget(
      const TestApp(
        child: Scaffold(
          body: Column(
            children: [
              LogItem(
                log: Log(payload: 'short', dateTime: '2024-01-01 12:00:00'),
              ),
            ],
          ),
        ),
      ),
    );

    final item = tester.getRect(find.byType(LogItem));
    final header = tester.getRect(find.byType(RecordHeader));
    final body = tester.getRect(find.byType(SelectableText));
    expect(header.top - item.top, 10);
    expect(item.bottom - body.bottom, 12);
  });

  testWidgets('tapping the level reports it for filtering', (tester) async {
    String? clicked;
    await tester.pumpWidget(
      TestApp(
        child: Scaffold(
          body: LogItem(
            log: const Log(
              logLevel: LogLevel.warning,
              payload:
                  '[TCP] dial Proxy 10.0.0.2:1 --> a.example:443 error: EOF',
              dateTime: '2024-01-01 12:00:00',
            ),
            onClick: (value) => clicked = value,
          ),
        ),
      ),
    );

    await tester.tap(find.text('warning'));

    expect(clicked, 'warning');
  });

  group('LogListController', () {
    final logs = seedLogs();

    test('keeps trimmed logs while auto scroll is off', () {
      final controller = LogListController();
      addTearDown(controller.dispose);
      controller.setLogs(logs.sublist(0, 100));
      controller.setAutoScrollToEnd(false);

      controller.setLogs(logs.sublist(10, 110));

      expect(controller.value.logs, logs.sublist(0, 110));
    });

    test('resume replaces the retained logs and follows the end', () {
      final controller = LogListController();
      addTearDown(controller.dispose);
      controller.setLogs(logs.sublist(0, 100));
      controller.setAutoScrollToEnd(false);
      controller.setLogs(logs.sublist(10, 110));

      final latest = logs.sublist(20, 120);
      controller.resumeAutoScrollToEnd(latest);

      expect(controller.value.autoScrollToEnd, isTrue);
      expect(controller.value.logs, latest);
      controller.setLogs(logs.sublist(30, 130));
      expect(controller.value.logs, logs.sublist(30, 130));
    });
  });
}
