import 'package:fl_clash/core/event.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

class _RecordingListener with CoreEventListener {
  _RecordingListener({this.onCrashCallback});

  final void Function()? onCrashCallback;
  final List<String> crashes = [];

  @override
  void onCrash(String message) {
    crashes.add(message);
    onCrashCallback?.call();
  }
}

void main() {
  test(
    'a listener may unregister itself while an event is dispatched',
    () async {
      late _RecordingListener first;
      final second = _RecordingListener();
      first = _RecordingListener(
        onCrashCallback: () => coreEventManager.removeListener(first),
      );

      coreEventManager.addListener(first);
      coreEventManager.addListener(second);
      addTearDown(() {
        coreEventManager.removeListener(first);
        coreEventManager.removeListener(second);
      });

      coreEventManager.sendEvent(
        const CoreEvent(type: CoreEventType.crash, data: 'core-a'),
      );
      await pumpEventQueue();

      expect(first.crashes, ['core-a']);
      expect(second.crashes, ['core-a']);

      coreEventManager.sendEvent(
        const CoreEvent(type: CoreEventType.crash, data: 'core-b'),
      );
      await pumpEventQueue();

      expect(first.crashes, ['core-a']);
      expect(second.crashes, ['core-a', 'core-b']);
    },
  );
}
