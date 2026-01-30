// lib/data/models/task_model.dart
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:myday_ai/domain/entities/task_entity.dart';

part 'task_model.g.dart';

@HiveType(typeId: 1)
class TaskModel {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String title;
  
  @HiveField(2)
  final String? description;
  
  @HiveField(3)
  final DateTime dueDate;
  
  @HiveField(4)
  final TaskPriority priority;
  
  @HiveField(5)
  final bool isCompleted;
  
  @HiveField(6)
  final DateTime createdAt;
  
  @HiveField(7)
  final String? planId;
  
  @HiveField(8)
  final DateTime? completedAt;
  
  @HiveField(9)
  final List<String> tags;

  TaskModel({
    String? id,
    required this.title,
    this.description,
    required this.dueDate,
    required this.priority,
    this.isCompleted = false,
    DateTime? createdAt,
    this.planId,
    this.completedAt,
    this.tags = const [],
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  // Convert to Entity
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
      completedAt: completedAt,
      tags: tags,
    );
  }

  // Convert from Entity
  factory TaskModel.fromEntity(TaskEntity entity) {
    return TaskModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      dueDate: entity.dueDate,
      priority: entity.priority,
      isCompleted: entity.isCompleted,
      createdAt: entity.createdAt,
      planId: entity.planId,
      completedAt: entity.completedAt,
      tags: entity.tags,
    );
  }

  // Copy with method for immutability
  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    TaskPriority? priority,
    bool? isCompleted,
    DateTime? createdAt,
    String? planId,
    DateTime? completedAt,
    List<String>? tags,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      planId: planId ?? this.planId,
      completedAt: completedAt ?? this.completedAt,
      tags: tags ?? this.tags,
    );
  }

  // Mark as completed
  TaskModel markAsCompleted() {
    return copyWith(
      isCompleted: true,
      completedAt: DateTime.now(),
    );
  }

  // Mark as incomplete
  TaskModel markAsIncomplete() {
    return copyWith(
      isCompleted: false,
      completedAt: null,
    );
  }

  // Update priority
  TaskModel updatePriority(TaskPriority newPriority) {
    return copyWith(priority: newPriority);
  }

  // Update due date
  TaskModel updateDueDate(DateTime newDueDate) {
    return copyWith(dueDate: newDueDate);
  }

  // Add tag
  TaskModel addTag(String tag) {
    return copyWith(tags: [...tags, tag]);
  }

  // Remove tag
  TaskModel removeTag(String tag) {
    return copyWith(tags: tags.where((t) => t != tag).toList());
  }

  // Check if task is overdue
  bool get isOverdue {
    return !isCompleted && dueDate.isBefore(DateTime.now());
  }

  // Check if task is due today
  bool get isDueToday {
    final now = DateTime.now();
    return dueDate.year == now.year &&
        dueDate.month == now.month &&
        dueDate.day == now.day;
  }

  // Get formatted due date string
  String get formattedDueDate {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDate = DateTime(dueDate.year, dueDate.month, dueDate.day);

    if (taskDate == today) {
      return 'Today';
    } else if (taskDate == today.add(const Duration(days: 1))) {
      return 'Tomorrow';
    } else if (taskDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else {
      return '${dueDate.day}/${dueDate.month}/${dueDate.year}';
    }
  }

  // Get priority color index
  int get priorityColorIndex {
    switch (priority) {
      case TaskPriority.high:
        return 0;
      case TaskPriority.medium:
        return 1;
      case TaskPriority.low:
        return 2;
    }
  }

  // Get priority string
  String get priorityString {
    switch (priority) {
      case TaskPriority.high:
        return 'High';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.low:
        return 'Low';
    }
  }

  // Get priority emoji
  String get priorityEmoji {
    switch (priority) {
      case TaskPriority.high:
        return '🔴';
      case TaskPriority.medium:
        return '🟡';
      case TaskPriority.low:
        return '🟢';
    }
  }

  // Convert to map for JSON serialization
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'priority': priority.index,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
      'planId': planId,
      'completedAt': completedAt?.toIso8601String(),
      'tags': tags,
    };
  }

  // Create from map
  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      dueDate: DateTime.parse(map['dueDate'] as String),
      priority: TaskPriority.values[map['priority'] as int],
      isCompleted: map['isCompleted'] as bool,
      createdAt: DateTime.parse(map['createdAt'] as String),
      planId: map['planId'] as String?,
      completedAt: map['completedAt'] != null
          ? DateTime.parse(map['completedAt'] as String)
          : null,
      tags: List<String>.from(map['tags'] as List),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TaskModel &&
        other.id == id &&
        other.title == title &&
        other.description == description &&
        other.dueDate == dueDate &&
        other.priority == priority &&
        other.isCompleted == isCompleted &&
        other.createdAt == createdAt &&
        other.planId == planId &&
        other.completedAt == completedAt &&
        other.tags == tags;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      title,
      description,
      dueDate,
      priority,
      isCompleted,
      createdAt,
      planId,
      completedAt,
      tags,
    );
  }

  @override
  String toString() {
    return 'TaskModel(id: $id, title: $title, priority: $priority, isCompleted: $isCompleted, dueDate: $dueDate)';
  }
}

