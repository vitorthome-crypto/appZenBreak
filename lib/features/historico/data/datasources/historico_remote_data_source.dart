/// Interface para operações remotas do histórico de meditação no Supabase.
abstract class HistoricoRemoteDataSource {
  /// Salva uma sessão de meditação no histórico.
  /// 
  /// Parâmetros:
  /// - [userId]: ID do usuário autenticado
  /// - [duracao_segundos]: Duração da meditação em segundos
  /// - [meditacao_id]: ID da meditação (opcional)
  Future<void> salvarSessao({
    String? userId,
    required int duracao_segundos,
    int? meditacao_id,
    bool parcial = false,
  });

  /// Busca estatísticas de meditação do usuário.
  /// 
  /// Retorna um mapa com:
  /// - 'vezes': quantidade total de sessões
  /// - 'minutos': tempo total em minutos
  Future<Map<String, int>> buscarEstatisticas({String? userId});

  /// Obtém todas as sessões de meditação do usuário.
  /// 
  /// Retorna uma lista de mapas com os dados de cada sessão.
  Future<List<Map<String, dynamic>>> obterTodas({String? userId});
}
