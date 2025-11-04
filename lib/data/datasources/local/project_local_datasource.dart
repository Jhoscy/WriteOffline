import 'package:isar_community/isar.dart';
import '../../models/project_model.dart';
import 'isar_local_datasource.dart';

/// Local data source for Project using Isar
class ProjectLocalDatasource {
  /// Get all projects from local database
  Future<List<ProjectModel>> getAll({bool includeDeleted = false}) async {
    final isar = await IsarLocalDatasource.getIsar();
    
    if (includeDeleted) {
      return await isar.projectModels.where().findAll();
    } else {
      return await isar.projectModels
          .filter()
          .isDeletedEqualTo(false)
          .findAll();
    }
  }

  /// Get a single project by ID
  Future<ProjectModel?> getById(String id) async {
    final isar = await IsarLocalDatasource.getIsar();
    return await isar.projectModels
        .filter()
        .idEqualTo(id)
        .findFirst();
  }

  /// Insert or update a project
  Future<void> upsert(ProjectModel project) async {
    final isar = await IsarLocalDatasource.getIsar();
    await isar.writeTxn(() async {
      await isar.projectModels.put(project);
    });
  }

  /// Insert or update multiple projects
  Future<void> upsertAll(List<ProjectModel> projects) async {
    final isar = await IsarLocalDatasource.getIsar();
    await isar.writeTxn(() async {
      await isar.projectModels.putAll(projects);
    });
  }

  /// Delete a project (logical deletion)
  Future<void> delete(String id) async {
    final project = await getById(id);
    
    if (project != null) {
      project.isDeleted = true;
      project.updatedAt = DateTime.now();
      project.needsSync = true;
      await upsert(project);
    }
  }

  /// Get all projects that need syncing
  Future<List<ProjectModel>> getNeedsSync() async {
    final isar = await IsarLocalDatasource.getIsar();
    return await isar.projectModels
        .filter()
        .needsSyncEqualTo(true)
        .findAll();
  }

  /// Mark a project as synced
  Future<void> markAsSynced(String id) async {
    final project = await getById(id);
    
    if (project != null) {
      project.needsSync = false;
      await upsert(project);
    }
  }

  /// Watch all projects as a stream
  Stream<List<ProjectModel>> watchAll({bool includeDeleted = false}) async* {
    final isar = await IsarLocalDatasource.getIsar();
    
    if (includeDeleted) {
      yield* isar.projectModels.where().watch(fireImmediately: true);
    } else {
      yield* isar.projectModels
          .filter()
          .isDeletedEqualTo(false)
          .watch(fireImmediately: true);
    }
  }

  /// Clear all projects (for testing purposes)
  Future<void> clearAll() async {
    final isar = await IsarLocalDatasource.getIsar();
    await isar.writeTxn(() async {
      await isar.projectModels.clear();
    });
  }
}

