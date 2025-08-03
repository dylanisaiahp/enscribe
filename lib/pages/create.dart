import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../data/note.dart'; // Import the Note data model.

/// A stateful widget for creating a new note.
/// It takes a callback function to handle the creation of a new note
/// and a list of all existing notes to populate the category suggestions.
class CreateNotePage extends StatefulWidget {
  // Callback function to be executed when a new note is created.
  final Function(Note) onNoteCreated;
  // A list of all existing notes, used to get unique categories.
  final List<Note> allNotes;

  const CreateNotePage({
    super.key,
    required this.onNoteCreated,
    required this.allNotes,
  });

  @override
  State<CreateNotePage> createState() => _CreateNotePageState();
}

/// The state class for the CreateNotePage widget.
class _CreateNotePageState extends State<CreateNotePage> {
  // Text controllers to manage the input for title, category, and content.
  final _titleController = TextEditingController();
  final _categoryController = TextEditingController();
  final _contentController = TextEditingController();
  // A focus node to control the focus of the category text field.
  final _categoryFocusNode = FocusNode();

  @override
  void dispose() {
    // Dispose of all controllers and focus nodes to prevent memory leaks.
    _titleController.dispose();
    _categoryController.dispose();
    _contentController.dispose();
    _categoryFocusNode.dispose();
    super.dispose();
  }

  /// Extracts all unique categories from the list of all notes.
  /// It maps each note to its category, filters out empty categories,
  /// and returns a Set to ensure uniqueness.
  Set<String> _getAllUniqueCategories() => widget.allNotes
      .map((note) => note.category)
      .where((category) => category.isNotEmpty)
      .toSet();

  /// Creates a new Note object and calls the onNoteCreated callback.
  void _saveNote() {
    // Unfocus any active text field to dismiss the keyboard.
    FocusScope.of(context).unfocus();

    // Create a new Note instance with current data and timestamps.
    final note = Note(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      category: _categoryController.text.trim(),
      content: _contentController.text.trim(),
      created: DateTime.now(),
      modified: DateTime.now(),
    );

    // Call the callback function provided by the parent widget.
    widget.onNoteCreated(note);

    // Clear all text fields after saving the note.
    _titleController.clear();
    _categoryController.clear();
    _contentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    // Get the current theme to style the widgets.
    final theme = Theme.of(context);
    final background = theme.colorScheme.secondary;
    final onSurface = theme.colorScheme.onSurface;
    final hintColor = onSurface.withAlpha(
      153,
    ); // A faded version of the onSurface color.

    return Scaffold(
      // The main layout widget for the screen.
      body: SafeArea(
        // Ensures the content avoids system overlays like the status bar.
        bottom: false,
        child: GestureDetector(
          // Allows dismissing the keyboard by tapping outside of a text field.
          onTap: () => FocusScope.of(context).unfocus(),
          behavior:
              HitTestBehavior.opaque, // Ensures the entire area is tappable.
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Text field for the note's title.
                TextField(
                  textCapitalization: TextCapitalization.sentences,
                  autocorrect: true,
                  enableSuggestions: true,
                  controller: _titleController,
                  style: TextStyle(color: onSurface),
                  decoration: InputDecoration(
                    hintText: 'Title',
                    hintStyle: TextStyle(color: hintColor),
                    prefixIcon: const Icon(Symbols.title_rounded, fill: 1.0),
                    filled: true,
                    fillColor: background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16), // Spacer.
                // Text field for the note's category.
                TextField(
                  textCapitalization: TextCapitalization.sentences,
                  autocorrect: true,
                  enableSuggestions: true,
                  maxLength: 12, // Limits the category length.
                  focusNode: _categoryFocusNode,
                  controller: _categoryController,
                  style: TextStyle(color: onSurface),
                  decoration: InputDecoration(
                    counterText: '', // Hides the character counter.
                    hintText: 'Category',
                    hintStyle: TextStyle(color: hintColor),
                    prefixIcon: const Icon(Symbols.category_rounded, fill: 1.0),
                    filled: true,
                    fillColor: background,
                    // Suffix icon with a PopupMenuButton for category suggestions.
                    suffixIcon: PopupMenuButton<String>(
                      icon: Icon(Symbols.filter_list_rounded, color: onSurface),
                      tooltip: 'Select category',
                      onSelected: (selectedCategory) {
                        setState(() {
                          _categoryController.text =
                              selectedCategory; // Update the text field with the selected category.
                        });
                        _categoryFocusNode.unfocus(); // Dismiss the keyboard.
                      },
                      itemBuilder: (context) {
                        final uniqueCategories =
                            _getAllUniqueCategories().toList()
                              ..sort(); // Get and sort unique categories.
                        if (uniqueCategories.isEmpty) {
                          // Show a message if there are no existing categories.
                          return [
                            const PopupMenuItem<String>(
                              enabled: false,
                              child: Text('No categories created yet'),
                            ),
                          ];
                        }
                        // Create a menu item for each unique category.
                        return uniqueCategories
                            .map(
                              (category) => PopupMenuItem<String>(
                                value: category,
                                child: Text(category),
                              ),
                            )
                            .toList();
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    suffixIconConstraints: const BoxConstraints(
                      minWidth: 48,
                      minHeight: 48,
                    ),
                  ),
                ),
                const SizedBox(height: 16), // Spacer.
                // Expanded text field for the note's content.
                Expanded(
                  child: TextField(
                    textCapitalization: TextCapitalization.sentences,
                    autocorrect: true,
                    enableSuggestions: true,
                    controller: _contentController,
                    style: TextStyle(color: onSurface),
                    decoration: InputDecoration(
                      hintText: 'Write your note here…',
                      hintStyle: TextStyle(color: hintColor),
                      prefixIcon: Padding(
                        // Align the note icon to the top left of the text field.
                        padding: const EdgeInsets.only(top: 10),
                        child: Align(
                          alignment: Alignment.topCenter,
                          widthFactor: 1.0,
                          child: const Icon(Symbols.note_rounded, fill: 1.0),
                        ),
                      ),
                      filled: true,
                      fillColor: background,
                      contentPadding: const EdgeInsets.all(12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    keyboardType:
                        TextInputType.multiline, // Enables multiline input.
                    expands:
                        true, // Allows the text field to expand to fill available space.
                    maxLines: null,
                    minLines: null,
                    textAlignVertical:
                        TextAlignVertical.top, // Aligns text to the top.
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      // The floating action button to save the note.
      floatingActionButton: SizedBox(
        height: 48,
        width: 96,
        child: FloatingActionButton.extended(
          onPressed:
              _saveNote, // The function to call when the button is pressed.
          label: const Text('Create'),
          backgroundColor: background,
          foregroundColor: onSurface,
          elevation: 0,
          extendedPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
        ),
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.endFloat, // Positions the FAB.
    );
  }
}
