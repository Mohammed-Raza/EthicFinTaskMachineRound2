import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/task_entity.dart';

part 'task_model.g.dart';

@JsonSerializable()
class TaskModel extends TaskEntity {
  @JsonKey(fromJson: _boolFromInt, toJson: _boolToInt)
  @override
  final bool isCompleted;

  @JsonKey(fromJson: _boolFromInt, toJson: _boolToInt)
  @override
  final bool isSynced;

  const TaskModel({
    required super.id,
    required super.title,
    required super.description,
    required super.priority,
    required super.dueDate,
    this.isCompleted = false,
    required super.createdAt,
    super.updatedAt,
    this.isSynced = false,
  }) : super(isCompleted: isCompleted, isSynced: isSynced);

  factory TaskModel.fromJson(Map<String, dynamic> json) => _$TaskModelFromJson(json);

  Map<String, dynamic> toJson() => _$TaskModelToJson(this);

  static bool _boolFromInt(dynamic value) {
    if (value is bool) return value;
    if (value is int) return value == 1;
    return false;
  }

  static int _boolToInt(bool value) => value ? 1 : 0;

  factory TaskModel.fromFirestore(Map<String, dynamic> json, String docId) {
    return TaskModel(
      id: docId,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      priority: TaskPriority.values.firstWhere(
        (e) => e.toString() == json['priority'],
        orElse: () => TaskPriority.low,
      ),
      dueDate: json['dueDate'] != null ? (json['dueDate'] as dynamic).toDate() : DateTime.now(),
      isCompleted: json['isCompleted'] ?? false,
      createdAt: json['createdAt'] != null ? (json['createdAt'] as dynamic).toDate() : DateTime.now(),
      updatedAt: json['updatedAt'] != null ? (json['updatedAt'] as dynamic).toDate() : null,
      isSynced: true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'priority': priority.toString(),
      'dueDate': dueDate,
      'isCompleted': isCompleted,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  @override
  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    TaskPriority? priority,
    DateTime? dueDate,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  factory TaskModel.fromEntity(TaskEntity entity) {
    return TaskModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      priority: entity.priority,
      dueDate: entity.dueDate,
      isCompleted: entity.isCompleted,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      isSynced: entity.isSynced,
    );
  }
}
