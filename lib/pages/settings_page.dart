import 'package:flutter/material.dart';
import '../data/themes.dart'; // Imports the custom theme data.
import '../sections/settings/about.dart'; // Imports the About section widget.
import '../sections/settings/appearance.dart'; // Imports the Appearance section widget.
import '../sections/settings/note.dart'; // Imports the Notes section widget.
import '../nav.dart';

/// A stateful widget that displays the application's settings page.
/// It receives various properties and callbacks from its parent widget
/// to manage the app's state related to theme, view, and note display options.
class SettingsPage extends StatefulWidget {
  /// The currently selected theme for the application.
  final EnscribeTheme selectedTheme;

  final void Function(EnscribeTheme) onThemeChanged;
  final bool isGridView;
  final bool showDateTime;
  final bool showCategory;
  final ValueChanged<bool> onToggleView;
  final ValueChanged<bool> onToggleDateTime;
  final ValueChanged<bool> onToggleCategory;
  final NavBarPosition selectedNavBarPosition;
  final ValueChanged<NavBarPosition> onNavBarPositionChanged;

  const SettingsPage({
    super.key,
    required this.selectedTheme,
    required this.onThemeChanged,
    required this.isGridView,
    required this.showDateTime,
    required this.showCategory,
    required this.onToggleView,
    required this.onToggleDateTime,
    required this.onToggleCategory,
    required this.selectedNavBarPosition,
    required this.onNavBarPositionChanged,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

/// The state class for the SettingsPage widget.
class _SettingsPageState extends State<SettingsPage> {
  // A GlobalKey to access the RenderBox of a widget, used here to measure
  // the width of the dropdown menu for the theme selector.
  final GlobalKey _dropdownKey = GlobalKey();
  // A variable to store the calculated width of the dropdown.
  double _dropdownWidth = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Get the current theme to style the widgets.
    final theme = Theme.of(context);
    final titleStyle = theme.textTheme.titleLarge!;
    final background = theme.colorScheme.secondary;
    final accent = theme.colorScheme.tertiary;
    final onSurface = theme.colorScheme.onSurface;
    final textColor = theme.textTheme.labelLarge!.color ?? Colors.black;

    final bool isNavBarTop =
        widget.selectedNavBarPosition == NavBarPosition.top;

    // This callback is scheduled to run after the widget tree has been built
    // and laid out. It's used to get the actual width of the dropdown menu
    // to ensure its size is correct.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final box = _dropdownKey.currentContext?.findRenderObject() as RenderBox?;
      if (box != null && _dropdownWidth != box.size.width) {
        setState(() => _dropdownWidth = box.size.width);
      }
    });

    return Scaffold(
      // The main layout widget for the screen.
      body: SafeArea(
        top: !isNavBarTop,
        bottom: false,
        child: GestureDetector(
          // Tapping on the empty space of the page dismisses the keyboard.
          onTap: () => FocusScope.of(context).unfocus(),
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: EdgeInsets.only(top: 16, bottom: 16, left: 20, right: 20),
            child: MediaQuery.removePadding(
              context: context,
              removeTop: true,
              child: ListView(
                children: [
                  // The Appearance settings section.
                  AppearanceSection(
                    selectedTheme: widget.selectedTheme,
                    onThemeChanged: widget.onThemeChanged,
                    onSurface: onSurface,
                    accent: accent,
                    background: background,
                    textColor: textColor,
                    titleStyle: titleStyle,
                    theme: theme,
                    selectedNavBarPosition: widget.selectedNavBarPosition,
                    onNavBarPositionChanged: widget.onNavBarPositionChanged,
                  ),
                  const SizedBox(height: 16), // A spacer.
                  // The Notes settings section.
                  NotesSection(
                    isGridView: widget.isGridView,
                    showDateTime: widget.showDateTime,
                    showCategory: widget.showCategory,
                    onToggleView: widget.onToggleView,
                    onToggleDateTime: widget.onToggleDateTime,
                    onToggleCategory: widget.onToggleCategory,
                    onSurface: onSurface,
                    titleStyle: titleStyle,
                    accent: accent,
                    background: background,
                  ),
                  const SizedBox(height: 16), // A spacer.
                  // The About section.
                  AboutSection(
                    background: background,
                    accent: accent,
                    titleStyle: titleStyle,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
