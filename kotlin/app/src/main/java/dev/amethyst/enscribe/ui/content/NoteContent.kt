package dev.amethyst.enscribe.ui.content

import android.net.Uri
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.AddAPhoto
import androidx.compose.material.icons.filled.Category
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
import androidx.compose.ui.graphics.vector.rememberVectorPainter
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalFocusManager
import androidx.compose.ui.text.input.KeyboardCapitalization
import androidx.compose.ui.text.input.TextFieldValue
import androidx.compose.ui.unit.dp
import androidx.core.net.toUri

/**
 * A composable function to display and edit the content of a Note entry.
 *
 * This component is responsible for the UI layout of a single Note. It includes
 * an image, background color chooser, title, category field, and a
 * multi-line text field for the note's main content.
 *
 * @param modifier The modifier to be applied to the layout.
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun NoteContent(modifier: Modifier = Modifier) {
    // State variables to hold the content and UI state
    var title by remember { mutableStateOf(TextFieldValue("")) }
    var category by remember { mutableStateOf(TextFieldValue("")) }
    var content by remember { mutableStateOf(TextFieldValue("")) }
    var selectedImageUri by remember { mutableStateOf<Uri?>(null) }
    var cardBackgroundColor by remember { mutableStateOf<Color?>(null) }
    var isImageFillCard by remember { mutableStateOf(false) }
    var showImageDialog by remember { mutableStateOf(false) }
    var showColorDialog by remember { mutableStateOf(false) }

    // Use LocalFocusManager to clear focus when clicking outside of text fields
    val focusManager = LocalFocusManager.current

    // Dialog for image selection
    if (showImageDialog) {
        ImagePickerDialog(
            onDismissRequest = { showImageDialog = false },
            onImageSelected = { uri ->
                selectedImageUri = uri
                showImageDialog = false
            }
        )
    }

    // Dialog for color selection
    if (showColorDialog) {
        ColorPickerDialog(
            onDismissRequest = { showColorDialog = false },
            onColorSelected = { color ->
                cardBackgroundColor = color
                showColorDialog = false
            }
        )
    }

    // Main layout Column wrapped in a clickable modifier to clear focus
    Column(
        modifier = modifier
            .fillMaxSize()
            .padding(top = 16.dp, start = 16.dp, end = 16.dp)
            .clickable(
                interactionSource = remember { MutableInteractionSource() },
                indication = null
            ) { focusManager.clearFocus() },
        verticalArrangement = Arrangement.spacedBy(8.dp) // Inner spacing remains at 8.dp
    ) {
        // Row for Image and Color options
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(8.dp) // Inner spacing remains at 8.dp
        ) {
            // Image Button/Preview
            Box(
                modifier = Modifier
                    .weight(1f)
                    .height(if (selectedImageUri == null) 56.dp else 96.dp) // Dynamic height
                    .background(
                        color = MaterialTheme.colorScheme.secondary,
                        shape = MaterialTheme.shapes.small
                    ),
                contentAlignment = Alignment.Center
            ) {
                if (selectedImageUri == null) {
                    IconButton(
                        onClick = { showImageDialog = true },
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
                    // TODO: Replace with a proper image loading library like Coil
                    // AsyncImage(
                    //     model = selectedImageUri,
                    //     contentDescription = "Selected image",
                    //     contentScale = ContentScale.Crop,
                    //     modifier = Modifier.fillMaxSize()
                    // )
                    Image(
                        painter = rememberVectorPainter(image = Icons.Default.AddAPhoto),
                        contentDescription = "Selected image",
                        contentScale = ContentScale.Crop,
                        modifier = Modifier.fillMaxSize()
                    )

                    IconButton(
                        onClick = { selectedImageUri = null },
                        modifier = Modifier.align(Alignment.TopEnd)
                    ) {
                        Icon(
                            imageVector = Icons.Default.Close,
                            contentDescription = "Clear image",
                            tint = Color.White
                        )
                    }

                    IconButton(
                        onClick = { isImageFillCard = !isImageFillCard },
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
            // Background Color Button
            Box(
                modifier = Modifier
                    .weight(1f)
                    .height(if (cardBackgroundColor == null) 56.dp else 96.dp), // Dynamic height
                contentAlignment = Alignment.Center
            ) {
                Card(
                    modifier = Modifier.fillMaxSize(),
                    colors = CardDefaults.cardColors(
                        containerColor = cardBackgroundColor ?: MaterialTheme.colorScheme.secondary
                    )
                ) {
                    IconButton(
                        onClick = { showColorDialog = true },
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
                        onClick = { cardBackgroundColor = null },
                        modifier = Modifier.align(Alignment.TopEnd)
                    ) {
                        Icon(
                            imageVector = Icons.Default.Close,
                            contentDescription = "Clear background color",
                            tint = MaterialTheme.colorScheme.onSecondary
                        )
                    }
                }
            }
        }
        // Title Text Field
        OutlinedTextField(
            value = title,
            onValueChange = {
                if (it.text.length <= 16) {
                    title = it
                }
            },
            placeholder = { Text("Title") },
            modifier = Modifier.fillMaxWidth(),
            colors = OutlinedTextFieldDefaults.colors(
                focusedContainerColor = MaterialTheme.colorScheme.secondary,
                unfocusedContainerColor = MaterialTheme.colorScheme.secondary,
                focusedTextColor = MaterialTheme.colorScheme.onSurface,
                unfocusedTextColor = MaterialTheme.colorScheme.onSecondary,
                focusedPlaceholderColor = MaterialTheme.colorScheme.onSecondary,
                unfocusedPlaceholderColor = MaterialTheme.colorScheme.onSecondary,
                disabledContainerColor = MaterialTheme.colorScheme.secondary,
                cursorColor = MaterialTheme.colorScheme.tertiary,
                focusedBorderColor = MaterialTheme.colorScheme.tertiary,
                unfocusedBorderColor = MaterialTheme.colorScheme.secondary
            ),
            singleLine = true,
            keyboardOptions = KeyboardOptions(capitalization = KeyboardCapitalization.Words),
            shape = MaterialTheme.shapes.small
        )

        // Category Text Field with embedded buttons
        OutlinedTextField(
            value = category,
            onValueChange = {
                if (it.text.length <= 16) {
                    category = it
                }
            },
            placeholder = { Text("Category") },
            modifier = Modifier.fillMaxWidth(),
            colors = OutlinedTextFieldDefaults.colors(
                focusedContainerColor = MaterialTheme.colorScheme.secondary,
                unfocusedContainerColor = MaterialTheme.colorScheme.secondary,
                focusedTextColor = MaterialTheme.colorScheme.onSurface,
                unfocusedTextColor = MaterialTheme.colorScheme.onSecondary,
                focusedPlaceholderColor = MaterialTheme.colorScheme.onSecondary,
                unfocusedPlaceholderColor = MaterialTheme.colorScheme.onSecondary,
                disabledContainerColor = MaterialTheme.colorScheme.secondary,
                cursorColor = MaterialTheme.colorScheme.tertiary,
                focusedBorderColor = MaterialTheme.colorScheme.tertiary,
                unfocusedBorderColor = MaterialTheme.colorScheme.secondary
            ),
            singleLine = true,
            keyboardOptions = KeyboardOptions(capitalization = KeyboardCapitalization.Words),
            shape = MaterialTheme.shapes.small,
            trailingIcon = {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    IconButton(onClick = { /* TODO: Implement category selector */ }) {
                        Icon(
                            imageVector = Icons.Default.Category,
                            contentDescription = "Select category",
                            tint = MaterialTheme.colorScheme.onSecondary,
                        )
                    }
                    Spacer(Modifier.width(8.dp))
                    IconButton(onClick = { /* TODO: Implement category color picker */ }) {
                        Icon(
                            imageVector = Icons.Default.ColorLens,
                            contentDescription = "Choose category color",
                            tint = MaterialTheme.colorScheme.onSecondary,
                        )
                    }
                    Spacer(Modifier.width(8.dp))
                }
            }
        )

        // Main content text field
        OutlinedTextField(
            value = content,
            onValueChange = { content = it },
            placeholder = { Text("Note Content") },
            modifier = Modifier
                .fillMaxWidth()
                .weight(1f),
            colors = OutlinedTextFieldDefaults.colors(
                focusedContainerColor = MaterialTheme.colorScheme.secondary,
                unfocusedContainerColor = MaterialTheme.colorScheme.secondary,
                focusedTextColor = MaterialTheme.colorScheme.onSurface,
                unfocusedTextColor = MaterialTheme.colorScheme.onSecondary,
                focusedPlaceholderColor = MaterialTheme.colorScheme.onSecondary,
                unfocusedPlaceholderColor = MaterialTheme.colorScheme.onSecondary,
                disabledContainerColor = MaterialTheme.colorScheme.secondary,
                cursorColor = MaterialTheme.colorScheme.tertiary,
                focusedBorderColor = MaterialTheme.colorScheme.tertiary,
                unfocusedBorderColor = MaterialTheme.colorScheme.secondary
            ),
            keyboardOptions = KeyboardOptions(capitalization = KeyboardCapitalization.Sentences),
            shape = MaterialTheme.shapes.small
        )
    }
}

