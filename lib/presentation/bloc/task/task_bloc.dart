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

      // Preserve previous filter if available; otherwise default to all
      final TaskFilter currentFilter =
      (state is TaskLoaded) ? (state as TaskLoaded).currentFilter : TaskFilter.all;

      final filteredTasks = _filterTasks(tasks, currentFilter);

      emit(TaskLoaded(
        tasks: tasks,
        filteredTasks: filteredTasks,
        currentFilter: currentFilter,
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

      // Work on copies
      final all = List<Task>.from(currentState.tasks);
      final visible = List<Task>.from(currentState.filteredTasks);

      var oldVisibleIndex = event.oldIndex;
      var newVisibleIndex = event.newIndex;

      // When moving down the list, ReorderableListView's newIndex is one greater
      if (oldVisibleIndex < newVisibleIndex) newVisibleIndex -= 1;

      // Clamp new index to valid range for the visible list
      if (newVisibleIndex < 0) newVisibleIndex = 0;
      if (newVisibleIndex > visible.length) newVisibleIndex = visible.length;

      // Guard: ensure old index is valid
      if (oldVisibleIndex < 0 || oldVisibleIndex >= visible.length) {
        // nothing to do
        return;
      }

      // Remove from visible and insert at new visible position
      final moved = visible.removeAt(oldVisibleIndex);
      visible.insert(newVisibleIndex, moved);

      // Now apply the same change to the full list `all`.
      final originalIndex = all.indexWhere((t) => t.id == moved.id);
      if (originalIndex == -1) {
        // fallback: if item not found in full list, just emit the updated filtered list
        emit(currentState.copyWith(filteredTasks: visible));
        return;
      }

      // Remove item from its original position in 'all'
      all.removeAt(originalIndex);

      // Determine the target index in 'all' to insert the moved item.
      int targetIndex;
      if (newVisibleIndex >= visible.length - 1) {
        // Inserting at/after last visible item: append after the last visible item in 'all'
        if (visible.isEmpty) {
          targetIndex = all.length;
        } else {
          final lastVisibleId = visible.last.id;
          final lastIdx = all.indexWhere((t) => t.id == lastVisibleId);
          targetIndex = (lastIdx == -1) ? all.length : lastIdx + 1;
        }
      } else {
        // Insert before the item now at newVisibleIndex in the visible list
        final neighborId = visible[newVisibleIndex].id;
        final neighborIdx = all.indexWhere((t) => t.id == neighborId);
        targetIndex = (neighborIdx == -1) ? all.length : neighborIdx;
      }

      // Clamp targetIndex to valid bounds for 'all'
      if (targetIndex < 0) targetIndex = 0;
      if (targetIndex > all.length) targetIndex = all.length;

      // Insert into full list
      all.insert(targetIndex, moved);

      // Emit updated state: update both tasks and filteredTasks
      emit(currentState.copyWith(tasks: all, filteredTasks: visible));
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