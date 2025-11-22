class FornecedorDto {
  final int id;
  final String name;
  final String? imageUrl;
  final String? brandColorHex;
  final double? rating;
  final double? distanceKm;
  final String? status;
  final Map<String, dynamic>? metadata;
  final DateTime? updatedAt;

  FornecedorDto({
    required this.id,
    required this.name,
    this.imageUrl,
    this.brandColorHex,
    this.rating,
    this.distanceKm,
    this.status,
    this.metadata,
    this.updatedAt,
  });

  /// Cria um [FornecedorDto] a partir de um mapa (desserialização)
  factory FornecedorDto.fromMap(Map<String, dynamic> map) {
    return FornecedorDto(
      id: map['id'] as int,
      name: map['name'] as String,
      imageUrl: map['imageUrl'] as String?,
      brandColorHex: map['brandColorHex'] as String?,
      rating: (map['rating'] as num?)?.toDouble(),
      distanceKm: (map['distanceKm'] as num?)?.toDouble(),
      status: map['status'] as String?,
      metadata: map['metadata'] as Map<String, dynamic>?,
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'] as String)
          : null,
    );
  }

  /// Converte este [FornecedorDto] para um mapa (serialização)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'brandColorHex': brandColorHex,
      'rating': rating,
      'distanceKm': distanceKm,
      'status': status,
      'metadata': metadata,
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  @override
  String toString() => 'FornecedorDto(id: $id, name: $name, rating: $rating)';
}
