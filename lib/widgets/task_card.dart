import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onToggleComplete;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TaskCard({
    super.key,
    required this.task,
    required this.onToggleComplete,
    required this.onEdit,
    required this.onDelete,
  });

  Color _getCategoryColor() {
    switch (task.category) {
      case 'Travail':
        return Colors.blue;
      case 'Personnel':
        return Colors.green;
      case 'Urgent':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryColor = _getCategoryColor();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Checkbox
            GestureDetector(
              onTap: onToggleComplete,
              child: Container(
                width: 28,
                height: 28,
                margin: const EdgeInsets.only(top: 2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: task.completed ? Colors.green : Colors.grey.shade400,
                    width: 2,
                  ),
                  color: task.completed ? Colors.green : Colors.transparent,
                ),
                child: task.completed
                    ? const Icon(Icons.check, size: 18, color: Colors.white)
                    : null,
              ),
            ),
            const SizedBox(width: 12),

            // Contenu
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Titre et badge catégorie
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          task.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            decoration: task.completed
                                ? TextDecoration.lineThrough
                                : null,
                            color: task.completed
                                ? Colors.grey.shade500
                                : Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: categoryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: categoryColor.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          task.category,
                          style: TextStyle(
                            color: (categoryColor as MaterialColor).shade700,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Description
                  Text(
                    task.description,
                    style: TextStyle(
                      color: task.completed
                          ? Colors.grey.shade400
                          : Colors.grey.shade700,
                      fontSize: 14,
                      decoration: task.completed
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Date
                  Text(
                    'Créée le ${DateFormat('d MMMM yyyy', 'fr_FR').format(task.createdAt)}',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            // Boutons d'action
            Column(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.edit,
                    color: Colors.blue.shade600,
                    size: 20,
                  ),
                  onPressed: onEdit,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(height: 8),
                IconButton(
                  icon: Icon(
                    Icons.delete,
                    color: Colors.red.shade600,
                    size: 20,
                  ),
                  onPressed: onDelete,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}