import '../../domain/entities/reminder.dart';

/// Modelo de dados para Reminder (com serialização)
class ReminderModel extends Reminder {
  ReminderModel({
    required int id,
    required String title,
    required String description,
    required DateTime scheduledAt,
    required String type,
    required String priority,
    required bool isActive,
    Map<String, dynamic>? metadata,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) : super(
    id: id,
    title: title,
    description: description,
    scheduledAt: scheduledAt,
    type: type,
    priority: priority,
    isActive: isActive,
    metadata: metadata,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  /// Converte JSON para ReminderModel
  factory ReminderModel.fromJson(Map<String, dynamic> json) {
    return ReminderModel(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      scheduledAt: json['scheduledAt'] is DateTime
          ? json['scheduledAt'] as DateTime
          : DateTime.parse(json['scheduledAt'] as String? ?? DateTime.now().toIso8601String()),
      type: json['type'] as String? ?? 'custom',
      priority: json['priority'] as String? ?? 'medium',
      isActive: json['isActive'] as bool? ?? true,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: json['createdAt'] is DateTime
          ? json['createdAt'] as DateTime
          : DateTime.parse(json['createdAt'] as String? ?? DateTime.now().toIso8601String()),
      updatedAt: json['updatedAt'] != null
          ? json['updatedAt'] is DateTime
              ? json['updatedAt'] as DateTime
              : DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  /// Converte ReminderModel para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'scheduledAt': scheduledAt.toIso8601String(),
      'type': type,
      'priority': priority,
      'isActive': isActive,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Converte Reminder (domain) para ReminderModel (data)
  factory ReminderModel.fromEntity(Reminder reminder) {
    return ReminderModel(
      id: reminder.id,
      title: reminder.title,
      description: reminder.description,
      scheduledAt: reminder.scheduledAt,
      type: reminder.type,
      priority: reminder.priority,
      isActive: reminder.isActive,
      metadata: reminder.metadata,
      createdAt: reminder.createdAt,
      updatedAt: reminder.updatedAt,
    );
  }

  /// Converte ReminderModel para Reminder (domain)
  Reminder toEntity() {
    return Reminder(
      id: id,
      title: title,
      description: description,
      scheduledAt: scheduledAt,
      type: type,
      priority: priority,
      isActive: isActive,
      metadata: metadata,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
