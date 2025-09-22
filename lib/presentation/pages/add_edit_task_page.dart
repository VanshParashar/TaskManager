import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/task.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/date_utils.dart';

class AddEditTaskPage extends StatefulWidget {
  final Task? task;

  const AddEditTaskPage({super.key, this.task});

  @override
  State<AddEditTaskPage> createState() => _AddEditTaskPageState();
}

class _AddEditTaskPageState extends State<AddEditTaskPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  TaskStatus _selectedStatus = TaskStatus.toDo;
  DateTime _selectedDueDate = DateTime.now().add(const Duration(days: 1));
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _titleController.text = widget.task!.title;
      _descriptionController.text = widget.task!.description;
      _selectedStatus = widget.task!.status;
      _selectedDueDate = widget.task!.dueDate;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Color _statusColor(TaskStatus status, ThemeData theme) {
    switch (status) {
      case TaskStatus.toDo:
        return theme.colorScheme.primary;
      case TaskStatus.inProgress:
        return Colors.orange;
      case TaskStatus.done:
        return Colors.green;
      default:
        return theme.colorScheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.task != null;
    final theme = Theme.of(context);

    return Scaffold(
      // Gradient AppBar-like area implemented with a Container for flexibility
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back_ios_new),
                    color: Colors.white,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isEditing ? 'Edit Task' : 'Add New Task',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isEditing ? 'Make changes to your task' : 'Create a new task quickly',
                          style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  // Save icon (mirrors previous Save button but more compact)
                  IconButton(
                    onPressed: _saveTask,
                    icon: const Icon(Icons.check_circle),
                    color: Colors.white,
                    iconSize: 28,
                    tooltip: 'Save',
                  ),
                ],
              ),
            ),

            // Content card
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
                child: Column(
                  children: [
                    // Card containing form
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: theme.shadowColor.withOpacity(0.04),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title
                            TextFormField(
                              controller: _titleController,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.4),
                                labelText: 'Title *',
                                hintText: 'Enter task title',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                prefixIcon: const Icon(Icons.title_outlined),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Title is required';
                                }
                                if (value.trim().length < 3) {
                                  return 'Title must be at least 3 characters';
                                }
                                return null;
                              },
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: 14),

                            // Description
                            TextFormField(
                              controller: _descriptionController,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.35),
                                labelText: 'Description',
                                hintText: 'Write a short description (optional)',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                prefixIcon: const Icon(Icons.sticky_note_2_outlined),
                              ),
                              maxLines: 4,
                              textInputAction: TextInputAction.newline,
                            ),
                            const SizedBox(height: 14),

                            // Status chips
                            Text(
                              'Status',
                              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              children: TaskStatus.values.map((status) {
                                final selected = status == _selectedStatus;
                                final color = _statusColor(status, theme);
                                return ChoiceChip(
                                  label: Text(status.displayName),
                                  selected: selected,
                                  onSelected: (_) {
                                    setState(() {
                                      _selectedStatus = status;
                                    });
                                  },
                                  selectedColor: color.withOpacity(0.15),
                                  backgroundColor: theme.colorScheme.onSurface.withOpacity(0.04),
                                  side: BorderSide(
                                    color: selected ? color : theme.colorScheme.outline,
                                  ),
                                  labelStyle: TextStyle(
                                    color: selected ? color : theme.textTheme.bodyMedium?.color,
                                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 18),

                            // Due date tile (animated to give subtle feedback)
                            GestureDetector(
                              onTap: _selectDueDate,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withOpacity(0.03),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: theme.colorScheme.outline),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.primary.withOpacity(0.12),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(Icons.calendar_month, color: theme.colorScheme.primary),
                                    ),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Due Date',
                                          style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          AppDateUtils.formatDate(_selectedDueDate),
                                          style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                                    const Spacer(),
                                    Icon(Icons.edit, size: 18, color: theme.hintColor),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Optional metadata / preview card
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: theme.colorScheme.outline),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Created', style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
                                const SizedBox(height: 6),
                                Text(
                                  widget.task != null ? AppDateUtils.formatDate(widget.task!.createdAt) : '—',
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: theme.colorScheme.outline),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Priority', style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
                                const SizedBox(height: 6),
                                // Simple derivation of priority from status for preview
                                Text(
                                  _selectedStatus == TaskStatus.done
                                      ? 'Low'
                                      : (_selectedStatus == TaskStatus.inProgress ? 'High' : 'Medium'),
                                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Primary action button (big and friendly)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _saving ? null : _saveTask,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 6,
                        ),
                        icon: _saving
                            ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)),
                        )
                            : Icon(isEditing ? Icons.save_as : Icons.add_task),
                        label: Text(
                          isEditing ? 'Update Task' : 'Create Task',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Secondary destructive / cancel
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).maybePop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        // Small theming to match page style
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(primary: const Color(0xFF6A11CB)),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDueDate = picked;
      });
    }
  }

  void _saveTask() {
    // basic debounce to show saving state for UX
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _saving = true);

      final now = DateTime.now();
      final task = Task(
        id: widget.task?.id ?? const Uuid().v4(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        status: _selectedStatus,
        dueDate: _selectedDueDate,
        createdAt: widget.task?.createdAt ?? now,
        updatedAt: now,
      );

      // Simulate a short delay to show loader; remove delay if not desired
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) {
          Navigator.of(context).pop(task);
        }
      });
    }
  }
}
