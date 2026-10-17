import 'dart:io';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The URL schemes Xray builds a name server from; anything else must be a
/// plain address it asks over UDP.
const _dnsSchemes = {
  'https',
  'h2c',
  'https+local',
  'h2c+local',
  'tcp',
  'tcp+local',
  'quic+local',
};

bool _isPlainAddress(String value) {
  if (InternetAddress.tryParse(value) != null) return true;
  final uri = Uri.tryParse('udp://$value');
  return uri != null &&
      uri.hasPort &&
      uri.port > 0 &&
      uri.port < 65536 &&
      InternetAddress.tryParse(uri.host) != null;
}

/// Why [value] is not a DNS server Xray can use, or null when it is one.
@visibleForTesting
String? validateDnsServer(String value, AppLocalizations appLocalizations) {
  if (value.isEmpty) {
    return appLocalizations.emptyTip(appLocalizations.dnsServer);
  }
  if (value == 'localhost' || _isPlainAddress(value)) return null;
  final uri = Uri.tryParse(value);
  if (uri != null &&
      _dnsSchemes.contains(uri.scheme.toLowerCase()) &&
      uri.host.isNotEmpty) {
    return null;
  }
  return appLocalizations.dnsServerTip;
}

/// Configure DNS, after the page iOS has for it: Automatic keeps the
/// default servers, Manual lets each list be edited. Nothing is applied until
/// Save, and back leaves the settings as they were.
class DnsView extends ConsumerStatefulWidget {
  const DnsView({super.key});

  @override
  ConsumerState<DnsView> createState() => _DnsViewState();
}

class _DnsViewState extends ConsumerState<DnsView> {
  late final CoreConfig _saved = ref.read(coreSettingProvider);
  late bool _manual =
      !listEquals(_saved.proxyDns, defaultProxyDnsServers) ||
      !listEquals(_saved.directDns, defaultDirectDnsServers);
  late List<String> _proxy = _saved.proxyDns;
  late List<String> _direct = _saved.directDns;

  List<String> get _stagedProxy => _manual ? _proxy : defaultProxyDnsServers;
  List<String> get _stagedDirect => _manual ? _direct : defaultDirectDnsServers;

  bool get _canSave =>
      _stagedProxy.isNotEmpty &&
      _stagedDirect.isNotEmpty &&
      (!listEquals(_stagedProxy, _saved.proxyDns) ||
          !listEquals(_stagedDirect, _saved.directDns));

  void _save() {
    ref
        .read(coreSettingProvider.notifier)
        .update(
          (state) =>
              state.copyWith(proxyDns: _stagedProxy, directDns: _stagedDirect),
        );
    Navigator.of(context).pop();
  }

  Widget _modeRow(String title, bool manual) {
    final palette = GroupedPalette.of(context);
    return GroupedRow(
      key: ValueKey('dns.mode.$manual'),
      title: title,
      trailing: _manual == manual
          ? GlyphIcon(AppGlyphs.check, size: 18, color: palette.accent)
          : null,
      onTap: () => setState(() => _manual = manual),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return GroupedPage(
      title: appLocalizations.configureDns,
      leading: GroupedBarAction(
        label: appLocalizations.cancel,
        tooltip: appLocalizations.cancel,
        onPressed: () => Navigator.of(context).maybePop(),
      ),
      trailing: GroupedBarAction(
        label: appLocalizations.save,
        tooltip: appLocalizations.save,
        onPressed: _canSave ? _save : null,
      ),
      body: GroupedBody(
        children: [
          GroupedSection(
            children: [
              _modeRow(appLocalizations.auto, false),
              _modeRow(appLocalizations.manual, true),
            ],
          ),
          if (_manual) ...[
            const SizedBox(height: groupedSectionGap),
            _DnsServerSection(
              key: const ValueKey('dns.proxy'),
              header: appLocalizations.proxyDns,
              footer: appLocalizations.proxyDnsDesc,
              servers: _proxy,
              onChanged: (servers) => setState(() => _proxy = servers),
            ),
            const SizedBox(height: groupedSectionGap),
            _DnsServerSection(
              key: const ValueKey('dns.direct'),
              header: appLocalizations.directDns,
              footer: appLocalizations.directDnsDesc,
              servers: _direct,
              onChanged: (servers) => setState(() => _direct = servers),
            ),
          ],
        ],
      ),
    );
  }
}

/// One list of servers in the iOS manner: a red minus in front of each that
/// brings up its Delete button, a swipe that does the same, and a green plus
/// row that adds one. The first server is asked first.
class _DnsServerSection extends StatefulWidget {
  const _DnsServerSection({
    super.key,
    required this.header,
    required this.footer,
    required this.servers,
    required this.onChanged,
  });

