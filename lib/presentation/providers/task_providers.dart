import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/task.dart';
import 'repository_providers.dart';

/// Provider for watching all tasks
final tasksProvider = StreamProvider<List<Task>>((ref) {
  final repository = ref.watch(taskRepositoryProvider);
  return repository.watchTasks();
});

/// Provider for watching tasks by project ID
final tasksByProjectIdProvider = StreamProvider.family<List<Task>, String>((ref, projectId) {
  final repository = ref.watch(taskRepositoryProvider);
  return repository.watchTasksByProjectId(projectId);
});

/// Provider for getting a specific task by ID
final taskByIdProvider = FutureProvider.family<Task?, String>((ref, id) async {
  final repository = ref.watch(taskRepositoryProvider);
  return repository.getTaskById(id);
});

/// Notifier for task operations
class TaskNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() {
    return const AsyncValue.data(null);
  }

  /// Create a new task
  Future<void> createTask({
    required String name,
    required String description,
    DateTime? dueDate,
    required String projectId,
  }) async {
    state = const AsyncValue.loading();
    
    try {
      final repository = ref.read(taskRepositoryProvider);
      final now = DateTime.now();
      
      final task = Task(
        id: const Uuid().v4(),
        name: name,
        description: description,
        dueDate: dueDate,
        projectId: projectId,
        createdAt: now,
        updatedAt: now,
      );
      
      await repository.createTask(task);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Update an existing task
  Future<void> updateTask(Task task) async {
    state = const AsyncValue.loading();
    
    try {
      final repository = ref.read(taskRepositoryProvider);
      await repository.updateTask(task);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Delete a task (logical deletion)
  Future<void> deleteTask(String id) async {
    state = const AsyncValue.loading();
    
    try {
      final repository = ref.read(taskRepositoryProvider);
      await repository.deleteTask(id);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

/// Provider for task notifier
final taskNotifierProvider = NotifierProvider<TaskNotifier, AsyncValue<void>>(() {
  return TaskNotifier();
});

