import 'dart:convert';

import 'package:fl_clash/common/share_link.dart';
import 'package:fl_clash/common/subscription.dart';
import 'package:flutter_test/flutter_test.dart';

const _uuid = 'b831381d-6324-4d53-ad4f-8cda48b30811';
const _pbk = 'AQIDBAUGBwgJCgsMDQ4PEBESExQVFhcYGRobHB0eHyA';

final _links = [
  'vmess://${base64.encode(utf8.encode('{"v":"2","ps":"vm-ws","add":"vm.example.com","port":"443","id":"$_uuid","aid":"0","scy":"auto","net":"ws","type":"none","host":"cdn.example.com","path":"/ws","tls":"tls","sni":"vm.example.com","fp":"chrome"}'))}',
  'vmess://${base64.encode(utf8.encode('{"v":"2","ps":"vm-http","add":"1.2.3.4","port":"80","id":"$_uuid","aid":"0","scy":"aes-128-gcm","net":"tcp","type":"http","host":"a.com,b.com","path":"/p","tls":""}'))}',
  'vless://$_uuid@vl.example.com:443?type=tcp&security=reality&encryption=none&flow=xtls-rprx-vision&sni=www.microsoft.com&fp=chrome&pbk=$_pbk&sid=6ba85179e30d4fc2&spx=%2F#vless reality',
  'vless://$_uuid@vl.example.com:443?type=grpc&serviceName=gs&mode=multi&security=tls&sni=vl.example.com&alpn=h2#grpc',
  'vless://$_uuid@vl.example.com:443?type=xhttp&path=%2Fx&host=h.example.com&mode=auto&security=tls&allowInsecure=1#xhttp',
  'vless://$_uuid@[2001:db8::1]:443?type=httpupgrade&path=%2Fu&security=tls#v6',
  'trojan://p%40ss@tj.example.com:443?security=tls&sni=tj.example.com&type=ws&path=%2Ftj#trojan-ws',
  'ss://${base64.encode(utf8.encode('aes-256-gcm:password'))}@1.2.3.4:8388#ss',
  'ss://${base64.encode(utf8.encode('2022-blake3-aes-128-gcm:a2V5:a2V5'))}@ss.example.com:443#ss2022',
  'hysteria2://auth@hy.example.com:443?sni=hy.example.com&obfs=salamander&obfs-password=obfs&mport=20000-30000&insecure=1#hy2',
  'hysteria://hy1.example.com:443?auth=a&upmbps=50&downmbps=100&peer=hy1.example.com&alpn=hysteria&obfs=xplus&obfsParam=o#hy1',
  'tuic://$_uuid:pw@tu.example.com:443?congestion_control=bbr&alpn=h3&sni=tu.example.com&udp_relay_mode=quic&allow_insecure=1#tuic',
  'anytls://pw@at.example.com:443?sni=at.example.com&insecure=1#anytls',
  'mierus://user:p%40ss@mi.example.com?handshake-mode=HANDSHAKE_NO_WAIT&mtu=1400&multiplexing=MULTIPLEXING_HIGH&port=6666&profile=mieru&protocol=TCP',
  'mierus://user:pass@[2001:db8::1]?port=9998-9999&profile=range&protocol=UDP',
];

void main() {
  for (final link in _links) {
    test(
      'a link survives being shared: ${link.substring(0, link.indexOf(':'))} '
      '${parseShareLink(link)?['tag']}',
      () {
        final outbound = parseShareLink(link);
        expect(outbound, isNotNull, reason: link);

        final shared = nodeShareLink(outbound!);

        expect(shared, isNotNull);
        expect(parseShareLink(shared!), outbound);
      },
    );
  }

  test('an outbound written in the older nested form still has a link', () {
    final outbound = {
      'tag': 'nested',
      'protocol': 'vless',
      'settings': {
        'vnext': [
          {
            'address': 'n.example.com',
            'port': 443,
            'users': [
              {'id': _uuid, 'encryption': 'none'},
            ],
          },
        ],
      },
      'streamSettings': {
        'network': 'ws',
        'security': 'tls',
        'wsSettings': {'path': '/n'},
        'tlsSettings': {'serverName': 'n.example.com'},
      },
    };

    final parsed = parseShareLink(nodeShareLink(outbound)!)!;

    expect(parsed['settings'], {
      'address': 'n.example.com',
      'port': 443,
      'id': _uuid,
      'encryption': 'none',
    });
    expect(parsed['streamSettings']['wsSettings'], {'path': '/n'});
  });

  test('a node with no link form is shared as JSON that reads back', () {
    final outbound = {
      'tag': 'mieru',
      'protocol': 'mieru',
      'settings': {'address': 'm.example.com', 'port': 2999},
    };

    expect(nodeShareLink(outbound), isNull);
    expect(json.decode(nodeShareText(outbound)), {
      'outbounds': [outbound],
    });
  });
}
