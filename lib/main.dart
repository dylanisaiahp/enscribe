import 'package:flutter/material.dart';
import 'data/note.dart';
import 'pages/load.dart';
import 'data/themes.dart';
import 'nav.dart';
import 'data/storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const EnscribeApp());
}

class EnscribeApp extends StatefulWidget {
  const EnscribeApp({super.key});

  @override
  State<EnscribeApp> createState() => _EnscribeAppState();
}

class _EnscribeAppState extends State<EnscribeApp> {
  final NoteStorage _noteStorage = NoteStorage();
  final ValueNotifier<List<Note>> _notesNotifier = ValueNotifier([]);

  EnscribeTheme _selectedTheme = EnscribeTheme.graphene;
  bool _isGridView = false;
  bool _isLoading = true;
  bool _showCategory = true;
  bool _showDateTime = true;

  // NEW: NavBar position state
  NavBarPosition _selectedNavBarPosition = NavBarPosition.bottom;

  @override
  void initState() {
    super.initState();
    _initializeAppData();
  }

  @override
  void dispose() {
    _notesNotifier.dispose();
    _noteStorage.dispose();
    super.dispose();
  }

  Future<void> _initializeAppData() async {
    final stopwatch = Stopwatch()..start();

    await _loadPreferences();
    await _loadNotes();

    const int minDurationMs = 400;
    final elapsed = stopwatch.elapsedMilliseconds;
    final remaining = minDurationMs - elapsed;
    if (remaining > 0) await Future.delayed(Duration(milliseconds: remaining));

    stopwatch.stop();

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadPreferences() async {
    final themeName = await _noteStorage.getPreference('selectedTheme');
    if (themeName != null) {
      _selectedTheme = EnscribeTheme.values.firstWhere(
        (e) => e.toString() == 'EnscribeTheme.$themeName',
        orElse: () => EnscribeTheme.graphene,
      );
    }

    _isGridView = (await _noteStorage.getPreference('isGridView')) == 'true';
    _showCategory =
        (await _noteStorage.getPreference('showCategory')) == 'true';
    _showDateTime =
        (await _noteStorage.getPreference('showDateTime')) == 'true';

    // NEW: Load saved NavBar position, default to bottom if null
    final navBarPositionString = await _noteStorage.getPreference(
      'navBarPosition',
    );
    if (navBarPositionString != null) {
      _selectedNavBarPosition = NavBarPosition.values.firstWhere(
        (e) => e.toString() == 'NavBarPosition.$navBarPositionString',
        orElse: () => NavBarPosition.bottom,
      );
    }

    if (mounted) setState(() {});
  }

  Future<void> _savePreference(String key, String value) async {
    await _noteStorage.savePreference(key, value);
    await _loadPreferences();
  }

  Future<void> _loadNotes() async {
    final loadedNotes = await _noteStorage.getNotes();
    _notesNotifier.value = loadedNotes;
  }

  Future<void> _onNoteCreated(Note newNote) async {
    await _noteStorage.addNote(newNote);
    await _loadNotes();
  }

  Future<void> _onNoteModified(
    String originalNoteId,
    Note? modifiedNote,
  ) async {
    if (modifiedNote == null) {
      await _noteStorage.deleteNote(originalNoteId);
    } else {
      await _noteStorage.updateNote(modifiedNote);
    }
    await _loadNotes();
  }

  void _onThemeChanged(EnscribeTheme newTheme) {
    setState(() => _selectedTheme = newTheme);
    _savePreference('selectedTheme', newTheme.name);
  }

  void _onToggleGridView(bool value) {
    setState(() => _isGridView = value);
    _savePreference('isGridView', value.toString());
  }

  void _onToggleCategory(bool value) {
    setState(() => _showCategory = value);
    _savePreference('showCategory', value.toString());
  }

  void _onToggleDateTime(bool value) {
    setState(() => _showDateTime = value);
    _savePreference('showDateTime', value.toString());
  }

  // NEW: Handle nav bar position changes
  void _onNavBarPositionChanged(NavBarPosition newPosition) {
    setState(() => _selectedNavBarPosition = newPosition);
    _savePreference('navBarPosition', newPosition.name);
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = EnscribeThemes.themeData[_selectedTheme]!;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Enscribe',
      theme: currentTheme,
      home: _isLoading
          ? const LoadingPage()
          : ValueListenableBuilder<List<Note>>(
              valueListenable: _notesNotifier,
              builder: (context, notes, child) {
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
                  selectedNavBarPosition: _selectedNavBarPosition,
                  onNavBarPositionChanged: _onNavBarPositionChanged,
                );
              },
            ),
    );
  }
}
