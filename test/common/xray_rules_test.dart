import 'dart:convert';

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

  group('withPresets', () {
    test('puts the presets ahead of the rules, narrow ones first', () {
      const own = {
        'domain': ['domain:example.com'],
        'outboundTag': 'direct',
      };

      final rules = withPresets(
        const [own],
        const [RulePreset.mainlandChina, RulePreset.ads],
      );

      expect(rules, [
        ...RulePreset.ads.rules,
        ...RulePreset.mainlandChina.rules,
        own,
      ]);
    });

    test('adds a rule that is there already only once', () {
      final rules = withPresets(builtInRules, const [
        RulePreset.mainlandChina,
        RulePreset.lan,
      ]);

      expect(rules, [...RulePreset.lan.rules, ...builtInRules]);
    });

    test('every preset says where it sends traffic', () {
      expect(RulePreset.ads.policy, RulePolicy.block);
      expect(RulePreset.httpdns.policy, RulePolicy.block);
      expect(RulePreset.winSpy.policy, RulePolicy.block);
      expect(RulePreset.quic.policy, RulePolicy.block);
      expect(RulePreset.lan.policy, RulePolicy.direct);
      expect(RulePreset.google.policy, RulePolicy.proxy);
      expect(RulePreset.mainlandChina.policy, RulePolicy.direct);
      expect(RulePreset.foreign.policy, RulePolicy.proxy);
    });

    test('every preset is a rule Xray reads, sent one way, none twice', () {
      final seen = <String>{};
      for (final preset in RulePreset.values) {
        expect(preset.rules, isNotEmpty, reason: preset.name);
        for (final rule in preset.rules) {
          expect(rulePolicyOf(rule), preset.policy, reason: preset.name);
          expect(
            rule.entries.any(
              (entry) =>
                  entry.key != 'outboundTag' &&
                  switch (entry.value) {
                    final List list => list.isNotEmpty,
                    final String text => text.isNotEmpty,
                    _ => false,
                  },
            ),
            isTrue,
            reason: '${preset.name} matches something',
          );
          if (preset != RulePreset.mainlandChina) {
            expect(seen.add(jsonEncode(rule)), isTrue, reason: preset.name);
          }
        }
      }
    });

    test('the two sweeping presets come last, so the narrow ones win', () {
      expect(RulePreset.values.reversed.take(2), [
        RulePreset.foreign,
        RulePreset.mainlandChina,
      ]);
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
