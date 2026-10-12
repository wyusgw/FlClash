// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../rule.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RuleSet _$RuleSetFromJson(Map<String, dynamic> json) => _RuleSet(
  id: (json['id'] as num).toInt(),
  label: json['label'] as String? ?? '',
  url: json['url'] as String?,
  lastUpdateDate: json['lastUpdateDate'] == null
      ? null
      : DateTime.parse(json['lastUpdateDate'] as String),
  rules:
      (json['rules'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList() ??
      const [],
);

Map<String, dynamic> _$RuleSetToJson(_RuleSet instance) => <String, dynamic>{
  'id': instance.id,
  'label': instance.label,
  'url': instance.url,
  'lastUpdateDate': instance.lastUpdateDate?.toIso8601String(),
  'rules': instance.rules,
};
