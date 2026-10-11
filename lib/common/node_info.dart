import 'package:fl_clash/icons/icons.dart';

const _groups = <(Glyph, List<String>)>[
  (AppGlyphs.reset, ['重置', 'reset']),
  (AppGlyphs.sync, ['最后更新', '最後更新', '更新时间', '更新時間', 'last update']),
  (AppGlyphs.clock, ['到期', '过期', '過期', '有效期', 'expire', 'expiry']),
  (AppGlyphs.dataUsage, ['流量', 'traffic', 'remaining']),
  (AppGlyphs.link, ['官网', '官網', '网站', '網站', 'website', 'http://', 'https://']),
];

/// The icon of a "node" that is really a line of the subscription's own
/// notes, such as what is left of the traffic or when the plan ends; null for
/// a name that is none of those.
Glyph? nodeInfoGlyph(String name) {
  final lower = name.toLowerCase();
  for (final (glyph, words) in _groups) {
    if (words.any(lower.contains)) return glyph;
  }
  return null;
}
