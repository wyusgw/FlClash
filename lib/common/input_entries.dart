enum InputIssueKind { valueTooLong }

class InputIssue {
  final int line;
  final String raw;
  final InputIssueKind kind;

  const InputIssue({required this.line, required this.raw, required this.kind});

  @override
  bool operator ==(Object other) =>
      other is InputIssue &&
      other.line == line &&
      other.raw == raw &&
      other.kind == kind;

  @override
  int get hashCode => Object.hash(line, raw, kind);

  @override
  String toString() => 'InputIssue(line: $line, raw: $raw, kind: $kind)';
}

class ParsedInput<T> {
  final List<T> entries;
  final int skippedExisting;
  final List<InputIssue> issues;

  const ParsedInput({
    required this.entries,
    required this.skippedExisting,
    required this.issues,
  });

  bool get isValid => issues.isEmpty;
}

final _lineSeparator = RegExp(r'\r?\n');
final _listSeparator = RegExp(r'[,，]');

/// Lines copied out of a YAML sequence keep their `- ` marker and quotes.
String _stripLineMarkup(String line) {
  var value = line.trim();
  if (value.startsWith('- ')) {
    value = value.substring(2).trim();
  }
  if (value.endsWith(',')) {
    value = value.substring(0, value.length - 1).trim();
  }
  return value;
}

String _unquote(String value) {
  if (value.length < 2) {
    return value;
  }
  final first = value[0];
  if ((first == '"' || first == "'") && value.endsWith(first)) {
    return value.substring(1, value.length - 1).trim();
  }
  return value;
}

ParsedInput<String> parseListInput(
  String text, {
  Set<String> existing = const {},
  int? maxLength,
}) {
  final entries = <String>[];
  final issues = <InputIssue>[];
  final seen = <String>{};
  var skippedExisting = 0;
  final lines = text.split(_lineSeparator);
  for (var index = 0; index < lines.length; index++) {
    final line = _stripLineMarkup(lines[index]);
    final values = line.split(_listSeparator);
    for (final raw in values) {
      final value = _unquote(raw.trim());
      if (value.isEmpty) {
        continue;
      }
      if (maxLength != null && value.length > maxLength) {
        issues.add(
          InputIssue(
            line: index + 1,
            raw: value,
            kind: InputIssueKind.valueTooLong,
          ),
        );
        continue;
      }
      if (!seen.add(value)) {
        continue;
      }
      if (existing.contains(value)) {
        skippedExisting++;
        continue;
      }
      entries.add(value);
    }
  }
  return ParsedInput(
    entries: entries,
    skippedExisting: skippedExisting,
    issues: issues,
  );
}
