import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/widgets/haptics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  late List<MethodCall> calls;

  setUp(() {
    calls = [];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          calls.add(call);
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  Future<BuildContext> pump(WidgetTester tester, {bool? hapticFeedback}) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.listen(appSettingProvider, (_, _) {});
    if (hapticFeedback != null) {
      container
          .read(appSettingProvider.notifier)
          .update((state) => state.copyWith(hapticFeedback: hapticFeedback));
    }
    late BuildContext captured;
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: Builder(
          builder: (context) {
            captured = context;
            return const SizedBox();
          },
        ),
      ),
    );
    return captured;
  }

  bool ticked() => calls.any((call) => call.method == 'HapticFeedback.vibrate');

  testWidgets('ticks while haptic feedback is on, which is the default', (
    tester,
  ) async {
    selectionHaptic(await pump(tester));

    expect(ticked(), isTrue);
  });

  testWidgets('stays silent once haptic feedback is off', (tester) async {
    selectionHaptic(await pump(tester, hapticFeedback: false));

    expect(ticked(), isFalse);
  });

  testWidgets('ticks when there is no scope to ask', (tester) async {
    late BuildContext captured;
    await tester.pumpWidget(
      Builder(
        builder: (context) {
          captured = context;
          return const SizedBox();
        },
      ),
    );

    selectionHaptic(captured);

    expect(ticked(), isTrue);
  });
}
