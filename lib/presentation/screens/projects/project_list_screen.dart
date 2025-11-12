import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/services/sync_orchestrator.dart';
import '../../providers/project_providers.dart';
import '../../providers/service_providers.dart';
import '../../widgets/glassmorphism_utils.dart';
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
    final isConnected = connectivityAsync.asData?.value ?? connectivityService.isConnected;

    // Get sync status
    final syncStatus = syncStatusAsync.asData?.value ?? SyncStatus.idle;

    return GlassmorphismUtils.gradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Projects'),
          actions: [
            // Connectivity indicator with glassmorphism
            GlassmorphismUtils.glassContainer(
              blurStrength: 8.0,
              opacity: 0.1,
              borderRadius: BorderRadius.circular(20),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              margin: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  Icon(
                    isConnected ? Icons.cloud_done : Icons.cloud_off,
                    color: isConnected ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                    size: 20,
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
            // Manual sync button with glassmorphism
            GlassmorphismUtils.glassButton(
              blurStrength: 8.0,
              opacity: 0.1,
              borderRadius: BorderRadius.circular(20),
              padding: const EdgeInsets.all(8),
              onPressed: () {
                if (!isConnected) return;
                final orchestrator = ref.read(syncOrchestratorProvider);
                orchestrator.forceSyncNow().then((_) {
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
                            'Sync completed successfully',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    );
                  }
                }).catchError((e) {
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
                          child: Text(
                            'Sync failed: $e',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    );
                  }
                });
              },
              child: Icon(
                Icons.sync,
                color: isConnected ? Colors.white : Colors.white.withOpacity(0.5),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: projectsAsync.when(
            data: (projects) {
              if (projects.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.only(top: 20), // Some spacing from app bar
                  child: Center(
                    child: GlassmorphismUtils.glassContainer(
                      blurStrength: 12.0,
                      opacity: 0.1,
                      borderRadius: BorderRadius.circular(16),
                      padding: const EdgeInsets.all(24),
                      child: const Text(
                        'No projects yet. Tap + to create one.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.only(
                  top: 20, // Some spacing from app bar
                  bottom: 100, // Space for FAB
                  left: 16,
                  right: 16,
                ),
                itemCount: projects.length,
                itemBuilder: (context, index) {
                  final project = projects[index];
                  return GlassmorphismUtils.glassCard(
                    blurStrength: 15.0,
                    opacity: 0.08,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                    title: Text(
                      project.projectName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Text(
                          project.description,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getStatusColor(project.status).withOpacity(0.8),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                project.status,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Budget: \$${project.budget.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.8),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        if (project.startDate != null || project.endDate != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              '${project.startDate != null ? DateFormat('MMM dd, yyyy').format(project.startDate!) : 'No start'} - ${project.endDate != null ? DateFormat('MMM dd, yyyy').format(project.endDate!) : 'No end'}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.6),
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
                              builder: (context) => ProjectFormScreen(project: project),
                            ),
                          );
                        } else if (value == 'delete') {
                          _showDeleteDialog(context, ref, project.id);
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
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TaskListScreen(projectId: project.id),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
          loading: () => Padding(
            padding: const EdgeInsets.only(top: 40),
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
              ),
            ),
          ),
          error: (error, stack) => Padding(
            padding: const EdgeInsets.only(top: 40),
            child: Center(
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
        ),
        floatingActionButton: GlassmorphismUtils.glassFab(
          blurStrength: 20.0,
          opacity: 0.12,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ProjectFormScreen(),
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

  Color _getStatusColor(String status) {
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

  void _showDeleteDialog(BuildContext context, WidgetRef ref, String projectId) {
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
            'Delete Project',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          content: const Text(
            'Are you sure you want to delete this project?',
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
                ref.read(projectNotifierProvider.notifier).deleteProject(projectId).then((_) {
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
                            'Project deleted',
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

