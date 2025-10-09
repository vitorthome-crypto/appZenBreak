import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/prefs_service.dart';

class ReminderPage extends StatefulWidget {
  const ReminderPage({super.key});

  @override
  State<ReminderPage> createState() => _ReminderPageState();
}

class _ReminderPageState extends State<ReminderPage> {
  TimeOfDay? _selected;

  Future<void> _pickTime() async {
    final now = TimeOfDay.now();
    final picked = await showTimePicker(context: context, initialTime: now);
    if (picked != null) setState(() => _selected = picked);
  }

  Future<void> _save() async {
    if (_selected == null) return;
    final prefs = Provider.of<PrefsService>(context, listen: false);
    final str = _selected!.format(context);
    await prefs.setReminderTime(str);
    await prefs.setReminderScheduled(true);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lembrete agendado')));
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agendar lembrete')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(onPressed: _pickTime, child: const Text('Escolher horário')),
            const SizedBox(height: 12),
            if (_selected != null) Text('Selecionado: ${_selected!.format(context)}'),
            const Spacer(),
            ElevatedButton(onPressed: _save, child: const Text('Salvar lembrete')),
          ],
        ),
      ),
    );
  }
}
