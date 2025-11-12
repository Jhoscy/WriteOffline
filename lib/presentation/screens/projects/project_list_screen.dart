import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/services/sync_orchestrator.dart';
import '../../providers/project_providers.dart';
import '../../providers/service_providers.dart';
import '../../providers/theme_provider.dart';
import '../../theme/app_theme.dart';
import 'project_form_screen.dart';
import '../tasks/task_list_screen.dart';

class ProjectListScreen extends ConsumerWidget {
  const ProjectListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch theme to ensure rebuild on theme change
    ref.watch(themeModeProvider);

    final projectsAsync = ref.watch(projectsProvider);
    final connectivityAsync = ref.watch(connectivityStatusProvider);
    final syncStatusAsync = ref.watch(syncStatusProvider);

    // Get initial connectivity status
    final connectivityService = ref.watch(connectivityServiceProvider);
    final isConnected =
        connectivityAsync.asData?.value ?? connectivityService.isConnected;

    // Get sync status
    final syncStatus = syncStatusAsync.asData?.value ?? SyncStatus.idle;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Projects'),
        actions: [
          // Theme toggle switch
          Consumer(
            builder: (context, ref, child) {
              final themeMode = ref.watch(themeModeProvider);
              final isDark = themeMode == ThemeMode.dark;

              return IconButton(
                icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
                tooltip:
                    isDark ? 'Switch to light mode' : 'Switch to dark mode',
                onPressed: () {
                  ref.read(themeModeProvider.notifier).toggleTheme();
                },
              );
            },
          ),
          // Connectivity indicator
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isConnected
                        ? Colors.green.withOpacity(0.1)
                        : context.errorColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isConnected ? Icons.cloud_done : Icons.cloud_off,
                    color: isConnected
                        ? Colors.green.shade700
                        : context.errorColor,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 8),
                if (syncStatus == SyncStatus.syncing)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
          ),
          // Manual sync button
          IconButton(
            icon: const Icon(Icons.sync),
            tooltip: 'Sync',
            onPressed: isConnected
                ? () async {
                    final orchestrator = ref.read(syncOrchestratorProvider);
                    try {
                      await orchestrator.forceSyncNow();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Sync completed successfully'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Sync failed: $e'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    }
                  }
                : null,
          ),
        ],
      ),
      body: projectsAsync.when(
        data: (projects) {
          if (projects.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.description_outlined,
                    size: 64,
                    color: context.greyColor(400),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No projects yet',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: context.greyColor(600),
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap + to create your first project',
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
            itemCount: projects.length,
            itemBuilder: (context, index) {
              final project = projects[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Builder(
                  builder: (cardContext) => InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              TaskListScreen(projectId: project.id),
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
                                      project.projectName,
                                      style: Theme.of(cardContext)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: -0.5,
                                            color: cardContext.onSurfaceColor,
                                          ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      project.description,
                                      style: Theme.of(cardContext)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: cardContext.greyColor(600),
                                            height: 1.5,
                                          ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              Builder(
                                builder: (menuContext) =>
                                    PopupMenuButton<String>(
                                  icon: Icon(
                                    Icons.more_vert,
                                    color: menuContext.greyColor(600),
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
                                          builder: (context) =>
                                              ProjectFormScreen(
                                                  project: project),
                                        ),
                                      );
                                    } else if (value == 'delete') {
                                      _showDeleteDialog(
                                          context, ref, project.id);
                                    }
                                  },
                                  itemBuilder: (menuContext) => [
                                    PopupMenuItem(
                                      value: 'edit',
                                      child: Row(
                                        children: [
                                          Icon(Icons.edit_outlined, size: 18),
                                          const SizedBox(width: 12),
                                          Text(
                                            'Edit',
                                            style: TextStyle(
                                                color:
                                                    menuContext.onSurfaceColor),
                                          ),
                                        ],
                                      ),
                                    ),
                                    PopupMenuItem(
                                      value: 'delete',
                                      child: Row(
                                        children: [
                                          Icon(Icons.delete_outline,
                                              size: 18,
                                              color: menuContext.errorColor),
                                          const SizedBox(width: 12),
                                          Text('Delete',
                                              style: TextStyle(
                                                  color:
                                                      menuContext.errorColor)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Builder(
                            builder: (chipContext) => Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _buildStatusChip(chipContext, project.status),
                                if (project.budget > 0)
                                  Builder(
                                    builder: (context) {
                                      final isDark =
                                          Theme.of(context).brightness ==
                                              Brightness.dark;
                                      return Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: isDark
                                              ? Colors.green.shade900
                                                  .withOpacity(0.3)
                                              : Colors.green.shade100,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          '\$${project.budget.toStringAsFixed(0)}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.w500,
                                                color: context.onSurfaceColor,
                                              ),
                                        ),
                                      );
                                    },
                                  ),
                                if (project.startDate != null ||
                                    project.endDate != null)
                                  Builder(
                                    builder: (context) {
                                      final isDark =
                                          Theme.of(context).brightness ==
                                              Brightness.dark;
                                      return Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: isDark
                                              ? Colors.purple.shade900
                                                  .withOpacity(0.3)
                                              : Colors.purple.shade100,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.calendar_today,
                                              size: 14,
                                              color: context.greyColor(600),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              project.startDate != null
                                                  ? DateFormat('MMM dd').format(
                                                      project.startDate!)
                                                  : '—',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.w500,
                                                    color:
                                                        context.onSurfaceColor,
                                                  ),
                                            ),
                                            if (project.endDate != null) ...[
                                              Text(
                                                ' - ${DateFormat('MMM dd').format(project.endDate!)}',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall
                                                    ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: context
                                                          .onSurfaceColor,
                                                    ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      );
                                    },
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
                'Error loading projects',
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ProjectFormScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, String status) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: StatusColors.getBackgroundColor(status, isDark: isDark),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: StatusColors.getTextColor(status, isDark: isDark),
              fontWeight: FontWeight.w500,
            ),
      ),
    );
  }

  void _showDeleteDialog(
      BuildContext context, WidgetRef ref, String projectId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Delete Project'),
        content: const Text(
            'Are you sure you want to delete this project? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref
                  .read(projectNotifierProvider.notifier)
                  .deleteProject(projectId);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Project deleted'),
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
