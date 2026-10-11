import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/misc.dart' show ProviderListenable;

import 'grouped_list.dart';
import 'grouped_page.dart';
import 'input.dart';

export 'package:riverpod/misc.dart' show ProviderListenable;

typedef ConfigLabel = String Function(AppLocalizations appLocalizations);

typedef ConfigWriter<T> = void Function(WidgetRef ref, T value);

abstract class _ConfigItem<T> extends ConsumerWidget implements GroupedInset {
  const _ConfigItem({
    super.key,
    required this.selector,
    required this.title,
    required this.onChanged,
    this.subtitle,
    this.leading,
  });

  final ProviderListenable<T> selector;
  final ConfigLabel title;
  final ConfigLabel? subtitle;
  final ConfigWriter<T> onChanged;
  final Widget? leading;

  @override
  double get separatorInset => leading == null
      ? groupedRowPadding + 1
      : groupedRowPadding + groupedLeadingSize + groupedLeadingGap;

  Widget buildItem(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations appLocalizations,
    T value,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    return buildItem(context, ref, appLocalizations, ref.watch(selector));
  }

  String? buildSubtitle(AppLocalizations appLocalizations) {
    return subtitle?.call(appLocalizations);
  }
}

class ConfigToggleItem extends _ConfigItem<bool> {
  const ConfigToggleItem({
    super.key,
    required super.selector,
    required super.title,
    required super.onChanged,
    super.subtitle,
    super.leading,
  });

  @override
  Widget buildItem(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations appLocalizations,
    bool value,
  ) {
    return GroupedRow(
      leading: leading,
      title: title(appLocalizations),
      subtitle: buildSubtitle(appLocalizations),
      trailing: GroupedSwitch(
        value: value,
        onChanged: (value) => onChanged(ref, value),
      ),
      onTap: () => onChanged(ref, !value),
    );
  }
}

class ConfigOptionsItem<T> extends _ConfigItem<T> {
  const ConfigOptionsItem({
    super.key,
    required super.selector,
    required super.title,
    required super.onChanged,
    required this.options,
    required this.textBuilder,
    super.subtitle,
    super.leading,
  });

  final List<T> options;
  final String Function(T value) textBuilder;

  @override
  Widget buildItem(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations appLocalizations,
    T value,
  ) {
    return GroupedRow(
      leading: leading,
      title: title(appLocalizations),
      subtitle: buildSubtitle(appLocalizations),
      value: textBuilder(value),
      chevron: true,
      onTap: () => BaseNavigator.push(
        context,
        _ConfigChoicePage<T>(
          selector: selector,
          title: title(appLocalizations),
          options: options,
          textBuilder: textBuilder,
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _ConfigChoicePage<T> extends ConsumerWidget {
  const _ConfigChoicePage({
    required this.selector,
    required this.title,
    required this.options,
    required this.textBuilder,
    required this.onChanged,
  });

  final ProviderListenable<T> selector;
  final String title;
  final List<T> options;
  final String Function(T value) textBuilder;
  final ConfigWriter<T> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GroupedChoicePage<T>(
      title: title,
      choices: {for (final option in options) option: textBuilder(option)},
      selected: ref.watch(selector),
      onSelected: (value) => onChanged(ref, value),
    );
  }
}

class ConfigTextItem extends _ConfigItem<String> {
  const ConfigTextItem({
    super.key,
    required super.selector,
    required super.title,
    required super.onChanged,
    this.maxLength,
    this.keyboardType,
    this.validator,
    this.normalize,
    this.showValueAsSubtitle = true,
    super.subtitle,
    super.leading,
  });

  final int? maxLength;
  final TextInputType? keyboardType;
  final String? Function(String? value, AppLocalizations appLocalizations)?
  validator;
  final String Function(String value)? normalize;
  final bool showValueAsSubtitle;

  String? _normalize(String? value) {
    if (value == null) {
      return null;
    }
    return normalize?.call(value) ?? value;
  }

  @override
  Widget buildItem(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations appLocalizations,
    String value,
  ) {
    final label = title(appLocalizations);
    final validator = this.validator;
    return GroupedRow(
      leading: leading,
      title: label,
      subtitle: showValueAsSubtitle ? null : buildSubtitle(appLocalizations),
      value: showValueAsSubtitle ? value : null,
      onTap: () async {
        final input = await dialogs.showCommonDialog<String>(
          child: InputDialog(
            title: label,
            value: value,
            inputFormatters: maxLength == null
                ? null
                : TextInputLimits.limit(maxLength!),
            keyboardType: keyboardType,
            validator: (value) {
              final normalized = _normalize(value);
              if (normalized == null || normalized.isEmpty) {
                return appLocalizations.emptyTip(label);
              }
              return validator?.call(normalized, appLocalizations);
            },
          ),
        );
        final normalized = _normalize(input);
        if (normalized == null) {
          return;
        }
        onChanged(ref, normalized);
      },
    );
  }
}

class ConfigListEditItem extends _ConfigItem<List<String>> {
  const ConfigListEditItem({
    super.key,
    required super.selector,
    required super.title,
    required super.onChanged,
    this.itemMaxLength,
    super.subtitle,
    super.leading,
  });

  final int? itemMaxLength;

  @override
  Widget buildItem(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations appLocalizations,
    List<String> value,
  ) {
    final label = title(appLocalizations);
    return GroupedRow(
      leading: leading,
      title: label,
      subtitle: buildSubtitle(appLocalizations),
      value: value.isEmpty ? appLocalizations.none : value.join(', '),
      chevron: true,
      onTap: () async {
        final items = await BaseNavigator.push<Object>(
          context,
          ListEditView(
            title: label,
            items: value,
            itemMaxLength: itemMaxLength,
            titleBuilder: (item) => Text(item),
          ),
        );
        if (items is List) {
          onChanged(ref, List<String>.from(items));
        }
      },
    );
  }
}
