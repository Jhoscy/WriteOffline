import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../data/datasources/local/project_local_datasource.dart';
import '../../data/datasources/local/task_local_datasource.dart';
import '../../data/datasources/remote/project_remote_datasource.dart';
import '../../data/datasources/remote/task_remote_datasource.dart';
import 'connectivity_service.dart';

/// Orchestrator for managing offline-first sync with LWW conflict resolution
class SyncOrchestrator {
  final ProjectLocalDatasource _projectLocalDatasource;
  final ProjectRemoteDatasource _projectRemoteDatasource;
  final TaskLocalDatasource _taskLocalDatasource;
  final TaskRemoteDatasource _taskRemoteDatasource;
  final ConnectivityService _connectivityService;

  StreamSubscription<bool>? _connectivitySubscription;
  Timer? _periodicSyncTimer;
  
  bool _isSyncing = false;
  DateTime? _lastSyncTime;

  final StreamController<SyncStatus> _syncStatusController = 
      StreamController<SyncStatus>.broadcast();

  /// Stream of sync status changes
  Stream<SyncStatus> get onSyncStatusChanged => _syncStatusController.stream;

  /// Get last sync time
  DateTime? get lastSyncTime => _lastSyncTime;

  /// Check if currently syncing
  bool get isSyncing => _isSyncing;

  SyncOrchestrator({
    required ProjectLocalDatasource projectLocalDatasource,
    required ProjectRemoteDatasource projectRemoteDatasource,
    required TaskLocalDatasource taskLocalDatasource,
    required TaskRemoteDatasource taskRemoteDatasource,
    required ConnectivityService connectivityService,
  })  : _projectLocalDatasource = projectLocalDatasource,
        _projectRemoteDatasource = projectRemoteDatasource,
        _taskLocalDatasource = taskLocalDatasource,
        _taskRemoteDatasource = taskRemoteDatasource,
        _connectivityService = connectivityService;

