import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('expense_manager.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    final db = await openDatabase(
      path,
      version: 2,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _createDB,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE persons ADD COLUMN userImage TEXT');
        }
      },
    );

    // Ensure the default guest user exists (required for foreign keys since login was removed)
    await db.insert(
      'users',
      {
        'hostId': 1,
        'email': 'guest@example.com',
        'password': 'guest',
        'confirmPassword': 'guest',
        'mobileNo': '0000000000',
        'isActive': 1
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );

    return db;
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        hostId INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT NOT NULL,
        password TEXT NOT NULL,
        confirmPassword TEXT NOT NULL,
        mobileNo TEXT NOT NULL,
        createAt TEXT,
        isActive INTEGER
      )
    ''');
    
    // Insert a dummy user so that relationships with hostId = 1 don't fail if we don't use login
    await db.rawInsert('''
      INSERT INTO users (hostId, email, password, confirmPassword, mobileNo, isActive)
      VALUES (1, 'default@example.com', '123456', '123456', '0000000000', 1)
    ''');

    await db.execute('''
      CREATE TABLE events (
        eventID INTEGER PRIMARY KEY AUTOINCREMENT,
        eventName TEXT NOT NULL,
        eventDate TEXT NOT NULL,
        hostID INTEGER,
        FOREIGN KEY (hostID) REFERENCES users (hostId) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE persons (
        userID INTEGER PRIMARY KEY AUTOINCREMENT,
        userName TEXT NOT NULL,
        userImage TEXT,
        eventID INTEGER NOT NULL,
        hostID INTEGER,
        FOREIGN KEY (eventID) REFERENCES events (eventID) ON DELETE CASCADE,
        FOREIGN KEY (hostID) REFERENCES users (hostId) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE transactions (
        expenseID INTEGER PRIMARY KEY AUTOINCREMENT,
        userID INTEGER NOT NULL,
        eventID INTEGER NOT NULL,
        amount REAL NOT NULL,
        transactionDate TEXT NOT NULL,
        transactionType TEXT NOT NULL,
        description TEXT,
        hostId INTEGER,
        FOREIGN KEY (userID) REFERENCES persons (userID) ON DELETE CASCADE,
        FOREIGN KEY (eventID) REFERENCES events (eventID) ON DELETE CASCADE,
        FOREIGN KEY (hostId) REFERENCES users (hostId) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
