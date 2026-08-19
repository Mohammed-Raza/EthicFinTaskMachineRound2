import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ethic_fin_task2/presentation/blocs/task/task_bloc.dart';
import 'package:ethic_fin_task2/presentation/screens/add_edit_task_screen.dart';
import 'package:ethic_fin_task2/domain/entities/task_entity.dart';

import 'package:go_router/go_router.dart';

class MockTaskBloc extends MockBloc<TaskEvent, TaskState> implements TaskBloc {}

class FakeTaskEvent extends Fake implements TaskEvent {}

void main() {
  late MockTaskBloc mockTaskBloc;

  setUpAll(() {
    registerFallbackValue(FakeTaskEvent());
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
    mockTaskBloc = MockTaskBloc();
  });

  Widget createWidgetUnderTest({TaskEntity? task}) {
    final router = GoRouter(
      initialLocation: '/test',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const Scaffold(body: Text('Home')),
          routes: [
            GoRoute(
              path: 'test',
              builder: (context, state) => AddEditTaskScreen(task: task),
            ),
          ],
        ),
      ],
    );

    return BlocProvider<TaskBloc>.value(
      value: mockTaskBloc,
      child: MaterialApp.router(
        routerConfig: router,
      ),
    );
  }

  testWidgets('renders Create Task title when adding', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    expect(find.text('Create Task'), findsOneWidget);
    expect(find.text('CREATE TASK'), findsOneWidget);
  });

  testWidgets('renders Edit Task title when editing', (WidgetTester tester) async {
    final task = TaskEntity(
      id: '1',
      title: 'Existing Task',
      description: 'Existing Desc',
      priority: TaskPriority.high,
      dueDate: DateTime.now(),
      createdAt: DateTime.now(),
    );
    await tester.pumpWidget(createWidgetUnderTest(task: task));
    expect(find.text('Edit Task'), findsOneWidget);
    expect(find.text('UPDATE TASK'), findsOneWidget);
    expect(find.text('Existing Task'), findsOneWidget);
  });

  testWidgets('shows validation error when title is empty and saved', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    
    await tester.tap(find.text('CREATE TASK'));
    await tester.pump();

    expect(find.text('Please enter a title'), findsOneWidget);
    expect(find.text('Please enter a description'), findsOneWidget);
  });

  testWidgets('adds task when form is valid', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    
    await tester.enterText(find.byType(TextFormField).at(0), 'New Task');
    await tester.enterText(find.byType(TextFormField).at(1), 'New Description');
    
    final button = find.text('CREATE TASK');
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pump();

    verify(() => mockTaskBloc.add(any(that: isA<AddTask>()))).called(1);
  });
}
