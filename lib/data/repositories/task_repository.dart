// lib/data/repositories/task_repository.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:myday_ai/data/models/task_model.dart';
import 'package:myday_ai/domain/entities/task_entity.dart';
import 'package:myday_ai/domain/repositories/task_repository_interface.dart';
import 'package:myday_ai/services/database/database_service.dart';

class TaskRepository implements TaskRepositoryInterface {
  final DatabaseService _databaseService;

  TaskRepository(this._databaseService);

  @override
  Future<int> createTask(TaskEntity task) async {
    final isar = await _databaseService.isar;
    final taskModel = TaskModel.fromEntity(task);
    await isar.writeTxn(() async {
      await isar.taskModels.put(taskModel);
    });
    return taskModel.id;
  }

  @override
  Future<List<TaskEntity>> getTasks({
    String? filter,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    final isar = await _databaseService.isar;
    QueryBuilder<TaskModel> query = isar.taskModels.where();

    if (filter == 'today') {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));
      query = query.filter().dueDateBetween(startOfDay, endOfDay);
    } else if (filter == 'upcoming') {
      final now = DateTime.now();
      query = query.filter().dueDateGreaterThan(now);
    } else if (fromDate != null && toDate != null) {
      query = query.filter().dueDateBetween(fromDate, toDate);
    }

    final tasks = await query.findAll();
    return tasks.map((model) => model.toEntity()).toList();
  }

  @override
  Future<void> updateTask(TaskEntity task) async {
    final isar = await _databaseService.isar;
    final taskModel = TaskModel.fromEntity(task);
    await isar.writeTxn(() async {
      await isar.taskModels.put(taskModel);
    });
  }

  @override
  Future<void> deleteTask(int id) async {
    final isar = await _databaseService.isar;
    await isar.writeTxn(() async {
      await isar.taskModels.delete(id);
    });
  }

  @override
  Future<void> toggleTaskCompletion(int id, bool isCompleted) async {
    final isar = await _databaseService.isar;
    final task = await isar.taskModels.get(id);
    if (task != null) {
      task.isCompleted = isCompleted;
      await isar.writeTxn(() async {
        await isar.taskModels.put(task);
      });
    }
  }
}

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  final databaseService = ref.watch(databaseServiceProvider);
  return TaskRepository(databaseService);
});