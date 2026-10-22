import 'dart:async';
import 'dart:math';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/profiles/add.dart';
import 'package:fl_clash/views/profiles/edit.dart';
import 'package:fl_clash/views/profiles/profiles.dart';
import 'package:fl_clash/views/home/node_context_menu.dart';
import 'package:fl_clash/views/home/node_share.dart';
import 'package:fl_clash/views/home/route_mode.dart';
import 'package:fl_clash/widgets/haptics.dart';
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

  /// How far the logo has taken the bar's title over, from 0 to 1.
  final _logo = ValueNotifier<double>(0);

  @override
  void dispose() {
    _edit.dispose();
    _logo.dispose();
    super.dispose();
  }

  bool _onScroll(ScrollMetrics metrics, int depth) {
    if (depth == 0 && metrics.axis == Axis.vertical) {
      _logo.value = ((metrics.pixels - _logoStart) / (_logoEnd - _logoStart))
          .clamp(0.0, 1.0);
    }
    return false;
  }

  Future<void> _deleteSelected() async {
    final ids = [
      for (final profile in ref.read(profilesProvider))
        if (_edit.isSelected(_profileKey(profile.id))) profile.id,
    ];
    if (ids.isEmpty) return;
    final appLocalizations = context.appLocalizations;
    final confirmed = await dialogs.showMessage(
      message: TextSpan(
        text: appLocalizations.deleteTip(appLocalizations.profile),
      ),
      destructive: true,
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
            titleWidget: editing ? null : _BarTitle(progress: _logo),
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
            body: NotificationListener<ScrollMetricsNotification>(
              onNotification: (n) => _onScroll(n.metrics, n.depth),
              child: NotificationListener<ScrollNotification>(
                onNotification: (n) => _onScroll(n.metrics, n.depth),
                child: const _HomeBody(),
              ),
            ),
          );
        },
      ),
    );
  }
}

// The logo starts to show once the global routing row reaches the bar, and has
// taken the title's place once the connectivity row has gone under it.
const _logoStart = 13 + groupedRowHeight;
const _logoEnd = 13 + groupedRowHeight * 3;

/// The bar's title: the app's name, giving way to its logo as the switch rows
/// scroll away under the bar. The logo then stands in for the switch.
class _BarTitle extends StatelessWidget {
  const _BarTitle({required this.progress});

  final ValueNotifier<double> progress;

  @override
  Widget build(BuildContext context) {
    final palette = GroupedPalette.of(context);
    return ValueListenableBuilder(
      valueListenable: progress,
      builder: (context, value, _) => Stack(
        alignment: Alignment.center,
        children: [
          Opacity(
            opacity: 1 - value,
            child: Text(
              appName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: palette.rowTitle,
            ),
          ),
          Opacity(
            opacity: value,
            child: IgnorePointer(
              ignoring: value < 0.5,
              child: const _LogoSwitch(),
            ),
          ),
        ],
      ),
    );
  }
}

/// The logo in the bar, in colour while the proxy runs and grey while it does
/// not; tapping it turns the proxy on or off, as the switch does.
class _LogoSwitch extends ConsumerWidget {
  const _LogoSwitch();

  static const _grey = <double>[
    0.2126, 0.7152, 0.0722, 0, 0, //
    0.2126, 0.7152, 0.0722, 0, 0, //
    0.2126, 0.7152, 0.0722, 0, 0, //
    0, 0, 0, 0.55, 0,
  ];

