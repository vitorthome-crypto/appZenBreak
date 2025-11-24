import '../models/reminder_model.dart';

/// Contrato para operações de armazenamento local de lembretes
abstract class RemindersLocalDataSource {
  /// Carrega todos os lembretes
  Future<List<ReminderModel>> getAll();

  /// Carrega um lembrete específico por ID
  Future<ReminderModel?> getById(int id);

  /// Busca lembretes por critérios
  Future<List<ReminderModel>> search({
    String? title,
    String? type,
    String? priority,
    bool? isActive,
  });

  /// Salva um novo lembrete
  Future<ReminderModel> create(ReminderModel reminder);

  /// Atualiza um lembrete existente
  Future<ReminderModel> update(ReminderModel reminder);

  /// Deleta um lembrete
  Future<void> delete(int id);

  /// Deleta múltiplos lembretes
  Future<void> deleteMultiple(List<int> ids);

  /// Ativa/desativa um lembrete
  Future<void> toggleActive(int id, bool isActive);

  /// Obtém lembretes por tipo
  Future<List<ReminderModel>> getByType(String type);

  /// Obtém lembretes atrasados
  Future<List<ReminderModel>> getOverdue();

  /// Obtém lembretes próximos (próxima 1 hora)
  Future<List<ReminderModel>> getComingSoon();

  /// Limpa todos os lembretes
  Future<void> clear();
}
