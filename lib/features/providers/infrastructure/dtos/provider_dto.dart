/// Data Transfer Object (DTO) para Fornecedor
/// Facilita serialização/desserialização de dados entre API/cache local
class FornecedorDto {
  final int id;
  final String name;
  final String? imageUrl;
  final String? brandColorHex;
  final double? rating;
  final double? distanceKm;
  final String? status;
  final Map<String, dynamic>? metadata;
  final DateTime updatedAt;

  FornecedorDto({
    required this.id,
    required this.name,
    this.imageUrl,
    this.brandColorHex,
    this.rating,
    this.distanceKm,
    this.status,
    this.metadata,
    required this.updatedAt,
  });

  /// Cria uma instância a partir de um mapa (desserialização)
  factory FornecedorDto.fromMap(Map<String, dynamic> map) {
    return FornecedorDto(
      id: map['id'] as int,
      name: map['name'] as String,
      imageUrl: map['image_url'] as String?,
      brandColorHex: map['brand_color_hex'] as String?,
      rating: (map['rating'] as num?)?.toDouble(),
      distanceKm: (map['distance_km'] as num?)?.toDouble(),
      status: map['status'] as String?,
      metadata: map['metadata'] as Map<String, dynamic>?,
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  /// Converte para mapa (serialização)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'image_url': imageUrl,
      'brand_color_hex': brandColorHex,
      'rating': rating,
      'distance_km': distanceKm,
      'status': status,
      'metadata': metadata,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  String toString() => 'FornecedorDto(id: $id, name: $name, rating: $rating)';
}
