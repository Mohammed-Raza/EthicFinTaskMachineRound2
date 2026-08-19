import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/task_entity.dart';
import '../../../domain/repositories/task_repository.dart';

part 'task_event.dart';
part 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskRepository repository;
  StreamSubscription? _taskSubscription;

  TaskBloc({required this.repository}) : super(const TaskState()) {
    on<LoadTasks>(_onLoadTasks);
    on<AddTask>(_onAddTask);
    on<UpdateTask>(_onUpdateTask);
    on<DeleteTask>(_onDeleteTask);
    on<ToggleTaskCompletion>(_onToggleTaskCompletion);
    on<SearchTasks>(_onSearchTasks);
    on<FilterTasks>(_onFilterTasks);
    on<SortTasks>(_onSortTasks);
    on<SyncTasks>(_onSyncTasks);
    on<_UpdateTasksInternal>(_onUpdateTasksInternal);
  }

  Future<void> _onLoadTasks(LoadTasks event, Emitter<TaskState> emit) async {
    emit(state.copyWith(status: TaskStatus.loading));
    await _taskSubscription?.cancel();
    _taskSubscription = repository.watchTasks().listen((tasks) {
      add(_UpdateTasksInternal(tasks));
    });
  }

  void _onUpdateTasksInternal(_UpdateTasksInternal event, Emitter<TaskState> emit) {
    final filtered = _applyFilterAndSearch(
      event.tasks,
      state.searchQuery,
      state.filter,
      state.sortBy,
    );
    emit(state.copyWith(
      status: TaskStatus.success,
      allTasks: event.tasks,
      filteredTasks: filtered,
    ));
  }

  Future<void> _onAddTask(AddTask event, Emitter<TaskState> emit) async {
    emit(state.copyWith(errorMessage: null));
    try {
      await repository.addTask(event.task);
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onUpdateTask(UpdateTask event, Emitter<TaskState> emit) async {
    emit(state.copyWith(errorMessage: null));
    try {
      await repository.updateTask(event.task);
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onDeleteTask(DeleteTask event, Emitter<TaskState> emit) async {
    emit(state.copyWith(errorMessage: null));
    try {
      await repository.deleteTask(event.taskId);
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onToggleTaskCompletion(ToggleTaskCompletion event, Emitter<TaskState> emit) async {
    final updatedTask = event.task.copyWith(
      isCompleted: !event.task.isCompleted,
      updatedAt: DateTime.now(),
    );
    add(UpdateTask(updatedTask));
  }

  void _onSearchTasks(SearchTasks event, Emitter<TaskState> emit) {
    final filtered = _applyFilterAndSearch(
      state.allTasks,
      event.query,
      state.filter,
      state.sortBy,
    );
    emit(state.copyWith(
      searchQuery: event.query,
      filteredTasks: filtered,
    ));
  }

  void _onFilterTasks(FilterTasks event, Emitter<TaskState> emit) {
    final filtered = _applyFilterAndSearch(
      state.allTasks,
      state.searchQuery,
      event.filter,
      state.sortBy,
    );
    emit(state.copyWith(
      filter: event.filter,
      filteredTasks: filtered,
    ));
  }

  void _onSortTasks(SortTasks event, Emitter<TaskState> emit) {
    final filtered = _applyFilterAndSearch(
      state.allTasks,
      state.searchQuery,
      state.filter,
      event.sortBy,
    );
    emit(state.copyWith(
      sortBy: event.sortBy,
      filteredTasks: filtered,
    ));
  }

  Future<void> _onSyncTasks(SyncTasks event, Emitter<TaskState> emit) async {
    await repository.syncTasks();
  }

  List<TaskEntity> _applyFilterAndSearch(
    List<TaskEntity> tasks,
    String query,
    String filter,
    String sortBy,
  ) {
    var result = tasks;

    // Search
    if (query.isNotEmpty) {
      result = result.where((task) => 
        task.title.toLowerCase().contains(query.toLowerCase()) ||
        task.description.toLowerCase().contains(query.toLowerCase())
      ).toList();
    }

    // Filter
    if (filter == 'Completed') {
      result = result.where((task) => task.isCompleted).toList();
    } else if (filter == 'Pending') {
      result = result.where((task) => !task.isCompleted).toList();
    }

    // Sort
    if (sortBy == 'Due Date') {
      result.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    } else if (sortBy == 'Priority') {
      result.sort((a, b) => b.priority.index.compareTo(a.priority.index)); // High to Low
    }

    return result;
  }

  @override
  Future<void> close() {
    _taskSubscription?.cancel();
    return super.close();
  }
}

class _UpdateTasksInternal extends TaskEvent {
  final List<TaskEntity> tasks;
  const _UpdateTasksInternal(this.tasks);
  @override
  List<Object?> get props => [tasks];
}
