import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../domain/entities/project.dart';
import '../../providers/project_providers.dart';
import '../../widgets/glassmorphism_utils.dart';

class ProjectFormScreen extends ConsumerStatefulWidget {
  final Project? project;

  const ProjectFormScreen({super.key, this.project});

  @override
  ConsumerState<ProjectFormScreen> createState() => _ProjectFormScreenState();
}

class _ProjectFormScreenState extends ConsumerState<ProjectFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _budgetController;
  late String _selectedStatus;
  DateTime? _startDate;
  DateTime? _endDate;

  final List<String> _statusOptions = [
    'Planning',
    'Active',
    'In Progress',
    'On Hold',
    'Completed',
    'Cancelled',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.project?.projectName ?? '');
    _descriptionController = TextEditingController(text: widget.project?.description ?? '');
    _budgetController = TextEditingController(
      text: widget.project?.budget.toString() ?? '0',
    );
    _selectedStatus = widget.project?.status ?? 'Planning';
    _startDate = widget.project?.startDate;
    _endDate = widget.project?.endDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.project != null;

    return GlassmorphismUtils.gradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(isEditing ? 'Edit Project' : 'New Project'),
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
                      isEditing ? 'Edit Project Details' : 'Create New Project',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // Project Name Field
                    TextFormField(
                      controller: _nameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Project Name *',
                        labelStyle: TextStyle(color: Colors.white.withOpacity(0.8)),
                        hintText: 'Enter project name',
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                        prefixIcon: Icon(
                          Icons.folder,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                      maxLength: 128,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a project name';
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
                        hintText: 'Describe your project',
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

                    // Budget Field
                    TextFormField(
                      controller: _budgetController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Budget *',
                        labelStyle: TextStyle(color: Colors.white.withOpacity(0.8)),
                        hintText: '0.00',
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                        prefixIcon: Icon(
                          Icons.attach_money,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a budget';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Status Dropdown
                    DropdownButtonFormField<String>(
                      value: _selectedStatus,
                      style: const TextStyle(color: Colors.white),
                      dropdownColor: const Color(0xFF1E293B).withOpacity(0.9),
                      decoration: InputDecoration(
                        labelText: 'Status',
                        labelStyle: TextStyle(color: Colors.white.withOpacity(0.8)),
                        prefixIcon: Icon(
                          Icons.flag,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                      items: _statusOptions.map((status) {
                        return DropdownMenuItem(
                          value: status,
                          child: Text(
                            status,
                            style: const TextStyle(color: Colors.white),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedStatus = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 20),

                    // Start Date Picker
                    GlassmorphismUtils.glassContainer(
                      blurStrength: 8.0,
                      opacity: 0.05,
                      borderRadius: BorderRadius.circular(12),
                      padding: const EdgeInsets.all(16),
                      child: ListTile(
                        title: Text(
                          'Start Date',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          _startDate != null
                              ? DateFormat('MMM dd, yyyy').format(_startDate!)
                              : 'Not set',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                        trailing: Icon(
                          Icons.calendar_today,
                          color: Colors.white.withOpacity(0.8),
                        ),
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _startDate ?? DateTime.now(),
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
                              _startDate = date;
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    // End Date Picker
                    GlassmorphismUtils.glassContainer(
                      blurStrength: 8.0,
                      opacity: 0.05,
                      borderRadius: BorderRadius.circular(12),
                      padding: const EdgeInsets.all(16),
                      child: ListTile(
                        title: Text(
                          'End Date',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          _endDate != null
                              ? DateFormat('MMM dd, yyyy').format(_endDate!)
                              : 'Not set',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                        trailing: Icon(
                          Icons.calendar_today,
                          color: Colors.white.withOpacity(0.8),
                        ),
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _endDate ?? DateTime.now(),
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
                              _endDate = date;
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Save Button
                    GlassmorphismUtils.glassButton(
                      blurStrength: 12.0,
                      opacity: 0.1,
                      borderRadius: BorderRadius.circular(16),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      onPressed: _saveProject,
                      child: Text(
                        isEditing ? 'Update Project' : 'Create Project',
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

  Future<void> _saveProject() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();
    final budget = double.parse(_budgetController.text.trim());

    if (widget.project != null) {
      // Update existing project
      final updatedProject = widget.project!.copyWith(
        projectName: name,
        description: description,
        budget: budget,
        status: _selectedStatus,
        startDate: _startDate,
        endDate: _endDate,
      );
      
      await ref.read(projectNotifierProvider.notifier).updateProject(updatedProject);
    } else {
      // Create new project
      await ref.read(projectNotifierProvider.notifier).createProject(
        projectName: name,
        description: description,
        budget: budget,
        status: _selectedStatus,
        startDate: _startDate,
        endDate: _endDate,
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
              widget.project != null
                  ? 'Project updated successfully'
                  : 'Project created successfully',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      );
    }
  }
}

