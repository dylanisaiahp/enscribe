import 'dart:io';
import 'package:flutter/material.dart';

/// Checks if a file exists at the given path.
Future<bool> fileExists(String? path) async {
  if (path == null || path.isEmpty) return false;
  try {
    return await File(path).exists();
  } catch (e) {
    return false;
  }
}

/// Returns true if a color is considered visually light (luminance > 0.5).
bool isLightColor(Color color) {
  final luminance = color.computeLuminance();
  return luminance > 0.5;
}

/// Smart contrast color selection to ensure optimal text color over a background.
Color getOptimalTextColor(BuildContext context, Color backgroundColor,
    TextStyle? textStyle) {
  final themeTextColor = textStyle?.color ?? Theme
      .of(context)
      .colorScheme
      .onSurface;
  final bgLuminance = backgroundColor.computeLuminance();
  final themeLuminance = themeTextColor.computeLuminance();
  final contrastWithTheme = (bgLuminance > themeLuminance)
      ? (bgLuminance + 0.05) / (themeLuminance + 0.05)
      : (themeLuminance + 0.05) / (bgLuminance + 0.05);
  if (contrastWithTheme >= 3.0) {
    return themeTextColor;
  }
  return isLightColor(backgroundColor) ? Colors.black87 : Colors.white;
}

/// Builds image or a themed broken image fallback if not present.
Widget buildImageWithFallback({
  required BuildContext context,
  required String? imageUrl,
  required double width,
  required double height,
  BoxFit fit = BoxFit.cover,
}) {
  return FutureBuilder<bool>(
    future: fileExists(imageUrl),
    builder: (context, snapshot) {
      if (snapshot.data == true) {
        return Image.file(
          File(imageUrl!),
          width: width,
          height: height,
          fit: fit,
        );
      }
      final theme = Theme.of(context);
      return Container(
        width: width,
        height: height,
        color: theme.colorScheme.surface,
        child: Icon(
          Icons.broken_image_rounded,
          size: 48,
          color: theme.colorScheme.onSurface.withAlpha(100),
        ),
      );
    },
  );
}
