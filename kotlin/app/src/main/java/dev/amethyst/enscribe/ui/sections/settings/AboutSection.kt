package dev.amethyst.enscribe.ui.sections.settings

import android.content.Context
import android.content.Intent
import android.content.pm.PackageInfo
import android.net.Uri
import android.os.Build
import android.widget.Toast
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.rounded.Code
import androidx.compose.material.icons.rounded.Description
import androidx.compose.material.icons.rounded.Info
import androidx.compose.material.icons.rounded.SystemUpdate
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.Icon
import androidx.compose.material3.ListItem
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Shape
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.unit.dp
import androidx.core.content.FileProvider
import androidx.core.net.toUri
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import okhttp3.OkHttpClient
import okhttp3.Request
import java.io.File
import java.io.IOException

// The URL for the GitHub repository.
private val gitHubUrl = "https://github.com/dylanisaiahp/enscribe".toUri()

// The GitHub API URL to get the latest release information.
private const val githubApiUrl =
    "https://api.github.com/repos/dylanisaiahp/enscribe/releases/latest"

@Composable
fun AboutSection(
    background: Color,
    accent: Color,
    textColor: Color,
    titleStyle: TextStyle,
    onSurface: Color,
    modifier: Modifier = Modifier,
    shape: Shape = RoundedCornerShape(16.dp),
) {
    var showDescriptionSubtitle by remember { mutableStateOf(false) }
    var showVersionSubtitle by remember { mutableStateOf(false) }
    var appVersion by remember { mutableStateOf<String?>(null) }
    val interactionSource = remember { MutableInteractionSource() }
    val context = LocalContext.current


    // Fetch the app version when the version subtitle is shown.
    LaunchedEffect(showVersionSubtitle) {
        if (showVersionSubtitle && appVersion == null) {
            appVersion = getAppVersion(context)
        }
    }

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
                text = "About",
                style = titleStyle,
                color = accent,
                modifier = Modifier.padding(start = 16.dp, bottom = 8.dp)
            )

            // Description ListTile
            ListItem(
                headlineContent = { Text("Description", color = textColor) },
                leadingContent = {
                    Icon(
                        Icons.Rounded.Description,
                        contentDescription = "Description",
                        tint = onSurface
                    )
                },
                supportingContent = {
                    if (showDescriptionSubtitle) {
                        Text(
                            "Enscribe notes, tasks, and scripture.",
                            color = textColor.copy(alpha = 0.6f)
                        )
                    }
                },
                modifier = Modifier
                    .fillMaxWidth()
                    .clickable(
                        interactionSource = interactionSource,
                        indication = null,
                        onClick = { showDescriptionSubtitle = !showDescriptionSubtitle }
                    ),
                tonalElevation = 0.dp,
                shadowElevation = 0.dp,
                colors = androidx.compose.material3.ListItemDefaults.colors(
                    containerColor = background
                ),
            )

            // Version ListTile
            ListItem(
                headlineContent = { Text("Version", color = textColor) },
                leadingContent = {
                    Icon(
                        Icons.Rounded.Info,
                        contentDescription = "Version",
                        tint = onSurface
                    )
                },
                supportingContent = {
                    if (showVersionSubtitle) {
                        if (appVersion != null) {
                            Text(appVersion!!, color = textColor.copy(alpha = 0.6f))
                        } else {
                            CircularProgressIndicator(
                                modifier = Modifier.size(24.dp),
                                strokeWidth = 2.dp,
                                color = onSurface
                            )
                        }
                    }
                },
                modifier = Modifier
                    .fillMaxWidth()
                    .clickable(
                        interactionSource = interactionSource,
                        indication = null,
                        onClick = { showVersionSubtitle = !showVersionSubtitle }
                    ),
                tonalElevation = 0.dp,
                shadowElevation = 0.dp,
                colors = androidx.compose.material3.ListItemDefaults.colors(
                    containerColor = background
                ),
            )

            // Updates ListTile
            ListItem(
                headlineContent = { Text("Updates", color = textColor) },
                leadingContent = {
                    Icon(
                        Icons.Rounded.SystemUpdate,
                        contentDescription = "Updates",
                        tint = onSurface
                    )
                },
                modifier = Modifier
                    .fillMaxWidth()
                    .clickable(
                        interactionSource = interactionSource,
                        indication = null,
                        onClick = { checkForUpdates(context) }
                    ),
                tonalElevation = 0.dp,
                shadowElevation = 0.dp,
                colors = androidx.compose.material3.ListItemDefaults.colors(
                    containerColor = background
                ),
            )

            // Source Code ListTile
            ListItem(
                headlineContent = { Text("Source", color = textColor) },
                leadingContent = {
                    Icon(
                        Icons.Rounded.Code,
                        contentDescription = "Source",
                        tint = onSurface
                    )
                },
                modifier = Modifier
                    .fillMaxWidth()
                    .clickable(
                        interactionSource = interactionSource,
                        indication = null,
                        onClick = { launchUrl(context, gitHubUrl) }
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

// A helper function to get the app version.
private fun getAppVersion(context: Context): String? {
    return try {
        val packageInfo: PackageInfo =
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                context.packageManager.getPackageInfo(
                    context.packageName,
                    android.content.pm.PackageManager.PackageInfoFlags.of(0)
                )
            } else {
                @Suppress("DEPRECATION")
                context.packageManager.getPackageInfo(context.packageName, 0)
            }
        packageInfo.versionName
    } catch (_: Exception) {
        "Unknown"
    }
}

// Helper function to launch a URL safely.
private fun launchUrl(context: Context, url: Uri) {
    try {
        val intent = Intent(Intent.ACTION_VIEW, url)
        context.startActivity(intent)
    } catch (_: Exception) {
        Toast.makeText(context, "Could not open the URL: $url", Toast.LENGTH_SHORT).show()
    }
}

// Function to check for updates.
private fun checkForUpdates(context: Context) {
    // This is a placeholder as coroutines are needed for network operations
    // and would require a ViewModel or similar architecture for proper state management.
    Toast.makeText(context, "Checking for updates...", Toast.LENGTH_SHORT).show()
    // The actual update logic needs to be implemented within a coroutine scope.
}

// Function to download and install APK. This would also need to be a suspend function.
private suspend fun downloadAndInstallApk(context: Context, url: String) {
    withContext(Dispatchers.IO) {
        try {
            val client = OkHttpClient()
            val request = Request.Builder().url(url).build()
            val response = client.newCall(request).execute()

            if (response.isSuccessful) {
                val inputStream = response.body.byteStream()
                val tempDir = context.cacheDir
                val fileName = url.split("/").last()
                val file = File(tempDir, fileName)

                inputStream.use { input ->
                    file.outputStream().use { output ->
                        input.copyTo(output)
                    }
                }

                withContext(Dispatchers.Main) {
                    Toast.makeText(
                        context,
                        "Update downloaded. Launching installer...",
                        Toast.LENGTH_SHORT
                    ).show()
                    val uri = FileProvider.getUriForFile(
                        context,
                        "${context.packageName}.provider",
                        file
                    )
                    val intent = Intent(Intent.ACTION_VIEW).apply {
                        setDataAndType(uri, "application/vnd.android.package-archive")
                        flags =
                            Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_GRANT_READ_URI_PERMISSION
                    }
                    context.startActivity(intent)
                }
            } else {
                withContext(Dispatchers.Main) {
                    Toast.makeText(
                        context,
                        "Failed to download update: ${response.code}",
                        Toast.LENGTH_SHORT
                    ).show()
                }
            }
        } catch (e: IOException) {
            withContext(Dispatchers.Main) {
                Toast.makeText(
                    context,
                    "An error occurred during download: ${e.message}",
                    Toast.LENGTH_SHORT
                ).show()
            }
        }
    }
}
