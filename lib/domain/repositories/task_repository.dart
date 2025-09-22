import '../entities/task.dart';
import '../../core/constants/app_constants.dart';

abstract class TaskRepository {
  Future<List<Task>> getTasks();
  Future<void> addTask(Task task);
  Future<void> updateTask(Task task);
  Future<void> deleteTask(String id);
  Future<List<Task>> getTasksByStatus(TaskStatus status);
}