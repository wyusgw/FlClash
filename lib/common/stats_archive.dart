import 'dart:convert';
import 'dart:io';

import 'package:fl_clash/models/models.dart';
import 'package:path/path.dart' show join;

import 'file.dart';
import 'path.dart';

const _maxRecords = 200;

/// The runs of the Core kept for later, newest first, in a file of their own
/// beside the app's data.
class StatsArchive {
  const StatsArchive();

  Future<File> get _file async =>
      File(join(await appPath.homeDirPath, 'stats_archive.json'));

  Future<List<StatsRecord>> load() async {
    final file = await _file;
    if (!await file.exists()) return const [];
    try {
      final data = json.decode(await file.readAsString());
      if (data is! List) return const [];
      return [
        for (final item in data)
          if (item is Map<String, Object?>) StatsRecord.fromJson(item),
      ];
    } on Object {
      return const [];
    }
  }

  Future<void> save(List<StatsRecord> records) async {
    final file = await _file;
    final kept = records.take(_maxRecords).toList();
    await file.safeWriteAsString(
      json.encode([for (final record in kept) record.toJson()]),
    );
  }
}
