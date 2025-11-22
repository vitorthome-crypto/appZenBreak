import '../../infrastructure/dtos/provider_dto.dart';
import '../../domain/entities/provider.dart';

/// Mapper responsável por converter entre ProviderDto (data layer) e Provider (domain)
/// Centraliza toda a lógica de transformação e validação entre camadas
class ProviderMapper {
  /// Converte um [FornecedorDto] para um [Provider]
  static Provider fromDto(FornecedorDto dto) {
    return Provider(
      id: dto.id,
      name: dto.name,
      imageUrl: dto.imageUrl,
      brandColorHex: dto.brandColorHex,
      rating: dto.rating,
      distanceKm: dto.distanceKm,
      status: dto.status,
      metadata: dto.metadata,
      updatedAt: dto.updatedAt,
    );
  }

  /// Converte um [Provider] para um [FornecedorDto]
  static FornecedorDto toDto(Provider provider) {
    return FornecedorDto(
      id: provider.id,
      name: provider.name,
      imageUrl: provider.imageUrl,
      brandColorHex: provider.brandColorHex,
      rating: provider.rating,
      distanceKm: provider.distanceKm,
      status: provider.status,
      metadata: provider.metadata,
      updatedAt: provider.updatedAt,
    );
  }

  /// Converte uma lista de [FornecedorDto] para [Provider]
  static List<Provider> fromDtoList(List<FornecedorDto> dtos) {
    return dtos.map((dto) => fromDto(dto)).toList();
  }

  /// Converte uma lista de [Provider] para [FornecedorDto]
  static List<FornecedorDto> toDtoList(List<Provider> providers) {
    return providers.map((provider) => toDto(provider)).toList();
  }
}
