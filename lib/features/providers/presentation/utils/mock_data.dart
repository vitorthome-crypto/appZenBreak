import 'package:flutter/material.dart';
import '../../infrastructure/dtos/provider_dto.dart';
import '../../infrastructure/dao/providers_local_dao.dart';

/// Utilitário para popular o cache com dados de exemplo
/// Útil para testes e demonstração
class FornecedoresMockData {
  static Future<void> seedMockData() async {
    final dao = FornecedoresLocalDaoSharedPrefs();

    // Limpar cache anterior
    await dao.clear();

    // Dados de exemplo
    final mockFornecedores = [
      FornecedorDto(
        id: 1,
        name: 'Farmácia São José',
        imageUrl: 'https://via.placeholder.com/150?text=Farmacia+SJ',
        brandColorHex: '#1ABC9C',
        rating: 4.7,
        distanceKm: 1.4,
        status: 'active',
        metadata: {
          'tags': ['farmacia', '24h'],
          'featured': true,
        },
        updatedAt: DateTime.now(),
      ),
      FornecedorDto(
        id: 2,
        name: 'Farmácia Central',
        imageUrl: 'https://via.placeholder.com/150?text=Farmacia+Central',
        brandColorHex: '#3498DB',
        rating: 4.5,
        distanceKm: 2.1,
        status: 'active',
        metadata: {
          'tags': ['farmacia'],
          'featured': false,
        },
        updatedAt: DateTime.now(),
      ),
      FornecedorDto(
        id: 3,
        name: 'Drogaria do Bairro',
        imageUrl: 'https://via.placeholder.com/150?text=Drogaria',
        brandColorHex: '#E74C3C',
        rating: 4.2,
        distanceKm: 0.8,
        status: 'active',
        metadata: {
          'tags': ['drogaria', 'ofertas'],
          'featured': true,
        },
        updatedAt: DateTime.now(),
      ),
      FornecedorDto(
        id: 4,
        name: 'Laboratório Premium',
        brandColorHex: '#9B59B6',
        rating: 4.9,
        distanceKm: 3.2,
        status: 'active',
        metadata: {
          'tags': ['laboratorio', 'exames'],
          'featured': false,
        },
        updatedAt: DateTime.now(),
      ),
      FornecedorDto(
        id: 5,
        name: 'Clínica Saúde Total',
        brandColorHex: '#F39C12',
        rating: 4.6,
        distanceKm: 1.9,
        status: 'inactive',
        metadata: {
          'tags': ['clinica', 'consultas'],
          'featured': false,
        },
        updatedAt: DateTime.now().subtract(const Duration(days: 7)),
      ),
    ];

    // Persistir no cache
    await dao.upsertAll(mockFornecedores);
  }
}

/// Widget de teste para popular dados mock
/// Remover após desenvolvimento/testes
class MockDataButton extends StatelessWidget {
  const MockDataButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () async {
        await FornecedoresMockData.seedMockData();
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dados de exemplo carregados!')),
        );
      },
      tooltip: 'Carregar dados de exemplo',
      child: const Icon(Icons.refresh),
    );
  }
}
