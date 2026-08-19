import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/task_entity.dart';
import '../../../domain/repositories/task_repository.dart';
import '../auth/auth_bloc.dart';

part 'task_event.dart';
part 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskRepository repository;
  final AuthBloc authBloc;
  StreamSubscription? _taskSubscription;
  StreamSubscription? _authSubscription;

  TaskBloc({required this.repository, required this.authBloc}) : super(const TaskState()) {
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

    _authSubscription = authBloc.stream.listen((authState) {
      if (authState.status == AuthStatus.authenticated) {
        add(LoadTasks());
      }
    });
  }

  String get _userId => authBloc.state.user?.uid ?? '';

  Future<void> _onLoadTasks(LoadTasks event, Emitter<TaskState> emit) async {
    if (_userId.isEmpty) return;
    emit(state.copyWith(status: TaskStatus.loading));
    await _taskSubscription?.cancel();
    _taskSubscription = repository.watchTasks(_userId).listen((tasks) {
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
    if (_userId.isEmpty) return;
    emit(state.copyWith(errorMessage: null));
    try {
      await repository.addTask(_userId, event.task);
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onUpdateTask(UpdateTask event, Emitter<TaskState> emit) async {
    if (_userId.isEmpty) return;
    emit(state.copyWith(errorMessage: null));
    try {
      await repository.updateTask(_userId, event.task);
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onDeleteTask(DeleteTask event, Emitter<TaskState> emit) async {
    if (_userId.isEmpty) return;
    emit(state.copyWith(errorMessage: null));
    try {
      await repository.deleteTask(_userId, event.taskId);
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
    if (_userId.isEmpty) return;
    await repository.syncTasks(_userId);
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
    _authSubscription?.cancel();
    return super.close();
  }
}

class _UpdateTasksInternal extends TaskEvent {
  final List<TaskEntity> tasks;
  const _UpdateTasksInternal(this.tasks);
  @override
  List<Object?> get props => [tasks];
}
