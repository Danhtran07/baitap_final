class Task {
  final int id;
  final String title;
  final String description;
  final String status;
  final String? category;
  final String? priority;
  final String? date;
  final String? dueDate;
  final bool? isCompleted;
  final List<Subtask>? subtasks;
  final List<Attachment>? attachments;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    this.category,
    this.priority,
    this.date,
    this.dueDate,
    this.isCompleted,
    this.subtasks,
    this.attachments,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    // Format date từ ISO string sang readable format
    String? formatDate(String? isoDate) {
      if (isoDate == null) return null;
      try {
        final dateTime = DateTime.parse(isoDate);
        // Format: "14:00 2024-03-26"
        final hours = dateTime.hour.toString().padLeft(2, '0');
        final minutes = dateTime.minute.toString().padLeft(2, '0');
        final year = dateTime.year;
        final month = dateTime.month.toString().padLeft(2, '0');
        final day = dateTime.day.toString().padLeft(2, '0');
        return '$hours:$minutes $year-$month-$day';
      } catch (e) {
        return isoDate;
      }
    }

    return Task(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? 'Pending',
      category: json['category'],
      priority: json['priority'],
      date: json['date'] ?? formatDate(json['dueDate']),
      dueDate: json['dueDate'],
      isCompleted: json['isCompleted'] ?? false,
      subtasks: json['subtasks'] != null
          ? (json['subtasks'] as List)
              .map((e) => Subtask.fromJson(e))
              .toList()
          : null,
      attachments: json['attachments'] != null
          ? (json['attachments'] as List)
              .map((e) => Attachment.fromJson(e))
              .toList()
          : null,
    );
  }
}

class Subtask {
  final int id;
  final String title;
  final bool isCompleted;

  Subtask({
    required this.id,
    required this.title,
    required this.isCompleted,
  });

  factory Subtask.fromJson(Map<String, dynamic> json) {
    return Subtask(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      isCompleted: json['isCompleted'] ?? false,
    );
  }
}

class Attachment {
  final int id;
  final String name;
  final String? url;

  Attachment({
    required this.id,
    required this.name,
    this.url,
  });

  factory Attachment.fromJson(Map<String, dynamic> json) {
    return Attachment(
      id: json['id'] ?? 0,
      // API trả về fileName, nhưng fallback về name nếu không có
      name: json['fileName'] ?? json['name'] ?? '',
      url: json['fileUrl'] ?? json['url'],
    );
  }
}
