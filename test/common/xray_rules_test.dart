import 'package:fl_clash/common/xray_rules.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('parseXrayRules', () {
    const rule = {
      'domain': ['geosite:google'],
      'outboundTag': 'proxy',
    };

    test('takes a whole config, its routing object or the list', () {
      for (final text in [
        '{"routing":{"rules":[{"domain":["geosite:google"],"outboundTag":"proxy"}]}}',
        '{"rules":[{"domain":["geosite:google"],"outboundTag":"proxy"}]}',
        '[{"domain":["geosite:google"],"outboundTag":"proxy"}]',
      ]) {
        expect(parseXrayRules(text), [rule], reason: text);
      }
    });

    test('drops entries that match nothing', () {
      expect(
        parseXrayRules(
          '[{"outboundTag":"proxy"},"text",{"domain":["geosite:google"],"outboundTag":"proxy"}]',
        ),
        [rule],
      );
    });

    test('refuses text with no rule in it', () {
      for (final text in ['not json', '{}', '[]', '[{"outboundTag":"x"}]']) {
        expect(() => parseXrayRules(text), throwsFormatException, reason: text);
      }
    });
  });

  test('a rule names its policy by the conventional outbound tags', () {
    expect(rulePolicyOf({'outboundTag': 'direct'}), RulePolicy.direct);
    expect(rulePolicyOf({'outboundTag': 'block'}), RulePolicy.block);
    expect(rulePolicyOf({'outboundTag': 'reject'}), RulePolicy.block);
    expect(rulePolicyOf({'outboundTag': 'proxy'}), RulePolicy.proxy);
    expect(rulePolicyOf({'outboundTag': 'my-node'}), RulePolicy.proxy);
    expect(rulePolicyOf({}), RulePolicy.proxy);
  });

  test('buildRule writes each value with the prefix of its match', () {
    expect(
      buildRule(RuleMatch.domainSuffix, ['a.com', 'b.com'], RulePolicy.direct),
      {
        'domain': ['domain:a.com', 'domain:b.com'],
        'outboundTag': 'direct',
      },
    );
    expect(buildRule(RuleMatch.ipCidr, ['10.0.0.0/8'], RulePolicy.block), {
      'ip': ['10.0.0.0/8'],
      'outboundTag': 'block',
    });
    expect(buildRule(RuleMatch.geoip, ['cn'], RulePolicy.direct), {
      'ip': ['geoip:cn'],
      'outboundTag': 'direct',
    });
    expect(buildRule(RuleMatch.port, ['80', '443'], RulePolicy.proxy), {
      'port': '80,443',
      'outboundTag': 'proxy',
    });
  });

  group('testRules', () {
    const rules = [
      {
        'domain': ['geosite:google', 'domain:example.com'],
        'outboundTag': 'direct',
      },
      {
        'domain': ['full:exact.org', 'keyword:tube', r'regexp:^ad\d+\.'],
        'outboundTag': 'block',
      },
      {
        'ip': ['geoip:cn', '10.0.0.0/8', '2001:db8::/32'],
        'outboundTag': 'direct',
      },
      {'port': '443', 'outboundTag': 'block'},
      {'network': 'tcp,udp', 'outboundTag': 'proxy'},
    ];

    test('matches domains by each prefix', () {
      expect(testRules(rules, 'example.com').index, 0);
      expect(testRules(rules, 'www.example.com').index, 0);
      expect(testRules(rules, 'notexample.com').index, 4);
      expect(testRules(rules, 'exact.org').index, 1);
      expect(testRules(rules, 'www.exact.org').index, 4);
      expect(testRules(rules, 'youtube.com').index, 1);
      expect(testRules(rules, 'ad12.example.net').index, 1);
    });

    test('matches addresses by CIDR, IPv4 and IPv6', () {
      expect(testRules(rules, '10.1.2.3').index, 2);
      expect(testRules(rules, '11.1.2.3').index, 4);
      expect(testRules(rules, '2001:db8::1').index, 2);
    });

    test('says when a geo entry was passed over', () {
      expect(testRules(rules, 'example.com').skippedGeo, isTrue);
      expect(testRules(builtInRules, 'baidu.com'), (
        index: null,
        skippedGeo: true,
      ));
    });

    test('a rule with other matchers never matches here', () {
      expect(
        testRules(const [
          {'port': '443', 'outboundTag': 'block'},
        ], 'example.com').index,
        isNull,
      );
    });
  });
}
