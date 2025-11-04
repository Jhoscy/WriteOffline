import 'package:isar_community/isar.dart';
import '../../domain/entities/task.dart';
import 'project_model.dart';

part 'task_model.g.dart';

/// Isar model for Task with annotations for code generation
@collection
class TaskModel {
  Id get isarId => fastHash(id);

  @Index(unique: true)
  late String id;

  late String name;

  late String description;

  @Index()
  late DateTime? dueDate;

  @Index()
  late String projectId;

  @Index()
  late DateTime createdAt;

  @Index()
  late DateTime updatedAt;

  @Index()
  late bool isDeleted;

  @Index()
  late bool needsSync; // Flag to track if this needs to be synced to remote

  TaskModel();

  /// Convert from domain entity to data model
  factory TaskModel.fromEntity(Task task, {bool needsSync = false}) {
    return TaskModel()
      ..id = task.id
      ..name = task.name
      ..description = task.description
      ..dueDate = task.dueDate
      ..projectId = task.projectId
      ..createdAt = task.createdAt
      ..updatedAt = task.updatedAt
      ..isDeleted = task.isDeleted
      ..needsSync = needsSync;
  }

  /// Convert from data model to domain entity
  Task toEntity() {
    return Task(
      id: id,
      name: name,
      description: description,
      dueDate: dueDate,
      projectId: projectId,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isDeleted: isDeleted,
    );
  }

  /// Convert from Appwrite document
  factory TaskModel.fromAppwrite(Map<String, dynamic> doc, {bool needsSync = false}) {
    return TaskModel()
      ..id = doc['\$id'] as String
      ..name = doc['name'] as String
      ..description = doc['description'] as String
      ..dueDate = doc['dueDate'] != null ? DateTime.parse(doc['dueDate'] as String) : null
      ..projectId = doc['projectId'] as String
      ..createdAt = DateTime.parse(doc['createdAt'] as String)
      ..updatedAt = DateTime.parse(doc['updatedAt'] as String)
      ..isDeleted = doc['isDeleted'] as bool? ?? false
      ..needsSync = needsSync;
  }

  /// Convert to Appwrite document
  Map<String, dynamic> toAppwrite() {
    return {
      '\$id': id,
      'name': name,
      'description': description,
      'dueDate': dueDate?.toUtc().toIso8601String(),
      'projectId': projectId,
      'createdAt': createdAt.toUtc().toIso8601String(),
      'updatedAt': updatedAt.toUtc().toIso8601String(),
      'isDeleted': isDeleted,
    };
  }
}

