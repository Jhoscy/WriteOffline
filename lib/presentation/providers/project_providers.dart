import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/project.dart';
import 'repository_providers.dart';

/// Provider for watching all projects
final projectsProvider = StreamProvider<List<Project>>((ref) {
  final repository = ref.watch(projectRepositoryProvider);
  return repository.watchProjects();
});

/// Provider for getting a specific project by ID
final projectByIdProvider = FutureProvider.family<Project?, String>((ref, id) async {
  final repository = ref.watch(projectRepositoryProvider);
  return repository.getProjectById(id);
});

/// Notifier for project operations
class ProjectNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() {
    return const AsyncValue.data(null);
  }

  /// Create a new project
  Future<void> createProject({
    required String projectName,
    required String description,
    DateTime? startDate,
    DateTime? endDate,
    required double budget,
    required String status,
  }) async {
    state = const AsyncValue.loading();
    
    try {
      final repository = ref.read(projectRepositoryProvider);
      final now = DateTime.now();
      
      final project = Project(
        id: const Uuid().v4(),
        projectName: projectName,
        description: description,
        startDate: startDate,
        endDate: endDate,
        budget: budget,
        status: status,
        createdAt: now,
        updatedAt: now,
      );
      
      await repository.createProject(project);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Update an existing project
  Future<void> updateProject(Project project) async {
    state = const AsyncValue.loading();
    
    try {
      final repository = ref.read(projectRepositoryProvider);
      await repository.updateProject(project);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Delete a project (logical deletion)
  Future<void> deleteProject(String id) async {
    state = const AsyncValue.loading();
    
    try {
      final repository = ref.read(projectRepositoryProvider);
      await repository.deleteProject(id);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

/// Provider for project notifier
final projectNotifierProvider = NotifierProvider<ProjectNotifier, AsyncValue<void>>(() {
  return ProjectNotifier();
});

