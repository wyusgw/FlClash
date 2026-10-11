import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/pages/scan.dart';
import 'package:fl_clash/providers/action.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/views/profiles/region.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void showAddProfilePage(BuildContext context) {
  unawaited(BaseNavigator.push(context, const AddProfileView()));
}

Future<void> scanProfileQrCode(BuildContext context, WidgetRef ref) async {
  final profilesAction = ref.read(profilesActionProvider.notifier);
  if (system.isDesktop) {
    unawaited(profilesAction.addProfileFormQrCode());
    return;
  }
  final url = await BaseNavigator.push(context, const ScanPage());
  if (url != null) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(profilesAction.addProfileFormURL(url));
    });
  }
}

String nodeKindLabel(NodeKind kind) => switch (kind) {
  NodeKind.shadowsocks => 'Shadowsocks',
  NodeKind.vmess => 'VMess',
  NodeKind.vless => 'VLESS',
  NodeKind.socks => 'Socks5',
  NodeKind.http => 'HTTP',
  NodeKind.trojan => 'Trojan',
  NodeKind.hysteria => 'Hysteria',
  NodeKind.hysteria2 => 'Hysteria2',
  NodeKind.tuic => 'TUIC',
  NodeKind.anytls => 'AnyTLS',
  NodeKind.mieru => 'Mieru',
};

String nodeFieldLabel(AppLocalizations l, String key) => switch (key) {
  'address' => l.address,
  'port' => l.port,
  'password' => l.password,
  'method' => l.algorithm,
  'uuid' => l.uuid,
  'security' => l.security,
  'network' => l.network,
  'path' => l.path,
  'host' => l.host,
  'serviceName' => l.serviceName,
  'tls' => 'TLS',
  'sni' => l.serverName,
  'allowInsecure' => l.allowInsecure,
  'flow' => l.flow,
  'fingerprint' => l.fingerprint,
  'publicKey' => l.publicKey,
  'shortId' => l.shortId,
  'congestion' => l.congestionControl,
  'obfsPassword' => l.obfsPassword,
  'uploadSpeed' => l.uploadSpeed,
  'downloadSpeed' => l.downloadSpeed,
  'remark' => l.name,
  'username' => l.username,
  'transport' => l.transportMode,
  'multiplexing' => l.multiplexing,
  'handshake' => l.handshake,
  _ => key,
};

/// The page that takes a server: a subscription by its address, or one
/// protocol by the fields it needs; either way a QR code and a file are the
/// other ways in.
class AddProfileView extends ConsumerStatefulWidget {
  const AddProfileView({super.key});

  @override
  ConsumerState<AddProfileView> createState() => _AddProfileViewState();
}

class _AddProfileViewState extends ConsumerState<AddProfileView> {
  final _url = TextEditingController();
  final _label = TextEditingController();
  NodeKind? _kind;
  Map<String, String> _values = {};

  bool get _valid {
    final kind = _kind;
    return kind == null
        ? _url.text.trim().isUrl
        : nodeFormProblem(kind, _values) == null;
  }

  @override
  void dispose() {
    _url.dispose();
    _label.dispose();
    super.dispose();
  }

  void _setKind(NodeKind? kind) {
    setState(() {
      _kind = kind;
      _values = kind == null ? {} : nodeDefaults(kind);
    });
  }

  void _setValue(String key, String value) {
    setState(() => _values = {..._values, key: value});
  }

  void _save() {
    final profilesAction = ref.read(profilesActionProvider.notifier);
    final kind = _kind;
    if (kind == null) {
      final label = _label.text.trim();
      final url = _url.text.trim();
      Navigator.of(context).pop();
      unawaited(
        profilesAction.addProfileFormURL(
          url,
          label: label.isEmpty ? null : label,
        ),
      );
      return;
    }
    final outbound = buildNodeOutbound(kind, _values);
    if (outbound == null) {
      dialogs.showNotifier(
        context.appLocalizations.nodeInvalid,
        level: MessageLevel.error,
      );
      return;
    }
    Navigator.of(context).pop();
    unawaited(profilesAction.addManualNode(outbound));
  }

