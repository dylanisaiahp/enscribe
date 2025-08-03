import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import '../../data/themes.dart'; // Imports the custom theme data.

/// A stateless widget that represents the Appearance settings section.
/// It displays a dropdown menu for the user to select the app's theme.
class AppearanceSection extends StatelessWidget {
  /// The currently selected theme.
  final EnscribeTheme selectedTheme;

  /// Callback to be invoked when a new theme is selected.
  final ValueChanged<EnscribeTheme> onThemeChanged;

  /// Color for text and icons on the surface.
  final Color onSurface;

  /// Accent color for the UI.
  final Color accent;

  /// Background color for the section.
  final Color background;

  /// Text color.
  final Color textColor;

  /// Text style for the section title.
  final TextStyle titleStyle;

  /// The current theme data.
  final ThemeData theme;

  /// A global key used to measure the size of the dropdown button.
  final GlobalKey dropdownKey;

  const AppearanceSection({
    super.key,
    required this.selectedTheme,
    required this.onThemeChanged,
    required this.onSurface,
    required this.accent,
    required this.background,
    required this.textColor,
    required this.titleStyle,
    required this.theme,
    required this.dropdownKey,
  });

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
              child: Text(
                'Appearance',
                style: titleStyle.copyWith(color: accent),
              ),
            ),
            const SizedBox(height: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Icon and text for the "Theme" option.
                      Row(
                        children: [
                          Icon(
                            // Dynamically chooses an icon based on the current theme brightness.
                            theme.brightness == Brightness.dark
                                ? Icons.dark_mode_rounded
                                : Icons.light_mode_rounded,
                            size: 28.0,
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Theme',
                                style: TextStyle(fontSize: 16),
                              ),
                              Text(
                                'Choose your theme',
                                style: TextStyle(
                                  color: onSurface.withAlpha(153),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      // The custom dropdown button for theme selection.
                      DropdownButtonHideUnderline(
                        child: DropdownButton2<EnscribeTheme>(
                          key: dropdownKey,
                          value: selectedTheme,
                          onChanged: (t) {
                            if (t != null) onThemeChanged(t);
                          },
                          // Custom styling for the button itself.
                          buttonStyleData: ButtonStyleData(
                            height: 40,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: theme.brightness == Brightness.dark
                                  ? Color.lerp(background, Colors.white, 0.1)
                                  : Color.lerp(background, Colors.black, 0.1),
                            ),
                          ),
                          // Custom styling for the dropdown menu.
                          dropdownStyleData: DropdownStyleData(
                            maxHeight: 416,
                            width: 224,
                            elevation: 0,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: theme.brightness == Brightness.dark
                                  ? Color.lerp(background, Colors.white, 0.1)
                                  : Color.lerp(background, Colors.black, 0.1),
                            ),
                            offset: const Offset(-116, -8),
                            scrollbarTheme: ScrollbarThemeData(
                              thumbColor: WidgetStateProperty.all(
                                onSurface.withAlpha(64),
                              ),
                              radius: const Radius.circular(40),
                              thickness: WidgetStateProperty.all<double>(2),
                              thumbVisibility: WidgetStateProperty.all<bool>(
                                true,
                              ),
                            ),
                          ),
                          // Custom styling for each item in the dropdown menu.
                          menuItemStyleData: MenuItemStyleData(
                            height: 64,
                            padding: const EdgeInsets.all(8),
                          ),
                          // The list of theme options.
                          items: EnscribeTheme.values.map((theme) {
                            final info = themeDescriptions[theme]!;
                            return DropdownMenuItem<EnscribeTheme>(
                              value: theme,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    info.name,
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    info.description,
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          // Builder for the selected item displayed on the button.
                          selectedItemBuilder: (BuildContext context) {
                            return EnscribeTheme.values.map((theme) {
                              return Center(
                                child: Text(
                                  themeDescriptions[theme]!.name,
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 16,
                                  ),
                                ),
                              );
                            }).toList();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
