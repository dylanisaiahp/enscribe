package dev.amethyst.enscribe

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.animation.AnimatedContent
import androidx.compose.animation.ExperimentalAnimationApi
import androidx.compose.animation.SizeTransform
import androidx.compose.animation.core.tween
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.slideInHorizontally
import androidx.compose.animation.slideOutHorizontally
import androidx.compose.animation.togetherWith
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.saveable.Saver
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import dev.amethyst.enscribe.data.db.EnscribeDatabase
import dev.amethyst.enscribe.data.db.SettingsEntity
import dev.amethyst.enscribe.data.models.EntryType
import dev.amethyst.enscribe.ui.components.EntryEditor
import dev.amethyst.enscribe.ui.nav.NavBar
import dev.amethyst.enscribe.ui.pages.CreatePage
import dev.amethyst.enscribe.ui.pages.HomePage
import dev.amethyst.enscribe.ui.pages.LogPage
import dev.amethyst.enscribe.ui.pages.SettingsPage
import dev.amethyst.enscribe.ui.theme.EnscribeTheme
import kotlinx.coroutines.launch

/**
 * Defines all the possible screens/states in our app.
 * This is a much more robust way to handle navigation than a simple integer.
 */
sealed class Screen {
    object Home : Screen()
    object CreateMenu : Screen()
    data class Editor(val entryType: EntryType, val isCreating: Boolean) : Screen()
    object Log : Screen()
    object Settings : Screen()
}

/**
 * Custom Saver for the Screen sealed class.
 * This tells rememberSavable how to convert a Screen object into a savable
 * type (a list of strings in this case) and how to restore it.
 */
private val ScreenSaver = Saver<Screen, Any>(
    save = { screen ->
        when (screen) {
            Screen.Home -> "Home"
            Screen.CreateMenu -> "CreateMenu"
            Screen.Log -> "Log"
            Screen.Settings -> "Settings"
            is Screen.Editor -> listOf(
                "Editor",
                screen.entryType.name,
                screen.isCreating.toString()
            )
        }
    },
    restore = { savedValue ->
        when (savedValue) {
            "Home" -> Screen.Home
            "CreateMenu" -> Screen.CreateMenu
            "Log" -> Screen.Log
            "Settings" -> Screen.Settings
            is List<*> -> {
                val screenType = savedValue[0] as String
                if (screenType == "Editor") {
                    val entryType = EntryType.valueOf(savedValue[1] as String)
                    val isCreating = (savedValue[2] as String).toBoolean()
                    Screen.Editor(entryType, isCreating)
                } else {
                    Screen.Home // Fallback in case of unexpected data
                }
            }

            else -> Screen.Home // Default to Home if restoration fails
        }
    }
)

