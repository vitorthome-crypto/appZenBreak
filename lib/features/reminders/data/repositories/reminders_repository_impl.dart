import '../../domain/entities/reminder.dart';
import '../../domain/repositories/reminders_repository.dart';
import '../datasources/reminders_local_data_source.dart';
import '../models/reminder_model.dart';

/// Implementação do repositório de lembretes
/// Coordena as operações entre datasources
class RemindersRepositoryImpl implements RemindersRepository {
  final RemindersLocalDataSource localDataSource;

  RemindersRepositoryImpl({required this.localDataSource});

  @override
  Future<List<Reminder>> getAll() async {
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
    return created.toEntity();
  }

  @override
  Future<Reminder> update(Reminder reminder) async {
    final model = ReminderModel.fromEntity(reminder);
    final updated = await localDataSource.update(model);
    return updated.toEntity();
  }

  @override
  Future<void> delete(int id) async {
    await localDataSource.delete(id);
  }

  @override
  Future<void> deleteMultiple(List<int> ids) async {
    await localDataSource.deleteMultiple(ids);
  }

  @override
  Future<void> toggleActive(int id, bool isActive) async {
    await localDataSource.toggleActive(id, isActive);
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
}
