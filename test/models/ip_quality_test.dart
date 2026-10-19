import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

IpQuality _quality(
  IpType type, {
  bool isProxy = false,
  bool isVpn = false,
  bool isTor = false,
  bool isAbuser = false,
}) {
  return IpQuality(
    ip: '203.0.113.9',
    source: IpQualitySource.ipLocate,
    type: type,
    isProxy: isProxy,
    isVpn: isVpn,
    isTor: isTor,
    isAbuser: isAbuser,
  );
}

void main() {
  group('IpQuality.level', () {
    test('rates residential, mobile and business addresses good', () {
      for (final type in [IpType.residential, IpType.mobile, IpType.business]) {
        expect(_quality(type).level, IpQualityLevel.good);
      }
    });

    test('rates data center addresses normal even when flagged as VPN', () {
      expect(_quality(IpType.hosting).level, IpQualityLevel.normal);
      expect(
        _quality(IpType.hosting, isProxy: true, isVpn: true).level,
        IpQualityLevel.normal,
      );
    });

    test('rates Tor exits and abusers risky whatever their type', () {
      expect(
        _quality(IpType.residential, isTor: true).level,
        IpQualityLevel.risky,
      );
      expect(
        _quality(IpType.business, isAbuser: true).level,
        IpQualityLevel.risky,
      );
    });
  });

  group('IpQuality.purity', () {
    test('starts from the kind of network', () {
      expect(_quality(IpType.residential).purity, 100);
      expect(_quality(IpType.mobile).purity, 95);
      expect(_quality(IpType.business).purity, 90);
      expect(_quality(IpType.hosting).purity, 60);
    });

    test('loses points for every flag raised against the address', () {
      expect(_quality(IpType.residential, isProxy: true).purity, 80);
      expect(_quality(IpType.hosting, isProxy: true, isVpn: true).purity, 15);
      expect(_quality(IpType.residential, isTor: true).purity, 50);
    });

    test('never drops below zero', () {
      expect(_quality(IpType.hosting, isTor: true, isAbuser: true).purity, 0);
    });
  });
}
