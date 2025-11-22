# Arquitetura ZenBreak - Clean Architecture

## Visão Geral

O projeto ZenBreak implementa **Clean Architecture** com separação clara entre camadas de domínio, dados e apresentação. Esta arquitetura garante:

- ✅ **Testabilidade**: Lógica de negócio independente de frameworks
- ✅ **Manutenibilidade**: Responsabilidades bem definidas por camada
- ✅ **Escalabilidade**: Fácil adicionar novos recursos sem modificar código existente
- ✅ **Flexibilidade**: Trocar implementações (ex: SharedPreferences → Firebase) sem afetar outras camadas

---

## Estrutura de Pastas

```
lib/features/providers/
├── domain/                    # Lógica de negócio pura (independente de framework)
│   ├── entities/
│   │   └── provider.dart     # Entidade com validações de domínio
│   └── repositories/
│       └── providers_repository.dart  # Interface de abstração
│
├── data/                      # Implementação de acesso a dados
│   ├── datasources/
│   │   ├── providers_local_data_source.dart       # Interface abstrata
│   │   └── providers_local_data_source_impl.dart  # Implementação SharedPrefs
│   ├── repositories/
│   │   └── providers_repository_impl.dart  # Coordena datasources e mappers
│   └── mappers/
│       └── provider_mapper.dart  # DTO ↔ Entity conversão
│
├── infrastructure/            # Detalhes técnicos (SerDes, low-level cache)
│   ├── dtos/
│   │   └── provider_dto.dart  # Objetos de transferência com toMap/fromMap
│   └── dao/
│       └── providers_local_dao.dart  # Acesso direto a SharedPreferences
│
└── presentation/              # UI e lógica de apresentação
    ├── pages/
    │   └── fornecedores_page.dart  # Página principal de listing
    ├── controllers/
    │   └── fornecedores_controller.dart  # Business logic para UI
    ├── widgets/
    │   └── fornecedor_list_item.dart  # Widget de item
    └── utils/
        └── mock_data.dart  # Dados de teste
```

---

## Fluxo de Dados

### 🔄 Leitura (Carregamento de Fornecedores)

```
FornecedoresPage (UI)
    ↓
FornecedoresController (setState via ChangeNotifier)
    ↓
ProvidersRepository.getAll()
    ↓
ProvidersLocalDataSource.getAll() → SharedPreferences
    ↓
ProvidersDTO[] → ProviderMapper.fromDtoList()
    ↓
Provider[] (Entities) → UI re-renders
```

### ✏️ Escrita (Salvar Fornecedor)

```
FornecedoresPage (User Action)
    ↓
FornecedoresController.addProvider(name, rating...)
    ↓
ProvidersRepository.add(entity)
    ↓
ProviderMapper.toDto(entity)
    ↓
ProvidersLocalDataSource.add(dto)
    ↓
SharedPreferences.setString('providers', json)
    ↓
notifyListeners() → UI atualiza
```

---

## Camadas Explicadas

### 📌 **Domain Layer** (lib/features/providers/domain/)

**Propósito**: Representar regras de negócio **independentes de qualquer framework**.

**Componentes**:

#### `entities/provider.dart`
```dart
class Provider {
  final int id;
  final String name;
  final double? rating;
  final String? status;
  
  // Validações de domínio
  bool get isActive => status == 'active';
  bool get isValid => name.isNotEmpty && id > 0;
  
  // Validação no construtor
  Provider({...}) : assert(rating == null || (rating >= 0 && rating <= 5));
}
```

**Características**:
- ✅ Sem dependências externas (nem Flutter!)
- ✅ Contém validações de negócio (`isActive`, `isValid`)
- ✅ Imutável (final fields)
- ✅ `==` operator para comparação

#### `repositories/providers_repository.dart`
```dart
abstract class ProvidersRepository {
  Future<List<Provider>> getAll();
  Future<Provider?> getById(int id);
  Future<void> add(Provider provider);
  Future<void> delete(int id);
}
```

**Características**:
- ✅ Interface que define o contrato
- ✅ Retorna entities (não DTOs)
- ✅ Não sabe como os dados são persistidos

