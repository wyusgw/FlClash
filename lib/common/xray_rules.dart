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

/// A ready-made rule for the quick config. They are listed in the order they
/// should be read: the narrow ones first, then the services, then the two that
/// sweep up everything left, mainland China direct and the rest abroad by proxy.
enum RulePreset {
  ads,
  httpdns,
  winSpy,
  quic,
  bittorrent,
  lan,
  appleCn,
  googleCn,
  google,
  youtube,
  telegram,
  openai,
  anthropic,
  netflix,
  disney,
  spotify,
  twitter,
  facebook,
  whatsapp,
  github,
  discord,
  tiktok,
  mainlandChina,
  foreign;

  /// The rules this adds, each kept as Xray reads it.
  List<Map<String, dynamic>> get rules => switch (this) {
    ads => [_rule('domain', 'geosite:category-ads-all', 'block')],
    httpdns => [_rule('domain', 'geosite:category-httpdns-cn', 'block')],
    winSpy => [_rule('domain', 'geosite:win-spy', 'block')],
    quic => const [
      {'network': 'udp', 'port': '443', 'outboundTag': 'block'},
    ],
    bittorrent => [_rule('protocol', 'bittorrent', 'direct')],
    lan => [
      _rule('ip', 'geoip:private', 'direct'),
      _rule('domain', 'geosite:private', 'direct'),
    ],
    appleCn => [_rule('domain', 'geosite:apple-cn', 'direct')],
    googleCn => [_rule('domain', 'geosite:google-cn', 'direct')],
    google => [
      _rule('domain', 'geosite:google', 'proxy'),
      _rule('ip', 'geoip:google', 'proxy'),
    ],
    youtube => [_rule('domain', 'geosite:youtube', 'proxy')],
    telegram => [
      _rule('domain', 'geosite:telegram', 'proxy'),
      _rule('ip', 'geoip:telegram', 'proxy'),
    ],
    openai => [_rule('domain', 'geosite:openai', 'proxy')],
    anthropic => [_rule('domain', 'geosite:anthropic', 'proxy')],
    netflix => [
      _rule('domain', 'geosite:netflix', 'proxy'),
      _rule('ip', 'geoip:netflix', 'proxy'),
    ],
    disney => [_rule('domain', 'geosite:disney', 'proxy')],
    spotify => [_rule('domain', 'geosite:spotify', 'proxy')],
    twitter => [
      _rule('domain', 'geosite:twitter', 'proxy'),
      _rule('ip', 'geoip:twitter', 'proxy'),
    ],
    facebook => [
      _rule('domain', 'geosite:facebook', 'proxy'),
      _rule('ip', 'geoip:facebook', 'proxy'),
    ],
    whatsapp => [_rule('domain', 'geosite:whatsapp', 'proxy')],
    github => [_rule('domain', 'geosite:github', 'proxy')],
    discord => [_rule('domain', 'geosite:discord', 'proxy')],
    tiktok => [_rule('domain', 'geosite:tiktok', 'proxy')],
    mainlandChina => builtInRules,
    foreign => [_rule('domain', 'geosite:geolocation-!cn', 'proxy')],
  };

  RulePolicy get policy => rulePolicyOf(rules.first);
}

Map<String, dynamic> _rule(String field, String value, String outboundTag) => {
  field: [value],
  'outboundTag': outboundTag,
};

/// [rules] with those of [presets] put in front, so they decide where both
/// match; a rule already there is not added twice.
List<Map<String, dynamic>> withPresets(
  List<Map<String, dynamic>> rules,
  Iterable<RulePreset> presets,
) {
  final existing = {for (final rule in rules) jsonEncode(rule)};
  final added = <Map<String, dynamic>>[];
  for (final preset in RulePreset.values.where(presets.contains)) {
    for (final rule in preset.rules) {
      if (existing.add(jsonEncode(rule))) {
        added.add(rule);
      }
    }
  }
  return [...added, ...rules];
}

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
