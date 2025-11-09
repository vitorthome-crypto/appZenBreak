class ProviderDto {
  final int id;
  final String name;
  final String? imageUrl;
  final String? brandColorHex;
  final double? rating;
  final double? distanceKm;
  final Map<String, dynamic>? metadata;
  final DateTime updatedAt;

  ProviderDto({
    required this.id,
    required this.name,
    this.imageUrl,
    this.brandColorHex,
    this.rating,
    this.distanceKm,
    this.metadata,
    required this.updatedAt,
  });

  factory ProviderDto.fromMap(Map<String, dynamic> map) {
    return ProviderDto(
      id: map['id'] as int,
      name: map['name'] as String,
      imageUrl: map['image_url'] as String?,
      brandColorHex: map['brand_color_hex'] as String?,
      rating: map['rating'] as double?,
      distanceKm: map['distance_km'] as double?,
      metadata: map['metadata'] as Map<String, dynamic>?,
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'image_url': imageUrl,
      'brand_color_hex': brandColorHex,
      'rating': rating,
      'distance_km': distanceKm,
      'metadata': metadata,
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}