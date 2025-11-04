import 'package:isar_community/isar.dart';
import '../../domain/entities/project.dart';

part 'project_model.g.dart';

/// Isar model for Project with annotations for code generation
@collection
class ProjectModel {
  Id get isarId => fastHash(id);

  @Index(unique: true)
  late String id;

  late String projectName;

  late String description;

  @Index()
  late DateTime? startDate;

  late DateTime? endDate;

  late double budget;

  @Index()
  late String status;

  @Index()
  late DateTime createdAt;

  @Index()
  late DateTime updatedAt;

  @Index()
  late bool isDeleted;

  @Index()
  late bool needsSync; // Flag to track if this needs to be synced to remote

  ProjectModel();

  /// Convert from domain entity to data model
  factory ProjectModel.fromEntity(Project project, {bool needsSync = false}) {
    return ProjectModel()
      ..id = project.id
      ..projectName = project.projectName
      ..description = project.description
      ..startDate = project.startDate
      ..endDate = project.endDate
      ..budget = project.budget
      ..status = project.status
      ..createdAt = project.createdAt
      ..updatedAt = project.updatedAt
      ..isDeleted = project.isDeleted
      ..needsSync = needsSync;
  }

  /// Convert from data model to domain entity
  Project toEntity() {
    return Project(
      id: id,
      projectName: projectName,
      description: description,
      startDate: startDate,
      endDate: endDate,
      budget: budget,
      status: status,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isDeleted: isDeleted,
    );
  }

  /// Convert from Appwrite document
  factory ProjectModel.fromAppwrite(Map<String, dynamic> doc, {bool needsSync = false}) {
    return ProjectModel()
      ..id = doc['\$id'] as String
      ..projectName = doc['projectName'] as String
      ..description = doc['description'] as String
      ..startDate = doc['startDate'] != null ? DateTime.parse(doc['startDate'] as String) : null
      ..endDate = doc['endDate'] != null ? DateTime.parse(doc['endDate'] as String) : null
      ..budget = (doc['budget'] as num).toDouble()
      ..status = doc['status'] as String
      ..createdAt = DateTime.parse(doc['createdAt'] as String)
      ..updatedAt = DateTime.parse(doc['updatedAt'] as String)
      ..isDeleted = doc['isDeleted'] as bool? ?? false
      ..needsSync = needsSync;
  }

  /// Convert to Appwrite document
  Map<String, dynamic> toAppwrite() {
    return {
      '\$id': id,
      'projectName': projectName,
      'description': description,
      'startDate': startDate?.toUtc().toIso8601String(),
      'endDate': endDate?.toUtc().toIso8601String(),
      'budget': budget,
      'status': status,
      'createdAt': createdAt.toUtc().toIso8601String(),
      'updatedAt': updatedAt.toUtc().toIso8601String(),
      'isDeleted': isDeleted,
    };
  }
}

/// Fast hash function for generating Isar IDs from strings
int fastHash(String string) {
  var hash = 0xcbf29ce484222325;
  var i = 0;
  while (i < string.length) {
    final codeUnit = string.codeUnitAt(i++);
    hash ^= codeUnit >> 8;
    hash *= 0x100000001b3;
    hash ^= codeUnit & 0xFF;
    hash *= 0x100000001b3;
  }
  return hash;
}

