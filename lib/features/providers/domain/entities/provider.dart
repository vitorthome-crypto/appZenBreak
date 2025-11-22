/// Entidade que representa um fornecedor no domínio da aplicação
/// Contém apenas lógica de negócio e validações
class Provider {
  final int id;
  final String name;
  final String? imageUrl;
  final String? brandColorHex;
  final double? rating;
  final double? distanceKm;
  final String? status;
  final Map<String, dynamic>? metadata;
  final DateTime? updatedAt;

  Provider({
    required this.id,
    required this.name,
    this.imageUrl,
    this.brandColorHex,
    this.rating,
    this.distanceKm,
    this.status,
    this.metadata,
    this.updatedAt,
  }) : assert(
    rating == null || (rating >= 0 && rating <= 5),
    'Rating deve estar entre 0 e 5',
  );

  /// Validações de negócio
  bool get isActive => status == 'active';
  bool get isInactive => status == 'inactive';
  
  /// Valida se o provider tem dados suficientes
  bool get isValid => name.isNotEmpty && id > 0;
  
  /// Formata a distância para exibição
  String get formattedDistance => distanceKm != null 
      ? '${distanceKm!.toStringAsFixed(1)} km' 
      : 'N/A';
  
  /// Formata o rating para exibição
  String get formattedRating => rating != null 
      ? rating!.toStringAsFixed(1) 
      : 'N/A';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Provider &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          imageUrl == other.imageUrl &&
          brandColorHex == other.brandColorHex &&
          rating == other.rating &&
          distanceKm == other.distanceKm &&
          status == other.status;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      imageUrl.hashCode ^
      brandColorHex.hashCode ^
      rating.hashCode ^
      distanceKm.hashCode ^
      status.hashCode;

  @override
  String toString() =>
      'Provider(id: $id, name: $name, rating: $rating, distance: $distanceKm km)';

  /// Cria uma cópia do Provider com campos opcionais atualizados
  Provider copyWith({
    int? id,
    String? name,
    String? imageUrl,
    String? brandColorHex,
    double? rating,
    double? distanceKm,
    String? status,
    Map<String, dynamic>? metadata,
    DateTime? updatedAt,
  }) {
    return Provider(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      brandColorHex: brandColorHex ?? this.brandColorHex,
      rating: rating ?? this.rating,
      distanceKm: distanceKm ?? this.distanceKm,
      status: status ?? this.status,
      metadata: metadata ?? this.metadata,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
