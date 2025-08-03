import 'package:flutter/material.dart';
import 'data/note.dart';
import 'pages/load.dart';
import 'data/themes.dart';
import 'nav.dart';
import 'data/storage.dart';

/// The entry point of the application.
/// It ensures that Flutter is initialized before running the app.
void main() async {
  // This is needed to use async functions before the app starts.
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const EnscribeApp());
}

/// The root widget of the application.
/// This is a stateful widget because it holds the app's main data and settings.
class EnscribeApp extends StatefulWidget {
  const EnscribeApp({super.key});

  @override
  State<EnscribeApp> createState() => _EnscribeAppState();
}

/// The state for the EnscribeApp widget.
/// It manages all the key data for the app, like notes, themes, and settings.
class _EnscribeAppState extends State<EnscribeApp> {
  // Handles saving and loading notes and settings from local storage.
  final NoteStorage _noteStorage = NoteStorage();

  // A special listener for the list of notes, so the UI can update automatically.
  final ValueNotifier<List<Note>> _notesNotifier = ValueNotifier([]);

  // Variables for app settings.
  // These are set to a default value when the app first runs.
  EnscribeTheme _selectedTheme = EnscribeTheme.graphene;
  bool _isGridView = false;
  bool _isLoading = true;
  bool _showCategory = true;
  bool _showDateTime = true;

  /// This is the first method that runs when the app starts.
  /// We use it to load all the saved data and settings.
  @override
  void initState() {
    super.initState();
    _initializeAppData();
  }

  /// This method runs when the app is closed.
  /// It's used to clean up resources, like the note notifier.
  @override
  void dispose() {
    _notesNotifier.dispose();
    _noteStorage.dispose();
    super.dispose();
  }

  /// This method loads all the app data at startup.
  /// It first loads saved settings and then loads the notes.
  Future<void> _initializeAppData() async {
    final stopwatch = Stopwatch()..start();

    await _loadPreferences();
    await _loadNotes();

    // Ensures the loading screen is shown for at least a little while.
    const int minDurationMs = 400;
    final elapsed = stopwatch.elapsedMilliseconds;
    final remaining = minDurationMs - elapsed;
    if (remaining > 0) await Future.delayed(Duration(milliseconds: remaining));

    stopwatch.stop();

    // After loading, we update the app state to show the main screen.
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  /// Loads the user's saved preferences from local storage.
  Future<void> _loadPreferences() async {
    // Tries to get the saved theme name.
    final themeName = await _noteStorage.getPreference('selectedTheme');
    if (themeName != null) {
      _selectedTheme = EnscribeTheme.values.firstWhere(
        (e) => e.toString() == 'EnscribeTheme.$themeName',
        orElse: () => EnscribeTheme.graphene,
      );
    }

    // Loads other settings.
    _isGridView = (await _noteStorage.getPreference('isGridView')) == 'true';
    _showCategory =
        (await _noteStorage.getPreference('showCategory')) == 'true';
    _showDateTime =
        (await _noteStorage.getPreference('showDateTime')) == 'true';

    if (mounted) setState(() {});
  }

  /// Saves a user preference to local storage and reloads all preferences.
  Future<void> _savePreference(String key, String value) async {
    await _noteStorage.savePreference(key, value);
    await _loadPreferences();
  }

  /// Loads all notes from local storage into the notes notifier.
  Future<void> _loadNotes() async {
    final loadedNotes = await _noteStorage.getNotes();
    _notesNotifier.value = loadedNotes;
  }

  /// Called when a new note is created.
  /// It adds the note to storage and then reloads the notes list.
  Future<void> _onNoteCreated(Note newNote) async {
    await _noteStorage.addNote(newNote);
    await _loadNotes();
  }

  /// Called when a note is modified or deleted.
  Future<void> _onNoteModified(
    String originalNoteId,
    Note? modifiedNote,
  ) async {
    // If the modified note is null, it means the note was deleted.
    if (modifiedNote == null) {
      await _noteStorage.deleteNote(originalNoteId);
    } else {
      await _noteStorage.updateNote(modifiedNote);
    }
    await _loadNotes();
  }

  /// Updates the app's theme and saves the new theme preference.
  void _onThemeChanged(EnscribeTheme newTheme) {
    setState(() => _selectedTheme = newTheme);
    _savePreference('selectedTheme', newTheme.name);
  }

  /// Toggles between grid and list view for notes.
  void _onToggleGridView(bool value) {
    setState(() => _isGridView = value);
    _savePreference('isGridView', value.toString());
  }

  /// Toggles showing the note category on the UI.
  void _onToggleCategory(bool value) {
    setState(() => _showCategory = value);
    _savePreference('showCategory', value.toString());
  }

  /// Toggles showing the note's date and time on the UI.
  void _onToggleDateTime(bool value) {
    setState(() => _showDateTime = value);
    _savePreference('showDateTime', value.toString());
  }

  /// The main build method for the app.
  @override
  Widget build(BuildContext context) {
    final currentTheme = EnscribeThemes.themeData[_selectedTheme]!;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Enscribe',
      theme: currentTheme,
      // Shows the loading screen first, then the main navigation.
      home: _isLoading
          ? const LoadingPage()
          : ValueListenableBuilder<List<Note>>(
              valueListenable: _notesNotifier,
              builder: (context, notes, child) {
                // The HomeNavigation widget displays the notes and handles
                // all user interactions.
                return HomeNavigation(
                  notes: notes,
                  onNoteCreated: _onNoteCreated,
                  onNoteModified: _onNoteModified,
                  selectedTheme: _selectedTheme,
                  onThemeChanged: _onThemeChanged,
                  isGridView: _isGridView,
                  onToggleGridView: _onToggleGridView,
                  onToggleCategory: _onToggleCategory,
                  onToggleDateTime: _onToggleDateTime,
                  showCategory: _showCategory,
                  showDateTime: _showDateTime,
                );
              },
            ),
    );
  }
}
