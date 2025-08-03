import 'package:flutter/material.dart';
import 'note.dart';
import '../pages/edit.dart';

/// A StatelessWidget that displays a single note as a tappable card.
/// It supports editing on tap and deletion on long press.
class NoteCard extends StatelessWidget {
  /// The note data to be displayed by this card.
  final Note note;

  /// A callback function that is triggered when a note is modified (edited or deleted).
  /// It takes the original note ID and the new or null note as arguments.
  final Function(String originalNoteId, Note? modifiedNote) onNoteModified;

  /// Flag to determine if the card should be displayed in a grid view layout.
  final bool isGridViewMode;

  /// Flag to control the visibility of the note's category.
  final bool showCategory;

  /// Flag to control the visibility of the note's modification date and time.
  final bool showDateTime;

  /// A list of all notes, passed to the edit page for context (e.g., to check for duplicate titles).
  final List<Note> allNotes;

  const NoteCard({
    super.key,
    required this.note,
    required this.onNoteModified,
    required this.allNotes,
    this.isGridViewMode = false,
    this.showCategory = true,
    this.showDateTime = true,
  });

  @override
  Widget build(BuildContext context) {
    // Access the current theme for consistent styling.
    final theme = Theme.of(context);
    final titleStyle = theme.textTheme.titleLarge!;
    final bodyStyle = theme.textTheme.bodyMedium!;
    final captionStyle = theme.textTheme.bodySmall!;
    final background = theme.colorScheme.secondary;
    final accent = theme.colorScheme.tertiary;

    // Define a consistent style for the dialog buttons.
    final buttonStyle = TextButton.styleFrom(
      backgroundColor: theme.brightness == Brightness.dark
          ? Color.lerp(background, Colors.white, 0.1)
          : Color.lerp(background, Colors.black, 0.1),
      foregroundColor: theme.colorScheme.onSurface,
    );

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      color: background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      // InkWell provides tap feedback and handles gestures.
      child: InkWell(
        // Handles a single tap on the card.
        onTap: () async {
          // Unfocus any active text fields.
          FocusManager.instance.primaryFocus?.unfocus(
            disposition: UnfocusDisposition.scope,
          );

          // Navigate to the edit page and wait for a result.
          final result = await Navigator.of(context).push<Note?>(
            MaterialPageRoute(
              builder: (context) =>
                  EditNotePage(note: note, allNotes: allNotes),
            ),
          );

          // Call the modification callback with the result from the edit page.
          onNoteModified(note.id, result);
        },
        // Handles a long press on the card.
        onLongPress: () async {
          // Unfocus any active text fields.
          FocusScope.of(context).unfocus();

          // Show a dialog to confirm note deletion.
          final bool? confirmDelete = await showDialog<bool>(
            context: context,
            builder: (BuildContext dialogContext) {
              return AlertDialog(
                title: const Text('Delete Note'),
                content: const Text(
                  'Are you sure? This action can not be undone.',
                ),
                actions: <Widget>[
                  TextButton(
                    style: buttonStyle,
                    onPressed: () => Navigator.of(dialogContext).pop(false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    style: buttonStyle,
                    onPressed: () => Navigator.of(dialogContext).pop(true),
                    child: const Text('Delete'),
                  ),
                ],
              );
            },
          );

          // After the dialog, request focus on a new, empty node.
          if (context.mounted) {
            FocusScope.of(context).requestFocus(FocusNode());
          }
          // If the user confirmed deletion, call the modification callback with a null result.
          if (confirmDelete == true) {
            onNoteModified(note.id, null);
          }
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: isGridViewMode
                ? MainAxisAlignment.spaceBetween
                : MainAxisAlignment.start,
            children: [
              // Display the note's title, defaulting to 'Untitled'.
              Align(
                alignment: Alignment.topLeft,
                child: Text(
                  note.title.isNotEmpty ? note.title : 'Untitled',
                  style: titleStyle.copyWith(color: accent),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 4),
              // Display the note's content, defaulting to 'No content'.
              Text(
                note.content.isNotEmpty ? note.content : 'No content',
                style: bodyStyle.copyWith(color: theme.colorScheme.onSurface),
                maxLines: isGridViewMode ? 8 : 5,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              // Conditionally display the category and date in a row.
              if (showCategory || showDateTime)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Display the note's category.
                    if (showCategory)
                      Text(
                        note.category,
                        style: captionStyle.copyWith(
                          color: theme.colorScheme.onSurface.withAlpha(153),
                        ),
                      ),
                    // Display the note's modified date.
                    if (showDateTime)
                      Text(
                        formatDynamicDate(note.modified),
                        style: captionStyle.copyWith(
                          color: theme.colorScheme.onSurface.withAlpha(153),
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
