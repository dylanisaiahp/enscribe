package dev.amethyst.enscribe.ui.pages

import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.ExperimentalComposeUiApi
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import dev.amethyst.enscribe.ui.sections.settings.AppearanceSection
import dev.amethyst.enscribe.ui.theme.EnscribeTheme

@OptIn(ExperimentalComposeUiApi::class)
@Composable
fun SettingsPage(
    selectedTheme: EnscribeTheme,
    onThemeChanged: (EnscribeTheme) -> Unit,
    //isGridView: Boolean,
    //showDateTime: Boolean,
    //showCategory: Boolean,
    //onToggleView: (Boolean) -> Unit,
    //onToggleDateTime: (Boolean) -> Unit,
    //onToggleCategory: (Boolean) -> Unit,
    modifier: Modifier = Modifier,
) {
    val theme = MaterialTheme
    val titleStyle = theme.typography.titleLarge
    val background = theme.colorScheme.secondary
    val accent = theme.colorScheme.tertiary
    val onSurface = theme.colorScheme.onSurface
    val textColor = theme.colorScheme.onSurfaceVariant

    LazyColumn(
        modifier = Modifier
            .statusBarsPadding()
            .padding(horizontal = 20.dp)
            .fillMaxSize(),
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
    }
}
