part of '../general.dart';

const _minPort = 1024;
const _maxPort = 49151;

class _PortDialog extends ConsumerStatefulWidget {
  const _PortDialog();

  @override
  ConsumerState<_PortDialog> createState() => _PortDialogState();
}

class _PortDialogState extends ConsumerState<_PortDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: ref.read(coreSettingProvider).mixedPort.toString(),
    );
  }

  Future<void> _handleReset() async {
    final res = await dialogs.showMessage(
      message: TextSpan(text: context.appLocalizations.resetTip),
    );
    if (res != true) {
      return;
    }
    ref
        .read(coreSettingProvider.notifier)
        .update((state) => state.copyWith(mixedPort: defaultMixedPort));
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  void _handleUpdate() {
    if (validatePort(_controller.text, context.appLocalizations) != null) {
      _formKey.currentState?.validate();
      return;
    }
    ref
        .read(coreSettingProvider.notifier)
        .update(
          (state) => state.copyWith(mixedPort: int.parse(_controller.text)),
        );
    Navigator.of(context).pop();
  }

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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return CommonDialog(
      title: appLocalizations.port,
      actions: [
        TextButton(
          onPressed: _handleReset,
          child: Text(appLocalizations.reset),
        ),
        const SizedBox(width: 4),
        TextButton(
          onPressed: _handleUpdate,
          child: Text(appLocalizations.submit),
        ),
      ],
      child: Form(
        autovalidateMode: AutovalidateMode.onUserInteraction,
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: TextFormField(
            keyboardType: TextInputType.number,
            maxLines: 1,
            minLines: 1,
            inputFormatters: TextInputLimits.digitsOnly(TextInputLimits.port),
            controller: _controller,
            onFieldSubmitted: (_) => _handleUpdate(),
            decoration: InputDecoration(labelText: appLocalizations.mixedPort),
            validator: (value) => validatePort(value, appLocalizations),
          ),
        ),
      ),
    );
  }
}
