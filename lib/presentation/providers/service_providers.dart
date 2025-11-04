import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/connectivity_service.dart';
import '../../core/services/sync_orchestrator.dart';
import 'datasource_providers.dart';

/// Provider for connectivity service
final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  final service = ConnectivityService();
  service.initialize();
  
  ref.onDispose(() {
    service.dispose();
  });
  
  return service;
});

/// Provider for sync orchestrator
final syncOrchestratorProvider = Provider<SyncOrchestrator>((ref) {
  final projectLocalDatasource = ref.watch(projectLocalDatasourceProvider);
  final projectRemoteDatasource = ref.watch(projectRemoteDatasourceProvider);
  final taskLocalDatasource = ref.watch(taskLocalDatasourceProvider);
  final taskRemoteDatasource = ref.watch(taskRemoteDatasourceProvider);
  final connectivityService = ref.watch(connectivityServiceProvider);
  
  final orchestrator = SyncOrchestrator(
    projectLocalDatasource: projectLocalDatasource,
    projectRemoteDatasource: projectRemoteDatasource,
    taskLocalDatasource: taskLocalDatasource,
    taskRemoteDatasource: taskRemoteDatasource,
    connectivityService: connectivityService,
  );
  
  orchestrator.initialize();
  
  ref.onDispose(() {
    orchestrator.dispose();
  });
  
  return orchestrator;
});

/// Provider for connectivity status
final connectivityStatusProvider = StreamProvider<bool>((ref) {
  final service = ref.watch(connectivityServiceProvider);
  return service.onConnectivityChanged;
});

/// Provider for sync status
final syncStatusProvider = StreamProvider<SyncStatus>((ref) {
  final orchestrator = ref.watch(syncOrchestratorProvider);
  return orchestrator.onSyncStatusChanged;
});

