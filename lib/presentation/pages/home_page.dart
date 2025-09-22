// lib/presentation/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/task.dart';
import '../../core/constants/app_constants.dart';
import '../bloc/task/task_bloc.dart';
import '../bloc/task/task_event.dart';
import '../bloc/task/task_state.dart';
import '../bloc/theme/theme_bloc.dart';
import '../bloc/theme/theme_event.dart';
import '../bloc/theme/theme_state.dart';
import '../widgets/task_item.dart';
import '../widgets/filter_tabs.dart';
import '../widgets/empty_state.dart';
import 'add_edit_task_page.dart';

class HomePage extends StatefulWidget {
  final TaskFilter? initialFilter; // NEW

  const HomePage({super.key, this.initialFilter});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _fabAnimationController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // context.read<TaskBloc>().add(LoadTasks());

    // If an initial filter is provided, apply it after the LoadTasks is dispatched.
    if (widget.initialFilter != null) {
      // Wait a microtask so that the bloc has a chance to start loading.
      Future.microtask(() => context.read<TaskBloc>().add(FilterTasks(widget.initialFilter!)));
    }

    _fabAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      lowerBound: 0.9,
      upperBound: 1.0,
    )..value = 1.0;

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocListener<TaskBloc, TaskState>(
      listener: (context, state) {
        if (state is TaskError) {
          _showSnackBar(context, state.message, Colors.red);
        }
      },
      child: Scaffold(
        // small gradient header to mimic design
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(68),
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xFF6A11CB), Color(0xFF2575FC)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0,3))],
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.list_alt, color: Colors.white),
                    ),
                    const SizedBox(width: 10),
                    Text('Task List', style: theme.textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                    const Spacer(),
                    IconButton(onPressed: () => context.read<TaskBloc>().add(LoadTasks()), icon: const Icon(Icons.refresh, color: Colors.white)),
                    BlocBuilder<ThemeBloc, ThemeState>(
                      builder: (context, state) {
                        final isDark = state is ThemeLoaded ? state.isDarkMode : false;
                        return IconButton(
                          onPressed: () => context.read<ThemeBloc>().add(ToggleThemeEvent()),
                          icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode, color: Colors.white),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        body: RefreshIndicator(
          onRefresh: () async {
            context.read<TaskBloc>().add(LoadTasks());
            await Future.delayed(const Duration(milliseconds: 250));
          },
          child: Column(
            children: [
              // search bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Material(
                  elevation: 2,
                  borderRadius: BorderRadius.circular(12),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: 'Search tasks',
                      suffixIcon: _searchQuery.isNotEmpty ? IconButton(icon: const Icon(Icons.clear), onPressed: () => _searchController.clear()) : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ),

              // tasks & filters
              Expanded(
                child: BlocBuilder<TaskBloc, TaskState>(
                  builder: (context, state) {
                    if (state is TaskLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state is TaskLoaded) {
                      final visible = state.filteredTasks.where((t) {
                        if (_searchQuery.isEmpty) return true;
                        final q = _searchQuery.toLowerCase();
                        return t.title.toLowerCase().contains(q) || t.description.toLowerCase().contains(q);
                      }).toList();

                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            child: FilterTabs(
                              currentFilter: state.currentFilter,
                              onFilterChanged: (f) => context.read<TaskBloc>().add(FilterTasks(f)),
                              taskCounts: {
                                TaskFilter.all: state.tasks.length,
                                TaskFilter.toDo: state.tasks.where((t) => t.status == TaskStatus.toDo).length,
                                TaskFilter.inProgress: state.tasks.where((t) => t.status == TaskStatus.inProgress).length,
                                TaskFilter.done: state.tasks.where((t) => t.status == TaskStatus.done).length,
                              },
                            ),
                          ),

                          const SizedBox(height: 4),

                          Expanded(
                            child: visible.isEmpty
                                ? EmptyState(filter: state.currentFilter)
                                : ReorderableListView.builder(
                              padding: const EdgeInsets.only(bottom: 96, left: 12, right: 12, top: 6),
                              itemCount: visible.length,
                              onReorder: (oldIndex, newIndex) {
                                context.read<TaskBloc>().add(ReorderTasks(oldIndex, newIndex));
                              },
                              itemBuilder: (context, index) {
                                final task = visible[index];
                                return Container(
                                  key: ValueKey(task.id),
                                  margin: const EdgeInsets.symmetric(vertical: 6),
                                  child: TaskItem(
                                    task: task,
                                    isDark: Theme.of(context).brightness == Brightness.dark,
                                    onStatusChanged: (updated) => context.read<TaskBloc>().add(UpdateTaskEvent(updated)),
                                    onEdit: (t) => _openEdit(t),
                                    onDelete: (id) {
                                      context.read<TaskBloc>().add(DeleteTaskEvent(id));
                                      _showSnack(context, 'Task deleted', Colors.green);
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    }

                    return const Center(child: Text('Something went wrong'));
                  },
                ),
              ),
            ],
          ),
        ),

        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: ScaleTransition(
          scale: Tween<double>(begin: 1.0, end: 1.0).animate(_fabAnimationController),
          child: GestureDetector(
            onTapDown: (_) => _fabAnimationController.reverse(),
            onTapUp: (_) => _fabAnimationController.forward(),
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFCD7BFF), Color(0xFF6A11CB)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 12, offset: const Offset(0, 6))],
              ),
              child: FloatingActionButton.extended(
                onPressed: () => _openAdd(),
                icon: const Icon(Icons.add),
                label: const Text('Add Task'),
                backgroundColor: Colors.transparent,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openAdd() async {
    final result = await Navigator.of(context).push<Task>(MaterialPageRoute(builder: (_) => const AddEditTaskPage()));
    if (result != null) {
      context.read<TaskBloc>().add(AddTaskEvent(result));
      _showSnack(context, 'Task created', Colors.green);
    }
  }

  Future<void> _openEdit(Task task) async {
    final result = await Navigator.of(context).push<Task>(MaterialPageRoute(builder: (_) => AddEditTaskPage(task: task)));
    if (result != null) {
      context.read<TaskBloc>().add(UpdateTaskEvent(result));
      _showSnack(context, 'Task updated', Colors.green);
    }
  }

  void _showSnack(BuildContext ctx, String message, Color color) {
    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ));
  }

  void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }
}
