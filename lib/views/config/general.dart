import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/views/config/on_demand.dart';
import 'package:fl_clash/views/config/user_agents.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LogLevelItem extends ConsumerWidget {
  const LogLevelItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    return ConfigOptionsItem<LogLevel>(
      title: (l) => l.logLevel,
      options: LogLevel.values,
      textBuilder: (logLevel) => logLevel.name,
      selector: coreSettingProvider.select((state) => state.logLevel),
      onChanged: (ref, value) => ref
          .read(coreSettingProvider.notifier)
          .update((state) => state.copyWith(logLevel: value)),
    );
  }
}

class UaItem extends ConsumerWidget with GroupedPlainInset {
  const UaItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final appLocalizations = context.appLocalizations;
    final globalUa = ref.watch(
      appSettingProvider.select((state) => state.globalUa),
    );
    return GroupedRow(
      title: appLocalizations.userAgent,
      value: globalUa ?? appLocalizations.defaultText,
      chevron: true,
      onTap: () => BaseNavigator.push(context, const UserAgentsView()),
    );
  }
}

const _minPort = 1024;
const _maxPort = 49151;

@visibleForTesting
String? validatePort(String? value, AppLocalizations appLocalizations) {
  final label = appLocalizations.mixedPort;
  if (value == null || value.isEmpty) {
    return appLocalizations.emptyTip(label);
  }
  final port = int.tryParse(value);
  if (port == null) {
    return appLocalizations.numberTip(label);
  }
  if (port < _minPort || port > _maxPort) {
    return appLocalizations.portTip(label);
  }
  return null;
}

class PortItem extends ConsumerWidget with GroupedPlainInset {
  const PortItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final appLocalizations = context.appLocalizations;
    final mixedPort = ref.watch(
      coreSettingProvider.select((state) => state.mixedPort),
    );
    return GroupedInputRow(
      title: appLocalizations.port,
      value: '$mixedPort',
      resetValue: '$defaultMixedPort',
      keyboardType: TextInputType.number,
      inputFormatters: TextInputLimits.digitsOnly(TextInputLimits.port),
      validator: (value) => validatePort(value, appLocalizations),
      onSubmitted: (value) => ref
          .read(coreSettingProvider.notifier)
          .update((state) => state.copyWith(mixedPort: int.parse(value))),
    );
  }
}

class AuthenticationItem extends ConsumerWidget {
  const AuthenticationItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    return ConfigToggleItem(
      title: (l) => l.authentication,
      subtitle: (l) => l.authenticationDesc,
      selector: networkSettingProvider.select(
        (state) => state.authentication.enable,
      ),
      onChanged: (ref, value) =>
          ref.read(networkSettingProvider.notifier).update((state) {
            var authentication = state.authentication.copyWith(enable: value);
            if (value && authentication.username.isEmpty) {
              authentication = authentication.copyWith(
                username: generateRandomSecret(8),
                password: generateRandomSecret(16),
              );
            }
            return state.copyWith(authentication: authentication);
          }),
    );
  }
}

class AuthenticationAccountItem extends ConsumerWidget {
  const AuthenticationAccountItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    return ConfigTextItem(
      title: (l) => l.account,
      maxLength: TextInputLimits.userName,
      selector: networkSettingProvider.select(
        (state) => state.authentication.username,
      ),
      // The config builder and the Dart proxy string both split user:pass on
      // the first colon, so a colon in the username breaks authentication.
      normalize: (value) => value.trim().replaceAll(':', ''),
      onChanged: (ref, value) => ref
          .read(networkSettingProvider.notifier)
          .update((state) => state.copyWith.authentication(username: value)),
    );
  }
}

class AuthenticationPasswordItem extends ConsumerWidget {
  const AuthenticationPasswordItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    return ConfigTextItem(
      title: (l) => l.password,
      maxLength: TextInputLimits.password,
      selector: networkSettingProvider.select(
        (state) => state.authentication.password,
      ),
      normalize: (value) => value.trim(),
      onChanged: (ref, value) => ref
          .read(networkSettingProvider.notifier)
          .update((state) => state.copyWith.authentication(password: value)),
    );
  }
}

ConfigToggleItem _clashToggle({
  required ConfigLabel title,
  ConfigLabel? subtitle,
  required bool Function(CoreConfig state) select,
  required CoreConfig Function(CoreConfig state, bool value) update,
}) {
  return ConfigToggleItem(
    title: title,
    subtitle: subtitle,
    selector: coreSettingProvider.select(select),
    onChanged: (ref, value) => ref
        .read(coreSettingProvider.notifier)
        .update((state) => update(state, value)),
  );
}

ConfigToggleItem _appSettingToggle({
  required ConfigLabel title,
  ConfigLabel? subtitle,
  required bool Function(AppSettingProps state) select,
  required AppSettingProps Function(AppSettingProps state, bool value) update,
}) {
  return ConfigToggleItem(
    title: title,
    subtitle: subtitle,
    selector: appSettingProvider.select(select),
    onChanged: (ref, value) => ref
        .read(appSettingProvider.notifier)
        .update((state) => update(state, value)),
  );
}

class GeneralView extends ConsumerWidget {
  const GeneralView({super.key});

