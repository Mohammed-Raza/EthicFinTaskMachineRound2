import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/task_model.dart';

abstract class LocalDataSource {
  Future<List<TaskModel>> getTasks();
  Future<void> cacheTask(TaskModel task);
  Future<void> deleteTask(String taskId);
  Future<List<TaskModel>> getUnsyncedTasks();
  Future<void> markAsSynced(String taskId);
}

class LocalDataSourceImpl implements LocalDataSource {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'tasks.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE tasks(
            id TEXT PRIMARY KEY,
            title TEXT,
            description TEXT,
            priority TEXT,
            dueDate TEXT,
            isCompleted INTEGER,
            createdAt TEXT,
            updatedAt TEXT,
            isSynced INTEGER
          )
        ''');
      },
    );
  }

  @override
  Future<List<TaskModel>> getTasks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('tasks', orderBy: 'createdAt DESC');
    return List.generate(maps.length, (i) => TaskModel.fromJson(maps[i]));
  }

  @override
  Future<void> cacheTask(TaskModel task) async {
    final db = await database;
    await db.insert(
      'tasks',
      task.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> deleteTask(String taskId) async {
    final db = await database;
    await db.delete('tasks', where: 'id = ?', whereArgs: [taskId]);
  }

  @override
  Future<List<TaskModel>> getUnsyncedTasks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('tasks', where: 'isSynced = ?', whereArgs: [0]);
    return List.generate(maps.length, (i) => TaskModel.fromJson(maps[i]));
  }

  @override
  Future<void> markAsSynced(String taskId) async {
    final db = await database;
    await db.update('tasks', {'isSynced': 1}, where: 'id = ?', whereArgs: [taskId]);
  }
}
