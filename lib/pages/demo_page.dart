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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    
    return Scaffold(
      appBar: AppBar(title: const Text('Sessão Demonstrativa')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Legenda de respiração
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainer.withAlpha((0.5 * 255).round()),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colorScheme.outline.withAlpha((0.2 * 255).round()),
                ),
              ),
              child: Column(
                children: [
                  Icon(Icons.info_outline, color: colorScheme.primary),
                  const SizedBox(height: 8),
                  Text(
                    'Inspira o ar quando o círculo estiver crescendo.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Solte o ar quando o círculo estiver diminuindo.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Expanded(child: BreathingSession(durationSeconds: 10, onFinished: _onFinish)),
            const SizedBox(height: 12),
            if (_finished)
              ElevatedButton(
                onPressed: () => Navigator.pushReplacementNamed(context, '/policy-viewer'),
                child: const Text('Agendar lembrete / Ver políticas'),
              )
            else
              Text(
                'Siga a respiração...',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
