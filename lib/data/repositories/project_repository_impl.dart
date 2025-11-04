import '../../domain/entities/project.dart';
import '../../domain/repositories/project_repository.dart';
import '../datasources/local/project_local_datasource.dart';
import '../datasources/remote/project_remote_datasource.dart';
import '../models/project_model.dart';
import 'package:uuid/uuid.dart';

/// Implementation of ProjectRepository for local operations
class ProjectLocalRepositoryImpl implements ProjectRepository {
  final ProjectLocalDatasource _localDatasource;

  ProjectLocalRepositoryImpl(this._localDatasource);

  @override
  Future<List<Project>> getAllProjects({bool includeDeleted = false}) async {
    final models = await _localDatasource.getAll(includeDeleted: includeDeleted);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<Project?> getProjectById(String id) async {
    final model = await _localDatasource.getById(id);
    return model?.toEntity();
  }

  @override
  Future<Project> createProject(Project project) async {
    final now = DateTime.now();
    final updatedProject = project.copyWith(
      id: project.id.isEmpty ? const Uuid().v4() : project.id,
      createdAt: project.createdAt,
      updatedAt: now,
    );
    
    final model = ProjectModel.fromEntity(updatedProject, needsSync: true);
    await _localDatasource.upsert(model);
    return updatedProject;
  }

  @override
  Future<Project> updateProject(Project project) async {
    final now = DateTime.now();
    final updatedProject = project.copyWith(updatedAt: now);
    
    final model = ProjectModel.fromEntity(updatedProject, needsSync: true);
    await _localDatasource.upsert(model);
    return updatedProject;
  }

  @override
  Future<void> deleteProject(String id) async {
    await _localDatasource.delete(id);
  }

  @override
  Stream<List<Project>> watchProjects({bool includeDeleted = false}) {
    return _localDatasource
        .watchAll(includeDeleted: includeDeleted)
        .map((models) => models.map((m) => m.toEntity()).toList());
  }
}

/// Implementation of ProjectRepository for remote operations
class ProjectRemoteRepositoryImpl implements ProjectRepository {
  final ProjectRemoteDatasource _remoteDatasource;

  ProjectRemoteRepositoryImpl(this._remoteDatasource);

  @override
  Future<List<Project>> getAllProjects({bool includeDeleted = false}) async {
    final models = await _remoteDatasource.getAll();
    final filtered = includeDeleted 
        ? models 
        : models.where((m) => !m.isDeleted).toList();
    return filtered.map((m) => m.toEntity()).toList();
  }

  @override
  Future<Project?> getProjectById(String id) async {
    final model = await _remoteDatasource.getById(id);
    return model?.toEntity();
  }

  @override
  Future<Project> createProject(Project project) async {
    final now = DateTime.now();
    final updatedProject = project.copyWith(
      id: project.id.isEmpty ? const Uuid().v4() : project.id,
      createdAt: project.createdAt,
      updatedAt: now,
    );
    
    final model = ProjectModel.fromEntity(updatedProject);
    final createdModel = await _remoteDatasource.create(model);
    return createdModel.toEntity();
  }

  @override
  Future<Project> updateProject(Project project) async {
    final now = DateTime.now();
    final updatedProject = project.copyWith(updatedAt: now);
    
    final model = ProjectModel.fromEntity(updatedProject);
    final updatedModel = await _remoteDatasource.update(model);
    return updatedModel.toEntity();
  }

  @override
  Future<void> deleteProject(String id) async {
    final project = await getProjectById(id);
    if (project != null) {
      final deletedProject = project.copyWith(
        isDeleted: true,
        updatedAt: DateTime.now(),
      );
      await updateProject(deletedProject);
    }
  }

  @override
  Stream<List<Project>> watchProjects({bool includeDeleted = false}) {
    // Remote doesn't support real-time watching in this implementation
    // Return a stream with initial data
    return Stream.fromFuture(getAllProjects(includeDeleted: includeDeleted));
  }
}

