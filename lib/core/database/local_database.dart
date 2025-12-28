import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalDatabase {
  static final LocalDatabase instance = LocalDatabase._init();
  static Database? _database;

  LocalDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('labodc.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE saved_projects ADD COLUMN userId TEXT');
    }
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE saved_projects (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      userId TEXT,                         
      projectId TEXT,
      projectName TEXT,
      description TEXT,
      startDate TEXT,
      endDate TEXT,
      currentApplicants INTEGER,
      status TEXT,
      skillsJson TEXT
    )
  ''');
  }
}