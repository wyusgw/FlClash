import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';

Future<T> decodeJSONTask<T>(String data) async {
  return compute<String, T>(_decodeJSON, data);
}

Future<T> _decodeJSON<T>(String content) async {
  return json.decode(content);
}

Future<String> encodeJSONTask<T>(T data) async {
  return compute<T, String>(_encodeJSON, data);
}

Future<String> _encodeJSON<T>(T content) async {
  return json.encode(content);
}

Future<String> encodeMD5Task(String data) async {
  return compute<String, String>(_encodeMD5, data);
}

Future<String> _encodeMD5<T>(String content) async {
  return content.toMd5();
}

/// Throws [FormatException] when the file is not UTF-8.
Future<String?> readTextFileTask(String path) {
  return compute(_readTextFile, path);
}

String? _readTextFile(String path) {
  final file = File(path);
  if (!file.existsSync()) {
    return null;
  }
  return utf8.decode(file.readAsBytesSync());
}

Future<List<Group>> toGroupsTask(ComputeGroupsState data) async {
  return compute<ComputeGroupsState, List<Group>>(buildGroups, data);
}

@visibleForTesting
Future<List<Group>> buildGroups(ComputeGroupsState state) async {
  final proxiesData = state.proxiesData;
  final all = proxiesData.all;
  final sortType = state.sortType;
  final delayMap = state.delayMap;
  final selectedMap = state.selectedMap;
  final defaultTestUrl = state.defaultTestUrl;
  final proxies = proxiesData.proxies;
  if (proxies.isEmpty) return [];
  final groups = <Group>[];
  for (final groupName in all) {
    final raw = proxies[groupName];
    if (raw is! Map) continue;
    if (!GroupTypeExtension.valueList.contains(raw['type'])) continue;
    final memberNames = raw['all'];
    final group = Map<String, dynamic>.from(raw);
    group['all'] = memberNames is List
        ? memberNames.map((name) => proxies[name]).nonNulls.toList()
        : const [];
    groups.add(Group.fromJson(group));
  }
  return computeSort(
    groups: groups,
    sortType: sortType,
    delayMap: delayMap,
    selectedMap: selectedMap,
    defaultTestUrl: defaultTestUrl,
  );
}

Future<({String json, String md5})> makeRealProfileTask(
  MakeRealProfileState data,
) async {
  return compute<MakeRealProfileState, ({String json, String md5})>(
    encodeXrayConfig,
    data,
  );
}

typedef ShakingStoreArgs = ({Iterable<int> profileIds});

Future<List<String>> shakingProfileTask(ShakingStoreArgs data) async {
  return compute<
    ({ShakingStoreArgs args, RootIsolateToken token}),
    List<String>
  >(_shakingProfileTask, (args: data, token: RootIsolateToken.instance!));
}

Future<List<String>> _shakingProfileTask(
  ({ShakingStoreArgs args, RootIsolateToken token}) data,
) async {
  BackgroundIsolateBinaryMessenger.ensureInitialized(data.token);
  return shakeOrphanFiles(
    profileIds: data.args.profileIds,
    profilesDirPath: await appPath.profilesPath,
  );
}

@visibleForTesting
List<String> shakeOrphanFiles({
  required Iterable<int> profileIds,
  required String profilesDirPath,
}) {
  final dir = Directory(profilesDirPath);
  if (!dir.existsSync()) {
    return [];
  }
  return [
    for (final entity in dir.listSync(followLinks: false))
      if (entity is File &&
          !profileIds.contains(
            int.tryParse(basenameWithoutExtension(entity.path)),
          ))
        entity.path,
  ];
}

Future<String> encodeLogsTask(List<Log> data) async {
  return compute<List<Log>, String>(_encodeLogsTask, data);
}

Future<String> _encodeLogsTask(List<Log> data) async {
  final logsRaw = data.map((item) => item.toString());
  final logsRawString = logsRaw.join('\n');
  return logsRawString;
}

Future<List<T>> mapListTask<T, S>(List<S> results, T Function(S) mapper) async {
  return compute<({List<S> results, T Function(S) mapper}), List<T>>(
    _mapListTask,
    (results: results, mapper: mapper),
  );
}

Future<List<T>> _mapListTask<T, S>(
  ({List<S> results, T Function(S) mapper}) args,
) async {
  return args.results.map((item) => args.mapper(item)).toList();
}
