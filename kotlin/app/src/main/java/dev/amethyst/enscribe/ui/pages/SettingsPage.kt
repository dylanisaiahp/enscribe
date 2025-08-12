package dev.amethyst.enscribe.ui.pages

import android.net.Uri
import android.widget.Toast
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.WindowInsets
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.systemBars
import androidx.compose.foundation.layout.windowInsetsPadding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.runtime.Composable
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.ui.ExperimentalComposeUiApi
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.unit.dp
import dev.amethyst.enscribe.data.db.EnscribeDatabase
import dev.amethyst.enscribe.ui.components.settings.AboutSection
import dev.amethyst.enscribe.ui.components.settings.AppearanceSection
import dev.amethyst.enscribe.ui.components.settings.DatabaseSection
import dev.amethyst.enscribe.ui.components.settings.NotesSection
import dev.amethyst.enscribe.ui.theme.EnscribeTheme
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

@OptIn(ExperimentalComposeUiApi::class)
@Composable
fun SettingsPage(
    selectedTheme: EnscribeTheme,
    onThemeChanged: (EnscribeTheme) -> Unit,
    isGridView: Boolean,
    showDateTime: Boolean,
    showCategory: Boolean,
    onToggleView: (Boolean) -> Unit,
    onToggleDateTime: (Boolean) -> Unit,
    onToggleCategory: (Boolean) -> Unit,
) {
    val theme = MaterialTheme
    val titleStyle = theme.typography.titleLarge
    val background = theme.colorScheme.secondary
    val accent = theme.colorScheme.tertiary
    val textColor = theme.colorScheme.onSurface
    val onSecondary = theme.colorScheme.onSecondary

    val context = LocalContext.current
    val coroutineScope = rememberCoroutineScope()

    val database = EnscribeDatabase.getInstance(context)

    // Launcher for creating a file (used for Backup and Export)
    val createDocumentLauncher = rememberLauncherForActivityResult(
        contract = ActivityResultContracts.CreateDocument("application/json"),
        onResult = { uri: Uri? ->
            if (uri != null) {
                coroutineScope.launch {
                    withContext(Dispatchers.IO) {
                        try {
                            val dataToExport = database.exportAllDataAsJson()
                            context.contentResolver.openOutputStream(uri)?.use { outputStream ->
                                outputStream.write(dataToExport.toByteArray())
                                withContext(Dispatchers.Main) {
                                    Toast.makeText(
                                        context,
                                        "Backup saved successfully.",
                                        Toast.LENGTH_SHORT
                                    ).show()
                                }
                            }
                        } catch (e: Exception) {
                            withContext(Dispatchers.Main) {
                                Toast.makeText(
                                    context,
                                    "Failed to save file: ${e.message}",
                                    Toast.LENGTH_LONG
                                ).show()
                            }
                        }
                    }
                }
            } else {
                Toast.makeText(context, "Backup canceled.", Toast.LENGTH_SHORT).show()
            }
        }
    )

    // Launcher for opening a file (used for Restore and Import)
    val openDocumentLauncher = rememberLauncherForActivityResult(
        contract = ActivityResultContracts.OpenDocument(),
        onResult = { uri: Uri? ->
            if (uri != null) {
                coroutineScope.launch {
                    withContext(Dispatchers.IO) {
                        try {
                            context.contentResolver.openInputStream(uri)?.use { inputStream ->
                                val dataToImport = inputStream.readBytes().toString(Charsets.UTF_8)
                                database.importDataFromJson(dataToImport)
                                withContext(Dispatchers.Main) {
                                    Toast.makeText(
                                        context,
                                        "Data restored successfully.",
                                        Toast.LENGTH_SHORT
                                    ).show()
                                }
                            }
                        } catch (e: Exception) {
                            withContext(Dispatchers.Main) {
                                Toast.makeText(
                                    context,
                                    "Failed to open file: ${e.message}",
                                    Toast.LENGTH_LONG
                                ).show()
                            }
                        }
                    }
                }
            } else {
                Toast.makeText(context, "Restore canceled.", Toast.LENGTH_SHORT).show()
            }
        }
    )

    val onBackup: () -> Unit = { createDocumentLauncher.launch("enscribe_backup.json") }
    val onRestore: () -> Unit = { openDocumentLauncher.launch(arrayOf("application/json")) }
    val onImport: () -> Unit = { openDocumentLauncher.launch(arrayOf("application/json")) }
    val onExport: () -> Unit = { createDocumentLauncher.launch("enscribe_export.json") }

    Scaffold(
        containerColor = Color.Transparent,
    ) { innerPadding ->
        LazyColumn(
            modifier = Modifier
                .windowInsetsPadding(WindowInsets.systemBars)
                .padding(horizontal = 20.dp)
                .padding(bottom = innerPadding.calculateBottomPadding() + 52.dp, top = 16.dp)
                .fillMaxSize()
        ) {
            item {
                AppearanceSection(
                    selectedTheme = selectedTheme,
                    onThemeChanged = onThemeChanged,
                    onSurface = textColor,
                    accent = accent,
                    background = background,
                    textColor = textColor,
                    titleStyle = titleStyle,
                    isDark = selectedTheme.isDark,
                )
            }
            item { Spacer(modifier = Modifier.height(16.dp)) }
            item {
                NotesSection(
                    isGridView = isGridView,
                    showDateTime = showDateTime,
                    showCategory = showCategory,
                    onToggleView = onToggleView,
                    onToggleDateTime = onToggleDateTime,
                    onToggleCategory = onToggleCategory,
                    onSurface = textColor,
                    accent = accent,
                    background = background,
                    textColor = textColor,
                    onSecondary = onSecondary,
                    titleStyle = titleStyle,
                )
            }
            item { Spacer(modifier = Modifier.height(16.dp)) }
            item {
                DatabaseSection(
                    onBackup = onBackup,
                    onRestore = onRestore,
                    onImport = onImport,
                    onExport = onExport,
                    onSurface = textColor,
                    accent = accent,
                    background = background,
                    textColor = textColor,
                    titleStyle = titleStyle,
                )
            }
            item { Spacer(modifier = Modifier.height(16.dp)) }
            item {
                AboutSection(
                    onSurface = textColor,
                    accent = accent,
                    background = background,
                    textColor = textColor,
                    titleStyle = titleStyle,
                )
            }
        }
    }
}