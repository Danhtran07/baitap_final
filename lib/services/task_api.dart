import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/task.dart';

class TaskApi {
  static const String baseUrl = "https://amock.io/api/researchUTH";

  // GET LIST TASKS
  static Future<List<Task>> getTasks() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/tasks"));

      if (response.statusCode != 200) {
        print('API Error: Status code ${response.statusCode}');
        print('Response body: ${response.body}');
        return [];
      }

      final dynamic decoded = jsonDecode(response.body);
      
      // Debug: In ra để kiểm tra
      print('API Response type: ${decoded.runtimeType}');
      
      List<dynamic> tasksList = [];
      
      // Nếu response là array trực tiếp
      if (decoded is List) {
        tasksList = decoded;
        print('Tasks count (direct array): ${tasksList.length}');
      }
      // Nếu response là Map (object), tìm array bên trong
      else if (decoded is Map<String, dynamic>) {
        print('Response is a Map. Keys: ${decoded.keys}');
        
        // Thử các key phổ biến
        if (decoded.containsKey('tasks')) {
          tasksList = decoded['tasks'] as List<dynamic>? ?? [];
        } else if (decoded.containsKey('data')) {
          tasksList = decoded['data'] as List<dynamic>? ?? [];
        } else if (decoded.containsKey('items')) {
          tasksList = decoded['items'] as List<dynamic>? ?? [];
        } else {
          // Nếu không có key nào, in ra để debug
          print('Map structure: $decoded');
          // Thử tìm key đầu tiên là List
          for (var key in decoded.keys) {
            if (decoded[key] is List) {
              tasksList = decoded[key] as List<dynamic>;
              print('Found list at key: $key, count: ${tasksList.length}');
              break;
            }
          }
        }
      }
      
      if (tasksList.isEmpty) {
        print('No tasks found in response');
        return [];
      }
      
      try {
        final tasks = tasksList.map((e) {
          try {
            return Task.fromJson(e as Map<String, dynamic>);
          } catch (e2) {
            print('Error parsing task: $e2');
            print('Task data: $e');
            rethrow;
          }
        }).toList();
        
        print('Successfully parsed ${tasks.length} tasks');
        return tasks;
      } catch (e) {
        print('Error mapping tasks: $e');
        return [];
      }
    } catch (e) {
      print('Exception in getTasks: $e');
      return [];
    }
  }

  // GET TASK DETAIL
  static Future<Task?> getTaskDetail(int id) async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/task/$id"));

      if (response.statusCode != 200) {
        print('API Detail Error: Status code ${response.statusCode}');
        print('Response body: ${response.body}');
        return null;
      }

      final dynamic decoded = jsonDecode(response.body);
      
      // API trả về structure: { "isSuccess": true, "message": "...", "data": {...} }
      Map<String, dynamic>? taskData;
      
      if (decoded is Map<String, dynamic>) {
        // Nếu có key "data", lấy data từ đó
        if (decoded.containsKey('data')) {
          taskData = decoded['data'] as Map<String, dynamic>?;
          print('Found task data in response.data');
        } else {
          // Nếu không có "data", thử parse trực tiếp
          taskData = decoded;
          print('Parsing task data directly from response');
        }
      }
      
      if (taskData == null) {
        print('Task data is null');
        return null;
      }
      
      try {
        final task = Task.fromJson(taskData);
        print('Successfully parsed task: ${task.title}');
        return task;
      } catch (e) {
        print('Error parsing task detail: $e');
        print('Task data: $taskData');
        return null;
      }
    } catch (e) {
      print('Exception in getTaskDetail: $e');
      return null;
    }
  }

  // DELETE TASK
  static Future<bool> deleteTask(int id) async {
    try {
      final response = await http.delete(Uri.parse("$baseUrl/task/$id"));
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      return false;
    }
  }
}
