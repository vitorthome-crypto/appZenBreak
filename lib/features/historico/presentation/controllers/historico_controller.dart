import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Model para armazenar estatísticas de meditação.
class EstatisticasMeditacao {
  final int totalVezes;
  final int totalMinutos;

  EstatisticasMeditacao({
    required this.totalVezes,
    required this.totalMinutos,
  });

  factory EstatisticasMeditacao.empty() {
    return EstatisticasMeditacao(totalVezes: 0, totalMinutos: 0);
  }
}

/// Controller que gerencia o estado do histórico de meditação usando Provider.
class HistoricoController extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  EstatisticasMeditacao _estatisticas = EstatisticasMeditacao.empty();
  bool _carregando = false;
  String? _erro;
  List<Map<String, dynamic>> _sessoes = [];

  HistoricoController();

  // Getters
  EstatisticasMeditacao get estatisticas => _estatisticas;
  bool get carregando => _carregando;
  String? get erro => _erro;
  List<Map<String, dynamic>> get sessoes => _sessoes;

  /// Salva uma nova sessão de meditação.
  Future<void> salvarSessao({
    required int duracao_segundos,
    int? meditacao_id,
  }) async {
    try {
      _erro = null;

      final data = {
        'duracao_segundos': duracao_segundos,
        // Enviar timestamp em UTC para evitar discrepâncias com o servidor
        'data_sessao': DateTime.now().toUtc().toIso8601String(),
        if (meditacao_id != null) 'meditacao_id': meditacao_id,
      };

      await _supabase.from('historico_usuario').insert(data);

      // Atualiza estado local após salvar
      await carregarEstatisticas();
      await carregarSessoes();
      debugPrint('[HistoricoController] Sessão salva com sucesso!');
      notifyListeners();
    } catch (e) {
      _erro = 'Erro ao salvar sessão: $e';
      debugPrint('[HistoricoController] $_erro');
      rethrow;
    }
  }

  /// Carrega as estatísticas de meditação do banco (soma e contagem).
  Future<void> carregarEstatisticas() async {
    try {
      _carregando = true;
      _erro = null;
      notifyListeners();

      final response = await _supabase.from('historico_usuario').select('duracao_segundos');
      final lista = List<Map<String, dynamic>>.from(response);

      final totalVezes = lista.length;
      int totalSegundos = 0;
      for (var item in lista) {
        totalSegundos += (item['duracao_segundos'] as int);
      }
      final totalMinutos = (totalSegundos / 60).round();

      _estatisticas = EstatisticasMeditacao(
        totalVezes: totalVezes,
        totalMinutos: totalMinutos,
      );
    } catch (e) {
      _erro = 'Erro ao carregar estatísticas: $e';
      debugPrint('[HistoricoController] $_erro');
    } finally {
      _carregando = false;
      notifyListeners();
    }
  }

  /// Carrega todas as sessões.
  Future<void> carregarSessoes() async {
    try {
      _carregando = true;
      _erro = null;
      notifyListeners();

      final response = await _supabase.from('historico_usuario').select().order('data_sessao', ascending: false);
      _sessoes = List<Map<String, dynamic>>.from(response);
    } catch (e) {
      _erro = 'Erro ao carregar sessões: $e';
      debugPrint('[HistoricoController] $_erro');
    } finally {
      _carregando = false;
      notifyListeners();
    }
  }

  /// Limpa o erro atual.
  void limparErro() {
    _erro = null;
    notifyListeners();
  }
}
