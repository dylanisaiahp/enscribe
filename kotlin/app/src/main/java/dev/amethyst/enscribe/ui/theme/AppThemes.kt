package dev.amethyst.enscribe.ui.theme

import androidx.compose.material3.ColorScheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable

enum class EnscribeTheme {
    Onyx,
    Midnight,
    Burgundy,
    Graphene,
    Lumen,
    Beige,
    Amethyst,
    Lavender,
    Aqua,
    Mint,
}

data class EnscribeThemeInfo(val name: String, val description: String)

val themeDescriptions = mapOf(
    EnscribeTheme.Onyx to EnscribeThemeInfo("Onyx", "Deep black for high contrast and OLED."),
    EnscribeTheme.Midnight to EnscribeThemeInfo("Midnight", "Dark theme with cool blue tones."),
    EnscribeTheme.Burgundy to EnscribeThemeInfo("Burgundy", "Rich dark theme with deep reds."),
    EnscribeTheme.Graphene to EnscribeThemeInfo("Graphene", "Soft, modern graphite tones."),
    EnscribeTheme.Lumen to EnscribeThemeInfo("Lumen", "Bright, clean light theme."),
    EnscribeTheme.Beige to EnscribeThemeInfo("Beige", "Warm and cozy light hues."),
    EnscribeTheme.Amethyst to EnscribeThemeInfo("Amethyst", "Dark theme with subtle purple."),
    EnscribeTheme.Lavender to EnscribeThemeInfo("Lavender", "Airy light with purple accents."),
    EnscribeTheme.Aqua to EnscribeThemeInfo("Aqua", "Refreshing light water-inspired."),
    EnscribeTheme.Mint to EnscribeThemeInfo("Mint", "Crisp, cool light theme.")
)

fun getThemeColors(theme: EnscribeTheme): ThemeColors = when (theme) {
    EnscribeTheme.Onyx -> ThemePalettes.onyx
    EnscribeTheme.Midnight -> ThemePalettes.midnight
    EnscribeTheme.Burgundy -> ThemePalettes.burgundy
    EnscribeTheme.Graphene -> ThemePalettes.graphene
    EnscribeTheme.Lumen -> ThemePalettes.lumen
    EnscribeTheme.Beige -> ThemePalettes.beige
    EnscribeTheme.Amethyst -> ThemePalettes.amethyst
    EnscribeTheme.Lavender -> ThemePalettes.lavender
    EnscribeTheme.Aqua -> ThemePalettes.aqua
    EnscribeTheme.Mint -> ThemePalettes.mint
}

// Converts ThemeColors to a Material3 Scheme
fun ThemeColors.toColorScheme(isDark: Boolean): ColorScheme {
    return if (isDark) {
        darkColorScheme(
            primary = background,
            onPrimary = text,
            secondary = surface,
            onSecondary = container,
            tertiary = accent,
            surface = surface,
            onSurface = text,
            error = error,
            onError = text,
        )
    } else {
        lightColorScheme(
            primary = background,
            onPrimary = text,
            secondary = surface,
            onSecondary = container,
            tertiary = accent,
            surface = surface,
            onSurface = text,
            error = error,
            onError = text
        )
    }
}

@Composable
fun EnscribeTheme(
    theme: EnscribeTheme,
    isDarkTheme: Boolean = false,
    content: @Composable () -> Unit
) {
    val colors = getThemeColors(theme)
    val colorScheme = colors.toColorScheme(isDarkTheme)

    MaterialTheme(
        colorScheme = colorScheme,
        typography = MaterialTheme.typography,
        content = content
    )
}
