import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task_model.dart';

abstract class RemoteDataSource {
  Future<List<TaskModel>> getTasks(String userId);
  Future<void> addTask(String userId, TaskModel task);
  Future<void> updateTask(String userId, TaskModel task);
  Future<void> deleteTask(String userId, String taskId);
}

class RemoteDataSourceImpl implements RemoteDataSource {
  final FirebaseFirestore firestore;

  RemoteDataSourceImpl({required this.firestore});

  CollectionReference _userTasks(String userId) => 
      firestore.collection('users').doc(userId).collection('tasks');

  @override
  Future<List<TaskModel>> getTasks(String userId) async {
    final snapshot = await _userTasks(userId).get();
    return snapshot.docs.map((doc) => TaskModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id)).toList();
  }

  @override
  Future<void> addTask(String userId, TaskModel task) async {
    await _userTasks(userId).doc(task.id).set(task.toFirestore());
  }

  @override
  Future<void> updateTask(String userId, TaskModel task) async {
    await _userTasks(userId).doc(task.id).update(task.toFirestore());
  }

  @override
  Future<void> deleteTask(String userId, String taskId) async {
    await _userTasks(userId).doc(taskId).delete();
  }
}
