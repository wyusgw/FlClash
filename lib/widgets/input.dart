import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/widgets/dialog.dart';
import 'package:fl_clash/widgets/null_status.dart';
import 'package:fl_clash/widgets/pop_scope.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'grouped_input.dart';
import 'grouped_list.dart';
import 'grouped_page.dart';
import 'text_menu.dart';
part 'edit_view.dart';

class CommonCheckBox extends StatelessWidget {
  final bool? value;
  final ValueChanged<bool?>? onChanged;
  final bool isCircle;

  const CommonCheckBox({
    required this.value,
    required this.onChanged,
    this.isCircle = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Checkbox(
      materialTapTargetSize: MaterialTapTargetSize.padded,
      visualDensity: VisualDensity.standard,
      shape: isCircle ? AppShape.circle : null,
      value: value,
      onChanged: onChanged,
    );
  }
}

class InputDialog extends StatefulWidget {
  final String title;
  final String value;
  final String? suffixText;
  final String? labelText;
  final String? resetValue;
  final String? hintText;
  final FormFieldValidator<String>? validator;
  final AutovalidateMode? autovalidateMode;
  final bool? obscureText;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? keyboardType;

  const InputDialog({
    super.key,
    required this.title,
    required this.value,
    this.suffixText,
    this.resetValue,
    this.hintText,
    this.validator,
    this.obscureText,
    this.labelText,
    this.maxLength,
    this.inputFormatters,
    this.keyboardType,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
  });

  @override
  State<InputDialog> createState() => _InputDialogState();
}

class _InputDialogState extends State<InputDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _textController;

  String get value => widget.value;

  String get title => widget.title;

  String? get suffixText => widget.suffixText;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: value);
  }

  Future<void> _handleUpdate() async {
    if (_formKey.currentState?.validate() == false) return;
    final text = _textController.value.text;
    Navigator.of(context).pop<String>(text);
  }

  Future<void> _handleReset() async {
    if (widget.resetValue == null) {
      return;
    }
    Navigator.of(context).pop<String>(widget.resetValue);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final palette = GroupedPalette.of(context);
    final resettable =
        widget.resetValue != null &&
        _textController.value.text != widget.resetValue;
    return Dialog(
      backgroundColor: palette.bar,
      elevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      shape: AppShape.xxl,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 300),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: palette.rowTitle.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Flexible(
                child: SingleChildScrollView(
                  child: Form(
                    autovalidateMode: widget.autovalidateMode,
                    key: _formKey,
                    child: TextFormField(
                      maxLength: widget.maxLength,
                      inputFormatters: widget.inputFormatters,
                      obscureText: widget.obscureText ?? false,
                      keyboardType: widget.keyboardType ?? TextInputType.url,
                      maxLines: widget.obscureText == true ? 1 : 5,
                      minLines: 1,
                      controller: _textController,
                      cursorColor: palette.accent,
                      style: palette.rowTitle.copyWith(fontSize: 15),
                      contextMenuBuilder: systemTextContextMenu,
                      onChanged: (_) => setState(() {}),
                      onFieldSubmitted: (_) => _handleUpdate(),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: palette.hover,
                        border: const AppInputBorder(
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: const AppInputBorder(
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: const AppInputBorder(
                          borderSide: BorderSide.none,
                        ),
                        errorBorder: const AppInputBorder(
                          borderSide: BorderSide(color: groupedDanger),
                        ),
                        focusedErrorBorder: const AppInputBorder(
                          borderSide: BorderSide(color: groupedDanger),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        suffixText: suffixText,
                        hintText: widget.hintText,
                        labelText: widget.labelText,
                      ),
                      validator: widget.validator,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                spacing: 10,
                children: [
                  Expanded(
                    child: DialogButton(
                      label: resettable
                          ? appLocalizations.reset
                          : appLocalizations.cancel,
                      color: palette.hover,
                      foreground: palette.label,
                      onPressed: resettable
                          ? _handleReset
                          : () => Navigator.of(context).pop(),
                    ),
                  ),
                  Expanded(
                    child: DialogButton(
                      label: appLocalizations.submit,
                      color: palette.accent,
                      foreground: const Color(0xFFFFFFFF),
                      onPressed: _handleUpdate,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NoInputBorder extends InputBorder {
  const NoInputBorder() : super(borderSide: BorderSide.none);

  @override
  NoInputBorder copyWith({BorderSide? borderSide}) => const NoInputBorder();

  @override
  bool get isOutline => false;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  NoInputBorder scale(double t) => const NoInputBorder();

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()..addRect(rect);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return Path()..addRect(rect);
  }

  @override
  void paintInterior(
    Canvas canvas,
    Rect rect,
    Paint paint, {
    TextDirection? textDirection,
  }) {
    canvas.drawRect(rect, paint);
  }

  @override
  bool get preferPaintInterior => true;

  @override
  void paint(
    Canvas canvas,
    Rect rect, {
    double? gapStart,
    double gapExtent = 0.0,
    double gapPercentage = 0.0,
    TextDirection? textDirection,
  }) {}
}
