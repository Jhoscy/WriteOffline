import '../entities/task.dart';

/// Repository interface for Task operations
/// This defines the contract that data layer must implement
abstract class TaskRepository {
  /// Get all tasks (excluding deleted ones by default)
  Future<List<Task>> getAllTasks({bool includeDeleted = false});

  /// Get all tasks for a specific project
  Future<List<Task>> getTasksByProjectId(String projectId, {bool includeDeleted = false});

  /// Get a single task by ID
  Future<Task?> getTaskById(String id);

  /// Create a new task
  Future<Task> createTask(Task task);

  /// Update an existing task
  Future<Task> updateTask(Task task);

  /// Delete a task (logical deletion)
  Future<void> deleteTask(String id);

  /// Watch tasks stream for real-time updates
  Stream<List<Task>> watchTasks({bool includeDeleted = false});

  /// Watch tasks for a specific project
  Stream<List<Task>> watchTasksByProjectId(String projectId, {bool includeDeleted = false});
}

