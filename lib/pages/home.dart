import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'dart:io';
import '../data/card.dart';
import '../nav.dart';

enum NoteSortOrder {
  modifiedNewest,
  modifiedOldest,
  titleAscending,
  categoryAscending,
}

class HomePage extends StatefulWidget {
  final List<CardData> cards;
  final Function(String originalCardId, CardData? modifiedCard) onCardModified;
  final bool isGridView;
  final bool showCategory;
  final bool showDateTime;
  final NavBarPosition selectedNavBarPosition;

  const HomePage({
    super.key,
    required this.cards,
    required this.onCardModified,
    required this.isGridView,
    required this.showCategory,
    required this.showDateTime,
    required this.selectedNavBarPosition,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _searchQuery = '';
  late final FocusNode _searchFocusNode;
  NoteSortOrder _currentSortOrder = NoteSortOrder.modifiedNewest;
  Set<String> _selectedCategories = {};
  Set<String> _tempSelectedCategories = {};
  List<CardData> _displayedCards = [];
  bool _isLoading = true;
  Key _switcherKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    _searchFocusNode = FocusNode();
    _tempSelectedCategories = Set.from(_selectedCategories);
    _loadCardsWithDelay();
  }

  @override
  void didUpdateWidget(covariant HomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.cards != widget.cards ||
        oldWidget.isGridView != widget.isGridView) {
      _filterAndSortCards();
    }
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadCardsWithDelay() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 100));
    _filterAndSortCards();
    setState(() => _isLoading = false);
  }

  Set<String> _getAllUniqueCategories() {
    return widget.cards
        .map((card) => card.category)
        .where((category) => category != null && category.isNotEmpty)
        .cast<String>()
        .toSet();
  }

  void _filterAndSortCards() {
    final query = _searchQuery.trim().toLowerCase();

    final filteredAndSorted = widget.cards.where((card) {
      final textMatches =
          query.isEmpty ||
          (card.title).toLowerCase().contains(query) ||
          (card.content ?? '').toLowerCase().contains(query);
      final categoryMatches =
          _selectedCategories.isEmpty ||
          _selectedCategories.contains(card.category ?? '');
      return textMatches && categoryMatches;
    }).toList();

    filteredAndSorted.sort((a, b) {
      switch (_currentSortOrder) {
        case NoteSortOrder.modifiedNewest:
          return b.modified.compareTo(a.modified);
        case NoteSortOrder.modifiedOldest:
          return a.modified.compareTo(b.modified);
        case NoteSortOrder.titleAscending:
          return (a.title).toLowerCase().compareTo((b.title).toLowerCase());
        case NoteSortOrder.categoryAscending:
          final categoryComparison = (a.category ?? '').toLowerCase().compareTo(
            (b.category ?? '').toLowerCase(),
          );
          return categoryComparison != 0
              ? categoryComparison
              : (a.title).toLowerCase().compareTo((b.title).toLowerCase());
      }
    });

    setState(() {
      _displayedCards = filteredAndSorted;
      _switcherKey = UniqueKey();
    });
  }

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

    if (result != null) {
      setState(() {
        _selectedCategories = result;
        _filterAndSortCards();
      });
    }
  }

  // Helper widget for text & category & datetime rows
  Widget _buildCardText(BuildContext context, CardData card) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          card.title.isNotEmpty ? card.title : 'Untitled',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Theme.of(context).colorScheme.tertiary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          (card.content?.isNotEmpty == true) ? card.content! : 'No content',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
          maxLines: widget.isGridView ? 8 : 5,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (widget.showCategory && (card.category?.isNotEmpty ?? false))
              Text(
                card.category!,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.white70),
              ),
            if (widget.showDateTime)
              Text(
                formatDynamicDate(card.modified),
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.white70),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildListOrGrid() {
    if (_displayedCards.isEmpty) {
      return Center(
        key: const ValueKey('empty_cards'),
        child: Text(
          widget.cards.isEmpty
              ? 'You have no entries.'
              : 'No entries match your search.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withAlpha(153),
          ),
        ),
      );
    }

    return widget.isGridView
        ? MasonryGridView.builder(
            key: const ValueKey('grid_view'),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _displayedCards.length,
            crossAxisSpacing: 14,
            mainAxisSpacing: 0,
            gridDelegate: const SliverSimpleGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
            ),
            itemBuilder: (context, i) {
              final card = _displayedCards[i];
              return GestureDetector(
                key: ValueKey(card.id),
                onTap: () {
                  // Your tap handler here
                },
                child: Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  color: Colors.transparent,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: card.imageUrl != null && card.imageUrl!.isNotEmpty
                        ? (card.imageIsBackground == 0
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Image.file(
                                      File(card.imageUrl!),
                                      width: double.infinity,
                                      height: 120,
                                      fit: BoxFit.cover,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: _buildCardText(context, card),
                                    ),
                                  ],
                                )
                              : Stack(
                                  children: [
                                    Positioned.fill(
                                      child: Image.file(
                                        File(card.imageUrl!),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Positioned.fill(
                                      child: Container(
                                        color:
                                            (card.backgroundColor ??
                                                    Theme.of(
                                                      context,
                                                    ).colorScheme.secondary)
                                                .withAlpha(128),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: _buildCardText(context, card),
                                    ),
                                  ],
                                ))
                        : Container(
                            color:
                                card.backgroundColor ??
                                Theme.of(context).colorScheme.secondary,
                            padding: const EdgeInsets.all(16.0),
                            child: _buildCardText(context, card),
                          ),
                  ),
                ),
              );
            },
          )
        : ListView.builder(
            key: const ValueKey('list_view'),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _displayedCards.length,
            itemBuilder: (context, i) {
              final card = _displayedCards[i];
              return GestureDetector(
                key: ValueKey(card.id),
                onTap: () {
                  // Your tap handler here
                },
                child: Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  color: Colors.transparent,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: card.imageUrl != null && card.imageUrl!.isNotEmpty
                        ? (card.imageIsBackground == 0
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Image.file(
                                      File(card.imageUrl!),
                                      width: double.infinity,
                                      height: 120,
                                      fit: BoxFit.cover,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: _buildCardText(context, card),
                                    ),
                                  ],
                                )
                              : Stack(
                                  children: [
                                    Positioned.fill(
                                      child: Image.file(
                                        File(card.imageUrl!),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Positioned.fill(
                                      child: Container(
                                        color:
                                            (card.backgroundColor ??
                                                    Theme.of(
                                                      context,
                                                    ).colorScheme.secondary)
                                                .withAlpha(128),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: _buildCardText(context, card),
                                    ),
                                  ],
                                ))
                        : Container(
                            color:
                                card.backgroundColor ??
                                Theme.of(context).colorScheme.secondary,
                            padding: const EdgeInsets.all(16.0),
                            child: _buildCardText(context, card),
                          ),
                  ),
                ),
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
                Padding(
                  padding: const EdgeInsets.only(
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
                            _filterAndSortCards();
                          },
                          onTap: () {
                            if (!_searchFocusNode.hasFocus) {
                              _searchFocusNode.requestFocus();
                            }
                          },
                          decoration: InputDecoration(
                            hintText: 'Search entries...',
                            prefixIcon: const Icon(
                              Symbols.search_rounded,
                              fill: 1.0,
                            ),
                            suffixIcon: Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
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
                                  PopupMenuButton<NoteSortOrder>(
                                    icon: const Icon(Symbols.sort_rounded),
                                    tooltip: 'Sort entries',
                                    padding: EdgeInsets.zero,
                                    onSelected: (result) {
                                      setState(() {
                                        _currentSortOrder = result;
                                        _filterAndSortCards();
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