  static const _identity = <double>[
    1, 0, 0, 0, 0, //
    0, 1, 0, 0, 0, //
    0, 0, 1, 0, 0, //
    0, 0, 0, 1, 0,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final isStart = ref.watch(isStartProvider);
    return Semantics(
      button: true,
      toggled: isStart,
      label: isStart
          ? appLocalizations.connected
          : appLocalizations.notConnected,
      child: InkResponse(
        onTap: () {
          toggleHaptic(context);
          ref.read(commonActionProvider.notifier).toggleRunning();
        },
        radius: 20,
        splashFactory: NoSplash.splashFactory,
        hoverColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: TweenAnimationBuilder<double>(
          tween: Tween(end: isStart ? 1 : 0),
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          builder: (_, colour, child) => ColorFiltered(
            colorFilter: ColorFilter.matrix([
              for (var i = 0; i < 20; i++)
                _grey[i] + (_identity[i] - _grey[i]) * colour,
            ]),
            child: child,
          ),
          child: Image.asset(
            'assets/images/icon.png',
            width: 26,
            height: 26,
            filterQuality: FilterQuality.medium,
          ),
        ),
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
  late final _expanded = <int>{?ref.read(currentProfileIdProvider)};

  void _toggle(Profile profile) {
    setState(() {
      if (!_expanded.add(profile.id)) {
        _expanded.remove(profile.id);
      }
    });
  }

  Widget _section(Profile profile, {int? dragIndex}) {
    return _SubscriptionSection(
      profile: profile,
      expanded: _expanded.contains(profile.id),
      onToggle: () => _toggle(profile),
      dragIndex: dragIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final profiles = ref.watch(profilesProvider);
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
          sliver: profiles.isEmpty
              ? SliverToBoxAdapter(
                  child: GroupedSection(
                    footer: context.appLocalizations.subscriptionFoldTip,
                    children: [
                      GroupedRow(
                        title: context.appLocalizations.addNode,
                        chevron: true,
                        onTap: () => showAddProfilePage(context),
                      ),
                    ],
                  ),
                )
              : editing
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
                    child: _section(profiles[index], dragIndex: index),
                  ),
                )
              : SliverList(
                  delegate: SliverChildListDelegate([
                    for (final profile in profiles) ...[
                      _section(profile),
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
    return GroupedSection(
      children: [
        GroupedRow(
          leading: Image.asset(
            'assets/images/icon.png',
            width: groupedLeadingSize + 1,
            height: groupedLeadingSize + 1,
            filterQuality: FilterQuality.medium,
          ),
          title: isStart
              ? selected.takeFirstValid([
                  firstNode ?? '',
                  ?profile?.realLabel,
                ], defaultValue: appLocalizations.connected)
              : appLocalizations.notConnected,
          trailing: Opacity(
            opacity: editing ? 0.5 : 1,
            child: GroupedSwitch(
              value: isStart,
              onChanged: editing
                  ? null
                  : (_) {
                      toggleHaptic(context);
                      ref.read(commonActionProvider.notifier).toggleRunning();
                    },
            ),
          ),
        ),
        GroupedRow(
          leading: const GroupedIcon(AppGlyphs.settings),
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
      leading: const GroupedIcon(AppGlyphs.gauge),
      title: context.appLocalizations.connectivityTest,
      trailing: testing
          ? SizedBox.square(
              dimension: 17,
              child: IosSpinner(color: palette.icon),
            )
          : Tooltip(
              message: context.appLocalizations.delayTestMethod,
              child: InkResponse(
                onTap: () =>
                    BaseNavigator.push(context, const DelayMethodView()),
                radius: 18,
                splashFactory: NoSplash.splashFactory,
                hoverColor: Colors.transparent,
                highlightColor: Colors.transparent,
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
        child: IosSpinner(color: palette.icon),
      );
    }
    if (delay == null) {
      return const SizedBox.shrink();
    }
    return Text(
      delay > 0 ? '${delay}ms' : context.appLocalizations.timeout,
      style: GroupedPalette.of(context).caption2.copyWith(
        fontWeight: FontWeight.w500,
        color: context.colorScheme.delayColor(delay),
      ),
    );
  }
}

Future<void> _pasteFromClipboard(BuildContext context, WidgetRef ref) async {
  final source = await readClipboardImport();
  if (!context.mounted) return;
  if (source == null) {
    context.showNotifier(
      context.appLocalizations.clipboardNothingToImport,
      level: MessageLevel.error,
    );
    return;
  }
  await ref.read(profilesActionProvider.notifier).importFromClipboard(source);
}

class _Toolbar extends ConsumerStatefulWidget {
  const _Toolbar();

  @override
  ConsumerState<_Toolbar> createState() => _ToolbarState();
}

class _ToolbarState extends ConsumerState<_Toolbar> {
  bool _updating = false;

  Future<void> _update(Profile profile) async {
    setState(() => _updating = true);
    try {
      await globalState.safeRun(
        () => ref
            .read(profilesActionProvider.notifier)
            .updateProfile(profile, showLoading: true),
      );
    } finally {
      if (mounted) setState(() => _updating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final profile = ref.watch(currentProfileProvider);
    final nodes = ref.watch(
      groupsProvider.select((state) => state.getGroup(nodeGroupName)?.all),
    );
    final edit = _EditScope.of(context);
    final detectsClipboard = ref.watch(
      appSettingProvider.select((state) => state.clipboardDetection),
    );
    final isUpdating = ref.watch(
      isUpdatingProvider(profile?.updatingKey ?? ''),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        spacing: _toolbarGap,
        children: [
          if (!detectsClipboard)
            _ToolbarButton(
              glyph: AppGlyphs.paste,
              tooltip: appLocalizations.paste,
              onPressed: () => unawaited(_pasteFromClipboard(context, ref)),
            ),
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
            spinning: _updating,
            onPressed: profile == null || isUpdating
                ? null
                : () => unawaited(_update(profile)),
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
    this.spinning = false,
  });

  final Glyph glyph;
  final String tooltip;
  final VoidCallback? onPressed;
  final bool spinning;

  @override
  Widget build(BuildContext context) {
    final palette = GroupedPalette.of(context);
    return Tooltip(
      message: tooltip,
      child: InkResponse(
        onTap: onPressed,
        radius: 16,
        splashFactory: NoSplash.splashFactory,
        hoverColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: _Spin(
          spinning: spinning,
          child: GlyphIcon(
            glyph,
            size: 18,
            color: onPressed == null && !spinning
                ? palette.tertiary
                : palette.secondary,
          ),
        ),
      ),
    );
  }
}

/// Turns its child while [spinning], and lets it finish the turn and settle
/// upright when it stops.
class _Spin extends StatefulWidget {
  const _Spin({required this.spinning, required this.child});

  final bool spinning;
  final Widget child;

  @override
  State<_Spin> createState() => _SpinState();
}

class _SpinState extends State<_Spin> with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  @override
  void initState() {
    super.initState();
    if (widget.spinning) unawaited(_controller.repeat());
  }

  @override
  void didUpdateWidget(covariant _Spin oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.spinning == oldWidget.spinning) return;
    if (widget.spinning) {
      unawaited(_controller.repeat());
    } else {
      unawaited(_controller.animateTo(1, curve: Curves.easeOut));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(turns: _controller, child: widget.child);
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
    return '↑:${_gigabytes(info.upload)},'
        '↓:${_gigabytes(info.download)},'
        'TOT:${_gigabytes(info.total)} '
        'EXPIRES:$expire';
  }

  void _choose(WidgetRef ref, Proxy node, {required bool current}) {
    if (current) {
      ref
          .read(proxiesActionProvider.notifier)
          .changeProxyDebounce(nodeGroupName, node.name);
      return;
    }
    ref
        .read(profilesProvider.notifier)
        .put(
          profile.copyWith(
            selectedMap: {...profile.selectedMap, nodeGroupName: node.name},
          ),
        );
    ref.read(groupsProvider.notifier).value = const [];
    ref.read(currentProfileIdProvider.notifier).value = profile.id;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = GroupedPalette.of(context);
    final appLocalizations = context.appLocalizations;
    final isUpdating = ref.watch(isUpdatingProvider(profile.updatingKey));
    final current = ref.watch(currentProfileIdProvider) == profile.id;
    final running = expanded && current
        ? ref.watch(
            groupsProvider.select(
              (state) => state.getGroup(nodeGroupName)?.all,
            ),
          )
        : null;
    // Until the core has the subscription just switched to, its nodes come
    // from its file like any other's.
    final nodes = !expanded
        ? null
        : running != null && running.isNotEmpty
        ? running
        : ref
              .watch(profileNodesProvider(profile.id, profile.lastUpdateDate))
              .value;
    final selected = current
        ? ref.watch(selectedProxyNameProvider(nodeGroupName))
        : null;
    final edit = _EditScope.of(context);
    final editing = edit.editing;
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final chevron = AnimatedRotation(
      turns: expanded ? (rtl ? -0.25 : 0.25) : 0,
      duration: _drawerDuration(context),
      curve: Curves.easeOutCubic,
      child: GlyphIcon(AppGlyphs.chevronForward, size: 19, color: palette.icon),
    );
    final header = SwipeActions(
      enabled: !editing && !system.isDesktop,
      leading: [
        if (current)
          SwipeAction(
            label: appLocalizations.test,
            color: swipeActionGo,
            onPressed: () => unawaited(
              ref
                  .read(proxiesActionProvider.notifier)
                  .delayTestPageGroup(nodeGroupName),
            ),
          ),
        SwipeAction(
          label: appLocalizations.delete,
          color: groupedDanger,
          fullSwipe: true,
          slideOut: true,
          onPressed: () => ProfileActions(profile).deleteProfile(context, ref),
        ),
      ],
      child: GroupedRow(
        leading: editing
            ? Row(
                mainAxisSize: MainAxisSize.min,
                spacing: _selectGap,
                children: [
                  GroupedSelectMark(
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
                  globalState.safeRun(
                    () => ref
                        .read(profilesActionProvider.notifier)
                        .updateProfile(profile, showLoading: true),
                  ),
                ),
              ),
            if (editing && dragIndex != null)
              ReorderableDragStartListener(
                index: dragIndex!,
                child: GlyphIcon(
                  AppGlyphs.dragHandle,
                  size: 19,
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
        onTap: editing ? () => edit.toggle(_profileKey(profile.id)) : onToggle,
      ),
    );
    return GroupedSection(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            header,
            _NodeDrawer(
              open: expanded,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final (index, node)
                      in (nodes ?? const <Proxy>[]).indexed)
                    _RevealRow(
                      index: index,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const GroupedHairline(inset: 0),
                          _NodeMenuTarget(
                            profile: profile,
                            node: node,
                            current: current,
                            child: _NodeSwipe(
                              profile: profile,
                              node: node,
                              current: current,
                              enabled: !editing,
                              child: GroupedRow(
                                key: ValueKey('${profile.id}.${node.name}'),
                                leading: editing
                                    ? Row(
                                        mainAxisSize: MainAxisSize.min,
                                        spacing: _selectGap,
                                        children: [
                                          GroupedSelectMark(
                                            selected: edit.isSelected(
                                              _nodeKey(profile.id, node.name),
                                            ),
                                          ),
                                          NodeIcon(
                                            name: node.name,
                                            region: node.region,
                                            address: node.address,
                                          ),
                                        ],
                                      )
                                    : NodeIcon(
                                        name: node.name,
                                        region: node.region,
                                        address: node.address,
                                      ),
                                leadingWidth: editing
                                    ? groupedLeadingSize * 2 + _selectGap
                                    : groupedLeadingSize,
                                title: node.name,
                                subtitle: [
                                  node.type,
                                  if (node.network != null) node.network!,
                                ].map((part) => part.toUpperCase()).join(' / '),
                                titleWidget: EmojiText(
                                  nodeDisplayName(node.name),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: palette.rowTitle.copyWith(
                                    color: node.name == selected
                                        ? palette.accent
                                        : null,
                                  ),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  spacing: 10,
                                  children: [
                                    if (current) _NodeDelay(name: node.name),
                                    if (!editing)
                                      _RoundAction(
                                        glyph: AppGlyphs.info,
                                        tooltip: appLocalizations.details(
                                          node.name,
                                        ),
                                        onPressed: () => showNodeDetail(
                                          context,
                                          ref,
                                          profile,
                                          node,
                                        ),
                                      ),
                                  ],
                                ),
                                onTap: editing
                                    ? () => edit.toggle(
                                        _nodeKey(profile.id, node.name),
                                      )
                                    : () =>
                                          _choose(ref, node, current: current),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

Duration _drawerDuration(BuildContext context) =>
    MediaQuery.disableAnimationsOf(context)
    ? Duration.zero
    : const Duration(milliseconds: 420);

// Fast out of the header, then settling slowly into place.
const _drawerOpen = Cubic(0.05, 0.7, 0.1, 1);

/// A subscription's nodes, sliding open under its header and closed back into
/// it, fading as they go. While it closes it keeps showing the nodes it had.
class _NodeDrawer extends StatefulWidget {
  const _NodeDrawer({required this.open, required this.child});

  final bool open;
  final Widget child;

  @override
  State<_NodeDrawer> createState() => _NodeDrawerState();
}

class _NodeDrawerState extends State<_NodeDrawer>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    value: widget.open ? 1 : 0,
  );
  late final _size = CurvedAnimation(
    parent: _controller,
    curve: _drawerOpen,
    reverseCurve: Curves.easeInOutCubic,
  );
  // The rows fade in one by one as it opens; closing fades them all at once.
  late final _fade = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0, 0.2, curve: Curves.easeOut),
    reverseCurve: const Interval(0.3, 1, curve: Curves.easeIn),
  );

  /// What shows while the drawer closes, after the section stops building it.
  Widget? _closing;

  /// How long nodes that come after the drawer has opened take to push it on.
  Duration _grow = Duration.zero;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final duration = _drawerDuration(context);
    _controller.duration = duration;
    _controller.reverseDuration = duration * 0.8;
    _grow = duration;
  }

  @override
  void didUpdateWidget(_NodeDrawer old) {
    super.didUpdateWidget(old);
    if (widget.open == old.open) return;
    if (widget.open) {
      _closing = null;
      unawaited(_controller.forward());
    } else {
      _closing = old.child;
      unawaited(
        _controller.reverse().whenComplete(() {
          if (mounted && !widget.open) setState(() => _closing = null);
        }),
      );
    }
  }

  @override
  void dispose() {
    _size.dispose();
    _fade.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final child = widget.open ? widget.child : _closing;
    if (child == null) return const SizedBox.shrink();
    final revealed = _DrawerReveal(animation: _controller, child: child);
    return ClipRect(
      child: SizeTransition(
        sizeFactor: _size,
        alignment: AlignmentDirectional.topStart,
        child: FadeTransition(
          opacity: _fade,
          // A subscription not in use reads its nodes from its file, so they
          // can come in after the drawer has opened; they push it on smoothly.
          child: _grow == Duration.zero
              ? revealed
              : AnimatedSize(
                  duration: _grow,
                  curve: _drawerOpen,
                  alignment: AlignmentDirectional.topStart,
                  child: revealed,
                ),
        ),
      ),
    );
  }
}

class _DrawerReveal extends InheritedWidget {
  const _DrawerReveal({required this.animation, required super.child});

  final Animation<double> animation;

  static Animation<double>? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_DrawerReveal>()?.animation;

  @override
  bool updateShouldNotify(_DrawerReveal old) => animation != old.animation;
}

/// A node row of an opening drawer: it fades in and settles down a little
/// after the one above it.
class _RevealRow extends StatelessWidget {
  const _RevealRow({required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final animation = _DrawerReveal.of(context);
    if (animation == null) return child;
    final start = min(index * 0.05, 0.4);
    final curve = Interval(start, start + 0.6, curve: Curves.easeOutCubic);
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (_, child) {
        final t = animation.status == AnimationStatus.forward
            ? curve.transform(animation.value)
            : 1.0;
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, -8 * (1 - t)),
            child: child,
          ),
        );
      },
    );
  }
}

/// A node row that slides aside on a touch screen: right for test and copy,
/// left for its QR code and delete.
class _NodeSwipe extends ConsumerWidget {
  const _NodeSwipe({
    required this.profile,
    required this.node,
    required this.current,
    required this.enabled,
    required this.child,
  });

  final Profile profile;
  final Proxy node;

  /// Only the subscription in use can be tested: the core runs no other.
  final bool current;
  final bool enabled;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    return SwipeActions(
      enabled: enabled && !system.isDesktop,
      leading: [
        if (current)
          SwipeAction(
            label: appLocalizations.test,
            color: swipeActionGo,
            fullSwipe: true,
            onPressed: () => unawaited(
              ref
                  .read(proxiesActionProvider.notifier)
                  .proxyDelayTest(node, ref.read(appSettingProvider).testUrl),
            ),
          ),
        SwipeAction(
          label: appLocalizations.copy,
          color: swipeActionNeutral,
          onPressed: () => unawaited(copyNode(context, ref, profile, node)),
        ),
      ],
      trailing: [
        SwipeAction(
          label: appLocalizations.qrcode,
          color: swipeActionNeutral,
          onPressed: () =>
              unawaited(showNodeQrCode(context, ref, profile, node)),
        ),
        SwipeAction(
          label: appLocalizations.delete,
          color: groupedDanger,
          fullSwipe: true,
          slideOut: true,
          onPressed: () => deleteNode(context, ref, profile, node),
        ),
      ],
      child: child,
    );
  }
}

/// Opens a node's menu where it was asked for: a right click, or a long press.
class _NodeMenuTarget extends ConsumerWidget {
  const _NodeMenuTarget({
    required this.profile,
    required this.node,
    required this.current,
    required this.child,
  });

  final Profile profile;
  final Proxy node;
  final bool current;
  final Widget child;

  Future<void> _open(
    BuildContext context,
    WidgetRef ref,
    Offset position,
  ) async {
    final appLocalizations = context.appLocalizations;
    final overlay =
        Overlay.of(context).context.findRenderObject()! as RenderBox;
    final box = context.findRenderObject() as RenderBox?;
    final rect = box != null && box.hasSize
        ? box.localToGlobal(Offset.zero) & box.size
        : null;
    final testUrl = ref.read(appSettingProvider).testUrl;
    final chosen = system.isDesktop
        ? await _showDesktopMenu(context, overlay, position)
        : await showNodeContextMenu<_NodeAction>(
            context: context,
            title: node.name,
            anchor: position,
            preview: rect == null ? null : child,
            previewRect: rect,
            groups: [
              if (current)
                [
                  NodeMenuEntry(
                    value: _NodeAction.test,
                    label: appLocalizations.delayTest,
                    glyph: AppGlyphs.send,
                  ),
                ],
              [
                NodeMenuEntry(
                  value: _NodeAction.details,
                  label: appLocalizations.details(node.name),
                  glyph: AppGlyphs.document,
                ),
                NodeMenuEntry(
                  value: _NodeAction.copy,
                  label: appLocalizations.copy,
                  glyph: AppGlyphs.duplicate,
                ),
              ],
              [
                NodeMenuEntry(
                  value: _NodeAction.qrcode,
                  label: appLocalizations.qrcode,
                  glyph: AppGlyphs.qrCode,
                ),
                if (node.address != null)
                  NodeMenuEntry(
                    value: _NodeAction.copyAddress,
                    label: appLocalizations.copyAddress,
                    glyph: AppGlyphs.copy,
                  ),
                NodeMenuEntry(
                  value: _NodeAction.copyName,
                  label: appLocalizations.copyName,
                  glyph: AppGlyphs.textShort,
                ),
              ],
              [
                NodeMenuEntry(
                  value: _NodeAction.delete,
                  label: appLocalizations.delete,
                  glyph: AppGlyphs.delete,
                  danger: true,
                ),
              ],
            ],
          );
    if (chosen == null || !context.mounted) {
      return;
    }
    await _run(context, ref, chosen, testUrl);
  }

  Future<_NodeAction?> _showDesktopMenu(
    BuildContext context,
    RenderBox overlay,
    Offset position,
  ) {
    final appLocalizations = context.appLocalizations;
    return showMenu<_NodeAction>(
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
        if (current)
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
        PopupMenuItem(
          value: _NodeAction.copy,
          height: 30,
          child: Text(appLocalizations.copy),
        ),
        PopupMenuItem(
          value: _NodeAction.qrcode,
          height: 30,
          child: Text(appLocalizations.qrcode),
        ),
        const PopupMenuDivider(height: 1),
        PopupMenuItem(
          value: _NodeAction.delete,
          height: 30,
          child: Text(appLocalizations.delete),
        ),
      ],
    );
  }

  Future<void> _run(
    BuildContext context,
    WidgetRef ref,
    _NodeAction chosen,
    String testUrl,
  ) async {
    switch (chosen) {
      case _NodeAction.test:
        unawaited(
          ref
              .read(proxiesActionProvider.notifier)
              .proxyDelayTest(node, testUrl),
        );
      case _NodeAction.details:
        unawaited(showNodeDetail(context, ref, profile, node));
      case _NodeAction.copyName:
        await Clipboard.setData(ClipboardData(text: node.name));
      case _NodeAction.copyAddress:
        await Clipboard.setData(ClipboardData(text: node.address!));
      case _NodeAction.copy:
        await copyNode(context, ref, profile, node);
      case _NodeAction.qrcode:
        await showNodeQrCode(context, ref, profile, node);
      case _NodeAction.delete:
        await deleteNode(context, ref, profile, node);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onSecondaryTapDown: (details) =>
          unawaited(_open(context, ref, details.globalPosition)),
      onLongPressStart: (details) {
        selectionHaptic(context);
        unawaited(_open(context, ref, details.globalPosition));
      },
      child: child,
    );
  }
}

enum _NodeAction { test, details, copyName, copyAddress, copy, qrcode, delete }

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
        splashFactory: NoSplash.splashFactory,
        hoverColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: busy
            ? SizedBox.square(
                dimension: 17,
                child: IosSpinner(color: palette.icon),
              )
            : GlyphIcon(glyph, size: 19, color: palette.icon),
      ),
    );
  }
}
