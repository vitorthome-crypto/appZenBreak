import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/daily_goal_controller.dart';

class MetasPage extends StatefulWidget {
  const MetasPage({super.key});

  @override
  State<MetasPage> createState() => _MetasPageState();
}

class _MetasPageState extends State<MetasPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _handleCompleteSession(DailyGoalController controller) async {
    try {
      await controller.completeSession();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sessão registrada! ✓'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Metas Diárias'),
        elevation: 0,
      ),
      body: Consumer<DailyGoalController?>(
        builder: (context, dailyGoalController, _) {
          if (dailyGoalController == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Erro ao carregar metas',
                    style: textTheme.bodyLarge,
                  ),
                ],
              ),
            );
          }

          if (dailyGoalController.loading) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
              ),
            );
          }

          final goal = dailyGoalController.todayGoal;
          if (goal == null) {
            return Center(
              child: Text(
                'Nenhuma meta para hoje',
                style: textTheme.bodyLarge,
              ),
            );
          }

          final progress = dailyGoalController.todayProgress;
          final completed = dailyGoalController.goalCompleted;
          final sessionsCompleted = dailyGoalController.sessionsCompleted;
          final sessionTarget = dailyGoalController.sessionsTarget;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Card de Meta Hoje
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          colorScheme.primary.withAlpha((0.9 * 255).round()),
                          colorScheme.primary.withAlpha((0.7 * 255).round()),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.primary.withAlpha((0.3 * 255).round()),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Meta de Hoje',
                          style: textTheme.titleMedium?.copyWith(
                            color: colorScheme.onPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              onPressed: () async {
                                final newTarget = (sessionTarget - 1).clamp(1, 999);
                                await dailyGoalController.setTargetSessions(newTarget);
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Meta atualizada: $newTarget sessão${newTarget > 1 ? 's' : ''}/dia')),
                                  );
                                }
                              },
                              icon: Icon(Icons.remove_circle_outline, color: colorScheme.onPrimary),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '$sessionTarget',
                              style: textTheme.displayMedium?.copyWith(
                                color: colorScheme.onPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: () async {
                                final newTarget = sessionTarget + 1;
                                await dailyGoalController.setTargetSessions(newTarget);
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Meta atualizada: $newTarget sessão${newTarget > 1 ? 's' : ''}/dia')),
                                  );
                                }
                              },
                              icon: Icon(Icons.add_circle_outline, color: colorScheme.onPrimary),
                            ),
                          ],
                        ),
                        Text(
                          'sessão${sessionTarget > 1 ? 's' : ''} por dia',
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onPrimary.withAlpha((0.8 * 255).round()),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Progress Bar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            minHeight: 12,
                            value: progress,
                            backgroundColor: colorScheme.onPrimary.withAlpha((0.2 * 255).round()),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              completed ? Colors.green : colorScheme.onPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '${(progress * 100).toStringAsFixed(0)}% completo',
                          style: textTheme.labelMedium?.copyWith(
                            color: colorScheme.onPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Status da Meta
                  if (completed)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.withAlpha((0.1 * 255).round()),
                        border: Border.all(color: Colors.green, width: 2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green, size: 32),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Parabéns!',
                                  style: textTheme.titleSmall?.copyWith(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Você completou sua meta de hoje 🎉',
                                  style: textTheme.bodySmall?.copyWith(
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withAlpha((0.1 * 255).round()),
                        border: Border.all(
                          color: colorScheme.primary,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            color: colorScheme.primary,
                            size: 32,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Em Progresso',
                                  style: textTheme.titleSmall?.copyWith(
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Complete mais ${sessionTarget - sessionsCompleted} sessão${sessionTarget - sessionsCompleted > 1 ? 's' : ''}',
                                  style: textTheme.bodySmall?.copyWith(
                                    color: colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 24),

                  // Sessões Completadas
                  Text(
                    'Sessões Completadas Hoje',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: List.generate(
                      sessionTarget,
                      (index) {
                        final isCompleted = index < sessionsCompleted;
                        return GestureDetector(
                          onTap: isCompleted ? null : () => _handleCompleteSession(dailyGoalController),
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: isCompleted ? Colors.green : colorScheme.surfaceContainer,
                              border: Border.all(
                                color: isCompleted ? Colors.green : colorScheme.outline,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: isCompleted
                                  ? [
                                      BoxShadow(
                                        color: Colors.green.withAlpha((0.3 * 255).round()),
                                        blurRadius: 8,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (isCompleted)
                                  Icon(
                                    Icons.check_circle,
                                    color: colorScheme.onPrimary,
                                    size: 32,
                                  )
                                else
                                  Icon(
                                    Icons.add_circle_outline,
                                    color: colorScheme.outline,
                                    size: 32,
                                  ),
                                const SizedBox(height: 4),
                                Text(
                                  '${index + 1}',
                                  style: textTheme.labelSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: isCompleted ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Botão de Registrar Sessão
                  if (!completed)
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: FilledButton.icon(
                        onPressed: () => _handleCompleteSession(dailyGoalController),
                        icon: const Icon(Icons.add),
                        label: const Text('Registrar Sessão Completa'),
                      ),
                    ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
