import 'package:fl_clash/common/node_info.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('nodeInfoGlyph', () {
    test('tells each line of a subscription\'s notes apart', () {
      expect(nodeInfoGlyph('最后更新时间：2026年10月11日 22:07:59'), AppGlyphs.sync);
      expect(nodeInfoGlyph('剩余流量：8.08 GB'), AppGlyphs.dataUsage);
      expect(nodeInfoGlyph('距离下次重置剩余：20 天'), AppGlyphs.reset);
      expect(nodeInfoGlyph('套餐到期：2026年12月05日'), AppGlyphs.clock);
      expect(nodeInfoGlyph('官网：http://10.0.0.5:25566'), AppGlyphs.link);
      expect(nodeInfoGlyph('🚀温馨提示: 感到卡顿请先更新订阅'), AppGlyphs.info);
      expect(nodeInfoGlyph('📢 公告：节点维护'), AppGlyphs.info);
      expect(nodeInfoGlyph('套餐：标准版'), AppGlyphs.info);
      expect(nodeInfoGlyph('客服：@support'), AppGlyphs.info);
      expect(nodeInfoGlyph('套餐到期：2026年12月05日'), AppGlyphs.clock);
    });

    test('reads the English wording too', () {
      expect(nodeInfoGlyph('Traffic remaining: 8 GB'), AppGlyphs.dataUsage);
      expect(nodeInfoGlyph('Expires 2026-12-05'), AppGlyphs.clock);
      expect(nodeInfoGlyph('Last update: today'), AppGlyphs.sync);
      expect(nodeInfoGlyph('Website https://example.com'), AppGlyphs.link);
      expect(nodeInfoGlyph('Bandwidth: 100 GB'), AppGlyphs.dataUsage);
    });

    test('a name that is only a name has none', () {
      expect(nodeInfoGlyph('日本'), isNull);
      expect(nodeInfoGlyph('Tokyo 01'), isNull);
      expect(nodeInfoGlyph(''), isNull);
    });
  });
}
