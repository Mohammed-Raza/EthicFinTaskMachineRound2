import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/task_entity.dart';

class TaskItem extends StatelessWidget {
  final TaskEntity task;
  final VoidCallback onTap;
  final Function(bool?) onToggle;
  final VoidCallback onDelete;

  const TaskItem({
    super.key,
    required this.task,
    required this.onTap,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getPriorityColor(task.priority);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Transform.scale(
                  scale: 1.2,
                  child: Checkbox(
                    value: task.isCompleted,
                    onChanged: onToggle,
                    activeColor: Theme.of(context).colorScheme.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: task.isCompleted ? Colors.grey : Theme.of(context).colorScheme.onSurface,
                          decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        task.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.event_available_rounded, size: 14, color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7)),
                          const SizedBox(width: 4),
                          Text(
                            'Due: ${DateFormat('MMM dd').format(task.dueDate)}',
                            style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.primary),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '• Created: ${DateFormat('MMM dd').format(task.createdAt)}',
                            style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.7)),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              task.priority.name.toUpperCase(),
                              style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold),
                            ),
                          ),
                          if (!task.isSynced) ...[
                            const SizedBox(width: 12),
                            const Icon(Icons.sync_rounded, size: 14, color: Colors.orangeAccent),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.delete_sweep_rounded, color: Colors.red.shade300),
                  onPressed: onDelete,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return Colors.blueAccent;
      case TaskPriority.medium:
        return Colors.orangeAccent;
      case TaskPriority.high:
        return Colors.redAccent;
    }
  }
}
