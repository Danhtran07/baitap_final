import '../models/task.dart';
import '../database/database_helper.dart';

class TaskRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<List<Task>> getAllTasks() async {
    return await _dbHelper.getAllTasks();
  }

  Stream<List<Task>> getAllTasksStream() {
    return _dbHelper.getAllTasksStream();
  }

  Future<Task?> getTaskById(int id) async {
    return await _dbHelper.getTaskById(id);
  }

  Future<String> insertTask(Task task) async {
    return await _dbHelper.insertTask(task);
  }

  Future<void> updateTask(Task task) async {
    return await _dbHelper.updateTask(task);
  }

  Future<void> deleteTask(int id) async {
    return await _dbHelper.deleteTask(id);
  }
}
