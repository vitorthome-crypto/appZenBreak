import '../../infrastructure/dtos/provider_dto.dart';

/// Interface abstrata para operações de acesso a dados locais de fornecedores
/// Define o contrato que qualquer implementação deve seguir
abstract class ProvidersLocalDataSource {
  /// Retorna todos os fornecedores armazenados localmente
  Future<List<FornecedorDto>> getAll();

  /// Retorna um fornecedor específico por ID
  Future<FornecedorDto?> getById(int id);

  /// Insere ou atualiza múltiplos fornecedores
  Future<void> saveAll(List<FornecedorDto> fornecedores);

  /// Insere ou atualiza um único fornecedor
  Future<void> save(FornecedorDto fornecedor);

  /// Deleta um fornecedor por ID
  Future<void> delete(int id);

  /// Limpa o cache de fornecedores
  Future<void> clear();
}
