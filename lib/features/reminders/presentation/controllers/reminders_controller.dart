import 'package:flutter/foundation.dart';
import '../../domain/entities/reminder.dart';
import '../../domain/repositories/reminders_repository.dart';
import '../../domain/usecases/reminder_usecases.dart';

/// Controller responsável pela lógica de apresentação de lembretes
class RemindersController extends ChangeNotifier {
  final RemindersRepository repository;

  late GetAllRemindersUseCase _getAllReminders;
  late CreateReminderUseCase _createReminder;
  late UpdateReminderUseCase _updateReminder;
  late DeleteReminderUseCase _deleteReminder;
  late ToggleReminderActiveUseCase _toggleActive;
  late GetOverdueRemindersUseCase _getOverdueReminders;
  late GetComingSoonRemindersUseCase _getComingSoonReminders;

  List<Reminder> _reminders = [];
  List<Reminder> _filteredReminders = [];
  String _searchQuery = '';
  String? _filterType;
  String? _filterPriority;
  bool _sortDescending = true;
  bool _isLoading = false;
  String? _error;

  RemindersController({required this.repository}) {
    _getAllReminders = GetAllRemindersUseCase(repository: repository);
    _createReminder = CreateReminderUseCase(repository: repository);
    _updateReminder = UpdateReminderUseCase(repository: repository);
    _deleteReminder = DeleteReminderUseCase(repository: repository);
    _toggleActive = ToggleReminderActiveUseCase(repository: repository);
    _getOverdueReminders = GetOverdueRemindersUseCase(repository: repository);
    _getComingSoonReminders = GetComingSoonRemindersUseCase(repository: repository);
  }

  // Getters
  List<Reminder> get reminders => _filteredReminders;
  String get searchQuery => _searchQuery;
  String? get filterType => _filterType;
  String? get filterPriority => _filterPriority;
  bool get sortDescending => _sortDescending;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Carrega todos os lembretes e sincroniza com remoto
  Future<void> loadReminders() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _reminders = await _getAllReminders();
      _applyFilters();

      // Sincronização em background (não-bloqueante)
      _syncRemindersInBackground();
    } catch (e) {
      _error = 'Erro ao carregar lembretes: $e';
      _reminders = [];
      _filteredReminders = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Sincroniza lembretes locais com remoto em background
  void _syncRemindersInBackground() {
    // Fire-and-forget para não bloquear UI
    repository.syncWithRemote(_reminders).catchError((e) {
      print('⚠️ Erro ao sincronizar em background: $e');
      // Não atualiza UI - sincronização é operação melhorada
    });
  }

  /// Define a query de busca
  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  /// Define o filtro de tipo
  void setFilterType(String? type) {
    _filterType = type;
    _applyFilters();
  }

  /// Define o filtro de prioridade
  void setFilterPriority(String? priority) {
    _filterPriority = priority;
    _applyFilters();
  }

  /// Define a ordem de classificação
  void setSortDescending(bool descending) {
    _sortDescending = descending;
    _applyFilters();
  }

  /// Aplica todos os filtros e busca
  void _applyFilters() {
    List<Reminder> result = List.from(_reminders);

    // Aplica busca por texto
    if (_searchQuery.isNotEmpty) {
      result = result
          .where((r) =>
              r.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              r.description.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    // Aplica filtro de tipo
    if (_filterType != null) {
      result = result.where((r) => r.type == _filterType).toList();
    }

    // Aplica filtro de prioridade
    if (_filterPriority != null) {
      result = result.where((r) => r.priority == _filterPriority).toList();
    }

    // Aplica ordenação
    result.sort((a, b) {
      final comparison = a.scheduledAt.compareTo(b.scheduledAt);
      return _sortDescending ? -comparison : comparison;
    });

    _filteredReminders = result;
    notifyListeners();
  }

  /// Cria um novo lembrete
  Future<Reminder?> createReminder({
    required String title,
    required String description,
    required DateTime scheduledAt,
    required String type,
    required String priority,
  }) async {
    try {
      final reminder = Reminder(
        id: 0,
        title: title,
        description: description,
        scheduledAt: scheduledAt,
        type: type,
        priority: priority,
        isActive: true,
        createdAt: DateTime.now(),
      );
      final created = await _createReminder(reminder);
      await loadReminders();
      return created;
    } catch (e) {
      _error = 'Erro ao criar lembrete: $e';
      notifyListeners();
      return null;
    }
  }

  /// Atualiza um lembrete
  Future<Reminder?> updateReminder(Reminder reminder) async {
    try {
      final updated = await _updateReminder(reminder);
      await loadReminders();
      return updated;
    } catch (e) {
      _error = 'Erro ao atualizar lembrete: $e';
      notifyListeners();
      return null;
    }
  }

  /// Deleta um lembrete
  Future<bool> deleteReminder(int id) async {
    try {
      await _deleteReminder(id);
      await loadReminders();
      return true;
    } catch (e) {
      _error = 'Erro ao deletar lembrete: $e';
      notifyListeners();
      return false;
    }
  }

  /// Alterna ativo/inativo de um lembrete
  Future<bool> toggleReminderActive(int id, bool isActive) async {
    try {
      await _toggleActive(id, isActive);
      await loadReminders();
      return true;
    } catch (e) {
      _error = 'Erro ao atualizar lembrete: $e';
      notifyListeners();
      return false;
    }
  }

  /// Carrega lembretes atrasados
  Future<void> loadOverdueReminders() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _reminders = await _getOverdueReminders();
      _filteredReminders = List.from(_reminders);
    } catch (e) {
      _error = 'Erro ao carregar lembretes atrasados: $e';
      _reminders = [];
      _filteredReminders = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Carrega lembretes próximos
  Future<void> loadComingSoonReminders() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _reminders = await _getComingSoonReminders();
      _filteredReminders = List.from(_reminders);
    } catch (e) {
      _error = 'Erro ao carregar lembretes próximos: $e';
      _reminders = [];
      _filteredReminders = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Limpa os filtros
  void clearFilters() {
    _searchQuery = '';
    _filterType = null;
    _filterPriority = null;
    _sortDescending = true;
    _applyFilters();
  }
}
