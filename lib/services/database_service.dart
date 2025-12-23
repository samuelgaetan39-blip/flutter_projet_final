import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/task.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('tasks.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const intType = 'INTEGER NOT NULL';

    await db.execute('''
      CREATE TABLE tasks (
        id $idType,
        title $textType,
        description $textType,
        category $textType,
        completed $intType,
        createdAt $textType
      )
    ''');
  }

  // CREATE
  Future<Task> createTask(Task task) async {
    final db = await instance.database;
    final id = await db.insert('tasks', task.toMap());
    return task.copyWith(id: id);
  }

  // READ - Toutes les tâches
  Future<List<Task>> getAllTasks() async {
    final db = await instance.database;
    final result = await db.query(
      'tasks',
      orderBy: 'createdAt DESC',
    );
    return result.map((map) => Task.fromMap(map)).toList();
  }

  // READ - Tâche par ID
  Future<Task?> getTask(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Task.fromMap(maps.first);
    }
    return null;
  }

  // READ - Tâches par catégorie
  Future<List<Task>> getTasksByCategory(String category) async {
    final db = await instance.database;
    final result = await db.query(
      'tasks',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'createdAt DESC',
    );
    return result.map((map) => Task.fromMap(map)).toList();
  }

  // UPDATE
  Future<int> updateTask(Task task) async {
    final db = await instance.database;
    return db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  // DELETE
  Future<int> deleteTask(int id) async {
    final db = await instance.database;
    return await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Recherche par titre
  Future<List<Task>> searchTasks(String query) async {
    final db = await instance.database;
    final result = await db.query(
      'tasks',
      where: 'title LIKE ? OR description LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'createdAt DESC',
    );
    return result.map((map) => Task.fromMap(map)).toList();
  }

  // Fermer la base de données
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}