import 'dart:async';
import 'dart:convert';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/pages/editor.dart';
import 'package:fl_clash/pages/scan.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/providers/state.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

const _pagePadding = EdgeInsets.fromLTRB(
  groupedPageInset,
  13,
  groupedPageInset,
  20,
);

String rulePolicyLabel(AppLocalizations l, RulePolicy policy) =>
    switch (policy) {
      RulePolicy.proxy => l.policyProxy,
      RulePolicy.direct => l.policyDirect,
      RulePolicy.block => l.policyBlock,
    };

String ruleMatchLabel(AppLocalizations l, RuleMatch match) => switch (match) {
  RuleMatch.domainSuffix => l.matchDomainSuffix,
  RuleMatch.domain => l.matchDomain,
  RuleMatch.keyword => l.matchKeyword,
  RuleMatch.regexp => l.matchRegexp,
  RuleMatch.geosite => 'GeoSite',
  RuleMatch.ipCidr => 'IP-CIDR',
  RuleMatch.geoip => 'GeoIP',
  RuleMatch.port => l.port,
};

/// One line for what [rule] matches: its first matcher's values, with how
/// many more it holds.
String describeRule(Map<String, dynamic> rule) {
  for (final field in ['domain', 'ip', 'port', 'network', 'protocol']) {
    final value = rule[field];
    if (value is List && value.isNotEmpty) {
      final more = value.length > 1 ? ' +${value.length - 1}' : '';
      return '${value.first}$more';
    }
    if (value is String && value.isNotEmpty) {
      return '$field: $value';
    }
  }
  return jsonEncode(rule);
}

const _builtInDefault = RuleSet(id: defaultRuleSetId, rules: builtInRules);

/// The default config as stored, or the built-in rules before its first edit.
RuleSet _defaultOf(List<RuleSet> sets) =>
    sets.where((set) => set.id == defaultRuleSetId).firstOrNull ??
    _builtInDefault;

RuleSet? _setOf(List<RuleSet> sets, int id) => id == defaultRuleSetId
    ? _defaultOf(sets)
    : sets.where((set) => set.id == id).firstOrNull;

String _labelOf(AppLocalizations l, RuleSet set) =>
    set.id == defaultRuleSetId && set.label.isEmpty
    ? l.builtInRules
    : set.label;

void _updateSet(WidgetRef ref, int id, RuleSet Function(RuleSet set) update) {
  ref.read(ruleSetsProvider.notifier).update((sets) {
    if (id == defaultRuleSetId && !sets.any((set) => set.id == id)) {
      return [update(_builtInDefault), ...sets];
    }
    return [for (final set in sets) set.id == id ? update(set) : set];
  });
}

Future<List<Map<String, dynamic>>> _download(String url) async {
  final response = await request.getTextResponseForUrl(url);
  return parseXrayRules(response.data ?? '');
}

void _showRulesError(BuildContext context, Object error) {
  context.showNotifier(
    error is FormatException
        ? context.appLocalizations.rulesInvalid
        : userFacingErrorMessage(error, context.appLocalizations),
    level: MessageLevel.error,
  );
}

/// Drops a rule config, falling back to the built-in rules if it was in use.
void _deleteRuleSet(WidgetRef ref, int id) {
  if (ref.read(currentRuleSetIdProvider) == id) {
    ref.read(currentRuleSetIdProvider.notifier).value = null;
  }
  ref
      .read(ruleSetsProvider.notifier)
      .update((sets) => [...sets.where((set) => set.id != id)]);
}

void _keep(WidgetRef ref, RuleSet set) {
  ref.read(ruleSetsProvider.notifier).update((sets) => [...sets, set]);
}

