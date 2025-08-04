import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sqflite/sqflite.dart';
import 'database.dart';
import 'colors.dart';

/// An enumeration of all available themes in the application.
/// Each theme is a unique identifier for a color scheme and text style.
enum EnscribeTheme {
  onyx,
  midnight,
  burgundy,
  graphene,
  lumen,
  beige,
  amethyst,
  lavender,
  aqua,
  mint,
}

/// A simple data class to hold a theme's display name and a brief description.
class EnscribeThemeInfo {
  final String name;
  final String description;

  const EnscribeThemeInfo(this.name, this.description);
}

/// A constant map that provides brief info for each theme in the [EnscribeTheme] enum.
const Map<EnscribeTheme, EnscribeThemeInfo> themeDescriptions = {
  EnscribeTheme.onyx: EnscribeThemeInfo(
    'Onyx',
    'Deep black for high contrast and OLED.',
  ),
  EnscribeTheme.midnight: EnscribeThemeInfo(
    'Midnight',
    'Dark theme with cool blue tones.',
  ),
  EnscribeTheme.burgundy: EnscribeThemeInfo(
    'Burgundy',
    'Rich dark theme with deep reds.',
  ),
  EnscribeTheme.graphene: EnscribeThemeInfo(
    'Graphene',
    'Soft, modern graphite tones.',
  ),
  EnscribeTheme.lumen: EnscribeThemeInfo('Lumen', 'Bright, clean light theme.'),
  EnscribeTheme.beige: EnscribeThemeInfo('Beige', 'Warm and cozy light hues.'),
  EnscribeTheme.amethyst: EnscribeThemeInfo(
    'Amethyst',
    'Dark theme with subtle purple.',
  ),
  EnscribeTheme.lavender: EnscribeThemeInfo(
    'Lavender',
    'Airy light with purple accents.',
  ),
  EnscribeTheme.aqua: EnscribeThemeInfo(
    'Aqua',
    'Refreshing light water-inspired.',
  ),
  EnscribeTheme.mint: EnscribeThemeInfo('Mint', 'Crisp, cool light theme.'),
};

/// A static class responsible for managing theme data persistence using the local database.
/// It handles saving and loading the user's selected theme.
class EnscribeThemeManager {
  static const _tableName = 'theme';
  static const _keyColumn = 'setting';
  static const _valueColumn = 'themeName';

  /// Private getter to access the database instance from the [DatabaseService].
  static Future<Database> get _database async => DatabaseService().database;

