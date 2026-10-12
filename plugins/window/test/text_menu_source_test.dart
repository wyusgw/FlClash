import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

File _source(String relativePath) {
  final direct = File(relativePath);
  if (direct.existsSync()) {
    return direct;
  }
  return File('plugins/window/$relativePath');
}

void main() {
  const method = 'showTextMenu';

  test('every desktop runner answers the text menu call', () {
    final sources = {
      'macOS': 'macos/window/Sources/window/WindowPlugin.swift',
      'Windows': 'windows/window_plugin.cpp',
      'Linux': 'linux/window_plugin.cc',
    };

    for (final entry in sources.entries) {
      expect(
        _source(entry.value).readAsStringSync(),
        contains('"$method"'),
        reason: '${entry.key} registers $method',
      );
    }
  });

  test('macOS takes its titles and submenus from the system text menu', () {
    final swift = _source(
      'macos/window/Sources/window/WindowPlugin.swift',
    ).readAsStringSync();

    expect(swift, contains('NSTextView.defaultMenu'));
    expect(swift, contains('checkSpelling:'));
    expect(swift, contains('orderFrontSubstitutionsPanel:'));
    expect(swift, contains('startSpeaking:'));
  });

  test('Windows and Linux grey the entries that are not enabled', () {
    expect(
      _source('windows/window_plugin.cpp').readAsStringSync(),
      contains('MF_GRAYED'),
    );
    expect(
      _source('linux/window_plugin.cc').readAsStringSync(),
      contains('gtk_widget_set_sensitive'),
    );
  });

  test('each runner answers with the index of the entry chosen', () {
    expect(
      _source(
        'macos/window/Sources/window/WindowPlugin.swift',
      ).readAsStringSync(),
      contains('menu.popUp('),
    );
    expect(
      _source('windows/window_plugin.cpp').readAsStringSync(),
      contains('TPM_RETURNCMD'),
    );
    expect(
      _source('linux/window_plugin.cc').readAsStringSync(),
      contains('gtk_menu_popup_at_rect'),
    );
  });
}
