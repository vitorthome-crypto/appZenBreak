import '../../domain/entities/reminder.dart';
import '../../domain/repositories/reminders_repository.dart';
import '../datasources/reminders_local_data_source.dart';
import '../datasources/reminders_remote_data_source.dart';
import '../models/reminder_model.dart';

/// Implementação do repositório de lembretes
/// Coordena as operações entre datasources (local + remoto com fallback)
/// Estratégia: Offline-first com sincronização automática
class RemindersRepositoryImpl implements RemindersRepository {
  final RemindersLocalDataSource localDataSource;
  final RemindersRemoteDataSource? remoteDataSource;

  RemindersRepositoryImpl({
    required this.localDataSource,
    this.remoteDataSource,
  });

  @override
  Future<List<Reminder>> getAll() async {
    try {
      if (remoteDataSource != null) {
        // Tenta buscar remoto primeiro (cloud-primary com fallback)
        try {
          final remoteModels = await remoteDataSource!.getAll();
          // Sincroniza com cache local
          for (var model in remoteModels) {
            await localDataSource.create(model);
          }
          return remoteModels.map((m) => m.toEntity()).toList();
        } catch (e) {
          // Log mas continua com fallback
          print('⚠️ Erro ao buscar remoto: $e, usando cache local');
        }
      }
    } catch (e) {
      print('❌ Erro crítico ao sincronizar: $e');
    }

    // Fallback sempre para local (offline-first)
    final models = await localDataSource.getAll();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<Reminder?> getById(int id) async {
    final model = await localDataSource.getById(id);
    return model?.toEntity();
  }

  @override
  Future<List<Reminder>> search({
    String? title,
    String? type,
    String? priority,
    bool? isActive,
  }) async {
    final models = await localDataSource.search(
      title: title,
      type: type,
      priority: priority,
      isActive: isActive,
    );
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<Reminder> create(Reminder reminder) async {
    final model = ReminderModel.fromEntity(reminder);
    final created = await localDataSource.create(model);

    // Sincroniza com remoto se disponível (não-bloqueante)
    if (remoteDataSource != null) {
      try {
        await remoteDataSource!.create(created);
      } catch (e) {
        print('⚠️ Erro ao sincronizar criação remota: $e');
        // Continua mesmo se sync falhar (será sincronizado depois)
      }
    }

    return created.toEntity();
  }

  @override
  Future<Reminder> update(Reminder reminder) async {
    final model = ReminderModel.fromEntity(reminder);
    final updated = await localDataSource.update(model);

    // Sincroniza com remoto se disponível (não-bloqueante)
    if (remoteDataSource != null) {
      try {
        await remoteDataSource!.update(updated);
      } catch (e) {
        print('⚠️ Erro ao sincronizar atualização remota: $e');
      }
    }

    return updated.toEntity();
  }

  @override
  Future<void> delete(int id) async {
    await localDataSource.delete(id);

    // Sincroniza com remoto se disponível (não-bloqueante)
    if (remoteDataSource != null) {
      try {
        await remoteDataSource!.delete(id);
      } catch (e) {
        print('⚠️ Erro ao sincronizar deleção remota: $e');
      }
    }
  }

  @override
  Future<void> deleteMultiple(List<int> ids) async {
    await localDataSource.deleteMultiple(ids);

    // Sincroniza com remoto se disponível (não-bloqueante)
    if (remoteDataSource != null) {
      try {
        await remoteDataSource!.deleteMultiple(ids);
      } catch (e) {
        print('⚠️ Erro ao sincronizar deleção múltipla remota: $e');
      }
    }
  }

  @override
  Future<void> toggleActive(int id, bool isActive) async {
    await localDataSource.toggleActive(id, isActive);

    // Sincroniza com remoto se disponível (não-bloqueante)
    if (remoteDataSource != null) {
      try {
        await remoteDataSource!.toggleActive(id, isActive);
      } catch (e) {
        print('⚠️ Erro ao sincronizar toggle remoto: $e');
      }
    }
  }

  @override
  Future<List<Reminder>> getByType(String type) async {
    final models = await localDataSource.getByType(type);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<Reminder>> getOverdue() async {
    final models = await localDataSource.getOverdue();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<Reminder>> getComingSoon() async {
    final models = await localDataSource.getComingSoon();
    return models.map((m) => m.toEntity()).toList();
  }

  /// Sincroniza lembretes locais com remoto (implementação de push/pull)
  /// Estratégia: Envia mudanças locais, depois puxa atualizações remotas
  @override
  Future<void> syncWithRemote(List<Reminder> localReminders) async {
    if (remoteDataSource == null) {
      print('ℹ️ Remote datasource não configurado, sincronização ignorada');
      return;
    }

    try {
      print('🔄 Iniciando sincronização com Supabase...');

      // Converte entidades para modelos
      final localModels = localReminders
          .map((r) => ReminderModel.fromEntity(r))
          .toList();

      // Delegação ao datasource remoto (coordena push/pull)
      await remoteDataSource!.sync(localModels);

      print('✅ Sincronização concluída com sucesso');
    } catch (e) {
      print('❌ Erro durante sincronização: $e');
      // Não lança erro - sincronização é operação melhorada (best-effort)
    }
  }
}
