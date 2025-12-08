import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../features/historico/presentation/controllers/historico_controller.dart';

/// Página de Histórico de Meditação do usuário.
/// 
/// Mostra:
/// - Estatísticas gerais (total de vezes e tempo total)
/// - Lista de todas as sessões com data e duração
class HistoricoPage extends StatefulWidget {
  const HistoricoPage({super.key});

  @override
  State<HistoricoPage> createState() => _HistoricoPageState();
}

class _HistoricoPageState extends State<HistoricoPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HistoricoController>(context, listen: false)
          .carregarSessoes();
    });
  }

  Future<void> _onRefresh() async {
    final controller = Provider.of<HistoricoController>(context, listen: false);
    // Carregar sessões e estatísticas em paralelo
    await Future.wait([
      controller.carregarSessoes(),
      controller.carregarEstatisticas(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico de Meditação'),
      ),
      body: Consumer<HistoricoController>(
        builder: (context, historicoController, child) {
          if (historicoController.carregando) {
            // Allow pull-to-refresh while loading by providing a scrollable
            return RefreshIndicator(
              onRefresh: _onRefresh,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height - kToolbarHeight,
                  child: const Center(child: CircularProgressIndicator()),
                ),
              ),
            );
          }

          if (historicoController.erro != null) {
            // Show error but keep area scrollable so RefreshIndicator works
            return RefreshIndicator(
              onRefresh: _onRefresh,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height - kToolbarHeight,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, size: 64, color: Colors.red),
                          const SizedBox(height: 16),
                          Text(
                            'Erro ao carregar histórico',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            historicoController.erro ?? 'Erro desconhecido',
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () => historicoController.carregarSessoes(),
                            icon: const Icon(Icons.refresh),
                            label: const Text('Tentar Novamente'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }

          final sessoes = historicoController.sessoes;

          if (sessoes.isEmpty) {
            // Keep area scrollable to allow pull-to-refresh even when empty
            return RefreshIndicator(
              onRefresh: _onRefresh,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height - kToolbarHeight,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.history_outlined,
                            size: 80,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Nenhuma sessão registrada',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(color: Colors.grey),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Volte para a home e inicie uma meditação!',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _onRefresh,
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: sessoes.length + 1,
              itemBuilder: (context, index) {
              // Header com estatísticas
              if (index == 0) {
                final totalVezes = sessoes.length;
                int totalSegundos = 0;

                for (var sessao in sessoes) {
                  totalSegundos +=
                      (sessao['duracao_segundos'] as int? ?? 0);
                }

                final totalMinutos = (totalSegundos / 60).round();
                final totalHoras = totalMinutos ~/ 60;
                final minutosRestantes = totalMinutos % 60;

                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceEvenly,
                            children: [
                              _StatColumn(
                                icon: Icons.track_changes,
                                label: 'Sessões',
                                valor: '$totalVezes',
                                cor: Colors.cyan,
                              ),
                              _StatColumn(
                                icon: Icons.schedule,
                                label: 'Tempo Total',
                                valor: totalHoras > 0
                                    ? '${totalHoras}h ${minutosRestantes}m'
                                    : '${totalMinutos}m',
                                cor: Colors.blue,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              // Lista de sessões (indexação: index-1 pois 0 é o header)
              final sessao = sessoes[index - 1];
              final duracao = sessao['duracao_segundos'] as int? ?? 0;
              final minutos = (duracao / 60).round();
              final data = sessao['data_sessao'] != null
                  ? DateTime.parse(sessao['data_sessao'] as String)
                  : DateTime.now();

              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 4.0,
                ),
                child: ListTile(
                  leading: const Icon(Icons.check_circle,
                      color: Colors.green, size: 28),
                  title: Text(
                    '$minutos minuto${minutos != 1 ? 's' : ''}${(sessao['parcial'] as bool? ?? false) ? ' (parcial)' : ''}',
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    '${_formatarData(data)}${(sessao['parcial'] as bool? ?? false) ? ' • Parcial' : ''}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  trailing: Text(
                    _formatarHora(data),
                    style: Theme.of(context)
                        .textTheme
                        .labelSmall
                        ?.copyWith(color: Colors.grey),
                  ),
                ),
              );
            },
              ),
            );
        },
      ),
    );
  }

  /// Formata a data de forma legível (ex: "Há 2 horas", "Ontem", "25 nov").
  String _formatarData(DateTime data) {
    final agora = DateTime.now();
    final hoje = DateTime(agora.year, agora.month, agora.day);
    final dataFormatada = DateTime(data.year, data.month, data.day);
    final ontem = DateTime(hoje.year, hoje.month, hoje.day - 1);

    final diferenca = agora.difference(data);

    if (diferenca.inSeconds < 60) {
      return 'Agora mesmo';
    } else if (diferenca.inMinutes < 60) {
      final m = diferenca.inMinutes;
      return 'Há $m minuto${m > 1 ? 's' : ''}';
    } else if (diferenca.inHours < 24) {
      final h = diferenca.inHours;
      return 'Há $h hora${h > 1 ? 's' : ''}';
    } else if (dataFormatada == ontem) {
      return 'Ontem';
    } else if (diferenca.inDays < 7) {
      return 'Há ${diferenca.inDays} dia${diferenca.inDays > 1 ? 's' : ''}';
    } else {
      // Formato: "25 nov"
      const meses = [
        'jan',
        'fev',
        'mar',
        'abr',
        'mai',
        'jun',
        'jul',
        'ago',
        'set',
        'out',
        'nov',
        'dez'
      ];
      return '${data.day} ${meses[data.month - 1]}';
    }
  }

  /// Formata apenas a hora (ex: "14:30").
  String _formatarHora(DateTime data) {
    return '${data.hour.toString().padLeft(2, '0')}:${data.minute.toString().padLeft(2, '0')}';
  }
}

/// Widget auxiliar para exibir coluna com estatística.
class _StatColumn extends StatelessWidget {
  final IconData icon;
  final String label;
  final String valor;
  final Color cor;

  const _StatColumn({
    required this.icon,
    required this.label,
    required this.valor,
    required this.cor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: cor, size: 36),
        const SizedBox(height: 8),
        Text(
          label,
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: Colors.grey),
        ),
        const SizedBox(height: 4),
        Text(
          valor,
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(color: cor, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
