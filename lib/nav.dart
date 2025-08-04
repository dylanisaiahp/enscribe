import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:flutter/services.dart';
import 'pages/home.dart';
import 'pages/create.dart';
import 'pages/settings.dart';
import '../data/note.dart';
import 'data/themes.dart';

enum NavBarPosition { top, bottom, left, right }

class HomeNavigation extends StatefulWidget {
  final List<Note> notes;
  final Function(Note) onNoteCreated;
  final Function(String originalNoteId, Note? modifiedNote) onNoteModified;
  final EnscribeTheme selectedTheme;
  final void Function(EnscribeTheme) onThemeChanged;
  final bool isGridView;
  final bool showCategory;
  final bool showDateTime;
  final ValueChanged<bool> onToggleGridView;
  final ValueChanged<bool> onToggleDateTime;
  final ValueChanged<bool> onToggleCategory;

  final NavBarPosition selectedNavBarPosition; // <-- New
  final ValueChanged<NavBarPosition> onNavBarPositionChanged; // <-- New

  const HomeNavigation({
    super.key,
    required this.notes,
    required this.onNoteCreated,
    required this.onNoteModified,
    required this.selectedTheme,
    required this.onThemeChanged,
    required this.isGridView,
    required this.showCategory,
    required this.showDateTime,
    required this.onToggleGridView,
    required this.onToggleDateTime,
    required this.onToggleCategory,
    required this.selectedNavBarPosition,
    required this.onNavBarPositionChanged,
  });

  @override
  State<HomeNavigation> createState() => _HomeNavigationState();
}

