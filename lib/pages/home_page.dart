import 'package:flutter/material.dart';

import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter/services.dart';
import '../data/card.dart';
import '../nav.dart';
import '../components/note_editor.dart';
import '../components/home_card_widgets.dart';
import '../components/home_animated_reveal.dart';
import '../components/home_helpers.dart';
import '../components/home_image_section.dart';

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

  // Cache for category calculations
  late Set<String> _cachedCategories;
  int _lastCardsLength = 0;

  // Multi-selection state
  bool _isSelectionMode = false;
  final Set<String> _selectedCardIds = {};

  // NEW: Animated/stagger reveal
  List<int> _animatedCardIndexes = [];

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
    _staggerRevealCards();
  }

  Set<String> _getAllUniqueCategories() {
    // Cache the result to improve performance
    if (_lastCardsLength != widget.cards.length) {
      _cachedCategories = widget.cards
          .map((card) => card.category)
          .where((category) => category != null && category.isNotEmpty)
          .cast<String>()
          .toSet();
      _lastCardsLength = widget.cards.length;
    }
    return _cachedCategories;
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
    });
  }

  void _enterSelectionMode(String cardId) {
    setState(() {
      _isSelectionMode = true;
      _selectedCardIds.add(cardId);
    });
  }

  void _exitSelectionMode() {
    setState(() {
      _isSelectionMode = false;
      _selectedCardIds.clear();
    });
  }

  void _toggleCardSelection(String cardId) {
    setState(() {
      if (_selectedCardIds.contains(cardId)) {
        _selectedCardIds.remove(cardId);
        if (_selectedCardIds.isEmpty) {
          _isSelectionMode = false;
        }
      } else {
        _selectedCardIds.add(cardId);
      }
    });
  }

  void _deleteSelectedCards() async {
    final selectedCards = _displayedCards
        .where((card) => _selectedCardIds.contains(card.id))
        .toList();

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete ${selectedCards.length} card${selectedCards.length == 1 ? '' : 's'}?',
        ),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Delete each selected card
      for (final card in selectedCards) {
        await widget.onCardModified(card.id, null);
      }
      _exitSelectionMode();
    }
  }

  void _shareSelectedCards() async {
    final selectedCards = _displayedCards
        .where((card) => _selectedCardIds.contains(card.id))
        .toList();

    if (selectedCards.isEmpty) return;

    // Create a formatted text of all selected cards
    final StringBuffer shareText = StringBuffer();

    for (int i = 0; i < selectedCards.length; i++) {
      final card = selectedCards[i];

      shareText.writeln('--- ${card.title} ---');

      if (card.category != null && card.category!.isNotEmpty) {
        shareText.writeln('Category: ${card.category}');
      }

      if (card.content != null && card.content!.isNotEmpty) {
        shareText.writeln(card.content);
      }

      if (card.tasks != null && card.tasks!.isNotEmpty) {
        shareText.writeln('Tasks:');
        for (final task in card.tasks!) {
          shareText.writeln('${task.isDone ? '✓' : '○'} ${task.text}');
        }
      }

      shareText.writeln('Created: ${formatDynamicDate(card.created, context)}');

      if (i < selectedCards.length - 1) {
        shareText.writeln('\n${'=' * 30}\n');
      }
    }

    // Copy to clipboard and show feedback
    await Clipboard.setData(ClipboardData(text: shareText.toString()));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${selectedCards.length} card${selectedCards.length == 1 ? '' : 's'} copied to clipboard',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }

    _exitSelectionMode();
  }

  Future<void> _showFilterDialog() async {
    _tempSelectedCategories = Set.from(_selectedCategories);
    final uniqueCategories = _getAllUniqueCategories().toList()
      ..sort();

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

  void _navigateToEditNote(CardData card) async {
    final uniqueCategories = _getAllUniqueCategories().toList()
      ..sort();

    final updatedNote = await Navigator.of(context).push<CardData>(
      MaterialPageRoute(
        builder: (context) => NoteEditor.edit(
          note: card,
          categories: uniqueCategories,
          onSave: (updatedNote) {
            Navigator.of(context).pop(updatedNote);
          },
          onBack: () {
            Navigator.of(context).pop();
          },
        ),
      ),
    );

    if (updatedNote != null) {
      widget.onCardModified(card.id, updatedNote);
    }
  }

  Widget _buildEmptyState() {
    return Center(
      key: const ValueKey('empty_cards'),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.note_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            widget.cards.isEmpty
                ? 'You have no entries.'
                : 'No entries match your search.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withAlpha(153),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _staggerRevealCards() async {
    setState(() {
      _animatedCardIndexes = [];
    });
    const delay = Duration(milliseconds: 70); // tweak for speed!
    for (int i = 0; i < _displayedCards.length; ++i) {
      await Future.delayed(delay);
      if (!mounted) return;
      setState(() {
        _animatedCardIndexes.add(i);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isNavBarTop =
        widget.selectedNavBarPosition == NavBarPosition.top;

    return Scaffold(
      appBar: _isSelectionMode
          ? AppBar(
              leading: IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: _exitSelectionMode,
              ),
              title: Text('${_selectedCardIds.length} selected'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.share_rounded),
                  onPressed: _shareSelectedCards,
                ),
                IconButton(
                  icon: const Icon(Icons.delete_rounded),
                  onPressed: _deleteSelectedCards,
                ),
              ],
            )
          : null,
      body: GestureDetector(
        onTap: () {
          // Unfocus search bar when tapping outside
          _searchFocusNode.unfocus();
        },
        child: SafeArea(
          top: !isNavBarTop,
          bottom: false,
          child: Column(
            children: [
              if (!_isSelectionMode) ...[
                // Search and filter UI
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
                          decoration: InputDecoration(
                            hintText: 'Search entries...',
                            prefixIcon: const Icon(Icons.search_rounded),
                            suffixIcon: Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.filter_alt_rounded),
                                    onPressed: _showFilterDialog,
                                    tooltip: 'Filter by category',
                                    padding: EdgeInsets.zero,
                                  ),
                                  PopupMenuButton<NoteSortOrder>(
                                    icon: const Icon(Icons.sort_rounded),
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
                            fillColor: Theme.of(context).colorScheme.secondary,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 12,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.tertiary,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              Expanded(
                child: _isLoading
                    ? const Center(
                        key: ValueKey('loading_indicator'),
                        child: CircularProgressIndicator(),
                      )
                    : _displayedCards.isEmpty
                    ? _buildEmptyState()
                    : _buildCardList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardList() {
    return widget.isGridView
        ? MasonryGridView.builder(
            key: const ValueKey('grid_view'),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _animatedCardIndexes.length,
            crossAxisSpacing: 14,
            mainAxisSpacing: 0,
            gridDelegate: const SliverSimpleGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
            ),
            itemBuilder: (context, i) {
              final cardIdx = _animatedCardIndexes[i];
              final card = _displayedCards[cardIdx];
              final isSelected = _selectedCardIds.contains(card.id);
              final formattedDate = formatDynamicDate(card.modified, context);
              final imageSection = gridCardImageSection(
                context,
                card,
                    (
                    {required String? imageUrl, required double width, required double height, BoxFit fit = BoxFit
                        .cover}) =>
                    buildImageWithFallback(context: context,
                        imageUrl: imageUrl,
                        width: width,
                        height: height,
                        fit: fit),
                widget.showCategory,
                widget.showDateTime,
                getOptimalTextColor,
                formattedDate,
              );
              return AnimatedCardReveal(
                index: i,
                child: buildGridCard(
                  context,
                  card,
                  isSelected,
                  widget.showCategory,
                  widget.showDateTime,
                  getOptimalTextColor,
                  formattedDate,
                  imageSection,
                  () {
                    if (_isSelectionMode) {
                      _toggleCardSelection(card.id);
                    } else {
                      _navigateToEditNote(card);
                    }
                  },
                  () {
                    if (!_isSelectionMode) {
                      _enterSelectionMode(card.id);
                    }
                  },
                ),
              );
            },
          )
        : ListView.builder(
            key: const ValueKey('list_view'),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _animatedCardIndexes.length,
            itemBuilder: (context, i) {
              final cardIdx = _animatedCardIndexes[i];
              final card = _displayedCards[cardIdx];
              final isSelected = _selectedCardIds.contains(card.id);
              final formattedDate = formatDynamicDate(card.modified, context);
              final imageSection = listCardImageSection(
                context,
                card,
                    (
                    {required String? imageUrl, required double width, required double height, BoxFit fit = BoxFit
                        .cover}) =>
                    buildImageWithFallback(context: context,
                        imageUrl: imageUrl,
                        width: width,
                        height: height,
                        fit: fit),
                widget.showCategory,
                widget.showDateTime,
                getOptimalTextColor,
                formattedDate,
              );
              return AnimatedCardReveal(
                index: i,
                child: buildListCard(
                  context,
                  card,
                  isSelected,
                  widget.showCategory,
                  widget.showDateTime,
                  getOptimalTextColor,
                  formattedDate,
                  imageSection,
                  () {
                    if (_isSelectionMode) {
                      _toggleCardSelection(card.id);
                    } else {
                      _navigateToEditNote(card);
                    }
                  },
                  () {
                    if (!_isSelectionMode) {
                      _enterSelectionMode(card.id);
                    }
                  },
                ),
              );
            },
          );
  }
}
