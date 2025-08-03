import 'package:flutter/material.dart';

/// A class to hold the color scheme for a specific theme.
/// Each theme is composed of a primary, secondary, accent, text, and error color.
class AppColors {
  const AppColors({
    required this.accentColor,
    required this.primaryColor,
    required this.secondaryColor,
    required this.textColor,
    required this.errorColor,
  });

  /// The main color used to highlight key elements and call to actions.
  final Color accentColor;

  /// The dominant background color of the application.
  final Color primaryColor;

  /// A complementary color to the primary color, used for secondary backgrounds or elements.
  final Color secondaryColor;

  /// The color used for text and icons, providing good contrast against the background colors.
  final Color textColor;

  /// The color used to indicate error states, such as invalid input or failed actions.
  final Color errorColor;
}

/// A collection of predefined color palettes for different application themes.
class AppColorPalettes {
  // Onyx Theme Colors: A dark theme with a deep purple accent.
  static const AppColors onyx = AppColors(
    accentColor: Color(0xFF9575CD),
    primaryColor: Color(0xFF000000),
    secondaryColor: Color(0xFF121212),
    textColor: Color(0xFFFFFFFF),
    errorColor: Color(0xFFCF6679),
  );

  // Midnight Theme Colors: A cool, dark blue theme.
  static const AppColors midnight = AppColors(
    accentColor: Color(0xFF4FC3F7),
    primaryColor: Color(0xFF0A1C2C),
    secondaryColor: Color(0xFF1E3A4D),
    textColor: Color(0xFFFFFFFF),
    errorColor: Color(0xFFCF6679),
  );

  // Burgundy Theme Colors: A warm, maroon-based dark theme with a fiery accent.
  static const AppColors burgundy = AppColors(
    accentColor: Color(0xFFFF6B6B),
    primaryColor: Color(0xFF6D3C45),
    secondaryColor: Color(0xFF8A4651),
    textColor: Color(0xFFFFFFFF),
    errorColor: Color(0xFFCF6679),
  );

  // Graphene Theme Colors: A neutral dark grey theme.
  static const AppColors graphene = AppColors(
    accentColor: Color(0xFFB39DDB),
    primaryColor: Color(0xFF1E1E1E),
    secondaryColor: Color(0xFF2D2D2D),
    textColor: Color(0xFFFFFFFF),
    errorColor: Color(0xFFCF6679),
  );

  // Amethyst Theme Colors: A rich, purple-toned dark theme.
  static const AppColors amethyst = AppColors(
    accentColor: Color(0xFFA390FF),
    primaryColor: Color(0xFF5B467B),
    secondaryColor: Color(0xFF6D5A91),
    textColor: Color(0xFFFFFFFF),
    errorColor: Color(0xFFCF6679),
  );

  // Lumen Theme Colors: A bright, light theme with a classic blue accent.
  static const AppColors lumen = AppColors(
    accentColor: Color(0xFF2196F3),
    primaryColor: Color(0xFFFFFFFF),
    secondaryColor: Color(0xFFF8F8F8),
    textColor: Color(0xFF000000),
    errorColor: Color(0xFFCF6679),
  );

  // Beige Theme Colors: A warm, earthy light theme.
  static const AppColors beige = AppColors(
    accentColor: Color(0xFF795548),
    primaryColor: Color(0xFFF5F5DC),
    secondaryColor: Color(0xFFEBEBD2),
    textColor: Color(0xFF000000),
    errorColor: Color(0xFFCF6679),
  );

  // Lavender Theme Colors: A soft, pastel light theme.
  static const AppColors lavender = AppColors(
    accentColor: Color(0xFFBA68C8),
    primaryColor: Color(0xFFF3E5F5),
    secondaryColor: Color(0xFFE6D8ED),
    textColor: Color(0xFF000000),
    errorColor: Color(0xFFCF6679),
  );

  // Aqua Theme Colors: A light, refreshing blue-green theme.
  static const AppColors aqua = AppColors(
    accentColor: Color(0xFF00BCD4),
    primaryColor: Color(0xFFD5F8FC),
    secondaryColor: Color(0xFFCCF2F7),
    textColor: Color(0xFF000000),
    errorColor: Color(0xFFCF6679),
  );

  // Mint Theme Colors: A light, natural green theme.
  static const AppColors mint = AppColors(
    accentColor: Color(0xFF4DB6AC),
    primaryColor: Color(0xFFE8F5E9),
    secondaryColor: Color(0xFFD6E9D8),
    textColor: Color(0xFF000000),
    errorColor: Color(0xFFCF6679),
  );
}
