import 'package:flutter/material.dart';
import '../data/themes.dart'; // Imports the custom theme data.
import '../sections/settings/about.dart'; // Imports the About section widget.
import '../sections/settings/appearance.dart'; // Imports the Appearance section widget.
import '../sections/settings/notes.dart'; // Imports the Notes section widget.

/// A stateful widget that displays the application's settings page.
/// It receives various properties and callbacks from its parent widget
/// to manage the app's state related to theme, view, and note display options.
class SettingsPage extends StatefulWidget {
  /// The currently selected theme for the application.
  final EnscribeTheme selectedTheme;

  /// Callback function to be called when the theme is changed.
  final void Function(EnscribeTheme) onThemeChanged;

  /// A boolean indicating whether the notes are displayed in a grid view.
  final bool isGridView;

  /// A boolean indicating whether the date and time should be shown on notes.
  final bool showDateTime;

  /// A boolean indicating whether the category should be shown on notes.
  final bool showCategory;

  /// Callback function to be called when the view toggle is triggered.
  final ValueChanged<bool> onToggleView;

  /// Callback function to be called when the date/time toggle is triggered.
  final ValueChanged<bool> onToggleDateTime;

  /// Callback function to be called when the category toggle is triggered.
  final ValueChanged<bool> onToggleCategory;

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
        // Prevents content from being hidden by the bottom system navigation bar.
        bottom: false,
        child: GestureDetector(
          // Tapping on the empty space of the page dismisses the keyboard.
          onTap: () => FocusScope.of(context).unfocus(),
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
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
                  dropdownKey: _dropdownKey,
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
    );
  }
}
