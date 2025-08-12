package dev.amethyst.enscribe.ui.pages

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.rounded.ArrowForward
import androidx.compose.material.icons.rounded.Book
import androidx.compose.material.icons.rounded.CheckCircle
import androidx.compose.material.icons.rounded.EditNote
import androidx.compose.material.icons.rounded.Favorite
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp

// Import our shared EntryType enum.
import dev.amethyst.enscribe.data.models.EntryType

/**
 * The CreatePage, a simple menu for selecting an entry type.
 *
 * This Composable's only responsibility is to display the buttons
 * and to notify its parent when a button is clicked. It does not
 * manage its own state or perform navigation directly.
 *
 * @param accent The accent color for UI elements.
 * @param background The background color for buttons.
 * @param textColor The text color for buttons.
 * @param titleStyle The text style for the page title.
 * @param onEntrySelected A function that is called with the selected
 * [EntryType] when a button is clicked.
 */
@Composable
fun CreatePage(
    accent: Color,
    background: Color,
    textColor: Color,
    titleStyle: TextStyle,
    onEntrySelected: (EntryType) -> Unit,
    modifier: Modifier = Modifier
) {
    Column(
        modifier = modifier
            .fillMaxSize()
            .background(Color.Transparent)
            .padding(16.dp),
        verticalArrangement = Arrangement.Center,
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        // Page title
        Text(
            text = "Create something new",
            style = titleStyle.copy(color = accent),
            modifier = Modifier.padding(bottom = 24.dp)
        )

        // Buttons that now call the onEntrySelected lambda.
        CreateOptionButton(
            icon = Icons.Rounded.EditNote,
            title = "Note",
            subtitle = "Capture your thoughts",
            onClick = { onEntrySelected(EntryType.Note) },
            onSurface = textColor,
            background = background,
            textColor = textColor
        )
        Spacer(modifier = Modifier.height(12.dp))
        CreateOptionButton(
            icon = Icons.Rounded.CheckCircle,
            title = "Task",
            subtitle = "Plan and track actions",
            onClick = { onEntrySelected(EntryType.Task) },
            onSurface = textColor,
            background = background,
            textColor = textColor
        )
        Spacer(modifier = Modifier.height(12.dp))
        CreateOptionButton(
            icon = Icons.Rounded.Book,
            title = "Verse",
            subtitle = "Save an inspiring scripture",
            onClick = { onEntrySelected(EntryType.Verse) },
            onSurface = textColor,
            background = background,
            textColor = textColor
        )
        Spacer(modifier = Modifier.height(12.dp))
        CreateOptionButton(
            icon = Icons.Rounded.Favorite,
            title = "Prayer",
            subtitle = "Write and keep your prayers",
            onClick = { onEntrySelected(EntryType.Prayer) },
            onSurface = textColor,
            background = background,
            textColor = textColor
        )
    }
}

/**
 * The private Composable for a single button remains the same.
 */
@Composable
private fun CreateOptionButton(
    icon: ImageVector,
    title: String,
    subtitle: String,
    onClick: () -> Unit,
    onSurface: Color,
    background: Color,
    textColor: Color
) {
    val interactionSource = remember { MutableInteractionSource() }

    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(12.dp))
            .background(background)
            .clickable(
                interactionSource = interactionSource,
                indication = null,
                onClick = onClick
            )
            .padding(horizontal = 16.dp, vertical = 12.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Icon(
            imageVector = icon,
            contentDescription = title,
            tint = textColor,
            modifier = Modifier.size(28.dp)
        )
        Spacer(modifier = Modifier.width(12.dp))
        Column(
            modifier = Modifier.weight(1f)
        ) {
            Text(
                text = title,
                style = MaterialTheme.typography.bodyLarge.copy(
                    fontWeight = FontWeight.SemiBold,
                    color = textColor
                )
            )
            Text(
                text = subtitle,
                style = MaterialTheme.typography.bodySmall.copy(
                    color = textColor.copy(alpha = 0.6f)
                )
            )
        }
        Icon(
            imageVector = Icons.AutoMirrored.Rounded.ArrowForward,
            contentDescription = null,
            tint = onSurface
        )
    }
}
