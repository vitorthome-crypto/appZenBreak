# Clean Architecture - ZenBreak Implementation

ZenBreak segue os princípios de **Clean Architecture** com uma abordagem **feature-first**, organizando o código em camadas bem definidas (Domain, Data, Presentation) para máxima manutenibilidade, testabilidade e escalabilidade.

---

## 📐 Estrutura de Pastas

```
lib/
├── core/                          # Camada compartilhada (serviços, constantes, utilities)
│   ├── data/                      # Dados compartilhados (DTOs, local persistence)
│   └── domain/                    # Lógica compartilhada (entities base, use cases)
│
├── features/                      # Organização feature-first
│   ├── historico/                 # Feature: Histórico de Meditação
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   ├── repositories/      # Contratos (interfaces)
│   │   │   └── use_cases/
│   │   ├── data/
│   │   │   ├── datasources/       # Local & Remote data sources
│   │   │   ├── models/            # DTOs (Supabase, Cache)
│   │   │   └── repositories/      # Implementação dos contratos
│   │   └── presentation/
│   │       ├── pages/             # Telas (StatefulWidget)
│   │       ├── controllers/       # State management (Provider)
│   │       ├── widgets/           # Componentes UI reutilizáveis
│   │       └── utils/             # Helpers (formatação, etc.)
│   │
│   └── reminders/                 # Feature: Reminders (não utilizado atualmente)
│       ├── domain/
│       ├── data/
│       └── presentation/
│
├── pages/                         # Páginas globais (Splash, Home, etc.)
│   ├── splash_page.dart
│   ├── home_page.dart
│   ├── historico_page.dart
│   ├── demo_page.dart
│   ├── policy_viewer_page.dart
│   └── meditation_history_demo_page.dart
│
├── services/                      # Serviços globais (não dependem de features)
│   ├── prefs_service.dart         # SharedPreferences singleton
│   └── supabase_service.dart      # (Documentação/config Supabase)
│
├── widgets/                       # Widgets reutilizáveis globais
│   ├── breathing_session.dart
│   ├── breathing_session_with_history.dart
│   └── estatisticas_meditacao_widget.dart
│
└── main.dart                      # Entry point com Provider setup
```

---

## 🏗️ As 3 Camadas Principais

### 1️⃣ **Domain Layer** (Lógica de Negócio Pura)

**Responsabilidade:** Contém o core business logic, totalmente independente de Flutter, banco de dados ou UI.

**Arquivos:**
- `entities/` — Modelos de domínio (ex: `EstatisticasMeditacao`)
- `repositories/` — **Contratos/Interfaces** (ex: `HistoricoRepository`)
- `use_cases/` — Casos de uso específicos (se necessário)

**Exemplo - Interface do Repositório:**
```dart
// lib/features/historico/domain/repositories/historico_repository.dart
abstract class HistoricoRepository {
  /// Salva uma sessão de meditação.
  Future<void> salvarSessao({
    String? userId,
    required int duracao_segundos,
    int? meditacao_id,
    bool parcial = false,
  });

  /// Busca estatísticas de meditação.
  Future<Map<String, int>> buscarEstatisticas({String? userId});

  /// Obtém todas as sessões.
  Future<List<Map<String, dynamic>>> obterTodas({String? userId});
}
```

**Vantagens:**
- ✅ Pura Dart (sem imports de `flutter`, `supabase_flutter`, etc.)
- ✅ Fácil de testar (mockable)
- ✅ Independente de implementação (banco, API, cache)

---

### 2️⃣ **Data Layer** (Persistência & Acesso a Dados)

**Responsabilidade:** Gerencia dados de múltiplas fontes (local, remoto), mapeia entre DTOs e entities, implementa os contratos do Domain.

**Estrutura:**
- `datasources/` — Interfaces e implementações de acesso a dados
  - `historico_remote_data_source.dart` — Interface para dados remotos (Supabase)
  - `historico_remote_data_source_impl.dart` — Implementação Supabase
  - (Opcionalmente: `historico_local_data_source.dart` para cache local)
- `repositories/` — Implementação dos contratos Domain
  - `historico_repository_impl.dart` — Orquestra Local + Remote datasources
