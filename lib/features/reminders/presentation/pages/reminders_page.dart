import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/datasources/reminders_local_data_source_impl.dart';
import '../../data/repositories/reminders_repository_impl.dart';
import '../../domain/entities/reminder.dart';
import '../controllers/reminders_controller.dart';
import '../dialogs/reminder_details_dialog.dart';
import '../utils/mock_data.dart';
import '../widgets/reminder_list_item.dart';

class RemindersPage extends StatefulWidget {
  const RemindersPage({Key? key}) : super(key: key);

  @override
  State<RemindersPage> createState() => _RemindersPageState();
}

class _RemindersPageState extends State<RemindersPage> {
  late RemindersController _controller;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeController();
    _searchController.addListener(_onSearchChanged);
  }

  Future<void> _initializeController() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final localDataSource = RemindersLocalDataSourceImpl(prefs: prefs);
      final repository = RemindersRepositoryImpl(
        localDataSource: localDataSource,
      );

      _controller = RemindersController(repository: repository)
        ..addListener(() => setState(() {}));

      // Carrega dados existentes ou carrega mock data
      final reminders = await _controller.repository.getAll();
      if (reminders.isEmpty) {
        // Se não há lembretes, carrega dados de teste
        final mockReminders = generateMockReminders();
        for (final reminder in mockReminders) {
          await _controller.repository.create(reminder);
        }
      }

      await _controller.loadReminders();
    } catch (e) {
      debugPrint('Erro ao inicializar controller: $e');
    }
  }

  void _onSearchChanged() {
    _controller.setSearchQuery(_searchController.text);
  }

  void _showReminderDetailsDialog(BuildContext context, Reminder reminder) {
    showDialog(
      context: context,
      builder: (dialogContext) => ReminderDetailsDialog(
        reminder: reminder,
        onEdit: () {
          // TODO: Implementar edição
        },
        onDelete: () async {
          final success = await _controller.deleteReminder(reminder.id);
          if (success && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Lembrete removido com sucesso'),
                duration: Duration(seconds: 2),
              ),
            );
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lembretes'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Barra de busca
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar lembretes...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),

          // Filtros e opções
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  // Filtro por tipo
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: DropdownButton<String?>(
                      hint: const Text('Tipo'),
                      value: _controller.filterType,
                      items: const [
                        DropdownMenuItem(value: null, child: Text('Todos')),
                        DropdownMenuItem(value: 'breathing', child: Text('Respiração')),
                        DropdownMenuItem(value: 'hydration', child: Text('Hidratação')),
                        DropdownMenuItem(value: 'posture', child: Text('Postura')),
                        DropdownMenuItem(value: 'meditation', child: Text('Meditação')),
                        DropdownMenuItem(value: 'custom', child: Text('Customizado')),
                      ],
                      onChanged: _controller.setFilterType,
                    ),
                  ),

                  // Filtro por prioridade
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: DropdownButton<String?>(
                      hint: const Text('Prioridade'),
                      value: _controller.filterPriority,
                      items: const [
                        DropdownMenuItem(value: null, child: Text('Todas')),
                        DropdownMenuItem(value: 'high', child: Text('Alta')),
                        DropdownMenuItem(value: 'medium', child: Text('Média')),
                        DropdownMenuItem(value: 'low', child: Text('Baixa')),
                      ],
                      onChanged: _controller.setFilterPriority,
                    ),
                  ),

                  // Ordenação
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: DropdownButton<bool>(
                      hint: const Text('Ordem'),
                      value: _controller.sortDescending,
                      items: const [
                        DropdownMenuItem(value: true, child: Text('Mais próximos')),
                        DropdownMenuItem(value: false, child: Text('Mais distantes')),
                      ],
                      onChanged: (value) {
                        if (value != null) _controller.setSortDescending(value);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Lista de lembretes
          Expanded(
            child: _controller.isLoading
                ? const Center(child: CircularProgressIndicator())
                : _controller.reminders.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.alarm_off,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Nenhum lembrete encontrado',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _controller.reminders.length,
                        itemBuilder: (context, index) {
                          final reminder = _controller.reminders[index];
                          return ReminderListItem(
                            reminder: reminder,
                            onTap: () => _showReminderDetailsDialog(context, reminder),
                            onDismissed: () async {
                              final success = await _controller.deleteReminder(reminder.id);
                              if (success && mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Lembrete removido com sucesso'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              }
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