/// Downloads the rule set at [url] and keeps it; null when that failed, which
/// has been said.
Future<RuleSet?> _addDownloaded(
  BuildContext context,
  WidgetRef ref,
  String url, {
  String label = '',
}) async {
  try {
    final rules = await _download(url);
    final set = RuleSet(
      id: snowflake.id,
      label: label.isEmpty ? Uri.parse(url).host : label,
      url: url,
      lastUpdateDate: DateTime.now(),
      rules: rules,
    );
    _keep(ref, set);
    return set;
  } catch (error) {
    if (context.mounted) _showRulesError(context, error);
    return null;
  }
}

/// Keeps the rule set in a file the user picks; null when none was picked or
/// it held no rules, which has been said.
Future<RuleSet?> _addFromFile(
  BuildContext context,
  WidgetRef ref, {
  String label = '',
}) async {
  final file = await globalState.safeRun(picker.pickerFile);
  if (file == null) return null;
  try {
    final rules = parseXrayRules(utf8.decode(await file.readBytes()));
    final set = RuleSet(
      id: snowflake.id,
      label: label.isEmpty ? file.name : label,
      lastUpdateDate: DateTime.now(),
      rules: rules,
    );
    _keep(ref, set);
    return set;
  } catch (error) {
    if (context.mounted) _showRulesError(context, error);
    return null;
  }
}

String _ruleSetDetail(RuleSet set) {
  final kilobytes = utf8.encode(jsonEncode(set.rules)).length / 1024;
  final size = '${kilobytes.toStringAsFixed(1)}K';
  final date = set.lastUpdateDate;
  return date == null ? size : '${date.show} - $size';
}

const _defaultDot = Color(0xFFFF9F0A);
const _dotSize = 7.0;

/// The rule configs: restoring the built-in one, importing, testing, then
/// every local config with a dot on the default and a check on the one in use.
class RulesView extends ConsumerWidget {
  const RulesView({super.key});

