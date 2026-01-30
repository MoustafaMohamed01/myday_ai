// lib/data/models/task_model.dart
import 'package:isar/isar.dart';
import 'package:myday_ai/domain/entities/task_entity.dart';

part 'task_model.g.dart';

@collection
class TaskModel {
  Id id = Isar.autoIncrement;
  
  @Index()
  late String title;
  
  String? description;
  
  @Index()
  late DateTime dueDate;
  
  @Index()
  late TaskPriority priority;
  
  @Index()
  late bool isCompleted;
  
  DateTime createdAt = DateTime.now();
  
  String? planId;
  
  TaskEntity toEntity() {
    return TaskEntity(
      id: id,
      title: title,
      description: description,
      dueDate: dueDate,
      priority: priority,
      isCompleted: isCompleted,
      createdAt: createdAt,
      planId: planId,
    );
  }
  
  factory TaskModel.fromEntity(TaskEntity entity) {
    return TaskModel()
      ..id = entity.id
      ..title = entity.title
      ..description = entity.description
      ..dueDate = entity.dueDate
      ..priority = entity.priority
      ..isCompleted = entity.isCompleted
      ..createdAt = entity.createdAt
      ..planId = entity.planId;
  }
}

enum TaskPriority {
  low,
  medium,
  high,
}