- `models/` — DTOs e mapeadores (fromJson, toJson, toEntity)

**Exemplo - DataSource Interface:**
```dart
// lib/features/historico/data/datasources/historico_remote_data_source.dart
abstract class HistoricoRemoteDataSource {
  /// Salva uma sessão no Supabase.
  Future<void> salvarSessao({
    String? userId,
    required int duracao_segundos,
    int? meditacao_id,
    bool parcial = false,
  });

  Future<Map<String, int>> buscarEstatisticas({String? userId});
  Future<List<Map<String, dynamic>>> obterTodas({String? userId});
}
```

**Exemplo - DataSource Implementation:**
```dart
// lib/features/historico/data/datasources/historico_remote_data_source_impl.dart
class HistoricoRemoteDataSourceImpl implements HistoricoRemoteDataSource {
  final SupabaseClient client;

  HistoricoRemoteDataSourceImpl({required this.client});

  @override
  Future<void> salvarSessao({
    String? userId,
    required int duracao_segundos,
    int? meditacao_id,
    bool parcial = false,
  }) async {
    try {
      final data = {
        if (userId != null) 'user_id': userId,
        'duracao_segundos': duracao_segundos,
        'parcial': parcial,
        if (meditacao_id != null) 'meditacao_id': meditacao_id,
      };

      await client.from('historico_usuario').insert(data);
      debugPrint('[HistoricoRemoteDataSource] Sessão salva com sucesso!');
    } catch (e) {
      debugPrint('[HistoricoRemoteDataSource] Erro ao salvar: $e');
      rethrow;
    }
  }

  // ... outros métodos
}
```

**Exemplo - Repository Implementation:**
```dart
// lib/features/historico/data/repositories/historico_repository_impl.dart
class HistoricoRepositoryImpl implements HistoricoRepository {
  final HistoricoRemoteDataSource remoteDataSource;
  // (Opcionalmente) final HistoricoLocalDataSource localDataSource;

  HistoricoRepositoryImpl({required this.remoteDataSource});

  @override
  Future<void> salvarSessao({
    String? userId,
    required int duracao_segundos,
    int? meditacao_id,
    bool parcial = false,
  }) async {
    try {
      // 1. Salvar localmente (opcional)
      // await localDataSource.salvarSessao(...);

      // 2. Salvar remotamente
      await remoteDataSource.salvarSessao(
        userId: userId,
        duracao_segundos: duracao_segundos,
        meditacao_id: meditacao_id,
        parcial: parcial,
      );
    } catch (e) {
      rethrow;
    }
  }

  // ... outros métodos
}
```

**Vantagens:**
- ✅ Múltiplas datasources orquestradas (cache + API)
- ✅ Responsável por sincronização offline-first
- ✅ Mapeia DTOs ↔ Domain entities

---

### 3️⃣ **Presentation Layer** (UI & State Management)

**Responsabilidade:** Widgets, páginas, state management (Provider), e interação com o usuário. Depende apenas das interfaces do Domain, não das implementações.

**Estrutura:**
- `pages/` — Telas (StatefulWidget ou Consumer)
- `controllers/` — State management com `ChangeNotifier` (Provider)
- `widgets/` — Componentes UI reutilizáveis
- `utils/` — Helpers (formatação de datas, etc.)

**Exemplo - Controller (State Management):**
```dart
// lib/features/historico/presentation/controllers/historico_controller.dart
class HistoricoController extends ChangeNotifier {
  final HistoricoRepository repository; // Depende da interface Domain

  EstatisticasMeditacao _estatisticas = EstatisticasMeditacao.empty();
  List<Map<String, dynamic>> _sessoes = [];
  bool _carregando = false;
  String? _erro;

  // Getters
  EstatisticasMeditacao get estatisticas => _estatisticas;
  List<Map<String, dynamic>> get sessoes => _sessoes;
  bool get carregando => _carregando;
  String? get erro => _erro;

  HistoricoController({required this.repository});

  /// Salva uma sessão (chamado automaticamente ao terminar ou cancelar)
  Future<void> salvarSessao({
    required int duracao_segundos,
    int? meditacao_id,
    bool parcial = false,
  }) async {
    try {
      _erro = null;
      await repository.salvarSessao(
        userId: null, // Público: sem autenticação
        duracao_segundos: duracao_segundos,
        meditacao_id: meditacao_id,
        parcial: parcial,
      );

      // Recarrega lista e estatísticas
      await carregarEstatisticas();
      await carregarSessoes();
      notifyListeners();
      debugPrint('[HistoricoController] Sessão salva!');
    } catch (e) {
      _erro = 'Erro ao salvar: $e';
      notifyListeners();
    }
  }

  Future<void> carregarEstatisticas() async { /* ... */ }
  Future<void> carregarSessoes() async { /* ... */ }
}
```

