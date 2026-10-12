import 'package:flutter/services.dart';

import 'string.dart';
import 'subscription.dart';

/// What the clipboard holds that the app can take in.
sealed class ClipboardImport {
  const ClipboardImport(this.text);

  /// The clipboard text itself, so a prompt can tell a new copy from one it
  /// already asked about.
  final String text;
}

/// One subscription address.
final class ClipboardSubscription extends ClipboardImport {
  const ClipboardSubscription(super.text, this.url);

  final String url;
}

/// One or more share links, each of a supported node.
final class ClipboardNodes extends ClipboardImport {
  const ClipboardNodes(super.text, this.outbounds);

  final List<Map<String, dynamic>> outbounds;
}

ClipboardImport? parseClipboardImport(String? clipboard) {
  final text = clipboard?.trim() ?? '';
  if (text.isEmpty) {
    return null;
  }
  final uri = Uri.tryParse(text);
  if (uri != null &&
      text.isUrl &&
      (uri.scheme == 'http' || uri.scheme == 'https') &&
      !text.contains(RegExp(r'\s'))) {
    return ClipboardSubscription(text, text);
  }
  final lines = text
      .split(RegExp(r'[\r\n]+'))
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty);
  final outbounds = <Map<String, dynamic>>[];
  for (final line in lines) {
    final node = parseShareLink(line);
    if (node == null) {
      return null;
    }
    outbounds.add(node);
  }
  return outbounds.isEmpty ? null : ClipboardNodes(text, outbounds);
}

Future<ClipboardImport?> readClipboardImport() async {
  final data = await Clipboard.getData(Clipboard.kTextPlain);
  return parseClipboardImport(data?.text);
}
