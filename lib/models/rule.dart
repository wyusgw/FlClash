import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/rule.freezed.dart';
part 'generated/rule.g.dart';

/// A named list of Xray routing rules, written by hand, imported from a file
/// or downloaded from [url]. Each rule is kept as Xray reads it.
@freezed
abstract class RuleSet with _$RuleSet {
  const factory RuleSet({
    required int id,
    @Default('') String label,
    String? url,
    DateTime? lastUpdateDate,
    @Default([]) List<Map<String, dynamic>> rules,
  }) = _RuleSet;

  factory RuleSet.fromJson(Map<String, Object?> json) =>
      _$RuleSetFromJson(json);
}
