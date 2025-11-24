import '../entities/reminder.dart';

/// Contrato de repositório para operações com lembretes
/// Define as operações disponíveis (CRUD)
abstract class RemindersRepository {
  /// Carrega todos os lembretes
  Future<List<Reminder>> getAll();

  /// Carrega um lembrete específico por ID
  Future<Reminder?> getById(int id);

  /// Busca lembretes por critérios
  Future<List<Reminder>> search({
    String? title,
    String? type,
    String? priority,
    bool? isActive,
  });

  /// Cria um novo lembrete
  Future<Reminder> create(Reminder reminder);

  /// Atualiza um lembrete existente
  Future<Reminder> update(Reminder reminder);

  /// Deleta um lembrete
  Future<void> delete(int id);

  /// Deleta múltiplos lembretes
  Future<void> deleteMultiple(List<int> ids);

  /// Ativa/desativa um lembrete
  Future<void> toggleActive(int id, bool isActive);

  /// Obtém lembretes por tipo
  Future<List<Reminder>> getByType(String type);

  /// Obtém lembretes atrasados
  Future<List<Reminder>> getOverdue();

  /// Obtém lembretes próximos (próxima 1 hora)
  Future<List<Reminder>> getComingSoon();
}
