# 🔄 Guia de Implementação - Sincronização Supabase

## 📌 Resumo do Processo

Este guia detalha como conectar os datasources remotos criados aos repositórios existentes.

## 🎯 Passos de Implementação

### Passo 1: Atualizar RemindersRepositoryImpl

O repositório atual usa apenas datasource local. Vamos adicionar suporte ao remoto com fallback.

**Arquivo**: `lib/features/reminders/data/repositories/reminders_repository_impl.dart`

#### Mudanças necessárias:

```dart
import 'package:zenbreak/features/reminders/data/datasources/reminders_remote_data_source.dart';

class RemindersRepositoryImpl implements RemindersRepository {
  final RemindersLocalDataSource localDataSource;
  final RemindersRemoteDataSource? remoteDataSource; // NOVO

  RemindersRepositoryImpl({
    required this.localDataSource,
    this.remoteDataSource, // NOVO - opcional
  });

  // Métodos existentes mantêm fallback automático
  @override
  Future<List<Reminder>> getAll() async {
    try {
      if (remoteDataSource != null) {
        // Tenta remoto primeiro
        final remoteReminders = await remoteDataSource!.getAll();
        // Salva localmente para offline
        for (var reminder in remoteReminders) {
          await localDataSource.create(reminder);
        }
        return remoteReminders;
      }
    } catch (e) {
      // Fallback para local se remoto falhar
      print('Remote fetch failed: $e, using local cache');
    }
    
    // Sempre usa local como fallback
    return await localDataSource.getAll();
  }

  // Similar para outros métodos...
}
```

### Passo 2: Inicializar Datasources em Main.dart

**Arquivo**: `lib/main.dart`

Adicione após `SupabaseService.initialize()`:

```dart
import 'package:zenbreak/features/reminders/data/datasources/reminders_remote_data_source_impl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await SupabaseService.initialize(); // Já existe
  
  // NOVO: Criar datasources remotos
  final supabaseClient = SupabaseService.client;
  final remindersRemoteDataSource = RemindersRemoteDataSourceImpl(
    supabaseClient: supabaseClient,
  );
  
  // Injetar no repositório
  final remindersRepository = RemindersRepositoryImpl(
    localDataSource: RemindersLocalDataSourceImpl(),
    remoteDataSource: remindersRemoteDataSource,
  );
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => RemindersController(repository: remindersRepository),
        ),
      ],
      child: const MyApp(),
    ),
  );
}
```

### Passo 3: Adicionar Sincronização no Controller

**Arquivo**: `lib/features/reminders/presentation/controllers/reminders_controller.dart`

Adicione sincronização ao carregar:

```dart
class RemindersController extends ChangeNotifier {
  // ... código existente ...

  Future<void> loadReminders() async {
    _setLoading(true);
    try {
      _reminders = await _repository.getAll();
      
      // NOVO: Sincronizar após carregar
      await _syncReminders();
      
      notifyListeners();
    } catch (e) {
      _setError('Erro ao carregar lembretes: $e');
    } finally {
      _setLoading(false);
    }
  }

  // NOVO: Método de sincronização
  Future<void> _syncReminders() async {
    try {
      // Sincroniza dados locais com servidor
      await _repository.sync(_reminders);
    } catch (e) {
      print('Sync failed (não-crítico): $e');
      // Não falha - app continua funcionando offline
    }
  }
}
```

### Passo 4: Criar Providers Remote Datasource (Opcional)

Se quiser sincronizar também Providers:

```dart
// lib/features/providers/data/datasources/providers_remote_data_source.dart

abstract class ProvidersRemoteDataSource {
  Future<List<ProviderModel>> getAll();
  Future<List<ProviderModel>> search(String query);
  Future<ProviderModel> getById(String id);
  Future<ProviderModel> create(ProviderModel provider);
  Future<void> update(ProviderModel provider);
  Future<void> delete(String id);
  Future<void> sync(List<ProviderModel> local);
}
```

