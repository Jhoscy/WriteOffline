import 'package:equatable/equatable.dart';

/// Domain entity for Task
/// This represents the business logic model, independent of any framework
class Task extends Equatable {
  final String id;
  final String name;
  final String description;
  final DateTime? dueDate;
  final String projectId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted; // For logical deletion

  const Task({
    required this.id,
    required this.name,
    required this.description,
    this.dueDate,
    required this.projectId,
    required this.createdAt,
    required this.updatedAt,
    this.isDeleted = false,
  });

  Task copyWith({
    String? id,
    String? name,
    String? description,
    DateTime? dueDate,
    String? projectId,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
  }) {
    return Task(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      projectId: projectId ?? this.projectId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        dueDate,
        projectId,
        createdAt,
        updatedAt,
        isDeleted,
      ];
}

