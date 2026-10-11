import 'package:country_flags/country_flags.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:material_ui/material_ui.dart';

import 'grouped_list.dart';

const regionFlagSize = 19.0;

/// The round flag of a country by its alpha-2 code, filling the circle.
class RegionFlag extends StatelessWidget {
  const RegionFlag({
    super.key,
    required this.code,
    this.size,
    this.fallback = AppGlyphs.home,
  });

  final String? code;
  final double? size;

  /// What stands in where there is no flag.
  final Glyph fallback;

  @override
  Widget build(BuildContext context) {
    final dimension = size ?? regionFlagSize;
    final code = this.code;
    if (code != null && FlagCode.fromCountryCode(code) != null) {
      return CountryFlag.fromCountryCode(
        code,
        theme: ImageTheme(
          width: dimension,
          height: dimension,
          shape: const Circle(),
        ),
      );
    }
    return SizedBox.square(
      dimension: dimension,
      child: DecoratedBox(
        decoration: ShapeDecoration(
          color: GroupedPalette.of(context).icon,
          shape: AppShape.full,
        ),
        child: Center(
          child: GlyphIcon(
            fallback,
            size: dimension * 13 / regionFlagSize,
            color: const Color(0xFFFFFFFF),
          ),
        ),
      ),
    );
  }
}
