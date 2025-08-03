import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:flutter/services.dart';
import 'pages/home.dart';
import 'pages/create.dart';
import 'pages/settings.dart';
import '../data/note.dart';
import 'data/themes.dart';

/// This widget handles the main navigation for the app.
/// It uses a bottom navigation bar to switch between three main pages:
/// Home, Create, and Settings.
class HomeNavigation extends StatefulWidget {
  // A list of all the notes.
  final List<Note> notes;
  // A function to call when a new note is created.
  final Function(Note) onNoteCreated;
  // A function to call when a note is changed or deleted.
  final Function(String originalNoteId, Note? modifiedNote) onNoteModified;
  // The theme that is currently selected.
  final EnscribeTheme selectedTheme;
  // A function to call when the theme is changed.
  final void Function(EnscribeTheme) onThemeChanged;
  // True if the notes should be shown in a grid view.
  final bool isGridView;
  // True if the note category should be shown.
  final bool showCategory;
  // True if the note date and time should be shown.
  final bool showDateTime;
  // A function to call when the grid view setting is toggled.
  final ValueChanged<bool> onToggleGridView;
  // A function to call when the date and time setting is toggled.
  final ValueChanged<bool> onToggleDateTime;
  // A function to call when the category setting is toggled.
  final ValueChanged<bool> onToggleCategory;

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
  });

  @override
  State<HomeNavigation> createState() => _HomeNavigationState();
}

/// The state for the HomeNavigation widget.
class _HomeNavigationState extends State<HomeNavigation> {
  // This keeps track of which page is currently selected in the navigation bar.
  int _selectedIndex = 0;

  /// Changes the currently selected page based on the tapped icon.
  void _onItemTapped(int index) => setState(() => _selectedIndex = index);

  /// Builds the main screen of the app.
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // This widget will hold the page that is currently visible.
    late final Widget currentPage;
    switch (_selectedIndex) {
      // Case 0: The "Notes" page.
      case 0:
        currentPage = HomePage(
          notes: widget.notes,
          onNoteModified: widget.onNoteModified,
          isGridView: widget.isGridView,
          showCategory: widget.showCategory,
          showDateTime: widget.showDateTime,
        );
        break;
      // Case 1: The "Create" page.
      case 1:
        currentPage = CreateNotePage(
          onNoteCreated: (note) {
            widget.onNoteCreated(note);
            // After creating a note, it switches back to the "Notes" page.
            _onItemTapped(0);
          },
          allNotes: widget.notes,
        );
        break;
      // Case 2: The "Settings" page.
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
        );
        break;
      // Default case: Show the home page if something unexpected happens.
      default:
        currentPage = HomePage(
          notes: widget.notes,
          onNoteModified: widget.onNoteModified,
          isGridView: widget.isGridView,
          showCategory: widget.showCategory,
          showDateTime: widget.showDateTime,
        );
    }

    // This widget sets the style of the system status bar and navigation bar.
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        systemNavigationBarColor: theme.colorScheme.secondary,
        systemNavigationBarIconBrightness: theme.brightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark,
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: theme.brightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark,
      ),
      child: Scaffold(
        // This widget smoothly animates the transition when pages are switched.
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          reverseDuration: const Duration(milliseconds: 400),
          transitionBuilder: (child, animation) {
            // A curved animation for a softer effect.
            final curved = CurvedAnimation(
              parent: animation,
              curve: Curves.decelerate,
            );
            // An animation that slides the new page in from the right.
            final slide = Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(curved);
            // Combines the slide and fade animations.
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
        // The bottom bar with the navigation icons.
        bottomNavigationBar: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          child: NavigationBar(
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
                selectedIcon: Icon(
                  Symbols.dashboard_rounded,
                  fill: 1.0,
                  size: 24,
                ),
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
                selectedIcon: Icon(
                  Symbols.settings_rounded,
                  fill: 1.0,
                  size: 24,
                ),
                label: 'Settings',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
