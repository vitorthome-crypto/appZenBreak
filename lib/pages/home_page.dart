import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/prefs_service.dart';
import '../widgets/breathing_session.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _inSession = false;
  int _selectedDurationSeconds = 120;
  bool _prefsLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadSavedDuration();
  }

  Future<void> _loadSavedDuration() async {
    if (_prefsLoaded) return;
    final prefs = await PrefsService.getInstance();
    final saved = prefs.pauseDurationSeconds;
    if (!mounted) return;
    setState(() {
      _selectedDurationSeconds = saved;
      _prefsLoaded = true;
    });
  }

  void _startSession() {
    setState(() => _inSession = true);
  }

  void _cancelSession() {
    setState(() => _inSession = false);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pausa cancelada'), duration: Duration(seconds: 2)));
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

  @override
  Widget build(BuildContext context) {
    // prefs are loaded once in initState
    final calmColor = const Color(0xFFBEEAF6); // baby blue calm

    final prefs = Provider.of<PrefsService>(context); // listen: true por padrão
    final bgHex = prefs.backgroundColorHex;
    final bgColor = _colorFromHex(bgHex) ?? Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('ZenBreak'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) async {
              if (v == 'revoke') await _revoke();
              if (v == 'policies') Navigator.pushNamed(context, '/policy-viewer');
              if (v == 'reminder') Navigator.pushNamed(context, '/reminder');
              if (v == 'background') await _pickBackgroundColor();
            },
            itemBuilder: (c) => [
              const PopupMenuItem(value: 'reminder', child: Text('Ajustar lembrete')),
              const PopupMenuItem(value: 'policies', child: Text('Ver políticas')),
              const PopupMenuItem(value: 'background', child: Text('Cor de fundo')),
              const PopupMenuItem(value: 'revoke', child: Text('Revogar aceite')),
            ],
          )
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: Container(color: calmColor, height: 4),
        ),
      ),
      body: Center(
    child: _inSession
      ? BreathingSession(durationSeconds: _selectedDurationSeconds, onFinished: _endSession, onCancel: _cancelSession)
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
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(40),
                      backgroundColor: calmColor,
                      side: const BorderSide(color: Colors.black),
                    ),
                    child: const Text('Iniciar pausa', textAlign: TextAlign.center),
                  ),
                ],
              ),
      ),
    );
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

  Color? _colorFromHex(String? hex) {
    if (hex == null || hex.isEmpty) return null;
    var h = hex.trim();
    if (!h.startsWith('#')) h = '#$h';
    if (h.length == 7) {
      try {
        return Color(int.parse(h.substring(1), radix: 16) + 0xFF000000);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  Future<void> _pickBackgroundColor() async {
    final prefs = Provider.of<PrefsService>(context, listen: false);
    final current = prefs.backgroundColorHex ?? '#FFFFFF';
    final initialColor = _colorFromHex(current) ?? Colors.white;
    Color selectedColor = initialColor;

    final result = await showDialog<Color?>(context: context, builder: (c) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: const Text('Escolher cor de fundo'),
        content: SizedBox(
          width: 300,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Quick presets - cores variadas
                const Text('Cores disponíveis:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    // Azul claro
                    GestureDetector(
                      onTap: () {
                        setState(() => selectedColor = const Color(0xFFBEEAF6));
                      },
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: const Color(0xFFBEEAF6),
                          border: Border.all(
                            color: selectedColor == const Color(0xFFBEEAF6) ? Colors.black : Colors.grey,
                            width: selectedColor == const Color(0xFFBEEAF6) ? 3 : 1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(child: Text('Azul', style: TextStyle(fontSize: 10))),
                      ),
                    ),
                    // Verde claro
                    GestureDetector(
                      onTap: () {
                        setState(() => selectedColor = const Color(0xFFDFF7E0));
                      },
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: const Color(0xFFDFF7E0),
                          border: Border.all(
                            color: selectedColor == const Color(0xFFDFF7E0) ? Colors.black : Colors.grey,
                            width: selectedColor == const Color(0xFFDFF7E0) ? 3 : 1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(child: Text('Verde', style: TextStyle(fontSize: 10))),
                      ),
                    ),
                    // Rosa claro
                    GestureDetector(
                      onTap: () {
                        setState(() => selectedColor = const Color(0xFFFFDDD2));
                      },
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFDDD2),
                          border: Border.all(
                            color: selectedColor == const Color(0xFFFFDDD2) ? Colors.black : Colors.grey,
                            width: selectedColor == const Color(0xFFFFDDD2) ? 3 : 1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(child: Text('Rosa', style: TextStyle(fontSize: 10))),
                      ),
                    ),
                    // Roxo claro
                    GestureDetector(
                      onTap: () {
                        setState(() => selectedColor = const Color(0xFFE8D5F0));
                      },
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8D5F0),
                          border: Border.all(
                            color: selectedColor == const Color(0xFFE8D5F0) ? Colors.black : Colors.grey,
                            width: selectedColor == const Color(0xFFE8D5F0) ? 3 : 1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(child: Text('Roxo', style: TextStyle(fontSize: 10))),
                      ),
                    ),
                    // Amarelo claro
                    GestureDetector(
                      onTap: () {
                        setState(() => selectedColor = const Color(0xFFFFF8DC));
                      },
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF8DC),
                          border: Border.all(
                            color: selectedColor == const Color(0xFFFFF8DC) ? Colors.black : Colors.grey,
                            width: selectedColor == const Color(0xFFFFF8DC) ? 3 : 1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(child: Text('Amarelo', style: TextStyle(fontSize: 10))),
                      ),
                    ),
                    // Cinza claro
                    GestureDetector(
                      onTap: () {
                        setState(() => selectedColor = const Color(0xFFF5F5F5));
                      },
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          border: Border.all(
                            color: selectedColor == const Color(0xFFF5F5F5) ? Colors.black : Colors.grey,
                            width: selectedColor == const Color(0xFFF5F5F5) ? 3 : 1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(child: Text('Cinza', style: TextStyle(fontSize: 10))),
                      ),
                    ),
                    // Branco
                    GestureDetector(
                      onTap: () {
                        setState(() => selectedColor = Colors.white);
                      },
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: selectedColor == Colors.white ? Colors.black : Colors.grey,
                            width: selectedColor == Colors.white ? 3 : 1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(child: Text('Branco', style: TextStyle(fontSize: 10))),
                      ),
                    ),
                    // Laranja claro
                    GestureDetector(
                      onTap: () {
                        setState(() => selectedColor = const Color(0xFFFFE0CC));
                      },
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFE0CC),
                          border: Border.all(
                            color: selectedColor == const Color(0xFFFFE0CC) ? Colors.black : Colors.grey,
                            width: selectedColor == const Color(0xFFFFE0CC) ? 3 : 1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(child: Text('Laranja', style: TextStyle(fontSize: 10))),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(c, selectedColor),
            child: const Text('OK'),
          ),
        ],
      ),
    ));

    if (result != null) {
      final r = (result.red * 255).toInt().toRadixString(16).padLeft(2, '0');
      final g = (result.green * 255).toInt().toRadixString(16).padLeft(2, '0');
      final b = (result.blue * 255).toInt().toRadixString(16).padLeft(2, '0');
      final hex = '#${(r + g + b).toUpperCase()}';
      await prefs.setBackgroundColorHex(hex);
      setState(() {});
    }
  }
}
