import 'package:flutter/material.dart';
import '../../domain/entities/reminder.dart';

/// Diálogo que exibe detalhes completos de um lembrete e oferece ações:
/// - FECHAR: Fecha o diálogo
/// - EDITAR: Callback para editar (não implementado, apenas UI)
/// - REMOVER: Callback para remover
class ReminderDetailsDialog extends StatelessWidget {
  final Reminder reminder;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ReminderDetailsDialog({
    Key? key,
    required this.reminder,
    this.onEdit,
    this.onDelete,
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
    return AlertDialog(
      title: Row(
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
                style: const TextStyle(fontSize: 28),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  reminder.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getPriorityColor().withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    reminder.priorityLabel,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: _getPriorityColor(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status
            _DetailRow(
              label: 'Status',
              value: reminder.isActive ? '✓ Ativo' : '✗ Inativo',
              valueColor: reminder.isActive ? Colors.green : Colors.grey,
            ),
            const Divider(),

            // Tipo
            _DetailRow(
              label: 'Tipo',
              value: reminder.typeLabel,
            ),
            const Divider(),

            // Descrição
            _DetailRow(
              label: 'Descrição',
              value: reminder.description,
              isMultiline: true,
            ),
            const Divider(),

            // Data e Hora Agendada
            _DetailRow(
              label: 'Agendado para',
              value: reminder.formattedScheduledAt,
            ),
            const Divider(),

            // Data de Criação
            _DetailRow(
              label: 'Criado em',
              value: _formatDateTime(reminder.createdAt),
            ),
            const Divider(),

            // Data de Atualização (se houver)
            if (reminder.updatedAt != null) ...[
              _DetailRow(
                label: 'Atualizado em',
                value: _formatDateTime(reminder.updatedAt!),
              ),
              const Divider(),
            ],

            // Metadados (se houver)
            if (reminder.metadata != null && reminder.metadata!.isNotEmpty) ...[
              _DetailRow(
                label: 'Informações Adicionais',
                value: reminder.metadata.toString(),
                isMultiline: true,
              ),
              const Divider(),
            ],

            // ID
            _DetailRow(
              label: 'ID',
              value: reminder.id.toString(),
            ),
          ],
        ),
      ),
      actions: [
        // FECHAR
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('FECHAR'),
        ),
        // EDITAR
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
          ),
          onPressed: () {
            Navigator.pop(context);
            onEdit?.call();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Editar: Funcionalidade em desenvolvimento'),
                duration: Duration(seconds: 2),
              ),
            );
          },
          child: const Text(
            'EDITAR',
            style: TextStyle(color: Colors.white),
          ),
        ),
        // REMOVER
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
          ),
          onPressed: () {
            Navigator.pop(context);
            _showDeleteConfirmation(context);
          },
          child: const Text(
            'REMOVER',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  /// Mostra diálogo de confirmação antes de deletar
  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text('Deseja realmente remover o lembrete "${reminder.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(dialogContext);
              onDelete?.call();
            },
            child: const Text(
              'Remover',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} às ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

/// Widget auxiliar para exibir detalhes de forma consistente
class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isMultiline;
  final Color? valueColor;

  const _DetailRow({
    required this.label,
    required this.value,
    this.isMultiline = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: valueColor,
            ),
            maxLines: isMultiline ? null : 1,
            overflow: isMultiline ? TextOverflow.visible : TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
