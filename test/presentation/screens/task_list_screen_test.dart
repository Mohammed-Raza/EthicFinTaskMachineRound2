import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ethic_fin_task2/presentation/blocs/task/task_bloc.dart';
import 'package:ethic_fin_task2/presentation/blocs/theme_bloc.dart';
import 'package:ethic_fin_task2/presentation/screens/task_list_screen.dart';
import 'package:ethic_fin_task2/domain/entities/task_entity.dart';

import 'package:go_router/go_router.dart';

class MockTaskBloc extends MockBloc<TaskEvent, TaskState> implements TaskBloc {}
class MockThemeBloc extends MockBloc<ThemeEvent, ThemeState> implements ThemeBloc {}

void main() {
  late MockTaskBloc mockTaskBloc;
  late MockThemeBloc mockThemeBloc;

  setUp(() {
    mockTaskBloc = MockTaskBloc();
    mockThemeBloc = MockThemeBloc();

    when(() => mockThemeBloc.state).thenReturn(const ThemeState(ThemeMode.light));
  });

  Widget createWidgetUnderTest() {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const TaskListScreen(),
        ),
      ],
    );

    return MultiBlocProvider(
      providers: [
        BlocProvider<TaskBloc>.value(value: mockTaskBloc),
        BlocProvider<ThemeBloc>.value(value: mockThemeBloc),
      ],
      child: MaterialApp.router(
        routerConfig: router,
      ),
    );
  }

  testWidgets('renders Task Manager title', (WidgetTester tester) async {
    when(() => mockTaskBloc.state).thenReturn(const TaskState());
    await tester.pumpWidget(createWidgetUnderTest());
    expect(find.text('Task Manager'), findsOneWidget);
  });

  testWidgets('displays loading indicator when status is loading', (WidgetTester tester) async {
    when(() => mockTaskBloc.state).thenReturn(const TaskState(status: TaskStatus.loading));
    await tester.pumpWidget(createWidgetUnderTest());
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('displays empty message when no tasks', (WidgetTester tester) async {
    when(() => mockTaskBloc.state).thenReturn(const TaskState(status: TaskStatus.success, allTasks: []));
    await tester.pumpWidget(createWidgetUnderTest());
    expect(find.text('Your task list is empty'), findsOneWidget);
  });

  testWidgets('displays tasks when status is success', (WidgetTester tester) async {
    final tasks = [
      TaskEntity(
        id: '1',
        title: 'Task 1',
        description: 'Desc 1',
        priority: TaskPriority.medium,
        dueDate: DateTime.now(),
        createdAt: DateTime.now(),
      ),
    ];
    when(() => mockTaskBloc.state).thenReturn(TaskState(
      status: TaskStatus.success,
      allTasks: tasks,
      filteredTasks: tasks,
    ));

    await tester.pumpWidget(createWidgetUnderTest());
    expect(find.text('Task 1'), findsOneWidget);
    expect(find.text('Desc 1'), findsOneWidget);
  });
}
