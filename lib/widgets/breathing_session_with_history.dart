import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../features/historico/presentation/controllers/historico_controller.dart';
import 'breathing_session.dart';

/// Widget que encapsula BreathingSession e salva o histórico automaticamente ao terminar.
class BreathingSessionWithHistory extends StatefulWidget {
  final int durationSeconds;
  final int? meditacaoId;
  final VoidCallback? onFinished;

  const BreathingSessionWithHistory({
    super.key,
    this.durationSeconds = 120,
    this.meditacaoId,
    this.onFinished,
  });

  @override
  State<BreathingSessionWithHistory> createState() =>
      _BreathingSessionWithHistoryState();
}

class _BreathingSessionWithHistoryState
    extends State<BreathingSessionWithHistory> {
  late HistoricoController _historicoController;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _historicoController =
        Provider.of<HistoricoController>(context, listen: false);
  }

  void _onSessionFinished() async {
    try {
      // Salva a sessão no histórico
      await _historicoController.salvarSessao(
        duracao_segundos: widget.durationSeconds,
        meditacao_id: widget.meditacaoId,
      );

      // Chama callback customizado se fornecido
      widget.onFinished?.call();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sessão de meditação registrada!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao registrar sessão: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BreathingSession(
      durationSeconds: widget.durationSeconds,
      onFinished: _onSessionFinished,
    );
  }
}
