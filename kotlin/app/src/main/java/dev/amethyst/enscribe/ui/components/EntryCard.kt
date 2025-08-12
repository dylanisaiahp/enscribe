package dev.amethyst.enscribe.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import coil.compose.AsyncImage
import dev.amethyst.enscribe.data.models.Entry

@Composable
fun EntryCard(
    entry: Entry,
    onEntryClick: (Entry) -> Unit,
    // New parameters to control display based on settings
    isGridView: Boolean,
    showCategory: Boolean,
    showDateTime: Boolean,
    modifier: Modifier = Modifier
) {
    // Determine the card's background color based on the fill setting
    val cardBackgroundColor = if (entry.imageUri != null && entry.imageFillCard) {
        Color.Transparent
    } else {
        entry.backgroundColor?.let { Color(it.toULong()) } ?: MaterialTheme.colorScheme.secondary
    }

    Card(
        modifier = modifier.fillMaxWidth(),
        shape = RoundedCornerShape(16.dp),
        colors = CardDefaults.cardColors(containerColor = cardBackgroundColor),
        onClick = { onEntryClick(entry) }
    ) {
        // We use a Box to stack the image and the text content on top of each other.
        Box(
            modifier = Modifier.fillMaxWidth()
            // Removed the fixed height modifier to allow for dynamic heights.
        ) {
            // Conditionally show the image as the background if it's set to fill
            if (entry.imageUri != null && entry.imageFillCard) {
                AsyncImage(
                    model = entry.imageUri,
                    contentDescription = null,
                    contentScale = ContentScale.FillBounds,
                    modifier = Modifier.fillMaxSize()
                )
                // Add a semi-transparent overlay to ensure text is readable
                Box(
                    modifier = Modifier
                        .fillMaxSize()
                        .background(Color.Black.copy(alpha = 0.3f))
                )
            }

            // The content column is layered on top of the image
            Column(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(16.dp)
            ) {
                // Conditionally show the image as a banner if it's NOT set to fill
                if (entry.imageUri != null && !entry.imageFillCard) {
                    AsyncImage(
                        model = entry.imageUri,
                        contentDescription = null,
                        contentScale = ContentScale.Crop,
                        modifier = Modifier
                            .fillMaxWidth()
                            .height(100.dp) // Fixed height for the banner
                    )
                    Spacer(modifier = Modifier.height(8.dp))
                }

                // Top row for entry type and category
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text(
                        text = when (entry) {
                            is Entry.Note -> "NOTE"
                            is Entry.Task -> "TASK"
                            is Entry.Verse -> "VERSE"
                            is Entry.Prayer -> "PRAYER"
                        },
                        style = MaterialTheme.typography.labelSmall,
                        color = MaterialTheme.colorScheme.onSecondary,
                        fontWeight = FontWeight.Bold
                    )
                    // Conditionally show the category
                    if (showCategory && entry.category.isNotBlank()) {
                        Text(
                            text = entry.category,
                            style = MaterialTheme.typography.labelSmall,
                            color = Color(entry.categoryColor.toULong()),
                            fontWeight = FontWeight.Bold
                        )
                    }
                }
                Spacer(modifier = Modifier.height(8.dp))

                // Title
                Text(
                    text = entry.title,
                    style = MaterialTheme.typography.titleMedium,
                    color = MaterialTheme.colorScheme.onSurface,
                    // Use different max lines for grid vs list view
                    maxLines = if (isGridView) 2 else 1,
                    overflow = TextOverflow.Ellipsis
                )
                Spacer(modifier = Modifier.height(4.dp))

                // Specific content based on entry type
                when (entry) {
                    is Entry.Note -> Text(
                        text = entry.content,
                        style = MaterialTheme.typography.bodySmall,
                        color = MaterialTheme.colorScheme.onSecondary,
                        // Use different max lines for grid vs list view
                        maxLines = if (isGridView) 4 else 2,
                        overflow = TextOverflow.Ellipsis
                    )

                    is Entry.Task -> Text(
                        text = "Checklist: ${entry.checklist.size} items",
                        style = MaterialTheme.typography.bodySmall,
                        color = MaterialTheme.colorScheme.onSecondary
                    )

                    is Entry.Verse -> Text(
                        text = entry.verse,
                        style = MaterialTheme.typography.bodySmall,
                        color = MaterialTheme.colorScheme.onSecondary,
                        // Use different max lines for grid vs list view
                        maxLines = if (isGridView) 4 else 2,
                        overflow = TextOverflow.Ellipsis
                    )

                    is Entry.Prayer -> Text(
                        text = entry.prayer,
                        style = MaterialTheme.typography.bodySmall,
                        color = MaterialTheme.colorScheme.onSecondary,
                        // Use different max lines for grid vs list view
                        maxLines = if (isGridView) 4 else 2,
                        overflow = TextOverflow.Ellipsis
                    )
                }

                Spacer(modifier = Modifier.height(8.dp))

                // Conditionally show date and time
                if (showDateTime) {
                    Text(
                        text = "Modified: ${entry.formatDynamicDate()}",
                        style = MaterialTheme.typography.labelSmall,
                        color = MaterialTheme.colorScheme.onSecondary
                    )
                }
            }
        }
    }
}
