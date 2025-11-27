import '../../domain/entities/daily_goal.dart';

/// DTO para serialização/desserialização de metas diárias
class DailyGoalDTO {
  final String id;
  final String date;
  final int targetSessionsPerDay;
  final int completedSessions;
  final bool completed;
  final String createdAt;
  final String updatedAt;

  DailyGoalDTO({
    required this.id,
    required this.date,
    required this.targetSessionsPerDay,
    required this.completedSessions,
    required this.completed,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Converte DTO para Entity
  DailyGoal toDomain() {
    return DailyGoal(
      id: id,
      date: date,
      targetSessionsPerDay: targetSessionsPerDay,
      completedSessions: completedSessions,
      completed: completed,
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
    );
  }

  /// Converte Entity para DTO
  factory DailyGoalDTO.fromDomain(DailyGoal domain) {
    return DailyGoalDTO(
      id: domain.id,
      date: domain.date,
      targetSessionsPerDay: domain.targetSessionsPerDay,
      completedSessions: domain.completedSessions,
      completed: domain.completed,
      createdAt: domain.createdAt.toIso8601String(),
      updatedAt: domain.updatedAt.toIso8601String(),
    );
  }

  /// Converte JSON para DTO
  factory DailyGoalDTO.fromJson(Map<String, dynamic> json) {
    return DailyGoalDTO(
      id: json['id'] as String,
      date: json['date'] as String,
      targetSessionsPerDay: json['target_sessions_per_day'] as int? ?? 1,
      completedSessions: json['completed_sessions'] as int? ?? 0,
      completed: json['completed'] as bool? ?? false,
      createdAt: json['created_at'] as String? ?? DateTime.now().toIso8601String(),
      updatedAt: json['updated_at'] as String? ?? DateTime.now().toIso8601String(),
    );
  }

  /// Converte DTO para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'target_sessions_per_day': targetSessionsPerDay,
      'completed_sessions': completedSessions,
      'completed': completed,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
