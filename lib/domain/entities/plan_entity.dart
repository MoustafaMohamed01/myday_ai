// lib/domain/entities/plan_entity.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'plan_entity.freezed.dart';

@freezed
class PlanEntity with _$PlanEntity {
  factory PlanEntity({
    required int id,
    required String title,
    String? description,
    required DateTime createdAt,
    required List<String> taskIds,
    required List<String> eventIds,
  }) = _PlanEntity;
}