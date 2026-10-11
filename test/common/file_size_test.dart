import 'package:fl_clash/common/num.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('formatFileSize picks the unit that keeps the number small', () {
    expect(formatFileSize(0), '0B');
    expect(formatFileSize(512), '512B');
    expect(formatFileSize(1024), '1.0K');
    expect(formatFileSize(104857), '102.4K');
    expect(formatFileSize(3 * 1024 * 1024), '3.0M');
    expect(formatFileSize(5 * 1024 * 1024 * 1024), '5.0G');
  });
}
