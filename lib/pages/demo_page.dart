import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/prefs_service.dart';
import '../widgets/breathing_session.dart';

class DemoPage extends StatefulWidget {
  const DemoPage({super.key});

  @override
  State<DemoPage> createState() => _DemoPageState();
}

class _DemoPageState extends State<DemoPage> {
  bool _finished = false;

  void _onFinish() async {
    final prefs = Provider.of<PrefsService>(context, listen: false);
    await prefs.setDemoCompleted(true);
    setState(() => _finished = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sessão Demonstrativa')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(child: BreathingSession(durationSeconds: 10, onFinished: _onFinish)),
            const SizedBox(height: 12),
            if (_finished)
              ElevatedButton(
                onPressed: () => Navigator.pushReplacementNamed(context, '/policy-viewer'),
                style: ElevatedButton.styleFrom(side: const BorderSide(color: Colors.black), backgroundColor: const Color(0xFFBEEAF6)),
                child: const Text('Agendar lembrete / Ver políticas'),
              )
            else
              Text('Siga a respiração...'),
          ],
        ),
      ),
    );
  }
}
