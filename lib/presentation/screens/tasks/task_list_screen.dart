import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/task_providers.dart';
import '../../providers/project_providers.dart';
import '../../widgets/glassmorphism_utils.dart';
import 'task_form_screen.dart';

class TaskListScreen extends ConsumerWidget {
  final String projectId;

  const TaskListScreen({super.key, required this.projectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(tasksByProjectIdProvider(projectId));
    final projectAsync = ref.watch(projectByIdProvider(projectId));

    return GlassmorphismUtils.gradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: projectAsync.when(
            data: (project) => Text(project?.projectName ?? 'Tasks'),
            loading: () => const Text('Tasks'),
            error: (_, __) => const Text('Tasks'),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Project summary card
              projectAsync.when(
                data: (project) {
                  if (project == null) return const SizedBox.shrink();

                  return GlassmorphismUtils.glassCard(
                    blurStrength: 15.0,
                    opacity: 0.08,
                    margin: const EdgeInsets.all(20),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  project.projectName,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _getProjectStatusColor(project.status).withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  project.status,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            project.description,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.8),
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(
                                Icons.attach_money,
                                size: 16,
                                color: Colors.white.withOpacity(0.7),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Budget: \$${project.budget.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),
                          if (project.startDate != null || project.endDate != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    size: 16,
                                    color: Colors.white.withOpacity(0.7),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${project.startDate != null ? DateFormat('MMM dd, yyyy').format(project.startDate!) : 'No start'} - ${project.endDate != null ? DateFormat('MMM dd, yyyy').format(project.endDate!) : 'No end'}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.white.withOpacity(0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),

              // Tasks list
              Expanded(
                child: tasksAsync.when(
                  data: (tasks) {
                    if (tasks.isEmpty) {
                      return Center(
                        child: GlassmorphismUtils.glassContainer(
                          blurStrength: 12.0,
                          opacity: 0.1,
                          borderRadius: BorderRadius.circular(16),
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.task_alt,
                                size: 48,
                                color: Colors.white.withOpacity(0.6),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No tasks yet. Tap + to create one.',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.only(bottom: 80),
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        final task = tasks[index];
                        return GlassmorphismUtils.glassCard(
                          blurStrength: 15.0,
                          opacity: 0.08,
                          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          child: ListTile(
                            title: Text(
                              task.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 6),
                                Text(
                                  task.description,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 14,
                                    height: 1.3,
                                  ),
                                ),
                                if (task.dueDate != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: _isOverdue(task.dueDate!)
                                            ? const Color(0xFFEF4444).withOpacity(0.2)
                                            : const Color(0xFF6366F1).withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: _isOverdue(task.dueDate!)
                                              ? const Color(0xFFEF4444).withOpacity(0.3)
                                              : const Color(0xFF6366F1).withOpacity(0.3),
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.calendar_today,
                                            size: 12,
                                            color: _isOverdue(task.dueDate!)
                                                ? const Color(0xFFEF4444)
                                                : const Color(0xFF6366F1),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Due: ${DateFormat('MMM dd, yyyy').format(task.dueDate!)}',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: _isOverdue(task.dueDate!)
                                                  ? const Color(0xFFEF4444)
                                                  : const Color(0xFF6366F1),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            trailing: PopupMenuButton<String>(
                              icon: const Icon(
                                Icons.more_vert,
                                color: Colors.white,
                              ),
                              onSelected: (value) {
                                if (value == 'edit') {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => TaskFormScreen(
                                        projectId: projectId,
                                        task: task,
                                      ),
                                    ),
                                  );
                                } else if (value == 'delete') {
                                  _showDeleteDialog(context, ref, task.id);
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Text('Edit'),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Text('Delete'),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
                    ),
                  ),
                  error: (error, stack) => Center(
                    child: GlassmorphismUtils.glassContainer(
                      blurStrength: 12.0,
                      opacity: 0.1,
                      borderRadius: BorderRadius.circular(16),
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'Error: $error',
                        style: const TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: GlassmorphismUtils.glassFab(
          blurStrength: 20.0,
          opacity: 0.12,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TaskFormScreen(projectId: projectId),
              ),
            );
          },
          child: const Icon(
            Icons.add,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
    );
  }

  Color _getProjectStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
      case 'in progress':
        return const Color(0xFF10B981); // Emerald
      case 'completed':
        return const Color(0xFF3B82F6); // Blue
      case 'on hold':
        return const Color(0xFFF59E0B); // Amber
      case 'cancelled':
        return const Color(0xFFEF4444); // Red
      default:
        return const Color(0xFF6B7280); // Gray
    }
  }

  bool _isOverdue(DateTime dueDate) {
    return dueDate.isBefore(DateTime.now());
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, String taskId) {
    showDialog(
      context: context,
      builder: (context) => GlassmorphismUtils.glassContainer(
        blurStrength: 20.0,
        opacity: 0.15,
        borderRadius: BorderRadius.circular(16),
        margin: const EdgeInsets.all(40),
        child: AlertDialog(
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          title: const Text(
            'Delete Task',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          content: const Text(
            'Are you sure you want to delete this task?',
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.white.withOpacity(0.8)),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                ref.read(taskNotifierProvider.notifier).deleteTask(taskId).then((_) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        content: GlassmorphismUtils.glassContainer(
                          blurStrength: 10.0,
                          opacity: 0.15,
                          borderRadius: BorderRadius.circular(8),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: const Text(
                            'Task deleted',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    );
                  }
                });
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

