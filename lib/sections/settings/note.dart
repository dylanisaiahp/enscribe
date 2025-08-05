import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

/// A stateless widget that represents the Notes settings section.
/// This section contains switches to toggle the view type, timestamp, and category display.
class NotesSection extends StatelessWidget {
  /// A boolean to indicate whether the notes are displayed in a grid view.
  final bool isGridView;

  /// A boolean to indicate whether to show the date and time on notes.
  final bool showDateTime;

  /// A boolean to indicate whether to show the category on notes.
  final bool showCategory;

  /// Callback function to be called when the view toggle is triggered.
  final ValueChanged<bool> onToggleView;

  /// Callback function to be called when the date/time toggle is triggered.
  final ValueChanged<bool> onToggleDateTime;

  /// Callback function to be called when the category toggle is triggered.
  final ValueChanged<bool> onToggleCategory;

  /// Color for text and icons on the surface.
  final Color onSurface;

  /// Text style for the section title.
  final TextStyle titleStyle;

  /// The accent color for the UI.
  final Color accent;

  /// The background color for the section.
  final Color background;

  const NotesSection({
    super.key,
    required this.isGridView,
    required this.showDateTime,
    required this.showCategory,
    required this.onToggleView,
    required this.onToggleDateTime,
    required this.onToggleCategory,
    required this.onSurface,
    required this.titleStyle,
    required this.accent,
    required this.background,
  });

  /// A private helper function to build a custom SwitchListTile.
  /// It provides a consistent layout for all the toggle options in this section.
  Widget _buildSwitchListTile({
    required IconData icon,
    required double? fill,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      // The leading icon and title of the list tile.
      title: Row(
        children: [
          Icon(icon, fill: 1.0, color: onSurface, size: 28.0),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: onSurface.withAlpha(153),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      // The current value of the switch.
      value: value,
      // The callback function to be called when the switch state changes.
      onChanged: onChanged,
      // Custom colors for the switch's active and inactive states.
      activeColor: accent.withAlpha(128),
      activeTrackColor: accent,
      trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      inactiveThumbColor: onSurface.withAlpha(128),
      inactiveTrackColor: onSurface.withAlpha(64),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      // The decorative container for the section with a background color and rounded corners.
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Text('Notes', style: titleStyle.copyWith(color: accent)),
            ),
            const SizedBox(height: 4),
            // Switch for toggling between grid and column view.
            _buildSwitchListTile(
              icon: isGridView
                  ? Symbols.grid_view_rounded
                  : Symbols.view_list_rounded,
              fill: 1.0,
              title: isGridView ? 'Grid View' : 'Column View',
              subtitle: isGridView
                  ? 'Display notes in grid'
                  : 'Display notes in column',
              value: isGridView,
              onChanged: onToggleView,
            ),
            // Switch for toggling the display of date and time.
            _buildSwitchListTile(
              icon: Symbols.event_rounded,
              fill: 1.0,
              title: 'Timestamp',
              subtitle: 'Display date and time',
              value: showDateTime,
              onChanged: onToggleDateTime,
            ),
            // Switch for toggling the display of note categories.
            _buildSwitchListTile(
              icon: Symbols.category_rounded,
              fill: 1.0,
              title: 'Category',
              subtitle: 'Display note category',
              value: showCategory,
              onChanged: onToggleCategory,
            ),
          ],
        ),
      ),
    );
  }
}
