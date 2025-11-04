import '../../models/task_model.dart';

/// Abstract interface for Task remote operations
/// This allows swapping backends (Appwrite, Supabase, etc.)
abstract class TaskRemoteDatasource {
  /// Get all tasks from remote
  Future<List<TaskModel>> getAll();

  /// Get all tasks for a specific project from remote
  Future<List<TaskModel>> getByProjectId(String projectId);

  /// Get a single task by ID from remote
  Future<TaskModel?> getById(String id);

  /// Create a new task on remote
  Future<TaskModel> create(TaskModel task);

  /// Update an existing task on remote
  Future<TaskModel> update(TaskModel task);

  /// Get tasks updated after a specific timestamp
  Future<List<TaskModel>> getUpdatedAfter(DateTime timestamp);
}

