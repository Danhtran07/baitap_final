import 'dart:async';

import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../models/task.dart';

/// Local SQLite database helper (Room-equivalent for Flutter).
///
/// - Stores tasks locally so the app works offline.
/// - Exposes a stream to keep MVVM list UI auto-updated.
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static const _dbName = 'uth_smarttasks.db';
  static const _dbVersion = 1;

  static const _tableTasks = 'tasks';

  Database? _db;
  final StreamController<List<Task>> _tasksStreamController =
      StreamController<List<Task>>.broadcast();

  DatabaseHelper._init();

  Future<Database> get database async {
    final existing = _db;
    if (existing != null) return existing;

    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, _dbName);

    final opened = await openDatabase(
      path,
      version: _dbVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_tableTasks (
            id INTEGER PRIMARY KEY,
            title TEXT NOT NULL,
            description TEXT NOT NULL,
            status TEXT NOT NULL,
            category TEXT,
            priority TEXT,
            date TEXT,
            dueDate TEXT,
            isCompleted INTEGER NOT NULL DEFAULT 0,
            createdAt INTEGER NOT NULL
          )
        ''');
      },
    );

    _db = opened;

    // Emit initial data
    unawaited(_emitTasks());

    return opened;
  }

  Future<String> insertTask(Task task) async {
    try {
      final db = await database;
      final values = _taskToMap(task);
      values['createdAt'] = DateTime.now().millisecondsSinceEpoch;

      await db.insert(
        _tableTasks,
        values,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      await _emitTasks();
      return task.id.toString();
    } catch (e) {
      throw Exception('Error inserting task: $e');
    }
  }

  Future<List<Task>> getAllTasks() async {
    try {
      final db = await database;
      final rows = await db.query(
        _tableTasks,
        orderBy: 'createdAt DESC',
      );
      return rows.map(_mapToTask).toList();
    } catch (e) {
      throw Exception('Error getting tasks: $e');
    }
  }

  Stream<List<Task>> getAllTasksStream() {
    return _tasksStreamController.stream;
  }

  Future<Task?> getTaskById(int id) async {
    try {
      final db = await database;
      final rows = await db.query(
        _tableTasks,
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      if (rows.isEmpty) return null;
      return _mapToTask(rows.first);
    } catch (e) {
      throw Exception('Error getting task: $e');
    }
  }

  Future<void> updateTask(Task task) async {
    try {
      final db = await database;
      await db.update(
        _tableTasks,
        _taskToMap(task),
        where: 'id = ?',
        whereArgs: [task.id],
      );
      await _emitTasks();
    } catch (e) {
      throw Exception('Error updating task: $e');
    }
  }

  Future<void> deleteTask(int id) async {
    try {
      final db = await database;
      await db.delete(
        _tableTasks,
        where: 'id = ?',
        whereArgs: [id],
      );
      await _emitTasks();
    } catch (e) {
      throw Exception('Error deleting task: $e');
    }
  }

  Future<void> _emitTasks() async {
    final tasks = await getAllTasks();
    _tasksStreamController.add(tasks);
  }

  Map<String, dynamic> _taskToMap(Task task) {
    return {
      'id': task.id,
      'title': task.title,
      'description': task.description,
      'status': task.status,
      'category': task.category,
      'priority': task.priority,
      'date': task.date,
      'dueDate': task.dueDate,
      'isCompleted': (task.isCompleted ?? false) ? 1 : 0,
    };
  }

  Task _mapToTask(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as int,
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      status: map['status'] as String? ?? 'Pending',
      category: map['category'] as String?,
      priority: map['priority'] as String?,
      date: map['date'] as String?,
      dueDate: map['dueDate'] as String?,
      isCompleted: (map['isCompleted'] as int? ?? 0) == 1,
    );
  }

  Future<void> close() async {
    await _tasksStreamController.close();
    final db = _db;
    if (db != null) {
      await db.close();
      _db = null;
    }
  }
}
