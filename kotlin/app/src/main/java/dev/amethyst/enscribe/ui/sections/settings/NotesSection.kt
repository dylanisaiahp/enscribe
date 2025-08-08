package dev.amethyst.enscribe.ui.sections.settings

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.rounded.ViewList
import androidx.compose.material.icons.rounded.Category
import androidx.compose.material.icons.rounded.Dashboard
import androidx.compose.material.icons.rounded.Schedule
import androidx.compose.material3.Icon
import androidx.compose.material3.ListItem
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Switch
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Shape
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.unit.dp

@Composable
fun NotesSection(
    isGridView: Boolean,
    showDateTime: Boolean,
    showCategory: Boolean,
    onToggleView: (Boolean) -> Unit,
    onToggleDateTime: (Boolean) -> Unit,
    onToggleCategory: (Boolean) -> Unit,
    onSurface: Color,
    onSecondary: Color,
    accent: Color,
    background: Color,
    textColor: Color,
    titleStyle: TextStyle,
    modifier: Modifier = Modifier,
    shape: Shape = RoundedCornerShape(16.dp),
) {
    Surface(
        modifier = modifier.fillMaxWidth(),
        shape = shape,
        color = background,
        tonalElevation = 0.dp
    ) {
        Column(
            modifier = Modifier
                .padding(vertical = 16.dp, horizontal = 4.dp)
                .fillMaxWidth()
        ) {
            Text(
                text = "Notes",
                style = titleStyle,
                color = accent,
                modifier = Modifier.padding(start = 16.dp, bottom = 8.dp)
            )

            Column(modifier = Modifier.fillMaxWidth()) {
                SwitchListRow(
                    iconSelected = Icons.Rounded.Dashboard,
                    iconUnselected = Icons.AutoMirrored.Rounded.ViewList,
                    title = "View",
                    subtitle = "Toggle grid/column view",
                    checked = isGridView,
                    onCheckedChange = onToggleView,
                    onSurface = onSurface,
                    accent = accent,
                    textColor = textColor,
                    onSecondary = onSecondary,
                )
                SwitchListRow(
                    iconSelected = Icons.Rounded.Schedule,
                    iconUnselected = Icons.Rounded.Schedule,
                    title = "Timestamp",
                    subtitle = "Show date and time",
                    checked = showDateTime,
                    onCheckedChange = onToggleDateTime,
                    onSurface = onSurface,
                    accent = accent,
                    textColor = textColor,
                    onSecondary = onSecondary,
                )
                SwitchListRow(
                    iconSelected = Icons.Rounded.Category,
                    iconUnselected = Icons.Rounded.Category,
                    title = "Category",
                    subtitle = "Display entry category",
                    checked = showCategory,
                    onCheckedChange = onToggleCategory,
                    onSurface = onSurface,
                    accent = accent,
                    textColor = textColor,
                    onSecondary = onSecondary,
                )
            }
        }
    }
}

@Composable
private fun SwitchListRow(
    iconSelected: ImageVector,
    iconUnselected: ImageVector,
    title: String,
    subtitle: String,
    checked: Boolean,
    onCheckedChange: (Boolean) -> Unit,
    onSurface: Color,
    accent: Color,
    textColor: Color,
    onSecondary: Color,
    modifier: Modifier = Modifier
) {
    ListItem(
        headlineContent = {
            Text(title, color = textColor)
        },
        supportingContent = {
            Text(
                subtitle,
                style = MaterialTheme.typography.bodySmall.copy(color = onSurface.copy(alpha = 0.6f))
            )
        },
        leadingContent = {
            Icon(
                imageVector = if (checked) iconSelected else iconUnselected,
                contentDescription = title,
                modifier = Modifier.size(24.dp),
                tint = onSurface
            )
        },
        trailingContent = {
            Switch(
                checked = checked,
                onCheckedChange = onCheckedChange,
                colors = androidx.compose.material3.SwitchDefaults.colors(
                    checkedTrackColor = accent,
                    checkedThumbColor = onSurface,
                    uncheckedTrackColor = onSecondary.copy(alpha = 0.5f),
                    uncheckedThumbColor = onSurface,
                    uncheckedBorderColor = Color.Transparent,
                )
            )
        },
        modifier = modifier
    )
}
