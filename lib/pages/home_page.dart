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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ZenBreak'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) async {
              if (v == 'revoke') await _revoke();
              if (v == 'policies') Navigator.pushNamed(context, '/policy-viewer');
              if (v == 'reminder') Navigator.pushNamed(context, '/reminder');
            },
            itemBuilder: (c) => [
              const PopupMenuItem(value: 'reminder', child: Text('Ajustar lembrete')),
              const PopupMenuItem(value: 'policies', child: Text('Ver políticas')),
              const PopupMenuItem(value: 'revoke', child: Text('Revogar aceite')),
            ],
          )
        ],
      ),
      body: Center(
        child: _inSession
            ? BreathingSession(durationSeconds: 120, onFinished: _endSession)
            : ElevatedButton(
                onPressed: _startSession,
                style: ElevatedButton.styleFrom(shape: const CircleBorder(), padding: const EdgeInsets.all(40)),
                child: const Text('Iniciar pausa', textAlign: TextAlign.center),
              ),
      ),
    );
  }
}
