import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/task_providers.dart';
import '../../providers/project_providers.dart';
import '../../theme/neobrutalism_theme.dart';
import 'task_form_screen.dart';

class TaskListScreen extends ConsumerWidget {
  final String projectId;

  const TaskListScreen({super.key, required this.projectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(tasksByProjectIdProvider(projectId));
    final projectAsync = ref.watch(projectByIdProvider(projectId));

    return Scaffold(
      appBar: AppBar(
        title: projectAsync.when(
          data: (project) => Text(
            project?.projectName ?? 'Tasks',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
          ),
          loading: () => const Text('Tasks', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
          error: (_, __) => const Text('Tasks', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
        ),
      ),
      body: Column(
        children: [
          // Project summary card
          projectAsync.when(
            data: (project) {
              if (project == null) return const SizedBox.shrink();
              
              final statusColor = NeobrutalismTheme.getStatusColor(project.status);
              
              return Container(
                margin: const EdgeInsets.all(16),
                decoration: NeobrutalismTheme.neobrutalismBox(
                  color: const Color.fromARGB(255, 224, 213, 233),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              project.projectName,
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.only(left: 4, bottom: 4),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: NeobrutalismTheme.neobrutalismBox(
                                color: statusColor.withOpacity(0.5),
                                borderWidth: 2,
                                shadow: NeobrutalismTheme.labelShadow,
                              ),
                              child: Text(
                                project.status.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: Color.lerp(statusColor, Colors.white, 0.4) ?? statusColor,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        project.description,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: NeobrutalismTheme.neobrutalismBox(
                            color: NeobrutalismTheme.accentGold,
                            borderWidth: 2,
                            shadow: NeobrutalismTheme.labelShadow,
                          ),
                          child: Text(
                            'Budget: \$${project.budget.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
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
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      decoration: NeobrutalismTheme.neobrutalismBox(
                        color: NeobrutalismTheme.primaryWhite,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'EMPTY',
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.w900,
                              color: NeobrutalismTheme.primaryBlack,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No tasks yet.\nTap + to create one.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    final isOverdue = task.dueDate != null && _isOverdue(task.dueDate!);
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: NeobrutalismTheme.neobrutalismBox(
                        color: NeobrutalismTheme.primaryWhite,
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {},
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        task.name,
                                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ),
                                    PopupMenuButton<String>(
                                      icon: const Icon(Icons.more_vert, size: 20),
                                      shape: Border.all(
                                        color: NeobrutalismTheme.primaryBlack,
                                        width: NeobrutalismTheme.borderWidth,
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
                                          child: Text('Edit', style: TextStyle(fontWeight: FontWeight.w700)),
                                        ),
                                        const PopupMenuItem(
                                          value: 'delete',
                                          child: Text('Delete', style: TextStyle(fontWeight: FontWeight.w700, color: NeobrutalismTheme.statusCancelled)),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  task.description,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                if (task.dueDate != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 12),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.calendar_today,
                                          size: 14,
                                          color: isOverdue 
                                              ? NeobrutalismTheme.statusCancelled 
                                              : NeobrutalismTheme.primaryBlack,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Due: ${DateFormat('MMM dd, yyyy').format(task.dueDate!)}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: isOverdue 
                                                ? NeobrutalismTheme.statusCancelled 
                                                : NeobrutalismTheme.primaryBlack,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(NeobrutalismTheme.primaryRed),
                ),
              ),
              error: (error, stack) => Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: NeobrutalismTheme.neobrutalismBox(
                    color: NeobrutalismTheme.statusCancelled.withOpacity(0.1),
                  ),
                  child: Text(
                    'Error: $error',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: NeobrutalismTheme.statusCancelled,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Container(
        decoration: NeobrutalismTheme.neobrutalismBox(
          color: NeobrutalismTheme.accentGold,
          shadow: NeobrutalismTheme.buttonShadow,
        ),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TaskFormScreen(projectId: projectId),
              ),
            );
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add, color: NeobrutalismTheme.primaryBlack, size: 28),
        ),
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
        title: const Text('Delete Task', style: TextStyle(fontWeight: FontWeight.w900)),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
          Container(
            decoration: NeobrutalismTheme.neobrutalismBox(
              color: NeobrutalismTheme.statusCancelled,
              borderWidth: 3,
              shadow: NeobrutalismTheme.smallShadow,
            ),
            child: TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await ref.read(taskNotifierProvider.notifier).deleteTask(taskId);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Task deleted')),
                  );
                }
              },
              child: const Text(
                'Delete',
                style: TextStyle(
                  color: NeobrutalismTheme.primaryWhite,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


