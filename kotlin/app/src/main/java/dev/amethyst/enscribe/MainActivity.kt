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
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import dev.amethyst.enscribe.ui.nav.NavBar
import dev.amethyst.enscribe.ui.pages.CreatePage
import dev.amethyst.enscribe.ui.pages.HomePage
import dev.amethyst.enscribe.ui.pages.LogPage
import dev.amethyst.enscribe.ui.pages.SettingsPage
import dev.amethyst.enscribe.ui.theme.EnscribeTheme
import kotlinx.coroutines.launch

class MainActivity : ComponentActivity() {
    @OptIn(ExperimentalAnimationApi::class)
    override fun onCreate(savedInstanceState: Bundle?) {
        enableEdgeToEdge()
        super.onCreate(savedInstanceState)

        setContent {
            var selectedPage by rememberSaveable { mutableIntStateOf(0) }
            var previousPage by remember { mutableIntStateOf(0) }

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
                        // The NavBar can now be simplified as it doesn't need to handle the internal state of CreatePage
                        NavBar(
                            selectedIndex = selectedPage,
                            onItemSelected = {
                                previousPage = selectedPage
                                selectedPage = it
                            }
                        )
                    },
                ) { paddingValues ->
                    AnimatedContent(
                        targetState = selectedPage,
                        transitionSpec = {
                            val animationDuration = 400

                            if (targetState > previousPage) {
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
                    ) { targetPage ->
                        when (targetPage) {
                            0 -> HomePage(
                                modifier = Modifier.padding(paddingValues),
                                enscribeDatabase = enscribeDatabase,
                                isGridView = settings?.isGridView ?: true,
                                showCategory = settings?.showCategory ?: true,
                                showDateTime = settings?.showDateTime ?: true,
                                theme = currentTheme
                            )
                            // This is the only change to MainActivity. It now just calls CreatePage.
                            1 -> CreatePage(
                                accent = MaterialTheme.colorScheme.tertiary,
                                background = MaterialTheme.colorScheme.secondary,
                                textColor = MaterialTheme.colorScheme.onBackground,
                                titleStyle = MaterialTheme.typography.headlineLarge,
                                modifier = Modifier.padding(paddingValues)
                            )

                            2 -> LogPage(Modifier.padding(paddingValues))
                            3 -> SettingsPage(
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
}