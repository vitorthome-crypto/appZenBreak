# 🔌 Exemplo de Integração em main.dart

Este arquivo mostra como injetar os datasources remotos em `main.dart`.

## Código Completo (Exemplo)

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zenbreak/config/supabase_config.dart';
import 'package:zenbreak/services/supabase_service.dart';
import 'package:zenbreak/features/reminders/data/datasources/reminders_local_data_source_impl.dart';
import 'package:zenbreak/features/reminders/data/datasources/reminders_remote_data_source_impl.dart';
import 'package:zenbreak/features/reminders/data/repositories/reminders_repository_impl.dart';
import 'package:zenbreak/features/reminders/presentation/controllers/reminders_controller.dart';
import 'package:zenbreak/pages/home_page.dart';
import 'package:zenbreak/pages/splash_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1️⃣ Inicializar Supabase
  await SupabaseService.initialize();

  // 2️⃣ Criar datasources
  final localDataSource = RemindersLocalDataSourceImpl();
  
  // 3️⃣ Criar remote datasource com cliente Supabase
  final supabaseClient = SupabaseService.client;
  final remoteDataSource = RemindersRemoteDataSourceImpl(
    supabaseClient: supabaseClient,
  );

  // 4️⃣ Criar repositório com ambos datasources
  final remindersRepository = RemindersRepositoryImpl(
    localDataSource: localDataSource,
    remoteDataSource: remoteDataSource, // ✨ Novo!
  );

  // 5️⃣ Criar controller
  final remindersController = RemindersController(
    repository: remindersRepository,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => remindersController,
        ),
        // Adicione outros providers conforme necessário
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZenBreak - Meditação & Respiração',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6B4FBB),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const SplashPage(),
      routes: {
        '/home': (context) => const HomePage(),
      },
    );
  }
}
```

## Passo a Passo

### 1. Imports Necessários
```dart
// Supabase
import 'package:zenbreak/services/supabase_service.dart';

// Reminders - Datasources
import 'package:zenbreak/features/reminders/data/datasources/reminders_local_data_source_impl.dart';
import 'package:zenbreak/features/reminders/data/datasources/reminders_remote_data_source_impl.dart';

// Reminders - Repository
import 'package:zenbreak/features/reminders/data/repositories/reminders_repository_impl.dart';

// Reminders - Controller
import 'package:zenbreak/features/reminders/presentation/controllers/reminders_controller.dart';
```

### 2. Inicializar Supabase
```dart
await SupabaseService.initialize();
```

### 3. Criar Datasources
```dart
// Local (SharedPreferences)
final localDataSource = RemindersLocalDataSourceImpl();

// Remoto (Supabase)
final supabaseClient = SupabaseService.client;
final remoteDataSource = RemindersRemoteDataSourceImpl(
  supabaseClient: supabaseClient,
);
```

### 4. Injetar no Repositório
```dart
final remindersRepository = RemindersRepositoryImpl(
  localDataSource: localDataSource,
  remoteDataSource: remoteDataSource, // ✨ Novo!
);
```

### 5. Criar Controller e Providers
```dart
final remindersController = RemindersController(
  repository: remindersRepository,
);

MultiProvider(
  providers: [
    ChangeNotifierProvider(
      create: (_) => remindersController,
    ),
  ],
  child: const MyApp(),
)
```

## Variante com Autenticação

Se o seu app requer autenticação, você pode fazer verificação antes de injetar:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await SupabaseService.initialize();
  
  // Verifica se usuário está autenticado
  final session = SupabaseService.client.auth.currentSession;
  final isAuthenticated = session != null;
  
  final localDataSource = RemindersLocalDataSourceImpl();
  
  // Só cria remote datasource se autenticado
  RemindersRemoteDataSourceImpl? remoteDataSource;
  if (isAuthenticated) {
    remoteDataSource = RemindersRemoteDataSourceImpl(
      supabaseClient: SupabaseService.client,
    );
  }
  
  final remindersRepository = RemindersRepositoryImpl(
    localDataSource: localDataSource,
    remoteDataSource: remoteDataSource, // null se não autenticado
  );
  
  // ... resto do código
}
```

## Testando a Sincronização

Adicione este debug no controller:

```dart
class RemindersController extends ChangeNotifier {
  // ... código existente ...

  Future<void> debugSync() async {
    print('🔄 Iniciando sincronização de debug...');
    try {
      await repository.syncWithRemote(_reminders);
      print('✅ Sincronização de debug concluída');
    } catch (e) {
      print('❌ Erro na sincronização: $e');
    }
  }
}
```

Depois na tela:
```dart
ElevatedButton(
  onPressed: () => context.read<RemindersController>().debugSync(),
  child: const Text('Debug Sync'),
)
```

## Variante com Factory Pattern

Se preferir usar factory pattern (mais limpo):

```dart
class RemindersControllerFactory {
  static RemindersController create() {
    // Datasources
    final localDataSource = RemindersLocalDataSourceImpl();
    final remoteDataSource = RemindersRemoteDataSourceImpl(
      supabaseClient: SupabaseService.client,
    );
    
    // Repository
    final repository = RemindersRepositoryImpl(
      localDataSource: localDataSource,
      remoteDataSource: remoteDataSource,
    );
    
    // Controller
    return RemindersController(repository: repository);
  }
}

// No main:
runApp(
  MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (_) => RemindersControllerFactory.create(),
      ),
    ],
    child: const MyApp(),
  ),
);
```

## Variante com Service Locator (GetIt)

Se usar get_it para injeção de dependência:

```dart
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void setupServiceLocator() {
  // Datasources
  getIt.registerSingleton<RemindersLocalDataSource>(
    RemindersLocalDataSourceImpl(),
  );
  
  getIt.registerSingleton<RemindersRemoteDataSource>(
    RemindersRemoteDataSourceImpl(
      supabaseClient: SupabaseService.client,
    ),
  );
  
  // Repository
  getIt.registerSingleton<RemindersRepository>(
    RemindersRepositoryImpl(
      localDataSource: getIt<RemindersLocalDataSource>(),
      remoteDataSource: getIt<RemindersRemoteDataSource>(),
    ),
  );
  
  // Controller
  getIt.registerSingleton<RemindersController>(
    RemindersController(repository: getIt<RemindersRepository>()),
  );
}

// No main:
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.initialize();
  setupServiceLocator();
  
  runApp(const MyApp());
}
```

## Checklist de Integração

- [ ] Importar todos os arquivos necessários
- [ ] Chamar `SupabaseService.initialize()` antes de rodar app
- [ ] Criar instâncias de datasources
- [ ] Injetar no repositório
- [ ] Passar para controller
- [ ] Testar criar/ler/atualizar/deletar lembretes
- [ ] Testar sincronização (com e sem internet)
- [ ] Verificar logs (print statements)
- [ ] Monitorar no Supabase Dashboard

---

**Próximo**: Escolha sua abordagem favorita e aplique em `main.dart`!
