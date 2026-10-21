import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/common/dav_client.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/action.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/dialog.dart';
import 'package:fl_clash/widgets/fade_box.dart';
import 'package:fl_clash/widgets/grouped_input.dart';
import 'package:fl_clash/widgets/grouped_list.dart';
import 'package:fl_clash/widgets/grouped_page.dart';
import 'package:fl_clash/widgets/ios_controls.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BackupAndRestore extends ConsumerStatefulWidget {
  const BackupAndRestore({super.key});

  @override
  ConsumerState<BackupAndRestore> createState() => _BackupAndRestoreState();
}

class _BackupAndRestoreState extends ConsumerState<BackupAndRestore>
    with UniqueKeyStateMixin {
  final _davConnection = DAVConnectionController();

  @override
  void initState() {
    super.initState();
    ref.listenManual(davSettingProvider, (_, _) {
      _updateDAVClient();
    }, fireImmediately: true);
  }

  void _updateDAVClient() {
    unawaited(_davConnection.update(ref.read(davSettingProvider)));
  }

  @override
  void dispose() {
    _davConnection.dispose();
    super.dispose();
  }

  Future<void> _showAddWebDAV(DAVProps? dav) async {
    await BaseNavigator.push<void>(
      context,
      WebDAVFormPage(dav: dav?.copyWith()),
    );
  }

  Future<void> _run({
    required String title,
    required String successMessage,
    required Future<bool> Function() task,
  }) async {
    final res = await globalState.loadingRun<bool>(
      task,
      tag: LoadingTag.backup_restore,
      title: title,
    );
    if (res != true) return;
    dialogs.showNotifier(successMessage, level: MessageLevel.success);
  }

  Future<void> _backup(BackupDelivery deliver) {
    final appLocalizations = context.appLocalizations;
    return _run(
      title: appLocalizations.backup,
      successMessage: appLocalizations.backupSuccess,
      task: () => ref.read(backupActionProvider.notifier).backup(deliver),
    );
  }

  Future<void> _restore(RestoreOption option, BackupFetch fetch) {
    final appLocalizations = context.appLocalizations;
    return _run(
      title: appLocalizations.restore,
      successMessage: appLocalizations.restoreSuccess,
      task: () =>
          ref.read(backupActionProvider.notifier).restore(option, fetch),
    );
  }

  Future<RestoreOption?> _pickRestoreOption() {
    return dialogs.showCommonDialog<RestoreOption>(
      child: const RestoreOptionsDialog(),
    );
  }

  Future<void> _backupOnWebDAV() async {
    final client = _davConnection.client;
    if (client == null) return;
    await _backup((archivePath) async {
      await client.upload(archivePath);
      return true;
    });
  }

  Future<void> _restoreOnWebDAV() async {
    final client = _davConnection.client;
    if (client == null) return;
    final option = await _pickRestoreOption();
    if (option == null || !mounted) return;
    await _restore(option, (downloadPath) async {
      await client.download(downloadPath);
      return downloadPath;
    });
  }

  Future<void> _backupOnLocal() {
    return _backup((archivePath) async {
      final savedPath = await picker.saveFileWithPath(
        getBackupFileName(),
        archivePath,
      );
      return savedPath != null;
    });
  }

  Future<void> _restoreOnLocal() async {
    final option = await _pickRestoreOption();
    if (option == null || !mounted) return;
    final file = await picker.pickerFile();
    final path = file?.path;
    if (path == null || !mounted) return;
    await _restore(option, (_) async => path);
  }

  void _handleUpdateRestoreStrategy() {
    BaseNavigator.push(context, const _RestoreStrategyPage());
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final palette = GroupedPalette.of(context);
    final dav = ref.watch(davSettingProvider);
    final isLoading = ref.watch(loadingProvider(LoadingTag.backup_restore));
    Widget section(String header, List<Widget> children) {
      return Padding(
        padding: const EdgeInsets.only(bottom: groupedSectionGap),
        child: GroupedSection(header: header, children: children),
      );
    }

    Widget action(String label, VoidCallback onTap) {
      return GroupedRow(title: label, chevron: true, onTap: onTap);
    }

    return GroupedPage(
      title: appLocalizations.backupAndRestore,
      onBack: () => Navigator.of(context).maybePop(),
      body: Stack(
        children: [
          GroupedBody(
            children: [
              section(appLocalizations.remote, [
                if (dav == null)
                  GroupedRow(
                    leading: const GroupedIcon(AppGlyphs.account),
                    title: appLocalizations.noInfo,
                    subtitle: appLocalizations.pleaseBindWebDAV,
                    trailing: Text(
                      appLocalizations.bind,
                      style: palette.rowTitle.copyWith(color: palette.accent),
                    ),
                    onTap: () => _showAddWebDAV(dav),
                  )
                else ...[
                  GroupedRow(
                    leading: const GroupedIcon(AppGlyphs.account),
                    title: dav.user,
                    subtitleWidget: Row(
                      spacing: 6,
                      children: [
                        Text(appLocalizations.connectivity),
                        _DavConnectionIndicator(connection: _davConnection),
                      ],
                    ),
                    trailing: Text(
                      appLocalizations.edit,
                      style: palette.rowTitle.copyWith(color: palette.accent),
                    ),
                    onTap: () => _showAddWebDAV(dav),
                  ),
                  GroupedInputRow(
                    title: appLocalizations.file,
                    value: dav.fileName,
                    resetValue: defaultDavFileName,
                    inputFormatters: TextInputLimits.limit(
                      TextInputLimits.fileName,
                    ),
                    validator: (value) => value.isEmpty
                        ? appLocalizations.emptyTip(appLocalizations.file)
                        : null,
                    onSubmitted: (value) => ref
                        .read(davSettingProvider.notifier)
                        .update((state) => state?.copyWith(fileName: value)),
                  ),
                  action(appLocalizations.backup, _backupOnWebDAV),
                  action(appLocalizations.restore, _restoreOnWebDAV),
                ],
              ]),
              section(appLocalizations.local, [
                action(appLocalizations.backup, _backupOnLocal),
                action(appLocalizations.restore, _restoreOnLocal),
              ]),
              section(appLocalizations.options, [
                _RestoreStrategyItem(onPressed: _handleUpdateRestoreStrategy),
              ]),
            ],
          ),
          if (isLoading)
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: IosProgressBar(),
            ),
        ],
      ),
    );
  }
}

