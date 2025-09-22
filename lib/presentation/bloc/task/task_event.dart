import 'package:equatable/equatable.dart';
import '../../../domain/entities/task.dart';
import '../../../core/constants/app_constants.dart';

abstract class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object> get props => [];
}

class LoadTasks extends TaskEvent {}

class AddTaskEvent extends TaskEvent {
  final Task task;

  const AddTaskEvent(this.task);

  @override
  List<Object> get props => [task];
}

class UpdateTaskEvent extends TaskEvent {
  final Task task;

  const UpdateTaskEvent(this.task);

  @override
  List<Object> get props => [task];
}

class DeleteTaskEvent extends TaskEvent {
  final String taskId;

  const DeleteTaskEvent(this.taskId);

  @override
  List<Object> get props => [taskId];
}

class FilterTasks extends TaskEvent {
  final TaskFilter filter;

  const FilterTasks(this.filter);

  @override
  List<Object> get props => [filter];
}

class ReorderTasks extends TaskEvent {
  final int oldIndex;
  final int newIndex;

  const ReorderTasks(this.oldIndex, this.newIndex);

  @override
  List<Object> get props => [oldIndex, newIndex];
}