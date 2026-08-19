import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ethic_fin_task2/presentation/screens/task_details_screen.dart';
import 'package:ethic_fin_task2/domain/entities/task_entity.dart';
import 'package:intl/intl.dart';

import 'package:go_router/go_router.dart';

void main() {
  final task = TaskEntity(
    id: '1',
    title: 'Detail Task',
    description: 'Detail Description',
    priority: TaskPriority.high,
    dueDate: DateTime(2023, 12, 31),
    createdAt: DateTime(2023, 1, 1),
  );

  Widget createWidgetUnderTest() {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => TaskDetailsScreen(task: task),
        ),
      ],
    );
    return MaterialApp.router(
      routerConfig: router,
    );
  }

  testWidgets('displays task details correctly', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.text('Detail Task'), findsOneWidget);
    expect(find.text('Detail Description'), findsOneWidget);
    expect(find.text('HIGH'), findsOneWidget);
    expect(find.text('Due: Dec 31, 2023'), findsOneWidget);
    expect(find.text(DateFormat('MMM dd, yyyy HH:mm').format(task.createdAt)), findsOneWidget);
  });

  testWidgets('displays sync status correctly', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    expect(find.text('Pending Cloud Sync'), findsOneWidget);
  });
}
