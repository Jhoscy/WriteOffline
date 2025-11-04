import 'package:flutter/foundation.dart';
import '../../core/services/connectivity_service.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/local/task_local_datasource.dart';
import '../datasources/remote/task_remote_datasource.dart';
import '../models/task_model.dart';
import 'package:uuid/uuid.dart';

/// Hybrid repository that automatically syncs based on connectivity
/// - When online: writes to remote + local cache, reads from remote
/// - When offline: writes to local with sync flag, reads from local
class TaskHybridRepository implements TaskRepository {
  final TaskLocalDatasource _localDatasource;
  final TaskRemoteDatasource _remoteDatasource;
  final ConnectivityService _connectivityService;

  TaskHybridRepository({
    required TaskLocalDatasource localDatasource,
    required TaskRemoteDatasource remoteDatasource,
    required ConnectivityService connectivityService,
  })  : _localDatasource = localDatasource,
        _remoteDatasource = remoteDatasource,
        _connectivityService = connectivityService;

  bool get _isOnline => _connectivityService.isConnected;

  @override
  Future<List<Task>> getAllTasks({bool includeDeleted = false}) async {
    if (_isOnline) {
      try {
        // When online, fetch from remote and update local cache
        final remoteModels = await _remoteDatasource.getAll();
        
        // Update local cache with remote data, but preserve items with pending local changes
        for (final remoteModel in remoteModels) {
          final localModel = await _localDatasource.getById(remoteModel.id);
          
          // Only update if local doesn't have pending changes
          if (localModel == null || !localModel.needsSync) {
            remoteModel.needsSync = false;
            await _localDatasource.upsert(remoteModel);
          }
          // If local has pending changes (needsSync=true), keep local version
        }
        
        // Return from local (which now has merged data)
        return _getFromLocal(includeDeleted: includeDeleted);
      } catch (e) {
        debugPrint('Failed to fetch tasks from remote, falling back to local: $e');
        // Fall back to local on error
        return _getFromLocal(includeDeleted: includeDeleted);
      }
    } else {
      // When offline, read from local
      return _getFromLocal(includeDeleted: includeDeleted);
    }
  }

