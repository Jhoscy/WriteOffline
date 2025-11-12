import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../domain/entities/project.dart';
import '../../providers/project_providers.dart';
import '../../theme/app_theme.dart';

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

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Project' : 'New Project'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
          children: [
            // Text(
            //   isEditing ? 'Edit Document' : 'Create New Document',
            //   style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            //     fontWeight: FontWeight.w600,
            //     letterSpacing: -0.6,
            //   ),
            // ),
            const SizedBox(height: 32),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Project Name *',
                hintText: 'Enter project name',
              ),
              maxLength: 128,
              style: Theme.of(context).textTheme.bodyLarge,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a project name';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description *',
                hintText: 'Enter project description',
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
            TextFormField(
              controller: _budgetController,
              decoration: const InputDecoration(
                labelText: 'Budget *',
                hintText: '0.00',
                prefixText: '\$ ',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: Theme.of(context).textTheme.bodyLarge,
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
            const SizedBox(height: 24),
            DropdownButtonFormField<String>(
              value: _selectedStatus,
              decoration: const InputDecoration(
                labelText: 'Status',
              ),
              items: _statusOptions.map((status) {
                return DropdownMenuItem(
                  value: status,
                  child: Text(status),
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
                  'Start Date',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: context.onSurfaceColor,
                  ),
                ),
              subtitle: Text(
                _startDate != null 
                    ? DateFormat('MMM dd, yyyy').format(_startDate!) 
                    : 'Not set',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: _startDate != null 
                        ? context.greyColor(700) 
                        : context.greyColor(400),
                  ),
              ),
                trailing: Icon(
                  Icons.calendar_today,
                  size: 20,
                  color: context.greyColor(600),
                ),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _startDate ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (date != null) {
                  setState(() {
                    _startDate = date;
                  });
                }
              },
            ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: context.surfaceColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: context.greyColor(300)),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                title: Text(
                  'End Date',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: context.onSurfaceColor,
                  ),
                ),
              subtitle: Text(
                _endDate != null 
                    ? DateFormat('MMM dd, yyyy').format(_endDate!) 
                    : 'Not set',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: _endDate != null 
                        ? context.greyColor(700) 
                        : context.greyColor(400),
                  ),
              ),
                trailing: Icon(
                  Icons.calendar_today,
                  size: 20,
                  color: context.greyColor(600),
                ),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _endDate ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
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
            ElevatedButton(
              onPressed: _saveProject,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
              ),
              child: Text(
                isEditing ? 'Update Project' : 'Create Project',
              ),
            ),
          ],
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
          content: Text(
            widget.project != null 
                ? 'Project updated successfully' 
                : 'Project created successfully',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

