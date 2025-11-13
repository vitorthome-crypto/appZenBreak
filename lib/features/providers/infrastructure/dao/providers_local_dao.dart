import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../dtos/provider_dto.dart';

/// Interface do DAO local para Fornecedores
abstract class FornecedoresLocalDao {
  /// Retorna todos os fornecedores do cache
  Future<List<FornecedorDto>> listAll();

  /// Retorna um fornecedor pelo ID
  Future<FornecedorDto?> getById(int id);

  /// Insere ou atualiza uma lista de fornecedores
  Future<void> upsertAll(List<FornecedorDto> dtos);

  /// Limpa todo o cache de fornecedores
  Future<void> clear();
}

/// Implementação do DAO usando SharedPreferences
class FornecedoresLocalDaoSharedPrefs implements FornecedoresLocalDao {
  static const _cacheKey = 'fornecedores_cache_v1';

  Future<SharedPreferences> get _prefs async => SharedPreferences.getInstance();

  @override
  Future<void> upsertAll(List<FornecedorDto> dtos) async {
    final prefs = await _prefs;
    final raw = prefs.getString(_cacheKey);
    final Map<int, Map<String, dynamic>> current = {};

    // Carregar cache existente
    if (raw != null && raw.isNotEmpty) {
      try {
        final List<dynamic> list = jsonDecode(raw) as List<dynamic>;
        for (final e in list) {
          final m = Map<String, dynamic>.from(e as Map);
          current[m['id'] as int] = m;
        }
      } catch (_) {}
    }

    // Mesclar com novos dados (upsert)
    for (final dto in dtos) {
      current[dto.id] = dto.toMap();
    }

    // Persistir
    final merged = current.values.toList();
    await prefs.setString(_cacheKey, jsonEncode(merged));
  }

  @override
  Future<List<FornecedorDto>> listAll() async {
    final prefs = await _prefs;
    final raw = prefs.getString(_cacheKey);
    if (raw == null || raw.isEmpty) return [];

    try {
      final List<dynamic> list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => FornecedorDto.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<FornecedorDto?> getById(int id) async {
    final prefs = await _prefs;
    final raw = prefs.getString(_cacheKey);
    if (raw == null || raw.isEmpty) return null;

    try {
      final List<dynamic> list = jsonDecode(raw) as List<dynamic>;
      for (final e in list) {
        final m = Map<String, dynamic>.from(e as Map);
        if (m['id'] == id) return FornecedorDto.fromMap(m);
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
