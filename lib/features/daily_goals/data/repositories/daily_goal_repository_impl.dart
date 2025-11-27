import '../../domain/entities/daily_goal.dart';
import '../../domain/repositories/daily_goal_repository.dart';
import '../datasources/daily_goal_local_data_source.dart';

/// Implementação do repositório de metas diárias
class DailyGoalRepositoryImpl implements DailyGoalRepository {
  final DailyGoalLocalDataSource localDataSource;

  DailyGoalRepositoryImpl({required this.localDataSource});

  @override
  Future<DailyGoal?> getTodayGoal() => localDataSource.getTodayGoal();

  @override
  Future<DailyGoal?> getGoalByDate(String date) => localDataSource.getGoalByDate(date);

  @override
  Future<List<DailyGoal>> getGoalsByDateRange(String startDate, String endDate) =>
      localDataSource.getGoalsByDateRange(startDate, endDate);

  @override
  Future<void> createGoal(DailyGoal goal) => localDataSource.saveGoal(goal);

  @override
  Future<void> updateGoal(DailyGoal goal) => localDataSource.saveGoal(goal);

  @override
  Future<void> incrementCompletedSessions(String date) =>
      localDataSource.incrementCompletedSessions(date);

  @override
  Future<bool> isTodayGoalCompleted() async {
    final goal = await getTodayGoal();
    return goal?.completed ?? false;
  }

  @override
  Future<double> getTodayProgress() async {
    final goal = await getTodayGoal();
    if (goal == null) return 0.0;
    return goal.getProgressPercentage();
  }
}
