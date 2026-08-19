import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ethic_fin_task2/domain/entities/task_entity.dart';
import 'package:ethic_fin_task2/domain/repositories/task_repository.dart';
import 'package:ethic_fin_task2/presentation/blocs/task/task_bloc.dart';

class MockTaskRepository extends Mock implements TaskRepository {}

void main() {
  late TaskBloc taskBloc;
  late MockTaskRepository mockTaskRepository;

  setUpAll(() {
    registerFallbackValue(TaskEntity(
      id: '0',
      title: '',
      description: '',
      priority: TaskPriority.low,
      dueDate: DateTime.now(),
      createdAt: DateTime.now(),
    ));
  });

  setUp(() {
    mockTaskRepository = MockTaskRepository();
    taskBloc = TaskBloc(repository: mockTaskRepository);
  });

  tearDown(() {
    taskBloc.close();
  });

  final tTask = TaskEntity(
    id: '1',
    title: 'Test Task',
    description: 'Description',
    priority: TaskPriority.medium,
    dueDate: DateTime(2023, 12, 31),
    createdAt: DateTime(2023, 1, 1),
  );

  final tTasks = [tTask];

  test('initial state should be TaskState()', () {
    expect(taskBloc.state, const TaskState());
  });

  group('LoadTasks', () {
    blocTest<TaskBloc, TaskState>(
      'emits [loading, success] when watchTasks emits tasks',
      setUp: () {
        when(() => mockTaskRepository.watchTasks())
            .thenAnswer((_) => Stream.value(tTasks));
      },
      build: () => taskBloc,
      act: (bloc) => bloc.add(LoadTasks()),
      expect: () => [
        const TaskState(status: TaskStatus.loading),
        TaskState(
          status: TaskStatus.success,
          allTasks: tTasks,
          filteredTasks: tTasks,
        ),
      ],
    );
  });

  group('AddTask', () {
    blocTest<TaskBloc, TaskState>(
      'calls repository.addTask',
      setUp: () {
        when(() => mockTaskRepository.addTask(any()))
            .thenAnswer((_) async => {});
      },
      build: () => taskBloc,
      act: (bloc) => bloc.add(AddTask(tTask)),
      verify: (_) {
        verify(() => mockTaskRepository.addTask(tTask)).called(1);
      },
    );

    blocTest<TaskBloc, TaskState>(
      'emits state with error message when repository.addTask fails',
      setUp: () {
        when(() => mockTaskRepository.addTask(any()))
            .thenThrow(Exception('Failed to add'));
      },
      build: () => taskBloc,
      act: (bloc) => bloc.add(AddTask(tTask)),
      expect: () => [
        const TaskState(errorMessage: null), 
        const TaskState(errorMessage: 'Exception: Failed to add'),
      ],
    );
  });

  group('UpdateTask', () {
    blocTest<TaskBloc, TaskState>(
      'calls repository.updateTask',
      setUp: () {
        when(() => mockTaskRepository.updateTask(any()))
            .thenAnswer((_) async => {});
      },
      build: () => taskBloc,
      act: (bloc) => bloc.add(UpdateTask(tTask)),
      verify: (_) {
        verify(() => mockTaskRepository.updateTask(tTask)).called(1);
      },
    );
  });

  group('DeleteTask', () {
    blocTest<TaskBloc, TaskState>(
      'calls repository.deleteTask',
      setUp: () {
        when(() => mockTaskRepository.deleteTask(any()))
            .thenAnswer((_) async => {});
      },
      build: () => taskBloc,
      act: (bloc) => bloc.add(const DeleteTask('1')),
      verify: (_) {
        verify(() => mockTaskRepository.deleteTask('1')).called(1);
      },
    );
  });

  group('SearchTasks', () {
    blocTest<TaskBloc, TaskState>(
      'filters tasks based on search query',
      seed: () => TaskState(
        allTasks: [
          tTask,
          tTask.copyWith(id: '2', title: 'Other'),
        ],
        filteredTasks: [
          tTask,
          tTask.copyWith(id: '2', title: 'Other'),
        ],
      ),
      build: () => taskBloc,
      act: (bloc) => bloc.add(const SearchTasks('Other')),
      expect: () => [
        isA<TaskState>().having((s) => s.filteredTasks.length, 'length', 1)
                        .having((s) => s.filteredTasks.first.title, 'title', 'Other')
                        .having((s) => s.searchQuery, 'query', 'Other'),
      ],
    );
  });

  group('FilterTasks', () {
    final completedTask = tTask.copyWith(id: '2', isCompleted: true);
    blocTest<TaskBloc, TaskState>(
      'filters tasks based on completion status',
      seed: () => TaskState(
        allTasks: [tTask, completedTask],
        filteredTasks: [tTask, completedTask],
      ),
      build: () => taskBloc,
      act: (bloc) => bloc.add(const FilterTasks('Completed')),
      expect: () => [
        isA<TaskState>().having((s) => s.filteredTasks.length, 'length', 1)
                        .having((s) => s.filteredTasks.first.isCompleted, 'isCompleted', true)
                        .having((s) => s.filter, 'filter', 'Completed'),
      ],
    );
  });

  group('SortTasks', () {
    final highPriority = tTask.copyWith(id: '2', priority: TaskPriority.high);
    blocTest<TaskBloc, TaskState>(
      'sorts tasks based on priority',
      seed: () => TaskState(
        allTasks: [tTask, highPriority], // medium, high
        filteredTasks: [tTask, highPriority],
      ),
      build: () => taskBloc,
      act: (bloc) => bloc.add(const SortTasks('Priority')),
      expect: () => [
        isA<TaskState>().having((s) => s.filteredTasks.first.priority, 'first priority', TaskPriority.high)
                        .having((s) => s.sortBy, 'sortBy', 'Priority'),
      ],
    );
  });

  group('SyncTasks', () {
    blocTest<TaskBloc, TaskState>(
      'calls repository.syncTasks',
      setUp: () {
        when(() => mockTaskRepository.syncTasks())
            .thenAnswer((_) async => {});
      },
      build: () => taskBloc,
      act: (bloc) => bloc.add(SyncTasks()),
      verify: (_) {
        verify(() => mockTaskRepository.syncTasks()).called(1);
      },
    );
  });
}
