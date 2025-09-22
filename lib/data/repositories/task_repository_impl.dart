import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/local_task_datasource.dart';
import '../models/task_model.dart';
import '../../core/constants/app_constants.dart';

class TaskRepositoryImpl implements TaskRepository {
  final LocalTaskDatasource datasource;

  TaskRepositoryImpl(this.datasource);

  @override
  Future<List<Task>> getTasks() async {
    final taskModels = await datasource.getTasks();
    return taskModels.map((model) => model.toEntity()).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<void> addTask(Task task) async {
    await datasource.addTask(TaskModel.fromEntity(task));
  }

  @override
  Future<void> updateTask(Task task) async {
    await datasource.updateTask(TaskModel.fromEntity(task));
  }

  @override
  Future<void> deleteTask(String id) async {
    await datasource.deleteTask(id);
  }

  @override
  Future<List<Task>> getTasksByStatus(TaskStatus status) async {
    final tasks = await getTasks();
    return tasks.where((task) => task.status == status).toList();
  }
}