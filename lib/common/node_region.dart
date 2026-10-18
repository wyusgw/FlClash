import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/models/models.dart';

import 'node_info.dart';

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

/// The node a line of the subscription's notes takes its flag from: the first
/// real one that a country can be read off, else the first with a server.
Proxy? leadNode(Iterable<Proxy>? nodes) {
  final real = nodes?.where((node) => nodeInfoGlyph(node.name) == null);
  return real
          ?.where(
            (node) => node.region != null || nodeRegionCode(node.name) != null,
          )
          .firstOrNull ??
      real?.where((node) => node.address != null).firstOrNull;
}

/// The country a line of the subscription's notes is flagged with, found
/// without asking where a server is: the British flag for the traffic line,
/// else the one the name names, else the one [lead], the first real node,
/// carries or names. Null for a name that is no such line, or when none is
/// found.
String? infoLineRegionCode(String name, Proxy? lead) {
  final info = nodeInfoGlyph(name);
  if (info == null) return null;
  if (info == AppGlyphs.dataUsage) return 'GB';
  return nodeRegionCode(name) ??
      (lead == null ? null : lead.region ?? nodeRegionCode(lead.name));
}
