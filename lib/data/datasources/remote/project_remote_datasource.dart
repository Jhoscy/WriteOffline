import '../../models/project_model.dart';

/// Abstract interface for Project remote operations
/// This allows swapping backends (Appwrite, Supabase, etc.)
abstract class ProjectRemoteDatasource {
  /// Get all projects from remote
  Future<List<ProjectModel>> getAll();

  /// Get a single project by ID from remote
  Future<ProjectModel?> getById(String id);

  /// Create a new project on remote
  Future<ProjectModel> create(ProjectModel project);

  /// Update an existing project on remote
  Future<ProjectModel> update(ProjectModel project);

  /// Get projects updated after a specific timestamp
  Future<List<ProjectModel>> getUpdatedAfter(DateTime timestamp);
}

