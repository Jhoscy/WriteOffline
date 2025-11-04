import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../../models/project_model.dart';
import '../../models/task_model.dart';

/// Manages Isar database instance and initialization
class IsarLocalDatasource {
  static Isar? _isar;

  /// Get the Isar instance, initializing if necessary
  static Future<Isar> getIsar() async {
    if (_isar != null && _isar!.isOpen) {
      return _isar!;
    }

    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open(
      [ProjectModelSchema, TaskModelSchema],
      directory: dir.path,
      name: 'writeoffline',
    );

    return _isar!;
  }

  /// Close the Isar instance
  static Future<void> close() async {
    if (_isar != null && _isar!.isOpen) {
      await _isar!.close();
      _isar = null;
    }
  }
}