  /// Saves the provided [EnscribeTheme] to the database.
  /// It uses `ConflictAlgorithm.replace` to overwrite any existing theme setting.
  static Future<void> saveTheme(EnscribeTheme theme) async {
    final db = await _database;
    await db.insert(_tableName, {
      _keyColumn: 'selectedTheme',
      _valueColumn: theme.name,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Loads the saved theme from the database.
  /// It queries the `theme` table for the 'selectedTheme' setting.
  /// If no theme is found, it defaults to [EnscribeTheme.lumen].
  static Future<EnscribeTheme> loadTheme() async {
    final db = await _database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: '$_keyColumn = ?',
      whereArgs: ['selectedTheme'],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      final themeName = maps.first[_valueColumn] as String;
      // Finds the corresponding EnscribeTheme from its name, defaulting if not found.
      return EnscribeTheme.values.firstWhere(
        (t) => t.name == themeName,
        orElse: () => EnscribeTheme.lumen,
      );
    }
    return EnscribeTheme.lumen;
  }
}

/// A class that provides predefined [ThemeData] for each [EnscribeTheme].
/// It builds the full theme data object based on color palettes.
class EnscribeThemes {
  /// A private static method to construct a [ThemeData] object from a given [AppColors] palette.
  /// This centralizes the logic for creating consistent themes.
  static ThemeData _buildTheme(AppColors colors) {
    // Determine the overall brightness of the theme based on the text color.
    final brightness =
        ThemeData.estimateBrightnessForColor(colors.textColor) ==
            Brightness.dark
        ? Brightness.light
        : Brightness.dark;

    // Determine the brightness for "on" colors to ensure readability.
    final onPrimaryBrightness = ThemeData.estimateBrightnessForColor(
      colors.primaryColor,
    );
    final onSecondaryBrightness = ThemeData.estimateBrightnessForColor(
      colors.secondaryColor,
    );
    final onErrorBrightness = ThemeData.estimateBrightnessForColor(
      colors.errorColor,
    );

    return ThemeData(
      brightness: brightness,
      useMaterial3: true,
      scaffoldBackgroundColor: colors.primaryColor,
      splashFactory: NoSplash.splashFactory,
      // Define the color scheme for the entire app.
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: colors.primaryColor,
        onPrimary: onPrimaryBrightness == Brightness.dark
            ? Colors.white
            : Colors.black,
        secondary: colors.secondaryColor,
        onSecondary: onSecondaryBrightness == Brightness.dark
            ? Colors.white
            : Colors.black,
        tertiary: colors.accentColor,
        surface: colors.secondaryColor,
        onSurface: colors.textColor,
        error: colors.errorColor,
        onError: onErrorBrightness == Brightness.dark
            ? Colors.white
            : Colors.black,
      ),
      // Style the SnackBars.
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colors.secondaryColor,
        contentTextStyle: TextStyle(color: colors.textColor),
        actionTextColor: colors.accentColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      // Define the style for text input fields.
      inputDecorationTheme: InputDecorationTheme(
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide.none,
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: colors.accentColor, width: 2.0),
        ),
        labelStyle: TextStyle(color: colors.textColor),
        hintStyle: TextStyle(color: colors.textColor.withAlpha(153)),
      ),
      // Style the AppBar.
      appBarTheme: AppBarTheme(
        backgroundColor: colors.primaryColor,
        foregroundColor: colors.textColor,
        elevation: 0,
      ),
      // Style the NavigationBar.
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colors.secondaryColor,
        elevation: 0,
        indicatorColor: Colors.transparent,
        iconTheme: WidgetStateProperty.resolveWith<IconThemeData>((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: colors.accentColor);
          }
          return IconThemeData(color: colors.textColor.withAlpha(153));
        }),
        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((states) {
          return TextStyle(
            color: states.contains(WidgetState.selected)
                ? colors.accentColor
                : colors.textColor.withAlpha(153),
          );
        }),
      ),
      // Style the NavigationRail.
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: colors.secondaryColor,
        elevation: 0,
        indicatorColor: Colors.transparent,
        selectedIconTheme: IconThemeData(color: colors.accentColor),
        unselectedIconTheme: IconThemeData(
          color: colors.textColor.withAlpha(153),
        ),
        selectedLabelTextStyle: TextStyle(color: colors.accentColor),
        unselectedLabelTextStyle: TextStyle(
          color: colors.textColor.withAlpha(153),
        ),
      ),

      // Style the Card widget.
      cardTheme: CardThemeData(
        color: colors.secondaryColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          side: BorderSide(color: colors.textColor.withAlpha(25)),
        ),
      ),
      // Style the text selection and cursor.
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: colors.accentColor,
        selectionColor: colors.accentColor.withAlpha(76),
        selectionHandleColor: colors.accentColor,
      ),
      // Style the Switch widget.
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.all(colors.accentColor),
        trackColor: WidgetStateProperty.all(colors.secondaryColor),
      ),
      // Set the global text theme using Google Fonts.
      textTheme: GoogleFonts.interTextTheme(
        ThemeData(brightness: brightness).textTheme.apply(
          bodyColor: colors.textColor,
          displayColor: colors.textColor,
        ),
      ),
    );
  }

  /// A map that holds the complete [ThemeData] for each [EnscribeTheme].
  /// This allows for easy access to the configured themes throughout the application.
  static final Map<EnscribeTheme, ThemeData> themeData = {
    EnscribeTheme.onyx: _buildTheme(AppColorPalettes.onyx),
    EnscribeTheme.midnight: _buildTheme(AppColorPalettes.midnight),
    EnscribeTheme.burgundy: _buildTheme(AppColorPalettes.burgundy),
    EnscribeTheme.graphene: _buildTheme(AppColorPalettes.graphene),
    EnscribeTheme.lumen: _buildTheme(AppColorPalettes.lumen),
    EnscribeTheme.beige: _buildTheme(AppColorPalettes.beige),
    EnscribeTheme.amethyst: _buildTheme(AppColorPalettes.amethyst),
    EnscribeTheme.lavender: _buildTheme(AppColorPalettes.lavender),
    EnscribeTheme.aqua: _buildTheme(AppColorPalettes.aqua),
    EnscribeTheme.mint: _buildTheme(AppColorPalettes.mint),
  };
}
