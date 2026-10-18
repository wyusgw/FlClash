import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:jovial_svg/jovial_svg.dart';
import 'package:path/path.dart';

import 'path.dart';

const _flagPixels = 64;

final _flagIcons = <String, Future<String?>>{};

/// The path of a round PNG of the flag of an alpha-2 [code], drawn from the
/// same flag set the app's own flags come from, or null for a code the set
/// lacks. A menu that cannot hold a widget gets its flags through this.
Future<String?> flagIconPath(String code) {
  final key = code.toLowerCase();
  return _flagIcons.putIfAbsent(key, () async {
    try {
      return await _renderFlag(key);
    } catch (_) {
      return null;
    }
  });
}

Future<String?> _renderFlag(String code) async {
  final file = File(join(await appPath.tempPath, 'flags', '$code.png'));
  if (file.existsSync()) {
    return file.path;
  }
  final image = await ScalableImage.fromSIAsset(
    rootBundle,
    'packages/country_flags/res/si/$code.si',
  );
  const size = _flagPixels * 1.0;
  final recorder = ui.PictureRecorder();
  final canvas = ui.Canvas(recorder)
    ..clipPath(ui.Path()..addOval(const ui.Rect.fromLTWH(0, 0, size, size)));
  final viewport = image.viewport;
  final scale = math.max(size / viewport.width, size / viewport.height);
  canvas
    ..translate(
      (size - viewport.width * scale) / 2 - viewport.left * scale,
      (size - viewport.height * scale) / 2 - viewport.top * scale,
    )
    ..scale(scale);
  image.paint(canvas);
  final picture = recorder.endRecording();
  final rendered = await picture.toImage(_flagPixels, _flagPixels);
  final bytes = await rendered.toByteData(format: ui.ImageByteFormat.png);
  picture.dispose();
  rendered.dispose();
  if (bytes == null) {
    return null;
  }
  await file.parent.create(recursive: true);
  await file.writeAsBytes(bytes.buffer.asUint8List());
  return file.path;
}
