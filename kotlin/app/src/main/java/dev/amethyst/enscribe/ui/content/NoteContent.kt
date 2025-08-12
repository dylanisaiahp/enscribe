package dev.amethyst.enscribe.ui.content

import android.net.Uri
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.FlowRow
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.AddAPhoto
import androidx.compose.material.icons.filled.Check
import androidx.compose.material.icons.filled.Close
import androidx.compose.material.icons.filled.ColorLens
import androidx.compose.material.icons.filled.FitScreen
import androidx.compose.material.icons.filled.Fullscreen
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.OutlinedTextFieldDefaults
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalFocusManager
import androidx.compose.ui.text.input.KeyboardCapitalization
import androidx.compose.ui.unit.dp
import coil.compose.AsyncImage
import dev.amethyst.enscribe.ui.theme.ThemePalettes

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun NoteContent(
    title: String,
    onTitleChange: (String) -> Unit,
    category: String,
    onCategoryChange: (String) -> Unit,
    content: String,
    onContentChange: (String) -> Unit,
    selectedImageUri: Uri?,
    onImageChange: (Uri?) -> Unit,
    cardBackgroundColor: Color?,
    onBackgroundColorChange: (Color?) -> Unit,
    isImageFillCard: Boolean,
    onImageFillToggle: (Boolean) -> Unit,
    onImageChangeRequest: () -> Unit,
    onBackgroundColorRequest: () -> Unit,
    onCategoryColorRequest: () -> Unit,
    modifier: Modifier = Modifier
) {
    val focusManager = LocalFocusManager.current

    val textFieldColors = OutlinedTextFieldDefaults.colors(
        focusedContainerColor = MaterialTheme.colorScheme.secondary,
        unfocusedContainerColor = MaterialTheme.colorScheme.secondary,
        focusedTextColor = MaterialTheme.colorScheme.onSurface,
        unfocusedTextColor = MaterialTheme.colorScheme.onSecondary,
        focusedPlaceholderColor = MaterialTheme.colorScheme.onSecondary,
        unfocusedPlaceholderColor = MaterialTheme.colorScheme.onSecondary,
        cursorColor = MaterialTheme.colorScheme.tertiary,
        focusedBorderColor = MaterialTheme.colorScheme.tertiary,
        unfocusedBorderColor = MaterialTheme.colorScheme.secondary
    )

    Column(
        modifier = modifier
            .fillMaxSize()
            .padding(top = 16.dp, start = 16.dp, end = 16.dp)
            .clickable(
                interactionSource = remember { MutableInteractionSource() },
                indication = null
            ) { focusManager.clearFocus() },
        verticalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            // Image picker
            Box(
                modifier = Modifier
                    .weight(1f)
                    .height(if (selectedImageUri == null) 56.dp else 96.dp)
                    .background(
                        color = MaterialTheme.colorScheme.secondary,
                        shape = MaterialTheme.shapes.small
                    ),
                contentAlignment = Alignment.Center
            ) {
                if (selectedImageUri == null) {
                    IconButton(
                        onClick = onImageChangeRequest,
                        modifier = Modifier.fillMaxSize()
                    ) {
                        Icon(
                            imageVector = Icons.Default.AddAPhoto,
                            contentDescription = "Add image",
                            modifier = Modifier.size(32.dp),
                            tint = MaterialTheme.colorScheme.onSecondary,
                        )
                    }
                } else {
                    AsyncImage(
                        model = selectedImageUri,
                        contentDescription = "Selected image",
                        contentScale = if (isImageFillCard) ContentScale.Crop else ContentScale.Fit,
                        modifier = Modifier.fillMaxSize()
                    )

                    IconButton(
                        onClick = { onImageChange(null) },
                        modifier = Modifier.align(Alignment.TopEnd)
                    ) {
                        Icon(
                            imageVector = Icons.Default.Close,
                            contentDescription = "Clear image",
                            tint = Color.White
                        )
                    }

                    IconButton(
                        onClick = { onImageFillToggle(!isImageFillCard) },
                        modifier = Modifier.align(Alignment.TopStart)
                    ) {
                        Icon(
                            imageVector = if (isImageFillCard) Icons.Default.FitScreen else Icons.Default.Fullscreen,
                            contentDescription = if (isImageFillCard) "Fit image to card" else "Fill card with image",
                            tint = if (isImageFillCard) MaterialTheme.colorScheme.tertiary else Color.White
                        )
                    }
                }
            }

            // Background color picker
            Box(
                modifier = Modifier
                    .weight(1f)
                    .height(if (cardBackgroundColor == null) 56.dp else 96.dp),
                contentAlignment = Alignment.Center
            ) {
                Card(
                    modifier = Modifier.fillMaxSize(),
                    colors = CardDefaults.cardColors(
                        containerColor = cardBackgroundColor ?: MaterialTheme.colorScheme.secondary
                    )
                ) {
                    IconButton(
                        onClick = onBackgroundColorRequest,
                        modifier = Modifier.fillMaxSize()
                    ) {
                        if (cardBackgroundColor == null) {
                            Icon(
                                imageVector = Icons.Default.ColorLens,
                                contentDescription = "Choose background color",
                                modifier = Modifier.size(32.dp),
                                tint = MaterialTheme.colorScheme.onSecondary,
                            )
                        }
                    }
                }
                if (cardBackgroundColor != null) {
                    IconButton(
                        onClick = { onBackgroundColorChange(null) },
                        modifier = Modifier.align(Alignment.TopEnd)
                    ) {
                        Icon(
                            imageVector = Icons.Default.Close,
                            contentDescription = "Clear background color",
                            tint = MaterialTheme.colorScheme.onSurface
                        )
                    }
                }
            }
        }

        OutlinedTextField(
            value = title,
            onValueChange = { if (it.length <= 16) onTitleChange(it) },
            placeholder = { Text("Title") },
            modifier = Modifier.fillMaxWidth(),
            colors = textFieldColors,
            singleLine = true,
            keyboardOptions = KeyboardOptions(capitalization = KeyboardCapitalization.Words),
            shape = MaterialTheme.shapes.small
        )

        // Category + category color picker
        OutlinedTextField(
            value = category,
            onValueChange = { if (it.length <= 16) onCategoryChange(it) },
            placeholder = { Text("Category") },
            modifier = Modifier.fillMaxWidth(),
            colors = textFieldColors,
            singleLine = true,
            keyboardOptions = KeyboardOptions(capitalization = KeyboardCapitalization.Words),
            shape = MaterialTheme.shapes.small,
            trailingIcon = {
                Row {
                    IconButton(onClick = onCategoryColorRequest) {
                        Icon(
                            imageVector = Icons.Default.ColorLens,
                            contentDescription = "Choose category color",
                            tint = MaterialTheme.colorScheme.onSecondary,
                        )
                    }
                }
            }
        )

        OutlinedTextField(
            value = content,
            onValueChange = { onContentChange(it) },
            placeholder = { Text("Note Content") },
            modifier = Modifier
                .fillMaxWidth()
                .weight(1f),
            colors = textFieldColors,
            keyboardOptions = KeyboardOptions(capitalization = KeyboardCapitalization.Sentences),
            shape = MaterialTheme.shapes.small
        )
    }
}

