import 'dart:async';
import 'dart:convert';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/action.dart';
import 'package:fl_clash/views/profiles/add.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

/// The page of one server of a profile, its protocol and the fields that
/// protocol has, to be changed and saved back into the profile.
class EditServerView extends ConsumerStatefulWidget {
  const EditServerView({
    super.key,
    required this.profile,
    required this.outbound,
    required this.kind,
    required this.values,
  });

  final Profile profile;

  /// The node as it is stored, which the form was read from.
  final Map<String, dynamic> outbound;
  final NodeKind kind;
  final Map<String, String> values;

  @override
  ConsumerState<EditServerView> createState() => _EditServerViewState();
}

class _EditServerViewState extends ConsumerState<EditServerView> {
  late NodeKind _kind = widget.kind;
  late Map<String, String> _values = widget.values;

  Map<String, dynamic>? get _built => buildNodeOutbound(_kind, _values);

  bool get _changed {
    final built = _built;
    return built != null && jsonEncode(built) != jsonEncode(widget.outbound);
  }

  void _setKind(NodeKind kind) {
    if (kind == _kind) return;
    setState(() {
      _values = nodeValuesFor(kind, _values);
      _kind = kind;
    });
  }

  void _setValue(String key, String value) {
    setState(() => _values = {..._values, key: value});
  }

  void _save() {
    final built = _built;
    if (built == null) return;
    Navigator.of(context).pop();
    unawaited(
      ref
          .read(profilesActionProvider.notifier)
          .replaceNode(widget.profile, '${widget.outbound['tag']}', built),
    );
  }

  Future<void> _copy(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    context.showNotifier(
      context.appLocalizations.copySuccess,
      level: MessageLevel.success,
    );
  }

  Future<void> _pickKind() async {
    final picked = await BaseNavigator.push<String>(
      context,
      ChoiceView(
        title: context.appLocalizations.profileType,
        options: [for (final kind in NodeKind.values) nodeKindLabel(kind)],
        selected: nodeKindLabel(_kind),
      ),
    );
    if (picked == null) return;
    _setKind(NodeKind.values.firstWhere((k) => nodeKindLabel(k) == picked));
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final built = _built;
    final link = built == null ? null : buildNodeLink(_kind, _values);
    return GroupedPage(
      title: appLocalizations.editServer,
      onBack: () => Navigator.of(context).maybePop(),
      trailing: GroupedBarAction(
        label: appLocalizations.save,
        tooltip: appLocalizations.save,
        onPressed: _changed ? _save : null,
      ),
      body: GroupedBody(
        children: [
          GroupedSection(
            children: [
              GroupedRow(
                title: appLocalizations.profileType,
                value: nodeKindLabel(_kind),
                chevron: true,
                onTap: _pickKind,
              ),
            ],
          ),
          const SizedBox(height: groupedSectionGap),
          NodeFormFields(
            key: ValueKey(_kind),
            kind: _kind,
            values: _values,
            onChanged: _setValue,
          ),
          const SizedBox(height: groupedSectionGap),
          GroupedSection(
            children: [
              GroupedRow(
                leading: const GroupedIcon(AppGlyphs.code),
                title: appLocalizations.copyJson,
                chevron: true,
                onTap: () => _copy(
                  const JsonEncoder.withIndent('  ').convert(widget.outbound),
                ),
              ),
              if (link != null)
                GroupedRow(
                  leading: const GroupedIcon(AppGlyphs.link),
                  title: appLocalizations.copyLink,
                  chevron: true,
                  onTap: () => _copy(link),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
