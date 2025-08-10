package dev.amethyst.enscribe.ui.sections.create

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.Button
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier

@Composable
fun NoteEditor(
    onBack: () -> Unit,
    modifier: Modifier = Modifier,
) {
    Column(
        modifier = modifier.fillMaxSize()
    ) {
        // Your existing Note Editor UI
        Text("This is the Note Editor")
        // A button to go back to the CreatePage
        Button(onClick = onBack) {
            Text("Back")
        }
    }
}