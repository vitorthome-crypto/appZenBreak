import 'package:flutter/material.dart';
import '../../domain/entities/provider.dart';

/// Diálogo que exibe detalhes completos de um fornecedor e oferece ações:
/// - FECHAR: Fecha o diálogo
/// - EDITAR: Callback para editar (não implementado, apenas UI)
/// - REMOVER: Callback para remover
class ProviderDetailsDialog extends StatelessWidget {
  final Provider provider;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ProviderDetailsDialog({
    Key? key,
    required this.provider,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          // Imagem/Placeholder do fornecedor
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: _buildImage(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  provider.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                if (provider.status != null)
                  Chip(
                    label: Text(
                      provider.status == 'active'
                          ? '✓ Ativo'
                          : '✗ Inativo',
                      style: const TextStyle(fontSize: 11),
                    ),
                    backgroundColor: provider.status == 'active'
                        ? Colors.green.shade100
                        : Colors.red.shade100,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
              ],
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Detalhes do fornecedor
              _DetailRow(
                label: 'ID',
                value: provider.id.toString(),
              ),
              const Divider(),
              _DetailRow(
                label: 'Avaliação',
                value: provider.rating != null
                    ? '${provider.rating!.toStringAsFixed(1)} ⭐'
                    : 'Sem avaliação',
                valueColor: provider.rating != null
                    ? Colors.amber
                    : Colors.grey,
              ),
              const Divider(),
              _DetailRow(
                label: 'Distância',
                value: provider.distanceKm != null
                    ? '${provider.formattedDistance}'
                    : 'Desconhecida',
              ),
              const Divider(),
              if (provider.brandColorHex != null &&
                  provider.brandColorHex!.isNotEmpty)
                Column(
                  children: [
                    _DetailRow(
                      label: 'Cor da Marca',
                      value: provider.brandColorHex!,
                      widget: Container(
                        width: 40,
                        height: 30,
                        decoration: BoxDecoration(
                          color: _parseColor(provider.brandColorHex),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.grey),
                        ),
                      ),
                    ),
                    const Divider(),
                  ],
                ),
              if (provider.updatedAt != null)
                _DetailRow(
                  label: 'Atualizado em',
                  value: _formatDateTime(provider.updatedAt!),
                ),
              if (provider.metadata != null &&
                  provider.metadata!.isNotEmpty)
                Column(
                  children: [
                    const Divider(),
                    _DetailRow(
                      label: 'Metadados',
                      value: provider.metadata.toString(),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
      actions: [
        // Botão FECHAR
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('FECHAR'),
        ),
        // Botão EDITAR (UI apenas)
        TextButton(
          onPressed: onEdit != null
              ? () {
                  Navigator.pop(context);
                  onEdit?.call();
                }
              : null,
          child: const Text('EDITAR'),
        ),
        // Botão REMOVER (com confirmação)
        TextButton(
          onPressed: onDelete != null
              ? () {
                  Navigator.pop(context);
                  _showDeleteConfirmation(context);
                }
              : null,
          style: TextButton.styleFrom(
            foregroundColor: Colors.red,
          ),
          child: const Text('REMOVER'),
        ),
      ],
    );
  }

  /// Constrói a imagem do fornecedor
  Widget _buildImage() {
    if (provider.imageUrl != null && provider.imageUrl!.isNotEmpty) {
      return Image.network(
        provider.imageUrl!,
        width: 56,
        height: 56,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholder();
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return SizedBox(
            width: 56,
            height: 56,
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                ),
              ),
            ),
          );
        },
      );
    }
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    try {
      if (provider.brandColorHex == null ||
          provider.brandColorHex!.isEmpty) {
        return _defaultPlaceholder();
      }

      final color = _parseColor(provider.brandColorHex);
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
      return _defaultPlaceholder();
    }
  }

  Widget _defaultPlaceholder() {
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

  /// Parse hex color string to Color
  Color _parseColor(String? hexColor) {
    if (hexColor == null || hexColor.isEmpty) {
      return const Color(0xFF6C63FF);
    }
    try {
      final hex = hexColor.replaceFirst('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (e) {
      return const Color(0xFF6C63FF);
    }
  }

  /// Formata data/hora para exibição
  String _formatDateTime(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} às ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  /// Mostra diálogo de confirmação antes de remover
  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirmar remoção'),
        content: Text(
            'Você tem certeza que deseja remover "${provider.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('CANCELAR'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              onDelete?.call();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('REMOVER'),
          ),
        ],
      ),
    );
  }
}

/// Widget reutilizável para exibir uma linha de detalhe
class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final Widget? widget;

  const _DetailRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.widget,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 12),
              child: widget ??
                  Text(
                    value,
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      color: valueColor ?? Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
