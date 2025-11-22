import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/datasources/providers_local_data_source_impl.dart';
import '../../data/repositories/providers_repository_impl.dart';
import '../controllers/fornecedores_controller.dart';
import '../widgets/fornecedor_list_item.dart';

class FornecedoresPage extends StatefulWidget {
  const FornecedoresPage({Key? key}) : super(key: key);

  @override
  State<FornecedoresPage> createState() => _FornecedoresPageState();
}

class _FornecedoresPageState extends State<FornecedoresPage> {
  late FornecedoresController _controller;
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
      final localDataSource = ProvidersLocalDataSourceImpl(prefs: prefs);
      final repository = ProvidersRepositoryImpl(
        localDataSource: localDataSource,
      );

      _controller = FornecedoresController(repository: repository)
        ..addListener(() => setState(() {}));
      
      await _controller.loadProviders();
    } catch (e) {
      print('Erro ao inicializar controller: $e');
    }
  }

  void _onSearchChanged() {
    _controller.setSearchQuery(_searchController.text);
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
        title: const Text('Fornecedores'),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: Container(
            height: 4,
            color: const Color(0xFFBEEAF6),
          ),
        ),
      ),
      body: _controller.isLoading
          ? const Center(child: CircularProgressIndicator())
          : _controller.errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('❌ ${_controller.errorMessage}'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          _controller.loadProviders();
                        },
                        child: const Text('Tentar novamente'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Barra de busca
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Buscar por nome...',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                  },
                                )
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),

                    // Filtros e ordenação
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: [
                          // Status Filter
                          Expanded(
                            child: DropdownButton<String>(
                              value: _controller.statusFilter,
                              isExpanded: true,
                              items: const [
                                DropdownMenuItem(
                                  value: 'all',
                                  child: Text('Todos'),
                                ),
                                DropdownMenuItem(
                                  value: 'active',
                                  child: Text('Ativos'),
                                ),
                                DropdownMenuItem(
                                  value: 'inactive',
                                  child: Text('Inativos'),
                                ),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  _controller.setStatusFilter(value);
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Sort By
                          Expanded(
                            child: DropdownButton<String>(
                              value: _controller.sortBy,
                              isExpanded: true,
                              items: const [
                                DropdownMenuItem(
                                  value: 'name',
                                  child: Text('Nome'),
                                ),
                                DropdownMenuItem(
                                  value: 'rating',
                                  child: Text('Avaliação'),
                                ),
                                DropdownMenuItem(
                                  value: 'distance',
                                  child: Text('Distância'),
                                ),
                                DropdownMenuItem(
                                  value: 'updated_at',
                                  child: Text('Atualizado'),
                                ),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  _controller.setSortBy(value);
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Sort Direction
                          IconButton(
                            icon: Icon(
                              _controller.sortAscending
                                  ? Icons.arrow_upward
                                  : Icons.arrow_downward,
                            ),
                            onPressed: () {
                              _controller.setSortBy(
                                _controller.sortBy,
                                ascending: !_controller.sortAscending,
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    const Divider(),

                    // Lista paginada
                    Expanded(
                      child: _controller.filteredProviders.isEmpty
                          ? const Center(
                              child: Text('Nenhum fornecedor encontrado'),
                            )
                          : ListView.builder(
                              itemCount:
                                  _controller.currentPageProviders.length,
                              itemBuilder: (context, index) {
                                final provider =
                                    _controller.currentPageProviders[index];
                                return FornecedorListItem(
                                  fornecedor: provider,
                                  onTap: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            'Selecionado: ${provider.name}'),
                                      ),
                                    );
                                  },
                                  onDelete: () async {
                                    await _controller
                                        .deleteProvider(provider.id);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              '${provider.name} deletado'),
                                        ),
                                      );
                                    }
                                  },
                                );
                              },
                            ),
                    ),

                    // Controles de paginação
                    if (_controller.filteredProviders.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                              onPressed: _controller.currentPage > 1
                                  ? () {
                                      _controller.previousPage();
                                    }
                                  : null,
                              child: const Text('← Anterior'),
                            ),
                            Text(
                              'Página ${_controller.currentPage} de ${_controller.totalPages} '
                              '(${_controller.filteredProviders.length} total)',
                            ),
                            ElevatedButton(
                              onPressed:
                                  _controller.currentPage <
                                          _controller.totalPages
                                      ? () {
                                          _controller.nextPage();
                                        }
                                      : null,
                              child: const Text('Próxima →'),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
    );
  }
}
