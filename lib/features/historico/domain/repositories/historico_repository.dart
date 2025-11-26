/// Interface do repositório para operações de histórico de meditação.
abstract class HistoricoRepository {
  /// Salva uma sessão de meditação.
  Future<void> salvarSessao({
    String? userId,
    required int duracao_segundos,
    int? meditacao_id,
    bool parcial = false,
  });

  /// Busca estatísticas de meditação do usuário (vezes e minutos).
  Future<Map<String, int>> buscarEstatisticas({String? userId});

  /// Obtém todas as sessões de meditação do usuário.
  Future<List<Map<String, dynamic>>> obterTodas({String? userId});
}
