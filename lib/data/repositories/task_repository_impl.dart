import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/local_data_source.dart';
import '../datasources/remote_data_source.dart';
import '../models/task_model.dart';

class TaskRepositoryImpl implements TaskRepository {
  final LocalDataSource localDataSource;
  final RemoteDataSource remoteDataSource;
  final Connectivity connectivity;

  final _taskStreamController = StreamController<List<TaskEntity>>.broadcast();

  TaskRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.connectivity,
  });

  @override
  Future<List<TaskEntity>> getTasks(String userId) async {
    final localTasks = await localDataSource.getTasks();
    _taskStreamController.add(localTasks);
    
    final connectionStatus = await connectivity.checkConnectivity();
    if (!connectionStatus.contains(ConnectivityResult.none)) {
      try {
        final remoteTasks = await remoteDataSource.getTasks(userId);
        for (var task in remoteTasks) {
          await localDataSource.cacheTask(task);
        }
        final updatedLocalTasks = await localDataSource.getTasks();
        _taskStreamController.add(updatedLocalTasks);
        return updatedLocalTasks;
      } catch (e) {
        // Handle error or just return local tasks
      }
    }
    return localTasks;
  }

  @override
  Future<void> addTask(String userId, TaskEntity task) async {
    final taskModel = TaskModel.fromEntity(task);
    await localDataSource.cacheTask(taskModel);
    _emitLocalTasks();

    final connectionStatus = await connectivity.checkConnectivity();
    if (!connectionStatus.contains(ConnectivityResult.none)) {
      try {
        await remoteDataSource.addTask(userId, taskModel);
        await localDataSource.markAsSynced(task.id);
        _emitLocalTasks();
      } catch (e) {
        // Will sync later
      }
    }
  }

  @override
  Future<void> updateTask(String userId, TaskEntity task) async {
    final taskModel = TaskModel.fromEntity(task).copyWith(isSynced: false);
    await localDataSource.cacheTask(taskModel);
    _emitLocalTasks();

    final connectionStatus = await connectivity.checkConnectivity();
    if (!connectionStatus.contains(ConnectivityResult.none)) {
      try {
        await remoteDataSource.updateTask(userId, taskModel);
        await localDataSource.markAsSynced(task.id);
        _emitLocalTasks();
      } catch (e) {
        // Will sync later
      }
    }
  }

  @override
  Future<void> deleteTask(String userId, String taskId) async {
    await localDataSource.deleteTask(taskId);
    _emitLocalTasks();

    final connectionStatus = await connectivity.checkConnectivity();
    if (!connectionStatus.contains(ConnectivityResult.none)) {
      try {
        await remoteDataSource.deleteTask(userId, taskId);
      } catch (e) {
        // Handle error
      }
    }
  }

  @override
  Stream<List<TaskEntity>> watchTasks(String userId) {
    getTasks(userId); // Initial fetch
    return _taskStreamController.stream;
  }

  Future<void> _emitLocalTasks() async {
    final tasks = await localDataSource.getTasks();
    _taskStreamController.add(tasks);
  }

  @override
  Future<void> syncTasks(String userId) async {
    final connectionStatus = await connectivity.checkConnectivity();
    if (connectionStatus.contains(ConnectivityResult.none)) return;

    final unsyncedTasks = await localDataSource.getUnsyncedTasks();
    for (var task in unsyncedTasks) {
      try {
        await remoteDataSource.addTask(userId, task);
        await localDataSource.markAsSynced(task.id);
      } catch (e) {
        // Continue with others
      }
    }
    _emitLocalTasks();
  }
}
