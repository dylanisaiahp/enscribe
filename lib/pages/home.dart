import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../data/note.dart';
import '../data/card.dart';
import '../nav.dart';

/// Defines the different ways notes can be sorted on the home page.
enum NoteSortOrder {
  modifiedNewest,
  modifiedOldest,
  titleAscending,
  categoryAscending,
}

/// This widget represents the main home page where notes are displayed.
/// It receives the list of notes and user settings from the parent widget.
class HomePage extends StatefulWidget {
  final List<Note> notes;
  final Function(String originalNoteId, Note? modifiedNote) onNoteModified;
  final bool isGridView;
  final bool showCategory;
  final bool showDateTime;
  final NavBarPosition selectedNavBarPosition;

  const HomePage({
    super.key,
    required this.notes,
    required this.onNoteModified,
    required this.isGridView,
    required this.showCategory,
    required this.showDateTime,
    required this.selectedNavBarPosition,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

/// The state for the HomePage widget.
/// It manages the filtering, sorting, and display logic for notes.
class _HomePageState extends State<HomePage> {
  // State variables for search, sort, and filter features.
  String _searchQuery = '';
  late final FocusNode _searchFocusNode;
  NoteSortOrder _currentSortOrder = NoteSortOrder.modifiedNewest;
  Set<String> _selectedCategories = {};
  Set<String> _tempSelectedCategories = {};
  List<Note> _displayedNotes = [];
  bool _isLoading = true;
  Key _switcherKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    _searchFocusNode = FocusNode();
    _tempSelectedCategories = Set.from(_selectedCategories);
    _loadNotesWithDelay();
  }

  /// Called when the parent widget (HomeNavigation) updates.
  /// This is important to re-filter and re-sort notes if they change.
  @override
  void didUpdateWidget(covariant HomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.notes != widget.notes ||
        oldWidget.isGridView != widget.isGridView) {
      _filterAndSortNotes();
    }
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    super.dispose();
  }

  /// A small delay to show a loading indicator briefly when notes are reloaded.
  Future<void> _loadNotesWithDelay() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 100));
    _filterAndSortNotes();
    setState(() => _isLoading = false);
  }

  /// Retrieves all unique categories from the list of notes.
  Set<String> _getAllUniqueCategories() {
    return widget.notes
        .map((note) => note.category)
        .where((category) => category.isNotEmpty)
        .toSet();
  }

  /// Filters notes based on search query and selected categories, then sorts them.
  void _filterAndSortNotes() {
    final query = _searchQuery.trim().toLowerCase();

    // Filters notes based on the search query and selected categories.
    final filteredAndSorted = widget.notes.where((note) {
      final textMatches =
          query.isEmpty ||
          note.title.toLowerCase().contains(query) ||
          note.content.toLowerCase().contains(query);
      final categoryMatches =
          _selectedCategories.isEmpty ||
          _selectedCategories.contains(note.category);
      return textMatches && categoryMatches;
    }).toList();

    // Sorts the filtered notes based on the current sort order.
    filteredAndSorted.sort((a, b) {
      switch (_currentSortOrder) {
        case NoteSortOrder.modifiedNewest:
          return b.modified.compareTo(a.modified);
        case NoteSortOrder.modifiedOldest:
          return a.modified.compareTo(b.modified);
        case NoteSortOrder.titleAscending:
          return a.title.toLowerCase().compareTo(b.title.toLowerCase());
        case NoteSortOrder.categoryAscending:
          final categoryComparison = a.category.toLowerCase().compareTo(
            b.category.toLowerCase(),
          );
          // If categories are the same, sort by title.
          return categoryComparison != 0
              ? categoryComparison
              : a.title.toLowerCase().compareTo(b.title.toLowerCase());
      }
    });

    // Updates the state with the new list of notes to display.
    setState(() {
      _displayedNotes = filteredAndSorted;
      _switcherKey = UniqueKey();
    });
  }

  /// Shows a dialog to allow the user to filter notes by category.
  Future<void> _showFilterDialog() async {
    _tempSelectedCategories = Set.from(_selectedCategories);
    final uniqueCategories = _getAllUniqueCategories().toList()..sort();

    final result = await showDialog<Set<String>?>(
      context: context,
      builder: (dialogContext) {
        final theme = Theme.of(dialogContext);
        final accent = theme.colorScheme.tertiary;
        final background = theme.colorScheme.secondary;
        final onSurface = theme.colorScheme.onSurface;

        return AlertDialog(
          title: const Text('Filter by Category'),
          content: StatefulBuilder(
            builder: (context, setStateInsideDialog) {
              final allSelectedTemp =
                  _tempSelectedCategories.isEmpty ||
                  _tempSelectedCategories.length == uniqueCategories.length;

              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Option to select all categories.
                    CheckboxListTile(
                      title: const Text('All Categories'),
                      value: allSelectedTemp,
                      onChanged: (bool? newValue) {
                        setStateInsideDialog(() {
                          if (newValue == true) {
                            _tempSelectedCategories.clear();
                          } else {
                            _tempSelectedCategories = Set.from(
                              uniqueCategories,
                            );
                          }
                        });
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      activeColor: accent,
                    ),
                    const Divider(),
                    // Checkboxes for each unique category.
                    ...uniqueCategories.map((category) {
                      return CheckboxListTile(
                        title: Text(category),
                        value: _tempSelectedCategories.contains(category),
                        onChanged: (bool? newValue) {
                          setStateInsideDialog(() {
                            if (newValue == true) {
                              _tempSelectedCategories.add(category);
                            } else {
                              _tempSelectedCategories.remove(category);
                            }
                          });
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        activeColor: accent,
                      );
                    }),
                  ],
                ),
              );
            },
          ),
          actions: [
            // Cancel button for the dialog.
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: theme.brightness == Brightness.dark
                    ? Color.lerp(background, Colors.white, 0.1)
                    : Color.lerp(background, Colors.black, 0.1),
                foregroundColor: onSurface,
              ),
              onPressed: () => Navigator.of(dialogContext).pop(null),
              child: const Text('Cancel'),
            ),
            // Apply button to save the selected filters.
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: theme.brightness == Brightness.dark
                    ? Color.lerp(background, Colors.white, 0.1)
                    : Color.lerp(background, Colors.black, 0.1),
                foregroundColor: onSurface,
              ),
              onPressed: () {
                if (_tempSelectedCategories.length == uniqueCategories.length &&
                    uniqueCategories.isNotEmpty) {
                  _tempSelectedCategories.clear();
                }
                Navigator.of(dialogContext).pop(_tempSelectedCategories);
              },
              child: const Text('Apply'),
            ),
          ],
        );
      },
    );

    // If the user clicked apply, update the selected categories and re-filter notes.
    if (result != null) {
      setState(() {
        _selectedCategories = result;
        _filterAndSortNotes();
      });
    }
  }

  /// Returns either a ListView or a MasonryGridView based on the user's setting.
  Widget _buildListOrGrid() {
    // Shows a message if there are no notes.
    if (_displayedNotes.isEmpty) {
      return Center(
        key: const ValueKey('empty_notes'),
        child: Text(
          widget.notes.isEmpty
              ? 'You have no notes.'
              : 'No notes match your search.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withAlpha(153),
          ),
        ),
      );
    }

    // Displays notes in a staggered grid view.
    return widget.isGridView
        ? MasonryGridView.builder(
            key: const ValueKey('grid_view'),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _displayedNotes.length,
            crossAxisSpacing: 14,
            mainAxisSpacing: 0,
            gridDelegate: const SliverSimpleGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
            ),
            itemBuilder: (context, i) {
              final note = _displayedNotes[i];
              return NoteCard(
                key: ValueKey(note.id),
                note: note,
                onNoteModified: widget.onNoteModified,
                isGridViewMode: true,
                allNotes: widget.notes,
                showCategory: widget.showCategory,
                showDateTime: widget.showDateTime,
              );
            },
          )
        // Displays notes in a simple list view.
        : ListView.builder(
            key: const ValueKey('list_view'),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _displayedNotes.length,
            itemBuilder: (context, i) {
              final note = _displayedNotes[i];
              return NoteCard(
                key: ValueKey(note.id),
                note: note,
                onNoteModified: widget.onNoteModified,
                isGridViewMode: false,
                allNotes: widget.notes,
                showCategory: widget.showCategory,
                showDateTime: widget.showDateTime,
              );
            },
          );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final background = theme.colorScheme.secondary;
    final accent = theme.colorScheme.tertiary;
    final onPrimaryColor = theme.colorScheme.onPrimary;

    final bool isNavBarTop =
        widget.selectedNavBarPosition == NavBarPosition.top;

    return GestureDetector(
      // Tapping anywhere on the screen dismisses the keyboard.
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        body: SafeArea(
          top: !isNavBarTop,
          bottom: false,
          child: MediaQuery.removePadding(
            context: context,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search, filter, and sort bar.
                Padding(
                  padding: EdgeInsets.only(
                    top: 16,
                    bottom: 16,
                    left: 20,
                    right: 20,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          textCapitalization: TextCapitalization.sentences,
                          autocorrect: true,
                          enableSuggestions: true,
                          focusNode: _searchFocusNode,
                          autofocus: false,
                          onChanged: (q) {
                            setState(() => _searchQuery = q);
                            _filterAndSortNotes();
                          },
                          onTap: () {
                            if (!_searchFocusNode.hasFocus) {
                              _searchFocusNode.requestFocus();
                            }
                          },
                          decoration: InputDecoration(
                            hintText: 'Search notes...',
                            prefixIcon: const Icon(
                              Symbols.search_rounded,
                              fill: 1.0,
                            ),
                            suffixIcon: Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Filter button.
                                  Theme(
                                    data: theme.copyWith(
                                      checkboxTheme: CheckboxThemeData(
                                        fillColor:
                                            WidgetStateProperty.resolveWith<
                                              Color?
                                            >((states) {
                                              if (states.contains(
                                                WidgetState.selected,
                                              )) {
                                                return accent;
                                              }
                                              return null;
                                            }),
                                        checkColor: WidgetStateProperty.all(
                                          onPrimaryColor,
                                        ),
                                      ),
                                    ),
                                    child: IconButton(
                                      icon: const Icon(
                                        Symbols.filter_alt_rounded,
                                        fill: 1.0,
                                      ),
                                      onPressed: _showFilterDialog,
                                      tooltip: 'Filter by category',
                                      padding: EdgeInsets.zero,
                                    ),
                                  ),
                                  // Sort button.
                                  PopupMenuButton<NoteSortOrder>(
                                    icon: const Icon(Symbols.sort_rounded),
                                    tooltip: 'Sort notes',
                                    padding: EdgeInsets.zero,
                                    onSelected: (result) {
                                      setState(() {
                                        _currentSortOrder = result;
                                        _filterAndSortNotes();
                                      });
                                      _searchFocusNode.unfocus();
                                    },
                                    onCanceled: () {
                                      _searchFocusNode.unfocus();
                                    },
                                    itemBuilder: (context) => const [
                                      PopupMenuItem(
                                        value: NoteSortOrder.modifiedNewest,
                                        child: Text('Date (Newest)'),
                                      ),
                                      PopupMenuItem(
                                        value: NoteSortOrder.modifiedOldest,
                                        child: Text('Date (Oldest)'),
                                      ),
                                      PopupMenuItem(
                                        value: NoteSortOrder.titleAscending,
                                        child: Text('Title (A-Z)'),
                                      ),
                                      PopupMenuItem(
                                        value: NoteSortOrder.categoryAscending,
                                        child: Text('Category (A-Z)'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            filled: true,
                            fillColor: background,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 12,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: accent, width: 2),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // The main area where notes are displayed.
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    key: _switcherKey,
                    child: _isLoading
                        ? const Center(
                            key: ValueKey('loading_indicator'),
                            child: CircularProgressIndicator(),
                          )
                        : _buildListOrGrid(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
