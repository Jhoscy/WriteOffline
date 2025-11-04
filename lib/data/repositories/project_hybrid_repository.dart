import 'package:flutter/foundation.dart';
import '../../core/services/connectivity_service.dart';
import '../../domain/entities/project.dart';
import '../../domain/repositories/project_repository.dart';
import '../datasources/local/project_local_datasource.dart';
import '../datasources/remote/project_remote_datasource.dart';
import '../models/project_model.dart';
import 'package:uuid/uuid.dart';

/// Hybrid repository that automatically syncs based on connectivity
/// - When online: writes to remote + local cache, reads from remote
/// - When offline: writes to local with sync flag, reads from local
class ProjectHybridRepository implements ProjectRepository {
  final ProjectLocalDatasource _localDatasource;
  final ProjectRemoteDatasource _remoteDatasource;
  final ConnectivityService _connectivityService;

  ProjectHybridRepository({
    required ProjectLocalDatasource localDatasource,
    required ProjectRemoteDatasource remoteDatasource,
    required ConnectivityService connectivityService,
  })  : _localDatasource = localDatasource,
        _remoteDatasource = remoteDatasource,
        _connectivityService = connectivityService;

  bool get _isOnline => _connectivityService.isConnected;

  @override
  Future<List<Project>> getAllProjects({bool includeDeleted = false}) async {
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
        debugPrint('Failed to fetch from remote, falling back to local: $e');
        // Fall back to local on error
        return _getFromLocal(includeDeleted: includeDeleted);
      }
    } else {
      // When offline, read from local
      return _getFromLocal(includeDeleted: includeDeleted);
    }
  }

  Future<List<Project>> _getFromLocal({bool includeDeleted = false}) async {
    final models = await _localDatasource.getAll(includeDeleted: includeDeleted);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<Project?> getProjectById(String id) async {
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
        debugPrint('Failed to fetch project from remote, falling back to local: $e');
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
  Future<Project> createProject(Project project) async {
    final now = DateTime.now();
    final updatedProject = project.copyWith(
      id: project.id.isEmpty ? const Uuid().v4() : project.id,
      createdAt: project.createdAt,
      updatedAt: now,
    );

    if (_isOnline) {
      try {
        // When online, create on remote first
        final model = ProjectModel.fromEntity(updatedProject, needsSync: false);
        final createdModel = await _remoteDatasource.create(model);
        
        // Update local cache with synced data
        createdModel.needsSync = false;
        await _localDatasource.upsert(createdModel);
        
        return createdModel.toEntity();
      } catch (e) {
        debugPrint('Failed to create on remote, saving locally: $e');
        // Fall back to local with sync flag
        return _createLocally(updatedProject, needsSync: true);
      }
    } else {
      // When offline, save to local with sync flag
      return _createLocally(updatedProject, needsSync: true);
    }
  }

  Future<Project> _createLocally(Project project, {required bool needsSync}) async {
    final model = ProjectModel.fromEntity(project, needsSync: needsSync);
    await _localDatasource.upsert(model);
    return project;
  }

  @override
  Future<Project> updateProject(Project project) async {
    final now = DateTime.now();
    final updatedProject = project.copyWith(updatedAt: now);

    if (_isOnline) {
      try {
        // When online, update on remote first
        final model = ProjectModel.fromEntity(updatedProject, needsSync: false);
        final updatedModel = await _remoteDatasource.update(model);
        
        // Update local cache with synced data
        updatedModel.needsSync = false;
        await _localDatasource.upsert(updatedModel);
        
        return updatedModel.toEntity();
      } catch (e) {
        debugPrint('Failed to update on remote, saving locally: $e');
        // Fall back to local with sync flag
        return _updateLocally(updatedProject, needsSync: true);
      }
    } else {
      // When offline, save to local with sync flag
      return _updateLocally(updatedProject, needsSync: true);
    }
  }

  Future<Project> _updateLocally(Project project, {required bool needsSync}) async {
    final model = ProjectModel.fromEntity(project, needsSync: needsSync);
    await _localDatasource.upsert(model);
    return project;
  }

  @override
  Future<void> deleteProject(String id) async {
    if (_isOnline) {
      try {
        // When online, get the project first
        final project = await getProjectById(id);
        if (project != null) {
          final deletedProject = project.copyWith(
            isDeleted: true,
            updatedAt: DateTime.now(),
          );
          // Update on remote (soft delete)
          await updateProject(deletedProject);
        }
      } catch (e) {
        debugPrint('Failed to delete on remote, deleting locally: $e');
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
  Stream<List<Project>> watchProjects({bool includeDeleted = false}) {
    // Always watch local database for real-time updates
    // Local is the source of truth for the UI
    return _localDatasource
        .watchAll(includeDeleted: includeDeleted)
        .map((models) => models.map((m) => m.toEntity()).toList());
  }
}

