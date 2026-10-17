import 'package:fl_clash/widgets/sheet_header.dart';
import 'package:material_ui/material_ui.dart';

/// What a sheet shows in these tests: the drag handle over [body], the part of
/// a sheet page that the sheet's own drag logic looks for.
class SheetTestPage extends StatelessWidget {
  const SheetTestPage({super.key, required this.body});

  final Widget body;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SheetDragHandle(),
          Flexible(child: body),
        ],
      ),
    );
  }
}