  Future<List<Task>> _getFromLocal({bool includeDeleted = false}) async {
    final models = await _localDatasource.getAll(includeDeleted: includeDeleted);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<Task>> getTasksByProjectId(String projectId, {bool includeDeleted = false}) async {
    if (_isOnline) {
      try {
        // When online, fetch from remote and update local cache
        final remoteModels = await _remoteDatasource.getByProjectId(projectId);
        
        // Update local cache with remote data, but preserve items with pending local changes
        for (final remoteModel in remoteModels) {
          final localModel = await _localDatasource.getById(remoteModel.id);
          
          // Only update if local doesn't have pending changes
          if (localModel == null || !localModel.needsSync) {
            remoteModel.needsSync = false;
            await _localDatasource.upsert(remoteModel);
          }
          // If local has pending changes (needsSync=true), keep local version
        }
        
        // Return from local (which now has merged data)
        return _getFromLocalByProjectId(projectId, includeDeleted: includeDeleted);
      } catch (e) {
        debugPrint('Failed to fetch tasks from remote, falling back to local: $e');
        // Fall back to local on error
        return _getFromLocalByProjectId(projectId, includeDeleted: includeDeleted);
      }
    } else {
      // When offline, read from local
      return _getFromLocalByProjectId(projectId, includeDeleted: includeDeleted);
    }
  }

  Future<List<Task>> _getFromLocalByProjectId(String projectId, {bool includeDeleted = false}) async {
    final models = await _localDatasource.getByProjectId(projectId, includeDeleted: includeDeleted);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<Task?> getTaskById(String id) async {
    if (_isOnline) {
      try {
        // Check if local has pending changes first
        final localModel = await _localDatasource.getById(id);
        
        // If local has pending changes, return local version
        if (localModel != null && localModel.needsSync) {
          return localModel.toEntity();
        }
        
        // Otherwise, fetch from remote and update local cache
        final remoteModel = await _remoteDatasource.getById(id);
        if (remoteModel != null) {
          remoteModel.needsSync = false;
          await _localDatasource.upsert(remoteModel);
          return remoteModel.toEntity();
        }
        
        // If not on remote but exists locally, return local
        return localModel?.toEntity();
      } catch (e) {
        debugPrint('Failed to fetch task from remote, falling back to local: $e');
        // Fall back to local on error
        final localModel = await _localDatasource.getById(id);
        return localModel?.toEntity();
      }
    } else {
      // When offline, read from local
      final localModel = await _localDatasource.getById(id);
      return localModel?.toEntity();
    }
  }

  @override
  Future<Task> createTask(Task task) async {
    final now = DateTime.now();
    final updatedTask = task.copyWith(
      id: task.id.isEmpty ? const Uuid().v4() : task.id,
      createdAt: task.createdAt,
      updatedAt: now,
    );

    if (_isOnline) {
      try {
        // When online, create on remote first
        final model = TaskModel.fromEntity(updatedTask, needsSync: false);
        final createdModel = await _remoteDatasource.create(model);
        
        // Update local cache with synced data
        createdModel.needsSync = false;
        await _localDatasource.upsert(createdModel);
        
        return createdModel.toEntity();
      } catch (e) {
        debugPrint('Failed to create task on remote, saving locally: $e');
        // Fall back to local with sync flag
        return _createLocally(updatedTask, needsSync: true);
      }
    } else {
      // When offline, save to local with sync flag
      return _createLocally(updatedTask, needsSync: true);
    }
  }

  Future<Task> _createLocally(Task task, {required bool needsSync}) async {
    final model = TaskModel.fromEntity(task, needsSync: needsSync);
    await _localDatasource.upsert(model);
    return task;
  }

  @override
  Future<Task> updateTask(Task task) async {
    final now = DateTime.now();
    final updatedTask = task.copyWith(updatedAt: now);

    if (_isOnline) {
      try {
        // When online, update on remote first
        final model = TaskModel.fromEntity(updatedTask, needsSync: false);
        final updatedModel = await _remoteDatasource.update(model);
        
        // Update local cache with synced data
        updatedModel.needsSync = false;
        await _localDatasource.upsert(updatedModel);
        
        return updatedModel.toEntity();
      } catch (e) {
        debugPrint('Failed to update task on remote, saving locally: $e');
        // Fall back to local with sync flag
        return _updateLocally(updatedTask, needsSync: true);
      }
    } else {
      // When offline, save to local with sync flag
      return _updateLocally(updatedTask, needsSync: true);
    }
  }

  Future<Task> _updateLocally(Task task, {required bool needsSync}) async {
    final model = TaskModel.fromEntity(task, needsSync: needsSync);
    await _localDatasource.upsert(model);
    return task;
  }

  @override
  Future<void> deleteTask(String id) async {
    if (_isOnline) {
      try {
        // When online, get the task first
        final task = await getTaskById(id);
        if (task != null) {
          final deletedTask = task.copyWith(
            isDeleted: true,
            updatedAt: DateTime.now(),
          );
          // Update on remote (soft delete)
          await updateTask(deletedTask);
        }
      } catch (e) {
        debugPrint('Failed to delete task on remote, deleting locally: $e');
        // Fall back to local deletion
        await _localDatasource.delete(id);
      }
    } else {
      // When offline, mark for deletion locally
      final localModel = await _localDatasource.getById(id);
      if (localModel != null) {
        final deletedModel = localModel
          ..isDeleted = true
          ..updatedAt = DateTime.now()
          ..needsSync = true;
        await _localDatasource.upsert(deletedModel);
      }
    }
  }

  @override
  Stream<List<Task>> watchTasks({bool includeDeleted = false}) {
    // Always watch local database for real-time updates
    // Local is the source of truth for the UI
    return _localDatasource
        .watchAll(includeDeleted: includeDeleted)
        .map((models) => models.map((m) => m.toEntity()).toList());
  }

  @override
  Stream<List<Task>> watchTasksByProjectId(String projectId, {bool includeDeleted = false}) {
    // Always watch local database for real-time updates
    return _localDatasource
        .watchByProjectId(projectId, includeDeleted: includeDeleted)
        .map((models) => models.map((m) => m.toEntity()).toList());
  }
}

