import 'package:country_flags/country_flags.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';

const _nodeIconSize = 19.0;

/// A round flag for the country a node's name points at, filling the circle;
/// a name that points at none, or at a country the flag set lacks, gets the
/// plain house badge.
class NodeIcon extends StatelessWidget {
  const NodeIcon({super.key, required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final region = nodeRegionCode(name);
    if (region != null && FlagCode.fromCountryCode(region) != null) {
      return CountryFlag.fromCountryCode(
        region,
        theme: const ImageTheme(
          width: _nodeIconSize,
          height: _nodeIconSize,
          shape: Circle(),
        ),
      );
    }
    return SizedBox.square(
      dimension: _nodeIconSize,
      child: DecoratedBox(
        decoration: ShapeDecoration(
          color: GroupedPalette.of(context).icon,
          shape: AppShape.full,
        ),
        child: const Center(
          child: GlyphIcon(AppGlyphs.home, size: 13, color: Color(0xFFFFFFFF)),
        ),
      ),
    );
  }
}

void showNodeDetail(BuildContext context, Proxy node) {
  showExtend(
    context,
    builder: (context) {
      final appLocalizations = context.appLocalizations;
      return CommonScaffold(
        title: node.name,
        body: ListView(
          padding: EdgeInsets.fromLTRB(
            groupedPageInset,
            context.contentTopPadding,
            groupedPageInset,
            16,
          ),
          children: [
            GroupedSection(
              children: [
                GroupedRow(title: appLocalizations.name, value: node.name),
                GroupedRow(title: 'Type', value: node.type.toUpperCase()),
                if (node.network != null)
                  GroupedRow(
                    title: appLocalizations.network,
                    value: node.network!.toUpperCase(),
                  ),
                if (node.address != null)
                  GroupedRow(
                    title: appLocalizations.address,
                    value: node.address,
                  ),
              ],
            ),
          ],
        ),
      );
    },
  );
}
