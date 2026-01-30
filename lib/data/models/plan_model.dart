// lib/data/models/plan_model.dart
import 'package:isar/isar.dart';
import 'package:myday_ai/domain/entities/plan_entity.dart';

part 'plan_model.g.dart';

@collection
class PlanModel {
  Id id = Isar.autoIncrement;
  
  @Index()
  late String title;
  
  String? description;
  
  DateTime createdAt = DateTime.now();
  
  List<String> taskIds = [];
  List<String> eventIds = [];
  
  PlanEntity toEntity() {
    return PlanEntity(
      id: id,
      title: title,
      description: description,
      createdAt: createdAt,
      taskIds: taskIds,
      eventIds: eventIds,
    );
  }
  
  factory PlanModel.fromEntity(PlanEntity entity) {
    return PlanModel()
      ..id = entity.id
      ..title = entity.title
      ..description = entity.description
      ..createdAt = entity.createdAt
      ..taskIds = entity.taskIds
      ..eventIds = entity.eventIds;
  }
}