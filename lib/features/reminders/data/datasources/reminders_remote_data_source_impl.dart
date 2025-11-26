import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/reminder_model.dart';
import 'reminders_remote_data_source.dart';

/// Implementação do datasource remoto usando Supabase
/// Sincroniza lembretes com backend
class RemindersRemoteDataSourceImpl implements RemindersRemoteDataSource {
  static const String _tableName = 'reminders';
  final SupabaseClient supabaseClient;

  RemindersRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<List<ReminderModel>> getAll() async {
    try {
      final response = await supabaseClient
          .from(_tableName)
          .select()
          .order('scheduledAt', ascending: true);

      return List<ReminderModel>.from(
        response.map((item) => ReminderModel.fromJson(item as Map<String, dynamic>)),
      );
    } catch (e) {
      throw Exception('Erro ao carregar lembretes do servidor: $e');
    }
  }

  @override
  Future<ReminderModel?> getById(int id) async {
    try {
      final response = await supabaseClient
          .from(_tableName)
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;
      return ReminderModel.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Erro ao carregar lembrete do servidor: $e');
    }
  }

  @override
  Future<List<ReminderModel>> search({
    String? title,
    String? type,
    String? priority,
    bool? isActive,
  }) async {
    try {
      var query = supabaseClient.from(_tableName).select();

      if (title != null && title.isNotEmpty) {
        query = query.ilike('title', '%$title%');
      }
      if (type != null) {
        query = query.eq('type', type);
      }
      if (priority != null) {
        query = query.eq('priority', priority);
      }
      if (isActive != null) {
        query = query.eq('isActive', isActive);
      }

      final response = await query.order('scheduledAt', ascending: true);

      return List<ReminderModel>.from(
        response.map((item) => ReminderModel.fromJson(item as Map<String, dynamic>)),
      );
    } catch (e) {
      throw Exception('Erro ao buscar lembretes: $e');
    }
  }

  @override
  Future<ReminderModel> create(ReminderModel reminder) async {
    try {
      final response = await supabaseClient
          .from(_tableName)
          .insert(reminder.toJson())
          .select()
          .single();

      return ReminderModel.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Erro ao criar lembrete no servidor: $e');
    }
  }

  @override
  Future<ReminderModel> update(ReminderModel reminder) async {
    try {
      final response = await supabaseClient
          .from(_tableName)
          .update(reminder.toJson())
          .eq('id', reminder.id)
          .select()
          .single();

      return ReminderModel.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Erro ao atualizar lembrete no servidor: $e');
    }
  }

  @override
  Future<void> delete(int id) async {
    try {
      await supabaseClient.from(_tableName).delete().eq('id', id);
    } catch (e) {
      throw Exception('Erro ao deletar lembrete do servidor: $e');
    }
  }

  @override
  Future<void> deleteMultiple(List<int> ids) async {
    try {
      for (final id in ids) {
        await supabaseClient.from(_tableName).delete().eq('id', id);
      }
    } catch (e) {
      throw Exception('Erro ao deletar múltiplos lembretes: $e');
    }
  }

  @override
  Future<void> toggleActive(int id, bool isActive) async {
    try {
      await supabaseClient
          .from(_tableName)
          .update({'isActive': isActive, 'updatedAt': DateTime.now().toIso8601String()})
          .eq('id', id);
    } catch (e) {
      throw Exception('Erro ao atualizar status do lembrete: $e');
    }
  }

  @override
  Future<List<ReminderModel>> getByType(String type) async {
    try {
      final response = await supabaseClient
          .from(_tableName)
          .select()
          .eq('type', type)
          .order('scheduledAt', ascending: true);

      return List<ReminderModel>.from(
        response.map((item) => ReminderModel.fromJson(item as Map<String, dynamic>)),
      );
    } catch (e) {
      throw Exception('Erro ao carregar lembretes por tipo: $e');
    }
  }

  @override
  Future<List<ReminderModel>> getOverdue() async {
    try {
      final now = DateTime.now().toIso8601String();
      final response = await supabaseClient
          .from(_tableName)
          .select()
          .lt('scheduledAt', now)
          .eq('isActive', true)
          .order('scheduledAt', ascending: false);

      return List<ReminderModel>.from(
        response.map((item) => ReminderModel.fromJson(item as Map<String, dynamic>)),
      );
    } catch (e) {
      throw Exception('Erro ao carregar lembretes atrasados: $e');
    }
  }

  @override
  Future<List<ReminderModel>> getComingSoon() async {
    try {
      final now = DateTime.now();
      final oneHourLater = now.add(const Duration(hours: 1));

      final response = await supabaseClient
          .from(_tableName)
          .select()
          .gt('scheduledAt', now.toIso8601String())
          .lt('scheduledAt', oneHourLater.toIso8601String())
          .eq('isActive', true)
          .order('scheduledAt', ascending: true);

      return List<ReminderModel>.from(
        response.map((item) => ReminderModel.fromJson(item as Map<String, dynamic>)),
      );
    } catch (e) {
      throw Exception('Erro ao carregar lembretes próximos: $e');
    }
  }

  @override
  Future<void> sync(List<ReminderModel> localReminders) async {
    try {
      // Sincronizar lembretes locais com servidor
      for (final reminder in localReminders) {
        final existing = await getById(reminder.id);
        if (existing == null) {
          // Se não existe no servidor, criar
          await create(reminder);
        } else if (reminder.updatedAt != null && 
                   existing.updatedAt != null &&
                   reminder.updatedAt!.isAfter(existing.updatedAt!)) {
          // Se local é mais recente, atualizar no servidor
          await update(reminder);
        }
      }

      // Remover do local lembretes que foram deletados no servidor
      final remoteReminders = await getAll();
      final remoteIds = remoteReminders.map((r) => r.id).toSet();
      final localIds = localReminders.map((r) => r.id).toSet();
      final deletedIds = localIds.difference(remoteIds);

      if (deletedIds.isNotEmpty) {
        await deleteMultiple(deletedIds.toList());
      }
    } catch (e) {
      throw Exception('Erro ao sincronizar dados: $e');
    }
  }
}