## 🧪 Testando a Sincronização

### 1. Teste Offline-First

```dart
// Teste 1: App funcionando sem internet
void testOfflineMode() {
  // Desabilite internet no emulador/dispositivo
  // Create um novo reminder
  await controller.createReminder('Respirar', 'Sessão de 5 min');
  
  // Verify que foi salvo localmente
  expect(controller.reminders.length, 1);
  
  // Enable internet novamente
  // Aguarde sincronização automática
  await Future.delayed(Duration(seconds: 5));
  
  // Verify sincronização com Supabase
}
```

### 2. Teste de Sincronização

```dart
// Teste 2: Criar no app e verificar no Supabase
void testSync() async {
  final reminder = ReminderModel(
    title: 'Meditação',
    description: 'Sessão de 10 minutos',
    scheduledAt: DateTime.now().add(Duration(hours: 1)),
    type: 'meditation',
    priority: 'high',
  );
  
  await controller.createReminder(reminder);
  
  // Verificar no Supabase Dashboard > reminders table
}
```

## 📊 Monitorar Sincronização

Adicione logs para debug:

```dart
// Em reminders_remote_data_source_impl.dart
@override
Future<void> sync(List<ReminderModel> localReminders) async {
  print('🔄 Iniciando sincronização...');
  print('📱 Lembretes locais: ${localReminders.length}');
  
  try {
    final remoteReminders = await supabaseClient
        .from('reminders')
        .select()
        .eq('user_id', supabaseClient.auth.currentUser!.id);
    
    print('☁️ Lembretes remotos: ${remoteReminders.length}');
    
    // Lógica de sincronização...
    
    print('✅ Sincronização concluída!');
  } catch (e) {
    print('❌ Erro na sincronização: $e');
  }
}
```

## 🔍 Verificar Implementação

### Checklist de Testes

- [ ] App carrega lembretes do Supabase
- [ ] Criar novo reminder salva no Supabase
- [ ] Editar reminder atualiza no Supabase
- [ ] Deletar reminder remove do Supabase
- [ ] App funciona offline (sem internet)
- [ ] Sincronização automática quando online
- [ ] Não há duplicatas após sincronização
- [ ] Conflitos resolvem corretamente (timestamp)

## 🚨 Troubleshooting

### Problema: "Auth session missing"
**Solução**: Implemente login no app antes de usar Supabase
```dart
// Em main.dart ou na primeira página
if (supabaseClient.auth.currentSession == null) {
  // Mostrar tela de login
}
```

### Problema: RLS policy violation
**Solução**: Verifique se o `user_id` está correto
```dart
// Adicione prints para debug
final userId = supabaseClient.auth.currentUser?.id;
print('User ID: $userId');
```

### Problema: Dados não sincronizam
**Solução**: Verifique conectividade e logs
```dart
// Teste conectividade
final response = await supabaseClient.from('reminders').select().limit(1);
print('Conexão ok: ${response.isNotEmpty}');
```

## 📈 Próximas Fases

### Fase 2: Autenticação Completa
- Implementar tela de login/signup
- Adicionar logout
- Persister sessão

### Fase 3: Sincronização em Background
- Setup de background tasks
- Sincronização periódica
- Notificações de sync

### Fase 4: Outras Entidades
- Breathing Sessions sync
- Meditation Sessions sync
- Wellness Goals sync
- User Preferences sync

### Fase 5: Features Avançadas
- Real-time updates com Supabase subscriptions
- Offline queue com retry automático
- Compressão de dados
- Cache inteligente

## 📚 Referências

- [Provider Package](https://pub.dev/packages/provider)
- [Supabase Flutter](https://supabase.com/docs/reference/dart)
- [Clean Architecture em Flutter](https://resocoder.com/flutter-clean-architecture)

---

**Status**: Pronto para implementação em `RemindersRepositoryImpl` e `main.dart`
