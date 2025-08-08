package dev.amethyst.enscribe.ui.pages

import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.WindowInsets
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.systemBars
import androidx.compose.foundation.layout.windowInsetsPadding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.runtime.Composable
import androidx.compose.ui.ExperimentalComposeUiApi
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import dev.amethyst.enscribe.ui.sections.settings.AboutSection
import dev.amethyst.enscribe.ui.sections.settings.AppearanceSection
import dev.amethyst.enscribe.ui.sections.settings.NotesSection
import dev.amethyst.enscribe.ui.theme.EnscribeTheme

@OptIn(ExperimentalComposeUiApi::class)
@Composable
fun SettingsPage(
    selectedTheme: EnscribeTheme,
    onThemeChanged: (EnscribeTheme) -> Unit,
    isGridView: Boolean,
    showDateTime: Boolean,
    showCategory: Boolean,
    onToggleView: (Boolean) -> Unit,
    onToggleDateTime: (Boolean) -> Unit,
    onToggleCategory: (Boolean) -> Unit,
) {
    val theme = MaterialTheme
    val titleStyle = theme.typography.titleLarge
    val background = theme.colorScheme.secondary
    val accent = theme.colorScheme.tertiary
    val onSurface = theme.colorScheme.onSurface
    val textColor = theme.colorScheme.onSurfaceVariant
    val onSecondary = theme.colorScheme.onSecondary

    Scaffold(
        containerColor = Color.Transparent,
    ) { innerPadding ->
        LazyColumn(
            modifier = Modifier
                .windowInsetsPadding(WindowInsets.systemBars)
                .padding(horizontal = 20.dp)
                .padding(bottom = innerPadding.calculateBottomPadding() + 64.dp)
                .fillMaxSize()
        ) {
            item {
                AppearanceSection(
                    selectedTheme = selectedTheme,
                    onThemeChanged = onThemeChanged,
                    onSurface = onSurface,
                    accent = accent,
                    background = background,
                    textColor = textColor,
                    titleStyle = titleStyle,
                    isDark = true,
                )
            }
            item { Spacer(modifier = Modifier.height(16.dp)) }
            item {
                NotesSection(
                    isGridView = isGridView,
                    showDateTime = showDateTime,
                    showCategory = showCategory,
                    onToggleView = onToggleView,
                    onToggleDateTime = onToggleDateTime,
                    onToggleCategory = onToggleCategory,
                    onSurface = onSurface,
                    accent = accent,
                    background = background,
                    textColor = textColor,
                    titleStyle = titleStyle,
                    onSecondary = onSecondary,
                )
            }
            item { Spacer(modifier = Modifier.height(16.dp)) }
            item {
                AboutSection(
                    onSurface = onSurface,
                    accent = accent,
                    background = background,
                    textColor = textColor,
                    titleStyle = titleStyle,
                )
            }
        }
    }
}
