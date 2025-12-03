import '../../domain/repositories/historico_repository.dart';
import '../datasources/historico_remote_data_source.dart';

/// Implementação do repositório de histórico usando datasource remoto (Supabase).
class HistoricoRepositoryImpl implements HistoricoRepository {
  final HistoricoRemoteDataSource remoteDataSource;

  HistoricoRepositoryImpl({required this.remoteDataSource});

  @override
  Future<void> salvarSessao({
    String? userId,
    required int duracao_segundos,
    int? meditacao_id,
  }) async {
    try {
      await remoteDataSource.salvarSessao(
        userId: userId,
        duracao_segundos: duracao_segundos,
        meditacao_id: meditacao_id,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, int>> buscarEstatisticas({String? userId}) async {
    try {
      return await remoteDataSource.buscarEstatisticas(userId: userId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> obterTodas({String? userId}) async {
    try {
      return await remoteDataSource.obterTodas(userId: userId);
    } catch (e) {
      rethrow;
    }
  }
}
