import '../entities/daily_goal.dart';

/// Interface do repositório de metas diárias
abstract class DailyGoalRepository {
  /// Obtém a meta do dia atual
  Future<DailyGoal?> getTodayGoal();

  /// Obtém meta de uma data específica
  Future<DailyGoal?> getGoalByDate(String date);

  /// Lista todas as metas de um período
  Future<List<DailyGoal>> getGoalsByDateRange(String startDate, String endDate);

  /// Cria uma nova meta diária
  Future<void> createGoal(DailyGoal goal);

  /// Atualiza uma meta existente
  Future<void> updateGoal(DailyGoal goal);

  /// Incrementa o contador de sessões completadas
  Future<void> incrementCompletedSessions(String date);

  /// Verifica se a meta de hoje foi alcançada
  Future<bool> isTodayGoalCompleted();

  /// Retorna o progresso de hoje (sessões completadas / meta)
  Future<double> getTodayProgress();
}