class MainActivity : ComponentActivity() {
    @OptIn(ExperimentalAnimationApi::class)
    override fun onCreate(savedInstanceState: Bundle?) {
        enableEdgeToEdge()
        super.onCreate(savedInstanceState)

        setContent {
            // Corrected: Using a custom saver with rememberSavable for the screen state.
            // Removed explicit type argument as it can be inferred.
            var currentScreen by rememberSaveable(stateSaver = ScreenSaver) { mutableStateOf(Screen.Home) }
            var previousScreen by rememberSaveable(stateSaver = ScreenSaver) { mutableStateOf(Screen.Home) }

            val context = LocalContext.current
            val enscribeDatabase = remember { EnscribeDatabase.getInstance(context) }
            val settingsDao = remember { enscribeDatabase.settingsDao() }

            val settings by settingsDao.getSettings().collectAsState(
                initial = SettingsEntity()
            )
            val coroutineScope = rememberCoroutineScope()

            val currentTheme = EnscribeTheme.valueOf(settings?.themeName ?: "Onyx")

            EnscribeTheme(theme = currentTheme) {
                Scaffold(
                    containerColor = MaterialTheme.colorScheme.primary,
                    bottomBar = {
                        NavBar(
                            selectedIndex = when (currentScreen) {
                                Screen.Home -> 0
                                Screen.CreateMenu, is Screen.Editor -> 1
                                Screen.Log -> 2
                                Screen.Settings -> 3
                            },
                            onItemSelected = { index ->
                                previousScreen = currentScreen
                                currentScreen = when (index) {
                                    0 -> Screen.Home
                                    1 -> Screen.CreateMenu
                                    2 -> Screen.Log
                                    3 -> Screen.Settings
                                    else -> Screen.Home
                                }
                            }
                        )
                    },
                ) { paddingValues ->
                    AnimatedContent(
                        targetState = currentScreen,
                        transitionSpec = {
                            val animationDuration = 400

                            // Now using the previousScreen state to determine direction.
                            val isForward =
                                (previousPage(previousScreen) < previousPage(targetState))
                            if (isForward) {
                                (slideInHorizontally(
                                    initialOffsetX = { width -> width },
                                    animationSpec = tween(animationDuration)
                                ) + fadeIn(animationSpec = tween(animationDuration))).togetherWith(
                                    slideOutHorizontally(
                                        targetOffsetX = { width -> -width },
                                        animationSpec = tween(animationDuration)
                                    ) + fadeOut(animationSpec = tween(animationDuration))
                                )
                            } else {
                                (slideInHorizontally(
                                    initialOffsetX = { width -> -width },
                                    animationSpec = tween(animationDuration)
                                ) + fadeIn(animationSpec = tween(animationDuration))).togetherWith(
                                    slideOutHorizontally(
                                        targetOffsetX = { width -> width },
                                        animationSpec = tween(animationDuration)
                                    ) + fadeOut(animationSpec = tween(animationDuration))
                                )
                            }.using(
                                SizeTransform(clip = false)
                            )
                        },
                        label = "Page Transition",
                    ) { targetScreen ->
                        when (targetScreen) {
                            Screen.Home -> HomePage(
                                modifier = Modifier.padding(paddingValues),
                                enscribeDatabase = enscribeDatabase,
                                isGridView = settings?.isGridView ?: true,
                                showCategory = settings?.showCategory ?: true,
                                showDateTime = settings?.showDateTime ?: true,
                                theme = currentTheme
                            )

                            Screen.CreateMenu -> CreatePage(
                                accent = MaterialTheme.colorScheme.tertiary,
                                background = MaterialTheme.colorScheme.secondary,
                                textColor = MaterialTheme.colorScheme.onBackground,
                                titleStyle = MaterialTheme.typography.headlineLarge,
                                onEntrySelected = { entryType ->
                                    previousScreen = currentScreen
                                    currentScreen = Screen.Editor(entryType, true)
                                },
                                modifier = Modifier.padding(paddingValues),
                            )

                            is Screen.Editor -> EntryEditor(
                                onNavItemSelected = { index ->
                                    previousScreen = currentScreen
                                    currentScreen = when (index) {
                                        0 -> Screen.Home
                                        1 -> Screen.CreateMenu
                                        else -> Screen.Home
                                    }
                                },
                                entryType = targetScreen.entryType,
                                isCreating = targetScreen.isCreating,
                                modifier = Modifier.padding(paddingValues)
                            )

                            Screen.Log -> LogPage(Modifier.padding(paddingValues))
                            Screen.Settings -> SettingsPage(
                                selectedTheme = currentTheme,
                                onThemeChanged = { newTheme ->
                                    coroutineScope.launch {
                                        val currentSettings = settings ?: SettingsEntity()
                                        settingsDao.saveSettings(currentSettings.copy(themeName = newTheme.name))
                                    }
                                },
                                isGridView = settings?.isGridView ?: true,
                                showDateTime = settings?.showDateTime ?: true,
                                showCategory = settings?.showCategory ?: true,
                                onToggleView = { isGridView ->
                                    coroutineScope.launch {
                                        val currentSettings = settings ?: SettingsEntity()
                                        settingsDao.saveSettings(currentSettings.copy(isGridView = isGridView))
                                    }
                                },
                                onToggleDateTime = { showDateTime ->
                                    coroutineScope.launch {
                                        val currentSettings = settings ?: SettingsEntity()
                                        settingsDao.saveSettings(currentSettings.copy(showDateTime = showDateTime))
                                    }
                                },
                                onToggleCategory = { showCategory ->
                                    coroutineScope.launch {
                                        val currentSettings = settings ?: SettingsEntity()
                                        settingsDao.saveSettings(currentSettings.copy(showCategory = showCategory))
                                    }
                                },
                            )
                        }
                    }
                }
            }
        }
    }

    // Helper function to map screens to a numerical index for page transitions.
    private fun previousPage(screen: Screen): Int = when (screen) {
        Screen.Home -> 0
        Screen.CreateMenu -> 1
        is Screen.Editor -> 1
        Screen.Log -> 2
        Screen.Settings -> 3
    }
}
