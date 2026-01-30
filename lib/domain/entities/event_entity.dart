// lib/domain/entities/event_entity.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'event_entity.freezed.dart';

@freezed
class EventEntity with _$EventEntity {
  factory EventEntity({
    required int id,
    required String title,
    String? description,
    required DateTime startTime,
    required DateTime endTime,
    required bool isAllDay,
    required DateTime createdAt,
    String? planId,
  }) = _EventEntity;
}