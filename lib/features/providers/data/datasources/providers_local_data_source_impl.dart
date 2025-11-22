import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../infrastructure/dtos/provider_dto.dart';
import 'providers_local_data_source.dart';

/// Implementação de [ProvidersLocalDataSource] usando SharedPreferences
/// Responsável por persistência e recuperação de dados locais de fornecedores
class ProvidersLocalDataSourceImpl implements ProvidersLocalDataSource {
  static const String _cacheKey = 'fornecedores_cache_v1';

  final SharedPreferences _prefs;

  ProvidersLocalDataSourceImpl({required SharedPreferences prefs})
      : _prefs = prefs;

  @override
  Future<List<FornecedorDto>> getAll() async {
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
      final all = await getAll();
      return all.firstWhereOrNull((f) => f.id == id);
    } catch (e) {
      print('Erro ao obter fornecedor por ID: $e');
      return null;
    }
  }

  @override
  Future<void> saveAll(List<FornecedorDto> fornecedores) async {
    try {
      final existing = await getAll();
      
      // Criar um mapa com IDs já existentes para fácil lookup
      final existingMap = {for (var f in existing) f.id: f};
      
      // Atualizar ou adicionar novos fornecedores
      for (var fornecedor in fornecedores) {
        existingMap[fornecedor.id] = fornecedor;
      }

      // Converter mapa de volta para lista
      final merged = existingMap.values.toList();
      
      // Serializar e salvar
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
  Future<void> save(FornecedorDto fornecedor) async {
    try {
      await saveAll([fornecedor]);
    } catch (e) {
      print('Erro ao salvar fornecedor: $e');
      rethrow;
    }
  }

  @override
  Future<void> delete(int id) async {
    try {
      final all = await getAll();
      final filtered = all.where((f) => f.id != id).toList();
      
      if (filtered.isEmpty) {
        await _prefs.remove(_cacheKey);
      } else {
        final jsonString = jsonEncode(
          filtered.map((f) => f.toMap()).toList(),
        );
        await _prefs.setString(_cacheKey, jsonString);
      }
    } catch (e) {
      print('Erro ao deletar fornecedor: $e');
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

/// Extension para firstWhereOrNull (compatibilidade com versões antigas de Dart)
extension FirstWhereOrNullExtension<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T) test) {
    for (final element in this) {
      if (test(element)) {
        return element;
      }
    }
    return null;
  }
}
