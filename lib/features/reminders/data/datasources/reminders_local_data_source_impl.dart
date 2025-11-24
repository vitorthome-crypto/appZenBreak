import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/reminder_model.dart';
import 'reminders_local_data_source.dart';

/// Implementação do datasource local usando SharedPreferences
class RemindersLocalDataSourceImpl implements RemindersLocalDataSource {
  static const String _remindersKey = 'reminders_list';
  static const String _nextIdKey = 'reminders_next_id';

  final SharedPreferences prefs;

  RemindersLocalDataSourceImpl({required this.prefs});

  /// Gera o próximo ID único
  int _getNextId() {
    final currentId = prefs.getInt(_nextIdKey) ?? 1;
    prefs.setInt(_nextIdKey, currentId + 1);
    return currentId;
  }

  /// Carrega todos os lembretes do armazenamento
  List<ReminderModel> _loadAll() {
    final jsonString = prefs.getString(_remindersKey) ?? '[]';
    final jsonList = jsonDecode(jsonString) as List<dynamic>;
    return jsonList.map((item) => ReminderModel.fromJson(item as Map<String, dynamic>)).toList();
  }

  /// Salva todos os lembretes no armazenamento
  Future<void> _saveAll(List<ReminderModel> reminders) async {
    final jsonList = reminders.map((r) => r.toJson()).toList();
    final jsonString = jsonEncode(jsonList);
    await prefs.setString(_remindersKey, jsonString);
  }

  @override
  Future<List<ReminderModel>> getAll() async {
    return _loadAll();
  }

  @override
  Future<ReminderModel?> getById(int id) async {
    final reminders = _loadAll();
    try {
      return reminders.firstWhere((r) => r.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<ReminderModel>> search({
    String? title,
    String? type,
    String? priority,
    bool? isActive,
  }) async {
    final reminders = _loadAll();
    return reminders.where((r) {
      if (title != null && !r.title.toLowerCase().contains(title.toLowerCase())) return false;
      if (type != null && r.type != type) return false;
      if (priority != null && r.priority != priority) return false;
      if (isActive != null && r.isActive != isActive) return false;
      return true;
    }).toList();
  }

  @override
  Future<ReminderModel> create(ReminderModel reminder) async {
    final reminders = _loadAll();
    final id = _getNextId();
    final newReminder = ReminderModel(
      id: id,
      title: reminder.title,
      description: reminder.description,
      scheduledAt: reminder.scheduledAt,
      type: reminder.type,
      priority: reminder.priority,
      isActive: reminder.isActive,
      metadata: reminder.metadata,
      createdAt: DateTime.now(),
      updatedAt: null,
    );
    reminders.add(newReminder);
    await _saveAll(reminders);
    return newReminder;
  }

  @override
  Future<ReminderModel> update(ReminderModel reminder) async {
    final reminders = _loadAll();
    final index = reminders.indexWhere((r) => r.id == reminder.id);
    if (index == -1) {
      throw Exception('Lembrete não encontrado');
    }
    final updated = ReminderModel(
      id: reminder.id,
      title: reminder.title,
      description: reminder.description,
      scheduledAt: reminder.scheduledAt,
      type: reminder.type,
      priority: reminder.priority,
      isActive: reminder.isActive,
      metadata: reminder.metadata,
      createdAt: reminders[index].createdAt,
      updatedAt: DateTime.now(),
    );
    reminders[index] = updated;
    await _saveAll(reminders);
    return updated;
  }

  @override
  Future<void> delete(int id) async {
    final reminders = _loadAll();
    reminders.removeWhere((r) => r.id == id);
    await _saveAll(reminders);
  }

  @override
  Future<void> deleteMultiple(List<int> ids) async {
    final reminders = _loadAll();
    reminders.removeWhere((r) => ids.contains(r.id));
    await _saveAll(reminders);
  }

  @override
  Future<void> toggleActive(int id, bool isActive) async {
    final reminders = _loadAll();
    final index = reminders.indexWhere((r) => r.id == id);
    if (index != -1) {
      final reminder = reminders[index];
      reminders[index] = ReminderModel(
        id: reminder.id,
        title: reminder.title,
        description: reminder.description,
        scheduledAt: reminder.scheduledAt,
        type: reminder.type,
        priority: reminder.priority,
        isActive: isActive,
        metadata: reminder.metadata,
        createdAt: reminder.createdAt,
        updatedAt: DateTime.now(),
      );
      await _saveAll(reminders);
    }
  }

  @override
  Future<List<ReminderModel>> getByType(String type) async {
    final reminders = _loadAll();
    return reminders.where((r) => r.type == type).toList();
  }

  @override
  Future<List<ReminderModel>> getOverdue() async {
    final reminders = _loadAll();
    final now = DateTime.now();
    return reminders.where((r) => r.scheduledAt.isBefore(now) && r.isActive).toList();
  }

  @override
  Future<List<ReminderModel>> getComingSoon() async {
    final reminders = _loadAll();
    final now = DateTime.now();
    final oneHourLater = now.add(const Duration(hours: 1));
    return reminders.where((r) => r.scheduledAt.isAfter(now) && r.scheduledAt.isBefore(oneHourLater) && r.isActive).toList();
  }

  @override
  Future<void> clear() async {
    await prefs.remove(_remindersKey);
  }
}
