import 'package:flutter/material.dart';
import '../../infrastructure/dao/providers_local_dao.dart';
import '../../infrastructure/dtos/provider_dto.dart';

class FornecedoresMockData {
  static Future<void> seedMockData(
      FornecedoresLocalDaoSharedPrefs dao) async {
    // Limpar dados anteriores
    await dao.clear();

    // Criar 5 fornecedores de exemplo
    final mockFornecedores = [
      FornecedorDto(
        id: 1,
        name: 'Farmácia São José',
        imageUrl: 'https://via.placeholder.com/56?text=FSJ',
        rating: 4.7,
        distanceKm: 1.4,
        status: 'active',
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      FornecedorDto(
        id: 2,
        name: 'Farmácia Central',
        imageUrl: 'https://via.placeholder.com/56?text=FC',
        rating: 4.5,
        distanceKm: 2.1,
        status: 'active',
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      FornecedorDto(
        id: 3,
        name: 'Drogaria Popular',
        imageUrl: null,
        rating: 3.8,
        distanceKm: 0.8,
        status: 'active',
        updatedAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      FornecedorDto(
        id: 4,
        name: 'Farmácia do Bairro',
        imageUrl: 'https://via.placeholder.com/56?text=FDB',
        rating: 4.2,
        distanceKm: 3.5,
        status: 'inactive',
        updatedAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      FornecedorDto(
        id: 5,
        name: 'Megafarmácia',
        imageUrl: 'https://via.placeholder.com/56?text=MF',
        rating: 4.9,
        distanceKm: 5.0,
        status: 'active',
        updatedAt: DateTime.now().subtract(const Duration(days: 4)),
      ),
    ];

    // Salvar no DAO
    await dao.upsertAll(mockFornecedores);
  }
}

/// Widget FAB para carregar dados mock (útil para desenvolvimento/testes)
class MockDataButton extends StatelessWidget {
  final FornecedoresLocalDaoSharedPrefs dao;
  final VoidCallback? onSuccess;

  const MockDataButton({
    Key? key,
    required this.dao,
    this.onSuccess,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      tooltip: 'Carregar dados de teste',
      onPressed: () async {
        try {
          await FornecedoresMockData.seedMockData(dao);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✓ Dados mock carregados com sucesso'),
              ),
            );
          }
          onSuccess?.call();
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('✗ Erro ao carregar dados mock: $e'),
              ),
            );
          }
        }
      },
      child: const Icon(Icons.refresh),
    );
  }
}
