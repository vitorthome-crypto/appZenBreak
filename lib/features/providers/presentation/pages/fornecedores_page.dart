import 'package:flutter/material.dart';
import '../../infrastructure/dtos/provider_dto.dart';
import '../../infrastructure/dao/providers_local_dao.dart';
import '../widgets/fornecedor_list_item.dart';

/// Página de listagem de fornecedores
/// Implementa carregamento, filtros, paginação e integração com DAO local
class FornecedoresPage extends StatefulWidget {
  const FornecedoresPage({super.key});

  @override
  State<FornecedoresPage> createState() => _FornecedoresPageState();
}

class _FornecedoresPageState extends State<FornecedoresPage> {
  late FornecedoresLocalDao _dao;
  List<FornecedorDto> _allFornecedores = [];
  List<FornecedorDto> _filteredFornecedores = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  // Filtros e paginação
  int _currentPage = 1;
  int _pageSize = 20;
  String _searchQuery = '';
  String _sortBy = 'name';
  String _sortDir = 'asc';
  String? _statusFilter;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _dao = FornecedoresLocalDaoSharedPrefs();
    _loadFornecedores();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFornecedores() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final fornecedores = await _dao.listAll();
      if (!mounted) return;

      setState(() {
        _allFornecedores = fornecedores;
        _applyFiltersAndSort();
        _isLoading = false;
        _hasError = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _errorMessage = 'Erro ao carregar fornecedores: $e';
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_errorMessage)),
      );
    }
  }

  void _applyFiltersAndSort() {
    var result = _allFornecedores;

    // Aplicar filtro de busca
    if (_searchQuery.isNotEmpty) {
      result = result
          .where((f) =>
              f.name.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    // Aplicar filtro de status
    if (_statusFilter != null) {
      result =
          result.where((f) => f.status == _statusFilter).toList();
    }

    // Aplicar ordenação
    result.sort((a, b) {
      int cmp = 0;
      switch (_sortBy) {
        case 'name':
          cmp = a.name.compareTo(b.name);
          break;
        case 'rating':
          cmp = (a.rating ?? 0).compareTo(b.rating ?? 0);
          break;
        case 'distance_km':
          cmp = (a.distanceKm ?? 0).compareTo(b.distanceKm ?? 0);
          break;
        case 'updated_at':
          cmp = a.updatedAt.compareTo(b.updatedAt);
          break;
        default:
          cmp = a.name.compareTo(b.name);
      }
      return _sortDir == 'asc' ? cmp : -cmp;
    });

    _filteredFornecedores = result;
    _currentPage = 1; // Reset paginação
  }

  List<FornecedorDto> _getPaginatedList() {
    final startIdx = (_currentPage - 1) * _pageSize;
    final endIdx = startIdx + _pageSize;

    if (startIdx >= _filteredFornecedores.length) {
      return [];
    }

    return _filteredFornecedores.sublist(
      startIdx,
      endIdx.clamp(0, _filteredFornecedores.length),
    );
  }

  int get _totalPages {
    if (_filteredFornecedores.isEmpty) return 1;
    return (_filteredFornecedores.length / _pageSize).ceil();
  }

  void _onSearch(String query) {
    setState(() {
      _searchQuery = query;
      _applyFiltersAndSort();
    });
  }

  void _onSortChanged(String? value) {
    if (value != null) {
      setState(() {
        _sortBy = value;
        _applyFiltersAndSort();
      });
    }
  }

  void _toggleSortDirection() {
    setState(() {
      _sortDir = _sortDir == 'asc' ? 'desc' : 'asc';
      _applyFiltersAndSort();
    });
  }

  void _onPreviousPage() {
    if (_currentPage > 1) {
      setState(() => _currentPage--);
    }
  }

  void _onNextPage() {
    if (_currentPage < _totalPages) {
      setState(() => _currentPage++);
    }
  }

  @override
  Widget build(BuildContext context) {
    final calmColor = const Color(0xFFBEEAF6);
    final paginatedList = _getPaginatedList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fornecedores'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: Container(color: calmColor, height: 4),
        ),
      ),
      body: Column(
        children: [
          // Barra de busca
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar fornecedor...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _onSearch('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: _onSearch,
            ),
          ),

          // Filtros e ordenação
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    value: _sortBy,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(value: 'name', child: Text('Nome')),
                      DropdownMenuItem(value: 'rating', child: Text('Avaliação')),
                      DropdownMenuItem(
                        value: 'distance_km',
                        child: Text('Distância'),
                      ),
                      DropdownMenuItem(
                        value: 'updated_at',
                        child: Text('Atualização'),
                      ),
                    ],
                    onChanged: _onSortChanged,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(
                    _sortDir == 'asc'
                        ? Icons.arrow_upward
                        : Icons.arrow_downward,
                  ),
                  onPressed: _toggleSortDirection,
                ),
              ],
            ),
          ),

          // Lista ou mensagem de vazio/erro
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _hasError
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline,
                                size: 64, color: Colors.red),
                            const SizedBox(height: 16),
                            Text(_errorMessage),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadFornecedores,
                              child: const Text('Tentar novamente'),
                            ),
                          ],
                        ),
                      )
                    : paginatedList.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.inbox,
                                    size: 64, color: Colors.grey[300]),
                                const SizedBox(height: 16),
                                const Text('Nenhum fornecedor encontrado'),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: paginatedList.length,
                            itemBuilder: (context, index) {
                              final fornecedor = paginatedList[index];
                              return FornecedorListItem(
                                fornecedor: fornecedor,
                                onTap: () {
                                  // TODO: Implementar detalhes do fornecedor
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content:
                                          Text('Selecionado: ${fornecedor.name}'),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
          ),

          // Paginação
          if (paginatedList.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton.icon(
                    onPressed: _currentPage > 1 ? _onPreviousPage : null,
                    icon: const Icon(Icons.chevron_left),
                    label: const Text('Anterior'),
                  ),
                  Text(
                    'Página $_currentPage de $_totalPages',
                    style: const TextStyle(fontSize: 12),
                  ),
                  ElevatedButton.icon(
                    onPressed: _currentPage < _totalPages ? _onNextPage : null,
                    label: const Text('Próxima'),
                    icon: const Icon(Icons.chevron_right),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
