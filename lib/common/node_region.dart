/// Tried in order, so a name goes before any shorter one inside it, as
/// 印度尼西亚 before 印度, and a city before 中国.
const _names = {
  '香港': 'HK',
  '台湾': 'TW',
  '台灣': 'TW',
  '台北': 'TW',
  '臺北': 'TW',
  '新北': 'TW',
  '彰化': 'TW',
  '日本': 'JP',
  '东京': 'JP',
  '東京': 'JP',
  '大阪': 'JP',
  '埼玉': 'JP',
  '新加坡': 'SG',
  '狮城': 'SG',
  '美国': 'US',
  '美國': 'US',
  '洛杉矶': 'US',
  '洛杉磯': 'US',
  '圣何塞': 'US',
  '聖何塞': 'US',
  '硅谷': 'US',
  '矽谷': 'US',
  '西雅图': 'US',
  '西雅圖': 'US',
  '芝加哥': 'US',
  '达拉斯': 'US',
  '達拉斯': 'US',
  '纽约': 'US',
  '紐約': 'US',
  '韩国': 'KR',
  '韓國': 'KR',
  '首尔': 'KR',
  '首爾': 'KR',
  '英国': 'GB',
  '英國': 'GB',
  '伦敦': 'GB',
  '倫敦': 'GB',
  '德国': 'DE',
  '德國': 'DE',
  '法兰克福': 'DE',
  '法蘭克福': 'DE',
  '法国': 'FR',
  '法國': 'FR',
  '巴黎': 'FR',
  '加拿大': 'CA',
  '多伦多': 'CA',
  '多倫多': 'CA',
  '温哥华': 'CA',
  '溫哥華': 'CA',
  '澳大利亚': 'AU',
  '澳洲': 'AU',
  '悉尼': 'AU',
  '俄罗斯': 'RU',
  '俄羅斯': 'RU',
  '莫斯科': 'RU',
  '印度尼西亚': 'ID',
  '印度尼西亞': 'ID',
  '印度': 'IN',
  '孟买': 'IN',
  '孟買': 'IN',
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
  '阿姆斯特丹': 'NL',
  '意大利': 'IT',
  '西班牙': 'ES',
  '瑞士': 'CH',
  '瑞典': 'SE',
  '中国': 'CN',
  '中國': 'CN',
  'japan': 'JP',
  'tokyo': 'JP',
  'osaka': 'JP',
  'hong kong': 'HK',
  'hongkong': 'HK',
  'singapore': 'SG',
  'taiwan': 'TW',
  'taipei': 'TW',
  'united states': 'US',
  'los angeles': 'US',
  'san jose': 'US',
  'silicon valley': 'US',
  'seattle': 'US',
  'chicago': 'US',
  'dallas': 'US',
  'new york': 'US',
  'korea': 'KR',
  'seoul': 'KR',
  'united kingdom': 'GB',
  'london': 'GB',
  'germany': 'DE',
  'frankfurt': 'DE',
  'france': 'FR',
  'canada': 'CA',
  'toronto': 'CA',
  'vancouver': 'CA',
  'australia': 'AU',
  'sydney': 'AU',
  'russia': 'RU',
  'india': 'IN',
  'netherlands': 'NL',
  'amsterdam': 'NL',
};

final _flagEmoji = RegExp('[\u{1F1E6}-\u{1F1FF}]{2}\\s*', unicode: true);
final _codePattern = RegExp(r'(?<![A-Za-z])([A-Z]{2,3})(?![A-Za-z])');
const _knownCodes = {
  'HK', 'TW', 'JP', 'SG', 'US', 'KR', 'GB', 'UK', 'DE', 'FR', 'CA', 'AU', //
  'RU', 'IN', 'MY', 'TH', 'VN', 'PH', 'ID', 'TR', 'AR', 'BR', 'NL', 'IT',
  'ES', 'CH', 'SE', 'CN',
};
const _alpha3 = {
  'HKG': 'HK', 'TWN': 'TW', 'JPN': 'JP', 'SGP': 'SG', 'USA': 'US', //
  'KOR': 'KR', 'GBR': 'GB', 'DEU': 'DE', 'FRA': 'FR', 'CAN': 'CA',
  'AUS': 'AU', 'RUS': 'RU', 'IND': 'IN', 'MYS': 'MY', 'THA': 'TH',
  'VNM': 'VN', 'PHL': 'PH', 'IDN': 'ID', 'TUR': 'TR', 'ARG': 'AR',
  'BRA': 'BR', 'NLD': 'NL', 'ITA': 'IT', 'ESP': 'ES', 'CHE': 'CH',
  'SWE': 'SE', 'CHN': 'CN',
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
    final found = match.group(1)!;
    final code = found.length == 3
        ? _alpha3[found]
        : (_knownCodes.contains(found) ? found : null);
    if (code != null && !_followsNumber(name, match.start)) {
      return code == 'UK' ? 'GB' : code;
    }
  }
  return null;
}

const _infoWords = [
  '重置', '最后更新', '最後更新', '更新时间', '更新時間', '到期', '过期', '過期', //
  '有效期', '流量', '官网', '官網', '网站', '網站', '提示', '公告', '通知', '套餐',
  '客服', 'reset', 'last update', 'expire', 'traffic', 'remaining',
  'bandwidth', 'website', 'notice', 'http://', 'https://',
];

/// Whether a "node" is really a line of the subscription's own notes, such as
/// what is left of the traffic or when the plan ends. Such a line points at no
/// server worth asking about, so its address says nothing of a country.
bool isNodeInfoLine(String name) {
  final lower = name.toLowerCase();
  return _infoWords.any(lower.contains);
}

// Words that are also two-letter country codes.
const _plainWords = {'IN', 'ID', 'IT'};
final _hostSplit = RegExp(r'[^a-z]+');

/// The country a server's domain names, as an alpha-2 code, or null: `hk01.`,
/// `us-2.`, `jp-tokyo.` or `node.sg.` ahead of the registered domain. An
/// address that is a number says nothing.
String? hostRegionCode(String host) {
  final lower = host.toLowerCase().trim();
  if (lower.isEmpty || lower.contains(':') || !lower.contains('.')) return null;
  final labels = lower.split('.');
  if (labels.every((label) => int.tryParse(label) != null)) return null;
  final named = labels.length > 2
      ? labels.sublist(0, labels.length - 2)
      : [labels.first];
  for (final label in named) {
    for (final token in label.split(_hostSplit)) {
      final upper = token.toUpperCase();
      if (token.length == 2 &&
          _knownCodes.contains(upper) &&
          !_plainWords.contains(upper)) {
        return upper == 'UK' ? 'GB' : upper;
      }
      final alpha3 = _alpha3[upper];
      if (alpha3 != null) return alpha3;
      if (token.length > 3) {
        final city = _names[token];
        if (city != null) return city;
      }
    }
  }
  return null;
}

/// The name without its flag emoji, which the round flag beside it already
/// shows. A name that is nothing but flags stays as it is.
String nodeDisplayName(String name) {
  final stripped = name.replaceAll(_flagEmoji, '').trim();
  return stripped.isEmpty ? name : stripped;
}

final _gap = RegExp(r'[\s+]');

/// "8.08 GB" is a size, not Great Britain, whatever kind of space a panel puts
/// between the number and the unit.
bool _followsNumber(String name, int index) {
  var i = index - 1;
  while (i >= 0 && _gap.hasMatch(name[i])) {
    i--;
  }
  return i >= 0 && RegExp(r'\d').hasMatch(name[i]);
}

bool _isRegionalIndicator(int rune) => rune >= 0x1F1E6 && rune <= 0x1F1FF;
