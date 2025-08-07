package dev.amethyst.enscribe.ui.theme

import androidx.compose.ui.graphics.Color

data class ThemeColors(
    val accent: Color,
    val background: Color,
    val surface: Color,
    val container: Color,
    val text: Color,
    val error: Color
)

object ThemePalettes {
    val onyx = ThemeColors(
        accent = Color(0xFF9575CD),
        background = Color(0xFF000000),
        surface = Color(0xFF121212),
        container = Color(0xFF1F1F1F),
        text = Color(0xFFFFFFFF),
        error = Color(0xFFCF6679),
    )

    val midnight = ThemeColors(
        accent = Color(0xFF4FC3F7),
        background = Color(0xFF0A1C2C),
        surface = Color(0xFF1E3A4D),
        container = Color(0xFF2A4E66),
        text = Color(0xFFFFFFFF),
        error = Color(0xFFCF6679)
    )

    val burgundy = ThemeColors(
        accent = Color(0xFFFF6B6B),
        background = Color(0xFF6D3C45),
        surface = Color(0xFF8A4651),
        container = Color(0xFF9E5965),
        text = Color(0xFFFFFFFF),
        error = Color(0xFFCF6679),
    )

    val graphene = ThemeColors(
        accent = Color(0xFFB39DDB),
        background = Color(0xFF1E1E1E),
        surface = Color(0xFF2D2D2D),
        container = Color(0xFF3A3A3A),
        text = Color(0xFFFFFFFF),
        error = Color(0xFFCF6679)
    )

    val amethyst = ThemeColors(
        accent = Color(0xFFA390FF),
        background = Color(0xFF5B467B),
        surface = Color(0xFF6D5A91),
        container = Color(0xFF8170A5),
        text = Color(0xFFFFFFFF),
        error = Color(0xFFCF6679)
    )

    val lumen = ThemeColors(
        accent = Color(0xFF2196F3),
        background = Color(0xFFFFFFFF),
        surface = Color(0xFFF8F8F8),
        container = Color(0xFFEDEDED),
        text = Color(0xFF000000),
        error = Color(0xFFCF6679)
    )

    val beige = ThemeColors(
        accent = Color(0xFF795548),
        background = Color(0xFFF5F5DC),
        surface = Color(0xFFEBEBD2),
        container = Color(0xFFDCDCC3),
        text = Color(0xFF000000),
        error = Color(0xFFCF6679)
    )

    val lavender = ThemeColors(
        accent = Color(0xFFBA68C8),
        background = Color(0xFFF3E5F5),
        surface = Color(0xFFE6D8ED),
        container = Color(0xFFD5C9DE),
        text = Color(0xFF000000),
        error = Color(0xFFCF6679)
    )

    val aqua = ThemeColors(
        accent = Color(0xFF00BCD4),
        background = Color(0xFFD5F8FC),
        surface = Color(0xFFCCF2F7),
        container = Color(0xFFB9E6EC),
        text = Color(0xFF000000),
        error = Color(0xFFCF6679)
    )

    val mint = ThemeColors(
        accent = Color(0xFF4DB6AC),
        background = Color(0xFFE8F5E9),
        surface = Color(0xFFD6E9D8),
        container = Color(0xFFC5DCC8),
        text = Color(0xFF000000),
        error = Color(0xFFCF6679)
    )
}