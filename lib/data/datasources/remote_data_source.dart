import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task_model.dart';

abstract class RemoteDataSource {
  Future<List<TaskModel>> getTasks();
  Future<void> addTask(TaskModel task);
  Future<void> updateTask(TaskModel task);
  Future<void> deleteTask(String taskId);
}

class RemoteDataSourceImpl implements RemoteDataSource {
  final FirebaseFirestore firestore;

  RemoteDataSourceImpl({required this.firestore});

  @override
  Future<List<TaskModel>> getTasks() async {
    final snapshot = await firestore.collection('tasks').get();
    return snapshot.docs.map((doc) => TaskModel.fromFirestore(doc.data(), doc.id)).toList();
  }

  @override
  Future<void> addTask(TaskModel task) async {
    await firestore.collection('tasks').doc(task.id).set(task.toFirestore());
  }

  @override
  Future<void> updateTask(TaskModel task) async {
    await firestore.collection('tasks').doc(task.id).update(task.toFirestore());
  }

  @override
  Future<void> deleteTask(String taskId) async {
    await firestore.collection('tasks').doc(taskId).delete();
  }
}
