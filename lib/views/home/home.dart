import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/views/profiles/add.dart';
import 'package:fl_clash/views/profiles/edit.dart';
import 'package:fl_clash/views/home/route_mode.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'delay_test.dart';
import 'node_icon.dart';

const _toolbarGap = 12.0;
const _selectGap = 10.0;

/// What the home page's edit mode has chosen: which rows are ticked.
class _EditState extends ChangeNotifier {
  bool _editing = false;
  final _selected = <String>{};

  bool get editing => _editing;

  Set<String> get selected => Set.unmodifiable(_selected);

  bool isSelected(String key) => _selected.contains(key);

  void enter() {
    _editing = true;
    notifyListeners();
  }

  void exit() {
    _editing = false;
    _selected.clear();
    notifyListeners();
  }

  void toggle(String key) {
    if (!_selected.add(key)) {
      _selected.remove(key);
    }
    notifyListeners();
  }

  void clearSelection() {
    _selected.clear();
    notifyListeners();
  }
}

String _profileKey(int id) => 'p$id';

String _nodeKey(int profileId, String name) => 'n$profileId.$name';

class _EditScope extends InheritedNotifier<_EditState> {
  const _EditScope({required _EditState state, required super.child})
    : super(notifier: state);

  static _EditState of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_EditScope>()!.notifier!;
  }
}

class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  final _edit = _EditState();

  @override
  void dispose() {
    _edit.dispose();
    super.dispose();
  }

  Future<void> _deleteSelected() async {
    final appLocalizations = context.appLocalizations;
    final ids = [
      for (final profile in ref.read(profilesProvider))
        if (_edit.isSelected(_profileKey(profile.id))) profile.id,
    ];
    if (ids.isEmpty) return;
    final confirmed = await dialogs.showMessage(
      title: appLocalizations.tip,
      message: TextSpan(
        text: appLocalizations.deleteTip(appLocalizations.profile),
      ),
    );
    if (confirmed != true) return;
    final profilesAction = ref.read(profilesActionProvider.notifier);
    for (final id in ids) {
      await profilesAction.deleteProfile(id);
    }
    _edit.clearSelection();
  }

  Future<void> _copySelected() async {
    final lines = <String>[];
    for (final profile in ref.read(profilesProvider)) {
      if (_edit.isSelected(_profileKey(profile.id))) {
        lines.add(
          profile.type == ProfileType.url ? profile.url : profile.realLabel,
        );
      }
      final nodes = ref.read(groupsProvider).getGroup(nodeGroupName)?.all;
      if (profile.id != ref.read(currentProfileIdProvider)) continue;
      for (final node in nodes ?? const <Proxy>[]) {
        if (_edit.isSelected(_nodeKey(profile.id, node.name))) {
          lines.add(node.address ?? node.name);
        }
      }
    }
    if (lines.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: lines.join('\n')));
    if (mounted) {
      context.showNotifier(
        context.appLocalizations.copySuccess,
        level: MessageLevel.success,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return _EditScope(
      state: _edit,
      child: ListenableBuilder(
        listenable: _edit,
        builder: (context, _) {
          final editing = _edit.editing;
          final hasSelection = _edit.selected.isNotEmpty;
          final hasProfileSelected = ref
              .read(profilesProvider)
              .any((profile) => _edit.isSelected(_profileKey(profile.id)));
          return GroupedPage(
            title: editing ? '' : appName,
            leading: GroupedBarAction(
              glyph: AppGlyphs.scanFrame,
              tooltip: appLocalizations.qrcode,
              onPressed: () => scanProfileQrCode(context, ref),
            ),
            leadingActions: editing
                ? [
                    GroupedBarAction(
                      glyph: AppGlyphs.delete,
                      label: appLocalizations.delete,
                      tooltip: appLocalizations.delete,
                      onPressed: hasProfileSelected
                          ? () => unawaited(_deleteSelected())
                          : null,
                    ),
                    GroupedBarAction(
                      glyph: AppGlyphs.copy,
                      label: appLocalizations.copy,
                      tooltip: appLocalizations.copy,
                      onPressed: hasSelection
                          ? () => unawaited(_copySelected())
                          : null,
                    ),
                  ]
                : const [],
            trailing: editing
                ? GroupedBarAction(
                    label: appLocalizations.done,
                    tooltip: appLocalizations.done,
                    onPressed: _edit.exit,
                  )
                : GroupedBarAction(
                    glyph: AppGlyphs.add,
                    tooltip: appLocalizations.addProfile,
                    onPressed: () => showAddProfilePage(context),
                  ),
            body: const _HomeBody(),
          );
        },
      ),
    );
  }
}

