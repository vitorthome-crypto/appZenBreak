/// Entidade de Meta Diária
class DailyGoal {
  final String id;
  final String date; // ISO 8601 (YYYY-MM-DD)
  final int targetSessionsPerDay;
  final int completedSessions;
  final bool completed;
  final DateTime createdAt;
  final DateTime updatedAt;

  DailyGoal({
    required this.id,
    required this.date,
    required this.targetSessionsPerDay,
    required this.completedSessions,
    required this.completed,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Cria uma nova meta diária com padrões
  factory DailyGoal.create({
    required String date,
    int targetSessionsPerDay = 1,
    int completedSessions = 0,
  }) {
    final now = DateTime.now();
    return DailyGoal(
      id: '${date}_goal',
      date: date,
      targetSessionsPerDay: targetSessionsPerDay,
      completedSessions: completedSessions,
      completed: completedSessions >= targetSessionsPerDay,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Verifica se a meta foi atingida
  bool isMetReached() => completedSessions >= targetSessionsPerDay;

  /// Retorna a porcentagem de progresso (0.0 - 1.0)
  double getProgressPercentage() {
    if (targetSessionsPerDay == 0) return 0.0;
    return (completedSessions / targetSessionsPerDay).clamp(0.0, 1.0);
  }

  /// Cria uma cópia com campos atualizados
  DailyGoal copyWith({
    String? id,
    String? date,
    int? targetSessionsPerDay,
    int? completedSessions,
    bool? completed,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DailyGoal(
      id: id ?? this.id,
      date: date ?? this.date,
      targetSessionsPerDay: targetSessionsPerDay ?? this.targetSessionsPerDay,
      completedSessions: completedSessions ?? this.completedSessions,
      completed: completed ?? this.completed,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
