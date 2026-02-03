import 'package:flutter/foundation.dart';
import '../models/task.dart';
import '../repositories/task_repository.dart';

class AddTaskViewModel extends ChangeNotifier {
  final TaskRepository _repository = TaskRepository();
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<bool> addTask(String title, String description) async {
    if (title.trim().isEmpty) {
      _error = 'Task title cannot be empty';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final task = Task(
        id: DateTime.now().millisecondsSinceEpoch,
        title: title.trim(),
        description: description.trim(),
        // Following the assignment UI, we don't emphasize status; keep a neutral default.
        status: 'Todo',
        isCompleted: false,
      );

      await _repository.insertTask(task);
      _isLoading = false;
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
