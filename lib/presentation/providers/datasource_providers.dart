import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../data/datasources/local/project_local_datasource.dart';
import '../../data/datasources/local/task_local_datasource.dart';
import '../../data/datasources/remote/appwrite_remote_datasource.dart';

/// Provider for Appwrite remote datasource
final appwriteRemoteDatasourceProvider = Provider<AppwriteRemoteDatasource>((ref) {
  final datasource = AppwriteRemoteDatasource(
    endpoint: dotenv.env['APPWRITE_ENDPOINT'] ?? '',
    projectId: dotenv.env['APPWRITE_PROJECT_ID'] ?? '',
    databaseId: dotenv.env['APPWRITE_DATABASE_ID'] ?? '',
    projectsCollectionId: dotenv.env['APPWRITE_PROJECTS_COLLECTION_ID'] ?? '',
    tasksCollectionId: dotenv.env['APPWRITE_TASKS_COLLECTION_ID'] ?? '',
  );
  
  // Initialize the datasource
  datasource.initialize();
  
  return datasource;
});

/// Provider for Project remote datasource
final projectRemoteDatasourceProvider = Provider((ref) {
  final appwrite = ref.watch(appwriteRemoteDatasourceProvider);
  return AppwriteProjectRemoteDatasource(appwrite);
});

/// Provider for Task remote datasource
final taskRemoteDatasourceProvider = Provider((ref) {
  final appwrite = ref.watch(appwriteRemoteDatasourceProvider);
  return AppwriteTaskRemoteDatasource(appwrite);
});

/// Provider for Project local datasource
final projectLocalDatasourceProvider = Provider((ref) {
  return ProjectLocalDatasource();
});

/// Provider for Task local datasource
final taskLocalDatasourceProvider = Provider((ref) {
  return TaskLocalDatasource();
});

