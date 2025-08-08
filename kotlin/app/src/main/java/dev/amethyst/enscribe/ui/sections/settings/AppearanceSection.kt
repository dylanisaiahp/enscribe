package dev.amethyst.enscribe.ui.sections.settings

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.animateContentSize
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
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
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
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
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
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
) {
    var expanded by remember { mutableStateOf(false) }
    val interactionSource = remember { MutableInteractionSource() }

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
                    .clickable(
                        interactionSource = interactionSource,
                        indication = null,
                        onClick = { expanded = !expanded }
                    )
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
                    Text("Theme", style = MaterialTheme.typography.bodyLarge.copy(textColor))
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
                                    .clickable(
                                        interactionSource = remember { MutableInteractionSource() },
                                        indication = null,
                                        onClick = { onThemeChanged(theme) }
                                    )
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
                                            fontWeight = FontWeight.SemiBold,
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
    }
}