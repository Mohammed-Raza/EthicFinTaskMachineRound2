import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../blocs/task/task_bloc.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/theme_bloc.dart';
import '../widgets/task_item.dart';

class TaskListScreen extends StatelessWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<TaskBloc, TaskState>(
      listenWhen: (previous, current) => current.errorMessage != null,
      listener: (context, state) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.errorMessage!),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          title: const Text(
            'Task Manager',
            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
          ),
          actions: [
            BlocBuilder<ThemeBloc, ThemeState>(
              builder: (context, state) {
                return IconButton(
                  icon: Icon(
                    state.themeMode == ThemeMode.light 
                      ? Icons.dark_mode_rounded 
                      : Icons.light_mode_rounded
                  ),
                  onPressed: () => context.read<ThemeBloc>().add(ToggleTheme()),
                  tooltip: 'Toggle Theme',
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.sync_rounded),
              tooltip: 'Sync with Cloud',
              onPressed: () => context.read<TaskBloc>().add(SyncTasks()),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert_rounded),
              tooltip: 'More options',
              onSelected: (value) {
                if (value == 'Logout') {
                  context.read<AuthBloc>().add(AuthLogoutRequested());
                } else {
                  context.read<TaskBloc>().add(SortTasks(value));
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'Due Date', child: Text('Sort by Due Date')),
                const PopupMenuItem(value: 'Priority', child: Text('Sort by Priority')),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'Logout', 
                  child: Row(
                    children: [
                      Icon(Icons.logout, color: Colors.redAccent, size: 20),
                      SizedBox(width: 8),
                      Text('Logout', style: TextStyle(color: Colors.redAccent)),
                    ],
                  )
                ),
              ],
            ),
          ],
        ),
        body: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Theme.of(context).appBarTheme.backgroundColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  TextField(
                    style: TextStyle(color: Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search tasks...',
                      hintStyle: TextStyle(color: Colors.grey.shade600),
                      prefixIcon: Icon(Icons.search, color: Theme.of(context).colorScheme.primary),
                      fillColor: Theme.of(context).brightness == Brightness.light ? Colors.white : Colors.grey.shade900,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) => context.read<TaskBloc>().add(SearchTasks(value)),
                  ),
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['All', 'Pending', 'Completed'].map((filter) {
                        return BlocBuilder<TaskBloc, TaskState>(
                          buildWhen: (previous, current) => previous.filter != current.filter,
                          builder: (context, state) {
                            final isSelected = state.filter == filter;
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4.0),
                              child: ChoiceChip(
                                label: Text(filter),checkmarkColor: Colors.blueGrey,
                                selected: isSelected,
                                selectedColor: Colors.amber.shade300,
                                labelStyle: TextStyle(
                                  color: isSelected 
                                    ? (Theme.of(context).brightness == Brightness.light ? Colors.white : Colors.black)
                                    : (Theme.of(context).brightness == Brightness.light ? Colors.teal.shade700 : Colors.white70),
                                  fontWeight: FontWeight.bold,
                                ),
                                onSelected: (selected) {
                                  if (selected) {
                                    context.read<TaskBloc>().add(FilterTasks(filter));
                                  }
                                },
                              ),
                            );
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: BlocBuilder<TaskBloc, TaskState>(
                builder: (context, state) {
                  if (state.status == TaskStatus.loading) {
                    return Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary));
                  }

                  if (state.filteredTasks.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.task_alt_rounded, size: 80, color: Theme.of(context).colorScheme.primary.withOpacity(0.2)),
                          const SizedBox(height: 16),
                          Text(
                            state.allTasks.isEmpty
                                ? 'Your task list is empty'
                                : 'No matching tasks found',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (state.allTasks.isEmpty)
                            Text(
                              'Tap + to add your first task',
                              style: TextStyle(color: Theme.of(context).colorScheme.primary),
                            ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 80),
                    itemCount: state.filteredTasks.length,
                    itemBuilder: (context, index) {
                      final task = state.filteredTasks[index];
                      return TaskItem(
                        task: task,
                        onTap: () => context.go('/details', extra: task),
                        onToggle: (_) => context.read<TaskBloc>().add(ToggleTaskCompletion(task)),
                        onDelete: () => _confirmDelete(context, task.id),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => context.go('/add'),
          icon: const Icon(Icons.add),
          label: const Text('New Task'),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, String taskId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('This action cannot be undone. Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              context.read<TaskBloc>().add(DeleteTask(taskId));
              Navigator.pop(dialogContext);
            },
            child: const Text('DELETE', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}