---

### 🗄️ **Data Layer** (lib/features/providers/data/)

**Propósito**: Implementar persistência e conversão entre formatos.

#### `datasources/providers_local_data_source.dart`
```dart
abstract class ProvidersLocalDataSource {
  Future<List<ProviderDTO>> getAll();
  Future<ProviderDTO?> getById(int id);
  Future<void> add(ProviderDTO dto);
}
```

**Características**:
- ✅ Interface que abstrai o armazenamento
- ✅ Trabalha com DTOs (formato de serialização)
- ✅ Desacoplado de SharedPreferences

#### `datasources/providers_local_data_source_impl.dart`
```dart
class ProvidersLocalDataSourceImpl implements ProvidersLocalDataSource {
  final SharedPreferences prefs;
  
  @override
  Future<List<ProviderDTO>> getAll() async {
    final json = prefs.getString(_key);
    return ProviderDTO.fromJsonList(json);
  }
}
```

**Características**:
- ✅ Implementação concreta usando SharedPreferences
- ✅ Pode ser facilmente substituída (ex: Firebase)
- ✅ Conversão JSON ↔ DTO

#### `mappers/provider_mapper.dart`
```dart
class ProviderMapper {
  // DTO → Entity (dados → domínio)
  static Provider fromDto(ProviderDTO dto) {
    return Provider(
      id: dto.id,
      name: dto.name,
      rating: dto.rating,
    );
  }
  
  // Entity → DTO (domínio → dados)
  static ProviderDTO toDto(Provider entity) {
    return ProviderDTO(
      id: entity.id,
      name: entity.name,
      rating: entity.rating,
    );
  }
}
```

**Características**:
- ✅ Converte entre camadas (isolamento)
- ✅ Bidireção (fromDto + toDto)
- ✅ Possibilita enriquecimento/filtragem de dados

#### `repositories/providers_repository_impl.dart`
```dart
class ProvidersRepositoryImpl implements ProvidersRepository {
  final ProvidersLocalDataSource _localDataSource;
  
  @override
  Future<List<Provider>> getAll() async {
    final dtos = await _localDataSource.getAll();
    return ProviderMapper.fromDtoList(dtos);
  }
}
```

**Características**:
- ✅ Implementa a interface do domínio
- ✅ Coordena datasource + mapper
- ✅ Retorna entities (nunca DTOs para cima)

---

### 🎨 **Presentation Layer** (lib/features/providers/presentation/)

**Propósito**: UI e lógica de apresentação (com estado reativo).

#### `controllers/fornecedores_controller.dart`
```dart
class FornecedoresController extends ChangeNotifier {
  final ProvidersRepository _repository;
  
  List<Provider> _filteredProviders = [];
  String _searchQuery = '';
  
  Future<void> loadProviders() async {
    _allProviders = await _repository.getAll();
    _applyFiltersAndSort();
    notifyListeners(); // UI atualiza
  }
  
  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFiltersAndSort();
    notifyListeners();
  }
}
```

**Características**:
- ✅ Extends `ChangeNotifier` para reatividade
- ✅ Orquestra casos de uso (load, search, sort)
- ✅ Notifica listeners quando estado muda
- ✅ Trabalha apenas com entities

#### `pages/fornecedores_page.dart`
```dart
class FornecedoresPage extends StatefulWidget {
  late FornecedoresController _controller;
  
  @override
  void initState() {
    final prefs = await SharedPreferences.getInstance();
    final dataSource = ProvidersLocalDataSourceImpl(prefs: prefs);
    final repository = ProvidersRepositoryImpl(dataSource: dataSource);
    _controller = FornecedoresController(repository: repository);
    
    await _controller.loadProviders();
  }
}
```

**Características**:
- ✅ Injeta dependências (dataSource → repository → controller)
- ✅ Usa controller para lógica, não implementa lógica
- ✅ Constrói UI baseado no estado do controller

#### `widgets/fornecedor_list_item.dart`
```dart
class FornecedorListItem extends StatelessWidget {
  final Provider fornecedor; // Recebe entity, não DTO!
  
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(fornecedor.name),
      subtitle: Text(fornecedor.formattedRating),
    );
  }
}
```

