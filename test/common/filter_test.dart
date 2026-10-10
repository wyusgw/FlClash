import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:test/test.dart';

void main() {
  group('LogsState.list', () {
    Log log(LogLevel level, String payload) =>
        Log(logLevel: level, payload: payload, dateTime: '2024-01-01');

    test('returns all logs when no keywords and empty query', () {
      final state = LogsState(
        logs: [
          log(LogLevel.info, 'test message'),
          log(LogLevel.error, 'error occurred'),
        ],
      );
      expect(state.list.length, 2);
    });

    test('filters by keyword matching log level', () {
      final state = LogsState(
        logs: [
          log(LogLevel.info, 'info msg'),
          log(LogLevel.error, 'error msg'),
        ],
        keywords: ['error'],
      );
      expect(state.list.length, 1);
      expect(state.list[0].logLevel, LogLevel.error);
    });

    test('filters by query matching payload', () {
      final state = LogsState(
        logs: [
          log(LogLevel.info, 'connection established'),
          log(LogLevel.info, 'timeout error'),
        ],
        query: 'timeout',
      );
      expect(state.list.length, 1);
      expect(state.list[0].payload, 'timeout error');
    });

    test('query is case insensitive', () {
      final state = LogsState(
        logs: [log(LogLevel.info, 'Connection Established')],
        query: 'connection',
      );
      expect(state.list.length, 1);
    });

    test('query also matches log level name', () {
      final state = LogsState(
        logs: [log(LogLevel.info, 'test'), log(LogLevel.error, 'test')],
        query: 'error',
      );
      expect(state.list.length, 1);
      expect(state.list[0].logLevel, LogLevel.error);
    });

    test('empty result when no match', () {
      final state = LogsState(
        logs: [log(LogLevel.info, 'hello')],
        query: 'nonexistent',
      );
      expect(state.list, isEmpty);
    });

    test('query terms match in any order and across fields', () {
      final state = LogsState(
        logs: [
          log(LogLevel.error, 'dial tcp timeout'),
          log(LogLevel.info, 'dial tcp ok'),
        ],
        query: 'TIMEOUT dial',
      );
      expect(state.list.single.payload, 'dial tcp timeout');
      expect(
        state.copyWith(query: 'error dial').list.single.payload,
        'dial tcp timeout',
      );
    });
  });
}
