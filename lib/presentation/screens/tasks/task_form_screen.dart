import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../domain/entities/task.dart';
import '../../providers/task_providers.dart';
import '../../theme/neobrutalism_theme.dart';

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
        title: Text(isEditing ? 'Edit Task' : 'New Task', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Task Name *',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a task name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description *',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Container(
              decoration: NeobrutalismTheme.neobrutalismBox(
                color: NeobrutalismTheme.primaryWhite,
              ),
              child: ListTile(
                title: const Text('Due Date', style: TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Text(
                  _dueDate != null 
                      ? DateFormat('MMM dd, yyyy').format(_dueDate!) 
                      : 'Not set',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_dueDate != null)
                      IconButton(
                        icon: const Icon(Icons.clear, color: NeobrutalismTheme.primaryBlack),
                        onPressed: () {
                          setState(() {
                            _dueDate = null;
                          });
                        },
                      ),
                    const Icon(Icons.calendar_today, color: NeobrutalismTheme.primaryBlack),
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
            const SizedBox(height: 24),
            Container(
              decoration: NeobrutalismTheme.neobrutalismBox(
                color: NeobrutalismTheme.primaryRed,
                shadow: NeobrutalismTheme.buttonShadow,
              ),
              child: ElevatedButton(
                onPressed: _saveTask,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(NeobrutalismTheme.borderRadiusSmall),
                    side: const BorderSide(
                      color: NeobrutalismTheme.primaryBlack,
                      width: NeobrutalismTheme.borderWidth,
                    ),
                  ),
                ),
                child: Text(
                  isEditing ? 'Update Task' : 'Create Task',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: NeobrutalismTheme.primaryWhite,
                    letterSpacing: 1,
                  ),
                ),
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
        ),
      );
    }
  }
}

