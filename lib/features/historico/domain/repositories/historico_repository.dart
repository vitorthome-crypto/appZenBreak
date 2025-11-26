/// Interface do repositório para operações de histórico de meditação.
abstract class HistoricoRepository {
  /// Salva uma sessão de meditação.
  Future<void> salvarSessao({
    required String userId,
    required int duracao_segundos,
    int? meditacao_id,
  });

  /// Busca estatísticas de meditação do usuário (vezes e minutos).
  Future<Map<String, int>> buscarEstatisticas({required String userId});

  /// Obtém todas as sessões de meditação do usuário.
  Future<List<Map<String, dynamic>>> obterTodas({required String userId});
}