@HiveType(typeId: 2)
enum TaskPriority {
  @HiveField(0)
  low,
  
  @HiveField(1)
  medium,
  
  @HiveField(2)
  high,
}

// Helper extension for TaskPriority
extension TaskPriorityExtension on TaskPriority {
  String get name {
    switch (this) {
      case TaskPriority.low:
        return 'low';
      case TaskPriority.medium:
        return 'medium';
      case TaskPriority.high:
        return 'high';
    }
  }

  static TaskPriority fromName(String name) {
    switch (name.toLowerCase()) {
      case 'high':
        return TaskPriority.high;
      case 'medium':
        return TaskPriority.medium;
      case 'low':
        return TaskPriority.low;
      default:
        return TaskPriority.medium;
    }
  }

  // For UI display
  String get displayName {
    switch (this) {
      case TaskPriority.low:
        return 'Low';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.high:
        return 'High';
    }
  }

  // Color values for UI
  int get colorValue {
    switch (this) {
      case TaskPriority.low:
        return 0xFF4CAF50; // Green
      case TaskPriority.medium:
        return 0xFFFF9800; // Orange
      case TaskPriority.high:
        return 0xFFF44336; // Red
    }
  }

  // Icon data for UI
  String get icon {
    switch (this) {
      case TaskPriority.low:
        return '📌';
      case TaskPriority.medium:
        return '📍';
      case TaskPriority.high:
        return '🚨';
    }
  }
}

// Extension for List<TaskModel>
extension TaskModelListExtension on List<TaskModel> {
  List<TaskModel> get sortedByDueDate {
    return List.from(this)
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }

  List<TaskModel> get sortedByPriority {
    return List.from(this)
      ..sort((a, b) => b.priority.index.compareTo(a.priority.index));
  }

  List<TaskModel> get sortedByCreationDate {
    return List.from(this)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  List<TaskModel> get completed {
    return where((task) => task.isCompleted).toList();
  }

  List<TaskModel> get pending {
    return where((task) => !task.isCompleted).toList();
  }

  List<TaskModel> get overdue {
    return where((task) => task.isOverdue).toList();
  }

  List<TaskModel> get dueToday {
    return where((task) => task.isDueToday).toList();
  }

  List<TaskModel> get highPriority {
    return where((task) => task.priority == TaskPriority.high).toList();
  }

  List<TaskModel> get mediumPriority {
    return where((task) => task.priority == TaskPriority.medium).toList();
  }

  List<TaskModel> get lowPriority {
    return where((task) => task.priority == TaskPriority.low).toList();
  }

  Map<String, List<TaskModel>> groupByDate() {
    final Map<String, List<TaskModel>> grouped = {};
    
    for (final task in this) {
      final dateKey = '${task.dueDate.year}-${task.dueDate.month}-${task.dueDate.day}';
      grouped.putIfAbsent(dateKey, () => []).add(task);
    }
    
    return grouped;
  }
}
