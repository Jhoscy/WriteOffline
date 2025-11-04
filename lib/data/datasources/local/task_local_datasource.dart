import 'package:isar_community/isar.dart';
import '../../models/task_model.dart';
import 'isar_local_datasource.dart';

/// Local data source for Task using Isar
class TaskLocalDatasource {
  /// Get all tasks from local database
  Future<List<TaskModel>> getAll({bool includeDeleted = false}) async {
    final isar = await IsarLocalDatasource.getIsar();
    
    if (includeDeleted) {
      return await isar.taskModels.where().findAll();
    } else {
      return await isar.taskModels
          .filter()
          .isDeletedEqualTo(false)
          .findAll();
    }
  }

  /// Get all tasks for a specific project
  Future<List<TaskModel>> getByProjectId(String projectId, {bool includeDeleted = false}) async {
    final isar = await IsarLocalDatasource.getIsar();
    
    if (includeDeleted) {
      return await isar.taskModels
          .filter()
          .projectIdEqualTo(projectId)
          .findAll();
    } else {
      return await isar.taskModels
          .filter()
          .projectIdEqualTo(projectId)
          .and()
          .isDeletedEqualTo(false)
          .findAll();
    }
  }

  /// Get a single task by ID
  Future<TaskModel?> getById(String id) async {
    final isar = await IsarLocalDatasource.getIsar();
    return await isar.taskModels
        .filter()
        .idEqualTo(id)
        .findFirst();
  }

  /// Insert or update a task
  Future<void> upsert(TaskModel task) async {
    final isar = await IsarLocalDatasource.getIsar();
    await isar.writeTxn(() async {
      await isar.taskModels.put(task);
    });
  }

  /// Insert or update multiple tasks
  Future<void> upsertAll(List<TaskModel> tasks) async {
    final isar = await IsarLocalDatasource.getIsar();
    await isar.writeTxn(() async {
      await isar.taskModels.putAll(tasks);
    });
  }

  /// Delete a task (logical deletion)
  Future<void> delete(String id) async {
    final task = await getById(id);
    
    if (task != null) {
      task.isDeleted = true;
      task.updatedAt = DateTime.now();
      task.needsSync = true;
      await upsert(task);
    }
  }

  /// Get all tasks that need syncing
  Future<List<TaskModel>> getNeedsSync() async {
    final isar = await IsarLocalDatasource.getIsar();
    return await isar.taskModels
        .filter()
        .needsSyncEqualTo(true)
        .findAll();
  }

  /// Mark a task as synced
  Future<void> markAsSynced(String id) async {
    final task = await getById(id);
    
    if (task != null) {
      task.needsSync = false;
      await upsert(task);
    }
  }

  /// Watch all tasks as a stream
  Stream<List<TaskModel>> watchAll({bool includeDeleted = false}) async* {
    final isar = await IsarLocalDatasource.getIsar();
    
    if (includeDeleted) {
      yield* isar.taskModels.where().watch(fireImmediately: true);
    } else {
      yield* isar.taskModels
          .filter()
          .isDeletedEqualTo(false)
          .watch(fireImmediately: true);
    }
  }

  /// Watch tasks for a specific project as a stream
  Stream<List<TaskModel>> watchByProjectId(String projectId, {bool includeDeleted = false}) async* {
    final isar = await IsarLocalDatasource.getIsar();
    
    if (includeDeleted) {
      yield* isar.taskModels
          .filter()
          .projectIdEqualTo(projectId)
          .watch(fireImmediately: true);
    } else {
      yield* isar.taskModels
          .filter()
          .projectIdEqualTo(projectId)
          .and()
          .isDeletedEqualTo(false)
          .watch(fireImmediately: true);
    }
  }

  /// Clear all tasks (for testing purposes)
  Future<void> clearAll() async {
    final isar = await IsarLocalDatasource.getIsar();
    await isar.writeTxn(() async {
      await isar.taskModels.clear();
    });
  }
}

