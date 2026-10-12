part of 'input.dart';

abstract class _EditViewState<W extends ConsumerStatefulWidget, T>
    extends ConsumerState<W> {
  List<T> _entries = [];
  late final List<T> _initialEntries;
  final _selectionKey = uniqueId;

  String get title;

  List<T> get initialEntries;

  String idOf(T entry);

  Widget buildTitle(T entry);

  Widget? buildSubtitle(T entry);

  Widget? buildLeading(T entry);

  bool sameEntries(List<T> a, List<T> b);

  Object popResult(List<T> entries);

  /// What is typed to edit [entry].
  String textOf(T entry);

  /// Why [text] cannot add a new entry, or edit [entry], or null when it can.
  String? validateText(String text, T? entry);

  /// The entries [text] makes: one to replace [entry], or any number to add.
  List<T> entriesOf(String text, T? entry);

  /// The name the row being typed in carries.
  String get inputLabel;

  int? get inputMaxLength => null;

  bool _adding = false;
  String? _editing;

  @override
  void initState() {
    super.initState();
    _entries = List<T>.from(initialEntries);
    _initialEntries = List<T>.from(_entries);
  }

  void _handleReorder(int oldIndex, int newIndex) {
    _entries = _entries.copyAndReorder(oldIndex, newIndex);
    setState(() {});
  }

  void _handleSelected(T entry) {
    ref.read(itemsProvider(_selectionKey).notifier).update((state) {
      final newState = Set<String>.from(state)..addOrRemove(idOf(entry));
      return newState;
    });
  }

  void _handleSelectAll() {
    final ids = _entries.map(idOf).toSet();
    ref.read(itemsProvider(_selectionKey).notifier).update((selected) {
      return selected.containsAll(ids) ? {} : ids;
    });
  }

  void _handleAdd() => setState(() {
    _adding = true;
    _editing = null;
  });

  void _handleEdit(T entry) => setState(() {
    _adding = false;
    _editing = idOf(entry);
  });

  void _handleEndInput() => setState(() {
    _adding = false;
    _editing = null;
  });

  void _commitInput(T? entry, String text) {
    final entries = entriesOf(text, entry);
    if (entries.isNotEmpty) {
      if (entry == null) {
        _entries = [..._entries, ...entries];
      } else {
        final id = idOf(entry);
        _entries = [
          for (final current in _entries)
            if (idOf(current) == id) entries.single else current,
        ];
      }
    }
    _handleEndInput();
  }

  Widget _buildInput({T? entry, Widget? leading}) {
    return GroupedInputRow(
      key: ValueKey(entry == null ? #add : idOf(entry)),
      leading: leading,
      title: inputLabel,
      value: entry == null ? '' : textOf(entry),
      startEditing: true,
      inputFormatters: inputMaxLength == null || entry == null
          ? null
          : TextInputLimits.limit(inputMaxLength!),
      validator: (text) => validateText(text, entry),
      onSubmitted: (text) => _commitInput(entry, text),
      onCancel: _handleEndInput,
    );
  }

  void _handleDelete() {
    final selected = ref.read(itemsProvider(_selectionKey));
    _entries = _entries
        .where((entry) => !selected.contains(idOf(entry)))
        .toList();
    ref.read(itemsProvider(_selectionKey).notifier).value = {};
    setState(() {});
  }

  Future<void> _handleReset() async {
    final res = await dialogs.showMessage(
      message: TextSpan(text: context.appLocalizations.resetPageChangesTip),
    );
    if (!mounted || res != true) {
      return;
    }
    _entries = _initialEntries;
    setState(() {});
  }

  Widget _buildEntry({
    required T entry,
    required int index,
    required bool isSelected,
  }) {
    final trailing = buildLeading(entry);
    final mark = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _handleSelected(entry),
      child: GroupedSelectMark(selected: isSelected),
    );
    return ReorderableDelayedDragStartListener(
      key: ValueKey(idOf(entry)),
      index: index,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (index > 0)
            const GroupedHairline(
              inset: groupedRowPadding + groupedLeadingSize + groupedLeadingGap,
            ),
          if (_editing == idOf(entry))
            _buildInput(entry: entry, leading: mark)
          else
            GroupedRow(
              leading: mark,
              title: idOf(entry),
              titleWidget: DefaultTextStyle.merge(
                style: GroupedPalette.of(context).rowTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                child: buildTitle(entry),
              ),
              subtitleWidget: buildSubtitle(entry),
              trailing: trailing,
              onTap: () => _handleEdit(entry),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    final selected = ref.watch(itemsProvider(_selectionKey));
    final isEditing = selected.isNotEmpty;
    final isChanged = !sameEntries(_entries, _initialEntries);
    Widget row(int index) {
      final entry = _entries[index];
      return _buildEntry(
        entry: entry,
        index: index,
        isSelected: selected.contains(idOf(entry)),
      );
    }

    return CommonPopScope(
      onPop: (_) {
        if (isEditing) {
          ref.read(itemsProvider(_selectionKey).notifier).value = {};
          return false;
        }
        Navigator.of(context).pop(popResult(_entries));
        return false;
      },
      child: GroupedPage(
        title: title,
        leadingActions: [
          GroupedBarAction(
            glyph: AppGlyphs.chevronBack,
            tooltip: appLocalizations.back,
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          if (isEditing)
            GroupedBarAction(
              glyph: AppGlyphs.delete,
              tooltip: appLocalizations.delete,
              onPressed: _handleDelete,
            )
          else if (isChanged)
            GroupedBarAction(
              glyph: AppGlyphs.reset,
              tooltip: appLocalizations.reset,
              onPressed: _handleReset,
            ),
        ],
        trailing: isEditing
            ? GroupedBarAction(
                label: appLocalizations.selectAll,
                tooltip: appLocalizations.selectAll,
                onPressed: _handleSelectAll,
              )
            : GroupedBarAction(
                label: appLocalizations.add,
                tooltip: appLocalizations.add,
                onPressed: _handleAdd,
              ),
        body: NullStatusSwitcher(
          isEmpty: _entries.isEmpty && !_adding,
          nullStatus: NullStatus(label: appLocalizations.noData),
          child: GroupedBody(
            children: [
              GroupedCard(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ReorderableListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      buildDefaultDragHandles: false,
                      itemCount: _entries.length,
                      itemBuilder: (context, index) => row(index),
                      proxyDecorator: (child, index, animation) => Material(
                        type: MaterialType.transparency,
                        child: child,
                      ),
                      onReorderItem: _handleReorder,
                    ),
                    if (_adding) ...[
                      if (_entries.isNotEmpty)
                        const GroupedHairline(
                          inset:
                              groupedRowPadding +
                              groupedLeadingSize +
                              groupedLeadingGap,
                        ),
                      _buildInput(),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ListEditView extends ConsumerStatefulWidget {
  final String title;
  final List<String> items;
  final Widget Function(String item) titleBuilder;
  final Widget Function(String item)? subtitleBuilder;
  final Widget Function(String item)? leadingBuilder;
  final String? valueLabel;
  final int? itemMaxLength;

  const ListEditView({
    super.key,
    required this.title,
    required this.items,
    required this.titleBuilder,
    this.leadingBuilder,
    this.valueLabel,
    this.subtitleBuilder,
    this.itemMaxLength,
  });

  @override
  ConsumerState<ListEditView> createState() => _ListEditViewState();
}

class _ListEditViewState extends _EditViewState<ListEditView, String> {
  @override
  String get title => widget.title;

  @override
  List<String> get initialEntries => widget.items;

  @override
  String idOf(String entry) => entry;

  @override
  Widget buildTitle(String entry) => widget.titleBuilder(entry);

  @override
  Widget? buildSubtitle(String entry) => widget.subtitleBuilder?.call(entry);

  @override
  Widget? buildLeading(String entry) => widget.leadingBuilder?.call(entry);

  @override
  bool sameEntries(List<String> a, List<String> b) =>
      stringListEquality.equals(a, b);

  @override
  Object popResult(List<String> entries) => entries;

  String get _valueLabel => widget.valueLabel ?? context.appLocalizations.value;

  @override
  String get inputLabel => _valueLabel;

  @override
  int? get inputMaxLength => widget.itemMaxLength;

  @override
  String textOf(String entry) => entry;

  @override
  String? validateText(String text, String? entry) {
    final appLocalizations = context.appLocalizations;
    final label = _valueLabel;
    final parsed = parseListInput(
      text,
      existing: {..._entries}..remove(entry),
      maxLength: widget.itemMaxLength,
    );
    if (!parsed.isValid) {
      return appLocalizations.maxLengthTip(label, widget.itemMaxLength!);
    }
    if (parsed.entries.isEmpty) {
      return parsed.skippedExisting > 0
          ? appLocalizations.existsTip(label)
          : appLocalizations.emptyTip(label);
    }
    if (entry != null && parsed.entries.length > 1) {
      return appLocalizations.singleValueTip(label);
    }
    return null;
  }

  /// A new entry may be several, set apart by commas or lines; the ones that
  /// are already in the list are left out.
  @override
  List<String> entriesOf(String text, String? entry) {
    return parseListInput(
      text,
      existing: {..._entries}..remove(entry),
      maxLength: widget.itemMaxLength,
    ).entries;
  }
}
