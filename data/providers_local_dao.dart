import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../lib/features/home/infrastructure/dtos/provider_dto.dart';

abstract class ProvidersLocalDao {
  Future<void> upsertAll(List<ProviderDto> dtos);
  Future<List<ProviderDto>> listAll();
  Future<ProviderDto?> getById(int id);
  Future<void> clear();
}

class ProvidersLocalDaoSharedPrefs implements ProvidersLocalDao {
  static const _cacheKey = 'providers_cache_v1';

  Future<SharedPreferences> get _prefs async => SharedPreferences.getInstance();

  @override
  Future<void> upsertAll(List<ProviderDto> dtos) async {
    final prefs = await _prefs;
    final raw = prefs.getString(_cacheKey);
    final Map<int, Map<String, dynamic>> current = {};

    if (raw != null && raw.isNotEmpty) {
      try {
        final List<dynamic> list = jsonDecode(raw) as List<dynamic>;
        for (final e in list) {
          final m = Map<String, dynamic>.from(e as Map);
          current[m['id'] as int] = m;
        }
      } catch (_) {}
    }

    for (final dto in dtos) {
      current[dto.id] = dto.toMap();
    }

    final merged = current.values.toList();
    await prefs.setString(_cacheKey, jsonEncode(merged));
  }

  @override
  Future<List<ProviderDto>> listAll() async {
    final prefs = await _prefs;
    final raw = prefs.getString(_cacheKey);
    if (raw == null || raw.isEmpty) return [];

    try {
      final List<dynamic> list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => ProviderDto.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<ProviderDto?> getById(int id) async {
    final prefs = await _prefs;
    final raw = prefs.getString(_cacheKey);
    if (raw == null || raw.isEmpty) return null;

    try {
      final List<dynamic> list = jsonDecode(raw) as List<dynamic>;
      for (final e in list) {
        final m = Map<String, dynamic>.from(e as Map);
        if (m['id'] == id) return ProviderDto.fromMap(m);
      }
    } catch (_) {}

    return null;
  }

  @override
  Future<void> clear() async {
    final prefs = await _prefs;
    await prefs.remove(_cacheKey);
  }
}