import 'package:flutter/foundation.dart';
import 'dart:async';
import '../models/task.dart';
import '../repositories/task_repository.dart';

class TaskListViewModel extends ChangeNotifier {
  final TaskRepository _repository = TaskRepository();
  List<Task> _tasks = [];
  bool _isLoading = false;
  String? _error;
  StreamSubscription<List<Task>>? _tasksSubscription;

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String? get error => _error;

  TaskListViewModel() {
    _setupStreamListener();
  }

  void _setupStreamListener() {
    _tasksSubscription = _repository.getAllTasksStream().listen(
      (tasks) {
        _tasks = tasks;
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
      onError: (error) {
        _error = error.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> loadTasks() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _tasks = await _repository.getAllTasks();
      _error = null;
    } catch (e) {
      _error = e.toString();
      _tasks = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTask(Task task) async {
    try {
      await _repository.insertTask(task);
      // Stream sẽ tự động cập nhật danh sách
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteTask(int id) async {
    try {
      await _repository.deleteTask(id);
      // Stream sẽ tự động cập nhật danh sách
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _tasksSubscription?.cancel();
    super.dispose();
  }
}
