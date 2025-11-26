# 🏗️ Arquitetura Supabase Integration

## Sistema de Camadas

```
┌─────────────────────────────────────────────────────────────┐
│                    🎨 PRESENTATION                         │
│              (flutter/widgets + controllers)                │
│                                                             │
│  RemindersController                                       │
│  ├─ loadReminders() ────────────► Sincroniza automático   │
│  ├─ createReminder()                                       │
│  ├─ updateReminder()                                       │
│  ├─ deleteReminder()                                       │
│  └─ _syncRemindersInBackground()                           │
└─────────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│                    📦 DATA (Repository)                    │
│              (Coordena datasources)                         │
│                                                             │
│  RemindersRepositoryImpl                                    │
│  ├─ Tenta REMOTO primeiro                                 │
│  ├─ Fallback para LOCAL se falhar                         │
│  ├─ Sincronização não-bloqueante                          │
│  └─ Conflict resolution (timestamp)                        │
└─────────────────────────────────────────────────────────────┘
         │                           │
         │                           │
      ┌──▼──┐                   ┌────▼───┐
      │LOCAL│                   │ REMOTO │
      └──┬──┘                   └────┬───┘
         │                           │
         ▼                           ▼
┌──────────────┐          ┌──────────────────┐
│SharedPrefs   │          │Supabase Client   │
│              │          │                  │
│Offline Store │          │PostgreSQL DB     │
│ - Fast read  │          │ - Cloud sync     │
│ - Always ok  │          │ - Authoritative  │
│ - Local only │          │ - RLS security   │
└──────────────┘          └──────────────────┘
```

## Fluxo de Dados

### 🔵 Leitura (GET)

```
User clicks "Load Reminders"
        │
        ▼
RemindersController.loadReminders()
        │
        ├─► Repository.getAll()
        │       │
        │       ├─► RemoteDataSource.getAll() [TRY]
        │       │   ├─ Query: SELECT * FROM reminders
        │       │   ├─ Filter: WHERE user_id = current_user
        │       │   ├─ Order: scheduled_at ASC
        │       │   └─ Return: List<ReminderModel>
        │       │
        │       ├─ Success? 
        │       │   └─ Cache em local + Return
        │       │
        │       └─ Error/Offline?
        │           └─ Fallback: LocalDataSource.getAll()
        │               └─ Query: SharedPreferences
        │
        ├─► _syncRemindersInBackground() [FIRE & FORGET]
        │   └─ Repository.syncWithRemote(_reminders)
        │
        └─► UI Updates com dados
            (originários de local ou remoto)

Result: ✅ App funciona offline, sincroniza quando online
```

### 🟢 Criação (CREATE)

```
User creates new reminder
        │
        ▼
RemindersController.createReminder(reminder)
        │
        ├─► Repository.create(reminder)
        │       │
        │       ├─► LocalDataSource.create() [IMMEDIATE]
        │       │   └─ Save to SharedPreferences
        │       │
        │       └─► RemoteDataSource.create() [BACKGROUND]
        │           └─ INSERT INTO reminders
        │               VALUES (title, description, user_id, ...)
        │
        └─► UI Updates imediatamente
            (dados já estão em cache local)

Result: ✅ UI responsiva, sync automático
```

### 🟡 Atualização (UPDATE)

```
User edits reminder
        │
        ▼
RemindersController.updateReminder(reminder)
        │
        ├─► Repository.update(reminder)
        │       │
        │       ├─► LocalDataSource.update() [IMMEDIATE]
        │       │   └─ Update SharedPreferences
        │       │
        │       └─► RemoteDataSource.update() [BACKGROUND]
        │           └─ UPDATE reminders
        │               SET title=?, updated_at=NOW()
        │               WHERE id = ?
        │
        └─► UI Updates imediatamente
            (dados já estão em cache local)

Result: ✅ Mudanças sincronizadas automaticamente
```

### 🔴 Deleção (DELETE)

```
User deletes reminder
        │
        ▼
RemindersController.deleteReminder(id)
        │
        ├─► Repository.delete(id)
        │       │
        │       ├─► LocalDataSource.delete() [IMMEDIATE]
        │       │   └─ Remove de SharedPreferences
        │       │
        │       └─► RemoteDataSource.delete() [BACKGROUND]
        │           └─ UPDATE reminders
        │               SET is_active = false
        │               WHERE id = ?
        │               (Soft delete para auditoria)
        │
        └─► UI Updates imediatamente

Result: ✅ Deleção segura (soft delete com auditoria)
```

## Resolução de Conflitos

```
Cenário: Usuário edita lembretes offline, depois online

Device A (Offline)          Device B (Online)
│                           │
├─ Edit reminder 1          ├─ Edit reminder 1
├─ Timestamp: 14:30         ├─ Timestamp: 14:25
│                           │
└─ Go Online                └─ Already synced to Supabase
    │                           (timestamp: 14:25)
    └─ Sync with Supabase
        │
        ├─ Compare timestamps
        │   Device A: 14:30 ✅ (MAIS RECENTE)
        │   Supabase: 14:25
        │
        └─ Winner: Device A
            └─ UPDATE remoto com dados de Device A
```