  /// Initialize the sync orchestrator
  void initialize() {
    // Listen to connectivity changes
    _connectivitySubscription = 
        _connectivityService.onConnectivityChanged.listen((isConnected) {
      if (isConnected) {
        // Trigger sync when connection is restored
        sync();
      }
    });

    // Setup periodic sync (every 5 minutes when connected)
    _periodicSyncTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      if (_connectivityService.isConnected && !_isSyncing) {
        sync();
      }
    });

    // Initial sync if connected
    if (_connectivityService.isConnected) {
      sync();
    }
  }

  /// Perform full synchronization
  Future<void> sync() async {
    if (_isSyncing || !_connectivityService.isConnected) {
      return;
    }

    _isSyncing = true;
    _syncStatusController.add(SyncStatus.syncing);

    try {
      // Phase 1: Push local changes to remote
      await _pushLocalChanges();

      // Phase 2: Pull remote changes to local
      await _pullRemoteChanges();

      _lastSyncTime = DateTime.now();
      _syncStatusController.add(SyncStatus.success);
    } catch (e) {
      _syncStatusController.add(SyncStatus.error);
      debugPrint('Sync error: $e');
    } finally {
      _isSyncing = false;
    }
  }

  /// Push local changes (that need sync) to remote
  Future<void> _pushLocalChanges() async {
    // Push projects
    final projectsToSync = await _projectLocalDatasource.getNeedsSync();
    for (final project in projectsToSync) {
      try {
        // Deletions always win - push to remote immediately
        if (project.isDeleted) {
          await _projectRemoteDatasource.update(project);
          await _projectLocalDatasource.markAsSynced(project.id);
          continue;
        }
        
        // Check if remote has a newer version for non-deleted items
        final remoteProject = await _projectRemoteDatasource.getById(project.id);
        
        if (remoteProject == null || 
            _shouldLocalWin(project.updatedAt, remoteProject.updatedAt)) {
          // Local wins or doesn't exist on remote, push to remote
          await _projectRemoteDatasource.update(project);
        } else {
          // Remote wins, update local with remote version
          final updatedLocal = remoteProject..needsSync = false;
          await _projectLocalDatasource.upsert(updatedLocal);
        }
        
        // Mark as synced
        await _projectLocalDatasource.markAsSynced(project.id);
      } catch (e) {
        debugPrint('Error syncing project ${project.id}: $e');
      }
    }

    // Push tasks
    final tasksToSync = await _taskLocalDatasource.getNeedsSync();
    for (final task in tasksToSync) {
      try {
        // Deletions always win - push to remote immediately
        if (task.isDeleted) {
          await _taskRemoteDatasource.update(task);
          await _taskLocalDatasource.markAsSynced(task.id);
          continue;
        }
        
        // Check if remote has a newer version for non-deleted items
        final remoteTask = await _taskRemoteDatasource.getById(task.id);
        
        if (remoteTask == null || 
            _shouldLocalWin(task.updatedAt, remoteTask.updatedAt)) {
          // Local wins or doesn't exist on remote, push to remote
          await _taskRemoteDatasource.update(task);
        } else {
          // Remote wins, update local with remote version
          final updatedLocal = remoteTask..needsSync = false;
          await _taskLocalDatasource.upsert(updatedLocal);
        }
        
        // Mark as synced
        await _taskLocalDatasource.markAsSynced(task.id);
      } catch (e) {
        debugPrint('Error syncing task ${task.id}: $e');
      }
    }
  }

  /// Pull remote changes and merge with local using LWW
  Future<void> _pullRemoteChanges() async {
    try {
      // Pull projects
      final remoteProjects = await _projectRemoteDatasource.getAll();
      for (final remoteProject in remoteProjects) {
        final localProject = await _projectLocalDatasource.getById(remoteProject.id);
        
        if (localProject == null) {
          // Doesn't exist locally, add it
          remoteProject.needsSync = false;
          await _projectLocalDatasource.upsert(remoteProject);
        } else if (!localProject.needsSync) {
          // Local doesn't need sync, apply LWW
          if (_shouldRemoteWin(localProject.updatedAt, remoteProject.updatedAt)) {
            remoteProject.needsSync = false;
            await _projectLocalDatasource.upsert(remoteProject);
          }
        }
        // If local needs sync, we already handled it in push phase
      }

      // Pull tasks
      final remoteTasks = await _taskRemoteDatasource.getAll();
      for (final remoteTask in remoteTasks) {
        final localTask = await _taskLocalDatasource.getById(remoteTask.id);
        
        if (localTask == null) {
          // Doesn't exist locally, add it
          remoteTask.needsSync = false;
          await _taskLocalDatasource.upsert(remoteTask);
        } else if (!localTask.needsSync) {
          // Local doesn't need sync, apply LWW
          if (_shouldRemoteWin(localTask.updatedAt, remoteTask.updatedAt)) {
            remoteTask.needsSync = false;
            await _taskLocalDatasource.upsert(remoteTask);
          }
        }
        // If local needs sync, we already handled it in push phase
      }
    } catch (e) {
      debugPrint('Error pulling remote changes: $e');
      rethrow;
    }
  }

  /// LWW: Determine if local should win based on timestamp
  bool _shouldLocalWin(DateTime localTime, DateTime remoteTime) {
    return localTime.isAfter(remoteTime) || localTime.isAtSameMomentAs(remoteTime);
  }

  /// LWW: Determine if remote should win based on timestamp
  bool _shouldRemoteWin(DateTime localTime, DateTime remoteTime) {
    return remoteTime.isAfter(localTime);
  }

  /// Force a manual sync
  Future<void> forceSyncNow() async {
    if (!_connectivityService.isConnected) {
      throw Exception('Cannot sync while offline');
    }
    await sync();
  }

  /// Dispose resources
  void dispose() {
    _connectivitySubscription?.cancel();
    _periodicSyncTimer?.cancel();
    _syncStatusController.close();
  }
}

/// Sync status enumeration
enum SyncStatus {
  idle,
  syncing,
  success,
  error,
}

