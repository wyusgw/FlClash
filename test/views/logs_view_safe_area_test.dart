import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/views.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/test_app.dart';

void main() {
  testWidgets('the log list does not take the safe area into its card', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(412, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final container = ProviderContainer();
    addTearDown(container.dispose);
    globalState.container = container;
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(
          child: MediaQuery(
            data: MediaQueryData(
              size: Size(412, 900),
              padding: EdgeInsets.only(top: 46, bottom: 24),
            ),
            child: LogsView(),
          ),
        ),
      ),
    );
    container
        .read(logsProvider.notifier)
        .add(
          const Log(
            payload: 'initAppLinksListen',
            dateTime: '2026-10-19 19:36:55',
          ),
        );
    await tester.pump(const Duration(milliseconds: 301));
    await tester.pumpAndSettle();

    final card = tester.getRect(find.byType(GroupedCard).last);
    final item = tester.getRect(find.byType(RecordListItem));
    expect(item.top - card.top, lessThan(1));
    expect(card.bottom - item.bottom, lessThan(1));
  });
}
