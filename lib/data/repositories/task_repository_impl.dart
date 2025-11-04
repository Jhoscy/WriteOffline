import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/local/task_local_datasource.dart';
import '../datasources/remote/task_remote_datasource.dart';
import '../models/task_model.dart';
import 'package:uuid/uuid.dart';

/// Implementation of TaskRepository for local operations
class TaskLocalRepositoryImpl implements TaskRepository {
  final TaskLocalDatasource _localDatasource;

  TaskLocalRepositoryImpl(this._localDatasource);

  @override
  Future<List<Task>> getAllTasks({bool includeDeleted = false}) async {
    final models = await _localDatasource.getAll(includeDeleted: includeDeleted);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<Task>> getTasksByProjectId(String projectId, {bool includeDeleted = false}) async {
    final models = await _localDatasource.getByProjectId(projectId, includeDeleted: includeDeleted);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<Task?> getTaskById(String id) async {
    final model = await _localDatasource.getById(id);
    return model?.toEntity();
  }

  @override
  Future<Task> createTask(Task task) async {
    final now = DateTime.now();
    final updatedTask = task.copyWith(
      id: task.id.isEmpty ? const Uuid().v4() : task.id,
      createdAt: task.createdAt,
      updatedAt: now,
    );
    
    final model = TaskModel.fromEntity(updatedTask, needsSync: true);
    await _localDatasource.upsert(model);
    return updatedTask;
  }

  @override
  Future<Task> updateTask(Task task) async {
    final now = DateTime.now();
    final updatedTask = task.copyWith(updatedAt: now);
    
    final model = TaskModel.fromEntity(updatedTask, needsSync: true);
    await _localDatasource.upsert(model);
    return updatedTask;
  }

  @override
  Future<void> deleteTask(String id) async {
    await _localDatasource.delete(id);
  }

  @override
  Stream<List<Task>> watchTasks({bool includeDeleted = false}) {
    return _localDatasource
        .watchAll(includeDeleted: includeDeleted)
        .map((models) => models.map((m) => m.toEntity()).toList());
  }

  @override
  Stream<List<Task>> watchTasksByProjectId(String projectId, {bool includeDeleted = false}) {
    return _localDatasource
        .watchByProjectId(projectId, includeDeleted: includeDeleted)
        .map((models) => models.map((m) => m.toEntity()).toList());
  }
}

/// Implementation of TaskRepository for remote operations
class TaskRemoteRepositoryImpl implements TaskRepository {
  final TaskRemoteDatasource _remoteDatasource;

  TaskRemoteRepositoryImpl(this._remoteDatasource);

  @override
  Future<List<Task>> getAllTasks({bool includeDeleted = false}) async {
    final models = await _remoteDatasource.getAll();
    final filtered = includeDeleted 
        ? models 
        : models.where((m) => !m.isDeleted).toList();
    return filtered.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<Task>> getTasksByProjectId(String projectId, {bool includeDeleted = false}) async {
    final models = await _remoteDatasource.getByProjectId(projectId);
    final filtered = includeDeleted 
        ? models 
        : models.where((m) => !m.isDeleted).toList();
    return filtered.map((m) => m.toEntity()).toList();
  }

  @override
  Future<Task?> getTaskById(String id) async {
    final model = await _remoteDatasource.getById(id);
    return model?.toEntity();
  }

  @override
  Future<Task> createTask(Task task) async {
    final now = DateTime.now();
    final updatedTask = task.copyWith(
      id: task.id.isEmpty ? const Uuid().v4() : task.id,
      createdAt: task.createdAt,
      updatedAt: now,
    );
    
    final model = TaskModel.fromEntity(updatedTask);
    final createdModel = await _remoteDatasource.create(model);
    return createdModel.toEntity();
  }

  @override
  Future<Task> updateTask(Task task) async {
    final now = DateTime.now();
    final updatedTask = task.copyWith(updatedAt: now);
    
    final model = TaskModel.fromEntity(updatedTask);
    final updatedModel = await _remoteDatasource.update(model);
    return updatedModel.toEntity();
  }

  @override
  Future<void> deleteTask(String id) async {
    final task = await getTaskById(id);
    if (task != null) {
      final deletedTask = task.copyWith(
        isDeleted: true,
        updatedAt: DateTime.now(),
      );
      await updateTask(deletedTask);
    }
  }

  @override
  Stream<List<Task>> watchTasks({bool includeDeleted = false}) {
    // Remote doesn't support real-time watching in this implementation
    // Return a stream with initial data
    return Stream.fromFuture(getAllTasks(includeDeleted: includeDeleted));
  }

  @override
  Stream<List<Task>> watchTasksByProjectId(String projectId, {bool includeDeleted = false}) {
    // Remote doesn't support real-time watching in this implementation
    // Return a stream with initial data
    return Stream.fromFuture(getTasksByProjectId(projectId, includeDeleted: includeDeleted));
  }
}