  final String header;
  final String footer;
  final List<String> servers;
  final ValueChanged<List<String>> onChanged;

  @override
  State<_DnsServerSection> createState() => _DnsServerSectionState();
}

class _DnsServerSectionState extends State<_DnsServerSection> {
  bool _adding = false;
  String? _editing;
  String? _deleting;

  List<String> get _servers => widget.servers;

  void _close() => setState(() {
    _adding = false;
    _editing = null;
  });

  void _delete(String server) {
    setState(() => _deleting = null);
    widget.onChanged([..._servers]..remove(server));
  }

  String? _validate(String value, {String? current}) {
    final appLocalizations = context.appLocalizations;
    final problem = validateDnsServer(value, appLocalizations);
    if (problem != null) return problem;
    if (value != current && _servers.contains(value)) {
      return appLocalizations.existsTip(appLocalizations.dnsServer);
    }
    return null;
  }

  Widget _input({String? server}) {
    return GroupedInputRow(
      key: ValueKey(server ?? #add),
      title: context.appLocalizations.dnsServer,
      value: server ?? '',
      startEditing: true,
      keyboardType: TextInputType.url,
      inputFormatters: [
        FilteringTextInputFormatter.deny(RegExp(r'\s')),
        ...TextInputLimits.limit(TextInputLimits.url),
      ],
      validator: (value) => _validate(value, current: server),
      onSubmitted: (value) {
        widget.onChanged(
          server == null
              ? [..._servers, value]
              : [for (final item in _servers) item == server ? value : item],
        );
        _close();
      },
      onCancel: _close,
    );
  }

  Widget _circle(Glyph glyph, Color color, String tooltip, VoidCallback onTap) {
    return Tooltip(
      message: tooltip,
      child: InkResponse(
        onTap: onTap,
        radius: 16,
        child: GlyphIcon(glyph, fill: 1, size: 24, color: color),
      ),
    );
  }

  Widget _serverRow(String server) {
    final appLocalizations = context.appLocalizations;
    if (_editing == server) return _input(server: server);
    return SwipeActions(
      trailing: [
        SwipeAction(
          label: appLocalizations.delete,
          color: groupedDanger,
          fullSwipe: true,
          slideOut: true,
          onPressed: () => _delete(server),
        ),
      ],
      child: GroupedRow(
        key: ValueKey('dns.server.$server'),
        title: server,
        leading: _circle(
          AppGlyphs.removeCircle,
          groupedDanger,
          appLocalizations.delete,
          () => setState(() => _deleting = _deleting == server ? null : server),
        ),
        trailing: _deleting == server
            ? FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: groupedDanger,
                  foregroundColor: Colors.white,
                  visualDensity: VisualDensity.compact,
                ),
                onPressed: () => _delete(server),
                child: Text(appLocalizations.delete),
              )
            : null,
        onTap: () => setState(() {
          _deleting = null;
          _adding = false;
          _editing = server;
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return GroupedSection(
      header: widget.header,
      footer: widget.footer,
      children: [
        for (final server in _servers) _serverRow(server),
        if (_adding)
          _input()
        else
          GroupedRow(
            key: const ValueKey('dns.add'),
            title: appLocalizations.addServer,
            leading: _circle(
              AppGlyphs.addCircle,
              swipeActionGo,
              appLocalizations.addServer,
              () => setState(() => _adding = true),
            ),
            onTap: () => setState(() {
              _deleting = null;
              _editing = null;
              _adding = true;
            }),
          ),
      ],
    );
  }
}
