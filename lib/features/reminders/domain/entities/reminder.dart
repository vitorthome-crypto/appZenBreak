/// Entidade que representa um lembrete no domínio da aplicação
/// Contém apenas lógica de negócio e validações
class Reminder {
  final int id;
  final String title;
  final String description;
  final DateTime scheduledAt;
  final String type; // 'breathing', 'hydration', 'posture', 'meditation', 'custom'
  final String priority; // 'low', 'medium', 'high'
  final bool isActive;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Reminder({
    required this.id,
    required this.title,
    required this.description,
    required this.scheduledAt,
    required this.type,
    required this.priority,
    required this.isActive,
    this.metadata,
    required this.createdAt,
    this.updatedAt,
  }) : assert(
    title.isNotEmpty,
    'Título não pode estar vazio',
  );

  /// Validações de negócio
  bool get isOverdue => scheduledAt.isBefore(DateTime.now()) && isActive;

  bool get isComingSoon {
    final now = DateTime.now();
    final oneHourLater = now.add(const Duration(hours: 1));
    return scheduledAt.isAfter(now) && scheduledAt.isBefore(oneHourLater) && isActive;
  }

  bool get isValid => title.isNotEmpty && id > 0;

  /// Formata a data agendada para exibição
  String get formattedScheduledAt {
    final now = DateTime.now();
    final difference = scheduledAt.difference(now);

    if (isOverdue) {
      return 'Atrasado há ${_formatDuration(difference.abs())}';
    }

    if (isComingSoon) {
      return 'Em ${_formatDuration(difference)}';
    }

    if (scheduledAt.day == now.day) {
      return 'Hoje às ${_timeFormat(scheduledAt)}';
    }

    if (scheduledAt.day == now.add(const Duration(days: 1)).day) {
      return 'Amanhã às ${_timeFormat(scheduledAt)}';
    }

    return '${_dateFormat(scheduledAt)} às ${_timeFormat(scheduledAt)}';
  }

  String _formatDuration(Duration d) {
    if (d.inMinutes < 60) return '${d.inMinutes}m';
    if (d.inHours < 24) return '${d.inHours}h ${d.inMinutes % 60}m';
    return '${d.inDays}d';
  }

  String _timeFormat(DateTime dt) => '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  String _dateFormat(DateTime dt) => '${dt.day}/${dt.month}/${dt.year}';

  /// Obtém a cor baseada na prioridade
  String get priorityColor => {
    'low': '0xFF4CAF50',    // Verde
    'medium': '0xFFFFC107', // Âmbar
    'high': '0xFFFF5252',   // Vermelho
  }[priority] ?? '0xFF9E9E9E'; // Cinza padrão

  /// Obtém o ícone baseado no tipo
  String get typeIcon => {
    'breathing': '🫁',
    'hydration': '💧',
    'posture': '🧘',
    'meditation': '🧘‍♂️',
    'custom': '⏰',
  }[type] ?? '⏰';

  /// Obtém o label legível do tipo
  String get typeLabel => {
    'breathing': 'Respiração',
    'hydration': 'Hidratação',
    'posture': 'Postura',
    'meditation': 'Meditação',
    'custom': 'Customizado',
  }[type] ?? 'Tipo desconhecido';

  /// Obtém o label legível da prioridade
  String get priorityLabel => {
    'low': 'Baixa',
    'medium': 'Média',
    'high': 'Alta',
  }[priority] ?? 'Desconhecida';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Reminder &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          scheduledAt == other.scheduledAt;

  @override
  int get hashCode => id.hashCode ^ title.hashCode ^ scheduledAt.hashCode;

  @override
  String toString() => 'Reminder(id: $id, title: $title, type: $type, scheduledAt: $scheduledAt)';

  /// Método para criar uma cópia com alterações
  Reminder copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? scheduledAt,
    String? type,
    String? priority,
    bool? isActive,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Reminder(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      isActive: isActive ?? this.isActive,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
