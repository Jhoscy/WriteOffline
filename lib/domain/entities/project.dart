import 'package:equatable/equatable.dart';

/// Domain entity for Project
/// This represents the business logic model, independent of any framework
class Project extends Equatable {
  final String id;
  final String projectName;
  final String description;
  final DateTime? startDate;
  final DateTime? endDate;
  final double budget;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted; // For logical deletion

  const Project({
    required this.id,
    required this.projectName,
    required this.description,
    this.startDate,
    this.endDate,
    required this.budget,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.isDeleted = false,
  });

  Project copyWith({
    String? id,
    String? projectName,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    double? budget,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
  }) {
    return Project(
      id: id ?? this.id,
      projectName: projectName ?? this.projectName,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      budget: budget ?? this.budget,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  @override
  List<Object?> get props => [
        id,
        projectName,
        description,
        startDate,
        endDate,
        budget,
        status,
        createdAt,
        updatedAt,
        isDeleted,
      ];
}

