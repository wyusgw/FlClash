import 'package:fl_clash/common/constant.dart';
import 'package:fl_clash/models/config.dart';
import 'package:flutter_test/flutter_test.dart';

final _client = RegExp(r'^[A-Za-z0-9]+/\d+(\.\d+)*$');

void main() {
  test('the subscription client is Vex and carries a version', () {
    expect(subscriptionUserAgent, startsWith('Vex/'));
    expect(subscriptionUserAgent, matches(_client));
  });

  test('every preset names its client and a version', () {
    expect(defaultUserAgents, [subscriptionUserAgent]);
    for (final userAgent in defaultUserAgents) {
      expect(userAgent, matches(_client), reason: userAgent);
    }
  });

  test('the browser agent states a Chrome version', () {
    expect(browserUa, matches(RegExp(r'Chrome/\d+(\.\d+)* Safari/')));
  });
}
