package dev.amethyst.enscribe.ui.pages

import androidx.compose.foundation.ExperimentalFoundationApi
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.layout.wrapContentHeight
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.lazy.grid.items
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.Sort
import androidx.compose.material.icons.filled.FilterAlt
import androidx.compose.material.icons.filled.Search
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.Checkbox
import androidx.compose.material3.CheckboxDefaults
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.DropdownMenu
import androidx.compose.material3.DropdownMenuItem
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.OutlinedTextFieldDefaults
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalFocusManager
import androidx.compose.ui.text.input.TextFieldValue
import androidx.compose.ui.unit.DpOffset
import androidx.compose.ui.unit.dp
import dev.amethyst.enscribe.entrydata.EnscribeDatabase
import dev.amethyst.enscribe.entrydata.Entry
import dev.amethyst.enscribe.ui.theme.EnscribeTheme
import kotlinx.coroutines.launch

// --- DATA & FILTER LOGIC ---
enum class NoteSortOrder(val label: String) {
    ModifiedNewest("Date (Newest)"),
    ModifiedOldest("Date (Oldest)"),
    TitleAscending("Title (A-Z)"),
    TitleDescending("Title (Z-A)"),
    CategoryAscending("Category (A-Z)"),
    CategoryDescending("Category (Z-A)");
}

fun filterAndSortNotes(
    notes: List<Entry.Note>,
    searchQuery: String,
    sortOrder: NoteSortOrder,
    selectedCategories: Set<String>
): List<Entry.Note> {
    val query = searchQuery.trim().lowercase()
    val filtered = notes.filter { note ->
        (query.isBlank() ||
                note.title.lowercase().contains(query) ||
                note.content.lowercase().contains(query)) &&
                (selectedCategories.isEmpty() || selectedCategories.contains(note.category))
    }
    return filtered.sortedWith(
        when (sortOrder) {
            NoteSortOrder.ModifiedNewest -> compareByDescending { it.modifiedAt }
            NoteSortOrder.ModifiedOldest -> compareBy { it.modifiedAt }
            NoteSortOrder.TitleAscending -> compareBy { it.title.lowercase() }
            NoteSortOrder.TitleDescending -> compareByDescending { it.title.lowercase() }
            NoteSortOrder.CategoryAscending -> compareBy(
                { it.category.lowercase() },
                { it.title.lowercase() })

            NoteSortOrder.CategoryDescending -> compareByDescending<Entry.Note> { it.category.lowercase() }
                .thenByDescending { it.title.lowercase() }
        }
    )
}

