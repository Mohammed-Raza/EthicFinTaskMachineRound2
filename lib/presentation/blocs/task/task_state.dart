part of 'task_bloc.dart';

enum TaskStatus { initial, loading, success, failure }

class TaskState extends Equatable {
  final List<TaskEntity> allTasks;
  final List<TaskEntity> filteredTasks;
  final TaskStatus status;
  final String searchQuery;
  final String filter;
  final String sortBy;
  final String? errorMessage;

  const TaskState({
    this.allTasks = const [],
    this.filteredTasks = const [],
    this.status = TaskStatus.initial,
    this.searchQuery = '',
    this.filter = 'All',
    this.sortBy = 'Due Date',
    this.errorMessage,
  });

  TaskState copyWith({
    List<TaskEntity>? allTasks,
    List<TaskEntity>? filteredTasks,
    TaskStatus? status,
    String? searchQuery,
    String? filter,
    String? sortBy,
    String? errorMessage,
  }) {
    return TaskState(
      allTasks: allTasks ?? this.allTasks,
      filteredTasks: filteredTasks ?? this.filteredTasks,
      status: status ?? this.status,
      searchQuery: searchQuery ?? this.searchQuery,
      filter: filter ?? this.filter,
      sortBy: sortBy ?? this.sortBy,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        allTasks,
        filteredTasks,
        status,
        searchQuery,
        filter,
        sortBy,
        errorMessage,
      ];
}
