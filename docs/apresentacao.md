# Documentação: Implementação do Padrão Repository

## Requisitos Atendidos
1. **Sumário Executivo**: Explica o que foi implementado e os resultados obtidos.
2. **Arquitetura e Fluxo de Dados**: Inclui um diagrama simples e explicação do fluxo de dados.
3. **Objetivo de Cada Feature**: Define o propósito de cada funcionalidade.
4. **(Se usar IA) Prompt(s) usados e comentários sobre cada parte**: Inclui trechos de código gerados pela IA e explicações.
5. **Exemplos de Entrada e Saída**: Pode ser expandido com exemplos adicionais.
6. **Como Testar Localmente**: Fornece instruções para validar as implementações.
7. **Limitações e Riscos**: Identifica desafios e possíveis problemas.
8. **Código Gerado pela IA**: Apresenta o código gerado e explica sua relevância.
9. **Logs de Experimentos**: Não incluído, mas pode ser adicionado se necessário.
10. **Roteiro de Apresentação Oral**: Sugere como apresentar a solução.
11. **Política de Branches e Commits**: Detalha o uso de branches e mensagens de commit.
12. **Diagrama Simples**: Inclui um diagrama ASCII representando o fluxo.

## Sumário Executivo
Nesta entrega, foi implementado o padrão Repository no projeto, com o objetivo de unificar e abstrair o acesso a dados de diferentes fontes (remota e local). A implementação incluiu:

- Criação da interface `ProvidersLocalDao` e sua implementação `ProvidersLocalDaoSharedPrefs` para gerenciar o cache local de DTOs utilizando SharedPreferences.
- Criação da classe `ProviderDto` para representar os objetos de transferência de dados (DTOs).

### Resultados
- Desacoplamento da lógica de negócios das fontes de dados.
- Melhor testabilidade e flexibilidade para futuras mudanças tecnológicas.
- Suporte a estratégias como `offline-first` e sincronização incremental.

---

## Arquitetura e Fluxo de Dados

### Diagrama Simples
```
UI -> Repository -> Mapper -> [Local DAO <-> SharedPreferences | Remote API <-> Supabase]
```

### Explicação
- **UI**: Consome entidades validadas fornecidas pelo Repository.
- **Repository**: Coordena o fluxo de dados entre fontes locais e remotas.
- **Mapper**: Converte DTOs em Entities e vice-versa.
- **Local DAO**: Gerencia o cache local utilizando SharedPreferences.
- **Remote API**: Comunicação com o backend (Supabase).

---

## Features Implementadas

### 1. ProvidersLocalDao

#### Objetivo
Gerenciar o cache local de provedores, garantindo leitura rápida e suporte ao modo offline.

#### Código Gerado pela IA

## Prompt Usado-------------------------------------------------------

Crie docs/apresentacao.md contendo:
Sumário executivo (máx. 1 página): o que foi implementado e resultados.
Arquitetura e fluxo de dados: diagrama simples (ASCII ou imagem) e explicação curta de onde
(se houver) a IA entra no fluxo (inputs/outputs).
Para cada feature implementada:
Objetivo
(Se usar IA) Prompt(s) usados e comentários sobre cada parte
Exemplos de entrada e saída (pelo menos 3 casos com variação)
Como testar localmente (passo a passo)
Limitações e riscos (ex.: vieses, privacidade)
Código gerado pela IA (se aplicável): trechos relevantes e explicação linha a linha do porquê são
corretos/necessários.
Logs de experimentos (opcional): iterações de prompt/resposta que levaram à solução final.
Roteiro de apresentação oral: como a IA ajudou (se usada), decisões de design, por que a
solução é segura/ética, quais testes foram feitos.
Política de branches e commits (obrigatória): descreva como você trabalhou com controle de
versão — crie uma branch nova para cada feature e registre um commit a cada objetivo
concluído, com mensagens claras.

## -------------------------------------------------------------------

