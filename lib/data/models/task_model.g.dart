// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaskModel _$TaskModelFromJson(Map<String, dynamic> json) => TaskModel(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  priority: $enumDecode(_$TaskPriorityEnumMap, json['priority']),
  dueDate: DateTime.parse(json['dueDate'] as String),
  isCompleted: json['isCompleted'] == null
      ? false
      : TaskModel._boolFromInt(json['isCompleted']),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
  isSynced: json['isSynced'] == null
      ? false
      : TaskModel._boolFromInt(json['isSynced']),
);

Map<String, dynamic> _$TaskModelToJson(TaskModel instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'priority': _$TaskPriorityEnumMap[instance.priority]!,
  'dueDate': instance.dueDate.toIso8601String(),
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
  'isCompleted': TaskModel._boolToInt(instance.isCompleted),
  'isSynced': TaskModel._boolToInt(instance.isSynced),
};

const _$TaskPriorityEnumMap = {
  TaskPriority.low: 'TaskPriority.low',
  TaskPriority.medium: 'TaskPriority.medium',
  TaskPriority.high: 'TaskPriority.high',
};
