package dev.amethyst.enscribe.ui.components

import android.net.Uri
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
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
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.unit.dp
import dev.amethyst.enscribe.data.db.EnscribeDatabase
import dev.amethyst.enscribe.data.models.Entry
import dev.amethyst.enscribe.data.models.EntryType
import dev.amethyst.enscribe.ui.content.ColorPickerDialog
import dev.amethyst.enscribe.ui.content.NoteContent
import kotlinx.coroutines.launch
import java.time.Instant

@Composable
fun EntryEditor(
    onNavItemSelected: (Int) -> Unit,
    entryType: EntryType,
    isCreating: Boolean,
    modifier: Modifier = Modifier
) {
    val context = LocalContext.current
    val db = remember { EnscribeDatabase.getInstance(context) }
    val scope = rememberCoroutineScope()

    // Note state
    val title = remember { mutableStateOf("") }
    val category = remember { mutableStateOf("") }
    val content = remember { mutableStateOf("") }
    val imageUri = remember { mutableStateOf<Uri?>(null) }
    val backgroundColor = remember { mutableStateOf<Color?>(null) }
    val isImageFill = remember { mutableStateOf(false) }
    val categoryColor = remember { mutableIntStateOf(0) }
    val reminder = remember { mutableStateOf<Instant?>(null) }

    // Dialog visibility state
    val showBgColorDialog = remember { mutableStateOf(false) }
    val showCategoryColorDialog = remember { mutableStateOf(false) }

    // Image picker launcher
    val imagePickerLauncher = rememberLauncherForActivityResult(
        contract = ActivityResultContracts.GetContent()
    ) { uri: Uri? ->
        uri?.let { imageUri.value = it }
    }

    // Background color dialog
    if (showBgColorDialog.value) {
        ColorPickerDialog(
            onDismissRequest = { showBgColorDialog.value = false },
            onColorSelected = { color ->
                backgroundColor.value = color
                showBgColorDialog.value = false
            }
        )
    }

    // Category color dialog
    if (showCategoryColorDialog.value) {
        ColorPickerDialog(
            onDismissRequest = { showCategoryColorDialog.value = false },
            onColorSelected = { color ->
                categoryColor.intValue = color.value.toInt()
                showCategoryColorDialog.value = false
            }
        )
    }

    Scaffold(
        containerColor = Color.Transparent,
        modifier = modifier.fillMaxSize(),
        topBar = {
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(36.dp)
            ) {
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(start = 4.dp)
                ) {
                    IconButton(
                        onClick = { onNavItemSelected(0) }, // Back to Home
                        modifier = Modifier.height(32.dp)
                    ) {
                        Icon(
                            imageVector = Icons.AutoMirrored.Filled.ArrowBackIos,
                            contentDescription = "Back",
                            tint = MaterialTheme.colorScheme.onSurface
                        )
                    }

                    Text(
                        text = "${if (isCreating) "Create" else "Edit"} ${entryType.name}",
                        style = MaterialTheme.typography.titleMedium,
                        color = MaterialTheme.colorScheme.onSurface,
                    )
                }

                Row(
                    modifier = Modifier
                        .align(Alignment.CenterEnd)
                        .height(34.dp)
                        .padding(end = 4.dp),
                    horizontalArrangement = Arrangement.spacedBy(4.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    // Reminder button
                    IconButton(
                        onClick = {
                            // TODO: Date/time picker integration
                            reminder.value = Instant.now().plusSeconds(3600) // +1hr demo
                        }
                    ) {
                        Icon(
                            imageVector = Icons.Rounded.Notifications,
                            contentDescription = "Set Reminder",
                            tint = MaterialTheme.colorScheme.onSurface
                        )
                    }

                    // Save button
                    IconButton(
                        onClick = {
                            scope.launch {
                                val now = System.currentTimeMillis()
                                when (entryType) {
                                    EntryType.Note -> {
                                        val note = Entry.Note(
                                            title = title.value,
                                            category = category.value,
                                            categoryColor = categoryColor.intValue,
                                            backgroundColor = backgroundColor.value?.value?.toInt(),
                                            imageUri = imageUri.value?.toString(),
                                            imageFillCard = isImageFill.value,
                                            hasReminder = null, // Hook reminder later
                                            createdAt = now,
                                            modifiedAt = now,
                                            content = content.value
                                        )
                                        db.noteDao().insert(note)
                                    }

                                    else -> {}
                                }
                                onNavItemSelected(0) // Go Home after save
                            }
                        }
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
            if (entryType == EntryType.Note) {
                NoteContent(
                    title = title.value,
                    onTitleChange = { title.value = it },
                    category = category.value,
                    onCategoryChange = { category.value = it },
                    content = content.value,
                    onContentChange = { content.value = it },
                    selectedImageUri = imageUri.value,
                    onImageChange = { imageUri.value = it },
                    cardBackgroundColor = backgroundColor.value,
                    onBackgroundColorChange = { backgroundColor.value = it },
                    isImageFillCard = isImageFill.value,
                    onImageFillToggle = { isImageFill.value = it },
                    onImageChangeRequest = { imagePickerLauncher.launch("image/*") },
                    onBackgroundColorRequest = { showBgColorDialog.value = true },
                    onCategoryColorRequest = { showCategoryColorDialog.value = true }
                )
            }
        }
    }
}
