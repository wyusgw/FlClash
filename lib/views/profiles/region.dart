import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';

const _indexWidth = 18.0;

/// The flags to place a server under, by letter with a strip of letters at
/// the edge to jump by. Closing it with a pick hands back the alpha-2 code;
/// picking the one already chosen hands back an empty string, which leaves the
/// flag to the server's name and address again.
class RegionView extends StatefulWidget {
  const RegionView({super.key, required this.selected, this.detected});

  /// The code chosen so far; empty where the name and address decide.
  final String selected;

  /// What the name and address point at, checked while nothing is chosen.
  final String? detected;

  @override
  State<RegionView> createState() => _RegionViewState();
}

class _RegionViewState extends State<RegionView> {
  final _search = TextEditingController();
  final _scroll = ScrollController();
  final _sectionKeys = <String, GlobalKey>{};

  /// The country that carries the check: the one chosen, else the one found.
  String? get _checked =>
      widget.selected.isEmpty ? widget.detected : widget.selected;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final checked = _checked;
      final context = checked == null
          ? null
          : _sectionKeys[checked[0]]?.currentContext;
      if (context != null && context.mounted) {
        Scrollable.ensureVisible(context, alignment: 0.1);
      }
    });
  }

  @override
  void dispose() {
    _search.dispose();
    _scroll.dispose();
    super.dispose();
  }

  /// The countries that match the search, by first letter.
  Map<String, List<MapEntry<String, String>>> get _sections {
    final query = _search.text.trim().toLowerCase();
    final sections = <String, List<MapEntry<String, String>>>{};
    for (final entry in countryNames.entries) {
      if (query.isNotEmpty &&
          !entry.key.toLowerCase().contains(query) &&
          !entry.value.toLowerCase().contains(query)) {
        continue;
      }
      sections.putIfAbsent(entry.key[0], () => []).add(entry);
    }
    return sections;
  }

  void _jumpTo(String letter) {
    final context = _sectionKeys[letter]?.currentContext;
    if (context == null) return;
    Scrollable.ensureVisible(context, alignment: 0);
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final palette = GroupedPalette.of(context);
    Widget? check(bool on) =>
        on ? GlyphIcon(AppGlyphs.check, size: 18, color: palette.icon) : null;
    final sections = _sections;
    final checked = _checked;
    return GroupedPage(
      title: appLocalizations.flag,
      onBack: () => Navigator.of(context).maybePop(),
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scroll,
            padding: EdgeInsets.fromLTRB(
              groupedPageInset,
              13,
              groupedPageInset + _indexWidth,
              20 + BottomInsetScope.of(context),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GroupedSearchField(
                  controller: _search,
                  hint: appLocalizations.search,
                  clearTooltip: appLocalizations.clearSearch,
                  onChanged: (_) => setState(() {}),
                ),
                for (final MapEntry(key: letter, value: entries)
                    in sections.entries) ...[
                  const SizedBox(height: groupedSectionGap),
                  KeyedSubtree(
                    key: _sectionKeys.putIfAbsent(letter, GlobalKey.new),
                    child: GroupedSection(
                      header: letter,
                      children: [
                        for (final entry in entries)
                          GroupedRow(
                            key: ValueKey(entry.key),
                            leading: RegionFlag(code: entry.key),
                            title: entry.key,
                            trailing: check(entry.key == checked),
                            onTap: () => Navigator.of(context).pop(
                              entry.key == widget.selected ? '' : entry.key,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (sections.isNotEmpty)
            PositionedDirectional(
              end: 0,
              top: 0,
              bottom: 0,
              width: _indexWidth,
              child: _LetterIndex(
                letters: sections.keys.toList(),
                onSelected: _jumpTo,
              ),
            ),
        ],
      ),
    );
  }
}

/// A column of letters at the edge that jumps to the section of the one
/// touched, and follows a finger dragged along it.
class _LetterIndex extends StatelessWidget {
  const _LetterIndex({required this.letters, required this.onSelected});

  final List<String> letters;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final palette = GroupedPalette.of(context);
    return LayoutBuilder(
      builder: (context, box) {
        final step = (box.maxHeight / letters.length).clamp(0.0, 18.0);
        void pick(double dy) {
          final index = (dy / step).floor().clamp(0, letters.length - 1);
          onSelected(letters[index]);
        }

        return Center(
          child: SizedBox(
            height: step * letters.length,
            child: Listener(
              behavior: HitTestBehavior.opaque,
              onPointerDown: (event) => pick(event.localPosition.dy),
              onPointerMove: (event) => pick(event.localPosition.dy),
              child: Column(
                children: [
                  for (final letter in letters)
                    SizedBox(
                      height: step,
                      child: Center(
                        child: Text(
                          letter,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: palette.accent,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