**Exemplo - Page (Consumer + Controller):**
```dart
// lib/pages/historico_page.dart
class HistoricoPage extends StatefulWidget {
  const HistoricoPage({super.key});

  @override
  State<HistoricoPage> createState() => _HistoricoPageState();
}

class _HistoricoPageState extends State<HistoricoPage> {
  @override
  void initState() {
    super.initState();
    // Carregar dados ao abrir página
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HistoricoController>(context, listen: false)
          .carregarSessoes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Histórico')),
      body: Consumer<HistoricoController>(
        builder: (context, historicoController, child) {
          if (historicoController.carregando) {
            return const Center(child: CircularProgressIndicator());
          }

          if (historicoController.erro != null) {
            return Center(child: Text('Erro: ${historicoController.erro}'));
          }

          final sessoes = historicoController.sessoes;
          if (sessoes.isEmpty) {
            return const Center(child: Text('Nenhuma sessão'));
          }

          return ListView.builder(
            itemCount: sessoes.length,
            itemBuilder: (context, index) {
              final sessao = sessoes[index];
              final duracao = sessao['duracao_segundos'] as int? ?? 0;
              final parcial = sessao['parcial'] as bool? ?? false;

              return ListTile(
                title: Text(
                  '${duracao ~/ 60} min${parcial ? ' (parcial)' : ''}',
                ),
                subtitle: Text(sessao['data_sessao'] ?? ''),
              );
            },
          );
        },
      ),
    );
  }
}
```

**Vantagens:**
- ✅ UI separada da lógica de negócio
- ✅ Fácil testar lógica do controller (sem widgets)
- ✅ Reutilização de controllers entre páginas
- ✅ Estado gerenciado centralmente com Provider

---

## 🔄 Fluxo de Dados

