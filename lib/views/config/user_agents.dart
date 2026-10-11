import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

List<String> _visibleUserAgents(List<String> saved, String? selected) =>
    {...saved, ?selected}.toList();

class UserAgentsView extends ConsumerStatefulWidget {
  const UserAgentsView({super.key});

  @override
  ConsumerState<UserAgentsView> createState() => _UserAgentsViewState();
}

class _UserAgentsViewState extends ConsumerState<UserAgentsView> {
  String? get _selected => ref.read(appSettingProvider).globalUa;

  List<String> get _entries =>
      _visibleUserAgents(ref.read(appSettingProvider).userAgents, _selected);

  void _save(List<String> userAgents) {
    ref
        .read(appSettingProvider.notifier)
        .update((state) => state.copyWith(userAgents: userAgents));
  }

  void _select(String? userAgent) {
    ref
        .read(appSettingProvider.notifier)
        .update((state) => state.copyWith(globalUa: userAgent));
  }

  Future<String?> _showInputDialog([String? userAgent]) async {
    final appLocalizations = context.appLocalizations;
    final entries = _entries;
    final res = await dialogs.showCommonDialog<String>(
      child: InputDialog(
        title: userAgent == null ? appLocalizations.add : appLocalizations.edit,
        value: userAgent ?? '',
        labelText: appLocalizations.userAgent,
        inputFormatters: [
          FilteringTextInputFormatter.singleLineFormatter,
          ...TextInputLimits.limit(TextInputLimits.userAgent),
        ],
        validator: (value) {
          final next = value?.trim() ?? '';
          if (next.isEmpty) {
            return appLocalizations.emptyTip(appLocalizations.userAgent);
          }
          if (next != userAgent && entries.contains(next)) {
            return appLocalizations.existsTip(appLocalizations.userAgent);
          }
          return null;
        },
      ),
    );
    return res?.trim();
  }

  Future<void> _handleAdd() async {
    final userAgent = await _showInputDialog();
    if (!mounted || userAgent == null) {
      return;
    }
    _save([..._entries, userAgent]);
  }

  Future<void> _handleEdit(String userAgent) async {
    final next = await _showInputDialog(userAgent);
    if (!mounted || next == null || next == userAgent) {
      return;
    }
    _save([for (final item in _entries) item == userAgent ? next : item]);
    if (_selected == userAgent) {
      _select(next);
    }
  }

  Future<void> _handleDelete(String userAgent) async {
    final appLocalizations = context.appLocalizations;
    final res = await dialogs.showMessage(
      title: appLocalizations.tip,
      message: TextSpan(
        text: appLocalizations.deleteTip(appLocalizations.userAgent),
      ),
    );
    if (!mounted || res != true) {
      return;
    }
    _save([..._entries]..remove(userAgent));
    if (_selected == userAgent) {
      _select(null);
    }
  }

  Widget _buildRow({
    required int index,
    required String label,
    required bool isSelected,
    required VoidCallback onSelected,
    Widget? menu,
  }) {
    final palette = GroupedPalette.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (index > 0) const GroupedHairline(inset: groupedRowPadding + 1),
        GroupedRow(
          title: label,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 8,
            children: [
              if (isSelected)
                GlyphIcon(AppGlyphs.check, size: 18, color: palette.icon),
              ?menu,
            ],
          ),
          onTap: onSelected,
        ),
      ],
    );
  }

  Widget _buildItem(List<String> entries, int index, String? selected) {
    final userAgent = entries[index];
    return _buildRow(
      index: index + 1,
      label: userAgent,
      isSelected: userAgent == selected,
      onSelected: () => _select(userAgent),
      menu: _UserAgentItemMenu(
        onEdit: () => _handleEdit(userAgent),
        onDelete: () => _handleDelete(userAgent),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final userAgents = ref.watch(
      appSettingProvider.select((state) => state.userAgents),
    );
    final selected = ref.watch(
      appSettingProvider.select((state) => state.globalUa),
    );
    final entries = _visibleUserAgents(userAgents, selected);
    return GroupedPage(
      title: appLocalizations.userAgent,
      onBack: () => Navigator.of(context).maybePop(),
      trailing: GroupedBarAction(
        label: appLocalizations.add,
        tooltip: appLocalizations.add,
        onPressed: _handleAdd,
      ),
      body: GroupedBody(
        children: [
          GroupedCard(
            child: ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              buildDefaultDragHandles: false,
              header: _buildRow(
                index: 0,
                label: appLocalizations.defaultText,
                isSelected: selected == null,
                onSelected: () => _select(null),
              ),
              itemCount: entries.length,
              itemBuilder: (_, index) {
                return ReorderableDelayedDragStartListener(
                  key: ValueKey(entries[index]),
                  index: index,
                  child: _buildItem(entries, index, selected),
                );
              },
              proxyDecorator: (_, index, animation) => Material(
                type: MaterialType.transparency,
                child: _buildItem(entries, index, selected),
              ),
              onReorderItem: (oldIndex, newIndex) {
                _save(entries.copyAndReorder(oldIndex, newIndex));
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _UserAgentItemMenu extends StatelessWidget {
  const _UserAgentItemMenu({required this.onEdit, required this.onDelete});

  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final palette = GroupedPalette.of(context);
    return CommonPopupBox(
      popupBuilder: (_) => CommonPopupMenu(
        items: [
          CommonPopupMenuItem(
            glyph: AppGlyphs.edit,
            label: appLocalizations.edit,
            onPressed: onEdit,
          ),
          CommonPopupMenuItem(
            danger: true,
            glyph: AppGlyphs.delete,
            label: appLocalizations.delete,
            onPressed: onDelete,
          ),
        ],
      ),
      targetBuilder: (open) {
        return Tooltip(
          message: appLocalizations.more,
          child: InkResponse(
            onTap: open,
            radius: 16,
            child: GlyphIcon(AppGlyphs.more, size: 19, color: palette.icon),
          ),
        );
      },
    );
  }
}