@Composable
private fun ImagePickerDialog(
    onDismissRequest: () -> Unit,
    onImageSelected: (Uri) -> Unit
) {
    AlertDialog(
        onDismissRequest = onDismissRequest,
        title = { Text("Image Chooser") },
        text = { Text("Choose an image from your gallery.") },
        confirmButton = {
            TextButton(onClick = {
                // This is a placeholder. The real implementation would use
                // Android's Activity Result API to open a gallery.
                onImageSelected("https://placehold.co/400x200".toUri())
            }) {
                Text("Choose from Gallery")
            }
        },
        dismissButton = {
            TextButton(onClick = onDismissRequest) {
                Text("Cancel")
            }
        }
    )
}

@Composable
private fun ColorPickerDialog(
    onDismissRequest: () -> Unit,
    onColorSelected: (Color) -> Unit
) {
    var selectedColor by remember { mutableStateOf<Color?>(null) }
    val availableColors = listOf(
        Color(0xFFF9E899), // Yellow
        Color(0xFFB5EAD7), // Green
        Color(0xFFC7CEEA), // Blue
        Color(0xFFFFADAD), // Red
        Color(0xFFFFD1A5)  // Orange
    )

    AlertDialog(
        onDismissRequest = onDismissRequest,
        title = { Text("Background Color") },
        text = {
            Column {
                Text("Select a background color for your note.")
                Spacer(modifier = Modifier.height(16.dp))
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceAround
                ) {
                    availableColors.forEach { color ->
                        Box(
                            modifier = Modifier
                                .size(48.dp)
                                .background(color, CircleShape)
                                .clickable { selectedColor = color }
                        ) {
                            if (selectedColor == color) {
                                Box(
                                    modifier = Modifier
                                        .fillMaxSize()
                                        .background(Color.White.copy(alpha = 0.4f), CircleShape)
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
                Text("OK")
            }
        },
        dismissButton = {
            TextButton(onClick = onDismissRequest) {
                Text("Cancel")
            }
        }
    )
}
