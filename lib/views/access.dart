import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/plugins/app.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AccessView extends ConsumerStatefulWidget {
  const AccessView({super.key});

  @override
  ConsumerState<AccessView> createState() => _AccessViewState();
}

class _AccessViewState extends ConsumerState<AccessView> {
  late ScrollController _controller;
  final _searchController = TextEditingController();
  List<String>? _pinedList;
  bool _isInit = false;
  bool _installedAppsPermissionGranted = true;

  final _completer = Completer();

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    _completer.complete(_loadPackages());
    final accessControl = ref
        .read(vpnSettingProvider.select((state) => state.accessControlProps))
        .copyWith();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      ref.read(accessControlStateProvider.notifier).value = accessControl;
      _isInit = true;
      _pinList();
    });
    ref.listenManual(
      accessControlStateProvider.select((state) => state.mode),
      (_, _) => _pinList(),
    );
  }

  Future<void> _loadPackages() async {
    final action = ref.read(systemActionProvider.notifier);
    final packages = await action.getPackages();
    final granted =
        packages.isNotEmpty || await action.isInstalledAppsPermissionGranted();
    if (!mounted || granted == _installedAppsPermissionGranted) {
      return;
    }
    setState(() {
      _installedAppsPermissionGranted = granted;
    });
  }

  Future<void> _handleGrantInstalledAppsPermission() async {
    final appLocalizations = context.appLocalizations;
    final granted = await ref
        .read(systemActionProvider.notifier)
        .requestInstalledAppsPermission();
    if (!mounted) {
      return;
    }
    if (!granted) {
      final res = await dialogs.showMessage(
        message: TextSpan(
          text: appLocalizations.installedAppsPermissionDeniedMessage,
        ),
        confirmText: appLocalizations.settings,
      );
      if (res == true) {
        await app?.openAppSettings();
      }
      return;
    }
    await globalState.loadingRun(_loadPackages, tag: LoadingTag.access);
  }

  void _pinList() {
    if (!_isInit || !mounted) {
      return;
    }
    setState(() {
      _pinedList = ref.read(accessControlStateProvider).currentList;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _toggleSelectAll(List<String> allValueList) {
    ref.read(accessControlStateProvider.notifier).update((state) {
      final newSet = Set<String>.from(state.currentList);
      if (newSet.containsAll(allValueList)) {
        newSet.removeAll(allValueList);
      } else {
        newSet.addAll(allValueList);
      }
      return state.copyWithNewList(newSet.toList());
    });
  }

  Future<void> _intelligentSelected() async {
    final packageNames = ref.read(
      packagesProvider.select((state) => state.map((item) => item.packageName)),
    );
    if (packageNames.isEmpty) {
      return;
    }
    final selectedPackageNames =
        (await globalState.loadingRun<List<String>>(() async {
          return await app?.getChinaPackageNames() ?? [];
        }, tag: LoadingTag.access))?.toSet() ??
        {};
    final acceptList = packageNames
        .where((item) => !selectedPackageNames.contains(item))
        .toList();
    final rejectList = packageNames
        .where((item) => selectedPackageNames.contains(item))
        .toList();
    ref
        .read(accessControlStateProvider.notifier)
        .update(
          (state) =>
              state.copyWith(acceptList: acceptList, rejectList: rejectList),
        );
  }

  void _handleToSetting() {
    BaseNavigator.push<void>(
      context,
      AccessControlSettingsView(
        onIntelligentSelected: _intelligentSelected,
        onExport: _exportToClipboard,
        onImport: _importFormClipboard,
      ),
    );
  }

  void _handleSelected(String packageName) {
    ref.read(accessControlStateProvider.notifier).update((state) {
      final newSet = Set<String>.from(state.currentList)
        ..addOrRemove(packageName);
      return state.copyWithNewList(newSet.toList());
    });
  }

  void _handleToggle() {
    ref.read(accessControlStateProvider.notifier).update((state) {
      return state.copyWith(enable: !state.enable);
    });
  }

  Future<void> _handleBack() async {
    final appLocalizations = context.appLocalizations;
    final res = await dialogs.showMessage(
      title: appLocalizations.tip,
      message: TextSpan(text: appLocalizations.saveChanges),
    );
    if (res == null) {
      return;
    }
    if (res) {
      _handleSave();
    }
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  AccessControlProps _getRealAccessControlProps(
    AccessControlProps accessControl,
  ) {
    final packages = ref.read(packagesProvider);
    if (packages.isEmpty) {
      return accessControl;
    }
    final viewPackageNames = packages
        .whereVisible(
          isFilterSystemApp: accessControl.isFilterSystemApp,
          isFilterNonInternetApp: accessControl.isFilterNonInternetApp,
        )
        .map((item) => item.packageName)
        .toSet();
    return accessControl.copyWithNewList(
      accessControl.currentList
          .where((item) => viewPackageNames.contains(item))
          .toList()
        ..sort(),
    );
  }

  void _handleSave() {
    final accessControl = ref.read(accessControlStateProvider);
    ref
        .read(vpnSettingProvider.notifier)
        .update(
          (state) => state.copyWith(
            accessControlProps: _getRealAccessControlProps(accessControl),
          ),
        );
  }

  Future<void> _exportToClipboard() async {
    await globalState.safeRun(() {
      final currentList = ref.read(
        accessControlStateProvider.select((state) => state.currentList),
      );
      Clipboard.setData(ClipboardData(text: currentList.join('\n')));
    });
  }

  Future<void> _importFormClipboard() async {
    await globalState.safeRun(() async {
      final data = await Clipboard.getData('text/plain');
      final text = data?.text;
      if (text == null) return;
      final list = text.split('\n');
      ref
          .read(accessControlStateProvider.notifier)
          .update((state) => state.copyWithNewList(list.toSet().toList()));
    });
  }

  Widget _buildList({
    required List<Package> packages,
    required Set<String> selected,
    required bool isSearching,
    required bool canSelectAll,
  }) {
    return FutureBuilder(
      future: _completer.future,
      builder: (context, snapshot) {
        final appLocalizations = context.appLocalizations;
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CommonCircleLoading());
        }
        final allSelected =
            packages.isNotEmpty &&
            packages.every((item) => selected.contains(item.packageName));
        final headerCount = canSelectAll ? 1 : 0;
        return NullStatusSwitcher(
          isEmpty: packages.isEmpty,
          isSearching: isSearching,
          nullStatus: NullStatus(
            label: appLocalizations.noData,
            illustration: NullStatusIllustration.apps,
          ),
          child: Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                groupedPageInset,
                0,
                groupedPageInset,
                20 + BottomInsetScope.of(context),
              ),
              child: GroupedCard(
                child: CommonScrollBar(
                  controller: _controller,
                  child: ListView.separated(
                    controller: _controller,
                    shrinkWrap: true,
                    itemCount: packages.length + headerCount,
                    separatorBuilder: (_, index) => GroupedHairline(
                      inset: index < headerCount
                          ? groupedRowPadding + 1
                          : _packageSeparatorInset,
                    ),
                    itemBuilder: (_, index) {
                      if (index < headerCount) {
                        return GroupedRow(
                          title: allSelected
                              ? appLocalizations.cancelSelectAll
                              : appLocalizations.selectAll,
                          trailing: GroupedSelectMark(selected: allSelected),
                          onTap: () => _toggleSelectAll(
                            packages.map((item) => item.packageName).toList(),
                          ),
                        );
                      }
                      final package = packages[index - headerCount];
                      return PackageListItem(
                        key: Key(package.packageName),
                        package: package,
                        value: selected.contains(package.packageName),
                        onChanged: (value) {
                          _handleSelected(package.packageName);
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInstalledAppsPermissionStatus() {
    final appLocalizations = context.appLocalizations;
    return NullStatus(
      label: appLocalizations.installedAppsPermissionRequired,
      description: appLocalizations.installedAppsPermissionDesc,
      illustration: NullStatusIllustration.permission,
      action: ElasticButton(
        child: IosButton(
          onPressed: _handleGrantInstalledAppsPermission,
          glyph: AppGlyphs.lockOpen,
          label: appLocalizations.authorize,
        ),
      ),
    );
  }

  String _describe({
    required bool enable,
    required AccessControlMode mode,
    required int count,
  }) {
    final appLocalizations = context.appLocalizations;
    if (!enable) {
      return appLocalizations.accessControlDisabledDesc;
    }
    final describe = mode == AccessControlMode.acceptSelected
        ? appLocalizations.accessControlAllowDesc
        : appLocalizations.accessControlNotAllowDesc;
    return '$describe · ${appLocalizations.selected} $count';
  }

  void _onSearch(String value) {
    ref.read(queryProvider(QueryTag.access).notifier).value = value;
    _pinList();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(loadingProvider(LoadingTag.access));
    final query = SearchQuery(ref.watch(queryProvider(QueryTag.access)));
    final packages = ref.watch(packagesProvider);
    final accessControl = ref.watch(accessControlStateProvider);
    final viewPackages = packages
        .getViewList(
          pinedList: _pinedList ?? [],
          sortType: accessControl.sort,
          isFilterNonInternetApp: accessControl.isFilterNonInternetApp,
          isFilterSystemApp: accessControl.isFilterSystemApp,
        )
        .whereMatches(query, (package) => [package.label, package.packageName])
        .toList();
    final mode = accessControl.mode;
    final currentList = accessControl.currentList;
    final viewPackageNameList = viewPackages.map((e) => e.packageName).toList();
    final valueList = currentList.intersection(viewPackageNameList);
    final needsInstalledAppsPermission =
        packages.isEmpty && !_installedAppsPermissionGranted;
    final canSelectAll =
        accessControl.enable &&
        !needsInstalledAppsPermission &&
        viewPackageNameList.isNotEmpty;
    final hasChanges = ref.watch(
      vpnSettingProvider.select(
        (state) =>
            _getRealAccessControlProps(state.accessControlProps) !=
            _getRealAccessControlProps(accessControl),
      ),
    );
    final appLocalizations = context.appLocalizations;
    return CommonPopScope(
      onPop: hasChanges
          ? (_) {
              _handleBack();
              return false;
            }
          : null,
      child: GroupedPage(
        title: appLocalizations.appAccessControl,
        onBack: () => Navigator.of(context).maybePop(),
        trailing: GroupedBarAction(
          label: appLocalizations.save,
          tooltip: appLocalizations.save,
          onPressed: hasChanges ? _handleSave : null,
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (isLoading) const IosProgressBar(),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                groupedPageInset,
                13,
                groupedPageInset,
                10,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 12,
                children: [
                  GroupedSection(
                    footer: _describe(
                      enable: accessControl.enable,
                      mode: mode,
                      count: valueList.length,
                    ),
                    children: [
                      GroupedRow(
                        leading: const GroupedIcon(AppGlyphs.toggle),
                        title: appLocalizations.accessControl,
                        trailing: GroupedSwitch(
                          value: accessControl.enable,
                          onChanged: (_) => _handleToggle(),
                        ),
                      ),
                      GroupedRow(
                        leading: const GroupedIcon(AppGlyphs.sliders),
                        title: appLocalizations.accessControlSettings,
                        chevron: true,
                        onTap: _handleToSetting,
                      ),
                    ],
                  ),
                  GroupedSearchField(
                    controller: _searchController,
                    hint: appLocalizations.search,
                    clearTooltip: appLocalizations.clearSearch,
                    onChanged: _onSearch,
                  ),
                ],
              ),
            ),
            Expanded(
              child: needsInstalledAppsPermission
                  ? _buildInstalledAppsPermissionStatus()
                  : DisabledMask(
                      status: !accessControl.enable,
                      child: _buildList(
                        packages: viewPackages,
                        selected: valueList.toSet(),
                        isSearching: query.isNotEmpty,
                        canSelectAll: canSelectAll,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

const _packageSeparatorInset = groupedRowPadding + 24 + groupedLeadingGap;

class PackageListItem extends StatelessWidget {
  final Package package;
  final bool value;
  final void Function(bool?) onChanged;

  const PackageListItem({
    super.key,
    required this.package,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GroupedRow(
      leading: PackageIcon(packageName: package.packageName, size: 24),
      leadingWidth: 24,
      title: package.label,
      subtitle: package.packageName,
      trailing: GroupedSelectMark(selected: value),
      onTap: () => onChanged(!value),
    );
  }
}

class AccessControlSettingsView extends ConsumerWidget {
  const AccessControlSettingsView({
    super.key,
    required this.onIntelligentSelected,
    required this.onExport,
    required this.onImport,
  });

  final VoidCallback onIntelligentSelected;
  final VoidCallback onExport;
  final VoidCallback onImport;

  Glyph _modeGlyph(AccessControlMode mode) {
    return switch (mode) {
      AccessControlMode.acceptSelected => AppGlyphs.checkCircle,
      AccessControlMode.rejectSelected => AppGlyphs.block,
    };
  }

  String _modeText(AppLocalizations appLocalizations, AccessControlMode mode) {
    return switch (mode) {
      AccessControlMode.acceptSelected => appLocalizations.whitelistMode,
      AccessControlMode.rejectSelected => appLocalizations.blacklistMode,
    };
  }

  String _sortText(AppLocalizations appLocalizations, AccessSortType type) {
    return switch (type) {
      AccessSortType.none => appLocalizations.defaultText,
      AccessSortType.name => appLocalizations.name,
      AccessSortType.time => appLocalizations.time,
    };
  }

  Glyph _sortGlyph(AccessSortType type) {
    return switch (type) {
      AccessSortType.none => AppGlyphs.sort,
      AccessSortType.name => AppGlyphs.sortAlpha,
      AccessSortType.time => AppGlyphs.clock,
    };
  }

  Widget _check(BuildContext context, bool selected) {
    if (!selected) {
      return const SizedBox.shrink();
    }
    return GlyphIcon(
      AppGlyphs.check,
      size: 18,
      color: GroupedPalette.of(context).icon,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final state = ref.watch(accessControlStateProvider);
    final notifier = ref.read(accessControlStateProvider.notifier);
    return GroupedPage(
      title: appLocalizations.accessControlSettings,
      onBack: () => Navigator.of(context).maybePop(),
      body: GroupedBody(
        children: [
          GroupedSection(
            header: appLocalizations.mode,
            children: [
              for (final item in AccessControlMode.values)
                GroupedRow(
                  key: ValueKey(item),
                  leading: GroupedIcon(_modeGlyph(item)),
                  title: _modeText(appLocalizations, item),
                  trailing: _check(context, state.mode == item),
                  onTap: () =>
                      notifier.update((state) => state.copyWith(mode: item)),
                ),
            ],
          ),
          const SizedBox(height: groupedSectionGap),
          GroupedSection(
            header: appLocalizations.sort,
            children: [
              for (final item in AccessSortType.values)
                GroupedRow(
                  key: ValueKey(item),
                  leading: GroupedIcon(_sortGlyph(item)),
                  title: _sortText(appLocalizations, item),
                  trailing: _check(context, state.sort == item),
                  onTap: () =>
                      notifier.update((state) => state.copyWith(sort: item)),
                ),
            ],
          ),
          const SizedBox(height: groupedSectionGap),
          GroupedSection(
            header: appLocalizations.source,
            children: [
              GroupedRow(
                title: appLocalizations.systemApp,
                trailing: GroupedSwitch(
                  value: !state.isFilterSystemApp,
                  onChanged: (_) => notifier.update(
                    (state) => state.copyWith(
                      isFilterSystemApp: !state.isFilterSystemApp,
                    ),
                  ),
                ),
              ),
              GroupedRow(
                title: appLocalizations.noNetworkApp,
                trailing: GroupedSwitch(
                  value: !state.isFilterNonInternetApp,
                  onChanged: (_) => notifier.update(
                    (state) => state.copyWith(
                      isFilterNonInternetApp: !state.isFilterNonInternetApp,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: groupedSectionGap),
          GroupedSection(
            header: appLocalizations.action,
            children: [
              GroupedRow(
                leading: const GroupedIcon(AppGlyphs.sparkle),
                title: appLocalizations.intelligentSelected,
                onTap: onIntelligentSelected,
              ),
              GroupedRow(
                leading: const GroupedIcon(AppGlyphs.copy),
                title: appLocalizations.clipboardExport,
                onTap: onExport,
              ),
              GroupedRow(
                leading: const GroupedIcon(AppGlyphs.paste),
                title: appLocalizations.clipboardImport,
                onTap: onImport,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
