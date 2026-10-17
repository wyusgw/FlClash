import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/widgets/inherited.dart';
import 'package:material_ui/material_ui.dart';

import 'card.dart';

class DecorationListItem extends StatelessWidget {
  final Widget title;
  final Widget? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final bool? isSelected;
  final double? horizontalTitleGap;
  final EdgeInsetsGeometry? contentPadding;
  final VoidCallback? onPressed;
  final double? minVerticalPadding;
  final bool invalid;

  const DecorationListItem({
    super.key,
    this.contentPadding,
    required this.title,
    this.leading,
    this.trailing,
    this.subtitle,
    this.isSelected,
    this.onPressed,
    this.horizontalTitleGap,
    this.minVerticalPadding,
    this.invalid = false,
  });

  @override
  Widget build(BuildContext context) {
    final proxyDecorator =
        ProxyDecoratorProvider.of(context)?.isProxyDecorator ?? false;
    final position = ItemPositionProvider.of(context)?.position;
    final isStart = [
      ItemPosition.start,
      ItemPosition.startAndEnd,
    ].contains(position);
    final isEnd = [
      ItemPosition.end,
      ItemPosition.startAndEnd,
    ].contains(position);
    final borderRadius = AppRadius.vertical(
      top: isStart ? AppCorner.xl : AppCorner.none,
      bottom: isEnd ? AppCorner.xl : AppCorner.none,
    );
    return CommonCard(
      shape: proxyDecorator == true
          ? LinearBorder.none
          : AppShape.of(borderRadius),
      isError: invalid,
      isSelected: isSelected,
      padding: EdgeInsets.zero,
      type: CommonCardType.filled,
      onPressed: proxyDecorator ? null : onPressed,
      child: LayoutBuilder(
        builder: (_, constraints) {
          final isInfinite = constraints.maxHeight >= double.infinity;
          final tile = ListTile(
            leading: leading,
            contentPadding:
                contentPadding ?? const EdgeInsets.only(right: 16, left: 16),
            title: title,
            subtitle: subtitle,
            minVerticalPadding: minVerticalPadding ?? 6,
            minTileHeight: 54,
            horizontalTitleGap: horizontalTitleGap,
            trailing: trailing,
          );
          return Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                fit: isInfinite ? FlexFit.loose : FlexFit.tight,
                child: tile,
              ),
              if (!invalid && proxyDecorator != true && !isEnd)
                const Divider(height: 0, indent: 14, endIndent: 14),
            ],
          );
        },
      ),
    );
  }
}