@Composable
fun ColorPickerDialog(
    onDismissRequest: () -> Unit,
    onColorSelected: (Color) -> Unit
) {
    var selectedColor by remember { mutableStateOf<Color?>(null) }
    val availableColors = listOf(
        ThemePalettes.onyx.accent,
        ThemePalettes.midnight.accent,
        ThemePalettes.burgundy.accent,
        ThemePalettes.graphene.accent,
        ThemePalettes.amethyst.accent,
        ThemePalettes.lumen.accent,
        ThemePalettes.beige.accent,
        ThemePalettes.lavender.accent,
        ThemePalettes.aqua.accent,
        ThemePalettes.mint.accent
    )

    AlertDialog(
        onDismissRequest = onDismissRequest,
        title = { Text("Background Color") },
        text = {
            Column {
                Text("Select a background color for your note.")
                Spacer(modifier = Modifier.height(16.dp))
                FlowRow(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(8.dp),
                    verticalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    availableColors.forEach { color ->
                        Box(
                            contentAlignment = Alignment.Center,
                            modifier = Modifier
                                .size(32.dp)
                                .background(color, CircleShape)
                                .then(
                                    if (selectedColor == color) {
                                        Modifier.border(
                                            2.dp,
                                            MaterialTheme.colorScheme.onSurface,
                                            CircleShape
                                        )
                                    } else {
                                        Modifier
                                    }
                                )
                                .clickable { selectedColor = color }
                        ) {
                            if (selectedColor == color) {
                                Icon(
                                    imageVector = Icons.Default.Check,
                                    contentDescription = "Selected",
                                    tint = MaterialTheme.colorScheme.onSurface,
                                    modifier = Modifier.size(24.dp)
                                )
                            }
                        }
                    }
                }
            }
        },
        confirmButton = {
            TextButton(
                onClick = {
                    selectedColor?.let { onColorSelected(it) }
                    onDismissRequest()
                },
                enabled = selectedColor != null
            ) {
                Text("OK", color = MaterialTheme.colorScheme.onSurface)
            }
        },
        dismissButton = {
            TextButton(onClick = onDismissRequest) {
                Text("Cancel", color = MaterialTheme.colorScheme.onSurface)
            }
        }
    )
}
