import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/rule.freezed.dart';
part 'generated/rule.g.dart';

/// The id of the default rule config, which rule mode uses until another is
/// picked. It exists before the user first edits it, holding the built-in
/// rules.
const defaultRuleSetId = 0;

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
