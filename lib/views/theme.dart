import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/foundation.dart' show mapEquals;
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ThemeView extends StatelessWidget {
  const ThemeView({super.key});

  static const _gap = SliverToBoxAdapter(
    child: SizedBox(height: groupedSectionGap),
  );

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return GroupedPage(
      title: appLocalizations.appearance,
      onBack: () => Navigator.of(context).maybePop(),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              groupedPageInset,
              13,
              groupedPageInset,
              20 + BottomInsetScope.of(context),
            ),
            sliver: const SliverMainAxisGroup(
              slivers: [
                _AppearanceItem(),
                _gap,
                _ColorsItem(),
                _gap,
                _TextScaleFactorItem(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _themeModeLabel(AppLocalizations appLocalizations, ThemeMode mode) {
  return switch (mode) {
    ThemeMode.system => appLocalizations.auto,
    ThemeMode.light => appLocalizations.light,
    ThemeMode.dark => appLocalizations.dark,
  };
}

/// Whether the app follows the system, or stays light or dark.
class _AppearanceItem extends ConsumerWidget {
  const _AppearanceItem();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    final themeMode = ref.watch(
      themeSettingProvider.select((state) => state.themeMode),
    );
    return SliverToBoxAdapter(
      child: GroupedSection(
        children: [
          GroupedRow(
            title: appLocalizations.appearance,
            value: _themeModeLabel(appLocalizations, themeMode),
            chevron: true,
            onTap: () => BaseNavigator.push(context, const _ThemeModeView()),
          ),
        ],
      ),
    );
  }
}

class _ThemeModeView extends ConsumerWidget {
  const _ThemeModeView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    return GroupedChoicePage<ThemeMode>(
      title: appLocalizations.appearance,
      choices: {
        for (final mode in ThemeMode.values)
          mode: _themeModeLabel(appLocalizations, mode),
      },
      selected: ref.watch(
        themeSettingProvider.select((state) => state.themeMode),
      ),
      onSelected: (mode) => ref
          .read(themeSettingProvider.notifier)
          .update((state) => state.copyWith(themeMode: mode)),
    );
  }
}

/// The colors of the grouped pages: change them, set them back, or hand them
/// to another install as a link.
class _ColorsItem extends ConsumerWidget {
  const _ColorsItem();

  Future<void> _reset(BuildContext context, WidgetRef ref) async {
    final res = await dialogs.showMessage(
      title: context.appLocalizations.confirm,
      message: TextSpan(text: context.appLocalizations.resetTip),
      confirmText: context.appLocalizations.reset,
      destructive: true,
    );
    if (res != true) {
      return;
    }
    ref
        .read(themeSettingProvider.notifier)
        .update((state) => state.copyWith(paletteColors: const {}));
  }

  Future<void> _copyLink(BuildContext context, WidgetRef ref) async {
    final stored = ref.read(
      themeSettingProvider.select((state) => state.paletteColors),
    );
    final link = buildColorLink(
      protocolSchemes.last,
      dark: GroupedPalette.dark.withOverrides(
        paletteOverridesFor(stored, Brightness.dark),
      ),
      light: GroupedPalette.light.withOverrides(
        paletteOverridesFor(stored, Brightness.light),
      ),
    );
    await Clipboard.setData(ClipboardData(text: link.toString()));
    if (context.mounted) {
      context.showNotifier(
        context.appLocalizations.copySuccess,
        level: MessageLevel.success,
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    return SliverToBoxAdapter(
      child: GroupedSection(
        header: appLocalizations.colors,
        children: [
          GroupedRow(
            title: appLocalizations.colors,
            chevron: true,
            onTap: () =>
                BaseNavigator.push(context, const AppearanceColorsView()),
          ),
          GroupedRow(
            title: appLocalizations.resetColors,
            chevron: true,
            onTap: () => unawaited(_reset(context, ref)),
          ),
          GroupedRow(
            title: appLocalizations.copyColorLink,
            chevron: true,
            onTap: () => unawaited(_copyLink(context, ref)),
          ),
        ],
      ),
    );
  }
}

/// Every color of the grouped pages for the look in use, as its hex value and
/// name beside a swatch; a tap changes one and Save keeps the lot.
class AppearanceColorsView extends ConsumerStatefulWidget {
  const AppearanceColorsView({super.key});

  @override
  ConsumerState<AppearanceColorsView> createState() =>
      _AppearanceColorsViewState();
}

const _colorGroups = [
  [
    GroupedColorToken.bar,
    GroupedColorToken.sidebarBar,
    GroupedColorToken.sidebar,
  ],
  [
    GroupedColorToken.canvas,
    GroupedColorToken.fill,
    GroupedColorToken.hover,
    GroupedColorToken.separator,
    GroupedColorToken.switchOff,
  ],
  [
    GroupedColorToken.label,
    GroupedColorToken.secondary,
    GroupedColorToken.tertiary,
  ],
  [GroupedColorToken.accent, GroupedColorToken.icon],
];

class _AppearanceColorsViewState extends ConsumerState<AppearanceColorsView> {
  late Brightness _brightness;
  Map<GroupedColorToken, int>? _initialColors;
  late Map<GroupedColorToken, int> _draft;
  final _hex = TextEditingController();
  final _focus = FocusNode();
  GroupedColorToken? _editing;

  Map<GroupedColorToken, int> get _initial => _initialColors!;

  @override
  void initState() {
    super.initState();
    _hex.addListener(() {
      if (_editing != null) {
        setState(() {});
      }
    });
    // Moving to another row hands the field over within a frame, so a lost
    // focus only ends editing if nothing took it back by the end of it.
    _focus.addListener(() {
      if (_focus.hasFocus) {
        return;
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_focus.hasFocus) {
          _commitEdit();
        }
      });
    });
  }

  @override
  void dispose() {
    _focus.dispose();
    _hex.dispose();
    super.dispose();
  }

  // The colors shown are the ones in force when the page opens; later changes
  // to the theme must not overwrite what is being edited.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialColors != null) {
      return;
    }
    _brightness = Theme.of(context).brightness;
    final palette = _base.withOverrides(
      paletteOverridesFor(
        ref.read(themeSettingProvider.select((state) => state.paletteColors)),
        _brightness,
      ),
    );
    _initialColors = {
      for (final token in GroupedColorToken.values)
        token: palette.colorOf(token).toARGB32(),
    };
    _draft = {..._initialColors!};
  }

  /// The colors with the value being typed counted in, once it is one.
  Map<GroupedColorToken, int> get _current {
    final token = _editing;
    final color = token == null ? null : parseColorHex(_hex.text);
    return color == null ? _draft : {..._draft, token!: color};
  }

  bool get _changed => !mapEquals(_current, _initial);

  GroupedPalette get _base => _brightness == Brightness.dark
      ? GroupedPalette.dark
      : GroupedPalette.light;

  /// Puts the value of the row in hand, if it is a color, and leaves editing.
  /// A value that is not one leaves the color as it was.
  void _commitEdit() {
    final token = _editing;
    if (token == null) {
      return;
    }
    final color = parseColorHex(_hex.text);
    setState(() {
      _editing = null;
      if (color != null) {
        _draft = {..._draft, token: color};
      }
    });
  }

  void _startEdit(GroupedColorToken token) {
    if (_editing == token) {
      return;
    }
    _commitEdit();
    _hex.value = TextEditingValue(
      text: colorHex(_draft[token]!),
      selection: TextSelection.collapsed(
        offset: colorHex(_draft[token]!).length,
      ),
    );
    setState(() => _editing = token);
  }

  void _save() {
    _commitEdit();
    ref.read(themeSettingProvider.notifier).update((state) {
      final colors = {...state.paletteColors};
      for (final token in GroupedColorToken.values) {
        final key = paletteKey(_brightness, token);
        if (_draft[token] == _base.colorOf(token).toARGB32()) {
          colors.remove(key);
        } else {
          colors[key] = _draft[token]!;
        }
      }
      return state.copyWith(paletteColors: colors);
    });
    Navigator.of(context).pop();
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
      _save();
      return;
    }
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Widget _row(GroupedColorToken token) {
    final palette = GroupedPalette.of(context);
    final color = _draft[token]!;
    final editing = _editing == token;
    final style = palette.rowTitle.toJetBrainsMono.copyWith(height: 1.4);
    final strut = StrutStyle.fromTextStyle(style, forceStrutHeight: true);
    return ColoredBox(
      color: editing ? palette.hover : Colors.transparent,
      child: GroupedRow(
        titleWidget: editing
            ? Row(
                children: [
                  Text('#', style: style, strutStyle: strut),
                  Expanded(
                    child: GroupedEditableText(
                      controller: _hex,
                      focusNode: _focus,
                      style: style,
                      strutStyle: strut,
                      cursorColor: palette.accent,
                      selectionColor: palette.accent.withValues(alpha: 0.3),
                      textCapitalization: TextCapitalization.characters,
                      keyboardType: TextInputType.visiblePassword,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp('[0-9a-fA-F]'),
                        ),
                        LengthLimitingTextInputFormatter(8),
                      ],
                      onSubmitted: (_) => _commitEdit(),
                    ),
                  ),
                ],
              )
            : Text('#${colorHex(color)}', style: style, strutStyle: strut),
        title: token.id,
        subtitle: token.id,
        trailing: DecoratedBox(
          decoration: ShapeDecoration(
            color: Color(color),
            shape: CircleBorder(side: BorderSide(color: palette.tertiary)),
          ),
          child: const SizedBox.square(dimension: 20),
        ),
        onTap: () => _startEdit(token),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return CommonPopScope(
      onPop: _changed
          ? (_) {
              unawaited(_handleBack());
              return false;
            }
          : null,
      child: GroupedPage(
        title: appLocalizations.colors,
        onBack: () => Navigator.of(context).maybePop(),
        trailing: GroupedBarAction(
          label: appLocalizations.save,
          tooltip: appLocalizations.save,
          onPressed: _changed ? _save : null,
        ),
        body: GroupedBody(
          children: [
            for (final (index, group) in _colorGroups.indexed) ...[
              if (index > 0) const SizedBox(height: groupedSectionGap),
              GroupedSection(
                children: [for (final token in group) _row(token)],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TextScaleFactorItem extends ConsumerStatefulWidget {
  const _TextScaleFactorItem();

  static const _step = 0.05;

  @override
  ConsumerState<_TextScaleFactorItem> createState() =>
      _TextScaleFactorItemState();
}

class _TextScaleFactorItemState extends ConsumerState<_TextScaleFactorItem> {
  double? _draft;

  void _update(TextScale Function(TextScale textScale) update) {
    setState(() => _draft = null);
    ref
        .read(themeSettingProvider.notifier)
        .update((state) => state.copyWith(textScale: update(state.textScale)));
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final palette = GroupedPalette.of(context);
    final textScale = ref.watch(
      themeSettingProvider.select((state) => state.textScale),
    );
    final systemScale = defaultTextScaleFactor
        .clamp(minTextScale, maxTextScale)
        .toDouble();
    final scale = _draft ?? (textScale.enable ? textScale.scale : systemScale);
    final percent = '${(scale * 100).round()}%';
    final divisions =
        ((maxTextScale - minTextScale) / _TextScaleFactorItem._step).round();
    return SliverToBoxAdapter(
      child: GroupedBlock(
        header: appLocalizations.textScale,
        actions: [
          if (textScale.enable && textScale.scale != defaultTextScale)
            GroupedIconAction(
              glyph: AppGlyphs.reset,
              tooltip: appLocalizations.reset,
              onPressed: () =>
                  _update((state) => state.copyWith(scale: defaultTextScale)),
            ),
        ],
        child: Column(
          spacing: 12,
          children: [
            _SegmentedToggle(
              value: textScale.enable,
              offLabel: appLocalizations.followSystem,
              onLabel: appLocalizations.custom,
              onChanged: (value) =>
                  _update((state) => state.copyWith(enable: value)),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 12,
              children: [
                Expanded(
                  child: AnimatedSize(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutCubic,
                    alignment: Alignment.topLeft,
                    child: MediaQuery(
                      data: MediaQuery.of(
                        context,
                      ).copyWith(textScaler: TextScaler.linear(scale)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 4,
                        children: [
                          Text(
                            'Aa',
                            style: context.textTheme.titleLarge?.copyWith(
                              color: palette.label,
                            ),
                          ),
                          Text(
                            appLocalizations.textScalePreview,
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: palette.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                DecoratedBox(
                  decoration: ShapeDecoration(
                    color: palette.separator,
                    shape: AppShape.full,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    child: Text(
                      percent,
                      style: palette.rowValue.copyWith(
                        color: palette.label,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            MediaQuery.withNoTextScaling(
              child: Row(
                spacing: 12,
                children: [
                  ExcludeSemantics(
                    child: Text('A', style: palette.rowSubtitle),
                  ),
                  Expanded(
                    child: SliderTheme(
                      data: SliderDefaultsM3(context).copyWith(
                        activeTrackColor: palette.accent,
                        inactiveTrackColor: palette.separator,
                        trackHeight: 4,
                        thumbShape: const _IosThumbShape(),
                        overlayShape: SliderComponentShape.noOverlay,
                        tickMarkShape: SliderTickMarkShape.noTickMark,
                        showValueIndicator: ShowValueIndicator.never,
                      ),
                      child: Slider(
                        padding: EdgeInsets.zero,
                        min: minTextScale,
                        max: maxTextScale,
                        divisions: divisions,
                        value: scale,
                        label: percent,
                        onChanged: textScale.enable
                            ? (value) => setState(() => _draft = value)
                            : null,
                        onChangeEnd: (value) =>
                            _update((state) => state.copyWith(scale: value)),
                      ),
                    ),
                  ),
                  ExcludeSemantics(child: Text('A', style: palette.title2)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SegmentedToggle extends StatelessWidget {
  const _SegmentedToggle({
    required this.value,
    required this.offLabel,
    required this.onLabel,
    required this.onChanged,
  });

  static const double _height = 36;
  static const double _inset = 3;

  final bool value;
  final String offLabel;
  final String onLabel;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final palette = GroupedPalette.of(context);
    return Container(
      height: _height,
      padding: const EdgeInsets.all(_inset),
      decoration: ShapeDecoration(
        color: palette.separator,
        shape: AppShape.full,
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            alignment: value
                ? AlignmentDirectional.centerEnd
                : AlignmentDirectional.centerStart,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              heightFactor: 1,
              child: DecoratedBox(
                decoration: ShapeDecoration(
                  color: palette.accent,
                  shape: AppShape.full,
                ),
              ),
            ),
          ),
          Row(
            children: [
              for (final (option, label) in [
                (false, offLabel),
                (true, onLabel),
              ])
                Expanded(
                  child: Semantics(
                    selected: option == value,
                    button: true,
                    child: Material(
                      type: MaterialType.transparency,
                      shape: AppShape.full,
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        customBorder: AppShape.full,
                        onTap: option == value ? null : () => onChanged(option),
                        child: Center(
                          child: AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            style: palette.rowTitle.copyWith(
                              color: option == value
                                  ? const Color(0xFFFFFFFF)
                                  : palette.secondary,
                              fontWeight: option == value
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                            ),
                            child: Text(
                              label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// The thumb of an iOS slider: a plain white disc with a soft shadow.
class _IosThumbShape extends SliderComponentShape {
  const _IosThumbShape();

  static const _radius = 14.0;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) =>
      const Size.fromRadius(_radius);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;
    canvas.drawCircle(
      center.translate(0, 2),
      _radius,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
    canvas.drawCircle(center, _radius, Paint()..color = Colors.white);
  }
}