class _DavConnectionIndicator extends StatelessWidget {
  const _DavConnectionIndicator({required this.connection});

  final ValueNotifier<bool?> connection;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: connection,
      builder: (context, isConnected, _) {
        return Center(
          child: FadeThroughBox(
            child: isConnected == null
                ? const IosSpinner(size: 12)
                : Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: !isConnected
                          ? context.colorScheme.error
                          : context.colorScheme.success,
                    ),
                    width: 12,
                    height: 12,
                  ),
          ),
        );
      },
    );
  }
}

class _RestoreStrategyItem extends ConsumerWidget with GroupedPlainInset {
  const _RestoreStrategyItem({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final restoreStrategy = ref.watch(
      appSettingProvider.select((state) => state.restoreStrategy),
    );
    return GroupedRow(
      title: context.appLocalizations.restoreStrategy,
      value: restoreStrategy.label,
      chevron: true,
      onTap: onPressed,
    );
  }
}

class _RestoreStrategyPage extends ConsumerWidget {
  const _RestoreStrategyPage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GroupedChoicePage<RestoreStrategy>(
      title: context.appLocalizations.restoreStrategy,
      choices: {
        for (final strategy in RestoreStrategy.values) strategy: strategy.label,
      },
      selected: ref.watch(
        appSettingProvider.select((state) => state.restoreStrategy),
      ),
      onSelected: (strategy) => ref
          .read(appSettingProvider.notifier)
          .update((state) => state.copyWith(restoreStrategy: strategy)),
    );
  }
}

class RestoreOptionsDialog extends StatelessWidget {
  const RestoreOptionsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return ChoiceDialog<RestoreOption>(
      title: appLocalizations.restore,
      options: const [RestoreOption.onlyProfiles, RestoreOption.all],
      labelOf: (option) => switch (option) {
        RestoreOption.onlyProfiles => appLocalizations.restoreOnlyConfig,
        RestoreOption.all => appLocalizations.restoreAllData,
      },
    );
  }
}

