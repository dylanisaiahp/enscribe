package dev.amethyst.enscribe.ui.components

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBackIos
import androidx.compose.material.icons.rounded.Notifications
import androidx.compose.material.icons.rounded.Save
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import dev.amethyst.enscribe.data.EntryType

@Composable
fun EntryEditor(
    onBack: () -> Unit,
    entryType: EntryType,
    isCreating: Boolean,
    modifier: Modifier = Modifier,
) {
    Scaffold(
        containerColor = Color.Transparent,
        modifier = modifier.fillMaxSize(),
        topBar = {
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(42.dp)
            ) {
                // Back button on the left
                IconButton(
                    onClick = onBack,
                    modifier = Modifier
                        .align(Alignment.CenterStart)
                        .height(34.dp)
                        .padding(start = 4.dp)
                ) {
                    Icon(
                        imageVector = Icons.AutoMirrored.Filled.ArrowBackIos,
                        contentDescription = "Back",
                        tint = MaterialTheme.colorScheme.onSurface
                    )
                }

                // Title derived from the EntryType and the isCreating flag
                Text(
                    text = "${if (isCreating) "Create" else "Edit"} ${entryType.name}",
                    style = MaterialTheme.typography.titleMedium,
                    color = MaterialTheme.colorScheme.onSurface,
                    modifier = Modifier.align(Alignment.Center)
                )

                // Row for action icons on the right
                Row(
                    modifier = Modifier
                        .align(Alignment.CenterEnd)
                        .height(34.dp)
                        .padding(end = 4.dp),
                    horizontalArrangement = Arrangement.spacedBy(4.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    // Reminders icon (new)
                    IconButton(
                        onClick = { /* TODO: Implement reminders functionality */ }
                    ) {
                        Icon(
                            imageVector = Icons.Rounded.Notifications,
                            contentDescription = "Set Reminder",
                            tint = MaterialTheme.colorScheme.onSurface
                        )
                    }

                    // Save icon
                    IconButton(
                        onClick = { /* TODO: Functionality to save to database, show as a EntryCard in HomePage */ }
                    ) {
                        Icon(
                            imageVector = Icons.Rounded.Save,
                            contentDescription = "Save",
                            tint = MaterialTheme.colorScheme.onSurface
                        )
                    }
                }
            }
        }
    ) { paddingValues ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(paddingValues)
        ) {
            // Display the appropriate editor UI based on the entryType
            when (entryType) {
                EntryType.Note -> NoteEditorContent()
                EntryType.Task -> TaskEditorContent()
                EntryType.Verse -> VerseEditorContent()
                EntryType.Prayer -> PrayerEditorContent()
            }
        }
    }
}

// TODO: Replace these placeholder composables with your actual editor UI.
@Composable
fun NoteEditorContent() {
    Text(text = "Note Editor UI goes here.")
}

@Composable
fun TaskEditorContent() {
    Text(text = "Task Editor UI goes here.")
}

@Composable
fun VerseEditorContent() {
    Text(text = "Verse Editor UI goes here.")
}

@Composable
fun PrayerEditorContent() {
    Text(text = "Prayer Editor UI goes here.")
}
