import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'note.dart';

/// A class that handles all local storage operations using SQLite.
/// It acts as a singleton for the database instance.
class NoteStorage {
  /// The singleton instance of the database.
  static Database? _database;

  /// The name of the table for storing notes.
  static const String _notesTable = 'notes';

  /// The name of the table for storing application preferences.
  static const String _preferencesTable = 'preferences';

  /// A getter to access the database instance.
  /// It initializes the database if it has not been created yet.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  /// Initializes the SQLite database and creates the necessary tables.
  /// This method is called only once when the database is first accessed.
  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'enscribe_notes.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // SQL to create the notes table.
        await db.execute('''
          CREATE TABLE $_notesTable(
            id TEXT PRIMARY KEY,
            title TEXT,
            category TEXT,
            content TEXT,
            created TEXT,
            modified TEXT
          )
        ''');
        // SQL to create the preferences table for key-value pairs.
        await db.execute('''
          CREATE TABLE $_preferencesTable(
            key TEXT PRIMARY KEY,
            value TEXT
          )
        ''');
      },
    );
  }

  /// Saves a key-value preference to the preferences table.
  /// If the key already exists, the value is replaced.
  Future<void> savePreference(String key, String value) async {
    final db = await database;
    await db.insert(_preferencesTable, {
      'key': key,
      'value': value,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Retrieves a value from the preferences table based on its key.
  /// Returns `null` if the key is not found.
  Future<String?> getPreference(String key) async {
    final db = await database;
    final maps = await db.query(
      _preferencesTable,
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return maps.first['value'] as String?;
    }
    return null;
  }

  /// Adds a new note to the notes table.
  /// If a note with the same ID already exists, it will be replaced.
  Future<void> addNote(Note note) async {
    final db = await database;
    await db.insert(
      _notesTable,
      note.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Retrieves all notes from the notes table, sorted by the most recently modified first.
  Future<List<Note>> getNotes() async {
    final db = await database;
    final maps = await db.query(_notesTable, orderBy: 'modified DESC');
    return maps.map((map) => Note.fromJson(map)).toList();
  }

  /// Updates an existing note in the notes table.
  /// The note is identified by its unique `id`.
  Future<void> updateNote(Note note) async {
    final db = await database;
    await db.update(
      _notesTable,
      note.toJson(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  /// Deletes a note from the notes table based on its unique `id`.
  Future<void> deleteNote(String id) async {
    final db = await database;
    await db.delete(_notesTable, where: 'id = ?', whereArgs: [id]);
  }

  /// Closes the database connection to free up resources.
  /// This should be called when the application is shutting down.
  Future<void> dispose() async {
    if (_database != null && _database!.isOpen) {
      await _database!.close();
      _database = null;
    }
  }
}