class WebDAVFormPage extends ConsumerStatefulWidget {
  final DAVProps? dav;

  const WebDAVFormPage({super.key, this.dav});

  @override
  ConsumerState<WebDAVFormPage> createState() => _WebDAVFormPageState();
}

class _WebDAVFormPageState extends ConsumerState<WebDAVFormPage> {
  late TextEditingController _uriController;
  late TextEditingController _userController;
  late TextEditingController _passwordController;
  bool _obscure = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _uriController = TextEditingController(text: widget.dav?.uri);
    _userController = TextEditingController(text: widget.dav?.user);
    _passwordController = TextEditingController(text: widget.dav?.password);
  }

  String? _validate(AppLocalizations appLocalizations) {
    final uri = _uriController.text;
    if (uri.isEmpty || !uri.isUrl) {
      return appLocalizations.addressTip;
    }
    if (_userController.text.isEmpty) {
      return appLocalizations.emptyTip(appLocalizations.account);
    }
    if (_passwordController.text.isEmpty) {
      return appLocalizations.emptyTip(appLocalizations.password);
    }
    return null;
  }

  void _submit() {
    final error = _validate(context.appLocalizations);
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    ref
        .read(davSettingProvider.notifier)
        .update(
          (_) => DAVProps(
            uri: _uriController.text,
            user: _userController.text,
            password: _passwordController.text,
            fileName: widget.dav?.fileName ?? defaultDavFileName,
          ),
        );
    Navigator.pop(context);
  }

  Future<void> _delete() async {
    final confirmed = await dialogs.showMessage(
      title: 'WebDAV',
      message: TextSpan(
        text: context.appLocalizations.deleteTip(
          context.appLocalizations.webDAVConfiguration,
        ),
      ),
      destructive: true,
    );
    if (confirmed != true || !mounted) return;
    ref.read(davSettingProvider.notifier).update((_) => null);
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _uriController.dispose();
    _userController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final palette = GroupedPalette.of(context);
    final error = _error;
    return GroupedPage(
      title: appLocalizations.webDAVConfiguration,
      onBack: () => Navigator.of(context).maybePop(),
      trailing: GroupedBarAction(
        label: appLocalizations.save,
        tooltip: appLocalizations.save,
        onPressed: _submit,
      ),
      body: GroupedBody(
        children: [
          GroupedSection(
            footer: error == null ? appLocalizations.addressHelp : null,
            children: [
              GroupedFieldRow(
                label: appLocalizations.address,
                hint: appLocalizations.addressHelp,
                controller: _uriController,
                keyboardType: TextInputType.url,
                textInputAction: TextInputAction.next,
                inputFormatters: TextInputLimits.limit(TextInputLimits.uri),
              ),
              GroupedFieldRow(
                label: appLocalizations.account,
                hint: appLocalizations.account,
                controller: _userController,
                textInputAction: TextInputAction.next,
                inputFormatters: TextInputLimits.limit(
                  TextInputLimits.userName,
                ),
              ),
              GroupedFieldRow(
                label: appLocalizations.password,
                hint: appLocalizations.password,
                controller: _passwordController,
                obscure: _obscure,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
                inputFormatters: TextInputLimits.limit(
                  TextInputLimits.password,
                ),
                trailing: Tooltip(
                  message: _obscure
                      ? appLocalizations.showPassword
                      : appLocalizations.hidePassword,
                  child: InkResponse(
                    radius: 14,
                    onTap: () => setState(() => _obscure = !_obscure),
                    child: GlyphIcon(
                      _obscure ? AppGlyphs.eye : AppGlyphs.eyeOff,
                      size: 17,
                      color: palette.secondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (error != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                groupedRowPadding + 1,
                6,
                groupedRowPadding,
                0,
              ),
              child: Text(
                error,
                style: palette.sectionLabel.copyWith(
                  color: context.colorScheme.error,
                ),
              ),
            ),
          if (widget.dav != null) ...[
            const SizedBox(height: groupedSectionGap),
            GroupedSection(
              children: [
                GroupedRow(
                  leading: GroupedIcon(
                    AppGlyphs.delete,
                    color: context.colorScheme.error,
                  ),
                  title: appLocalizations.delete,
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