@OptIn(ExperimentalMaterial3Api::class, ExperimentalFoundationApi::class)
@Composable
fun HomePage(
    modifier: Modifier = Modifier,
    enscribeDatabase: EnscribeDatabase,
    isGridView: Boolean,
    showCategory: Boolean,
    showDateTime: Boolean,
    theme: EnscribeTheme,
) {
    var searchQuery by remember { mutableStateOf(TextFieldValue("")) }
    var currentSortOrder by remember { mutableStateOf(NoteSortOrder.ModifiedNewest) }
    var selectedCategories by remember { mutableStateOf(setOf<String>()) }
    var showFilterDialog by remember { mutableStateOf(false) }
    var showSortMenu by remember { mutableStateOf(false) }
    var displayedEntries by remember { mutableStateOf(listOf<Entry.Note>()) }
    var isLoading by remember { mutableStateOf(true) }
    val coroutineScope = rememberCoroutineScope()
    var allCategories by remember { mutableStateOf(setOf<String>()) }

    // DATA LOAD & FILTER
    LaunchedEffect(enscribeDatabase, searchQuery.text, currentSortOrder, selectedCategories) {
        coroutineScope.launch {
            isLoading = true
            val entries = enscribeDatabase.noteDao().getAll()
            allCategories = entries.map { it.category }.filter { it.isNotBlank() }.toSet()
            displayedEntries = filterAndSortNotes(
                entries,
                searchQuery.text,
                currentSortOrder,
                selectedCategories
            )
            isLoading = false
        }
    }

    EnscribeTheme(theme = theme) {
        val focusManager = LocalFocusManager.current
        Scaffold(
            containerColor = Color.Transparent,
            topBar = {
                Box(
                    modifier = Modifier
                        .background(Color.Transparent)
                        .statusBarsPadding()
                        .fillMaxWidth()
                ) {
                    Row(
                        Modifier
                            .fillMaxWidth()
                            .padding(horizontal = 16.dp)
                            .heightIn(min = 56.dp),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        OutlinedTextField(
                            value = searchQuery,
                            onValueChange = { searchQuery = it },
                            modifier = Modifier
                                .fillMaxWidth(),
                            shape = RoundedCornerShape(28.dp),
                            placeholder = {
                                Text(
                                    "Search entries…",
                                    color = MaterialTheme.colorScheme.onSurfaceVariant
                                )
                            },
                            maxLines = 1,
                            singleLine = true,
                            leadingIcon = { Icon(Icons.Filled.Search, contentDescription = null) },
                            trailingIcon = {
                                Row(
                                    verticalAlignment = Alignment.CenterVertically
                                ) {
                                    IconButton(
                                        onClick = { showFilterDialog = true },
                                        modifier = Modifier
                                            .size(32.dp)
                                    ) {
                                        Icon(
                                            Icons.Filled.FilterAlt,
                                            contentDescription = "Filter",
                                            tint = MaterialTheme.colorScheme.onSecondary
                                        )
                                    }
                                    Spacer(modifier = Modifier.width(8.dp))
                                    Box {
                                        IconButton(
                                            onClick = { showSortMenu = true },
                                            modifier = Modifier
                                                .size(32.dp)
                                        ) {
                                            Icon(
                                                Icons.AutoMirrored.Filled.Sort,
                                                contentDescription = "Sort",
                                                tint = MaterialTheme.colorScheme.onSecondary
                                            )
                                        }
                                        DropdownMenu(
                                            shape = RoundedCornerShape(16.dp),
                                            expanded = showSortMenu,
                                            onDismissRequest = { showSortMenu = false },
                                            modifier = Modifier.background(MaterialTheme.colorScheme.secondary),
                                            offset = DpOffset(0.dp, 0.dp),
                                        ) {
                                            NoteSortOrder.entries.forEach { sort ->
                                                DropdownMenuItem(
                                                    text = {
                                                        Text(
                                                            sort.label,
                                                            color = if (sort == currentSortOrder)
                                                                MaterialTheme.colorScheme.tertiary
                                                            else
                                                                MaterialTheme.colorScheme.onSecondary
                                                        )
                                                    },
                                                    onClick = {
                                                        currentSortOrder = sort
                                                        showSortMenu = false
                                                    },
                                                )
                                            }
                                        }
                                    }
                                    Spacer(modifier = Modifier.width(8.dp))
                                }
                            },
                            textStyle = MaterialTheme.typography.bodyMedium,
                            colors = OutlinedTextFieldDefaults.colors(
                                focusedContainerColor = MaterialTheme.colorScheme.secondary,
                                unfocusedContainerColor = MaterialTheme.colorScheme.secondary,
                                focusedTextColor = MaterialTheme.colorScheme.onSurface,
                                unfocusedTextColor = MaterialTheme.colorScheme.onSecondary,
                                disabledContainerColor = MaterialTheme.colorScheme.secondary,
                                cursorColor = MaterialTheme.colorScheme.tertiary,
                                focusedBorderColor = MaterialTheme.colorScheme.tertiary,
                                unfocusedBorderColor = MaterialTheme.colorScheme.secondary
                            )
                        )
                    }
                }
            },
            content = { innerPadding ->
                Column(
                    modifier = modifier
                        .fillMaxSize()
                        .padding(innerPadding)
                        .clickable(
                            interactionSource = remember { MutableInteractionSource() },
                            indication = null
                        ) { focusManager.clearFocus() }
                ) {
                    if (showFilterDialog) {
                        FilterDialog(
                            allCategories = allCategories,
                            selectedCategories = selectedCategories,
                            onDismiss = { showFilterDialog = false },
                            onApply = { selected ->
                                selectedCategories = selected
                                showFilterDialog = false
                            }
                        )
                    }

                    // Loading/empty/data views
                    when {
                        isLoading -> Box(
                            Modifier.fillMaxSize(),
                            contentAlignment = Alignment.Center
                        ) {
                            CircularProgressIndicator()
                        }

                        displayedEntries.isEmpty() -> Box(
                            Modifier.fillMaxSize(),
                            contentAlignment = Alignment.Center
                        ) {
                            Text(
                                if (searchQuery.text.isEmpty()) "You have no notes." else "No notes match your search.",
                                style = MaterialTheme.typography.bodyMedium.copy(
                                    color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.6f)
                                )
                            )
                        }

                        else -> {
                            if (isGridView) {
                                LazyVerticalGrid(
                                    columns = GridCells.Fixed(2),
                                    modifier = Modifier.fillMaxSize(),
                                    contentPadding = PaddingValues(12.dp),
                                    horizontalArrangement = Arrangement.spacedBy(14.dp),
                                    verticalArrangement = Arrangement.spacedBy(8.dp)
                                ) {
                                    items(displayedEntries, key = { it.id }) { note ->
                                        EntryCardDartView(note, showCategory, showDateTime)
                                    }
                                }
                            } else {
                                LazyColumn(
                                    modifier = Modifier.fillMaxSize(),
                                    contentPadding = PaddingValues(12.dp),
                                    verticalArrangement = Arrangement.spacedBy(8.dp)
                                ) {
                                    items(displayedEntries, key = { it.id }) { note ->
                                        EntryCardDartView(note, showCategory, showDateTime)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        )
    }
}

@Composable
fun EntryCardDartView(note: Entry.Note, showCategory: Boolean, showDateTime: Boolean) {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .wrapContentHeight(),
        shape = RoundedCornerShape(8.dp),
        colors = CardDefaults.cardColors(
            containerColor = MaterialTheme.colorScheme.surface,
        ),
        elevation = CardDefaults.cardElevation(defaultElevation = 4.dp),
    ) {
        Column(
            Modifier
                .padding(16.dp)
                .fillMaxWidth()
        ) {
            // TODO: If you have images, replace with AsyncImage, Image, or Coil image provider
            Text(
                note.title.ifBlank { "Untitled" },
                style = MaterialTheme.typography.titleLarge,
                color = MaterialTheme.colorScheme.onSurface,
                maxLines = 1
            )
            Spacer(Modifier.height(4.dp))
            Text(
                note.content.ifBlank { "No content" },
                style = MaterialTheme.typography.bodyMedium,
                maxLines = 8,
                color = MaterialTheme.colorScheme.onSurface
            )
            Spacer(Modifier.height(8.dp))
            Row(
                Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                if (showCategory && note.category.isNotBlank()) {
                    Text(
                        note.category,
                        style = MaterialTheme.typography.bodySmall,
                        color = MaterialTheme.colorScheme.secondary.copy(alpha = 0.75f)
                    )
                }
                if (showDateTime) {
                    Text(
                        formatDynamicDate(note.modifiedAt),
                        style = MaterialTheme.typography.bodySmall,
                        color = MaterialTheme.colorScheme.secondary.copy(alpha = 0.75f)
                    )
                }
            }
        }
    }
}

@Composable
fun FilterDialog(
    allCategories: Set<String>,
    selectedCategories: Set<String>,
    onDismiss: () -> Unit,
    onApply: (Set<String>) -> Unit
) {
    var tempSelected by remember { mutableStateOf(selectedCategories) }
    AlertDialog(
        onDismissRequest = onDismiss,
        confirmButton = {
            TextButton(onClick = { onApply(tempSelected) }) {
                Text("Apply", color = MaterialTheme.colorScheme.tertiary)
            }
        },
        dismissButton = {
            TextButton(onClick = onDismiss) {
                Text("Cancel", color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.5f))
            }
        },
        title = {
            Text(
                "Filter by Category",
                color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.5f)
            )
        },
        text = {
            Column {
                val sorted = allCategories.sorted()
                val allSelected =
                    tempSelected.size == sorted.size || tempSelected.isEmpty()
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Checkbox(
                        checked = allSelected,
                        onCheckedChange = { checked ->
                            tempSelected = if (checked) emptySet() else sorted.toSet()
                        },
                        colors = CheckboxDefaults.colors(
                            checkedColor = MaterialTheme.colorScheme.tertiary,
                            uncheckedColor = MaterialTheme.colorScheme.onSecondary,
                            checkmarkColor = MaterialTheme.colorScheme.onSurface,
                        )
                    )
                    Text(
                        "All Categories",
                        color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.5f)
                    )
                }
                Spacer(Modifier.height(8.dp))
                sorted.forEach { category ->
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Checkbox(
                            checked = tempSelected.contains(category),
                            onCheckedChange = { checked ->
                                tempSelected =
                                    if (checked) tempSelected + category else tempSelected - category
                            },
                            colors = CheckboxDefaults.colors(
                                checkedColor = MaterialTheme.colorScheme.tertiary,
                                uncheckedColor = MaterialTheme.colorScheme.onSecondary,
                                checkmarkColor = MaterialTheme.colorScheme.onSecondary
                            )
                        )
                        Text(category, color = MaterialTheme.colorScheme.onSecondary)
                    }
                }
            }
        },
        containerColor = MaterialTheme.colorScheme.secondary
    )
}

fun formatDynamicDate(timestamp: Long): String {
    return java.text.SimpleDateFormat("MMM dd, yyyy", java.util.Locale.getDefault())
        .format(java.util.Date(timestamp))
}