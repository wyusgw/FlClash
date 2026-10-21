import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/views/home/node_context_menu.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

const _groups = [
  [
    NodeMenuEntry(value: 'copy', label: 'Copy', glyph: AppGlyphs.duplicate),
    NodeMenuEntry(value: 'qr', label: 'QR code', glyph: AppGlyphs.qrCode),
  ],
  [
    NodeMenuEntry(
      value: 'delete',
      label: 'Delete',
      glyph: AppGlyphs.delete,
      danger: true,
    ),
  ],
];

void main() {
  late String? chosen;

  setUp(() => chosen = null);

  Future<void> open(
    WidgetTester tester, {
    required Rect rect,
    Offset? anchor,
    bool withPreview = true,
  }) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () async {
                  chosen = await showNodeContextMenu<String>(
                    context: context,
                    title: 'Node A',
                    anchor: anchor ?? rect.center,
                    groups: _groups,
                    preview: withPreview
                        ? const SizedBox(height: 60, child: Text('Node A'))
                        : null,
                    previewRect: withPreview ? rect : null,
                  );
                },
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  Rect menuRect(WidgetTester tester) => tester.getRect(
    find.ancestor(of: find.text('Copy'), matching: find.byType(Material)).first,
  );

  testWidgets('the row is lifted where it was, and the menu opens under it', (
    tester,
  ) async {
    const rect = Rect.fromLTWH(16, 120, 368, 60);
    await open(tester, rect: rect);

    final lifted = tester.getRect(find.text('Node A'));
    expect(lifted.top, greaterThanOrEqualTo(rect.top - 3));
    expect(lifted.top, lessThan(rect.bottom));
    expect(menuRect(tester).top, greaterThanOrEqualTo(rect.bottom));
    expect(menuRect(tester).bottom, lessThanOrEqualTo(800));
  });

  testWidgets('with no room under the row the menu opens above it', (
    tester,
  ) async {
    const rect = Rect.fromLTWH(16, 640, 368, 60);
    await open(tester, rect: rect);

    expect(menuRect(tester).bottom, lessThanOrEqualTo(rect.top));
    expect(menuRect(tester).top, greaterThanOrEqualTo(0));
  });

  testWidgets('the menu sits on the side the finger was on', (tester) async {
    const rect = Rect.fromLTWH(16, 120, 368, 60);
    await open(tester, rect: rect, anchor: const Offset(360, 150));
    expect(menuRect(tester).right, moreOrLessEquals(rect.right, epsilon: 1));
  });

  testWidgets('a finger on the left puts the menu on the left', (tester) async {
    const rect = Rect.fromLTWH(16, 120, 368, 60);
    await open(tester, rect: rect, anchor: const Offset(40, 150));
    expect(menuRect(tester).left, moreOrLessEquals(rect.left, epsilon: 1));
  });

  testWidgets('the lifted row takes no taps and a line answers', (
    tester,
  ) async {
    await open(tester, rect: const Rect.fromLTWH(16, 120, 368, 60));

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(chosen, 'delete');
    expect(find.text('Copy'), findsNothing);
  });

  testWidgets('without a row it keeps the titled card', (tester) async {
    await open(
      tester,
      rect: const Rect.fromLTWH(16, 120, 368, 60),
      withPreview: false,
    );

    expect(find.text('Node A'), findsOneWidget, reason: 'the title');
    expect(find.text('Copy'), findsOneWidget);
  });
}
