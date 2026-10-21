import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/common/permission.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/plugins/app.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi_ssid/wifi_ssid.dart';

class OnDemandView extends ConsumerStatefulWidget {
  const OnDemandView({super.key, this.isAndroid, this.isMacOS});

  final bool? isAndroid;
  final bool? isMacOS;

  @override
  ConsumerState createState() => _OnDemandViewState();
}

class _OnDemandViewState extends ConsumerState<OnDemandView>
    with UniqueKeyStateMixin {
  bool _requestingLocation = false;
  bool _adding = false;
  String? _editing;

  bool get _isAndroid => widget.isAndroid ?? system.isAndroid;

  bool get _isMacOS => widget.isMacOS ?? system.isMacOS;

  void _handlePermanentlyDeniedLocationPermission() {
    if (_isMacOS) {
      final appLocalizations = context.appLocalizations;
      dialogs.showMessage(
        title: appLocalizations.locationPermissionRequired,
        cancelable: false,
        message: TextSpan(
          style: context.textTheme.bodyMedium,
          text: appLocalizations.locationPermissionGuide(appName),
        ),
      );
    } else if (_isAndroid) {
      app?.openAppSettings();
    }
  }

  Future<void> _handleRequestLocationPermission() async {
    if (_requestingLocation) {
      return;
    }
    final appLocalizations = context.appLocalizations;
    final permission = ref.read(locationPermissionsProvider);
    if (permission == WifiSsidPermission.granted) {
      return;
    }
    if (permission == WifiSsidPermission.permanentlyDenied) {
      _handlePermanentlyDeniedLocationPermission();
      return;
    }
    final permissionsNotifier = ref.read(locationPermissionsProvider.notifier);
    final WifiSsidPermission res;
    _requestingLocation = true;
    try {
      res = await wifiSsidManager.requestPermission();
    } on PlatformException catch (e) {
      commonPrint.log('requestPermission error $e', logLevel: LogLevel.warning);
      return;
    } finally {
      _requestingLocation = false;
    }
    permissionsNotifier.value = res;
    if (!mounted) {
      return;
    }
    switch (getLocationPermissionFollowUp(res)) {
      case LocationPermissionFollowUp.none:
        return;
      case LocationPermissionFollowUp.openSettings:
        _handlePermanentlyDeniedLocationPermission();
        return;
      case LocationPermissionFollowUp.showDeniedMessage:
        break;
    }
    final needGo = await dialogs.showMessage(
      title: appLocalizations.locationPermissionRequired,
      message: TextSpan(text: appLocalizations.locationPermissionDeniedMessage),
      confirmText: appLocalizations.go,
    );
    if (needGo != true) {
      return;
    }
    unawaited(app?.openAppSettings());
  }

  void _handleOpenBatteryOptimizationSettings() {
    final isDisabled = ref.read(batteryOptimizationDisableProvider);
    if (isDisabled) {
      return;
    }
    permissions.needWaitingBatteryOptimizationSettings = true;
    app?.openBatteryOptimizationSettings();
  }

  void _handleAdd() => setState(() {
    _adding = true;
    _editing = null;
  });

  void _handleEdit(String ssid) => setState(() {
    _adding = false;
    _editing = ssid;
  });

  void _handleEndInput() => setState(() {
    _adding = false;
    _editing = null;
  });

  String? _validateSsid(String value, {String? current}) {
    final appLocalizations = context.appLocalizations;
    if (value.isEmpty) {
      return appLocalizations.emptyTip('SSID').trim();
    }
    if (value != current && ref.read(excludeSSIDsProvider).contains(value)) {
      return appLocalizations.existsTip('SSID').trim();
    }
    return null;
  }

  void _commitSsid(String? ssid, String newSSID) {
    ref.read(excludeSSIDsProvider.notifier).update((state) {
      if (ssid == null) {
        return [...state.toSet(), newSSID];
      }
      return [for (final item in state) item == ssid ? newSSID : item];
    });
    _handleEndInput();
  }

  Widget _buildInput({String? ssid, Widget? leading}) {
    return GroupedInputRow(
      key: ValueKey(ssid ?? #add),
      leading: leading,
      title: 'SSID',
      value: ssid ?? '',
      startEditing: true,
      inputFormatters: TextInputLimits.limit(32),
      validator: (value) => _validateSsid(value, current: ssid),
      onSubmitted: (value) => _commitSsid(ssid, value),
      onCancel: _handleEndInput,
    );
  }

  void _handleReorder(int oldIndex, newIndex) {
    ref.read(excludeSSIDsProvider.notifier).update((value) {
      return value.copyAndReorder(oldIndex, newIndex);
    });
  }

  void _handleSelectAll() {
    final excludeSSIDs = ref.read(excludeSSIDsProvider).toSet();
    ref.read(itemsProvider(key).notifier).update((selected) {
      return selected.containsAll(excludeSSIDs) ? {} : excludeSSIDs;
    });
  }

  void _handleDelete() {
    final selectedItems = ref.read(itemsProvider(key));
    ref.read(excludeSSIDsProvider.notifier).update((excludeSSIDs) {
      return excludeSSIDs
          .where((item) => !selectedItems.contains(item))
          .toList();
    });
    ref.read(itemsProvider(key).notifier).value = {};
  }

  Widget _buildStatus({required bool authorized, bool muted = false}) {
    final palette = GroupedPalette.of(context);
    final appLocalizations = context.appLocalizations;
    return Text(
      authorized
          ? appLocalizations.authorized
          : appLocalizations.tapToAuthorize,
      style: palette.rowValue.copyWith(
        color: muted
            ? palette.tertiary
            : (authorized ? palette.secondary : context.colorScheme.error),
      ),
    );
  }

  Widget _buildBatteryOptimizationSection({String? header}) {
    final appLocalizations = context.appLocalizations;
    // HyperOS takes a running VPN app off the battery optimization whitelist,
    // so the status reads as not authorized until the VPN stops.
    final isStart = ref.watch(isStartProvider);
    final isLoading = ref.watch(
      loadingProvider(LoadingTag.batteryOptimization),
    );
    final disabled = ref.watch(batteryOptimizationDisableProvider);
    return GroupedSection(
      header: header,
      footer: appLocalizations.batteryOptimizationDesc,
      children: [
        GroupedRow(
          title: appLocalizations.ignoreBatteryOptimization,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 8,
            children: [
              if (isStart)
                InfoMessageButton(
                  message: appLocalizations.batteryOptimizationStatusTip,
                ),
              if (!isStart && isLoading)
                const IosSpinner(size: 16)
              else
                _buildStatus(authorized: disabled, muted: isStart),
            ],
          ),
          onTap: isStart || isLoading
              ? null
              : _handleOpenBatteryOptimizationSettings,
        ),
      ],
    );
  }

  Widget _buildLocationPermissionSection({String? header}) {
    final appLocalizations = context.appLocalizations;
    final granted = ref.watch(
      locationPermissionsProvider.select(
        (state) => state == WifiSsidPermission.granted,
      ),
    );
    return GroupedSection(
      header: header,
      footer: appLocalizations.locationPermissionDesc,
      children: [
        GroupedRow(
          title: appLocalizations.locationPermission,
          trailing: _buildStatus(authorized: granted),
          onTap: _handleRequestLocationPermission,
        ),
      ],
    );
  }

  Widget _buildEntry(String ssid, int index, bool isSelected) {
    final mark = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        ref.read(itemsProvider(key).notifier).update((state) {
          return Set<String>.from(state)..addOrRemove(ssid);
        });
      },
      child: GroupedSelectMark(selected: isSelected),
    );
    return ReorderableDelayedDragStartListener(
      key: ValueKey(ssid),
      index: index,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (index > 0)
            const GroupedHairline(
              inset: groupedRowPadding + groupedLeadingSize + groupedLeadingGap,
            ),
          if (_editing == ssid)
            _buildInput(ssid: ssid, leading: mark)
          else
            GroupedRow(
              leading: mark,
              title: ssid,
              onTap: () => _handleEdit(ssid),
            ),
        ],
      ),
    );
  }

  Widget _buildExcludeSsids(List<String> excludeSSIDs, Set<dynamic> selected) {
    final appLocalizations = context.appLocalizations;
    final palette = GroupedPalette.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            groupedRowPadding + 1,
            0,
            groupedRowPadding,
            6,
          ),
          child: Text(
            appLocalizations.excludeSsids,
            style: palette.sectionLabel,
          ),
        ),
        if (excludeSSIDs.isEmpty && !_adding)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 36),
            child: NullStatus(
              label: appLocalizations.ssidsEmpty,
              illustration: NullStatusIllustration.wifi,
            ),
          )
        else
          GroupedCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ReorderableListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  buildDefaultDragHandles: false,
                  itemCount: excludeSSIDs.length,
                  itemBuilder: (_, index) => _buildEntry(
                    excludeSSIDs[index],
                    index,
                    selected.contains(excludeSSIDs[index]),
                  ),
                  proxyDecorator: (child, _, _) =>
                      Material(type: MaterialType.transparency, child: child),
                  onReorderItem: _handleReorder,
                ),
                if (_adding) ...[
                  if (excludeSSIDs.isNotEmpty)
                    const GroupedHairline(
                      inset:
                          groupedRowPadding +
                          groupedLeadingSize +
                          groupedLeadingGap,
                    ),
                  _buildInput(),
                ],
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            groupedRowPadding + 1,
            6,
            groupedRowPadding,
            0,
          ),
          child: Text(
            appLocalizations.excludeSsidsDesc,
            style: palette.sectionLabel,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final excludeSSIDs = ref.watch(excludeSSIDsProvider);
    final selectedItems = ref.watch(itemsProvider(key));
    final hasSelection = selectedItems.isNotEmpty;
    final prerequisites = [
      if (_isAndroid) _buildBatteryOptimizationSection,
      if (_isAndroid || _isMacOS) _buildLocationPermissionSection,
    ];
    return GroupedPage(
      title: appLocalizations.onDemand,
      leadingActions: [
        GroupedBarAction(
          glyph: AppGlyphs.chevronBack,
          tooltip: appLocalizations.back,
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        if (hasSelection)
          GroupedBarAction(
            glyph: AppGlyphs.delete,
            tooltip: appLocalizations.delete,
            onPressed: _handleDelete,
          ),
      ],
      trailing: hasSelection
          ? GroupedBarAction(
              label: appLocalizations.selectAll,
              tooltip: appLocalizations.selectAll,
              onPressed: _handleSelectAll,
            )
          : GroupedBarAction(
              label: appLocalizations.add,
              tooltip: appLocalizations.add,
              onPressed: _handleAdd,
            ),
      body: GroupedBody(
        children: [
          for (final (index, section) in prerequisites.indexed) ...[
            section(header: index == 0 ? appLocalizations.prerequisites : null),
            const SizedBox(height: groupedSectionGap),
          ],
          _buildExcludeSsids(excludeSSIDs, selectedItems),
        ],
      ),
    );
  }
}
