import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/daily_goal_controller.dart';

/// Widget para exibir o progresso da meta diária
class DailyGoalWidget extends StatelessWidget {
  final bool compact;

  const DailyGoalWidget({super.key, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Consumer<DailyGoalController>(
      builder: (context, controller, _) {
        if (controller.loading) {
          return SizedBox(
            height: compact ? 60 : 100,
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
              ),
            ),
          );
        }

        final progress = controller.todayProgress;
        final completed = controller.goalCompleted;
        final sessions = controller.sessionsCompleted;
        final target = controller.sessionsTarget;

        if (compact) {
          // Versão compacta para header/AppBar
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(
                  completed ? Icons.check_circle : Icons.schedule,
                  color: completed ? Colors.green : colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Meta de hoje',
                        style: textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        '$sessions/$target sessão${target > 1 ? 's' : ''}',
                        style: textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    minHeight: 6,
                    value: progress,
                    backgroundColor: colorScheme.surfaceContainer,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      completed ? Colors.green : colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        // Versão expandida para home
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainer.withAlpha((0.5 * 255).round()),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colorScheme.outline.withAlpha((0.2 * 255).round()),
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Meta de Hoje',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (completed)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withAlpha((0.2 * 255).round()),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check, color: Colors.green, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            'Concluída',
                            style: textTheme.labelSmall?.copyWith(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$sessions de $target',
                    style: textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${(progress * 100).toStringAsFixed(0)}%',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  minHeight: 8,
                  value: progress,
                  backgroundColor: colorScheme.surfaceContainer.withAlpha((0.5 * 255).round()),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    completed ? Colors.green : colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                completed
                    ? 'Parabéns! Você atingiu sua meta de hoje. 🎉'
                    : 'Complete mais ${target - sessions} sessão${target - sessions > 1 ? 's' : ''} para atingir sua meta.',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }
}