  List<Widget> _startupItems(
    BuildContext context,
    AppLocalizations appLocalizations,
  ) {
    return [
      if (system.isDesktop) ...[
        _appSettingToggle(
          title: (l) => l.autoLaunch,
          subtitle: (l) => l.autoLaunchDesc,
          select: (state) => state.autoLaunch,
          update: (state, value) => state.copyWith(autoLaunch: value),
        ),
        _appSettingToggle(
          title: (l) => l.silentLaunch,
          subtitle: (l) => l.silentLaunchDesc,
          select: (state) => state.silentLaunch,
          update: (state, value) => state.copyWith(silentLaunch: value),
        ),
      ],
      _appSettingToggle(
        title: (l) => l.autoRun,
        subtitle: (l) => l.autoRunDesc,
        select: (state) => state.autoRun,
        update: (state, value) => state.copyWith(autoRun: value),
      ),
      GroupedRow(
        title: appLocalizations.onDemand,
        subtitle: appLocalizations.onDemandDesc,
        chevron: true,
        onTap: () => BaseNavigator.push(context, const OnDemandView()),
      ),
      _appSettingToggle(
        title: (l) => l.minimizeOnExit,
        select: (state) => state.minimizeOnExit,
        update: (state, value) => state.copyWith(minimizeOnExit: value),
      ),
      if (system.isAndroid) ...[
        _appSettingToggle(
          title: (l) => l.exclude,
          subtitle: (l) => l.excludeDesc,
          select: (state) => state.hidden,
          update: (state, value) => state.copyWith(hidden: value),
        ),
        _appSettingToggle(
          title: (l) => l.showNotificationStopAction,
          select: (state) => state.showNotificationStopAction,
          update: (state, value) =>
              state.copyWith(showNotificationStopAction: value),
        ),
      ],
    ];
  }

  List<Widget> _inboundItems(bool authentication) {
    return [
      const PortItem(),
      _clashToggle(
        title: (l) => l.allowLan,
        select: (state) => state.allowLan,
        update: (state, value) => state.copyWith(allowLan: value),
      ),
      const AuthenticationItem(),
      if (authentication) ...const [
        AuthenticationAccountItem(),
        AuthenticationPasswordItem(),
      ],
    ];
  }

  List<Widget> _connectionItems() {
    return [
      _appSettingToggle(
        title: (l) => l.onlyStatisticsProxy,
        select: (state) => state.onlyStatisticsProxy,
        update: (state, value) => state.copyWith(onlyStatisticsProxy: value),
      ),
    ];
  }

  List<Widget> _requestItems() {
    return [
      const UaItem(),
      _appSettingToggle(
        title: (l) => l.checkCertificate,
        subtitle: (l) => l.checkCertificateDesc,
        select: (state) => state.checkCertificate,
        update: (state, value) => state.copyWith(checkCertificate: value),
      ),
      _appSettingToggle(
        title: (l) => l.geoRegion,
        subtitle: (l) => l.geoRegionDesc,
        select: (state) => state.geoRegion,
        update: (state, value) => state.copyWith(geoRegion: value),
      ),
      _appSettingToggle(
        title: (l) => l.autoCheckUpdate,
        select: (state) => state.autoCheckUpdate,
        update: (state, value) => state.copyWith(autoCheckUpdate: value),
      ),
    ];
  }

  List<Widget> _coreItems() {
    return [
      _clashToggle(
        title: (l) => 'IPv6',
        subtitle: (l) => l.ipv6Desc,
        select: (state) => state.ipv6,
        update: (state, value) => state.copyWith(ipv6: value),
      ),
    ];
  }

  List<Widget> _logItems() {
    return [
      const LogLevelItem(),
      _appSettingToggle(
        title: (l) => l.logcat,
        subtitle: (l) => l.logcatDesc,
        select: (state) => state.openLogs,
        update: (state, value) => state.copyWith(openLogs: value),
      ),
      if (system.isAndroid)
        _appSettingToggle(
          title: (l) => l.crashlytics,
          subtitle: (l) => l.crashlyticsTip,
          select: (state) => state.crashlytics,
          update: (state, value) => state.copyWith(crashlytics: value),
        ),
    ];
  }

  @override
  Widget build(BuildContext context, ref) {
    final appLocalizations = context.appLocalizations;
    final authentication = ref.watch(
      networkSettingProvider.select((state) => state.authentication.enable),
    );
    Widget section(String header, List<Widget> children) {
      return Padding(
        padding: const EdgeInsets.only(bottom: groupedSectionGap),
        child: GroupedSection(header: header, children: children),
      );
    }

    return GroupedPage(
      title: appLocalizations.general,
      onBack: () => Navigator.of(context).maybePop(),
      body: GroupedBody(
        children: [
          section(
            appLocalizations.startupAndBackground,
            _startupItems(context, appLocalizations),
          ),
          section(appLocalizations.requestsAndUpdates, _requestItems()),
          section(appLocalizations.inbound, _inboundItems(authentication)),
          section(appLocalizations.connection, _connectionItems()),
          section(appLocalizations.core, _coreItems()),
          section(appLocalizations.logsAndDiagnostics, _logItems()),
        ],
      ),
    );
  }
}
