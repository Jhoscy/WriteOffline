import '../entities/project.dart';

/// Repository interface for Project operations
/// This defines the contract that data layer must implement
abstract class ProjectRepository {
  /// Get all projects (excluding deleted ones by default)
  Future<List<Project>> getAllProjects({bool includeDeleted = false});

  /// Get a single project by ID
  Future<Project?> getProjectById(String id);

  /// Create a new project
  Future<Project> createProject(Project project);

  /// Update an existing project
  Future<Project> updateProject(Project project);

  /// Delete a project (logical deletion)
  Future<void> deleteProject(String id);

  /// Watch projects stream for real-time updates
  Stream<List<Project>> watchProjects({bool includeDeleted = false});
}

