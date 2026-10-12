typedef TrayMenuItemSelectedCallback = void Function();

enum TrayShortcutModifier { control, option, shift, command }

/// A key equivalent that selects its item while the menu is open. [key] is the
/// character the key types, lower case, or the platform's function-key
/// character for keys that type none. Only macOS acts on it; `detail` is what
/// every platform shows.
final class TrayShortcut {
  const TrayShortcut({required this.key, this.modifiers = const {}});

  final String key;
  final Set<TrayShortcutModifier> modifiers;
}

/// How a `detail` is tinted. macOS maps each tone to its system color, which
/// follows light, dark and the highlighted row; other platforms draw plain text.
enum TrayDetailTone { success, warning, error }

/// An item with `busy` set shows a spinner in place of its `detail` while the
/// work behind it runs. Only macOS draws it; other platforms keep the `detail`.
sealed class TrayMenuItem {
  const TrayMenuItem();
}

final class TrayMenuAction extends TrayMenuItem {
  const TrayMenuAction({
    required this.label,
    this.detail,
    this.busy = false,
    this.shortcut,
    this.enabled = true,
    this.onSelected,
  });

  final String label;
  final String? detail;
  final bool busy;
  final TrayShortcut? shortcut;
  final bool enabled;
  final TrayMenuItemSelectedCallback? onSelected;
}

final class TrayMenuCheckbox extends TrayMenuItem {
  const TrayMenuCheckbox({
    required this.label,
    required this.checked,
    this.detail,
    this.detailTone,
    this.busy = false,
    this.shortcut,
    this.enabled = true,
    this.onSelected,
  });

  final String label;
  final bool checked;
  final String? detail;
  final TrayDetailTone? detailTone;
  final bool busy;
  final TrayShortcut? shortcut;
  final bool enabled;
  final TrayMenuItemSelectedCallback? onSelected;
}

final class TrayMenuSubmenu extends TrayMenuItem {
  const TrayMenuSubmenu({
    required this.label,
    required this.items,
    this.detail,
    this.detailTone,
    this.busy = false,
    this.enabled = true,
  });

  final String label;
  final List<TrayMenuItem> items;
  final String? detail;
  final TrayDetailTone? detailTone;
  final bool busy;
  final bool enabled;
}

final class TrayMenuSeparator extends TrayMenuItem {
  const TrayMenuSeparator();
}
