// lib/domain/entities/task_entity.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'task_entity.freezed.dart';

@freezed
class TaskEntity with _$TaskEntity {
  const factory TaskEntity({
    required String id,
    required String title,
    String? description,
    required DateTime dueDate,
    required TaskPriority priority,
    required bool isCompleted,
    required DateTime createdAt,
    String? planId,
    DateTime? completedAt,
    @Default([]) List<String> tags,
  }) = _TaskEntity;
}

enum TaskPriority {
  low,
  medium,
  high,
}
