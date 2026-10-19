import 'package:fl_clash/enum/enum.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/ip_quality.freezed.dart';

@freezed
abstract class IpQuality with _$IpQuality {
  const factory IpQuality({
    required String ip,
    required IpQualitySource source,
    required IpType type,
    String? organization,
    int? asn,
    @Default(false) bool isProxy,
    @Default(false) bool isVpn,
    @Default(false) bool isTor,
    @Default(false) bool isAbuser,
  }) = _IpQuality;
}

extension IpQualityExt on IpQuality {
  IpQualityLevel get level {
    if (isTor || isAbuser) {
      return IpQualityLevel.risky;
    }
    return switch (type) {
      IpType.residential ||
      IpType.mobile ||
      IpType.business => IpQualityLevel.good,
      IpType.hosting => IpQualityLevel.normal,
    };
  }

  /// 0 to 100, from what the sources agree on: the kind of network the
  /// address sits in, less a penalty for each flag raised against it.
  int get purity {
    final base = switch (type) {
      IpType.residential => 100,
      IpType.mobile => 95,
      IpType.business => 90,
      IpType.hosting => 60,
    };
    final penalty =
        (isProxy ? 20 : 0) +
        (isVpn ? 25 : 0) +
        (isTor ? 50 : 0) +
        (isAbuser ? 40 : 0);
    return (base - penalty).clamp(0, 100);
  }
}