class _HomeBody extends ConsumerStatefulWidget {
  const _HomeBody();

  @override
  ConsumerState<_HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends ConsumerState<_HomeBody> {
  final _collapsed = <int>{};

  void _toggle(Profile profile) {
    final currentId = ref.read(currentProfileIdProvider);
    if (profile.id != currentId) {
      ref.read(currentProfileIdProvider.notifier).value = profile.id;
      setState(() => _collapsed.remove(profile.id));
      return;
    }
    setState(() {
      if (!_collapsed.add(profile.id)) {
        _collapsed.remove(profile.id);
      }
    });
  }

  Widget _section(Profile profile, int? currentId, {int? dragIndex}) {
    return _SubscriptionSection(
      profile: profile,
      expanded: profile.id == currentId && !_collapsed.contains(profile.id),
      onToggle: () => _toggle(profile),
      dragIndex: dragIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final profiles = ref.watch(profilesProvider);
    final currentId = ref.watch(currentProfileIdProvider);
    final editing = _EditScope.of(context).editing;
    return CustomScrollView(
      key: homeStoreKey,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            groupedPageInset,
            13,
            groupedPageInset,
            0,
          ),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const _ControlSection(),
              const _Toolbar(),
            ]),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(
            groupedPageInset,
            0,
            groupedPageInset,
            20 + BottomInsetScope.of(context),
          ),
          sliver: editing
              ? SliverReorderableList(
                  itemCount: profiles.length,
                  onReorderItem: (oldIndex, newIndex) => ref
                      .read(profilesProvider.notifier)
                      .reorder(profiles.copyAndReorder(oldIndex, newIndex)),
                  proxyDecorator: (child, _, _) =>
                      Material(type: MaterialType.transparency, child: child),
                  itemBuilder: (_, index) => Padding(
                    key: ValueKey(profiles[index].id),
                    padding: const EdgeInsets.only(bottom: groupedSectionGap),
                    child: _section(
                      profiles[index],
                      currentId,
                      dragIndex: index,
                    ),
                  ),
                )
              : SliverList(
                  delegate: SliverChildListDelegate([
                    for (final profile in profiles) ...[
                      _section(profile, currentId),
                      const SizedBox(height: groupedSectionGap),
                    ],
                  ]),
                ),
        ),
      ],
    );
  }
}

class _ControlSection extends ConsumerWidget {
  const _ControlSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final profile = ref.watch(currentProfileProvider);
    final isStart = ref.watch(isStartProvider);
    final mode = ref.watch(coreSettingProvider.select((state) => state.mode));
    final selected = ref.watch(selectedProxyNameProvider(nodeGroupName));
    final editing = _EditScope.of(context).editing;
    final firstNode = ref.watch(
      groupsProvider.select(
        (state) => state.getGroup(nodeGroupName)?.all.firstOrNull?.name,
      ),
    );
    if (profile == null) {
      return GroupedSection(
        children: [
          GroupedRow(
            leading: const GroupedIcon(AppGlyphs.add),
            title: appLocalizations.addProfile,
            chevron: true,
            onTap: () => showAddProfilePage(context),
          ),
        ],
      );
    }
    return GroupedSection(
      children: [
        GroupedRow(
          leading: const GroupedIcon(AppGlyphs.rocket),
          title: selected.takeFirstValid([firstNode ?? '', profile.realLabel]),
          trailing: Opacity(
            opacity: editing ? 0.5 : 1,
            child: GroupedSwitch(
              value: isStart,
              onChanged: editing
                  ? null
                  : (_) =>
                        ref.read(commonActionProvider.notifier).toggleRunning(),
            ),
          ),
        ),
        GroupedRow(
          leading: const GroupedIcon(AppGlyphs.starburst),
          title: appLocalizations.globalRouting,
          value: mode.label,
          chevron: true,
          onTap: () => BaseNavigator.push(context, const RouteModeView()),
        ),
        const _ConnectivityRow(),
      ],
    );
  }
}

