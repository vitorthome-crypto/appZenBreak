import '../entities/provider.dart';

/// Interface abstrata que define o contrato do repositório de fornecedores
/// Separa a lógica de negócio da implementação de acesso a dados
abstract class ProvidersRepository {
  /// Retorna todos os fornecedores
  Future<List<Provider>> getAll();

  /// Retorna um fornecedor específico por ID
  Future<Provider?> getById(int id);

  /// Busca fornecedores por nome
  Future<List<Provider>> search(String query);

  /// Salva (insere ou atualiza) múltiplos fornecedores
  Future<void> saveAll(List<Provider> providers);

  /// Salva um único fornecedor
  Future<void> save(Provider provider);

  /// Deleta um fornecedor por ID
  Future<void> delete(int id);

  /// Limpa o cache de fornecedores
  Future<void> clear();

  /// Retorna fornecedores filtrados por status
  Future<List<Provider>> getByStatus(String status);

  /// Ordena fornecedores por um critério específico
  /// [sortBy] pode ser: 'name', 'rating', 'distance', 'updated_at'
  Future<List<Provider>> getSorted(String sortBy, {bool ascending = true});
}
