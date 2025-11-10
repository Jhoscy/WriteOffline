import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../domain/entities/project.dart';
import '../../providers/project_providers.dart';
import '../../theme/neobrutalism_theme.dart';

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
        title: Text(isEditing ? 'Edit Project' : 'New Project', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Project Name *',
                border: OutlineInputBorder(),
              ),
              maxLength: 128,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a project name';
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
            TextFormField(
              controller: _budgetController,
              decoration: const InputDecoration(
                labelText: 'Budget *',
                border: OutlineInputBorder(),
                prefixText: '\$ ',
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
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedStatus,
              decoration: const InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
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
            const SizedBox(height: 16),
            Container(
              decoration: NeobrutalismTheme.neobrutalismBox(
                color: NeobrutalismTheme.primaryWhite,
              ),
              child: ListTile(
                title: const Text('Start Date', style: TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Text(
                  _startDate != null 
                      ? DateFormat('MMM dd, yyyy').format(_startDate!) 
                      : 'Not set',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                trailing: const Icon(Icons.calendar_today, color: NeobrutalismTheme.primaryBlack),
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
            const SizedBox(height: 16),
            Container(
              decoration: NeobrutalismTheme.neobrutalismBox(
                color: NeobrutalismTheme.primaryWhite,
              ),
              child: ListTile(
                title: const Text('End Date', style: TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Text(
                  _endDate != null 
                      ? DateFormat('MMM dd, yyyy').format(_endDate!) 
                      : 'Not set',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                trailing: const Icon(Icons.calendar_today, color: NeobrutalismTheme.primaryBlack),
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
            const SizedBox(height: 24),
            Container(
              decoration: NeobrutalismTheme.neobrutalismBox(
                color: NeobrutalismTheme.primaryRed,
                shadow: NeobrutalismTheme.buttonShadow,
              ),
              child: ElevatedButton(
                onPressed: _saveProject,
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
                  isEditing ? 'Update Project' : 'Create Project',
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
        ),
      );
    }
  }
}

