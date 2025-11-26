import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/historico_repository.dart';

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
  final HistoricoRepository repository;

  EstatisticasMeditacao _estatisticas = EstatisticasMeditacao.empty();
  bool _carregando = false;
  String? _erro;
  List<Map<String, dynamic>> _sessoes = [];

  HistoricoController({required this.repository});

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
      final user = Supabase.instance.client.auth.currentUser;

      if (user == null) {
        _erro = 'Usuário não autenticado';
        notifyListeners();
        return;
      }

      await repository.salvarSessao(
        userId: user.id,
        duracao_segundos: duracao_segundos,
        meditacao_id: meditacao_id,
      );

      // Após salvar, atualiza as estatísticas
      await carregarEstatisticas();
      debugPrint('[HistoricoController] Sessão salva com sucesso!');
    } catch (e) {
      _erro = 'Erro ao salvar sessão: $e';
      debugPrint('[HistoricoController] $erro');
      notifyListeners();
    }
  }

  /// Carrega as estatísticas de meditação do usuário.
  Future<void> carregarEstatisticas() async {
    try {
      _carregando = true;
      _erro = null;
      notifyListeners();

      final user = Supabase.instance.client.auth.currentUser;

      if (user == null) {
        _erro = 'Usuário não autenticado';
        _carregando = false;
        notifyListeners();
        return;
      }

      final dados = await repository.buscarEstatisticas(userId: user.id);

      _estatisticas = EstatisticasMeditacao(
        totalVezes: dados['vezes'] ?? 0,
        totalMinutos: dados['minutos'] ?? 0,
      );

      debugPrint(
          '[HistoricoController] Estatísticas carregadas: ${_estatisticas.totalVezes} vezes, ${_estatisticas.totalMinutos} min');
    } catch (e) {
      _erro = 'Erro ao carregar estatísticas: $e';
      debugPrint('[HistoricoController] $erro');
    } finally {
      _carregando = false;
      notifyListeners();
    }
  }

  /// Carrega todas as sessões de meditação do usuário.
  Future<void> carregarSessoes() async {
    try {
      _carregando = true;
      _erro = null;
      notifyListeners();

      final user = Supabase.instance.client.auth.currentUser;

      if (user == null) {
        _erro = 'Usuário não autenticado';
        _carregando = false;
        notifyListeners();
        return;
      }

      _sessoes = await repository.obterTodas(userId: user.id);

      debugPrint(
          '[HistoricoController] ${_sessoes.length} sessões carregadas');
    } catch (e) {
      _erro = 'Erro ao carregar sessões: $e';
      debugPrint('[HistoricoController] $erro');
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
