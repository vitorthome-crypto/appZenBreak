import '../models/reminder_model.dart';

/// Contrato para operações remotas de lembretes no Supabase
abstract class RemindersRemoteDataSource {
  /// Carrega todos os lembretes do servidor
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

  /// Cria um novo lembrete no servidor
  Future<ReminderModel> create(ReminderModel reminder);

  /// Atualiza um lembrete no servidor
  Future<ReminderModel> update(ReminderModel reminder);

  /// Deleta um lembrete do servidor
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

  /// Sincroniza dados locais com servidor
  Future<void> sync(List<ReminderModel> localReminders);
}
