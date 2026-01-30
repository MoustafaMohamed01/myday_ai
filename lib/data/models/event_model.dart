// lib/data/models/event_model.dart
import 'package:isar/isar.dart';
import 'package:myday_ai/domain/entities/event_entity.dart';

part 'event_model.g.dart';

@collection
class EventModel {
  Id id = Isar.autoIncrement;
  
  @Index()
  late String title;
  
  String? description;
  
  @Index()
  late DateTime startTime;
  
  @Index()
  late DateTime endTime;
  
  bool isAllDay = false;
  
  DateTime createdAt = DateTime.now();
  
  String? planId;
  
  EventEntity toEntity() {
    return EventEntity(
      id: id,
      title: title,
      description: description,
      startTime: startTime,
      endTime: endTime,
      isAllDay: isAllDay,
      createdAt: createdAt,
      planId: planId,
    );
  }
  
  factory EventModel.fromEntity(EventEntity entity) {
    return EventModel()
      ..id = entity.id
      ..title = entity.title
      ..description = entity.description
      ..startTime = entity.startTime
      ..endTime = entity.endTime
      ..isAllDay = entity.isAllDay
      ..createdAt = entity.createdAt
      ..planId = entity.planId;
  }
}