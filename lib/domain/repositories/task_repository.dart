import '../entities/task_entity.dart';

abstract class TaskRepository {
  Future<List<TaskEntity>> getTasks(String userId);
  Future<void> addTask(String userId, TaskEntity task);
  Future<void> updateTask(String userId, TaskEntity task);
  Future<void> deleteTask(String userId, String taskId);
  Stream<List<TaskEntity>> watchTasks(String userId);
  Future<void> syncTasks(String userId);
}
