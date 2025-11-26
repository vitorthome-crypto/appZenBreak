# 🧪 Guia de Testes - Supabase Integration

## 📋 Índice

1. [Testes Offline](#testes-offline)
2. [Testes Online](#testes-online)
3. [Testes de Sincronização](#testes-de-sincronização)
4. [Testes de Segurança](#testes-de-segurança)
5. [Testes de Performance](#testes-de-performance)

---

## 🔴 Testes Offline

### Teste 1: Criar Reminder Offline

**Objetivo**: Verificar se app cria reminders sem internet

**Passos**:
1. Desabilitar internet (airplane mode ou desabilitar wifi)
2. Abrir app
3. Criar novo reminder
4. Verificar que reminder aparece na lista

**Resultado Esperado**:
- ✅ Reminder criado com sucesso
- ✅ Aparece na lista imediatamente
- ✅ Sem erro de conexão

**Verificação**:
```dart
// No controller
print('Reminders offline: ${controller.reminders.length}');
// Esperado: 1 (ou mais se houver prévios)
```

### Teste 2: Editar Reminder Offline

**Objetivo**: Verificar se app edita reminders sem internet

**Passos**:
1. (Offline) Criar um reminder
2. Editar o título
3. Verificar que título foi atualizado

**Resultado Esperado**:
- ✅ Reminder editado com sucesso
- ✅ Título atualizado na lista

### Teste 3: Deletar Reminder Offline

**Objetivo**: Verificar se app deleta reminders sem internet

**Passos**:
1. (Offline) Criar um reminder
2. Deletar o reminder
3. Verificar que foi removido da lista

**Resultado Esperado**:
- ✅ Reminder deletado com sucesso
- ✅ Removido da lista

### Teste 4: Consultar Reminders Offline

**Objetivo**: Verificar se app consulta reminders locais sem internet

**Passos**:
1. Criar alguns reminders (online)
2. Desabilitar internet
3. Reabrir app
4. Verificar que reminders aparecem

**Resultado Esperado**:
- ✅ Reminders carregam do cache local
- ✅ Sem erro de conexão

---

## 🟢 Testes Online

### Teste 1: Carregar Reminders Online

**Objetivo**: Verificar se app carrega reminders do Supabase

**Passos**:
1. Conectar à internet
2. Abrir app
3. Ir para tela de reminders
4. Verificar que reminders aparecem

**Resultado Esperado**:
- ✅ Reminders carregam do Supabase
- ✅ Aparecem na lista

**Verificação no Supabase**:
```
Dashboard > reminders > Table Editor
// Veja os dados aparecerem em tempo real
```

### Teste 2: Criar Reminder Online

**Objetivo**: Verificar se app cria reminder no Supabase

**Passos**:
1. (Online) Criar novo reminder
2. Ir ao Supabase Dashboard > reminders
3. Verificar que reminder aparece na tabela

**Resultado Esperado**:
- ✅ Reminder aparece na tabela Supabase
- ✅ Dados corretos (title, type, priority, etc)

**Verificação**:
```sql
SELECT * FROM reminders WHERE title = 'Novo Reminder';
-- Esperado: 1 linha com os dados corretos
```

### Teste 3: Editar Reminder Online

**Objetivo**: Verificar se app atualiza reminder no Supabase

**Passos**:
1. (Online) Criar reminder
2. Editar título
3. Ir ao Supabase Dashboard > reminders
4. Verificar que título foi atualizado

**Resultado Esperado**:
- ✅ Reminder atualizado na tabela Supabase
- ✅ Timestamp `updated_at` atualizado

### Teste 4: Deletar Reminder Online

**Objetivo**: Verificar se app deleta reminder no Supabase (soft delete)

**Passos**:
1. (Online) Criar reminder
2. Deletar reminder
3. Ir ao Supabase Dashboard > reminders
4. Verificar que `is_active = false`

**Resultado Esperado**:
- ✅ `is_active` muda para false
- ✅ Reminder NÃO desaparece (auditoria)
- ✅ Dados preservados

---

## 🔄 Testes de Sincronização

### Teste 1: Sincronização Offline → Online

**Objetivo**: Verificar se dados offline sincronizam quando conecta

**Passos**:
1. Desabilitar internet
2. Criar 3 reminders offline
3. Abrir Supabase Dashboard (em outro navegador, já conectado)
4. Verificar que tabela está vazia (apenas local)
5. Habilitar internet no app
6. Aguardar ~2 segundos
7. Refresh Supabase Dashboard
8. Verificar que 3 reminders aparecem

**Resultado Esperado**:
- ✅ Reminders criados offline aparecem no Supabase
- ✅ Dados são idênticos (title, type, priority)
- ✅ Timestamps corretos

**Verificação**:
```sql
SELECT COUNT(*) FROM reminders;
-- Esperado: 3
```

### Teste 2: Sincronização Bidirecional

**Objetivo**: Verificar se mudanças remotas aparecem localmente

**Passos**:
1. Abrir app (conectado)
2. Abrir Supabase Dashboard em outro navegador
3. Editar reminder no Supabase (change title)
4. Voltar ao app
5. Puxar para refresh / reabrir app
6. Verificar que título foi atualizado

**Resultado Esperado**:
- ✅ Mudanças remotas aparecem no app
- ✅ Dados sincronizados

**Verificação**:
```dart
// Ao carregar
print('Reminder title (sincronizado): ${reminder.title}');
// Esperado: Novo título
```

### Teste 3: Conflito de Edição

**Objetivo**: Verificar como app resolve conflitos (dois dispositivos editando)

**Passos**:
1. **Device A**: Criar reminder "Meditação"
2. **Device A**: Editar título para "Meditação 10min" (14:30)
3. **Device B**: Editar mesmo reminder para "Meditação 5min" (14:25)
4. Aguardar sincronização
5. Verificar qual versão venceu

**Resultado Esperado**:
- ✅ Vence a versão mais recente (14:30)
- ✅ Reminders em sincro
- ✅ Sem conflitos visuais

**Verificação**:
```sql
SELECT title, updated_at FROM reminders 
WHERE id = 1;
-- Esperado: "Meditação 10min" com timestamp 14:30
```

### Teste 4: Filtros com Sincronização

**Objetivo**: Verificar se filtros funcionam com dados sincronizados

**Passos**:
1. Criar vários reminders (breathing, meditation, hydration)
2. Conectar à internet e sincronizar
3. Filtrar por tipo "breathing"
4. Verificar que apenas breathing aparece

**Resultado Esperado**:
- ✅ Filtros funcionam com dados remotos
- ✅ Query executada no Supabase

---

## 🔐 Testes de Segurança

### Teste 1: RLS - Isolamento de Usuário

**Objetivo**: Verificar que usuário A não vê dados de usuário B

**Passos**:
1. Implementar autenticação (Fase 2)
2. User A cria reminders
3. User A faz logout
4. User B faz login
5. User B abre app
6. Verificar que User B NÃO vê reminders de User A

**Resultado Esperado**:
- ✅ User B vê lista vazia
- ✅ RLS protegendo dados
- ✅ No SQL injection possível

**Verificação**:
```sql
-- Como User A
SELECT * FROM reminders;
-- Resultado: Dados de User A

-- Como User B
SELECT * FROM reminders;
-- Resultado: Lista vazia (RLS protege)
```

### Teste 2: Public Read - Providers

**Objetivo**: Verificar que providers são públicos para leitura

**Passos**:
1. Admin cria provider no Supabase
2. Desconectar (ou sem login)
3. App tentar carregar providers
4. Verificar que providers aparecem (sem login!)

**Resultado Esperado**:
- ✅ Providers carregam sem autenticação
- ✅ Public read funcionando

### Teste 3: Validação no Banco

**Objetivo**: Verificar que banco valida dados

**Passos**:
1. Tentar criar reminder com título vazio (direto no SQL)
2. Tentar criar reminder com data no passado
3. Tentar criar reminder com tipo inválido

**Resultado Esperado**:
- ✅ Banco rejeita dados inválidos
- ✅ Constraints em lugar
- ✅ Mensagens de erro claras

**Verificação**:
```sql
-- Esperado: Error
INSERT INTO reminders (title, scheduled_at, type)
VALUES ('', NOW(), 'invalid_type');

-- Resultado:
-- ERROR: new row for relation "reminders" violates 
-- check constraint "reminders_type_check"
```

---

## ⚡ Testes de Performance

### Teste 1: Tempo de Carga

**Objetivo**: Verificar tempo de carregamento de reminders

**Passos**:
1. Criar 100 reminders
2. Abrir app (online)
3. Medir tempo até aparecer lista
4. Registrar tempo

**Resultado Esperado**:
- ✅ Menos de 2 segundos para 100 items
- ✅ UI responsiva

**Verificação**:
```dart
final sw = Stopwatch()..start();
final reminders = await repository.getAll();
sw.stop();
print('Tempo de carga: ${sw.elapsedMilliseconds}ms');
// Esperado: <2000ms
```

### Teste 2: Tamanho de Dados

**Objetivo**: Verificar consumo de dados na sincronização

**Passos**:
1. Abrir app
2. Monitorar network em DevTools
3. Executar sincronização
4. Registrar bytes transferidos

**Resultado Esperado**:
- ✅ <100KB para sincronização inicial
- ✅ <10KB para mudanças incrementais

**Verificação**:
```
DevTools > Network > Monitor
Total bytes: ~50KB (exemplo)
```

### Teste 3: Memória

**Objetivo**: Verificar que app não vaza memória

**Passos**:
1. Abrir app
2. Carregar reminders (100+)
3. Aguardar 5 minutos
4. Verificar memória em DevTools

**Resultado Esperado**:
- ✅ Memória estável
- ✅ Sem memory leaks

---

## ✅ Checklist de Testes

### Offline Functionality
- [ ] Criar reminder offline
- [ ] Editar reminder offline
- [ ] Deletar reminder offline
- [ ] Consultar reminders offline
- [ ] Sem erros de rede

### Online Functionality
- [ ] Carregar reminders online
- [ ] Criar reminder online (sincroniza)
- [ ] Editar reminder online (sincroniza)
- [ ] Deletar reminder online (sincroniza)

### Synchronization
- [ ] Sincroniza offline → online
- [ ] Sincroniza online → offline (outro device)
- [ ] Resolve conflitos (timestamp)
- [ ] Filtros funcionam com dados remotos

### Security (Após auth)
- [ ] User A não vê dados de User B
- [ ] Providers públicos
- [ ] Banco valida dados
- [ ] RLS protegendo

### Performance
- [ ] Carga < 2 segundos (100 items)
- [ ] Dados < 100KB (sync inicial)
- [ ] Memória estável
- [ ] Sem memory leaks

### Error Handling
- [ ] Network error → fallback local
- [ ] Supabase down → usa local
- [ ] Invalid data → banco rejeita
- [ ] Conflitos → resolvem automático

---

## 🐛 Debug Tips

### Verificar Conexão
```dart
final isOnline = await InternetConnection().hasInternetAccess;
print('Online: $isOnline');
```

### Verificar Credenciais
```dart
final client = SupabaseService.client;
print('URL: ${client.supabaseUrl}');
print('Key: ${client.anonKey.substring(0, 20)}...');
```

### Verificar Dados Locais
```dart
final prefs = await SharedPreferences.getInstance();
final reminders = prefs.getStringList('reminders') ?? [];
print('Local reminders: ${reminders.length}');
```

### Verificar Sync Status
```dart
try {
  await repository.syncWithRemote(reminders);
  print('✅ Sync sucesso');
} catch (e) {
  print('❌ Sync erro: $e');
}
```

### Ativar Logs Detalhados
```dart
// Em reminders_remote_data_source_impl.dart
print('🔄 Iniciando sync...');
print('📱 Local: ${local.length}');
print('☁️ Remote: ${remote.length}');
print('✅ Sync completo');
```

---

## 📊 Relatório de Teste

Depois de executar os testes, documente:

```markdown
# Teste Report - Supabase Integration

**Data**: 2025-01-15
**Versão**: 1.0.0
**Device**: iPhone 14 / Android 12

## Testes Offline
- [x] Criar reminder: ✅ PASS
- [x] Editar reminder: ✅ PASS
- [x] Deletar reminder: ✅ PASS
- [x] Consultar: ✅ PASS

## Testes Online
- [x] Carregar reminders: ✅ PASS
- [x] Criar (sync): ✅ PASS
- [x] Editar (sync): ✅ PASS
- [x] Deletar (sync): ✅ PASS

## Testes de Sync
- [x] Offline → Online: ✅ PASS
- [x] Conflito: ✅ PASS

## Performance
- Carga 100 items: 1.2s ✅
- Dados network: 45KB ✅
- Memória: Estável ✅

## Conclusão
✅ TODOS OS TESTES PASSARAM
Pronto para produção!
```

---

**Dúvidas?** Ver `FAQ_SUPABASE.md`

**Tempo estimado**: 1-2 horas para todos os testes

**Recomendação**: Executar antes de deploy em produção
