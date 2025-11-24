import 'package:flutter/material.dart';
import '../../domain/entities/reminder.dart';

/// Widget que representa um item individual de lembrete na lista
class ReminderListItem extends StatelessWidget {
  final Reminder reminder;
  final VoidCallback onTap;
  final VoidCallback? onDismissed;

  const ReminderListItem({
    Key? key,
    required this.reminder,
    required this.onTap,
    this.onDismissed,
  }) : super(key: key);

  /// Retorna a cor baseada na prioridade
  Color _getPriorityColor() {
    switch (reminder.priority) {
      case 'high':
        return const Color(0xFFFF5252); // Vermelho
      case 'medium':
        return const Color(0xFFFFC107); // Âmbar
      case 'low':
        return const Color(0xFF4CAF50); // Verde
      default:
        return const Color(0xFF9E9E9E); // Cinza
    }
  }

  /// Retorna o ícone baseado no tipo
  String _getTypeIcon() {
    switch (reminder.type) {
      case 'breathing':
        return '🫁';
      case 'hydration':
        return '💧';
      case 'posture':
        return '🧘';
      case 'meditation':
        return '🧘‍♂️';
      default:
        return '⏰';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(reminder.id),
      background: Container(
        color: Colors.red.shade100,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: Icon(Icons.delete, color: Colors.red.shade700),
      ),
      onDismissed: (_) => onDismissed?.call(),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ícone do tipo
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      _getTypeIcon(),
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Informações principais
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              reminder.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (!reminder.isActive)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'Inativo',
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        reminder.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          // Data/Hora agendada
                          Icon(
                            Icons.schedule,
                            size: 12,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              reminder.formattedScheduledAt,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Indicador de prioridade
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _getPriorityColor(),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