```
┌─────────────────────────────────────────────────────────────────┐
│ 1. USER INTERACTION                                             │
│    HomePage: clica "Cancelar" durante sessão                    │
└──────────────────────────┬──────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│ 2. PRESENTATION (HomePage)                                      │
│    - Calcula tempo decorrido                                    │
│    - Chama HistoricoController.salvarSessao(parcial: true)      │
└──────────────────────────┬──────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│ 3. DOMAIN (Interface HistoricoRepository)                       │
│    - Repository.salvarSessao(userId, duracao, parcial)          │
│    - (Pure business logic, independente de implementação)       │
└──────────────────────────┬──────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│ 4. DATA (HistoricoRepositoryImpl)                               │
│    - Orquestra datasources (local + remote)                     │
│    - RemoteDataSource.salvarSessao(...)                         │
└──────────────────────────┬──────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│ 5. DATA (HistoricoRemoteDataSourceImpl)                         │
│    - Cria mapa de dados com campo 'parcial'                     │
│    - client.from('historico_usuario').insert(data)              │
└──────────────────────────┬──────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│ 6. EXTERNAL (Supabase Postgres)                                 │
│    - Insere nova linha em historico_usuario                     │
│    - RLS policies verificadas (públicas ou por auth.uid)        │
└──────────────────────────┬──────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│ 7. RESPONSE FLOW (Volta)                                        │
│    - Data Layer: success → chama carregarSessoes()              │
│    - Presentation: UI atualizada (Consumer rebuilds)            │
│    - HistoricoPage: mostra nova sessão com "(parcial)"          │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🧪 Testabilidade

Com Clean Architecture, cada camada é facilmente testável:

### Domain Tests (Unit)
```dart
test('HistoricoRepository.salvarSessao with parcial=true', () async {
  final mockDataSource = MockHistoricoRemoteDataSource();
  final repository = HistoricoRepositoryImpl(remoteDataSource: mockDataSource);

  await repository.salvarSessao(
    userId: null,
    duracao_segundos: 60,
    parcial: true,
  );

  verify(mockDataSource.salvarSessao(
    userId: null,
    duracao_segundos: 60,
    parcial: true,
  )).called(1);
});
```

### Presentation Tests (Widget/Controller)
```dart
test('HistoricoController.salvarSessao updates state', () async {
  final mockRepository = MockHistoricoRepository();
  final controller = HistoricoController(repository: mockRepository);

  await controller.salvarSessao(duracao_segundos: 120, parcial: false);

  expect(controller.erro, null);
  expect(controller.sessoes, isNotEmpty);
});
```

---

## 📊 Injeção de Dependência (main.dart)

```dart
// lib/main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(url: supabaseUrl, anonKey: anonKey);

  runApp(MyApp(prefs: prefs));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<PrefsService>.value(value: prefs!),
        ChangeNotifierProvider<HistoricoController>(
          create: (_) {
            final client = Supabase.instance.client;
            final remoteDataSource = HistoricoRemoteDataSourceImpl(client: client);
            final repository = HistoricoRepositoryImpl(remoteDataSource: remoteDataSource);
            return HistoricoController(repository: repository);
          },
        ),
      ],
      child: MaterialApp(
        // ... rotas, tema, etc.
      ),
    );
  }
}
```

**Benefícios:**
- ✅ Fácil trocar implementações (ex: local datasource)
- ✅ Controllers podem ser criados com diferentes repositories
- ✅ Testable: inject mocks facilmente

---

## 🎯 Vantagens Implementadas no ZenBreak

| Aspecto | Benefício | Exemplo |
|---------|-----------|---------|
| **Manutenibilidade** | Mudança em Supabase não afeta UI | Trocar RemoteDataSource sem alterar HomePage |
| **Testabilidade** | Logic isolada de UI e externos | Mock de repository para testar controller |
| **Escalabilidade** | Adicionar features sem afetar código existente | Nova feature em `features/reminders` independente |
| **Desacoplamento** | Camadas comunicam por interfaces | HomePage só conhece HistoricoRepository (interface) |
| **Reutilização** | Componentes compartilhados | `BreathingSession` + `EstatisticasMeditacaoWidget` |

---

## 🔧 Próximas Melhorias (Optional)

Se o projeto crescer, considere:

1. **Use Cases** — Encapsular lógica complexa do repositório em use cases
   ```dart
   // lib/features/historico/domain/usecases/salvar_sessao_usecase.dart
   class SalvarSessaoUseCase {
     final HistoricoRepository repository;
     Future<void> call({...}) => repository.salvarSessao(...);
   }
   ```

2. **Local Caching** — Adicionar datasource local (SQLite/Hive)
   ```dart
   // lib/features/historico/data/datasources/historico_local_data_source_impl.dart
   ```

3. **Service Locator (get_it)** — Gerenciar injeção de dependências globalmente
   ```dart
   GetIt getIt = GetIt.instance;
   getIt.registerSingleton<HistoricoRepository>(impl);
   ```

4. **BLoC Pattern** — Substituir Provider por BLoC para estado mais complexo

---

## 📚 Referências

- **Flutter Clean Architecture**: https://resocoder.com/flutter-clean-architecture
- **Provider Pattern**: https://pub.dev/packages/provider
- **Clean Code (Robert Martin)**: The Art of Clean Code
- **ZenBreak Docs**: Veja `docs/` para SQL schema, RLS policies, e guias

---

**Status:** ✅ Clean Architecture totalmente implementada no ZenBreak
**Padrão:** Feature-first com 3 camadas (Domain, Data, Presentation)
**State Management:** Provider (ChangeNotifier)
**Data Persistence:** Supabase (remoto) + SharedPreferences (local prefs)
