const _names = {
  '香港': 'HK',
  '台湾': 'TW',
  '台灣': 'TW',
  '日本': 'JP',
  '新加坡': 'SG',
  '狮城': 'SG',
  '美国': 'US',
  '美國': 'US',
  '韩国': 'KR',
  '韓國': 'KR',
  '英国': 'GB',
  '英國': 'GB',
  '德国': 'DE',
  '德國': 'DE',
  '法国': 'FR',
  '法國': 'FR',
  '加拿大': 'CA',
  '澳大利亚': 'AU',
  '澳洲': 'AU',
  '俄罗斯': 'RU',
  '俄羅斯': 'RU',
  '印度': 'IN',
  '马来西亚': 'MY',
  '馬來西亞': 'MY',
  '泰国': 'TH',
  '泰國': 'TH',
  '越南': 'VN',
  '菲律宾': 'PH',
  '菲律賓': 'PH',
  '印尼': 'ID',
  '土耳其': 'TR',
  '阿根廷': 'AR',
  '巴西': 'BR',
  '荷兰': 'NL',
  '荷蘭': 'NL',
  '意大利': 'IT',
  '西班牙': 'ES',
  '瑞士': 'CH',
  '瑞典': 'SE',
  '中国': 'CN',
  '中國': 'CN',
  'japan': 'JP',
  'hong kong': 'HK',
  'hongkong': 'HK',
  'singapore': 'SG',
  'taiwan': 'TW',
  'united states': 'US',
  'korea': 'KR',
  'united kingdom': 'GB',
  'germany': 'DE',
  'france': 'FR',
  'canada': 'CA',
  'australia': 'AU',
  'russia': 'RU',
  'india': 'IN',
  'netherlands': 'NL',
};

final _codePattern = RegExp(r'(?<![A-Za-z])([A-Z]{2})(?![A-Za-z])');
const _knownCodes = {
  'HK', 'TW', 'JP', 'SG', 'US', 'KR', 'GB', 'UK', 'DE', 'FR', 'CA', 'AU', //
  'RU', 'IN', 'MY', 'TH', 'VN', 'PH', 'ID', 'TR', 'AR', 'BR', 'NL', 'IT',
  'ES', 'CH', 'SE', 'CN',
};

/// The country a node's name points at, as an alpha-2 code, or null when it
/// names none. Subscriptions carry no region, so the name is all there is.
String? nodeRegionCode(String name) {
  final runes = name.runes.toList();
  for (var i = 0; i + 1 < runes.length; i++) {
    if (_isRegionalIndicator(runes[i]) && _isRegionalIndicator(runes[i + 1])) {
      return String.fromCharCodes([
        runes[i] - 0x1F1E6 + 0x41,
        runes[i + 1] - 0x1F1E6 + 0x41,
      ]);
    }
  }
  final lower = name.toLowerCase();
  for (final entry in _names.entries) {
    if (lower.contains(entry.key)) return entry.value;
  }
  for (final match in _codePattern.allMatches(name)) {
    final code = match.group(1)!;
    if (_knownCodes.contains(code) && !_followsNumber(name, match.start)) {
      return code == 'UK' ? 'GB' : code;
    }
  }
  return null;
}

/// "8.08 GB" is a size, not Great Britain.
bool _followsNumber(String name, int index) {
  var i = index - 1;
  while (i >= 0 && (name[i] == ' ' || name[i] == '+')) {
    i--;
  }
  return i >= 0 && RegExp(r'\d').hasMatch(name[i]);
}

bool _isRegionalIndicator(int rune) => rune >= 0x1F1E6 && rune <= 0x1F1FF;