class _HomeNavigationState extends State<HomeNavigation> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) => setState(() => _selectedIndex = index);

  Widget _buildNavigationBar(ThemeData theme) {
    final navBar = NavigationBar(
      backgroundColor: theme.colorScheme.surface,
      height: 72,
      elevation: 0,
      labelPadding: const EdgeInsets.only(top: 1),
      selectedIndex: _selectedIndex,
      onDestinationSelected: _onItemTapped,
      labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
      destinations: const [
        NavigationDestination(
          icon: Icon(Symbols.dashboard_rounded, fill: 0.0, size: 24),
          selectedIcon: Icon(Symbols.dashboard_rounded, fill: 1.0, size: 24),
          label: 'Notes',
        ),
        NavigationDestination(
          icon: Icon(Symbols.note_stack_add_rounded, fill: 0.0, size: 24),
          selectedIcon: Icon(
            Symbols.note_stack_add_rounded,
            fill: 1.0,
            size: 24,
          ),
          label: 'Create',
        ),
        NavigationDestination(
          icon: Icon(Symbols.settings_rounded, fill: 0.0, size: 24),
          selectedIcon: Icon(Symbols.settings_rounded, fill: 1.0, size: 24),
          label: 'Settings',
        ),
      ],
    );

    switch (widget.selectedNavBarPosition) {
      case NavBarPosition.top:
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(32),
          ),
          child: navBar,
        );
      case NavBarPosition.bottom:
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          child: navBar,
        );
      case NavBarPosition.left:
      case NavBarPosition.right:
        // For left or right, wrap in RotatedBox or a vertical container
        // but Flutter's NavigationBar is designed horizontally
        // You might want to build a custom vertical nav or use NavigationRail instead
        return SizedBox(
          width: 72,
          child: NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: _onItemTapped,
            labelType: NavigationRailLabelType.selected,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Symbols.dashboard_rounded, fill: 1.0),
                label: Text('Notes'),
              ),
              NavigationRailDestination(
                icon: Icon(Symbols.note_stack_add_rounded, fill: 1.0),
                label: Text('Create'),
              ),
              NavigationRailDestination(
                icon: Icon(Symbols.settings_rounded, fill: 1.0),
                label: Text('Settings'),
              ),
            ],
            groupAlignment: 0.0,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    late final Widget currentPage;
    switch (_selectedIndex) {
      case 0:
        currentPage = HomePage(
          notes: widget.notes,
          onNoteModified: widget.onNoteModified,
          isGridView: widget.isGridView,
          showCategory: widget.showCategory,
          showDateTime: widget.showDateTime,
          selectedNavBarPosition: widget.selectedNavBarPosition,
        );
        break;
      case 1:
        currentPage = CreateNotePage(
          onNoteCreated: (note) {
            widget.onNoteCreated(note);
            _onItemTapped(0);
          },
          allNotes: widget.notes,
          selectedNavBarPosition: widget.selectedNavBarPosition,
        );
        break;
      case 2:
        currentPage = SettingsPage(
          selectedTheme: widget.selectedTheme,
          onThemeChanged: widget.onThemeChanged,
          isGridView: widget.isGridView,
          onToggleView: widget.onToggleGridView,
          showCategory: widget.showCategory,
          showDateTime: widget.showDateTime,
          onToggleCategory: widget.onToggleCategory,
          onToggleDateTime: widget.onToggleDateTime,
          selectedNavBarPosition: widget.selectedNavBarPosition,
          onNavBarPositionChanged: widget.onNavBarPositionChanged,
        );
        break;
      default:
        currentPage = HomePage(
          notes: widget.notes,
          onNoteModified: widget.onNoteModified,
          isGridView: widget.isGridView,
          showCategory: widget.showCategory,
          showDateTime: widget.showDateTime,
          selectedNavBarPosition: widget.selectedNavBarPosition,
        );
    }

    Widget navigationBarWidget = _buildNavigationBar(theme);

    // Build layout depending on nav bar position
    switch (widget.selectedNavBarPosition) {
      case NavBarPosition.top:
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            systemNavigationBarColor: theme.colorScheme.secondary,
            systemNavigationBarIconBrightness:
                theme.brightness == Brightness.dark
                ? Brightness.light
                : Brightness.dark,
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: theme.brightness == Brightness.dark
                ? Brightness.light
                : Brightness.dark,
          ),
          child: Scaffold(
            body: Column(
              children: [
                navigationBarWidget,
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    reverseDuration: const Duration(milliseconds: 400),
                    transitionBuilder: (child, animation) {
                      final curved = CurvedAnimation(
                        parent: animation,
                        curve: Curves.decelerate,
                      );
                      final slide = Tween<Offset>(
                        begin: const Offset(1, 0),
                        end: Offset.zero,
                      ).animate(curved);
                      return SlideTransition(
                        position: slide,
                        child: FadeTransition(opacity: curved, child: child),
                      );
                    },
                    child: KeyedSubtree(
                      key: ValueKey(_selectedIndex),
                      child: currentPage,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );

      case NavBarPosition.bottom:
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            systemNavigationBarColor: theme.colorScheme.secondary,
            systemNavigationBarIconBrightness:
                theme.brightness == Brightness.dark
                ? Brightness.light
                : Brightness.dark,
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: theme.brightness == Brightness.dark
                ? Brightness.light
                : Brightness.dark,
          ),
          child: Scaffold(
            body: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              reverseDuration: const Duration(milliseconds: 400),
              transitionBuilder: (child, animation) {
                final curved = CurvedAnimation(
                  parent: animation,
                  curve: Curves.decelerate,
                );
                final slide = Tween<Offset>(
                  begin: const Offset(1, 0),
                  end: Offset.zero,
                ).animate(curved);
                return SlideTransition(
                  position: slide,
                  child: FadeTransition(opacity: curved, child: child),
                );
              },
              child: KeyedSubtree(
                key: ValueKey(_selectedIndex),
                child: currentPage,
              ),
            ),
            bottomNavigationBar: navigationBarWidget,
          ),
        );

      case NavBarPosition.left:
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            systemNavigationBarColor: theme.colorScheme.secondary,
            systemNavigationBarIconBrightness:
                theme.brightness == Brightness.dark
                ? Brightness.light
                : Brightness.dark,
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: theme.brightness == Brightness.dark
                ? Brightness.light
                : Brightness.dark,
          ),
          child: Scaffold(
            body: Row(
              children: [
                navigationBarWidget,
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    reverseDuration: const Duration(milliseconds: 400),
                    transitionBuilder: (child, animation) {
                      final curved = CurvedAnimation(
                        parent: animation,
                        curve: Curves.decelerate,
                      );
                      final slide = Tween<Offset>(
                        begin: const Offset(1, 0),
                        end: Offset.zero,
                      ).animate(curved);
                      return SlideTransition(
                        position: slide,
                        child: FadeTransition(opacity: curved, child: child),
                      );
                    },
                    child: KeyedSubtree(
                      key: ValueKey(_selectedIndex),
                      child: currentPage,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );

      case NavBarPosition.right:
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            systemNavigationBarColor: theme.colorScheme.secondary,
            systemNavigationBarIconBrightness:
                theme.brightness == Brightness.dark
                ? Brightness.light
                : Brightness.dark,
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: theme.brightness == Brightness.dark
                ? Brightness.light
                : Brightness.dark,
          ),
          child: Scaffold(
            body: Row(
              children: [
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    reverseDuration: const Duration(milliseconds: 400),
                    transitionBuilder: (child, animation) {
                      final curved = CurvedAnimation(
                        parent: animation,
                        curve: Curves.decelerate,
                      );
                      final slide = Tween<Offset>(
                        begin: const Offset(1, 0),
                        end: Offset.zero,
                      ).animate(curved);
                      return SlideTransition(
                        position: slide,
                        child: FadeTransition(opacity: curved, child: child),
                      );
                    },
                    child: KeyedSubtree(
                      key: ValueKey(_selectedIndex),
                      child: currentPage,
                    ),
                  ),
                ),
                navigationBarWidget,
              ],
            ),
          ),
        );
    }
  }
}
