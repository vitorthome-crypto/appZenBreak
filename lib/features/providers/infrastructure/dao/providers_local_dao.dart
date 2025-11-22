import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../dtos/provider_dto.dart';

/// Interface abstrata para acesso a dados de fornecedores locais
abstract class FornecedoresLocalDao {
  /// Retorna todos os fornecedores armazenados localmente
  Future<List<FornecedorDto>> listAll();

  /// Retorna um fornecedor específico por ID
  Future<FornecedorDto?> getById(int id);

  /// Insere ou atualiza múltiplos fornecedores
  Future<void> upsertAll(List<FornecedorDto> fornecedores);

  /// Limpa o cache de fornecedores
  Future<void> clear();
}

/// Implementação do DAO usando SharedPreferences
class FornecedoresLocalDaoSharedPrefs implements FornecedoresLocalDao {
  static const String _cacheKey = 'fornecedores_cache_v1';

  final SharedPreferences _prefs;

  FornecedoresLocalDaoSharedPrefs({required SharedPreferences prefs})
      : _prefs = prefs;

  @override
  Future<List<FornecedorDto>> listAll() async {
    try {
      final jsonString = _prefs.getString(_cacheKey);
      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }

      final decoded = jsonDecode(jsonString) as List<dynamic>;
      return decoded
          .map((item) => FornecedorDto.fromMap(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Erro ao listar fornecedores: $e');
      return [];
    }
  }

  @override
  Future<FornecedorDto?> getById(int id) async {
    try {
      final all = await listAll();
      return all.firstWhereOrNull((f) => f.id == id);
    } catch (e) {
      print('Erro ao obter fornecedor por ID: $e');
      return null;
    }
  }

  /// Extension method para firstWhereOrNull (compatível com versões anteriores de Dart)
  /// Remove duplicatas ao mesclar (baseado em ID) e preserva novos dados
  @override
  Future<void> upsertAll(List<FornecedorDto> fornecedores) async {
    try {
      final existing = await listAll();

      // Cria mapa de IDs existentes para merge
      final existingMap = {for (final f in existing) f.id: f};

      // Sobrescreve com novos dados (upsert)
      for (final fornecedor in fornecedores) {
        existingMap[fornecedor.id] = fornecedor;
      }

      final merged = existingMap.values.toList();
      final jsonString = jsonEncode(
        merged.map((f) => f.toMap()).toList(),
      );

      await _prefs.setString(_cacheKey, jsonString);
    } catch (e) {
      print('Erro ao inserir/atualizar fornecedores: $e');
      rethrow;
    }
  }

  @override
  Future<void> clear() async {
    try {
      await _prefs.remove(_cacheKey);
    } catch (e) {
      print('Erro ao limpar cache de fornecedores: $e');
      rethrow;
    }
  }
}

/// Extension útil para buscar elemento em lista com fallback null
extension FirstWhereOrNull<T> on List<T> {
  T? firstWhereOrNull(bool Function(T) test) {
    try {
      return firstWhere(test);
    } catch (e) {
      return null;
    }
  }
}
