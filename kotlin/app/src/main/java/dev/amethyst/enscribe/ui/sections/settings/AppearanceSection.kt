package dev.amethyst.enscribe.ui.sections.settings

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.animateContentSize
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.lazy.grid.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.DarkMode
import androidx.compose.material.icons.filled.KeyboardArrowDown
import androidx.compose.material.icons.filled.KeyboardArrowUp
import androidx.compose.material.icons.filled.LightMode
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.unit.dp
import dev.amethyst.enscribe.ui.nav.NavBarPosition
import dev.amethyst.enscribe.ui.theme.EnscribeTheme
import dev.amethyst.enscribe.ui.theme.getThemeColors
import dev.amethyst.enscribe.ui.theme.themeDescriptions

@Composable
fun AppearanceSection(
    selectedTheme: EnscribeTheme,
    onThemeChanged: (EnscribeTheme) -> Unit,
    onSurface: Color,
    accent: Color,
    background: Color,
    textColor: Color,
    titleStyle: TextStyle,
    isDark: Boolean,
    selectedNavBarPosition: NavBarPosition,
    onNavBarPositionChanged: (NavBarPosition) -> Unit
) {
    var expanded by remember { mutableStateOf(false) }
    var navExpanded by remember { mutableStateOf(false) }

    val navLabels = listOf("Top", "Bottom", "Left", "Right")

    Column(
        modifier = Modifier
            .clip(RoundedCornerShape(16.dp))
            .background(background)
            .padding(vertical = 16.dp)
    ) {
        // Title
        Text(
            "Appearance",
            style = titleStyle.copy(color = accent),
            modifier = Modifier.padding(start = 16.dp)
        )
        Spacer(Modifier.height(12.dp))

        // === THEME SECTION ===
        Column(
            modifier = Modifier
                .clip(RoundedCornerShape(12.dp))
                .background(background)
        ) {
            Row(
                modifier = Modifier
                    .clickable { expanded = !expanded }
                    .padding(horizontal = 16.dp, vertical = 12.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Icon(
                    imageVector = if (isDark) Icons.Default.DarkMode else Icons.Default.LightMode,
                    contentDescription = null,
                    modifier = Modifier.size(28.dp)
                )
                Spacer(Modifier.width(12.dp))
                Column(Modifier.weight(1f)) {
                    Text("Theme", style = MaterialTheme.typography.bodyLarge)
                    Text(
                        "Choose your theme",
                        style = MaterialTheme.typography.bodySmall.copy(color = onSurface.copy(alpha = 0.6f))
                    )
                }
                Icon(
                    imageVector = if (expanded) Icons.Default.KeyboardArrowUp else Icons.Default.KeyboardArrowDown,
                    contentDescription = null,
                    tint = onSurface
                )
            }

            AnimatedVisibility(visible = expanded) {
                Box(
                    modifier = Modifier
                        .padding(horizontal = 16.dp, vertical = 12.dp)
                        .animateContentSize()
                ) {
                    LazyVerticalGrid(
                        columns = GridCells.Fixed(2),
                        verticalArrangement = Arrangement.spacedBy(12.dp),
                        horizontalArrangement = Arrangement.spacedBy(12.dp),
                        modifier = Modifier.heightIn(max = 400.dp) // to mimic shrinkWrap
                    ) {
                        items(EnscribeTheme.entries.toTypedArray()) { theme ->
                            val info = themeDescriptions[theme]!!
                            val colors = getThemeColors(theme)
                            val isSelected = theme == selectedTheme

                            Row(
                                modifier = Modifier
                                    .clip(RoundedCornerShape(12.dp))
                                    .background(
                                        if (isSelected) accent.copy(alpha = 0.1f)
                                        else background.copy(alpha = 0.05f)
                                    )
                                    .border(
                                        width = 2.dp,
                                        color = if (isSelected) accent else Color.Transparent,
                                        shape = RoundedCornerShape(12.dp)
                                    )
                                    .clickable { onThemeChanged(theme) }
                                    .padding(horizontal = 12.dp, vertical = 8.dp),
                                verticalAlignment = Alignment.CenterVertically
                            ) {
                                Box(
                                    modifier = Modifier
                                        .size(16.dp)
                                        .clip(CircleShape)
                                        .background(colors.accent)
                                )
                                Spacer(Modifier.width(12.dp))
                                Column {
                                    Text(
                                        info.name,
                                        style = MaterialTheme.typography.bodyMedium.copy(
                                            fontWeight = androidx.compose.ui.text.font.FontWeight.SemiBold,
                                            color = textColor
                                        )
                                    )
                                    Text(
                                        info.description,
                                        style = MaterialTheme.typography.bodySmall.copy(
                                            color = onSurface.copy(alpha = 0.6f)
                                        ),
                                        maxLines = 2
                                    )
                                }
                            }
                        }
                    }
                }
            }
        }

        Spacer(Modifier.height(16.dp))

        // === NAV BAR SECTION ===
        Column(
            modifier = Modifier
                .clip(RoundedCornerShape(12.dp))
        ) {
            Row(
                modifier = Modifier
                    .clickable { navExpanded = !navExpanded }
                    .padding(horizontal = 16.dp, vertical = 12.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Icon(
                    imageVector = Icons.Default.KeyboardArrowDown, // Replace with custom Nav icon
                    contentDescription = null,
                    tint = onSurface,
                    modifier = Modifier.size(28.dp)
                )
                Spacer(Modifier.width(12.dp))
                Column(Modifier.weight(1f)) {
                    Text("Navigation Bar", style = MaterialTheme.typography.bodyLarge)
                    Text(
                        "Choose position",
                        style = MaterialTheme.typography.bodySmall.copy(color = onSurface.copy(alpha = 0.6f))
                    )
                }
                Icon(
                    imageVector = if (navExpanded) Icons.Default.KeyboardArrowUp else Icons.Default.KeyboardArrowDown,
                    contentDescription = null,
                    tint = onSurface
                )
            }

            AnimatedVisibility(visible = navExpanded) {
                Row(
                    modifier = Modifier
                        .padding(8.dp)
                        .clip(RoundedCornerShape(16.dp))
                        .background(
                            Color(
                                red = (background.red * 255 + 255 * 0.05f).toInt(),
                                green = (background.green * 255 + 255 * 0.05f).toInt(),
                                blue = (background.blue * 255 + 255 * 0.05f).toInt()
                            )
                        )
                        .padding(8.dp),
                    horizontalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    NavBarPosition.entries.forEachIndexed { index, position ->
                        val isSelected = selectedNavBarPosition == position
                        TextButton(
                            onClick = { onNavBarPositionChanged(position) },
                            colors = ButtonDefaults.textButtonColors(
                                containerColor = if (isSelected) accent else Color.Transparent,
                                contentColor = if (isSelected) textColor else textColor.copy(alpha = 0.5f)
                            ),
                            shape = RoundedCornerShape(12.dp),
                            contentPadding = PaddingValues(horizontal = 16.dp, vertical = 8.dp)
                        ) {
                            Text(navLabels[index])
                        }
                    }
                }
            }
        }
    }
}