  void _addFile() {
    final profilesAction = ref.read(profilesActionProvider.notifier);
    Navigator.of(context).pop();
    unawaited(profilesAction.addProfileFormFile());
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final kind = _kind;
    return GroupedPage(
      title: appLocalizations.addProfile,
      onBack: () => Navigator.of(context).maybePop(),
      trailing: GroupedBarAction(
        label: appLocalizations.save,
        tooltip: appLocalizations.save,
        onPressed: _valid ? _save : null,
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          groupedPageInset,
          13,
          groupedPageInset,
          20 + BottomInsetScope.of(context),
        ),
        children: [
          GroupedSection(
            children: [
              GroupedRow(
                title: appLocalizations.profileType,
                value: kind == null
                    ? appLocalizations.subscribe
                    : nodeKindLabel(kind),
                chevron: true,
                onTap: () => BaseNavigator.push(
                  context,
                  ProfileTypeView(selected: kind, onSelected: _setKind),
                ),
              ),
            ],
          ),
          const SizedBox(height: groupedSectionGap),
          if (kind == null)
            GroupedSection(
              children: [
                GroupedFieldRow(
                  label: appLocalizations.url,
                  hint: appLocalizations.required,
                  controller: _url,
                  keyboardType: TextInputType.url,
                  inputFormatters: TextInputLimits.limit(TextInputLimits.url),
                  onChanged: (_) => setState(() {}),
                ),
                GroupedFieldRow(
                  label: appLocalizations.name,
                  hint: appLocalizations.optional,
                  controller: _label,
                ),
              ],
            )
          else
            NodeFormFields(
              key: ValueKey(kind),
              kind: kind,
              values: _values,
              onChanged: _setValue,
            ),
          const SizedBox(height: groupedSectionGap),
          GroupedSection(
            children: [
              GroupedRow(
                leading: const GroupedIcon(AppGlyphs.scanFrame),
                title: appLocalizations.qrcode,
                chevron: true,
                onTap: () {
                  Navigator.of(context).pop();
                  unawaited(scanProfileQrCode(context, ref));
                },
              ),
              GroupedRow(
                leading: const GroupedIcon(AppGlyphs.importFile),
                title: appLocalizations.file,
                chevron: true,
                onTap: _addFile,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// The kinds of profile there are: a subscription, or one server of a
/// protocol. Given [onSelected] it picks one; without it, it only shows the
/// kind a profile already is.
class ProfileTypeView extends StatelessWidget {
  const ProfileTypeView({
    super.key,
    this.isFile = false,
    this.selected,
    this.onSelected,
  });

  final bool isFile;
  final NodeKind? selected;
  final ValueChanged<NodeKind?>? onSelected;

  void _pick(BuildContext context, NodeKind? kind) {
    onSelected?.call(kind);
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final palette = GroupedPalette.of(context);
    final picking = onSelected != null;
    Widget? check(bool on) =>
        on ? GlyphIcon(AppGlyphs.check, size: 18, color: palette.icon) : null;
    return GroupedPage(
      title: appLocalizations.profileType,
      onBack: () => Navigator.of(context).maybePop(),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          groupedPageInset,
          13,
          groupedPageInset,
          20 + BottomInsetScope.of(context),
        ),
        children: [
          GroupedSection(
            children: [
              GroupedRow(
                title: isFile
                    ? appLocalizations.file
                    : appLocalizations.subscribe,
                subtitle: isFile ? null : appLocalizations.subscribeDesc,
                trailing: check(!picking || selected == null),
                onTap: () => picking
                    ? _pick(context, null)
                    : Navigator.of(context).maybePop(),
              ),
            ],
          ),
          if (picking) ...[
            const SizedBox(height: groupedSectionGap),
            GroupedSection(
              header: appLocalizations.chooseType,
              children: [
                for (final kind in NodeKind.values)
                  GroupedRow(
                    key: ValueKey(kind),
                    title: nodeKindLabel(kind),
                    trailing: check(kind == selected),
                    onTap: () => _pick(context, kind),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// A page of options with the chosen one checked; picking one closes it and
/// hands the option back.
class ChoiceView extends StatelessWidget {
  const ChoiceView({
    super.key,
    required this.title,
    required this.options,
    required this.selected,
  });

  final String title;
  final List<String> options;
  final String selected;

  @override
  Widget build(BuildContext context) {
    final palette = GroupedPalette.of(context);
    return GroupedPage(
      title: title,
      onBack: () => Navigator.of(context).maybePop(),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          groupedPageInset,
          13,
          groupedPageInset,
          20 + BottomInsetScope.of(context),
        ),
        children: [
          GroupedSection(
            children: [
              for (final option in options)
                GroupedRow(
                  key: ValueKey(option),
                  title: option,
                  trailing: option == selected
                      ? GlyphIcon(
                          AppGlyphs.check,
                          size: 18,
                          color: palette.icon,
                        )
                      : null,
                  onTap: () => Navigator.of(context).pop(option),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// The inputs of one protocol's server form, in a grouped card. It keeps the
/// text being typed; [values] is what the parent holds of it.
class NodeFormFields extends ConsumerStatefulWidget {
  const NodeFormFields({
    super.key,
    required this.kind,
    required this.values,
    required this.onChanged,
  });

  final NodeKind kind;
  final Map<String, String> values;
  final void Function(String key, String value) onChanged;

  @override
  ConsumerState<NodeFormFields> createState() => _NodeFormFieldsState();
}

class _NodeFormFieldsState extends ConsumerState<NodeFormFields> {
  static const _settle = Duration(milliseconds: 800);

  final _controllers = <String, TextEditingController>{};
  final _revealed = <String>{};

  /// The address once typing has paused on it, so that the country is asked of
  /// the GeoIP service for an address and not for each letter of one.
  String _askedHost = '';
  Timer? _settling;

  @override
  void initState() {
    super.initState();
    _askedHost = widget.values['address']?.trim() ?? '';
  }

  @override
  void didUpdateWidget(covariant NodeFormFields oldWidget) {
    super.didUpdateWidget(oldWidget);
    final address = widget.values['address']?.trim() ?? '';
    if (address != (oldWidget.values['address']?.trim() ?? '')) {
      _settling?.cancel();
      _settling = Timer(_settle, () {
        if (mounted) setState(() => _askedHost = address);
      });
    }
  }

  @override
  void dispose() {
    _settling?.cancel();
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Map<String, String> get _values => widget.values;

  /// What the server's name, then where its address is, then the address
  /// itself point at.
  String? get _detected {
    final named = nodeRegionCode(_values['remark'] ?? '');
    if (named != null) return named;
    final host = _askedHost;
    if (host.isNotEmpty) {
      final located = ref.watch(nodeGeoRegionProvider(host)).value;
      if (located != null) return located;
    }
    return nodeRegionCode(_values['address'] ?? '');
  }

  Widget _regionButton() {
    final chosen = _values['region'] ?? '';
    final detected = _detected;
    return Tooltip(
      message: context.appLocalizations.flag,
      child: InkResponse(
        key: const ValueKey('field.region'),
        radius: 16,
        onTap: () async {
          final picked = await BaseNavigator.push<String>(
            context,
            RegionView(selected: chosen, detected: detected),
          );
          if (picked != null) _setValue('region', picked);
        },
        child: RegionFlag(code: chosen.isEmpty ? detected : chosen),
      ),
    );
  }

  void _setValue(String key, String value) => widget.onChanged(key, value);

  Widget _field(NodeField field) {
    final appLocalizations = context.appLocalizations;
    final palette = GroupedPalette.of(context);
    final label = nodeFieldLabel(appLocalizations, field.key);
    switch (field.type) {
      case NodeFieldType.text:
      case NodeFieldType.secret:
      case NodeFieldType.number:
        final secret = field.type == NodeFieldType.secret;
        final revealed = _revealed.contains(field.key);
        final controller = _controllers.putIfAbsent(
          field.key,
          () => TextEditingController(text: _values[field.key] ?? ''),
        );
        return GroupedFieldRow(
          key: ValueKey('field.${field.key}'),
          label: label,
          hint: field.required
              ? appLocalizations.required
              : appLocalizations.optional,
          controller: controller,
          obscure: secret && !revealed,
          keyboardType: field.type == NodeFieldType.number
              ? TextInputType.number
              : null,
          inputFormatters: field.type == NodeFieldType.number
              ? [FilteringTextInputFormatter.digitsOnly]
              : null,
          trailing: field.key == 'address'
              ? _regionButton()
              : secret
              ? InkResponse(
                  onTap: () => setState(() {
                    if (!_revealed.add(field.key)) _revealed.remove(field.key);
                  }),
                  radius: 14,
                  child: GlyphIcon(
                    revealed ? AppGlyphs.eyeOff : AppGlyphs.eye,
                    size: 19,
                    color: palette.secondary,
                  ),
                )
              : null,
          onChanged: (value) => _setValue(field.key, value),
        );
      case NodeFieldType.choice:
        return GroupedRow(
          key: ValueKey('field.${field.key}'),
          title: label,
          value: _values[field.key],
          chevron: true,
          onTap: () async {
            final picked = await BaseNavigator.push<String>(
              context,
              ChoiceView(
                title: label,
                options: field.options,
                selected: _values[field.key] ?? field.initial,
              ),
            );
            if (picked != null) _setValue(field.key, picked);
          },
        );
      case NodeFieldType.toggle:
        return GroupedRow(
          key: ValueKey('field.${field.key}'),
          title: label,
          trailing: GroupedSwitch(
            value: _values[field.key] == 'true',
            onChanged: (value) => _setValue(field.key, '$value'),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GroupedSection(
      children: [
        for (final field in nodeFields(widget.kind))
          if (field.visible(_values)) _field(field),
      ],
    );
  }
}
