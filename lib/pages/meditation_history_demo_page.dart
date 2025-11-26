import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/breathing_session_with_history.dart';
import '../widgets/estatisticas_meditacao_widget.dart';
import '../features/historico/presentation/controllers/historico_controller.dart';

/// Página de demonstração do histórico de meditação.
/// 
/// Mostra:
/// 1. Um botão para iniciar uma sessão de meditação (3 minutos)
/// 2. Um widget com as estatísticas do usuário
class MeditationHistoryDemoPage extends StatefulWidget {
  const MeditationHistoryDemoPage({super.key});

  @override
  State<MeditationHistoryDemoPage> createState() =>
      _MeditationHistoryDemoPageState();
}

class _MeditationHistoryDemoPageState extends State<MeditationHistoryDemoPage> {
  bool _meditando = false;

  void _iniciarMeditacao() {
    setState(() => _meditando = true);
  }

  void _finalizarMeditacao() {
    setState(() => _meditando = false);
    // O HistoricoController já foi notificado via BreathingSessionWithHistory
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Parabéns! Sua meditação foi registrada.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico de Meditação'),
      ),
      body: _meditando
          ? BreathingSessionWithHistory(
              durationSeconds: 180, // 3 minutos para demo
              meditacaoId: null,
              onFinished: _finalizarMeditacao,
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  // Card com estatísticas
                  const EstatisticasMeditacaoWidget(),
                  const SizedBox(height: 24),
                  // Botão para iniciar meditação
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: ElevatedButton.icon(
                      onPressed: _iniciarMeditacao,
                      icon: const Icon(Icons.favorite),
                      label: const Text('Iniciar Meditação (3 min)'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Seção de histórico
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Histórico de Sessões',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        Consumer<HistoricoController>(
                          builder: (context, historicoController, _) {
                            if (historicoController.carregando) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }

                            if (historicoController.sessoes.isEmpty) {
                              return Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(32.0),
                                  child: Text(
                                    'Nenhuma sessão registrada ainda.\nInicie uma meditação para começar!',
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: Colors.grey,
                                        ),
                                  ),
                                ),
                              );
                            }

                            return ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: historicoController.sessoes.length,
                              itemBuilder: (context, index) {
                                final sessao =
                                    historicoController.sessoes[index];
                                final duracao =
                                    sessao['duracao_segundos'] as int?;
                                final minutos = duracao != null
                                    ? (duracao / 60).round()
                                    : 0;
                                final data = sessao['data_sessao'] != null
                                    ? DateTime.parse(
                                        sessao['data_sessao'] as String)
                                    : DateTime.now();

                                return Card(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  child: ListTile(
                                    leading: const Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                    ),
                                    title: Text(
                                      '$minutos minutos',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge,
                                    ),
                                    subtitle: Text(
                                      _formatarData(data),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  /// Formata a data para exibição legível.
  String _formatarData(DateTime data) {
    final agora = DateTime.now();
    final diferenca = agora.difference(data);

    if (diferenca.inSeconds < 60) {
      return 'Há alguns segundos';
    } else if (diferenca.inMinutes < 60) {
      return 'Há ${diferenca.inMinutes} minuto(s)';
    } else if (diferenca.inHours < 24) {
      return 'Há ${diferenca.inHours} hora(s)';
    } else if (diferenca.inDays < 7) {
      return 'Há ${diferenca.inDays} dia(s)';
    } else {
      return '${data.day}/${data.month}/${data.year}';
    }
  }
}
