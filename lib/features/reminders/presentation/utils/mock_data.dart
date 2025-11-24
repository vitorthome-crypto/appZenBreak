import '../../domain/entities/reminder.dart';

/// Mock data para testes
List<Reminder> generateMockReminders() {
  final now = DateTime.now();
  return [
    Reminder(
      id: 1,
      title: 'Sessão de Respiração',
      description: 'Realizar exercício de respiração profunda por 5 minutos',
      scheduledAt: now.add(const Duration(hours: 2)),
      type: 'breathing',
      priority: 'high',
      isActive: true,
      createdAt: now.subtract(const Duration(days: 1)),
      metadata: {'duration': 5, 'technique': 'box_breathing'},
    ),
    Reminder(
      id: 2,
      title: 'Beber Água',
      description: 'Hidrate-se bebendo um copo de água',
      scheduledAt: now.add(const Duration(hours: 1)),
      type: 'hydration',
      priority: 'medium',
      isActive: true,
      createdAt: now.subtract(const Duration(days: 2)),
      metadata: {'amount_ml': 250},
    ),
    Reminder(
      id: 3,
      title: 'Alongamento Postural',
      description: 'Faça alongamentos para melhorar sua postura',
      scheduledAt: now.add(const Duration(hours: 4)),
      type: 'posture',
      priority: 'medium',
      isActive: true,
      createdAt: now.subtract(const Duration(days: 3)),
    ),
    Reminder(
      id: 4,
      title: 'Meditação Matinal',
      description: 'Comece o dia com 10 minutos de meditação',
      scheduledAt: now.subtract(const Duration(hours: 2)),
      type: 'meditation',
      priority: 'high',
      isActive: false,
      createdAt: now.subtract(const Duration(days: 5)),
      metadata: {'duration': 10},
    ),
    Reminder(
      id: 5,
      title: 'Conferir Bem-estar',
      description: 'Check-in rápido de como você está se sentindo',
      scheduledAt: now.add(const Duration(days: 1)),
      type: 'custom',
      priority: 'low',
      isActive: true,
      createdAt: now.subtract(const Duration(days: 1)),
    ),
  ];
}