class _ConnectivityRow extends ConsumerWidget {
  const _ConnectivityRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final method = ref.watch(
      appSettingProvider.select((state) => state.delayTestMethod),
    );
    final testing = ref.watch(
      delayTestingGroupsProvider.select(
        (state) => state.contains(nodeGroupName),
      ),
    );
    final hasNodes = ref.watch(
      groupsProvider.select(
        (state) => state.getGroup(nodeGroupName)?.all.isNotEmpty ?? false,
      ),
    );
    final palette = GroupedPalette.of(context);
    return GroupedRow(
      leading: const GroupedIcon(AppGlyphs.speed),
      title: context.appLocalizations.connectivityTest,
      trailing: testing
          ? SizedBox.square(
              dimension: 19,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: palette.icon,
              ),
            )
          : Tooltip(
              message: context.appLocalizations.delayTestMethod,
              child: InkResponse(
                onTap: () =>
                    BaseNavigator.push(context, const DelayMethodView()),
                radius: 18,
                child: GroupedIcon(delayMethodGlyph(method)),
              ),
            ),
      onTap: hasNodes && !testing
          ? () => unawaited(
              ref
                  .read(proxiesActionProvider.notifier)
                  .delayTestPageGroup(nodeGroupName),
            )
          : null,
    );
  }
}

/// The last latency measured for a node, or a spinner while one is running.
class _NodeDelay extends ConsumerWidget {
  const _NodeDelay({required this.name});

  final String name;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = GroupedPalette.of(context);
    final testUrl = ref.watch(
      appSettingProvider.select((state) => state.testUrl),
    );
    final phase = ref.watch(
      delayTestPhaseProvider(proxyName: name, testUrl: testUrl),
    );
    final delay = ref.watch(delayProvider(proxyName: name, testUrl: testUrl));
    if (phase != null) {
      return SizedBox.square(
        dimension: 12,
        child: CircularProgressIndicator(strokeWidth: 1.5, color: palette.icon),
      );
    }
    if (delay == null) {
      return const SizedBox.shrink();
    }
    return Text(
      delay > 0 ? '${delay}ms' : context.appLocalizations.timeout,
      style: TextStyle(
        fontSize: 10.5,
        fontWeight: FontWeight.w500,
        color: context.colorScheme.delayColor(delay),
      ),
    );
  }
}

class _Toolbar extends ConsumerWidget {
  const _Toolbar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final profile = ref.watch(currentProfileProvider);
    final nodes = ref.watch(
      groupsProvider.select((state) => state.getGroup(nodeGroupName)?.all),
    );
    final edit = _EditScope.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        spacing: _toolbarGap,
        children: [
          _ToolbarButton(
            glyph: AppGlyphs.signpost,
            tooltip: appLocalizations.delayTest,
            onPressed: nodes == null || nodes.isEmpty
                ? null
                : () => unawaited(
                    ref
                        .read(proxiesActionProvider.notifier)
                        .delayTestPageGroup(nodeGroupName),
                  ),
          ),
          _ToolbarButton(
            glyph: AppGlyphs.copy,
            tooltip: appLocalizations.addProfile,
            onPressed: () => showAddProfilePage(context),
          ),
          _ToolbarButton(
            glyph: AppGlyphs.sync,
            tooltip: appLocalizations.update,
            onPressed: profile == null
                ? null
                : () => unawaited(
                    ref
                        .read(profilesActionProvider.notifier)
                        .updateProfile(profile, showLoading: true),
                  ),
          ),
          _ToolbarButton(
            glyph: edit.editing ? AppGlyphs.close : AppGlyphs.more,
            tooltip: edit.editing
                ? appLocalizations.done
                : appLocalizations.more,
            onPressed: edit.editing
                ? edit.exit
                : (profile == null ? null : edit.enter),
          ),
        ],
      ),
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  const _ToolbarButton({
    required this.glyph,
    required this.tooltip,
    required this.onPressed,
  });

  final Glyph glyph;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final palette = GroupedPalette.of(context);
    return Tooltip(
      message: tooltip,
      child: InkResponse(
        onTap: onPressed,
        radius: 16,
        child: GlyphIcon(
          glyph,
          size: 18,
          color: onPressed == null ? palette.tertiary : palette.secondary,
        ),
      ),
    );
  }
}

