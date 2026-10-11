import 'package:fl_clash/common/app_ports.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/icons/app_glyphs.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/views/views.dart';
import 'package:material_ui/material_ui.dart';

class Navigation implements NavigationPort {
  static Navigation? _instance;

  @override
  List<NavigationItem> getItems() {
    return [
      NavigationItem(
        keep: false,
        glyph: AppGlyphs.home,
        label: PageLabel.dashboard,
        builder: (_) =>
            const HomeView(key: GlobalObjectKey(PageLabel.dashboard)),
      ),
      NavigationItem(
        glyph: AppGlyphs.folder,
        label: PageLabel.profiles,
        builder: (_) =>
            const ProfilesView(key: GlobalObjectKey(PageLabel.profiles)),
      ),
      NavigationItem(
        glyph: AppGlyphs.pulse,
        label: PageLabel.logs,
        builder: (_) => const DataView(key: GlobalObjectKey(PageLabel.logs)),
      ),
      NavigationItem(
        glyph: AppGlyphs.settings,
        label: PageLabel.tools,
        builder: (_) => const ToolsView(key: GlobalObjectKey(PageLabel.tools)),
      ),
    ];
  }

  Navigation._internal();

  factory Navigation() {
    _instance ??= Navigation._internal();
    return _instance!;
  }
}

final navigation = Navigation();
