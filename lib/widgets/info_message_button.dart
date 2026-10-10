import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';

class InfoMessageButton extends StatelessWidget {
  final String message;

  const InfoMessageButton({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return CommonMinIconButtonTheme(
      child: IconButton(
        tooltip: context.appLocalizations.tip,
        onPressed: () {
          dialogs.showMessage(message: TextSpan(text: message));
        },
        icon: GlyphIcon(
          AppGlyphs.info,
          fill: 1,
          size: 20.ap,
          color: context.colorScheme.error,
        ),
      ),
    );
  }
}
