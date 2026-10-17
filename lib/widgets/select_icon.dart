import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:material_ui/material_ui.dart';

class SelectIcon extends StatelessWidget {
  const SelectIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.inversePrimary,
      shape: AppShape.circle,
      child: Container(
        padding: const EdgeInsets.all(4),
        child: const GlyphIcon(AppGlyphs.check, size: 16),
      ),
    );
  }
}
