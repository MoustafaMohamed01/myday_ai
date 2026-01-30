import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:myday_ai/data/models/task_model.dart';
import 'package:myday_ai/data/models/event_model.dart';
import 'package:myday_ai/data/models/plan_model.dart';

class DatabaseService {
  static Isar? _isar;

  Future<Isar> get isar async {
    if (_isar != null) return _isar!;
    
    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open(
      [TaskModelSchema, EventModelSchema, PlanModelSchema],
      directory: dir.path,
    );
    return _isar!;
  }
}

final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService();
});