import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/widgets/sheet_header.dart';
import 'package:material_ui/material_ui.dart';

/// What a sheet shows in these tests: a drag handle, in a bottom sheet only,
/// and a title over [body]. They are the parts of a sheet page that the
/// sheet's drag logic and the tests look for.
class SheetTestPage extends StatelessWidget {
  const SheetTestPage({super.key, required this.body});

  final Widget body;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (context.isInBottomSheet) const SheetDragHandle(),
          const Padding(padding: EdgeInsets.all(8), child: Text('title')),
          Flexible(child: body),
        ],
      ),
    );
  }
}
