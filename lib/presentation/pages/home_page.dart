import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/task/task_bloc.dart';
import '../bloc/task/task_event.dart';
import '../bloc/task/task_state.dart';
import '../bloc/theme/theme_bloc.dart';
import '../bloc/theme/theme_event.dart';
import '../bloc/theme/theme_state.dart';
import '../widgets/task_item.dart';
import '../widgets/filter_tabs.dart';
import '../widgets/empty_state.dart';
import '../../domain/entities/task.dart';
import '../../core/constants/app_constants.dart';
import 'add_edit_task_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    context.read<TaskBloc>().add(LoadTasks());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TaskBloc, TaskState>(
      listener: (context, state) {
        if (state is TaskError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            AppConstants.appName,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: [
            BlocBuilder<ThemeBloc, ThemeState>(
              builder: (context, state) {
                final isDark = state is ThemeLoaded ? state.isDarkMode : false;
                return IconButton(
                  onPressed: () {
                    context.read<ThemeBloc>().add(ToggleThemeEvent());
                  },
                  icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
                  tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
                );
              },
            ),
          ],
        ),
        body: BlocBuilder<TaskBloc, TaskState>(
          builder: (context, state) {
            if (state is TaskLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (state is TaskLoaded) {
              return Column(
                children: [
                  FilterTabs(
                    currentFilter: state.currentFilter,
                    onFilterChanged: (filter) {
                      context.read<TaskBloc>().add(FilterTasks(filter));
                    },
                    taskCounts: _getTaskCounts(state.tasks),
                  ),
                  Expanded(
                    child: state.filteredTasks.isEmpty
                        ? EmptyState(filter: state.currentFilter)
                        : BlocBuilder<ThemeBloc, ThemeState>(
                      builder: (context, themeState) {
                        final isDark = themeState is ThemeLoaded
                            ? themeState.isDarkMode
                            : false;

                        return ReorderableListView.builder(
                          padding: const EdgeInsets.only(bottom: 80),
                          itemCount: state.filteredTasks.length,
                          onReorder: (oldIndex, newIndex) {
                            context.read<TaskBloc>().add(
                              ReorderTasks(oldIndex, newIndex),
                            );
                          },
                          itemBuilder: (context, index) {
                            final task = state.filteredTasks[index];
                            return TaskItem(
                              key: ValueKey(task.id),
                              task: task,
                              isDark: isDark,
                              onStatusChanged: (updatedTask) {
                                context
                                    .read<TaskBloc>()
                                    .add(UpdateTaskEvent(updatedTask));
                              },
                              onEdit: (task) => _editTask(context, task),
                              onDelete: (taskId) {
                                context
                                    .read<TaskBloc>()
                                    .add(DeleteTaskEvent(taskId));
                                _showSnackBar(
                                  context,
                                  'Task deleted successfully',
                                  Colors.green,
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              );
            }

            return const Center(
              child: Text('Something went wrong'),
            );
          },
        ),
        floatingActionButton: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6A11CB), Color(0xFF2575FC)], // purple to blue
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 12,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: FloatingActionButton.extended(
            onPressed: () => _addTask(context),
            icon: const Icon(Icons.add,size: 26),
            label: const Text(
              "Add Task",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                letterSpacing: 1.2,
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
        ),

      ),
    );
  }

  Map<TaskFilter, int> _getTaskCounts(List<Task> tasks) {
    return {
      TaskFilter.all: tasks.length,
      TaskFilter.toDo: tasks.where((t) => t.status == TaskStatus.toDo).length,
      TaskFilter.inProgress:
      tasks.where((t) => t.status == TaskStatus.inProgress).length,
      TaskFilter.done: tasks.where((t) => t.status == TaskStatus.done).length,
    };
  }

  Future<void> _addTask(BuildContext context) async {
    final result = await Navigator.of(context).push<Task>(
      MaterialPageRoute(
        builder: (context) => const AddEditTaskPage(),
      ),
    );

    if (result != null) {
      context.read<TaskBloc>().add(AddTaskEvent(result));
      _showSnackBar(context, 'Task created successfully', Colors.green);
    }
  }

  Future<void> _editTask(BuildContext context, Task task) async {
    final result = await Navigator.of(context).push<Task>(
      MaterialPageRoute(
        builder: (context) => AddEditTaskPage(task: task),
      ),
    );

    if (result != null) {
      context.read<TaskBloc>().add(UpdateTaskEvent(result));
      _showSnackBar(context, 'Task updated successfully', Colors.green);
    }
  }

  void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}