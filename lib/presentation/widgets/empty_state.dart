import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

class EmptyState extends StatelessWidget {
  final TaskFilter filter;

  const EmptyState({
    super.key,
    required this.filter,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getIcon(),
            size: 80,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            _getTitle(),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            _getSubtitle(),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  IconData _getIcon() {
    switch (filter) {
      case TaskFilter.all:
        return Icons.task_alt_outlined;
      case TaskFilter.toDo:
        return Icons.radio_button_unchecked;
      case TaskFilter.inProgress:
        return Icons.hourglass_empty;
      case TaskFilter.done:
        return Icons.check_circle_outline;
    }
  }

  String _getTitle() {
    switch (filter) {
      case TaskFilter.all:
        return 'No Tasks Yet';
      case TaskFilter.toDo:
        return 'No To Do Tasks';
      case TaskFilter.inProgress:
        return 'No Tasks In Progress';
      case TaskFilter.done:
        return 'No Completed Tasks';
    }
  }

  String _getSubtitle() {
    switch (filter) {
      case TaskFilter.all:
        return 'Start by creating your first task';
      case TaskFilter.toDo:
        return 'All tasks are either in progress or completed';
      case TaskFilter.inProgress:
        return 'No tasks are currently being worked on';
      case TaskFilter.done:
        return 'Complete some tasks to see them here';
    }
  }
}