  Future<void> _scan(BuildContext context, WidgetRef ref) async {
    final String? url = system.isDesktop
        ? await globalState.safeRun<String?>(picker.pickerConfigQRCode)
        : await BaseNavigator.push<String>(context, const ScanPage());
    if (url == null || !context.mounted) return;
    await _addDownloaded(context, ref, url);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final palette = GroupedPalette.of(context);
    final sets = ref.watch(ruleSetsProvider);
    final currentId = ref.watch(currentRuleSetIdProvider);
    final check = GlyphIcon(AppGlyphs.check, size: 18, color: palette.accent);
    void select(int? id) =>
        ref.read(currentRuleSetIdProvider.notifier).value = id;
    return GroupedPage(
      title: appLocalizations.profiles,
      leading: GroupedBarAction(
        glyph: AppGlyphs.scanFrame,
        tooltip: appLocalizations.qrcode,
        onPressed: () => unawaited(_scan(context, ref)),
      ),
      trailing: GroupedBarAction(
        glyph: AppGlyphs.add,
        tooltip: appLocalizations.addRuleSet,
        onPressed: () => BaseNavigator.push(context, const AddRuleSetView()),
      ),
      body: ListView(
        padding: _pagePadding.copyWith(
          bottom: _pagePadding.bottom + BottomInsetScope.of(context),
        ),
        children: [
          GroupedSection(
            children: [
              GroupedRow(
                leading: const GroupedIcon(AppGlyphs.undo),
                title: appLocalizations.restoreDefaultRules,
                chevron: true,
                onTap: () {
                  _updateSet(
                    ref,
                    defaultRuleSetId,
                    (set) => set.copyWith(
                      rules: builtInRules,
                      lastUpdateDate: DateTime.now(),
                    ),
                  );
                  select(null);
                },
              ),
              GroupedRow(
                leading: const GroupedIcon(AppGlyphs.cloudDownload),
                title: appLocalizations.importEllipsis,
                chevron: true,
                onTap: () => unawaited(_addFromFile(context, ref)),
              ),
              GroupedRow(
                leading: const GroupedIcon(AppGlyphs.target),
                title: appLocalizations.testRules,
                chevron: true,
                onTap: () => BaseNavigator.push(context, const TestRulesView()),
              ),
            ],
          ),
          const SizedBox(height: groupedSectionGap),
          GroupedSection(
            header: appLocalizations.localFiles,
            footer:
                '${appLocalizations.rulesLegend} '
                '${appLocalizations.rulesFooter}',
            children: [
              for (final set in [
                _defaultOf(sets),
                ...sets.where((set) => set.id != defaultRuleSetId),
              ])
                _RuleSetMenuTarget(
                  key: ValueKey(set.id),
                  ruleSet: set,
                  child: GroupedRow(
                    leading: set.id == defaultRuleSetId
                        ? const DecoratedBox(
                            decoration: ShapeDecoration(
                              shape: AppShape.circle,
                              color: _defaultDot,
                            ),
                            child: SizedBox.square(dimension: _dotSize),
                          )
                        : const SizedBox.square(dimension: _dotSize),
                    leadingWidth: _dotSize,
                    title: _labelOf(appLocalizations, set),
                    subtitle: _ruleSetDetail(set),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 6,
                      children: [
                        if (set.id == (currentId ?? defaultRuleSetId)) check,
                        Tooltip(
                          message: appLocalizations.edit,
                          child: InkResponse(
                            onTap: () => BaseNavigator.push(
                              context,
                              RuleSetView(id: set.id),
                            ),
                            radius: 16,
                            splashFactory: NoSplash.splashFactory,
                            hoverColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            child: GlyphIcon(
                              AppGlyphs.info,
                              size: 21,
                              color: palette.accent,
                            ),
                          ),
                        ),
                      ],
                    ),
                    onTap: () =>
                        select(set.id == defaultRuleSetId ? null : set.id),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

enum _RuleSetAction { rename, edit, editText, delete }

/// Opens a rule config's menu where it was asked for: a right click, or a
/// long press.
class _RuleSetMenuTarget extends ConsumerWidget {
  const _RuleSetMenuTarget({
    super.key,
    required this.ruleSet,
    required this.child,
  });

  final RuleSet ruleSet;
  final Widget child;

  Future<void> _rename(BuildContext context, WidgetRef ref) async {
    final appLocalizations = context.appLocalizations;
    final value = await dialogs.showCommonDialog<String>(
      child: InputDialog(
        title: appLocalizations.rename,
        value: _labelOf(appLocalizations, ruleSet),
        validator: (value) => value == null || value.trim().isEmpty
            ? appLocalizations.required
            : null,
      ),
    );
    final label = value?.trim();
    if (label == null || label.isEmpty) return;
    _updateSet(ref, ruleSet.id, (set) => set.copyWith(label: label));
  }

  void _editText(BuildContext context, WidgetRef ref) {
    final text = const JsonEncoder.withIndent(
      '  ',
    ).convert({'rules': ruleSet.rules});
    unawaited(
      BaseNavigator.push(
        context,
        EditorPage(
          title: _labelOf(context.appLocalizations, ruleSet),
          content: text,
          onSave: (context, _, content) {
            try {
              final rules = parseXrayRules(content);
              _updateSet(ref, ruleSet.id, (set) => set.copyWith(rules: rules));
              Navigator.of(context).pop();
            } catch (error) {
              _showRulesError(context, error);
            }
          },
        ),
      ),
    );
  }

  Future<void> _open(
    BuildContext context,
    WidgetRef ref,
    Offset position,
  ) async {
    final appLocalizations = context.appLocalizations;
    final overlay =
        Overlay.of(context).context.findRenderObject()! as RenderBox;
    final chosen = await showMenu<_RuleSetAction>(
      context: context,
      position: RelativeRect.fromRect(
        position & const Size(1, 1),
        Offset.zero & overlay.size,
      ),
      items: [
        PopupMenuItem(
          value: _RuleSetAction.rename,
          height: 30,
          child: Text(appLocalizations.rename),
        ),
        PopupMenuItem(
          value: _RuleSetAction.edit,
          height: 30,
          child: Text(appLocalizations.editRuleSet),
        ),
        PopupMenuItem(
          value: _RuleSetAction.editText,
          height: 30,
          child: Text(appLocalizations.editPlainText),
        ),
        if (ruleSet.id != defaultRuleSetId) ...[
          const PopupMenuDivider(height: 1),
          PopupMenuItem(
            value: _RuleSetAction.delete,
            height: 30,
            child: Text(
              appLocalizations.deleteRuleSet,
              style: const TextStyle(color: groupedDanger),
            ),
          ),
        ],
      ],
    );
    if (chosen == null || !context.mounted) return;
    switch (chosen) {
      case _RuleSetAction.rename:
        await _rename(context, ref);
      case _RuleSetAction.edit:
        unawaited(BaseNavigator.push(context, RuleSetView(id: ruleSet.id)));
      case _RuleSetAction.editText:
        _editText(context, ref);
      case _RuleSetAction.delete:
        _deleteRuleSet(ref, ruleSet.id);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onSecondaryTapDown: (details) =>
          unawaited(_open(context, ref, details.globalPosition)),
      onLongPressStart: (details) =>
          unawaited(_open(context, ref, details.globalPosition)),
      child: child,
    );
  }
}

/// Says which rule of the config in use a domain or an IP meets, as far as it
/// can be told without the core.
class TestRulesView extends ConsumerStatefulWidget {
  const TestRulesView({super.key});

  @override
  ConsumerState<TestRulesView> createState() => _TestRulesViewState();
}

class _TestRulesViewState extends ConsumerState<TestRulesView> {
  final _target = TextEditingController();

  @override
  void dispose() {
    _target.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final active = ref.watch(activeRulesProvider);
    final rules = active.isEmpty ? builtInRules : active;
    final target = _target.text.trim();
    final result = target.isEmpty ? null : testRules(rules, target);
    final index = result?.index;
    return GroupedPage(
      title: appLocalizations.testRules,
      onBack: () => Navigator.of(context).maybePop(),
      body: ListView(
        padding: _pagePadding,
        children: [
          GroupedSection(
            children: [
              GroupedFieldRow(
                label: appLocalizations.testRulesHint,
                hint: 'example.com',
                controller: _target,
                keyboardType: TextInputType.url,
                onChanged: (_) => setState(() {}),
              ),
            ],
          ),
          if (result != null) ...[
            const SizedBox(height: groupedSectionGap),
            GroupedSection(
              header: appLocalizations.testRulesMatched,
              footer: result.skippedGeo
                  ? appLocalizations.testRulesGeoNote
                  : null,
              children: [
                if (index == null)
                  GroupedRow(
                    title: appLocalizations.testRulesNoMatch,
                    value: appLocalizations.policyProxy,
                  )
                else
                  GroupedRow(
                    title: describeRule(rules[index]),
                    value: rulePolicyLabel(
                      appLocalizations,
                      rulePolicyOf(rules[index]),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Takes a new rule set: empty to fill by hand, from a file, or downloaded.
class AddRuleSetView extends ConsumerStatefulWidget {
  const AddRuleSetView({super.key});

  @override
  ConsumerState<AddRuleSetView> createState() => _AddRuleSetViewState();
}

class _AddRuleSetViewState extends ConsumerState<AddRuleSetView> {
  final _label = TextEditingController();
  final _url = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _label.dispose();
    _url.dispose();
    super.dispose();
  }

  bool get _valid {
    final url = _url.text.trim();
    return !_busy && (url.isEmpty ? _label.text.trim().isNotEmpty : url.isUrl);
  }

  void _open(RuleSet? set) {
    if (set == null || !mounted) return;
    Navigator.of(context).pop();
    unawaited(BaseNavigator.push(context, RuleSetView(id: set.id)));
  }

  Future<void> _save() async {
    final url = _url.text.trim();
    final label = _label.text.trim();
    if (url.isEmpty) {
      final set = RuleSet(id: snowflake.id, label: label);
      _keep(ref, set);
      _open(set);
      return;
    }
    setState(() => _busy = true);
    final set = await _addDownloaded(context, ref, url, label: label);
    if (!mounted) return;
    setState(() => _busy = false);
    _open(set);
  }

  Future<void> _importFile() async {
    _open(await _addFromFile(context, ref, label: _label.text.trim()));
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return GroupedPage(
      title: appLocalizations.addRuleSet,
      onBack: () => Navigator.of(context).maybePop(),
      trailing: GroupedBarAction(
        label: appLocalizations.save,
        tooltip: appLocalizations.save,
        onPressed: _valid ? () => unawaited(_save()) : null,
      ),
      body: ListView(
        padding: _pagePadding,
        children: [
          GroupedSection(
            footer: appLocalizations.addRuleSetDesc,
            children: [
              GroupedFieldRow(
                label: appLocalizations.name,
                hint: appLocalizations.required,
                controller: _label,
                onChanged: (_) => setState(() {}),
              ),
              GroupedFieldRow(
                label: appLocalizations.url,
                hint: appLocalizations.optional,
                controller: _url,
                keyboardType: TextInputType.url,
                inputFormatters: TextInputLimits.limit(TextInputLimits.url),
                onChanged: (_) => setState(() {}),
              ),
            ],
          ),
          const SizedBox(height: groupedSectionGap),
          GroupedSection(
            children: [
              GroupedRow(
                leading: const GroupedIcon(AppGlyphs.importFile),
                title: appLocalizations.importFile,
                chevron: true,
                onTap: _busy ? null : () => unawaited(_importFile()),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// One rule set: its name, its rules each with where it sends traffic, and,
/// for a downloaded one, an update from where it came.
class RuleSetView extends ConsumerStatefulWidget {
  const RuleSetView({super.key, required this.id});

  final int id;

  @override
  ConsumerState<RuleSetView> createState() => _RuleSetViewState();
}

class _RuleSetViewState extends ConsumerState<RuleSetView> {
  bool _updating = false;

  Future<void> _update(String url) async {
    setState(() => _updating = true);
    try {
      final rules = await _download(url);
      _updateSet(
        ref,
        widget.id,
        (set) => set.copyWith(rules: rules, lastUpdateDate: DateTime.now()),
      );
    } catch (error) {
      if (mounted) _showRulesError(context, error);
    } finally {
      if (mounted) setState(() => _updating = false);
    }
  }

  void _removeRule(int index) {
    _updateSet(
      ref,
      widget.id,
      (set) => set.copyWith(rules: [...set.rules]..removeAt(index)),
    );
  }

  void _delete() {
    _deleteRuleSet(ref, widget.id);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final palette = GroupedPalette.of(context);
    final set = ref.watch(
      ruleSetsProvider.select((sets) => _setOf(sets, widget.id)),
    );
    if (set == null) {
      return const SizedBox.shrink();
    }
    final url = set.url;
    final label = _labelOf(appLocalizations, set);
    return GroupedPage(
      title: label,
      onBack: () => Navigator.of(context).maybePop(),
      trailing: GroupedBarAction(
        glyph: AppGlyphs.add,
        tooltip: appLocalizations.addRule,
        onPressed: () =>
            BaseNavigator.push(context, AddRuleView(ruleSetId: widget.id)),
      ),
      body: ListView(
        padding: _pagePadding.copyWith(
          bottom: _pagePadding.bottom + BottomInsetScope.of(context),
        ),
        children: [
          GroupedSection(
            children: [
              GroupedInputRow(
                title: appLocalizations.name,
                value: label,
                validator: (value) =>
                    value.trim().isEmpty ? appLocalizations.required : null,
                onSubmitted: (value) => _updateSet(
                  ref,
                  widget.id,
                  (set) => set.copyWith(label: value.trim()),
                ),
              ),
              if (url != null) ...[
                GroupedRow(title: appLocalizations.url, value: url),
                GroupedRow(
                  leading: const GroupedIcon(AppGlyphs.sync),
                  title: appLocalizations.update,
                  value: set.lastUpdateDate?.show,
                  trailing: _updating
                      ? SizedBox.square(
                          dimension: 14,
                          child: IosSpinner(color: palette.secondary),
                        )
                      : null,
                  onTap: _updating ? null : () => unawaited(_update(url)),
                ),
              ],
            ],
          ),
          const SizedBox(height: groupedSectionGap),
          GroupedSection(
            header: appLocalizations.ruleCount(set.rules.length.toString()),
            children: [
              if (set.rules.isEmpty)
                GroupedRow(title: appLocalizations.noRules),
              for (final (index, rule) in set.rules.indexed)
                GroupedRow(
                  key: ValueKey('$index.${describeRule(rule)}'),
                  title: describeRule(rule),
                  value: rulePolicyLabel(appLocalizations, rulePolicyOf(rule)),
                  trailing: Tooltip(
                    message: appLocalizations.delete,
                    child: InkResponse(
                      onTap: () => _removeRule(index),
                      radius: 16,
                      splashFactory: NoSplash.splashFactory,
                      hoverColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      child: const GlyphIcon(
                        AppGlyphs.remove,
                        size: 19,
                        color: groupedDanger,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          if (set.id != defaultRuleSetId) ...[
            const SizedBox(height: groupedSectionGap),
            GroupedSection(
              children: [
                GroupedButtonRow(
                  label: appLocalizations.deleteRuleSet,
                  color: groupedDanger,
                  onTap: _delete,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Writes one rule into a rule set: what it matches and where it goes.
class AddRuleView extends ConsumerStatefulWidget {
  const AddRuleView({super.key, required this.ruleSetId});

  final int ruleSetId;

  @override
  ConsumerState<AddRuleView> createState() => _AddRuleViewState();
}

class _AddRuleViewState extends ConsumerState<AddRuleView> {
  final _value = TextEditingController();
  RuleMatch _match = RuleMatch.domainSuffix;
  RulePolicy _policy = RulePolicy.proxy;

  @override
  void dispose() {
    _value.dispose();
    super.dispose();
  }

  List<String> get _values => [
    for (final part in _value.text.split(','))
      if (part.trim().isNotEmpty) part.trim(),
  ];

  void _save() {
    final rule = buildRule(_match, _values, _policy);
    _updateSet(
      ref,
      widget.ruleSetId,
      (set) => set.copyWith(rules: [...set.rules, rule]),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final palette = GroupedPalette.of(context);
    final check = GlyphIcon(AppGlyphs.check, size: 18, color: palette.icon);
    return GroupedPage(
      title: appLocalizations.addRule,
      onBack: () => Navigator.of(context).maybePop(),
      trailing: GroupedBarAction(
        label: appLocalizations.save,
        tooltip: appLocalizations.save,
        onPressed: _values.isEmpty ? null : _save,
      ),
      body: ListView(
        padding: _pagePadding,
        children: [
          GroupedSection(
            footer: appLocalizations.ruleValueHint,
            children: [
              GroupedFieldRow(
                label: appLocalizations.ruleValue,
                hint: appLocalizations.required,
                controller: _value,
                onChanged: (_) => setState(() {}),
              ),
            ],
          ),
          const SizedBox(height: groupedSectionGap),
          GroupedSection(
            header: appLocalizations.ruleMatch,
            children: [
              for (final match in RuleMatch.values)
                GroupedRow(
                  key: ValueKey(match),
                  title: ruleMatchLabel(appLocalizations, match),
                  trailing: match == _match ? check : null,
                  onTap: () => setState(() => _match = match),
                ),
            ],
          ),
          const SizedBox(height: groupedSectionGap),
          GroupedSection(
            header: appLocalizations.rulePolicy,
            children: [
              for (final policy in RulePolicy.values)
                GroupedRow(
                  key: ValueKey(policy),
                  title: rulePolicyLabel(appLocalizations, policy),
                  trailing: policy == _policy ? check : null,
                  onTap: () => setState(() => _policy = policy),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
