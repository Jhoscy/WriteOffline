import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/services/sync_orchestrator.dart';
import '../../providers/project_providers.dart';
import '../../providers/service_providers.dart';
import '../../theme/neobrutalism_theme.dart';
import 'project_form_screen.dart';
import '../tasks/task_list_screen.dart';

class ProjectListScreen extends ConsumerWidget {
  const ProjectListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
        title: const Text('Projects',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
        actions: [
          // Connectivity indicator
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8.0),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: NeobrutalismTheme.neobrutalismBox(
              color: isConnected
                  ? NeobrutalismTheme.statusActive
                  : NeobrutalismTheme.statusCancelled,
              borderWidth: 3,
              shadow: NeobrutalismTheme.smallShadow,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isConnected ? Icons.cloud_done : Icons.cloud_off,
                  color: NeobrutalismTheme.primaryWhite,
                ),
                // const SizedBox(width: 6),
                if (syncStatus == SyncStatus.syncing)
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                          NeobrutalismTheme.primaryWhite),
                    ),
                  ),
              ],
            ),
          ),
          // Manual sync button
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: NeobrutalismTheme.neobrutalismBox(
              color: isConnected
                  ? NeobrutalismTheme.accentIndigo
                  : NeobrutalismTheme.primaryBlack,
              borderWidth: 3,
              shadow: NeobrutalismTheme.smallShadow,
            ),
            child: IconButton(
              icon:
                  const Icon(Icons.sync, color: NeobrutalismTheme.primaryWhite),
              onPressed: isConnected
                  ? () async {
                      final orchestrator = ref.read(syncOrchestratorProvider);
                      try {
                        await orchestrator.forceSyncNow();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Sync completed successfully')),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Sync failed: $e')),
                          );
                        }
                      }
                    }
                  : null,
            ),
          ),
        ],
      ),
      body: projectsAsync.when(
        data: (projects) {
          if (projects.isEmpty) {
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
                      'No projects yet.\nTap + to create one.',
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
            padding: const EdgeInsets.all(16),
            itemCount: projects.length,
            itemBuilder: (context, index) {
              final project = projects[index];
              final statusColor =
                  NeobrutalismTheme.getStatusColor(project.status);

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: NeobrutalismTheme.neobrutalismBox(
                  color: NeobrutalismTheme.primaryWhite,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              TaskListScreen(projectId: project.id),
                        ),
                      );
                    },
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
                                  project.projectName,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(
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
                                        builder: (context) =>
                                            ProjectFormScreen(project: project),
                                      ),
                                    );
                                  } else if (value == 'delete') {
                                    _showDeleteDialog(context, ref, project.id);
                                  }
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'edit',
                                    child: Text('Edit',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w700)),
                                  ),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Text('Delete',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            color: NeobrutalismTheme
                                                .statusCancelled)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            project.description,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: NeobrutalismTheme.neobrutalismBox(
                                  color: statusColor,
                                  borderWidth: 2,
                                  shadow: NeobrutalismTheme.labelShadow,
                                ),
                                child: Text(
                                  project.status.toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color:  NeobrutalismTheme.primaryWhite,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: NeobrutalismTheme.neobrutalismBox(
                                  color: NeobrutalismTheme.accentGold,
                                  borderWidth: 2,
                                  shadow: NeobrutalismTheme.labelShadow,
                                ),
                                child: Text(
                                  '\$${project.budget.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: NeobrutalismTheme.primaryBlack,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (project.startDate != null ||
                              project.endDate != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_today,
                                      size: 14,
                                      color: NeobrutalismTheme.primaryBlack),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${project.startDate != null ? DateFormat('MMM dd, yyyy').format(project.startDate!) : 'No start'} - ${project.endDate != null ? DateFormat('MMM dd, yyyy').format(project.endDate!) : 'No end'}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.w600,
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
            valueColor:
                AlwaysStoppedAnimation<Color>(NeobrutalismTheme.primaryRed),
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
                builder: (context) => const ProjectFormScreen(),
              ),
            );
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add,
              color: NeobrutalismTheme.primaryBlack, size: 28),
        ),
      ),
    );
  }

  void _showDeleteDialog(
      BuildContext context, WidgetRef ref, String projectId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Project',
            style: TextStyle(fontWeight: FontWeight.w900)),
        content: const Text('Are you sure you want to delete this project?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(fontWeight: FontWeight.w700)),
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
                await ref
                    .read(projectNotifierProvider.notifier)
                    .deleteProject(projectId);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Project deleted')),
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
