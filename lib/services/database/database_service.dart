// lib/services/database/database_service.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:myday_ai/data/models/task_model.dart';
import 'package:myday_ai/data/models/event_model.dart';
import 'package:myday_ai/data/models/plan_model.dart';

class DatabaseService {
  static const String tasksBox = 'tasks';
  static const String eventsBox = 'events';
  static const String plansBox = 'plans';

  Future<void> init() async {
    final appDir = await getApplicationDocumentsDirectory();
    Hive.init(appDir.path);
    
    // Register adapters
    Hive.registerAdapter(TaskModelAdapter());
    Hive.registerAdapter(TaskPriorityAdapter());
    Hive.registerAdapter(EventModelAdapter());
    Hive.registerAdapter(PlanModelAdapter());
    
    // Open boxes
    await Hive.openBox<TaskModel>(tasksBox);
    await Hive.openBox<EventModel>(eventsBox);
    await Hive.openBox<PlanModel>(plansBox);
  }

  Box<TaskModel> get tasksBoxInstance => Hive.box<TaskModel>(tasksBox);
  Box<EventModel> get eventsBoxInstance => Hive.box<EventModel>(eventsBox);
  Box<PlanModel> get plansBoxInstance => Hive.box<PlanModel>(plansBox);
}

final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService();
});
