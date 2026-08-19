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
  }) {
    connectivity.onConnectivityChanged.listen((status) {
      if (!status.contains(ConnectivityResult.none)) {
        syncTasks();
      }
    });
  }

  @override
  Future<List<TaskEntity>> getTasks() async {
    final localTasks = await localDataSource.getTasks();
    _taskStreamController.add(localTasks);
    
    final connectionStatus = await connectivity.checkConnectivity();
    if (!connectionStatus.contains(ConnectivityResult.none)) {
      try {
        final remoteTasks = await remoteDataSource.getTasks();
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
  Future<void> addTask(TaskEntity task) async {
    final taskModel = TaskModel.fromEntity(task);
    await localDataSource.cacheTask(taskModel);
    _emitLocalTasks();

    final connectionStatus = await connectivity.checkConnectivity();
    if (!connectionStatus.contains(ConnectivityResult.none)) {
      try {
        await remoteDataSource.addTask(taskModel);
        await localDataSource.markAsSynced(task.id);
        _emitLocalTasks();
      } catch (e) {
        // Will sync later
      }
    }
  }

  @override
  Future<void> updateTask(TaskEntity task) async {
    final taskModel = TaskModel.fromEntity(task).copyWith(isSynced: false);
    await localDataSource.cacheTask(taskModel);
    _emitLocalTasks();

    final connectionStatus = await connectivity.checkConnectivity();
    if (!connectionStatus.contains(ConnectivityResult.none)) {
      try {
        await remoteDataSource.updateTask(taskModel);
        await localDataSource.markAsSynced(task.id);
        _emitLocalTasks();
      } catch (e) {
        // Will sync later
      }
    }
  }

  @override
  Future<void> deleteTask(String taskId) async {
    await localDataSource.deleteTask(taskId);
    _emitLocalTasks();

    final connectionStatus = await connectivity.checkConnectivity();
    if (!connectionStatus.contains(ConnectivityResult.none)) {
      try {
        await remoteDataSource.deleteTask(taskId);
      } catch (e) {
        // Handle error
      }
    }
  }

  @override
  Stream<List<TaskEntity>> watchTasks() {
    getTasks(); // Initial fetch
    return _taskStreamController.stream;
  }

  Future<void> _emitLocalTasks() async {
    final tasks = await localDataSource.getTasks();
    _taskStreamController.add(tasks);
  }

  @override
  Future<void> syncTasks() async {
    final connectionStatus = await connectivity.checkConnectivity();
    if (connectionStatus.contains(ConnectivityResult.none)) return;

    final unsyncedTasks = await localDataSource.getUnsyncedTasks();
    for (var task in unsyncedTasks) {
      try {
        await remoteDataSource.addTask(task);
        await localDataSource.markAsSynced(task.id);
      } catch (e) {
        // Continue with others
      }
    }
    _emitLocalTasks();
  }
}
