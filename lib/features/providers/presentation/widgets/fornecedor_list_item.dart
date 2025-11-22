import 'package:flutter/material.dart';
import '../../domain/entities/provider.dart';

class FornecedorListItem extends StatelessWidget {
  final Provider fornecedor;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const FornecedorListItem({
    Key? key,
    required this.fornecedor,
    this.onTap,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Dismissible(
        key: Key('fornecedor_${fornecedor.id}'),
        background: Container(
          color: Colors.red,
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 16),
          child: const Icon(Icons.delete, color: Colors.white),
        ),
        onDismissed: (_) => onDelete?.call(),
        child: ListTile(
          onTap: onTap,
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: fornecedor.imageUrl != null &&
                    fornecedor.imageUrl!.isNotEmpty
                ? Image.network(
                    fornecedor.imageUrl!,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 56,
                        height: 56,
                        color: Colors.grey.shade300,
                        child: const Icon(Icons.image_not_supported,
                            color: Colors.grey),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        width: 56,
                        height: 56,
                        color: Colors.grey.shade200,
                        child: const Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      );
                    },
                  )
                : _buildColoredPlaceholder(),
          ),
          title: Text(
            fornecedor.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (fornecedor.rating != null)
                Row(
                  children: [
                    const Icon(Icons.star, size: 14, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(
                        '${fornecedor.rating?.toStringAsFixed(1)} avaliação'),
                  ],
                ),
              if (fornecedor.distanceKm != null)
                Text('${fornecedor.formattedDistance} de distância'),
              if (fornecedor.status != null)
                Chip(
                  label: Text(
                    fornecedor.status == 'active'
                        ? '✓ Ativo'
                        : '✗ Inativo',
                    style: const TextStyle(fontSize: 12),
                  ),
                  backgroundColor: fornecedor.status == 'active'
                      ? Colors.green.shade100
                      : Colors.red.shade100,
                ),
            ],
          ),
          trailing: const Icon(Icons.chevron_right),
        ),
      ),
    );
  }

  Widget _buildColoredPlaceholder() {
    try {
      if (fornecedor.brandColorHex == null ||
          fornecedor.brandColorHex!.isEmpty) {
        return _buildDefaultPlaceholder();
      }

      final hex = fornecedor.brandColorHex!.replaceFirst('#', '');
      final color = Color(int.parse('FF$hex', radix: 16));

      return Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.store, color: Colors.white),
      );
    } catch (e) {
      return _buildDefaultPlaceholder();
    }
  }

  Widget _buildDefaultPlaceholder() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFF6C63FF),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.store, color: Colors.white),
    );
  }
}