String _gigabytes(int bytes) =>
    '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)}GB';

class _SubscriptionSection extends ConsumerWidget {
  const _SubscriptionSection({
    required this.profile,
    required this.expanded,
    required this.onToggle,
    this.dragIndex,
  });

  final Profile profile;
  final bool expanded;
  final VoidCallback onToggle;

  /// Where the section sits in the reorderable list, while it is being edited.
  final int? dragIndex;

  String? _usage(SubscriptionInfo? info) {
    if (info == null || info.total <= 0) return null;
    final expire = info.expire > 0
        ? DateTime.fromMillisecondsSinceEpoch(info.expire * 1000).show
        : '∞';
    return '\u{1F680}↑:${_gigabytes(info.upload)},'
        '↓:${_gigabytes(info.download)},'
        'TOT:${_gigabytes(info.total)} '
        '\u{1F4A1}EXPIRES:$expire';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = GroupedPalette.of(context);
    final appLocalizations = context.appLocalizations;
    final isUpdating = ref.watch(isUpdatingProvider(profile.updatingKey));
    final nodes = expanded
        ? ref.watch(
            groupsProvider.select(
              (state) => state.getGroup(nodeGroupName)?.all,
            ),
          )
        : null;
    final selected = ref.watch(selectedProxyNameProvider(nodeGroupName));
    final edit = _EditScope.of(context);
    final editing = edit.editing;
    final chevron = GlyphIcon(
      expanded ? AppGlyphs.chevronDown : AppGlyphs.chevronForward,
      size: 19,
      color: palette.icon,
    );
    return GroupedSection(
      children: [
        GroupedRow(
          leading: editing
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: _selectGap,
                  children: [
                    _SelectMark(
                      selected: edit.isSelected(_profileKey(profile.id)),
                    ),
                    chevron,
                  ],
                )
              : chevron,
          leadingWidth: editing
              ? groupedLeadingSize * 2 + _selectGap
              : groupedLeadingSize,
          title: profile.realLabel,
          subtitle: _usage(profile.subscriptionInfo),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 12,
            children: [
              if (profile.type == ProfileType.url)
                _RoundAction(
                  glyph: AppGlyphs.refresh,
                  tooltip: appLocalizations.update,
                  busy: isUpdating,
                  onPressed: () => unawaited(
                    ref
                        .read(profilesActionProvider.notifier)
                        .updateProfile(profile, showLoading: true),
                  ),
                ),
              if (editing && dragIndex != null)
                ReorderableDragStartListener(
                  index: dragIndex!,
                  child: GlyphIcon(
                    AppGlyphs.dragHandle,
                    size: 21,
                    color: palette.tertiary,
                  ),
                )
              else
                _RoundAction(
                  glyph: AppGlyphs.info,
                  tooltip: appLocalizations.edit,
                  onPressed: () => BaseNavigator.push(
                    context,
                    EditProfileView(profile: profile),
                  ),
                ),
            ],
          ),
          onTap: editing
              ? () => edit.toggle(_profileKey(profile.id))
              : onToggle,
        ),
        for (final node in nodes ?? const <Proxy>[])
          _NodeMenuTarget(
            node: node,
            child: GroupedRow(
              key: ValueKey('${profile.id}.${node.name}'),
              leading: editing
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: _selectGap,
                      children: [
                        _SelectMark(
                          selected: edit.isSelected(
                            _nodeKey(profile.id, node.name),
                          ),
                        ),
                        NodeIcon(name: node.name),
                      ],
                    )
                  : NodeIcon(name: node.name),
              leadingWidth: editing
                  ? groupedLeadingSize * 2 + _selectGap
                  : groupedLeadingSize,
              title: node.name,
              subtitle: [
                node.type,
                if (node.network != null) node.network!,
              ].map((part) => part.toUpperCase()).join(' / '),
              titleWidget: EmojiText(
                node.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: palette.rowTitle.copyWith(
                  color: node.name == selected ? palette.accent : null,
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 10,
                children: [
                  _NodeDelay(name: node.name),
                  if (!editing)
                    _RoundAction(
                      glyph: AppGlyphs.info,
                      tooltip: appLocalizations.details(node.name),
                      onPressed: () => showNodeDetail(context, node),
                    ),
                ],
              ),
              onTap: editing
                  ? () => edit.toggle(_nodeKey(profile.id, node.name))
                  : () => ref
                        .read(proxiesActionProvider.notifier)
                        .changeProxyDebounce(nodeGroupName, node.name),
            ),
          ),
      ],
    );
  }
}

