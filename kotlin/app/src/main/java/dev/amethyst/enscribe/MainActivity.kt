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
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import dev.amethyst.enscribe.entrydata.EnscribeDatabase
import dev.amethyst.enscribe.ui.nav.NavBar
import dev.amethyst.enscribe.ui.nav.NavBarPosition
import dev.amethyst.enscribe.ui.pages.CreatePage
import dev.amethyst.enscribe.ui.pages.HomePage
import dev.amethyst.enscribe.ui.pages.LogPage
import dev.amethyst.enscribe.ui.pages.SettingsPage
import dev.amethyst.enscribe.ui.theme.EnscribeTheme
import dev.amethyst.enscribe.ui.theme.EnscribeTheme as ThemeEnum

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
            var isGridView by rememberSaveable { mutableStateOf(true) }
            var showCategory by rememberSaveable { mutableStateOf(true) }
            var showDateTime by rememberSaveable { mutableStateOf(true) }

            var currentTheme by rememberSaveable { mutableStateOf(ThemeEnum.Onyx) }
            val isDarkTheme = true

            var navBarPosition by rememberSaveable { mutableStateOf(NavBarPosition.Bottom) }

            EnscribeTheme(theme = currentTheme, isDarkTheme = isDarkTheme) {
                Scaffold(
                    containerColor = MaterialTheme.colorScheme.primary,
                    bottomBar = {
                        if (navBarPosition == NavBarPosition.Bottom) {
                            NavBar(
                                selectedIndex = selectedPage,
                                onItemSelected = {
                                    previousPage = selectedPage
                                    selectedPage = it
                                }
                            )
                        }
                    },
                    topBar = {
                        if (navBarPosition == NavBarPosition.Top) {
                            NavBar(
                                selectedIndex = selectedPage,
                                onItemSelected = {
                                    previousPage = selectedPage
                                    selectedPage = it
                                }
                            )
                        }
                    }
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
                                isGridView = isGridView,
                                showCategory = showCategory,
                                showDateTime = showDateTime,
                                theme = currentTheme
                            )

                            1 -> CreatePage(Modifier.padding(paddingValues))
                            2 -> LogPage(Modifier.padding(paddingValues))
                            3 -> SettingsPage(
                                modifier = Modifier.padding(paddingValues),
                                selectedTheme = currentTheme,
                                onThemeChanged = { currentTheme = it },
                                //isGridView = isGridView,
                                //showDateTime = showDateTime,
                                //showCategory = showCategory,
                                //onToggleView = { isGridView = it },
                                //onToggleDateTime = { showDateTime = it },
                                //onToggleCategory = { showCategory = it },
                                selectedNavBarPosition = navBarPosition,
                                onNavBarPositionChanged = { navBarPosition = it }
                            )
                        }
                    }
                }
            }
        }
    }
}
