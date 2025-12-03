/// Interface de repositório para a entidade `Provider`.
///
/// O repositório encapsula acesso a dados (cache e fontes remotas) e define
/// operações de leitura/escrita que podem ser implementadas por diferentes
/// fontes (local, remota). Manter uma interface clara facilita testes e
/// substituição de implementações.
///
/// ⚠️ Dicas: registre logs nas implementações, trate erros com retry quando
/// apropriado e mantenha as conversões (DTO <-> Entity) centralizadas.

import '../entities/provider.dart';

/// Interface abstrata que define o contrato do repositório de fornecedores.
///
/// Esta versão preserva os métodos esperados pelas implementações existentes
/// no código base (getAll, save, delete, etc.).
abstract class ProvidersRepository {
  /// Retorna todos os fornecedores armazenados (cache ou fonte primária).
  ///
  /// Uso: para carregar listas em telas. Prefira retornar dados do cache para
  /// resposta rápida e atualizar via sync quando necessário.
  Future<List<Provider>> getAll();

  /// Retorna um fornecedor específico por ID.
  ///
  /// Uso: busca direta para detalhes; deve ser eficiente e, quando possível,
  /// utilizar cache local antes de consultar rede.
  Future<Provider?> getById(int id);

  /// Busca fornecedores por consulta de texto.
  ///
  /// Uso: implementações podem pesquisar nome, tags ou metadados; normalize
  /// a query (minúsculas) antes de comparações para consistência.
  Future<List<Provider>> search(String query);

  /// Salva (insere ou atualiza) uma lista de fornecedores no repositório.
  ///
  /// Uso: útil ao sincronizar lotes do servidor para o cache local.
  Future<void> saveAll(List<Provider> providers);

  /// Salva (insere ou atualiza) um único fornecedor.
  Future<void> save(Provider provider);

  /// Deleta um fornecedor por ID.
  Future<void> delete(int id);

  /// Limpa o cache local de fornecedores.
  Future<void> clear();

  /// Retorna fornecedores filtrados por status.
  Future<List<Provider>> getByStatus(String status);

  /// Ordena fornecedores por um critério específico.
  ///
  /// [sortBy] exemplos: 'name', 'rating', 'distance', 'updated_at'.
  Future<List<Provider>> getSorted(String sortBy, {bool ascending = true});
}

/*
// Exemplo de uso:
// final repo = ProvidersRepositoryImpl(localDataSource: ...);
// final all = await repo.getAll();
// await repo.save(Provider(...));

// Dicas de implementação:
// - Centralize mapeamentos DTO <-> Entity em mappers separados.
// - Faça operações de I/O em camadas de datasource; o repositório orquestra.
// - Para testes, forneça um mock que implemente esta interface.
*/
