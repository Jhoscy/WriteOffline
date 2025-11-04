import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/project_repository_impl.dart';
import '../../data/repositories/task_repository_impl.dart';
import '../../data/repositories/project_hybrid_repository.dart';
import '../../data/repositories/task_hybrid_repository.dart';
import 'datasource_providers.dart';
import 'service_providers.dart';

/// Provider for local Project repository (legacy - kept for backwards compatibility)
final projectLocalRepositoryProvider = Provider((ref) {
  final localDatasource = ref.watch(projectLocalDatasourceProvider);
  return ProjectLocalRepositoryImpl(localDatasource);
});

/// Provider for remote Project repository (legacy - kept for backwards compatibility)
final projectRemoteRepositoryProvider = Provider((ref) {
  final remoteDatasource = ref.watch(projectRemoteDatasourceProvider);
  return ProjectRemoteRepositoryImpl(remoteDatasource);
});

/// Provider for hybrid Project repository (auto-syncs when online)
final projectRepositoryProvider = Provider((ref) {
  final localDatasource = ref.watch(projectLocalDatasourceProvider);
  final remoteDatasource = ref.watch(projectRemoteDatasourceProvider);
  final connectivityService = ref.watch(connectivityServiceProvider);
  
  return ProjectHybridRepository(
    localDatasource: localDatasource,
    remoteDatasource: remoteDatasource,
    connectivityService: connectivityService,
  );
});

/// Provider for local Task repository (legacy - kept for backwards compatibility)
final taskLocalRepositoryProvider = Provider((ref) {
  final localDatasource = ref.watch(taskLocalDatasourceProvider);
  return TaskLocalRepositoryImpl(localDatasource);
});

/// Provider for remote Task repository (legacy - kept for backwards compatibility)
final taskRemoteRepositoryProvider = Provider((ref) {
  final remoteDatasource = ref.watch(taskRemoteDatasourceProvider);
  return TaskRemoteRepositoryImpl(remoteDatasource);
});

/// Provider for hybrid Task repository (auto-syncs when online)
final taskRepositoryProvider = Provider((ref) {
  final localDatasource = ref.watch(taskLocalDatasourceProvider);
  final remoteDatasource = ref.watch(taskRemoteDatasourceProvider);
  final connectivityService = ref.watch(connectivityServiceProvider);
  
  return TaskHybridRepository(
    localDatasource: localDatasource,
    remoteDatasource: remoteDatasource,
    connectivityService: connectivityService,
  );
});

