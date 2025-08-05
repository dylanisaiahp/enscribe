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
      onCreate: (db, version) async {
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
      },
    );
  }

  Future<void> savePreference(String key, String value) async {
    final db = await database;
    await db.insert(_preferencesTable, {
      'key': key,
      'value': value,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<String?> getPreference(String key) async {
    final db = await database;
    final maps = await db.query(
      _preferencesTable,
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );
    return maps.isNotEmpty ? maps.first['value'] as String? : null;
  }

  /// Add a card (note, task, etc.)
  Future<void> addCard(CardData card) async {
    final db = await database;
    await db.insert(
      _cardsTable,
      card.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get all cards
  Future<List<CardData>> getCards() async {
    final db = await database;
    final maps = await db.query(_cardsTable, orderBy: 'modified DESC');
    return maps.map((map) => CardData.fromJson(map)).toList();
  }

  /// Update a card
  Future<void> updateCard(CardData card) async {
    final db = await database;
    await db.update(
      _cardsTable,
      card.toJson(),
      where: 'id = ?',
      whereArgs: [card.id],
    );
  }

  /// Delete a card
  Future<void> deleteCard(String id) async {
    final db = await database;
    await db.delete(_cardsTable, where: 'id = ?', whereArgs: [id]);
  }

  /// Clean up
  Future<void> dispose() async {
    if (_database != null && _database!.isOpen) {
      await _database!.close();
      _database = null;
    }
  }
}
