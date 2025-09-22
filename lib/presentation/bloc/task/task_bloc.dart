import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/task.dart';
import '../../../domain/usecases/get_tasks.dart';
import '../../../domain/usecases/add_task.dart';
import '../../../domain/usecases/update_task.dart';
import '../../../domain/usecases/delete_task.dart';
import '../../../core/constants/app_constants.dart';
import 'task_event.dart';
import 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final GetTasks getTasks;
  final AddTask addTask;
  final UpdateTask updateTask;
  final DeleteTask deleteTask;

  TaskBloc({
    required this.getTasks,
    required this.addTask,
    required this.updateTask,
    required this.deleteTask,
  }) : super(TaskInitial()) {
    on<LoadTasks>(_onLoadTasks);
    on<AddTaskEvent>(_onAddTask);
    on<UpdateTaskEvent>(_onUpdateTask);
    on<DeleteTaskEvent>(_onDeleteTask);
    on<FilterTasks>(_onFilterTasks);
    on<ReorderTasks>(_onReorderTasks);
  }

  Future<void> _onLoadTasks(LoadTasks event, Emitter<TaskState> emit) async {
    try {
      emit(TaskLoading());
      final tasks = await getTasks();
      emit(TaskLoaded(
        tasks: tasks,
        filteredTasks: tasks,
        currentFilter: TaskFilter.all,
      ));
    } catch (e) {
      emit(TaskError('Failed to load tasks: ${e.toString()}'));
    }
  }

  Future<void> _onAddTask(AddTaskEvent event, Emitter<TaskState> emit) async {
    if (state is TaskLoaded) {
      try {
        await addTask(event.task);
        final tasks = await getTasks();
        final currentState = state as TaskLoaded;
        final filteredTasks = _filterTasks(tasks, currentState.currentFilter);
        emit(currentState.copyWith(
          tasks: tasks,
          filteredTasks: filteredTasks,
        ));
      } catch (e) {
        emit(TaskError('Failed to add task: ${e.toString()}'));
      }
    }
  }

  Future<void> _onUpdateTask(UpdateTaskEvent event, Emitter<TaskState> emit) async {
    if (state is TaskLoaded) {
      try {
        await updateTask(event.task);
        final tasks = await getTasks();
        final currentState = state as TaskLoaded;
        final filteredTasks = _filterTasks(tasks, currentState.currentFilter);
        emit(currentState.copyWith(
          tasks: tasks,
          filteredTasks: filteredTasks,
        ));
      } catch (e) {
        emit(TaskError('Failed to update task: ${e.toString()}'));
      }
    }
  }

  Future<void> _onDeleteTask(DeleteTaskEvent event, Emitter<TaskState> emit) async {
    if (state is TaskLoaded) {
      try {
        await deleteTask(event.taskId);
        final tasks = await getTasks();
        final currentState = state as TaskLoaded;
        final filteredTasks = _filterTasks(tasks, currentState.currentFilter);
        emit(currentState.copyWith(
          tasks: tasks,
          filteredTasks: filteredTasks,
        ));
      } catch (e) {
        emit(TaskError('Failed to delete task: ${e.toString()}'));
      }
    }
  }

  void _onFilterTasks(FilterTasks event, Emitter<TaskState> emit) {
    if (state is TaskLoaded) {
      final currentState = state as TaskLoaded;
      final filteredTasks = _filterTasks(currentState.tasks, event.filter);
      emit(currentState.copyWith(
        filteredTasks: filteredTasks,
        currentFilter: event.filter,
      ));
    }
  }

  void _onReorderTasks(ReorderTasks event, Emitter<TaskState> emit) {
    if (state is TaskLoaded) {
      final currentState = state as TaskLoaded;
      final tasks = List.of(currentState.filteredTasks);
      final task = tasks.removeAt(event.oldIndex);
      tasks.insert(event.newIndex, task);

      emit(currentState.copyWith(filteredTasks: tasks));
    }
  }

  List<Task> _filterTasks(List<Task> tasks, TaskFilter filter) {
    switch (filter) {
      case TaskFilter.all:
        return tasks;
      case TaskFilter.toDo:
        return tasks.where((task) => task.status == TaskStatus.toDo).toList();
      case TaskFilter.inProgress:
        return tasks.where((task) => task.status == TaskStatus.inProgress).toList();
      case TaskFilter.done:
        return tasks.where((task) => task.status == TaskStatus.done).toList();
    }
  }
}