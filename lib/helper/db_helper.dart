import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static const _databaseName = "news_cache.db";
  static const _databaseVersion = 1;

  static const String tableNews = 'news';

  static const String columnId = 'id';
  static const String columnCategory = 'category';
  static const String columnData = 'data';
  static const String columnTimestamp = 'timestamp';

  static Database? _database;

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  _initDatabase() async {
    final path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableNews (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnCategory TEXT NOT NULL,
        $columnData TEXT NOT NULL,
        $columnTimestamp INTEGER NOT NULL
      )
    ''');
  }

  Future<void> insertNews(String category, String data) async {
    final db = await database;
    await db.insert(
      tableNews,
      {
        columnCategory: category,
        columnData: data,
        columnTimestamp: DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>?> getNews(String category) async {
    final db = await database;
    final results = await db.query(
      tableNews,
      where: '$columnCategory = ?',
      whereArgs: [category],
      limit: 1,
    );
    if (results.isNotEmpty) return results.first;
    return null;
  }
}
