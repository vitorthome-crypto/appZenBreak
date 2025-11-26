import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../features/historico/presentation/controllers/historico_controller.dart';

/// Widget que exibe as estatísticas de meditação do usuário.
/// 
/// Mostra: "Você meditou X vezes totalizando Y minutos"
class EstatisticasMeditacaoWidget extends StatefulWidget {
  const EstatisticasMeditacaoWidget({super.key});

  @override
  State<EstatisticasMeditacaoWidget> createState() =>
      _EstatisticasMeditacaoWidgetState();
}

class _EstatisticasMeditacaoWidgetState
    extends State<EstatisticasMeditacaoWidget> {
  @override
  void initState() {
    super.initState();
    // Carrega as estatísticas quando o widget é criado
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HistoricoController>(context, listen: false)
          .carregarEstatisticas();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HistoricoController>(
      builder: (context, historicoController, child) {
        if (historicoController.carregando) {
          return const Center(child: CircularProgressIndicator());
        }

        if (historicoController.erro != null) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  'Erro: ${historicoController.erro}',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.red),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () =>
                      historicoController.carregarEstatisticas(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Tentar Novamente'),
                ),
              ],
            ),
          );
        }

        final stats = historicoController.estatisticas;
        final vezes = stats.totalVezes;
        final minutos = stats.totalMinutos;

        return Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const Icon(Icons.favorite, color: Colors.cyan, size: 48),
                const SizedBox(height: 16),
                Text(
                  'Suas Meditações',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Você meditou $vezes ${vezes == 1 ? 'vez' : 'vezes'} totalizando $minutos ${minutos == 1 ? 'minuto' : 'minutos'}',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _StatCard(
                      icon: Icons.track_changes,
                      label: 'Sessões',
                      value: '$vezes',
                      color: Colors.cyan,
                    ),
                    _StatCard(
                      icon: Icons.schedule,
                      label: 'Tempo Total',
                      value: '$minutos min',
                      color: Colors.blue,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Card auxiliar para exibir estatísticas individuais.
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(color: color),
        ),
      ],
    );
  }
}
