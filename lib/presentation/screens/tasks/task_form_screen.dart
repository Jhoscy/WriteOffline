import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../domain/entities/task.dart';
import '../../providers/task_providers.dart';
import '../../widgets/glassmorphism_utils.dart';

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

    return GlassmorphismUtils.gradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(isEditing ? 'Edit Task' : 'New Task'),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: GlassmorphismUtils.glassContainer(
              blurStrength: 12.0,
              opacity: 0.08,
              borderRadius: BorderRadius.circular(20),
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Form title
                    Text(
                      isEditing ? 'Edit Task Details' : 'Create New Task',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // Task Name Field
                    TextFormField(
                      controller: _nameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Task Name *',
                        labelStyle: TextStyle(color: Colors.white.withOpacity(0.8)),
                        hintText: 'Enter task name',
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                        prefixIcon: Icon(
                          Icons.task,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a task name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Description Field
                    TextFormField(
                      controller: _descriptionController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Description *',
                        labelStyle: TextStyle(color: Colors.white.withOpacity(0.8)),
                        hintText: 'Describe your task',
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                        prefixIcon: Icon(
                          Icons.description,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                      maxLines: 4,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Due Date Picker
                    GlassmorphismUtils.glassContainer(
                      blurStrength: 8.0,
                      opacity: 0.05,
                      borderRadius: BorderRadius.circular(12),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Due Date',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _dueDate != null
                                      ? DateFormat('MMM dd, yyyy').format(_dueDate!)
                                      : 'Not set',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              if (_dueDate != null)
                                IconButton(
                                  icon: Icon(
                                    Icons.clear,
                                    color: Colors.white.withOpacity(0.7),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _dueDate = null;
                                    });
                                  },
                                ),
                              IconButton(
                                icon: Icon(
                                  Icons.calendar_today,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                                onPressed: () async {
                                  final date = await showDatePicker(
                                    context: context,
                                    initialDate: _dueDate ?? DateTime.now(),
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2100),
                                    builder: (context, child) {
                                      return GlassmorphismUtils.glassContainer(
                                        blurStrength: 15.0,
                                        opacity: 0.1,
                                        borderRadius: BorderRadius.circular(16),
                                        margin: const EdgeInsets.all(16),
                                        child: Theme(
                                          data: Theme.of(context).copyWith(
                                            colorScheme: const ColorScheme.dark(
                                              primary: Color(0xFF6366F1),
                                              surface: Color(0xFF1E293B),
                                            ),
                                          ),
                                          child: child!,
                                        ),
                                      );
                                    },
                                  );
                                  if (date != null) {
                                    setState(() {
                                      _dueDate = date;
                                    });
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Save Button
                    GlassmorphismUtils.glassButton(
                      blurStrength: 12.0,
                      opacity: 0.1,
                      borderRadius: BorderRadius.circular(16),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      onPressed: _saveTask,
                      child: Text(
                        isEditing ? 'Update Task' : 'Create Task',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
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
          backgroundColor: Colors.transparent,
          elevation: 0,
          content: GlassmorphismUtils.glassContainer(
            blurStrength: 10.0,
            opacity: 0.15,
            borderRadius: BorderRadius.circular(8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              widget.task != null
                  ? 'Task updated successfully'
                  : 'Task created successfully',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      );
    }
  }
}

