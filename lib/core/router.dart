import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../domain/entities/task_entity.dart';
import '../presentation/blocs/auth/auth_bloc.dart';
import '../presentation/screens/task_list_screen.dart';
import '../presentation/screens/add_edit_task_screen.dart';
import '../presentation/screens/task_details_screen.dart';
import '../presentation/screens/auth/login_screen.dart';
import '../presentation/screens/auth/signup_screen.dart';

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
          (dynamic _) => notifyListeners(),
        );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

GoRouter createRouter(AuthBloc authBloc) {
  return GoRouter(
    initialLocation: '/',
    refreshListenable: GoRouterRefreshStream(authBloc.stream),
    redirect: (context, state) {
      final authState = authBloc.state;
      final bool loggingIn = state.matchedLocation == '/login' || state.matchedLocation == '/signup';

      if (authState.status == AuthStatus.unknown) return null;
      
      if (authState.status == AuthStatus.unauthenticated) {
        return loggingIn ? null : '/login';
      }
      
      if (loggingIn) return '/';

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignUpScreen(),
      ),
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
}
