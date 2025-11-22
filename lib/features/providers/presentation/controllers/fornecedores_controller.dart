import 'package:flutter/foundation.dart';
import '../../domain/entities/provider.dart';
import '../../domain/repositories/providers_repository.dart';

/// Controller responsável por gerenciar o estado e a lógica da página de fornecedores
/// Utiliza ChangeNotifier para reatividade com o Provider package
class FornecedoresController extends ChangeNotifier {
  final ProvidersRepository _repository;

  // Estado
  List<Provider> _allProviders = [];
  List<Provider> _filteredProviders = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Filtros e busca
  String _searchQuery = '';
  String _sortBy = 'name'; // name, rating, distance, updated_at
  bool _sortAscending = true;
  String _statusFilter = 'all'; // all, active, inactive

  // Paginação
  static const int _pageSize = 20;
  int _currentPage = 1;

  FornecedoresController({required ProvidersRepository repository})
      : _repository = repository;

  // Getters
  List<Provider> get allProviders => _allProviders;
  List<Provider> get filteredProviders => _filteredProviders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String get sortBy => _sortBy;
  bool get sortAscending => _sortAscending;
  String get statusFilter => _statusFilter;
  int get currentPage => _currentPage;
  int get pageSize => _pageSize;

  /// Quantidade total de páginas
  int get totalPages =>
      (_filteredProviders.length / _pageSize).ceil().toInt();

  /// Fornecedores da página atual
  List<Provider> get currentPageProviders {
    final startIndex = (_currentPage - 1) * _pageSize;
    final endIndex = (startIndex + _pageSize).clamp(0, _filteredProviders.length);
    return _filteredProviders.sublist(startIndex, endIndex);
  }

  /// Carrega fornecedores iniciais
  Future<void> loadProviders() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _allProviders = await _repository.getAll();
      _applyFiltersAndSort();
    } catch (e) {
      _errorMessage = 'Erro ao carregar fornecedores: $e';
      print(_errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Atualiza a busca por nome
  void setSearchQuery(String query) {
    _searchQuery = query;
    _currentPage = 1; // Reset para primeira página
    _applyFiltersAndSort();
  }

  /// Altera o filtro de status
  void setStatusFilter(String status) {
    _statusFilter = status;
    _currentPage = 1;
    _applyFiltersAndSort();
  }

  /// Altera a ordenação
  void setSortBy(String sortBy, {bool ascending = true}) {
    _sortBy = sortBy;
    _sortAscending = ascending;
    _currentPage = 1;
    _applyFiltersAndSort();
  }

  /// Muda para a página anterior
  void previousPage() {
    if (_currentPage > 1) {
      _currentPage--;
      notifyListeners();
    }
  }

  /// Muda para a próxima página
  void nextPage() {
    if (_currentPage < totalPages) {
      _currentPage++;
      notifyListeners();
    }
  }

  /// Vai para uma página específica
  void goToPage(int page) {
    if (page >= 1 && page <= totalPages) {
      _currentPage = page;
      notifyListeners();
    }
  }

  /// Deleta um fornecedor
  Future<void> deleteProvider(int id) async {
    try {
      await _repository.delete(id);
      _allProviders.removeWhere((p) => p.id == id);
      _applyFiltersAndSort();
    } catch (e) {
      _errorMessage = 'Erro ao deletar fornecedor: $e';
      print(_errorMessage);
      notifyListeners();
    }
  }

  /// Salva/atualiza um fornecedor
  Future<void> saveProvider(Provider provider) async {
    try {
      await _repository.save(provider);
      
      // Atualiza a lista local
      final index = _allProviders.indexWhere((p) => p.id == provider.id);
      if (index >= 0) {
        _allProviders[index] = provider;
      } else {
        _allProviders.add(provider);
      }
      
      _applyFiltersAndSort();
    } catch (e) {
      _errorMessage = 'Erro ao salvar fornecedor: $e';
      print(_errorMessage);
      notifyListeners();
    }
  }

  /// Limpa o cache
  Future<void> clearCache() async {
    try {
      await _repository.clear();
      _allProviders.clear();
      _filteredProviders.clear();
      _currentPage = 1;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erro ao limpar cache: $e';
      print(_errorMessage);
      notifyListeners();
    }
  }

  /// Aplica filtros e ordenação à lista
  void _applyFiltersAndSort() async {
    try {
      List<Provider> filtered = List.from(_allProviders);

      // Aplicar filtro de status
      if (_statusFilter != 'all') {
        filtered = filtered
            .where((p) => p.status == _statusFilter)
            .toList();
      }

      // Aplicar busca por nome
      if (_searchQuery.isNotEmpty) {
        filtered = await _repository.search(_searchQuery);
        
        // Re-aplicar filtro de status após busca
        if (_statusFilter != 'all') {
          filtered = filtered
              .where((p) => p.status == _statusFilter)
              .toList();
        }
      }

      // Aplicar ordenação
      if (_sortBy == 'name') {
        filtered.sort((a, b) => _sortAscending
            ? a.name.compareTo(b.name)
            : b.name.compareTo(a.name));
      } else if (_sortBy == 'rating') {
        filtered.sort((a, b) {
          final aRating = a.rating ?? 0;
          final bRating = b.rating ?? 0;
          return _sortAscending
              ? aRating.compareTo(bRating)
              : bRating.compareTo(aRating);
        });
      } else if (_sortBy == 'distance') {
        filtered.sort((a, b) {
          final aDistance = a.distanceKm ?? double.maxFinite;
          final bDistance = b.distanceKm ?? double.maxFinite;
          return _sortAscending
              ? aDistance.compareTo(bDistance)
              : bDistance.compareTo(aDistance);
        });
      } else if (_sortBy == 'updated_at') {
        filtered.sort((a, b) {
          final aDate = a.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          final bDate = b.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          return _sortAscending
              ? aDate.compareTo(bDate)
              : bDate.compareTo(aDate);
        });
      }

      _filteredProviders = filtered;
      _currentPage = 1; // Reset para primeira página após filtrar
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erro ao aplicar filtros: $e';
      print(_errorMessage);
      notifyListeners();
    }
  }
}
