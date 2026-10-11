import 'dart:math';

import 'package:animations/animations.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/views/dashboard/widget_metrics.dart';
import 'package:fl_clash/views/proxies/card.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'row_card.dart';

const _summaryGap = 8.0;

class ProxyGroupsCard extends ConsumerWidget {
  const ProxyGroupsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nodes = ref.watch(
      visibleGroupsStateProvider.select(
        (state) => state.value.getGroup(nodeGroupName),
      ),
    );
    return RowCardFrame(
      child: PageTransitionSwitcher(
        duration: context.motionDuration(commonDuration),
        transitionBuilder: (child, animation, secondaryAnimation) {
          return SharedAxisTransition(
            animation: animation,
            secondaryAnimation: secondaryAnimation,
            transitionType: SharedAxisTransitionType.horizontal,
            fillColor: Colors.transparent,
            child: child,
          );
        },
        child: nodes == null
            ? const _EmptyPane(key: ValueKey('empty'))
            : _ProxiesPane(key: const ValueKey('nodes'), group: nodes),
      ),
    );
  }
}

class _EmptyPane extends StatelessWidget {
  const _EmptyPane({super.key});

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    return RowCardPane(
      header: InfoHeader(
        padding: DashboardWidgetMetrics.paddingOf(context).copyWith(bottom: 0),
        info: Info(label: appLocalizations.proxies, glyph: AppGlyphs.proxies),
      ),
      body: RowCardEmpty(
        illustration: NullStatusIllustration.proxies,
        label: appLocalizations.nullTip(appLocalizations.proxies),
      ),
    );
  }
}

class _ProxiesPane extends ConsumerStatefulWidget {
  const _ProxiesPane({super.key, required this.group});

  final Group group;

  @override
  ConsumerState<_ProxiesPane> createState() => _ProxiesPaneState();
}

class _ProxiesPaneState extends ConsumerState<_ProxiesPane> {
  final _controller = RowSnapScrollController();
  var _revealedSelected = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _revealSelected(double itemExtent) {
    if (_revealedSelected) {
      return;
    }
    _revealedSelected = true;
    final selected = ref.read(selectedProxyNameProvider(widget.group.name));
    final index = widget.group.all.indexWhere(
      (proxy) => proxy.name == selected,
    );
    if (index <= 0) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_controller.hasClients) {
        return;
      }
      _controller.jumpTo(
        min(index * itemExtent, _controller.position.maxScrollExtent),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final group = widget.group;
    final selected = ref.watch(selectedProxyNameProvider(group.name));
    final headerPadding = DashboardWidgetMetrics.paddingOf(
      context,
    ).copyWith(bottom: 0);
    return RowCardPane(
      header: InfoHeader(
        padding: headerPadding,
        info: Info(
          label: context.appLocalizations.proxies,
          glyph: AppGlyphs.proxies,
        ),
      ),
      body: _buildProxies(group, selected),
    );
  }

  Widget _buildProxies(Group group, String? selected) {
    final colorScheme = context.colorScheme;
    return RowCardSlots(
      rowExtent: rowCardLineExtentOf(context),
      builder: (_, rowHeight, spacing) {
        final itemExtent = rowHeight + spacing;
        _controller.itemExtent = itemExtent;
        _revealSelected(itemExtent);
        return ListView.builder(
          controller: _controller,
          padding: EdgeInsets.zero,
          physics: const RowSnapScrollPhysics(),
          itemExtent: itemExtent,
          itemCount: group.all.length,
          itemBuilder: (_, index) {
            final proxy = group.all[index];
            final isSelected = proxy.name == selected;
            return Padding(
              padding: EdgeInsets.only(bottom: spacing),
              child: RowCardPill(
                color: isSelected ? colorScheme.secondaryContainer : null,
                onTap: () => selectGroupProxy(
                  ref,
                  groupName: group.name,
                  groupType: group.type,
                  proxyName: proxy.name,
                ),
                child: Row(
                  spacing: _summaryGap,
                  children: [
                    Expanded(
                      child: _RowLabel(
                        text: proxy.name,
                        color: isSelected
                            ? colorScheme.onSecondaryContainer
                            : null,
                      ),
                    ),
                    _ProxyDelay(proxyName: proxy.name, testUrl: group.testUrl),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _RowLabel extends StatelessWidget {
  const _RowLabel({required this.text, this.color});

  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return OverflowTooltipText(
      text: text,
      style: context.textTheme.bodyMedium?.copyWith(
        color: color ?? context.colorScheme.onSurface,
      ),
    );
  }
}

class _ProxyDelay extends ConsumerWidget {
  const _ProxyDelay({required this.proxyName, required this.testUrl});

  final String proxyName;
  final String? testUrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final delay = ref.watch(
      delayProvider(proxyName: proxyName, testUrl: testUrl),
    );
    if (delay == null) {
      return const SizedBox.shrink();
    }
    return Text(
      delay > 0 ? '$delay' : 'Timeout',
      maxLines: 1,
      style: context.textTheme.labelSmall?.copyWith(
        color: context.colorScheme.delayColor(delay),
      ),
    );
  }
}
