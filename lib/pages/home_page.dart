import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/prefs_service.dart';
import '../widgets/breathing_session_with_history.dart';
import '../features/historico/presentation/controllers/historico_controller.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _inSession = false;
  int _selectedDurationSeconds = 120;
  int _lastRemainingSeconds = 0;

  void _startSession() {
    setState(() => _inSession = true);
  }

  void _endSession() {
    setState(() => _inSession = false);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pausa finalizada')));
  }

  Future<void> _revoke() async {
    final prefs = Provider.of<PrefsService>(context, listen: false);
    final confirmed = await showDialog<bool>(context: context, builder: (c) => AlertDialog(
          title: const Text('Revogar aceite'),
          content: const Text('Tem certeza que deseja revogar o aceite das políticas?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancelar')),
            TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Revogar')),
          ],
        ));
    if (confirmed != true) return;
    // Revoke
    await prefs.setPoliciesVersionAccepted('');
    await prefs.setAcceptedAt('');
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Aceite revogado'), duration: Duration(seconds: 3)));
    Navigator.pushReplacementNamed(context, '/');
  }

  // logout removed — app no longer requires authentication

  @override
  Widget build(BuildContext context) {
    final prefs = Provider.of<PrefsService>(context);
    final showMenu = prefs.policiesVersionAccepted != null && (prefs.policiesVersionAccepted?.isNotEmpty ?? false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ZenBreak'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) async {
              if (v == 'revoke') await _revoke();
              if (v == 'policies') Navigator.pushNamed(context, '/policy-viewer');
            },
            itemBuilder: (c) => [
              const PopupMenuItem(value: 'policies', child: Text('Ver políticas')),
              const PopupMenuItem(value: 'revoke', child: Text('Revogar aceite')),
            ],
          )
        ],
      ),
      drawer: showMenu
          ? Drawer(
              child: SafeArea(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    const DrawerHeader(
                      decoration: BoxDecoration(color: Colors.blue),
                      child: Text('Menu', style: TextStyle(color: Colors.white, fontSize: 18)),
                    ),
                    // Fornecedores e Lembretes removidos do menu conforme solicitado
                                        ListTile(
                                          leading: const Icon(Icons.flag),
                                          title: const Text('Metas'),
                                          onTap: () {
                                            Navigator.pop(context);
                                            Navigator.pushNamed(context, '/metas');
                                          },
                                        ),
                    ListTile(
                      leading: const Icon(Icons.history),
                      title: const Text('Histórico'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/historico');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.policy),
                      title: const Text('Políticas'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/policy-viewer');
                      },
                    ),
                  ],
                ),
              ),
            )
          : null,
      body: Center(
        child: _inSession
            ? Stack(
                  alignment: Alignment.center,
                  children: [
                      BreathingSessionWithHistory(
                        durationSeconds: _selectedDurationSeconds,
                        onFinished: _endSession,
                        onTick: (remaining) => _lastRemainingSeconds = remaining),
                  Positioned(
                    bottom: 48,
                    child: ElevatedButton(
                      onPressed: () async {
                        // Cancel session early and save partial session if any progress
                        final elapsed = _selectedDurationSeconds - _lastRemainingSeconds;
                        if (elapsed > 0) {
                          try {
                            final historico = Provider.of<HistoricoController>(context, listen: false);
                            await historico.salvarSessao(duracao_segundos: elapsed, meditacao_id: null);
                          } catch (_) {
                            // ignore errors saving partial
                          }
                        }
                        setState(() => _inSession = false);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pausa cancelada')));
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: const Text('Cancelar'),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Mostrar duração selecionada e permitir edição
                  GestureDetector(
                    onTap: _pickDuration,
                    child: Column(
                      children: [
                        Text('Duração da pausa', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        Text(_formatSecondsToMmSs(_selectedDurationSeconds), style: Theme.of(context).textTheme.headlineMedium),
                        const SizedBox(height: 12),
                        const Text('Toque para ajustar', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      // Persist selected duration and start
                      final prefs = Provider.of<PrefsService>(context, listen: false);
                      prefs.setPauseDurationSeconds(_selectedDurationSeconds);
                      _startSession();
                    },
                    style: ElevatedButton.styleFrom(shape: const CircleBorder(), padding: const EdgeInsets.all(40)),
                    child: const Text('Iniciar pausa', textAlign: TextAlign.center),
                  ),
                ],
              ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // Carregar preferências uma única vez no início
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final prefs = Provider.of<PrefsService>(context, listen: false);
      final saved = prefs.pauseDurationSeconds;
      if (saved != _selectedDurationSeconds) setState(() => _selectedDurationSeconds = saved);
    });
  }

  Future<void> _pickDuration() async {
    final result = await showDialog<int>(context: context, builder: (c) {
      final minController = TextEditingController(text: (_selectedDurationSeconds ~/ 60).toString());
      final secController = TextEditingController(text: (_selectedDurationSeconds % 60).toString());
      final formKey = GlobalKey<FormState>();
      return AlertDialog(
        title: const Text('Ajustar duração (MM:SS)'),
        content: Form(
          key: formKey,
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: minController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Minutos', hintText: '0-60'),
                  validator: (v) {
                    final n = int.tryParse(v ?? '');
                    if (n == null) return 'Inválido';
                    if (n < 0 || n > 60) return '0-60';
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: secController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Segundos', hintText: '0-59'),
                  validator: (v) {
                    final n = int.tryParse(v ?? '');
                    if (n == null) return 'Inválido';
                    if (n < 0 || n > 59) return '0-59';
                    return null;
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancelar')),
          TextButton(
              onPressed: () {
                if (!formKey.currentState!.validate()) return;
                final m = int.tryParse(minController.text) ?? 0;
                final s = int.tryParse(secController.text) ?? 0;
                final total = m * 60 + s;
                if (total <= 0) return;
                if (total > 3600) {
                  // limite 60:00
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Máximo permitido: 60:00')));
                  return;
                }
                Navigator.pop(c, total);
              },
              child: const Text('OK'))
        ],
      );
    });

    if (result != null) setState(() => _selectedDurationSeconds = result);
  }

  String _formatSecondsToMmSs(int total) {
    final minutes = (total ~/ 60).clamp(0, 60);
    final seconds = (total % 60).clamp(0, 59);
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