**Estratégia**: Last-write-wins com timestamp

## Tabelas do Schema

```sql
┌─────────────────────────────────────────────────┐
│ reminders                                       │
├─────────────────────────────────────────────────┤
│ id (PK)                                         │
│ title (NOT NULL)                                │
│ description                                     │
│ scheduled_at (NOT NULL)                         │
│ type (CHECK: breathing|meditation|...)         │
│ priority (CHECK: low|medium|high)               │
│ is_active (DEFAULT: true)                       │
│ metadata (JSONB)                                │
│ user_id (FK, RLS)                               │
│ created_at, updated_at, deleted_at              │
│ INDEX: (user_id, scheduled_at)                  │
└─────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────┐
│ breathing_sessions                              │
│ meditation_sessions                             │
│ wellness_goals                                  │
│ providers                                       │
│ user_preferences                                │
│ wellness_tips                                   │
└─────────────────────────────────────────────────┘
```

## Security - Row Level Security (RLS)

```sql
-- Exemplo: Reminders

-- 1. SELECT: Usuário vê apenas seus lembretes
CREATE POLICY "Users can see own reminders"
  ON reminders
  FOR SELECT
  USING (auth.uid() = user_id);

-- 2. INSERT: Usuário cria lembretes para si
CREATE POLICY "Users can create own reminders"
  ON reminders
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- 3. UPDATE: Usuário atualiza seus lembretes
CREATE POLICY "Users can update own reminders"
  ON reminders
  FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- 4. DELETE: Usuário deleta seus lembretes
CREATE POLICY "Users can delete own reminders"
  ON reminders
  FOR DELETE
  USING (auth.uid() = user_id);

-- Providers: Públicos para leitura
CREATE POLICY "Providers are public"
  ON providers
  FOR SELECT
  USING (true);
```

**Resultado**: Segurança no nível do banco de dados

## Componentes Criados

### 1. Interfaces (Contracts)

```dart
// Domain
RemindersRepository (interface)
├─ getAll()
├─ create()
├─ update()
├─ delete()
└─ syncWithRemote() ✨ NOVO

// Data
RemindersLocalDataSource (interface)
RemindersRemoteDataSource (interface) ✨ NOVO
```

### 2. Implementações

```dart
// Data
RemindersLocalDataSourceImpl
└─ Usa: SharedPreferences

RemindersRemoteDataSourceImpl ✨ NOVO
└─ Usa: Supabase Client

RemindersRepositoryImpl
├─ Coordena: Local + Remote
└─ Estratégia: Offline-first com fallback
```

### 3. Apresentação

```dart
// Presentation
RemindersController
├─ loadReminders() - com sync automático
├─ _syncRemindersInBackground() ✨ NOVO
└─ Fire-and-forget sync (não bloqueia UI)
```

## Performance

### Indexes em Supabase

```sql
-- Busca rápida por usuário
CREATE INDEX idx_reminders_user_id 
ON reminders(user_id);

-- Busca rápida por data
CREATE INDEX idx_reminders_scheduled_at 
ON reminders(scheduled_at);

-- Busca rápida por tipo
CREATE INDEX idx_reminders_type 
ON reminders(type);

-- Busca otimizada (usuário + data)
CREATE INDEX idx_reminders_user_scheduled 
ON reminders(user_id, scheduled_at);
```

### Cache Local

```dart
// Offline-first strategy
class RemindersController {
  List<Reminder> _reminders = [];
  
  // 1. Carrega local (instant)
  // 2. Sincroniza remoto (background)
  // 3. Sem esperar rede
}
```

## Tratamento de Erros

```dart
// Offline
try {
  return await remoteDataSource.getAll(); ❌ Fail
} catch (e) {
  print('⚠️ Remoto falhou: $e');
  return await localDataSource.getAll(); ✅ Fallback
}

// Online (sync)
try {
  await remoteDataSource.create(reminder); ✅ Success
} catch (e) {
  print('⚠️ Sync falhou: $e'); // Continua offline
  // Será sincronizado depois
}
```

## Logs de Debug

```
🔄 Iniciando sincronização com Supabase...
📱 Lembretes locais: 5
☁️ Lembretes remotos: 3
✅ Sincronização concluída!

⚠️ Erro ao buscar remoto: SocketException
   └─ usando cache local

✅ Criação sincronizada com sucesso
```

---

## Resumo: Por Que Funciona?

1. **Offline-First** ✅
   - Sempre salva local primeiro
   - App sempre funciona
   - Remoto é "melhoramento"

2. **Sync Automático** ✅
   - Background tasks
   - Não bloqueia UI
   - Falhas não críticas

3. **Fallback Inteligente** ✅
   - Remoto indisponível? Usa local
   - Network lento? Não espera
   - App continua funcionando

4. **RLS Security** ✅
   - Banco garante isolamento
   - Usuários só veem seus dados
   - Sem lógica no app

5. **Clean Architecture** ✅
   - Separação de responsabilidades
   - Fácil testar (mock datasources)
   - Fácil adicionar novas entidades

---

**Pronto para produção!** 🚀
