class AppConstants {
  static const String appName = 'Task Manager';
  static const String tasksBoxName = 'tasks_box';
  static const String themeBoxName = 'theme_box';
  static const String isDarkModeKey = 'is_dark_mode';
}

enum TaskStatus { toDo, inProgress, done }

extension TaskStatusExtension on TaskStatus {
  String get displayName {
    switch (this) {
      case TaskStatus.toDo:
        return 'To Do';
      case TaskStatus.inProgress:
        return 'In Progress';
      case TaskStatus.done:
        return 'Done';
    }
  }

  String get value {
    switch (this) {
      case TaskStatus.toDo:
        return 'to_do';
      case TaskStatus.inProgress:
        return 'in_progress';
      case TaskStatus.done:
        return 'done';
    }
  }
}

enum TaskFilter { all, toDo, inProgress, done }