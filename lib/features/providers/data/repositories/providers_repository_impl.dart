import '../../domain/entities/provider.dart';
import '../../domain/repositories/providers_repository.dart';
import '../datasources/providers_local_data_source.dart';
import '../mappers/provider_mapper.dart';

/// Implementação de [ProvidersRepository]
/// Coordena a datasource (acesso a dados) e mapper (conversão entre camadas)
/// Implementa a lógica de negócio de filtros, ordenação e busca
class ProvidersRepositoryImpl implements ProvidersRepository {
  final ProvidersLocalDataSource _localDataSource;

  ProvidersRepositoryImpl({required ProvidersLocalDataSource localDataSource})
      : _localDataSource = localDataSource;

  @override
  Future<List<Provider>> getAll() async {
    try {
      final dtos = await _localDataSource.getAll();
      return ProviderMapper.fromDtoList(dtos);
    } catch (e) {
      print('Erro ao obter todos os fornecedores: $e');
      rethrow;
    }
  }

  @override
  Future<Provider?> getById(int id) async {
    try {
      final dto = await _localDataSource.getById(id);
      return dto != null ? ProviderMapper.fromDto(dto) : null;
    } catch (e) {
      print('Erro ao obter fornecedor por ID: $e');
      rethrow;
    }
  }

  @override
  Future<List<Provider>> search(String query) async {
    try {
      final all = await getAll();
      final lowerQuery = query.toLowerCase();
      
      return all
          .where((provider) {
            final nameMatch = provider.name.toLowerCase().contains(lowerQuery);
            final tagsMatch = (provider.metadata?['tags'] as String?)
                    ?.toLowerCase()
                    .contains(lowerQuery) ??
                false;
            return nameMatch || tagsMatch;
          })
          .toList();
    } catch (e) {
      print('Erro ao buscar fornecedores: $e');
      rethrow;
    }
  }

  @override
  Future<void> saveAll(List<Provider> providers) async {
    try {
      final dtos = ProviderMapper.toDtoList(providers);
      await _localDataSource.saveAll(dtos);
    } catch (e) {
      print('Erro ao salvar múltiplos fornecedores: $e');
      rethrow;
    }
  }

  @override
  Future<void> save(Provider provider) async {
    try {
      final dto = ProviderMapper.toDto(provider);
      await _localDataSource.save(dto);
    } catch (e) {
      print('Erro ao salvar fornecedor: $e');
      rethrow;
    }
  }

  @override
  Future<void> delete(int id) async {
    try {
      await _localDataSource.delete(id);
    } catch (e) {
      print('Erro ao deletar fornecedor: $e');
      rethrow;
    }
  }

  @override
  Future<void> clear() async {
    try {
      await _localDataSource.clear();
    } catch (e) {
      print('Erro ao limpar cache: $e');
      rethrow;
    }
  }

  @override
  Future<List<Provider>> getByStatus(String status) async {
    try {
      final all = await getAll();
      return all.where((provider) => provider.status == status).toList();
    } catch (e) {
      print('Erro ao filtrar por status: $e');
      rethrow;
    }
  }

  @override
  Future<List<Provider>> getSorted(String sortBy,
      {bool ascending = true}) async {
    try {
      final all = await getAll();

      switch (sortBy) {
        case 'name':
          all.sort((a, b) => ascending
              ? a.name.compareTo(b.name)
              : b.name.compareTo(a.name));
          break;

        case 'rating':
          all.sort((a, b) {
            final aRating = a.rating ?? 0;
            final bRating = b.rating ?? 0;
            return ascending
                ? aRating.compareTo(bRating)
                : bRating.compareTo(aRating);
          });
          break;

        case 'distance':
          all.sort((a, b) {
            final aDistance = a.distanceKm ?? double.maxFinite;
            final bDistance = b.distanceKm ?? double.maxFinite;
            return ascending
                ? aDistance.compareTo(bDistance)
                : bDistance.compareTo(aDistance);
          });
          break;

        case 'updated_at':
          all.sort((a, b) {
            final aDate = a.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            final bDate = b.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            return ascending
                ? aDate.compareTo(bDate)
                : bDate.compareTo(aDate);
          });
          break;

        default:
          // Padrão: ordena por nome
          all.sort((a, b) => ascending
              ? a.name.compareTo(b.name)
              : b.name.compareTo(a.name));
      }

      return all;
    } catch (e) {
      print('Erro ao ordenar fornecedores: $e');
      rethrow;
    }
  }
}
