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
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.lazy.staggeredgrid.LazyVerticalStaggeredGrid
import androidx.compose.foundation.lazy.staggeredgrid.StaggeredGridCells
import androidx.compose.foundation.lazy.staggeredgrid.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.Sort
import androidx.compose.material.icons.filled.FilterAlt
import androidx.compose.material.icons.filled.Search
import androidx.compose.material3.AlertDialog
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
import dev.amethyst.enscribe.data.db.EnscribeDatabase
import dev.amethyst.enscribe.data.models.Entry
import dev.amethyst.enscribe.ui.components.EntryCard
import dev.amethyst.enscribe.ui.theme.EnscribeTheme
import kotlinx.coroutines.launch

// --- DATA & FILTER LOGIC ---
enum class EntrySortOrder(val label: String) {
    ModifiedNewest("Date (Newest)"),
    ModifiedOldest("Date (Oldest)"),
    TitleAscending("Title (A-Z)"),
    TitleDescending("Title (Z-A)"),
    CategoryAscending("Category (A-Z)"),
    CategoryDescending("Category (Z-A)");
}

fun filterAndSortEntries(
    entries: List<Entry>,
    searchQuery: String,
    sortOrder: EntrySortOrder,
    selectedCategories: Set<String>
): List<Entry> {
    val query = searchQuery.trim().lowercase()
    val filtered = entries.filter { entry ->
        (query.isBlank() ||
                entry.title.lowercase().contains(query)) &&
                (selectedCategories.isEmpty() || selectedCategories.contains(entry.category))
    }
    return filtered.sortedWith(
        when (sortOrder) {
            EntrySortOrder.ModifiedNewest -> compareByDescending { it.modifiedAt }
            EntrySortOrder.ModifiedOldest -> compareBy { it.modifiedAt }
            EntrySortOrder.TitleAscending -> compareBy { it.title.lowercase() }
            EntrySortOrder.TitleDescending -> compareByDescending { it.title.lowercase() }
            EntrySortOrder.CategoryAscending -> compareBy(
                { it.category.lowercase() },
                { it.title.lowercase() })

            EntrySortOrder.CategoryDescending -> compareByDescending<Entry> { it.category.lowercase() }
                .thenByDescending { it.title.lowercase() }
        }
    )
}

@OptIn(ExperimentalMaterial3Api::class, ExperimentalFoundationApi::class)
@Composable
fun HomePage(
    modifier: Modifier = Modifier,
    enscribeDatabase: EnscribeDatabase,
    // These parameters are now used to control the UI presentation
    isGridView: Boolean,
    showCategory: Boolean,
    showDateTime: Boolean,
    theme: EnscribeTheme,
) {
    var searchQuery by remember { mutableStateOf(TextFieldValue("")) }
    var currentSortOrder by remember { mutableStateOf(EntrySortOrder.ModifiedNewest) }
    var selectedCategories by remember { mutableStateOf(setOf<String>()) }
    var showFilterDialog by remember { mutableStateOf(false) }
    var showSortMenu by remember { mutableStateOf(false) }
    var displayedEntries by remember { mutableStateOf(listOf<Entry>()) }
    var isLoading by remember { mutableStateOf(true) }
    val coroutineScope = rememberCoroutineScope()
    var allCategories by remember { mutableStateOf(setOf<String>()) }

    LaunchedEffect(enscribeDatabase, searchQuery.text, currentSortOrder, selectedCategories) {
        coroutineScope.launch {
            isLoading = true
            val notes = enscribeDatabase.noteDao().getAll()
            val allEntries: List<Entry> = notes

            allCategories = allEntries.map { it.category }.filter { it.isNotBlank() }.toSet()
            displayedEntries = filterAndSortEntries(
                allEntries,
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
            modifier = Modifier.padding(top = 16.dp),
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
                                    color = MaterialTheme.colorScheme.onSecondary
                                )
                            },
                            maxLines = 1,
                            singleLine = true,
                            leadingIcon = {
                                Icon(
                                    Icons.Filled.Search,
                                    contentDescription = null,
                                    tint = MaterialTheme.colorScheme.onSecondary
                                )
                            },
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
                                            EntrySortOrder.entries.forEach { sort ->
                                                DropdownMenuItem(
                                                    text = {
                                                        Text(
                                                            sort.label,
                                                            color = if (sort == currentSortOrder) MaterialTheme.colorScheme.tertiary else MaterialTheme.colorScheme.onSecondary
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
                        ) { CircularProgressIndicator() }

                        displayedEntries.isEmpty() -> Box(
                            Modifier.fillMaxSize(),
                            contentAlignment = Alignment.Center
                        ) { Text("No entries found.") }
                        // The main change: Conditional rendering based on isGridView
                        isGridView -> {
                            LazyVerticalStaggeredGrid(
                                columns = StaggeredGridCells.Adaptive(minSize = 128.dp),
                                modifier = Modifier.fillMaxSize(),
                                contentPadding = PaddingValues(16.dp),
                                verticalItemSpacing = 12.dp,
                                horizontalArrangement = Arrangement.spacedBy(12.dp)
                            ) {
                                items(displayedEntries) { entry ->
                                    EntryCard(
                                        entry = entry,
                                        onEntryClick = { /* TODO: Navigate to editor */ },
                                        isGridView = true,
                                        showCategory = showCategory,
                                        showDateTime = showDateTime
                                    )
                                }
                            }
                        }

                        else -> { // Default to list view
                            LazyColumn(
                                modifier = Modifier.fillMaxSize(),
                                contentPadding = PaddingValues(16.dp),
                                verticalArrangement = Arrangement.spacedBy(12.dp)
                            ) {
                                items(displayedEntries) { entry ->
                                    EntryCard(
                                        entry = entry,
                                        onEntryClick = { /* TODO: Navigate to editor */ },
                                        isGridView = false,
                                        showCategory = showCategory,
                                        showDateTime = showDateTime
                                    )
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
fun FilterDialog(
    allCategories: Set<String>,
    selectedCategories: Set<String>,
    onDismiss: () -> Unit,
    onApply: (Set<String>) -> Unit,
) {
    AlertDialog(
        onDismissRequest = onDismiss,
        title = { Text("Filter by Category") },
        text = {
            Column {
                // ... (Implement your filter dialog UI here)
            }
        },
        confirmButton = {
            TextButton(onClick = { onApply(selectedCategories) }) {
                Text("Apply")
            }
        },
        dismissButton = {
            TextButton(onClick = onDismiss) {
                Text("Cancel")
            }
        },
    )
}
