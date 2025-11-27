import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../domain/entities/daily_goal.dart';
import '../models/daily_goal_dto.dart';

/// Interface para persistência local de metas diárias
abstract class DailyGoalLocalDataSource {
  Future<DailyGoal?> getTodayGoal();
  Future<DailyGoal?> getGoalByDate(String date);
  Future<List<DailyGoal>> getGoalsByDateRange(String startDate, String endDate);
  Future<void> saveGoal(DailyGoal goal);
  Future<void> incrementCompletedSessions(String date);
}

/// Implementação com SharedPreferences
class DailyGoalLocalDataSourceImpl implements DailyGoalLocalDataSource {
  final SharedPreferences prefs;

  DailyGoalLocalDataSourceImpl({required this.prefs});

  /// Chave para armazenar dados de metas diárias
  static const String _goalsPrefix = 'daily_goals_';

  /// Retorna a data atual no formato YYYY-MM-DD
  String _getTodayDate() {
    final now = DateTime.now();
    return '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  @override
  Future<DailyGoal?> getTodayGoal() async {
    return getGoalByDate(_getTodayDate());
  }

  @override
  Future<DailyGoal?> getGoalByDate(String date) async {
    try {
      final key = '$_goalsPrefix$date';
      final jsonStr = prefs.getString(key);
      if (jsonStr == null) return null;

      final json = _parseJson(jsonStr);
      final dto = DailyGoalDTO.fromJson(json);
      return dto.toDomain();
    } catch (e) {
      debugPrint('[DailyGoalLocalDataSource] Erro ao buscar meta: $e');
      return null;
    }
  }

  @override
  Future<List<DailyGoal>> getGoalsByDateRange(String startDate, String endDate) async {
    try {
      final start = DateTime.parse(startDate);
      final end = DateTime.parse(endDate);
      final goals = <DailyGoal>[];

      // Iterar por cada dia no intervalo
      for (var date = start; date.isBefore(end) || date.isAtSameMomentAs(end); date = date.add(const Duration(days: 1))) {
        final dateStr = '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        final goal = await getGoalByDate(dateStr);
        if (goal != null) goals.add(goal);
      }

      return goals;
    } catch (e) {
      debugPrint('[DailyGoalLocalDataSource] Erro ao buscar intervalo: $e');
      return [];
    }
  }

  @override
  Future<void> saveGoal(DailyGoal goal) async {
    try {
      final key = '$_goalsPrefix${goal.date}';
      final dto = DailyGoalDTO.fromDomain(goal);
      final jsonStr = _encodeJson(dto.toJson());
      await prefs.setString(key, jsonStr);
      debugPrint('[DailyGoalLocalDataSource] Meta salva para ${goal.date}');
    } catch (e) {
      debugPrint('[DailyGoalLocalDataSource] Erro ao salvar meta: $e');
      rethrow;
    }
  }

  @override
  Future<void> incrementCompletedSessions(String date) async {
    try {
      var goal = await getGoalByDate(date);
      
      if (goal == null) {
        // Criar nova meta se não existir
        goal = DailyGoal.create(date: date, completedSessions: 1);
      } else {
        // Incrementar sessões completadas
        final newCompleted = goal.completedSessions + 1;
        goal = goal.copyWith(
          completedSessions: newCompleted,
          completed: newCompleted >= goal.targetSessionsPerDay,
          updatedAt: DateTime.now(),
        );
      }

      await saveGoal(goal);
    } catch (e) {
      debugPrint('[DailyGoalLocalDataSource] Erro ao incrementar sessões: $e');
      rethrow;
    }
  }

  /// Helper para converter Map para JSON string
  String _encodeJson(Map<String, dynamic> json) {
    return jsonEncode(json);
  }

  /// Helper para fazer parse de JSON string
  Map<String, dynamic> _parseJson(String jsonStr) {
    return jsonDecode(jsonStr) as Map<String, dynamic>;
  }
}
