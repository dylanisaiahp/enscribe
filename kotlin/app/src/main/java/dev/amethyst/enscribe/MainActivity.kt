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
import androidx.compose.runtime.remember
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import dev.amethyst.enscribe.ui.nav.NavBar
import dev.amethyst.enscribe.ui.pages.CreatePage
import dev.amethyst.enscribe.ui.pages.HomePage
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

            val currentTheme = ThemeEnum.Onyx
            val isDarkTheme = true

            EnscribeTheme(theme = currentTheme, isDarkTheme = isDarkTheme) {
                Scaffold(
                    containerColor = MaterialTheme.colorScheme.primary,
                    bottomBar = {
                        NavBar(
                            selectedIndex = selectedPage,
                            onItemSelected = {
                                previousPage = selectedPage
                                selectedPage = it
                            }
                        )
                    }
                ) { paddingValues ->
                    AnimatedContent(
                        targetState = selectedPage,
                        transitionSpec = {
                            val animationDuration = 350

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
                            0 -> HomePage(Modifier.padding(paddingValues))
                            1 -> CreatePage(Modifier.padding(paddingValues))
                            2 -> SettingsPage(Modifier.padding(paddingValues))
                        }
                    }
                }
            }
        }
    }
}