/// The ring at the start of a row in edit mode, filled once it is ticked.
class _SelectMark extends StatelessWidget {
  const _SelectMark({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    final palette = GroupedPalette.of(context);
    return SizedBox.square(
      dimension: groupedLeadingSize,
      child: DecoratedBox(
        decoration: ShapeDecoration(
          color: selected ? palette.icon : Colors.transparent,
          shape: CircleBorder(
            side: selected
                ? BorderSide.none
                : BorderSide(color: palette.tertiary, width: 1.5),
          ),
        ),
        child: selected
            ? const GlyphIcon(
                AppGlyphs.check,
                size: 13,
                color: Color(0xFFFFFFFF),
              )
            : null,
      ),
    );
  }
}

/// Opens a node's menu where it was asked for: a right click, or a long press.
class _NodeMenuTarget extends ConsumerWidget {
  const _NodeMenuTarget({required this.node, required this.child});

  final Proxy node;
  final Widget child;

  Future<void> _open(
    BuildContext context,
    WidgetRef ref,
    Offset position,
  ) async {
    final appLocalizations = context.appLocalizations;
    final overlay =
        Overlay.of(context).context.findRenderObject()! as RenderBox;
    final testUrl = ref.read(appSettingProvider).testUrl;
    final chosen = await showMenu<_NodeAction>(
      context: context,
      position: RelativeRect.fromRect(
        position & const Size(1, 1),
        Offset.zero & overlay.size,
      ),
      items: [
        PopupMenuItem<_NodeAction>(
          enabled: false,
          height: 30,
          child: Text(node.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
        const PopupMenuDivider(height: 1),
        PopupMenuItem(
          value: _NodeAction.test,
          height: 30,
          child: Text(appLocalizations.delayTest),
        ),
        PopupMenuItem(
          value: _NodeAction.details,
          height: 30,
          child: Text(appLocalizations.details(node.name)),
        ),
        const PopupMenuDivider(height: 1),
        PopupMenuItem(
          value: _NodeAction.copyName,
          height: 30,
          child: Text(appLocalizations.copyName),
        ),
        if (node.address != null)
          PopupMenuItem(
            value: _NodeAction.copyAddress,
            height: 30,
            child: Text(appLocalizations.copyAddress),
          ),
      ],
    );
    if (chosen == null || !context.mounted) {
      return;
    }
    switch (chosen) {
      case _NodeAction.test:
        unawaited(
          ref
              .read(proxiesActionProvider.notifier)
              .proxyDelayTest(node, testUrl),
        );
      case _NodeAction.details:
        showNodeDetail(context, node);
      case _NodeAction.copyName:
        await Clipboard.setData(ClipboardData(text: node.name));
      case _NodeAction.copyAddress:
        await Clipboard.setData(ClipboardData(text: node.address!));
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

enum _NodeAction { test, details, copyName, copyAddress }

class _RoundAction extends StatelessWidget {
  const _RoundAction({
    required this.glyph,
    required this.tooltip,
    required this.onPressed,
    this.busy = false,
  });

  final Glyph glyph;
  final String tooltip;
  final VoidCallback onPressed;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final palette = GroupedPalette.of(context);
    return Tooltip(
      message: tooltip,
      child: InkResponse(
        onTap: busy ? null : onPressed,
        radius: 16,
        child: busy
            ? SizedBox.square(
                dimension: 19,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: palette.icon,
                ),
              )
            : GlyphIcon(glyph, size: 21, color: palette.icon),
      ),
    );
  }
}
