import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/task_providers.dart';
import '../../providers/project_providers.dart';
import '../../providers/theme_provider.dart';
import '../../theme/app_theme.dart';
import 'task_form_screen.dart';

class TaskListScreen extends ConsumerWidget {
  final String projectId;

  const TaskListScreen({super.key, required this.projectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch theme to ensure rebuild on theme change
    ref.watch(themeModeProvider);
    
    final tasksAsync = ref.watch(tasksByProjectIdProvider(projectId));
    final projectAsync = ref.watch(projectByIdProvider(projectId));

    return Scaffold(
      appBar: AppBar(
        title: projectAsync.when(
          data: (project) => Text(
            project?.projectName ?? 'Tasks',
            style: TextStyle(color: context.onSurfaceColor),
          ),
          loading: () => Text(
            'Tasks',
            style: TextStyle(color: context.onSurfaceColor),
          ),
          error: (_, __) => Text(
            'Tasks',
            style: TextStyle(color: context.onSurfaceColor),
          ),
        ),
      ),
      body: Column(
        children: [
          // Project summary card
          projectAsync.when(
            data: (project) {
              if (project == null) return const SizedBox.shrink();
              
              return Builder(
                builder: (cardContext) => Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cardContext.surfaceColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: cardContext.greyColor(200)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  project.projectName,
                                  style: Theme.of(cardContext).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: -0.5,
                                    color: cardContext.onSurfaceColor,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  project.description,
                                  style: Theme.of(cardContext).textTheme.bodyMedium?.copyWith(
                                    color: cardContext.greyColor(600),
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Builder(
                            builder: (statusContext) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: StatusColors.getBackgroundColor(
                                  project.status,
                                  isDark: Theme.of(statusContext).brightness == Brightness.dark,
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                project.status,
                                style: Theme.of(statusContext).textTheme.bodySmall?.copyWith(
                                  color: StatusColors.getTextColor(
                                    project.status,
                                    isDark: Theme.of(statusContext).brightness == Brightness.dark,
                                  ),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (project.budget > 0) ...[
                        const SizedBox(height: 12),
                        Builder(
                          builder: (budgetContext) {
                            final isDark = Theme.of(budgetContext).brightness == Brightness.dark;
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: isDark 
                                    ? Theme.of(budgetContext).colorScheme.onPrimaryFixed
                                    : Theme.of(budgetContext).colorScheme.onSecondary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.attach_money,
                                    size: 16,
                                    color: budgetContext.greyColor(600),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Budget: \$${project.budget.toStringAsFixed(2)}',
                                    style: Theme.of(budgetContext).textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w500,
                                      color: budgetContext.onSurfaceColor,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.task_outlined,
                          size: 64,
                          color: context.greyColor(400),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No tasks yet',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: context.greyColor(600),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap + to create your first task',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: context.greyColor(500),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    final isOverdue = task.dueDate != null && _isOverdue(task.dueDate!);
                    
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TaskFormScreen(
                                projectId: projectId,
                                task: task,
                          ),
                        ),
                          );
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                        Text(
                                          task.name,
                                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: -0.3,
                                            color: context.onSurfaceColor,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          task.description,
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            color: context.greyColor(600),
                                            height: 1.5,
                                          ),
                                        ),
                                  ],
                                ),
                              ),
                                  PopupMenuButton<String>(
                                    icon: Icon(
                                      Icons.more_vert,
                                      color: Colors.grey.shade600,
                                      size: 20,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
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
                                      PopupMenuItem(
                                        value: 'edit',
                                        child: Row(
                                          children: [
                                            Icon(Icons.edit_outlined, size: 18),
                                            const SizedBox(width: 12),
                                            Text(
                                              'Edit',
                                              style: TextStyle(color: context.onSurfaceColor),
                                            ),
                                          ],
                                        ),
                                      ),
                                      PopupMenuItem(
                              value: 'delete',
                                        child: Row(
                                          children: [
                                            Icon(Icons.delete_outline, size: 18, color: context.errorColor),
                                            const SizedBox(width: 12),
                                            Text('Delete', style: TextStyle(color: context.errorColor)),
                                          ],
                                        ),
                            ),
                          ],
                                  ),
                                ],
                              ),
                              if (task.dueDate != null) ...[
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: isOverdue 
                                        ? context.greyColor(100) 
                                        : context.secondaryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.calendar_today,
                                        size: 14,
                                        color: isOverdue 
                                            ? context.errorColor 
                                            : context.greyColor(600),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Due: ${DateFormat('MMM dd, yyyy').format(task.dueDate!)}',
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: isOverdue 
                                              ? context.errorColor 
                                              : context.greyColor(700),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: context.errorColor.withOpacity(0.6),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading tasks',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: context.onSurfaceColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error.toString(),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context.greyColor(600),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TaskFormScreen(projectId: projectId),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }


  bool _isOverdue(DateTime dueDate) {
    return dueDate.isBefore(DateTime.now());
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, String taskId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(taskNotifierProvider.notifier).deleteTask(taskId);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Task deleted'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: context.errorColor,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

