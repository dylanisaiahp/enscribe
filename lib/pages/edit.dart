import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:flutter/services.dart';
import '../data/note.dart';

/// A stateful widget for editing an existing note.
/// It receives the note to be edited and a list of all notes
/// to populate the category selection dropdown.
class EditNotePage extends StatefulWidget {
  /// The note object to be edited.
  final Note note;

  /// A list of all notes in the application, used to find unique categories.
  final List<Note> allNotes;

  const EditNotePage({super.key, required this.note, required this.allNotes});

  @override
  State<EditNotePage> createState() => _EditNotePageState();
}

class _EditNotePageState extends State<EditNotePage> {
  // Controllers for the text fields to manage their content.
  late final TextEditingController _titleController;
  late final TextEditingController _categoryController;
  late final TextEditingController _contentController;

  // A focus node to control the focus of the category text field.
  final _categoryFocusNode = FocusNode();

  // A flag to track if the user has performed an action (saved or backed out).
  bool _hasPerformedAction = false;

  @override
  void initState() {
    super.initState();

    // The WidgetsBinding.instance.addPostFrameCallback schedules a callback
    // to be executed after the frame is rendered. This is used here to
    // set the system UI overlay style, ensuring the navigation bar and
    // status bar colors match the app's theme after the widget is built.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final theme = Theme.of(context);
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          systemNavigationBarColor: theme.colorScheme.primary,
          systemNavigationBarIconBrightness: theme.brightness == Brightness.dark
              ? Brightness.light
              : Brightness.dark,
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: theme.brightness == Brightness.dark
              ? Brightness.light
              : Brightness.dark,
        ),
      );
    });

    // Initialize the text controllers with the current note's data.
    _titleController = TextEditingController(text: widget.note.title);
    _categoryController = TextEditingController(text: widget.note.category);
    _contentController = TextEditingController(text: widget.note.content);
  }

  @override
  void dispose() {
    // Dispose of the controllers and focus node to free up resources.
    _titleController.dispose();
    _categoryController.dispose();
    _contentController.dispose();
    _categoryFocusNode.dispose();
    super.dispose();
  }

  /// Retrieves a set of all unique categories from the list of all notes.
  /// This is used to populate the category dropdown menu.
  Set<String> _getAllUniqueCategories() {
    return widget.allNotes
        .map((note) => note.category)
        .where((category) => category.isNotEmpty)
        .toSet();
  }

  /// Handles the save action.
  /// It unfocuses any active text fields, sets the action flag,
  /// creates a new Note object with the updated values and current timestamp,
  /// and then pops the page with the updated note.
  void _onSave() {
    FocusScope.of(context).unfocus();
    _hasPerformedAction = true;

    final updated = widget.note.copyWith(
      title: _titleController.text.trim(),
      category: _categoryController.text.trim(),
      content: _contentController.text.trim(),
      newModified: DateTime.now(),
    );

    Navigator.of(context).pop(updated);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final background = theme.colorScheme.secondary;
    final onSurface = theme.colorScheme.onSurface;
    final hintColor = onSurface.withAlpha(153);

    // PopScope handles the user's attempt to go back.
    // canPop is set to false to prevent the default back behavior.
    // onPopInvokedWithResult is called when a back gesture or button is used.
    // If no action (like saving or using the back arrow button) has been performed,
    // the original note is returned to prevent accidental changes.
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) {
          return;
        }
        if (!_hasPerformedAction) {
          FocusScope.of(context).unfocus();
          Navigator.of(context).pop(widget.note);
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            SafeArea(
              bottom: false,
              child: GestureDetector(
                // Tapping outside of a text field dismisses the keyboard.
                onTap: () => FocusScope.of(context).unfocus(),
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top bar with back button and 'Edit' title.
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back),
                            color: onSurface,
                            onPressed: () {
                              FocusScope.of(context).unfocus();
                              _hasPerformedAction = true;
                              Navigator.of(context).pop(widget.note);
                            },
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Edit',
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: onSurface,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Title input field.
                      TextField(
                        textCapitalization: TextCapitalization.sentences,
                        autocorrect: true,
                        enableSuggestions: true,
                        controller: _titleController,
                        style: TextStyle(color: onSurface),
                        decoration: InputDecoration(
                          hintText: 'Title',
                          hintStyle: TextStyle(color: hintColor),
                          prefixIcon: const Icon(
                            Symbols.title_rounded,
                            fill: 1.0,
                          ),
                          filled: true,
                          fillColor: background,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Category input field with a dropdown menu.
                      TextField(
                        textCapitalization: TextCapitalization.sentences,
                        autocorrect: true,
                        enableSuggestions: true,
                        maxLength: 12,
                        focusNode: _categoryFocusNode,
                        controller: _categoryController,
                        style: TextStyle(color: onSurface),
                        decoration: InputDecoration(
                          counterText: '',
                          hintText: 'Category',
                          hintStyle: TextStyle(color: hintColor),
                          prefixIcon: const Icon(
                            Symbols.category_rounded,
                            fill: 1.0,
                          ),
                          filled: true,
                          fillColor: background,
                          // PopupMenuButton for selecting from existing categories.
                          suffixIcon: PopupMenuButton<String>(
                            icon: Icon(
                              Symbols.filter_list_rounded,
                              color: onSurface,
                            ),
                            tooltip: 'Select category',
                            onSelected: (selectedCategory) {
                              setState(() {
                                _categoryController.text = selectedCategory;
                              });
                              _categoryFocusNode.unfocus();
                            },
                            itemBuilder: (context) {
                              final uniqueCategories =
                                  _getAllUniqueCategories().toList()..sort();
                              if (uniqueCategories.isEmpty) {
                                return [
                                  const PopupMenuItem<String>(
                                    enabled: false,
                                    child: Text('No categories created yet'),
                                  ),
                                ];
                              }
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
                      const SizedBox(height: 16),
                      // The main content text field.
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
                              padding: const EdgeInsets.only(top: 10),
                              child: Align(
                                alignment: Alignment.topCenter,
                                widthFactor: 1.0,
                                child: const Icon(
                                  Symbols.note_rounded,
                                  fill: 1.0,
                                ),
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
                          keyboardType: TextInputType.multiline,
                          expands: true,
                          maxLines: null,
                          minLines: null,
                          textAlignVertical: TextAlignVertical.top,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Bottom bar with modification/creation dates and a save button.
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Display modification and creation dates.
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Modified: ${formatDynamicDate(widget.note.modified)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: onSurface.withAlpha(180),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Created: ${formatDynamicDate(widget.note.created)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: onSurface.withAlpha(180),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    // Floating action button for saving the note.
                    SizedBox(
                      height: 48,
                      width: 96,
                      child: FloatingActionButton.extended(
                        heroTag: 'saveNote',
                        onPressed: _onSave,
                        icon: const Icon(Icons.save_rounded),
                        label: const Text('Save'),
                        backgroundColor: background,
                        foregroundColor: onSurface,
                        elevation: 0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
