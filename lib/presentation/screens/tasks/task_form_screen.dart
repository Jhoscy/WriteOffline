import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../domain/entities/task.dart';
import '../../providers/task_providers.dart';
import '../../theme/app_theme.dart';

class TaskFormScreen extends ConsumerStatefulWidget {
  final String projectId;
  final Task? task;

  const TaskFormScreen({
    super.key,
    required this.projectId,
    this.task,
  });

  @override
  ConsumerState<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends ConsumerState<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  DateTime? _dueDate;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.task?.name ?? '');
    _descriptionController = TextEditingController(text: widget.task?.description ?? '');
    _dueDate = widget.task?.dueDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.task != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Task' : 'New Task'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
          children: [
            // Text(
            //   isEditing ? 'Edit Task' : 'Create New Task',
            //   style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            //     fontWeight: FontWeight.w600,
            //     letterSpacing: -0.6,
            //   ),
            // ),
            const SizedBox(height: 32),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Task Name *',
                hintText: 'Enter task name',
              ),
              style: Theme.of(context).textTheme.bodyLarge,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a task name';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description *',
                hintText: 'Enter task description',
                alignLabelWithHint: true,
              ),
              maxLines: 6,
              style: Theme.of(context).textTheme.bodyLarge,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                color: context.surfaceColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: context.greyColor(300)),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                title: Text(
                  'Due Date',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: context.onSurfaceColor,
                  ),
                ),
              subtitle: Text(
                _dueDate != null 
                    ? DateFormat('MMM dd, yyyy').format(_dueDate!) 
                    : 'Not set',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: _dueDate != null 
                        ? context.greyColor(700) 
                        : context.greyColor(400),
                  ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_dueDate != null)
                    IconButton(
                        icon: Icon(
                          Icons.clear,
                          size: 18,
                          color: context.greyColor(600),
                        ),
                      onPressed: () {
                        setState(() {
                          _dueDate = null;
                        });
                      },
                    ),
                    Icon(
                      Icons.calendar_today,
                      size: 20,
                      color: context.greyColor(600),
                    ),
                ],
              ),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _dueDate ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (date != null) {
                  setState(() {
                    _dueDate = date;
                  });
                }
              },
            ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _saveTask,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
              ),
              child: Text(
                isEditing ? 'Update Task' : 'Create Task',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();

    if (widget.task != null) {
      // Update existing task
      final updatedTask = widget.task!.copyWith(
        name: name,
        description: description,
        dueDate: _dueDate,
      );
      
      await ref.read(taskNotifierProvider.notifier).updateTask(updatedTask);
    } else {
      // Create new task
      await ref.read(taskNotifierProvider.notifier).createTask(
        name: name,
        description: description,
        dueDate: _dueDate,
        projectId: widget.projectId,
      );
    }

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.task != null 
                ? 'Task updated successfully' 
                : 'Task created successfully',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

