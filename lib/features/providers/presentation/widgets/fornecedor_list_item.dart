import 'package:flutter/material.dart';
import '../../infrastructure/dtos/provider_dto.dart';

/// Widget que exibe um fornecedor em formato de card/tile
class FornecedorListItem extends StatelessWidget {
  final FornecedorDto fornecedor;
  final VoidCallback? onTap;

  const FornecedorListItem({
    super.key,
    required this.fornecedor,
    this.onTap,
  });

  String _formatRating(double? rating) {
    if (rating == null) return '-';
    return rating.toStringAsFixed(1);
  }

  String _formatDistance(double? distance) {
    if (distance == null) return '-';
    return '${distance.toStringAsFixed(1)} km';
  }

  @override
  Widget build(BuildContext context) {
    final calmColor = const Color(0xFFBEEAF6);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        onTap: onTap,
        leading: fornecedor.imageUrl != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  fornecedor.imageUrl!,
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: calmColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.business),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    );
                  },
                ),
              )
            : Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: calmColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.business),
              ),
        title: Text(fornecedor.name),
        subtitle: Row(
          children: [
            if (fornecedor.rating != null) ...[
              const Icon(Icons.star, size: 14, color: Colors.orange),
              const SizedBox(width: 4),
              Text(_formatRating(fornecedor.rating)),
              const SizedBox(width: 8),
            ],
            if (fornecedor.distanceKm != null) ...[
              const Icon(Icons.location_on, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text(_formatDistance(fornecedor.distanceKm)),
            ],
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
