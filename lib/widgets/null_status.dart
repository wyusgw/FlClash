import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/widgets/fade_box.dart';
import 'package:fl_clash/widgets/grouped_list.dart';
import 'package:material_ui/material_ui.dart';

enum NullStatusIllustration {
  data,
  logs,
  proxies,
  profile,
  scripts,
  rules,
  connections,
  requests,
  dns,
  ntp,
  wifi,
  apps,
  history,
  permission,
  camera,
  error,
  search,
}

class NullStatusSwitcher extends StatefulWidget {
  /// Only the first load is held back; later loads keep what is on screen.
  final bool isLoading;
  final bool isEmpty;
  final bool isSearching;
  final NullStatus nullStatus;
  final Widget child;

  const NullStatusSwitcher({
    super.key,
    this.isLoading = false,
    required this.isEmpty,
    this.isSearching = false,
    required this.nullStatus,
    required this.child,
  });

  @override
  State<NullStatusSwitcher> createState() => _NullStatusSwitcherState();
}

class _NullStatusSwitcherState extends State<NullStatusSwitcher> {
  static const _exitDuration = Duration(milliseconds: 150);

  late bool _loaded = !widget.isLoading;

  @override
  void didUpdateWidget(covariant NullStatusSwitcher oldWidget) {
    super.didUpdateWidget(oldWidget);
    _loaded = _loaded || !widget.isLoading;
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const SizedBox.expand();
    }
    return AnimatedSwitcher(
      duration: context.motionDuration(commonDuration),
      reverseDuration: context.motionDuration(_exitDuration),
      switchInCurve: Easing.emphasizedDecelerate,
      switchOutCurve: Curves.easeIn,
      layoutBuilder: (currentChild, previousChildren) => Align(
        alignment: Alignment.center,
        child: Stack(
          alignment: Alignment.center,
          fit: StackFit.expand,
          children: <Widget>[...previousChildren, ?currentChild],
        ),
      ),
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: animation.drive(Tween(begin: 0.92, end: 1.0)),
          child: child,
        ),
      ),
      child: switch ((widget.isEmpty, widget.isSearching)) {
        (true, true) => KeyedSubtree(
          key: const ValueKey(_NullStatusSlot.noResults),
          child: NullStatus(
            label: context.appLocalizations.noSearchResults,
            illustration: NullStatusIllustration.search,
          ),
        ),
        (true, false) => KeyedSubtree(
          key: const ValueKey(_NullStatusSlot.empty),
          child: widget.nullStatus,
        ),
        (false, _) => KeyedSubtree(
          key: const ValueKey(_NullStatusSlot.content),
          child: widget.child,
        ),
      },
    );
  }
}

enum _NullStatusSlot { empty, noResults, content }

class NullStatus extends StatelessWidget {
  final String label;
  final String? description;
  final Widget? action;
  final NullStatusIllustration illustration;

  const NullStatus({
    super.key,
    required this.label,
    this.description,
    this.action,
    this.illustration = NullStatusIllustration.data,
  });

  @override
  Widget build(BuildContext context) {
    final description = this.description;
    final action = this.action;
    final palette = GroupedPalette.of(context);
    final compact = MediaQuery.sizeOf(context).height < _compactHeight;
    return Align(
      alignment: const Alignment(0.0, -0.2),
      child: SingleChildScrollView(
        primary: false,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _EnterItem(
                child: EmptyIllustration(
                  type: illustration,
                  dimension: compact ? 120 : 160,
                ),
              ),
              SizedBox(height: compact ? 12 : 16),
              _EnterItem(
                delay: _staggerStep,
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: palette.headline.copyWith(fontSize: 20),
                ),
              ),
              if (description != null) ...[
                const SizedBox(height: 8),
                _EnterItem(
                  delay: _staggerStep * 2,
                  child: Text(
                    description,
                    textAlign: TextAlign.center,
                    style: palette.subhead.copyWith(color: palette.secondary),
                  ),
                ),
              ],
              if (action != null) ...[
                const SizedBox(height: 24),
                _EnterItem(
                  delay: _staggerStep * (description != null ? 3 : 2),
                  child: action,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

const _compactHeight = 560.0;
const _staggerStep = Duration(milliseconds: 60);
const _enterRise = 12.0;

bool _skipsEntrance(BuildContext context) {
  final route = ModalRoute.of(context);
  final routeEntering =
      route != null &&
      (route.offstage || (route.animation?.isAnimating ?? false));
  return context.disableAnimations || routeEntering;
}

class _EnterItem extends StatefulWidget {
  final Duration delay;
  final Widget child;

  const _EnterItem({this.delay = Duration.zero, required this.child});

  @override
  State<_EnterItem> createState() => _EnterItemState();
}

class _EnterItemState extends State<_EnterItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool? _skipped;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: commonDuration + widget.delay,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_skipped != null) {
      return;
    }
    _skipped = _skipsEntrance(context);
    if (!_skipped!) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final skipped = _skipped;
    if (skipped == null || skipped) {
      return widget.child;
    }
    final total = commonDuration + widget.delay;
    final start = widget.delay.inMicroseconds / total.inMicroseconds;
    final animation = start == 0
        ? _controller.view
        : _controller.drive(CurveTween(curve: Interval(start, 1)));
    return FadeSlideEnterTransition(
      animation: animation,
      distance: _enterRise,
      axis: Axis.vertical,
      child: widget.child,
    );
  }
}

/// The glyph of an empty state, large and bare in the grey of secondary text,
/// as iOS draws a screen with nothing to show; a failure is drawn in red.
class EmptyIllustration extends StatelessWidget {
  final NullStatusIllustration type;
  final double dimension;

  const EmptyIllustration({
    super.key,
    required this.type,
    required this.dimension,
  });

  static const _glyphShare = 0.5;

  @override
  Widget build(BuildContext context) {
    final palette = GroupedPalette.of(context);
    return SizedBox.square(
      key: ValueKey(type),
      dimension: dimension,
      child: Center(
        child: GlyphIcon(
          _glyphOf(type),
          size: dimension * _glyphShare,
          color: type == NullStatusIllustration.error
              ? groupedDanger
              : palette.secondary,
        ),
      ),
    );
  }

  static Glyph _glyphOf(NullStatusIllustration type) => switch (type) {
    NullStatusIllustration.data => AppGlyphs.resources,
    NullStatusIllustration.logs => AppGlyphs.logs,
    NullStatusIllustration.proxies => AppGlyphs.proxies,
    NullStatusIllustration.profile => AppGlyphs.profiles,
    NullStatusIllustration.scripts => AppGlyphs.code,
    NullStatusIllustration.rules => AppGlyphs.rules,
    NullStatusIllustration.connections => AppGlyphs.connections,
    NullStatusIllustration.requests => AppGlyphs.requests,
    NullStatusIllustration.dns => AppGlyphs.dns,
    NullStatusIllustration.ntp => AppGlyphs.clock,
    NullStatusIllustration.wifi => AppGlyphs.wifi,
    NullStatusIllustration.apps => AppGlyphs.appsList,
    NullStatusIllustration.history => AppGlyphs.history,
    NullStatusIllustration.permission => AppGlyphs.lock,
    NullStatusIllustration.camera => AppGlyphs.camera,
    NullStatusIllustration.error => AppGlyphs.error,
    NullStatusIllustration.search => AppGlyphs.search,
  };
}
