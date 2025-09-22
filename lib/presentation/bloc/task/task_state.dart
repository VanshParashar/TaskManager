import 'package:equatable/equatable.dart';
import '../../../domain/entities/task.dart';
import '../../../core/constants/app_constants.dart';

abstract class TaskState extends Equatable {
  const TaskState();

  @override
  List<Object> get props => [];
}

class TaskInitial extends TaskState {}

class TaskLoading extends TaskState {}

class TaskLoaded extends TaskState {
  final List<Task> tasks;
  final List<Task> filteredTasks;
  final TaskFilter currentFilter;

  const TaskLoaded({
    required this.tasks,
    required this.filteredTasks,
    required this.currentFilter,
  });

  TaskLoaded copyWith({
    List<Task>? tasks,
    List<Task>? filteredTasks,
    TaskFilter? currentFilter,
  }) {
    return TaskLoaded(
      tasks: tasks ?? this.tasks,
      filteredTasks: filteredTasks ?? this.filteredTasks,
      currentFilter: currentFilter ?? this.currentFilter,
    );
  }

  @override
  List<Object> get props => [tasks, filteredTasks, currentFilter];
}

class TaskError extends TaskState {
  final String message;

  const TaskError(this.message);

  @override
  List<Object> get props => [message];
}