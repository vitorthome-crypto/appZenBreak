import '../entities/reminder.dart';
import '../repositories/reminders_repository.dart';

/// Use case para obter todos os lembretes
class GetAllRemindersUseCase {
  final RemindersRepository _repository;

  GetAllRemindersUseCase({required RemindersRepository repository})
      : _repository = repository;

  Future<List<Reminder>> call() async {
    return await _repository.getAll();
  }
}

/// Use case para buscar lembretes com filtros
class SearchRemindersUseCase {
  final RemindersRepository _repository;

  SearchRemindersUseCase({required RemindersRepository repository})
      : _repository = repository;

  Future<List<Reminder>> call({
    String? title,
    String? type,
    String? priority,
    bool? isActive,
  }) async {
    return await _repository.search(
      title: title,
      type: type,
      priority: priority,
      isActive: isActive,
    );
  }
}

/// Use case para criar um novo lembrete
class CreateReminderUseCase {
  final RemindersRepository _repository;

  CreateReminderUseCase({required RemindersRepository repository})
      : _repository = repository;

  Future<Reminder> call(Reminder reminder) async {
    if (!reminder.isValid) {
      throw ArgumentError('Lembrete inválido');
    }
    return await _repository.create(reminder);
  }
}

/// Use case para atualizar um lembrete
class UpdateReminderUseCase {
  final RemindersRepository _repository;

  UpdateReminderUseCase({required RemindersRepository repository})
      : _repository = repository;

  Future<Reminder> call(Reminder reminder) async {
    if (!reminder.isValid) {
      throw ArgumentError('Lembrete inválido');
    }
    return await _repository.update(reminder);
  }
}

/// Use case para deletar um lembrete
class DeleteReminderUseCase {
  final RemindersRepository _repository;

  DeleteReminderUseCase({required RemindersRepository repository})
      : _repository = repository;

  Future<void> call(int id) async {
    if (id <= 0) {
      throw ArgumentError('ID deve ser maior que zero');
    }
    return await _repository.delete(id);
  }
}

/// Use case para ativar/desativar um lembrete
class ToggleReminderActiveUseCase {
  final RemindersRepository _repository;

  ToggleReminderActiveUseCase({required RemindersRepository repository})
      : _repository = repository;

  Future<void> call(int id, bool isActive) async {
    if (id <= 0) {
      throw ArgumentError('ID deve ser maior que zero');
    }
    return await _repository.toggleActive(id, isActive);
  }
}

/// Use case para obter lembretes atrasados
class GetOverdueRemindersUseCase {
  final RemindersRepository _repository;

  GetOverdueRemindersUseCase({required RemindersRepository repository})
      : _repository = repository;

  Future<List<Reminder>> call() async {
    return await _repository.getOverdue();
  }
}

/// Use case para obter lembretes próximos
class GetComingSoonRemindersUseCase {
  final RemindersRepository _repository;

  GetComingSoonRemindersUseCase({required RemindersRepository repository})
      : _repository = repository;

  Future<List<Reminder>> call() async {
    return await _repository.getComingSoon();
  }
}
