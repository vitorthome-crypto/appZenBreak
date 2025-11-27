import 'package:flutter/material.dart';
import '../../domain/entities/daily_goal.dart';
import '../../domain/repositories/daily_goal_repository.dart';

/// Controller para metas diárias
class DailyGoalController extends ChangeNotifier {
  final DailyGoalRepository repository;

  DailyGoal? _todayGoal;
  bool _loading = false;
  String? _error;

  DailyGoalController({required this.repository}) {
    _initToday();
  }

  // Getters
  DailyGoal? get todayGoal => _todayGoal;
  bool get loading => _loading;
  String? get error => _error;
  bool get goalCompleted => _todayGoal?.completed ?? false;
  double get todayProgress => _todayGoal?.getProgressPercentage() ?? 0.0;
  int get sessionsCompleted => _todayGoal?.completedSessions ?? 0;
  int get sessionsTarget => _todayGoal?.targetSessionsPerDay ?? 1;

  /// Inicializa a meta de hoje
  Future<void> _initToday() async {
    try {
      _loading = true;
      _error = null;
      _todayGoal = await repository.getTodayGoal();

      // Se não existe meta hoje, criar uma nova
      if (_todayGoal == null) {
        _todayGoal = DailyGoal.create(
          date: _getTodayDate(),
          targetSessionsPerDay: 1,
        );
        await repository.createGoal(_todayGoal!);
      }

      notifyListeners();
    } catch (e) {
      _error = 'Erro ao carregar meta diária: $e';
      debugPrint('[DailyGoalController] $_error');
      notifyListeners();
    } finally {
      _loading = false;
    }
  }

  /// Incrementa sessões completadas de hoje
  Future<void> completeSession() async {
    try {
      _error = null;
      final today = _getTodayDate();
      await repository.incrementCompletedSessions(today);

      // Recarregar meta atualizada
      _todayGoal = await repository.getTodayGoal();
      notifyListeners();
      debugPrint('[DailyGoalController] Sessão registrada. Progresso: $sessionsCompleted/$sessionsTarget');
    } catch (e) {
      _error = 'Erro ao registrar sessão: $e';
      debugPrint('[DailyGoalController] $_error');
      notifyListeners();
    }
  }

  /// Atualiza o número de sessões alvo para hoje
  Future<void> setTargetSessions(int newTarget) async {
    if (_todayGoal == null) return;
    if (newTarget < 1) newTarget = 1;
    try {
      _loading = true;
      _error = null;
      final updated = _todayGoal!.copyWith(
        targetSessionsPerDay: newTarget,
        completed: _todayGoal!.completedSessions >= newTarget,
        updatedAt: DateTime.now(),
      );
      await repository.updateGoal(updated);
      _todayGoal = updated;
      notifyListeners();
      debugPrint('[DailyGoalController] Meta atualizada para $newTarget sessões/dia');
    } catch (e) {
      _error = 'Erro ao atualizar meta: $e';
      debugPrint('[DailyGoalController] $_error');
      notifyListeners();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Retorna data atual no formato YYYY-MM-DD
  String _getTodayDate() {
    final now = DateTime.now();
    return '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  /// Recarrega dados
  Future<void> refresh() => _initToday();
}