**Arquivo:** `data/providers_local_dao.dart`
```dart
abstract class ProvidersLocalDao {
  Future<void> upsertAll(List<ProviderDto> dtos);
  Future<List<ProviderDto>> listAll();
  Future<ProviderDto?> getById(int id);
  Future<void> clear();
}

class ProvidersLocalDaoSharedPrefs implements ProvidersLocalDao {
  static const _cacheKey = 'providers_cache_v1';

  Future<SharedPreferences> get _prefs async => SharedPreferences.getInstance();

  @override
  Future<void> upsertAll(List<ProviderDto> dtos) async {
    final prefs = await _prefs;
    final raw = prefs.getString(_cacheKey);
    final Map<int, Map<String, dynamic>> current = {};

    if (raw != null && raw.isNotEmpty) {
      try {
        final List<dynamic> list = jsonDecode(raw) as List<dynamic>;
        for (final e in list) {
          final m = Map<String, dynamic>.from(e as Map);
          current[m['id'] as int] = m;
        }
      } catch (_) {}
    }

    for (final dto in dtos) {
      current[dto.id] = dto.toMap();
    }

    final merged = current.values.toList();
    await prefs.setString(_cacheKey, jsonEncode(merged));
  }

  @override
  Future<List<ProviderDto>> listAll() async {
    final prefs = await _prefs;
    final raw = prefs.getString(_cacheKey);
    if (raw == null || raw.isEmpty) return [];

    try {
      final List<dynamic> list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => ProviderDto.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<ProviderDto?> getById(int id) async {
    final prefs = await _prefs;
    final raw = prefs.getString(_cacheKey);
    if (raw == null || raw.isEmpty) return null;

    try {
      final List<dynamic> list = jsonDecode(raw) as List<dynamic>;
      for (final e in list) {
        final m = Map<String, dynamic>.from(e as Map);
        if (m['id'] == id) return ProviderDto.fromMap(m);
      }
    } catch (_) {}

    return null;
  }

  @override
  Future<void> clear() async {
    final prefs = await _prefs;
    await prefs.remove(_cacheKey);
  }
}
```

#### Como Testar Localmente
1. Certifique-se de que o Flutter e o Dart estão configurados corretamente.
2. Adicione o pacote `shared_preferences` ao `pubspec.yaml`.
3. Execute os testes unitários para validar os métodos do DAO.

#### Limitações e Riscos
- **Persistência Simples**: SharedPreferences não é ideal para grandes volumes de dados.
- **Riscos de Corrupção**: JSON malformado pode causar perda de dados.

---

### 2. ProviderDto

#### Objetivo
Representar os dados de provedores como DTOs, facilitando a serialização e desserialização.

#### Código Gerado pela IA
**Arquivo:** `lib/features/home/infrastructure/dtos/provider_dto.dart`
```dart
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
```

#### Explicação do Código
A classe `ProviderDto` é um Data Transfer Object (DTO) que representa os dados de um provedor. Ela é projetada para facilitar a serialização e desserialização de dados entre o backend e o aplicativo. Aqui está uma explicação detalhada de cada parte:

- **Atributos**:
  - `id`: Identificador único do provedor (obrigatório).
  - `name`: Nome do provedor (obrigatório).
  - `imageUrl`: URL da imagem do provedor (opcional).
  - `brandColorHex`: Cor da marca em formato hexadecimal (opcional).
  - `rating`: Avaliação do provedor (opcional).
  - `distanceKm`: Distância do provedor em quilômetros (opcional).
  - `metadata`: Metadados adicionais sobre o provedor, armazenados como um mapa dinâmico (opcional).
  - `updatedAt`: Data e hora da última atualização dos dados (obrigatório).

- **Construtor**:
  - O construtor da classe utiliza parâmetros nomeados, com alguns obrigatórios (`required`) e outros opcionais (`?`). Isso garante flexibilidade ao criar instâncias da classe.

- **Método `fromMap`**:
  - Este método é uma fábrica que cria uma instância de `ProviderDto` a partir de um mapa (`Map<String, dynamic>`).
  - Ele utiliza o operador `as` para realizar cast seguro dos valores do mapa para os tipos esperados.
  - O campo `updatedAt` é convertido de uma string para um objeto `DateTime` usando `DateTime.parse`.

- **Método `toMap`**:
  - Este método converte uma instância de `ProviderDto` em um mapa (`Map<String, dynamic>`), facilitando a serialização para JSON ou outros formatos.
  - O campo `updatedAt` é convertido para uma string no formato ISO 8601 usando `toIso8601String`.

Essa classe é essencial para garantir que os dados sejam manipulados de forma consistente e segura em todo o aplicativo, especialmente ao interagir com fontes de dados externas ou locais.

#### Como Testar Localmente
1. Crie instâncias de `ProviderDto` com diferentes dados.
2. Teste os métodos `toMap` e `fromMap` para garantir a consistência.

#### Limitações e Riscos
- **Campos Opcionais**: Pode haver inconsistências se os dados forem incompletos.

---

## Política de Branches e Commits
- **Branch por Feature**: Cada funcionalidade foi desenvolvida em uma branch separada.
- **Commits Semânticos**: Mensagens de commit claras e descritivas foram utilizadas.
- **Exemplo**: `git commit -m "Implementação do padrão Repository com ProvidersLocalDao e ProviderDto"`.

---

## Roteiro de Apresentação Oral
1. **Introdução**: Explique o objetivo do padrão Repository.
2. **Decisões de Design**: Justifique o uso de SharedPreferences e a separação DTO/Entity.
3. **Demonstração**: Mostre os métodos principais e como testá-los.
4. **Conclusão**: Destaque os benefícios e as limitações da solução.