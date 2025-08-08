package dev.amethyst.enscribe.ui.pages

import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.runtime.Composable
import androidx.compose.ui.ExperimentalComposeUiApi
import androidx.compose.ui.Modifier
import androidx.compose.ui.focus.FocusManager
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalFocusManager
import androidx.compose.ui.unit.dp
import dev.amethyst.enscribe.ui.nav.NavBar
import dev.amethyst.enscribe.ui.nav.NavBarPosition
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
    selectedNavBarPosition: NavBarPosition,
    onNavBarPositionChanged: (NavBarPosition) -> Unit,
    modifier: Modifier = Modifier,
) {
    val focusManager: FocusManager = LocalFocusManager.current
    val theme = MaterialTheme
    val titleStyle = theme.typography.titleLarge
    val background = theme.colorScheme.secondary
    val accent = theme.colorScheme.tertiary
    val onSurface = theme.colorScheme.onSurface
    val textColor = theme.colorScheme.onSurfaceVariant

    val isNavBarTop = selectedNavBarPosition == NavBarPosition.Top

    if (isNavBarTop) {
        Scaffold(
            topBar = {
                NavBar(
                    selectedIndex = 3, // Adjust as needed for active tab
                    onItemSelected = {}, // If you want item switching in SettingsPage
                    navBarPosition = NavBarPosition.Top
                )
            },
            containerColor = Color.Transparent,
        ) { innerPadding ->
            LazyColumn(
                modifier = Modifier
                    .padding(start = 20.dp, end = 20.dp)
                    .fillMaxSize(),
                contentPadding = innerPadding
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
                        selectedNavBarPosition = selectedNavBarPosition,
                        onNavBarPositionChanged = onNavBarPositionChanged,
                        isDark = true
                    )
                }
            }
        }
    } else {
        LazyColumn(
            modifier = Modifier
                .statusBarsPadding()
                .padding(start = 20.dp, end = 20.dp)
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
                    selectedNavBarPosition = selectedNavBarPosition,
                    onNavBarPositionChanged = onNavBarPositionChanged,
                    isDark = true
                )
            }
        }
    }
}
