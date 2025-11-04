import 'package:appwrite/appwrite.dart';
import '../../models/project_model.dart';
import '../../models/task_model.dart';
import 'project_remote_datasource.dart';
import 'task_remote_datasource.dart';
import 'remote_datasource.dart';

/// Appwrite implementation of remote data source
class AppwriteRemoteDatasource implements RemoteDataSource {
  late Client _client;
  late TablesDB _tables;
  
  final String endpoint;
  final String projectId;
  final String databaseId;
  final String projectsCollectionId;
  final String tasksCollectionId;

  AppwriteRemoteDatasource({
    required this.endpoint,
    required this.projectId,
    required this.databaseId,
    required this.projectsCollectionId,
    required this.tasksCollectionId,
  });

  @override
  Future<void> initialize() async {
    _client = Client()
        .setEndpoint(endpoint)
        .setProject(projectId);
    
    _tables = TablesDB(_client);
  }

  @override
  Future<bool> isAvailable() async {
    try {
      // Try to list rows to check connectivity
      await _tables.listRows(
        databaseId: databaseId,
        tableId: projectsCollectionId,
        queries: [Query.limit(1)],
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  TablesDB get tables => _tables;
}

/// Appwrite implementation for Project remote operations
class AppwriteProjectRemoteDatasource implements ProjectRemoteDatasource {
  final AppwriteRemoteDatasource _appwrite;

  AppwriteProjectRemoteDatasource(this._appwrite);

  @override
  Future<List<ProjectModel>> getAll() async {
    try {
      final response = await _appwrite.tables.listRows(
        databaseId: _appwrite.databaseId,
        tableId: _appwrite.projectsCollectionId,
        queries: [
          Query.limit(100),
          Query.orderDesc('updatedAt'),
        ],
      );

      return response.rows
          .map((row) => ProjectModel.fromAppwrite(row.data))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch projects from remote: $e');
    }
  }

  @override
  Future<ProjectModel?> getById(String id) async {
    try {
      final row = await _appwrite.tables.getRow(
        databaseId: _appwrite.databaseId,
        tableId: _appwrite.projectsCollectionId,
        rowId: id,
      );

      return ProjectModel.fromAppwrite(row.data);
    } catch (e) {
      if (e is AppwriteException && e.code == 404) {
        return null;
      }
      throw Exception('Failed to fetch project by ID from remote: $e');
    }
  }

  @override
  Future<ProjectModel> create(ProjectModel project) async {
    try {
      final data = project.toAppwrite();
      final row = await _appwrite.tables.createRow(
        databaseId: _appwrite.databaseId,
        tableId: _appwrite.projectsCollectionId,
        rowId: project.id,
        data: data,
      );

      return ProjectModel.fromAppwrite(row.data);
    } catch (e) {
      throw Exception('Failed to create project on remote: $e');
    }
  }

  @override
  Future<ProjectModel> update(ProjectModel project) async {
    try {
      final data = project.toAppwrite();
      final row = await _appwrite.tables.updateRow(
        databaseId: _appwrite.databaseId,
        tableId: _appwrite.projectsCollectionId,
        rowId: project.id,
        data: data,
      );

      return ProjectModel.fromAppwrite(row.data);
    } catch (e) {
      // If row doesn't exist, create it
      if (e is AppwriteException && e.code == 404) {
        return await create(project);
      }
      throw Exception('Failed to update project on remote: $e');
    }
  }

  @override
  Future<List<ProjectModel>> getUpdatedAfter(DateTime timestamp) async {
    try {
      final response = await _appwrite.tables.listRows(
        databaseId: _appwrite.databaseId,
        tableId: _appwrite.projectsCollectionId,
        queries: [
          Query.greaterThan('updatedAt', timestamp.toIso8601String()),
          Query.limit(100),
          Query.orderDesc('updatedAt'),
        ],
      );

      return response.rows
          .map((row) => ProjectModel.fromAppwrite(row.data))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch updated projects from remote: $e');
    }
  }
}

/// Appwrite implementation for Task remote operations
class AppwriteTaskRemoteDatasource implements TaskRemoteDatasource {
  final AppwriteRemoteDatasource _appwrite;

  AppwriteTaskRemoteDatasource(this._appwrite);

  @override
  Future<List<TaskModel>> getAll() async {
    try {
      final response = await _appwrite.tables.listRows(
        databaseId: _appwrite.databaseId,
        tableId: _appwrite.tasksCollectionId,
        queries: [
          Query.limit(100),
          Query.orderDesc('updatedAt'),
        ],
      );

      return response.rows
          .map((row) => TaskModel.fromAppwrite(row.data))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch tasks from remote: $e');
    }
  }

  @override
  Future<List<TaskModel>> getByProjectId(String projectId) async {
    try {
      final response = await _appwrite.tables.listRows(
        databaseId: _appwrite.databaseId,
        tableId: _appwrite.tasksCollectionId,
        queries: [
          Query.equal('projectId', projectId),
          Query.limit(100),
          Query.orderDesc('updatedAt'),
        ],
      );

      return response.rows
          .map((row) => TaskModel.fromAppwrite(row.data))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch tasks by project ID from remote: $e');
    }
  }

  @override
  Future<TaskModel?> getById(String id) async {
    try {
      final row = await _appwrite.tables.getRow(
        databaseId: _appwrite.databaseId,
        tableId: _appwrite.tasksCollectionId,
        rowId: id,
      );

      return TaskModel.fromAppwrite(row.data);
    } catch (e) {
      if (e is AppwriteException && e.code == 404) {
        return null;
      }
      throw Exception('Failed to fetch task by ID from remote: $e');
    }
  }

  @override
  Future<TaskModel> create(TaskModel task) async {
    try {
      final data = task.toAppwrite();
      final row = await _appwrite.tables.createRow(
        databaseId: _appwrite.databaseId,
        tableId: _appwrite.tasksCollectionId,
        rowId: task.id,
        data: data,
      );

      return TaskModel.fromAppwrite(row.data);
    } catch (e) {
      throw Exception('Failed to create task on remote: $e');
    }
  }

  @override
  Future<TaskModel> update(TaskModel task) async {
    try {
      final data = task.toAppwrite();
      final row = await _appwrite.tables.updateRow(
        databaseId: _appwrite.databaseId,
        tableId: _appwrite.tasksCollectionId,
        rowId: task.id,
        data: data,
      );

      return TaskModel.fromAppwrite(row.data);
    } catch (e) {
      // If row doesn't exist, create it
      if (e is AppwriteException && e.code == 404) {
        return await create(task);
      }
      throw Exception('Failed to update task on remote: $e');
    }
  }

  @override
  Future<List<TaskModel>> getUpdatedAfter(DateTime timestamp) async {
    try {
      final response = await _appwrite.tables.listRows(
        databaseId: _appwrite.databaseId,
        tableId: _appwrite.tasksCollectionId,
        queries: [
          Query.greaterThan('updatedAt', timestamp.toIso8601String()),
          Query.limit(100),
          Query.orderDesc('updatedAt'),
        ],
      );

      return response.rows
          .map((row) => TaskModel.fromAppwrite(row.data))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch updated tasks from remote: $e');
    }
  }
}

