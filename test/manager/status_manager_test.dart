import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/manager/status_manager.dart';
import 'package:fl_clash/models/models.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/glyph_finders.dart';
import '../helpers/test_app.dart';

Future<StatusManagerState> _pumpStatusManager(WidgetTester tester) async {
  await tester.pumpWidget(
    const TestApp(
      wrapInProviderScope: true,
      child: StatusManager(child: SizedBox()),
    ),
  );
  return tester.state<StatusManagerState>(find.byType(StatusManager));
}

Finder _fadeOf(String text) {
  return find
      .ancestor(of: find.text(text), matching: find.byType(FadeTransition))
      .first;
}

double _opacityOf(WidgetTester tester, String text) {
  return tester.widget<FadeTransition>(_fadeOf(text)).opacity.value;
}

double _scaleOf(WidgetTester tester, String text) {
  final scale = find
      .ancestor(of: _fadeOf(text), matching: find.byType(Transform))
      .first;
  return tester.widget<Transform>(scale).transform.storage[0];
}

Finder _cardOf(String text) {
  return find
      .ancestor(of: find.text(text), matching: find.byType(Material))
      .first;
}

void main() {
  testWidgets('shows a message until its duration expires', (tester) async {
    final state = await _pumpStatusManager(tester);
    state.message('hello');
    await tester.pump();

    expect(find.text('hello'), findsOneWidget);

    await tester.pump(const Duration(seconds: 4));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('hello'), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('shows one message at a time and queues the rest', (
    tester,
  ) async {
    final state = await _pumpStatusManager(tester);
    state.message('first');
    state.message('second');
    await tester.pump();

    expect(find.text('first'), findsOneWidget);
    expect(find.text('second'), findsNothing);

    await tester.pump(const Duration(seconds: 4));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('first'), findsNothing);
    expect(find.text('second'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('puts the message in the middle of the screen', (tester) async {
    final state = await _pumpStatusManager(tester);
    state.message('centered');
    await tester.pumpAndSettle();

    final screen = tester.getRect(find.byType(StatusManager));
    final card = tester.getRect(_cardOf('centered'));
    expect(card.center.dx, closeTo(screen.center.dx, 0.5));
    expect(card.center.dy, closeTo(screen.center.dy, 0.5));

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('stacks the glyph above the centered text', (tester) async {
    final state = await _pumpStatusManager(tester);
    state.message('stacked', level: MessageLevel.error);
    await tester.pumpAndSettle();

    final glyph = tester.getCenter(find.byType(GlyphIcon));
    final text = tester.getCenter(find.text('stacked'));
    expect(glyph.dy, lessThan(text.dy));
    expect(glyph.dx, closeTo(text.dx, 0.5));

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('a new message fades and scales in instead of appearing', (
    tester,
  ) async {
    final state = await _pumpStatusManager(tester);
    state.message('animated');
    await tester.pump();

    expect(_opacityOf(tester, 'animated'), 0);
    expect(_scaleOf(tester, 'animated'), lessThan(1));

    await tester.pump(const Duration(milliseconds: 60));
    expect(_opacityOf(tester, 'animated'), greaterThan(0));

    await tester.pump(const Duration(milliseconds: 400));
    expect(_opacityOf(tester, 'animated'), 1);
    expect(_scaleOf(tester, 'animated'), 1);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('an expiring message fades out before it is removed', (
    tester,
  ) async {
    final state = await _pumpStatusManager(tester);
    state.message('leaving');
    await tester.pumpAndSettle();

    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(milliseconds: 100));
    final opacity = _opacityOf(tester, 'leaving');
    expect(opacity, greaterThan(0));
    expect(opacity, lessThan(1));

    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('leaving'), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('merges a repeat instead of queueing it again', (tester) async {
    final state = await _pumpStatusManager(tester);
    state.message('same');
    state.message('same');
    await tester.pump();

    expect(find.text('same'), findsOneWidget);

    await tester.pump(const Duration(seconds: 4));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('same'), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('a merged repeat restarts the visible duration', (tester) async {
    final state = await _pumpStatusManager(tester);
    state.message('same');
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));

    state.message('same');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1500));
    expect(find.text('same'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('an error preempts a low priority message on screen', (
    tester,
  ) async {
    final state = await _pumpStatusManager(tester);
    state.message('info one');
    state.message('boom', level: MessageLevel.error);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('info one'), findsNothing);
    expect(find.text('boom'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('an error jumps ahead of the messages waiting in the queue', (
    tester,
  ) async {
    final state = await _pumpStatusManager(tester);
    state.message('info one');
    state.message('info two');
    state.message('boom', level: MessageLevel.error);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('boom'), findsOneWidget);
    expect(find.text('info one'), findsNothing);
    expect(find.text('info two'), findsNothing);

    await tester.pump(const Duration(seconds: 6));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('info two'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('an error carries a level icon and outlives an info message', (
    tester,
  ) async {
    final state = await _pumpStatusManager(tester);
    state.message('boom', level: MessageLevel.error);
    await tester.pump();

    expect(find.byGlyph(AppGlyphs.close), findsOneWidget);

    await tester.pump(const Duration(seconds: 4));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('boom'), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('boom'), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('every level carries its own glyph', (tester) async {
    const glyphs = {
      MessageLevel.info: AppGlyphs.info,
      MessageLevel.success: AppGlyphs.check,
      MessageLevel.warning: AppGlyphs.warning,
      MessageLevel.error: AppGlyphs.close,
    };
    for (final entry in glyphs.entries) {
      final state = await _pumpStatusManager(tester);
      state.message('level', level: entry.key);
      await tester.pump();

      expect(find.byGlyph(entry.value), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
    }
  });

  testWidgets('a message with an action stays long enough to press it', (
    tester,
  ) async {
    final state = await _pumpStatusManager(tester);
    state.message(
      'restart needed',
      actionState: MessageActionState(actionText: 'restart', action: () {}),
    );
    await tester.pump();

    await tester.pump(const Duration(seconds: 4));
    expect(find.text('restart needed'), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('restart needed'), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('runs the action and dismisses the message when tapped', (
    tester,
  ) async {
    var ran = false;
    final state = await _pumpStatusManager(tester);
    state.message(
      'restart needed',
      actionState: MessageActionState(
        actionText: 'restart',
        action: () => ran = true,
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    await tester.tap(find.text('restart'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(ran, isTrue);
    expect(find.text('restart needed'), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('a swipe takes the message away', (tester) async {
    final state = await _pumpStatusManager(tester);
    state.message('swipe me');
    await tester.pumpAndSettle();

    await tester.drag(_cardOf('swipe me'), const Offset(600, 0));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 220));
    expect(find.text('swipe me'), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('a drag holds the auto dismiss until it is released', (
    tester,
  ) async {
    final state = await _pumpStatusManager(tester);
    state.message('held while the finger stays down on the card');
    await tester.pumpAndSettle();

    final gesture = await tester.startGesture(
      tester.getCenter(_cardOf('held while the finger stays down on the card')),
    );
    for (var step = 0; step < 4; step++) {
      await gesture.moveBy(const Offset(10, 0));
      await tester.pump(const Duration(milliseconds: 50));
    }
    await tester.pump(const Duration(seconds: 4));
    expect(
      find.text('held while the finger stays down on the card'),
      findsOneWidget,
    );

    await gesture.up();
    await tester.pumpAndSettle();
    expect(
      find.text('held while the finger stays down on the card'),
      findsOneWidget,
    );

    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(milliseconds: 500));
    expect(
      find.text('held while the finger stays down on the card'),
      findsNothing,
    );

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('a message that arrives during a drag waits for the release', (
    tester,
  ) async {
    final state = await _pumpStatusManager(tester);
    state.message('the message being held down by a finger');
    await tester.pumpAndSettle();

    final gesture = await tester.startGesture(
      tester.getCenter(_cardOf('the message being held down by a finger')),
    );
    for (var step = 0; step < 4; step++) {
      await gesture.moveBy(const Offset(10, 0));
      await tester.pump(const Duration(milliseconds: 50));
    }

    state.message('arrived mid drag');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('arrived mid drag'), findsNothing);

    await gesture.up();
    await tester.pumpAndSettle();
    expect(find.text('arrived mid drag'), findsNothing);

    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('arrived mid drag'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('a swiped message leaves in the direction of the swipe', (
    tester,
  ) async {
    for (final direction in [-1.0, 1.0]) {
      final state = await _pumpStatusManager(tester);
      state.message('swipe me');
      await tester.pumpAndSettle();
      final restingLeft = tester.getTopLeft(find.text('swipe me')).dx;

      await tester.drag(_cardOf('swipe me'), Offset(300 * direction, 0));
      await tester.pump();
      final releasedAt = tester.getTopLeft(find.text('swipe me')).dx;
      expect((releasedAt - restingLeft).sign, direction);

      while (find.text('swipe me').evaluate().isNotEmpty) {
        final left = tester.getTopLeft(find.text('swipe me')).dx;
        expect((left - releasedAt) * direction, greaterThanOrEqualTo(0));
        await tester.pump(const Duration(milliseconds: 40));
      }

      await tester.pumpWidget(const SizedBox.shrink());
    }
  });

  testWidgets('a short drag springs back and keeps the message', (
    tester,
  ) async {
    final state = await _pumpStatusManager(tester);
    state.message('swipe me');
    await tester.pumpAndSettle();
    final restingLeft = tester.getTopLeft(find.text('swipe me')).dx;

    final gesture = await tester.startGesture(
      tester.getCenter(_cardOf('swipe me')),
    );
    for (var step = 0; step < 4; step++) {
      await gesture.moveBy(const Offset(-10, 0));
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(tester.getTopLeft(find.text('swipe me')).dx, lessThan(restingLeft));
    await tester.pump(const Duration(milliseconds: 500));
    await gesture.up();
    await tester.pumpAndSettle();

    expect(tester.getTopLeft(find.text('swipe me')).dx, restingLeft);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('swipe dismiss removes the message', (tester) async {
    final state = await _pumpStatusManager(tester);
    state.message('swipe me');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    await tester.drag(_cardOf('swipe me'), const Offset(600, 0));
    await tester.pumpAndSettle();

    expect(find.text('swipe me'), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
