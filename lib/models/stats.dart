import 'common.dart';

/// What the Core has carried since it started or since the counters were last
/// cleared: everything, and the part of it that went through a proxy.
class TrafficStats {
  const TrafficStats({
    this.all = const Traffic(),
    this.proxy = const Traffic(),
  });

  final Traffic all;
  final Traffic proxy;

  /// What did not go through a proxy: the rest of [all].
  Traffic get direct => Traffic(
    up: (all.up - proxy.up).clamp(0, double.infinity),
    down: (all.down - proxy.down).clamp(0, double.infinity),
  );

  @override
  bool operator ==(Object other) =>
      other is TrafficStats && other.all == all && other.proxy == proxy;

  @override
  int get hashCode => Object.hash(all, proxy);
}

/// One run of the Core, kept when it ends.
class StatsRecord {
  const StatsRecord({
    required this.start,
    required this.end,
    required this.stats,
  });

  factory StatsRecord.fromJson(Map<String, Object?> json) {
    Traffic traffic(Object? value) => value is Map<String, Object?>
        ? Traffic.fromJson(value)
        : const Traffic();
    return StatsRecord(
      start: DateTime.fromMillisecondsSinceEpoch(json['start'] as int),
      end: DateTime.fromMillisecondsSinceEpoch(json['end'] as int),
      stats: TrafficStats(
        all: traffic(json['all']),
        proxy: traffic(json['proxy']),
      ),
    );
  }

  final DateTime start;
  final DateTime end;
  final TrafficStats stats;

  Duration get duration => end.difference(start);

  Map<String, Object?> toJson() => {
    'start': start.millisecondsSinceEpoch,
    'end': end.millisecondsSinceEpoch,
    'all': stats.all.toJson(),
    'proxy': stats.proxy.toJson(),
  };
}
