package dev.amethyst.enscribe.ui.components.settings

import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.rounded.Archive
import androidx.compose.material.icons.rounded.FileUpload
import androidx.compose.material.icons.rounded.Restore
import androidx.compose.material.icons.rounded.Save
import androidx.compose.material3.Icon
import androidx.compose.material3.ListItem
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Shape
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.unit.dp

@Composable
fun DatabaseSection(
    onBackup: () -> Unit,
    onRestore: () -> Unit,
    onImport: () -> Unit,
    onExport: () -> Unit,
    background: Color,
    accent: Color,
    textColor: Color,
    titleStyle: TextStyle,
    onSurface: Color,
    modifier: Modifier = Modifier,
    shape: Shape = RoundedCornerShape(16.dp),
) {
    val interactionSource = remember { MutableInteractionSource() }

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
                text = "Database",
                style = titleStyle,
                color = accent,
                modifier = Modifier.padding(start = 16.dp, bottom = 8.dp)
            )

            // Backup ListTile
            ListItem(
                headlineContent = { Text("Backup", color = textColor) },
                leadingContent = {
                    Icon(
                        Icons.Rounded.Save,
                        contentDescription = "Backup entries",
                        tint = onSurface,
                        modifier = Modifier.size(24.dp)
                    )
                },
                modifier = Modifier
                    .fillMaxWidth()
                    .clickable(
                        interactionSource = interactionSource,
                        indication = null,
                        onClick = onBackup
                    ),
                tonalElevation = 0.dp,
                shadowElevation = 0.dp,
                colors = androidx.compose.material3.ListItemDefaults.colors(
                    containerColor = background
                ),
            )

            // Restore ListTile
            ListItem(
                headlineContent = { Text("Restore", color = textColor) },
                leadingContent = {
                    Icon(
                        Icons.Rounded.Restore,
                        contentDescription = "Restore entries",
                        tint = onSurface,
                        modifier = Modifier.size(24.dp)
                    )
                },
                modifier = Modifier
                    .fillMaxWidth()
                    .clickable(
                        interactionSource = interactionSource,
                        indication = null,
                        onClick = onRestore
                    ),
                tonalElevation = 0.dp,
                shadowElevation = 0.dp,
                colors = androidx.compose.material3.ListItemDefaults.colors(
                    containerColor = background
                ),
            )

            // Export ListTile
            ListItem(
                headlineContent = { Text("Export", color = textColor) },
                leadingContent = {
                    Icon(
                        Icons.Rounded.FileUpload,
                        contentDescription = "Export entries",
                        tint = onSurface,
                        modifier = Modifier.size(24.dp)
                    )
                },
                modifier = Modifier
                    .fillMaxWidth()
                    .clickable(
                        interactionSource = interactionSource,
                        indication = null,
                        onClick = onExport
                    ),
                tonalElevation = 0.dp,
                shadowElevation = 0.dp,
                colors = androidx.compose.material3.ListItemDefaults.colors(
                    containerColor = background
                ),
            )

            // Import ListTile
            ListItem(
                headlineContent = { Text("Import", color = textColor) },
                leadingContent = {
                    Icon(
                        Icons.Rounded.Archive,
                        contentDescription = "Import entries",
                        tint = onSurface,
                        modifier = Modifier.size(24.dp)
                    )
                },
                modifier = Modifier
                    .fillMaxWidth()
                    .clickable(
                        interactionSource = interactionSource,
                        indication = null,
                        onClick = onImport
                    ),
                tonalElevation = 0.dp,
                shadowElevation = 0.dp,
                colors = androidx.compose.material3.ListItemDefaults.colors(
                    containerColor = background
                ),
            )
        }
    }
}