import 'package:fl_clash/state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('crash test availability', () {
    test('is enabled for debug builds', () {
      expect(
        GlobalState.canCrashCoreFor(isDebug: true, appEnv: 'stable'),
        isTrue,
      );
    });

    test('is enabled for dev builds', () {
      expect(
        GlobalState.canCrashCoreFor(isDebug: false, appEnv: 'dev'),
        isTrue,
      );
    });

    test('is disabled for pre and stable release builds', () {
      expect(
        GlobalState.canCrashCoreFor(isDebug: false, appEnv: 'pre'),
        isFalse,
      );
      expect(
        GlobalState.canCrashCoreFor(isDebug: false, appEnv: 'stable'),
        isFalse,
      );
    });
  });

  group('developer page entry', () {
    test('is listed for debug and dev builds without the logo tap', () {
      expect(
        GlobalState.alwaysShowDeveloperFor(isDebug: true, appEnv: 'stable'),
        isTrue,
      );
      expect(
        GlobalState.alwaysShowDeveloperFor(isDebug: false, appEnv: 'dev'),
        isTrue,
      );
    });

    test('stays behind the logo tap for pre and stable release builds', () {
      expect(
        GlobalState.alwaysShowDeveloperFor(isDebug: false, appEnv: 'pre'),
        isFalse,
      );
      expect(
        GlobalState.alwaysShowDeveloperFor(isDebug: false, appEnv: 'stable'),
        isFalse,
      );
    });
  });
}