**Características**:
- ✅ Recebe entities (nunca DTOs)
- ✅ Dumb widget (sem lógica de negócio)
- ✅ Usa getters formatados da entity

---

### 📦 **Infrastructure Layer** (lib/features/providers/infrastructure/)

**Propósito**: Detalhes técnicos de implementação (serialização, cache baixo nível).

#### `dtos/provider_dto.dart`
```dart
class ProviderDTO {
  final int id;
  final String name;
  final double? rating;
  
  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'rating': rating,
  };
  
  factory ProviderDTO.fromMap(Map<String, dynamic> map) => ProviderDTO(
    id: map['id'],
    name: map['name'],
    rating: map['rating'],
  );
}
```

**Características**:
- ✅ Objetos transferência de dados (Serialization)
- ✅ Métodos toMap/fromMap para JSON
- ✅ Estrutura espelha a storage (ex: banco de dados)

#### `dao/providers_local_dao.dart`
```dart
abstract class ProvidersLocalDAO {
  Future<List<ProviderDTO>> listAll();
  Future<void> insert(ProviderDTO dto);
}

class ProvidersLocalDAOSharedPrefs implements ProvidersLocalDAO {
  final SharedPreferences prefs;
  
  @override
  Future<List<ProviderDTO>> listAll() async {
    final json = prefs.getString('providers_key');
    return ProviderDTO.fromJsonList(json);
  }
}
```

**Características**:
- ✅ Acesso direto a SharedPreferences
- ✅ Usado por datasource (datasource > dao)
- ✅ Isolado em infrastructure (não se vaza para camadas superiores)

---

## Benefícios da Arquitetura

| Benefício | Como | Exemplo |
|-----------|------|---------|
| **Testabilidade** | Domain layer sem deps | Testar `Provider.isValid` sem mock |
| **Manutenibilidade** | Responsabilidades claras | Trocar JSON → XML só em DTO |
| **Escalabilidade** | Fácil adicionar camadas | Adicionar API remota = novo DataSource |
| **Reutilização** | Repository genérico | Mesma logic para mobile + web |
| **Debugging** | Fluxo linear | Erro em filtro? Procura em controller |

---

## Exemplo: Adicionar API Remota

**Atual**: Só SharedPreferences local

**Desejo**: Adicionar API remota

**Solução**:
```dart
// 1. Criar novo datasource
class ProvidersRemoteDataSourceImpl implements ProvidersDataSource {
  Future<List<ProviderDTO>> getAll() async {
    final response = await http.get(Uri.parse('https://api.com/providers'));
    return ProviderDTO.fromJsonList(response.body);
  }
}

// 2. Atualizar repository (NENHUMA mudança no domínio!)
class ProvidersRepositoryImpl implements ProvidersRepository {
  final ProvidersLocalDataSource local;
  final ProvidersRemoteDataSource remote;
  
  @override
  Future<List<Provider>> getAll() async {
    try {
      // Tentar remota primeiro
      return ProviderMapper.fromDtoList(await remote.getAll());
    } catch (e) {
      // Fall back para local
      return ProviderMapper.fromDtoList(await local.getAll());
    }
  }
}

// 3. Pronto! Controller + Pages não mudam!
```

---

## Regras Gerais

### ✅ **Permitido**

- Domain layer importar domain layer
- Data layer importar domain + data
- Presentation layer importar domain + presentation
- Qualquer layer importar `package:flutter`

### ❌ **Proibido**

- Domain layer importar data ou presentation
- Data layer importar presentation
- Presentation layer importar infrastructure (diretamente)

---

## Próximos Passos

1. **Implementar outros features** (breathing sessions, reminders) seguindo o mesmo padrão
2. **Adicionar testes unitários** para domain layer (entities, mappers)
3. **Testar repositories** com mock datasources
4. **Testar controllers** com mock repositories
5. **Considerar Service Locator** (get_it) para injeção de dependências

---

## Referências

- [Clean Architecture by Robert C. Martin](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Flutter Clean Architecture](https://resocoder.com/flutter-clean-architecture-tdd)

