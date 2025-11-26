import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'historico_remote_data_source.dart';

/// Implementação Supabase do datasource remoto para histórico de meditação.
class HistoricoRemoteDataSourceImpl implements HistoricoRemoteDataSource {
  final SupabaseClient client;

  HistoricoRemoteDataSourceImpl({required this.client});

  @override
  Future<void> salvarSessao({
    required String userId,
    required int duracao_segundos,
    int? meditacao_id,
  }) async {
    try {
      await client.from('historico_usuario').insert({
        'user_id': userId,
        'duracao_segundos': duracao_segundos,
        'meditacao_id': meditacao_id,
        // 'data_sessao' e 'updated_at' são preenchidos automaticamente pelo Supabase
      });
      debugPrint('[HistoricoRemoteDataSource] Sessão salva com sucesso!');
    } catch (e) {
      debugPrint('[HistoricoRemoteDataSource] Erro ao salvar sessão: $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, int>> buscarEstatisticas({required String userId}) async {
    try {
      final response = await client
          .from('historico_usuario')
          .select('duracao_segundos')
          .eq('user_id', userId);

      final lista = List<Map<String, dynamic>>.from(response);

      // 1. Quantidade de vezes (tamanho da lista)
      final totalVezes = lista.length;

      // 2. Soma total do tempo em segundos
      int totalSegundos = 0;
      for (var item in lista) {
        totalSegundos += (item['duracao_segundos'] as int);
      }

      // Converte para minutos
      final totalMinutos = (totalSegundos / 60).round();

      debugPrint(
          '[HistoricoRemoteDataSource] Estatísticas: $totalVezes vezes, $totalMinutos minutos');

      return {
        'vezes': totalVezes,
        'minutos': totalMinutos,
      };
    } catch (e) {
      debugPrint('[HistoricoRemoteDataSource] Erro ao buscar estatísticas: $e');
      rethrow;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> obterTodas({required String userId}) async {
    try {
      final response = await client
          .from('historico_usuario')
          .select()
          .eq('user_id', userId)
          .order('data_sessao', ascending: false);

      debugPrint(
          '[HistoricoRemoteDataSource] Total de sessões obtidas: ${response.length}');

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('[HistoricoRemoteDataSource] Erro ao obter sessões: $e');
      rethrow;
    }
  }
}
