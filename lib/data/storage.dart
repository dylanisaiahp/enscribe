import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'card.dart';

class CardStorage {
  static Database? _database;
  static const String _cardsTable = 'cards';
  static const String _preferencesTable = 'preferences';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'enscribe_cards.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_cardsTable(
        id TEXT PRIMARY KEY,
        type INTEGER,
        title TEXT,
        category TEXT,
        categoryColor INTEGER,
        content TEXT,
        tasks TEXT,
        created TEXT,
        modified TEXT,
        notification TEXT,
        backgroundColor INTEGER,
        imageUrl TEXT,
        imageIsBackground INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE $_preferencesTable(
        key TEXT PRIMARY KEY,
        value TEXT
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database migrations for future versions
    // This method will be called when the database version is increased

    // Example migration patterns:
    // if (oldVersion < 2) {
    //   await db.execute('ALTER TABLE $_cardsTable ADD COLUMN priority INTEGER DEFAULT 0');
    // }
    // if (oldVersion < 3) {
    //   await db.execute('CREATE INDEX idx_cards_modified ON $_cardsTable(modified)');
    //   await db.execute('CREATE INDEX idx_cards_category ON $_cardsTable(category)');
    // }
  }

  Future<void> savePreference(String key, String value) async {
    try {
      final db = await database;
      await db.insert(_preferencesTable, {
        'key': key,
        'value': value,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      throw Exception('Failed to save preference "$key". Details: $e');
    }
  }

  Future<String?> getPreference(String key) async {
    try {
      final db = await database;
      final maps = await db.query(
        _preferencesTable,
        where: 'key = ?',
        whereArgs: [key],
        limit: 1,
      );
      return maps.isNotEmpty ? maps.first['value'] as String? : null;
    } catch (e) {
      throw Exception('Failed to retrieve preference "$key". Details: $e');
    }
  }

  /// Add a card (note, task, etc.)
  Future<void> addCard(CardData card) async {
    try {
      final db = await database;
      await db.insert(
        _cardsTable,
        card.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw Exception('Failed to add note/card. Details: $e');
    }
  }

  /// Get all cards
  Future<List<CardData>> getCards() async {
    try {
      final db = await database;
      final maps = await db.query(_cardsTable, orderBy: 'modified DESC');
      return maps.map((map) => CardData.fromJson(map)).toList();
    } catch (e) {
      throw Exception('Failed to retrieve cards. Details: $e');
    }
  }

  /// Update a card
  Future<void> updateCard(CardData card) async {
    try {
      final db = await database;
      await db.update(
        _cardsTable,
        card.toJson(),
        where: 'id = ?',
        whereArgs: [card.id],
      );
    } catch (e) {
      throw Exception('Failed to update note/card. Details: $e');
    }
  }

  /// Delete a card
  Future<void> deleteCard(String id) async {
    try {
      final db = await database;
      await db.delete(_cardsTable, where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      throw Exception('Failed to delete note/card. Details: $e');
    }
  }

  /// Clean up
  Future<void> dispose() async {
    if (_database != null && _database!.isOpen) {
      await _database!.close();
      _database = null;
    }
  }
}
