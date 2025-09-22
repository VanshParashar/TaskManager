import 'package:hive_flutter/hive_flutter.dart';
import '../models/task_model.dart';
import '../../core/constants/app_constants.dart';

class LocalTaskDatasource {
  Future<Box<TaskModel>> get _box async =>
      await Hive.openBox<TaskModel>(AppConstants.tasksBoxName);

  Future<List<TaskModel>> getTasks() async {
    final box = await _box;
    return box.values.toList();
  }

  Future<void> addTask(TaskModel task) async {
    final box = await _box;
    await box.put(task.id, task);
  }

  Future<void> updateTask(TaskModel task) async {
    final box = await _box;
    await box.put(task.id, task);
  }

  Future<void> deleteTask(String id) async {
    final box = await _box;
    await box.delete(id);
  }

  Future<void> addDummyData() async {
    final box = await _box;
    if (box.isEmpty) {
      final now = DateTime.now();
      final dummyTasks = [
        TaskModel(
          id: '1',
          title: 'Complete Flutter Project',
          description: 'Build the task manager app with BLoC and clean architecture',
          status: 'in_progress',
          dueDate: now.add(const Duration(days: 2)),
          createdAt: now.subtract(const Duration(days: 1)),
          updatedAt: now,
        ),
        TaskModel(
          id: '2',
          title: 'Write Unit Tests',
          description: 'Add comprehensive unit tests for all business logic',
          status: 'to_do',
          dueDate: now.add(const Duration(days: 3)),
          createdAt: now.subtract(const Duration(hours: 12)),
          updatedAt: now,
        ),
        TaskModel(
          id: '3',
          title: 'Update Documentation',
          description: 'Create README with architecture explanation',
          status: 'done',
          dueDate: now.subtract(const Duration(days: 1)),
          createdAt: now.subtract(const Duration(days: 2)),
          updatedAt: now.subtract(const Duration(hours: 6)),
        ),
        TaskModel(
          id: '4',
          title: 'Code Review',
          description: 'Review code for best practices and optimization',
          status: 'to_do',
          dueDate: now.add(const Duration(days: 1)),
          createdAt: now.subtract(const Duration(hours: 8)),
          updatedAt: now,
        ),
      ];

      for (final task in dummyTasks) {
        await box.put(task.id, task);
      }
    }
  }
}