import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/entities/task.dart';
import '../../core/utils/date_utils.dart';
import '../../core/themes/app_theme.dart';
import 'status_chip.dart';

class TaskItem extends StatefulWidget {
  final Task task;
  final Function(Task) onStatusChanged;
  final Function(Task) onEdit;
  final Function(String) onDelete;
  final bool isDark;

  const TaskItem({
    super.key,
    required this.task,
    required this.onStatusChanged,
    required this.onEdit,
    required this.onDelete,
    required this.isDark,
  });

  @override
  State<TaskItem> createState() => _TaskItemState();
}

class _TaskItemState extends State<TaskItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isOverdue = AppDateUtils.isOverdue(widget.task.dueDate) &&
        widget.task.status != TaskStatus.done;

    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Dismissible(
          key: Key(widget.task.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.delete,
              color: Colors.white,
              size: 24,
            ),
          ),
          confirmDismiss: (direction) async {
            return await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Delete Task'),
                content: const Text('Are you sure you want to delete this task?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                    child: const Text('Delete'),
                  ),
                ],
              ),
            );
          },
          onDismissed: (direction) {
            widget.onDelete(widget.task.id);
          },
          child: Card(
            elevation: 2,
            child: InkWell(
              onTap: () => widget.onEdit(widget.task),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: isOverdue
                      ? Border.all(color: Colors.red.withOpacity(0.3), width: 1)
                      : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.task.title,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              decoration: widget.task.status == TaskStatus.done
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                        ),
                        StatusChip(
                          status: widget.task.status,
                          isDark: widget.isDark,
                          onStatusChanged: (status) {
                            final updatedTask = widget.task.copyWith(status: status);
                            widget.onStatusChanged(updatedTask);
                          },
                        ),
                      ],
                    ),
                    if (widget.task.description.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        widget.task.description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          decoration: widget.task.status == TaskStatus.done
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          isOverdue ? Icons.warning : Icons.schedule,
                          size: 16,
                          color: isOverdue
                              ? Colors.red
                              : Theme.of(context).colorScheme.outline,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          AppDateUtils.formatDate(widget.task.dueDate),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isOverdue
                                ? Colors.red
                                : Theme.of(context).colorScheme.outline,
                            fontWeight: isOverdue ? FontWeight.w600 : null,
                          ),
                        ),
                        if (isOverdue) ...[
                          const SizedBox(width: 8),
                          Text(
                            'Overdue',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                        const Spacer(),
                        Icon(
                          Icons.drag_handle,
                          size: 20,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}