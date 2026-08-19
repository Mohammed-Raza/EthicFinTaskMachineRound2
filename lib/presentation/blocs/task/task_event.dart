part of 'task_bloc.dart';

abstract class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object?> get props => [];
}

class LoadTasks extends TaskEvent {}

class AddTask extends TaskEvent {
  final TaskEntity task;
  const AddTask(this.task);

  @override
  List<Object?> get props => [task];
}

class UpdateTask extends TaskEvent {
  final TaskEntity task;
  const UpdateTask(this.task);

  @override
  List<Object?> get props => [task];
}

class DeleteTask extends TaskEvent {
  final String taskId;
  const DeleteTask(this.taskId);

  @override
  List<Object?> get props => [taskId];
}

class ToggleTaskCompletion extends TaskEvent {
  final TaskEntity task;
  const ToggleTaskCompletion(this.task);

  @override
  List<Object?> get props => [task];
}

class SearchTasks extends TaskEvent {
  final String query;
  const SearchTasks(this.query);

  @override
  List<Object?> get props => [query];
}

class FilterTasks extends TaskEvent {
  final String filter; // 'All', 'Completed', 'Pending'
  const FilterTasks(this.filter);

  @override
  List<Object?> get props => [filter];
}

class SortTasks extends TaskEvent {
  final String sortBy; // 'Due Date', 'Priority'
  const SortTasks(this.sortBy);

  @override
  List<Object?> get props => [sortBy];
}

class SyncTasks extends TaskEvent {}
