import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// A singleton service class to manage the SQLite database connection.
/// This ensures there is only one instance of the database throughout the app's lifecycle.
class DatabaseService {
  /// The single instance of the class.
  static final DatabaseService _instance = DatabaseService._internal();

  /// A factory constructor to return the singleton instance.
  factory DatabaseService() {
    return _instance;
  }

  /// Private constructor for the singleton pattern.
  DatabaseService._internal();

  /// The private database instance, which is nullable.
  static Database? _database;

  /// A getter to provide access to the database instance.
  /// It initializes the database if it's null, otherwise, it returns the existing instance.
  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDatabase();
    return _database!;
  }

  /// Initializes the SQLite database.
  /// This method determines the database path and opens the database.
  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'enscribe_database.db');

    // Open the database with a specific version and an onCreate callback.
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  /// The callback function to create tables when the database is first created.
  /// In this case, it creates a `theme` table to store a single setting.
  Future<void> _onCreate(Database db, int version) async {
    await db.execute(
      'CREATE TABLE theme(setting TEXT PRIMARY KEY, themeName TEXT)',
    );
  }

  /// Closes the database connection.
  /// This method should be called to free up resources when the app is terminated or no longer needs the database.
  Future<void> close() async {
    if (_database != null && _database!.isOpen) {
      await _database!.close();
      _database = null;
    }
  }
}
