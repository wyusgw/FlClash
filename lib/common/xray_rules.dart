import 'dart:convert';
import 'dart:io';

/// Where a rule sends what it matches. A rule set names it by the outbound tag
/// Xray configs conventionally use; any other tag is taken as the proxy.
enum RulePolicy {
  proxy('proxy'),
  direct('direct'),
  block('block');

  const RulePolicy(this.tag);

  final String tag;
}

RulePolicy rulePolicyOf(Map<String, dynamic> rule) {
  return switch (rule['outboundTag']) {
    'direct' || 'freedom' => RulePolicy.direct,
    'block' || 'reject' || 'blackhole' => RulePolicy.block,
    _ => RulePolicy.proxy,
  };
}

/// The rules rule mode routes by until the user picks a rule set: mainland
/// China direct, everything else through the proxy.
const builtInRules = [
  {
    'domain': ['geosite:cn'],
    'outboundTag': 'direct',
  },
  {
    'ip': ['geoip:cn'],
    'outboundTag': 'direct',
  },
];

/// What a hand-written rule matches, with the prefix Xray reads it by.
enum RuleMatch {
  domainSuffix('domain', 'domain:'),
  domain('domain', 'full:'),
  keyword('domain', 'keyword:'),
  regexp('domain', 'regexp:'),
  geosite('domain', 'geosite:'),
  ipCidr('ip', ''),
  geoip('ip', 'geoip:'),
  port('port', '');

  const RuleMatch(this.field, this.prefix);

  final String field;
  final String prefix;
}

const _matcherFields = {
  'domain',
  'ip',
  'port',
  'sourcePort',
  'network',
  'source',
  'sourceIP',
  'user',
  'inboundTag',
  'protocol',
  'attrs',
};

/// A rule matching each of [values] by [match], sent to [policy].
Map<String, dynamic> buildRule(
  RuleMatch match,
  List<String> values,
  RulePolicy policy,
) {
  final matcher = match == RuleMatch.port
      ? values.join(',')
      : [for (final value in values) '${match.prefix}$value'];
  return {match.field: matcher, 'outboundTag': policy.tag};
}

/// The rules in [text], which may be a whole Xray config, its `routing`
/// object, or the rule list itself. Throws a [FormatException] when there is
/// no rule that matches anything.
List<Map<String, dynamic>> parseXrayRules(String text) {
  final decoded = jsonDecode(text);
  final list = switch (decoded) {
    List() => decoded,
    {'routing': {'rules': final List rules}} => rules,
    {'rules': final List rules} => rules,
    _ => throw const FormatException('No routing rules found'),
  };
  final rules = [
    for (final rule in list)
      if (rule is Map && rule.keys.any(_matcherFields.contains))
        Map<String, dynamic>.from(rule),
  ];
  if (rules.isEmpty) {
    throw const FormatException('No routing rules found');
  }
  return rules;
}

/// The result of testing a target against a rule list here, without the
/// core: the first rule that matches, and whether a GeoSite or GeoIP entry,
/// which only the core can read, was passed over on the way.
typedef RuleTestResult = ({int? index, bool skippedGeo});

/// Finds the first rule in [rules] that sends [target], a domain or an IP
/// address, somewhere. Matchers other than domains, IPs and a bare network
/// are not checked, so such rules never match here.
RuleTestResult testRules(List<Map<String, dynamic>> rules, String target) {
  final host = target.trim().toLowerCase();
  final address = InternetAddress.tryParse(host);
  var skippedGeo = false;
  for (final (index, rule) in rules.indexed) {
    final entries = [
      ..._entries(
        rule['domain'],
      ).map((entry) => (field: 'domain', entry: entry)),
      ..._entries(rule['ip']).map((entry) => (field: 'ip', entry: entry)),
    ];
    if (entries.isEmpty) {
      final others = rule.keys.where(_matcherFields.contains).toSet();
      if (others.length == 1 && others.single == 'network') {
        return (index: index, skippedGeo: skippedGeo);
      }
      continue;
    }
    for (final (:field, :entry) in entries) {
      if (entry.startsWith('geosite:') ||
          entry.startsWith('geoip:') ||
          entry.startsWith('ext:')) {
        skippedGeo = true;
        continue;
      }
      final matched = field == 'domain'
          ? address == null && _domainMatches(entry, host)
          : address != null && _cidrContains(entry, address);
      if (matched) {
        return (index: index, skippedGeo: skippedGeo);
      }
    }
  }
  return (index: null, skippedGeo: skippedGeo);
}

List<String> _entries(Object? value) => switch (value) {
  final List list => [for (final item in list) '$item'.toLowerCase()],
  final String text => [text.toLowerCase()],
  _ => const [],
};

bool _domainMatches(String entry, String host) {
  if (entry.startsWith('domain:')) {
    final suffix = entry.substring(7);
    return host == suffix || host.endsWith('.$suffix');
  }
  if (entry.startsWith('full:')) {
    return host == entry.substring(5);
  }
  if (entry.startsWith('regexp:')) {
    return RegExp(entry.substring(7)).hasMatch(host);
  }
  final keyword = entry.startsWith('keyword:') ? entry.substring(8) : entry;
  return host.contains(keyword);
}

bool _cidrContains(String entry, InternetAddress address) {
  final slash = entry.indexOf('/');
  final network = InternetAddress.tryParse(
    slash == -1 ? entry : entry.substring(0, slash),
  );
  if (network == null || network.type != address.type) {
    return false;
  }
  final a = network.rawAddress;
  final b = address.rawAddress;
  final bits = slash == -1
      ? a.length * 8
      : int.tryParse(entry.substring(slash + 1)) ?? a.length * 8;
  for (var i = 0; i < bits; i++) {
    final mask = 0x80 >> (i % 8);
    if (a[i ~/ 8] & mask != b[i ~/ 8] & mask) {
      return false;
    }
  }
  return true;
}
