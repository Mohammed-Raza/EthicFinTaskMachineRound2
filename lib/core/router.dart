import 'package:go_router/go_router.dart';
import '../domain/entities/task_entity.dart';
import '../presentation/screens/task_list_screen.dart';
import '../presentation/screens/add_edit_task_screen.dart';
import '../presentation/screens/task_details_screen.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const TaskListScreen(),
      routes: [
        GoRoute(
          path: 'add',
          builder: (context, state) => const AddEditTaskScreen(),
        ),
        GoRoute(
          path: 'edit',
          builder: (context, state) {
            final task = state.extra as TaskEntity;
            return AddEditTaskScreen(task: task);
          },
        ),
        GoRoute(
          path: 'details',
          builder: (context, state) {
            final task = state.extra as TaskEntity;
            return TaskDetailsScreen(task: task);
          },
        ),
      ],
    ),
  ],
);
