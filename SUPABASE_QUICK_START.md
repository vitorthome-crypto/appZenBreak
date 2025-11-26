# 🚀 Quick Start - Supabase Integration

> Resumo rápido para começar com sincronização Supabase no ZenBreak

## ⚡ 5 Minutos para Setup

### 1. Criar Projeto Supabase
```
1. Acesse supabase.com
2. Clique "New project"
3. Preencha nome e senha
4. Escolha região (ex: South America)
```

### 2. Copiar Credenciais
```
Dashboard > Settings > API
├── URL: https://xxx.supabase.co
└── Anon Key: eyJ...xxx
```

### 3. Preencher .env
```bash
# .env
SUPABASE_URL=https://xxx.supabase.co
SUPABASE_ANON_KEY=eyJ...xxx
```

### 4. Executar Schema
```
Dashboard > SQL Editor > New Query
Cole conteúdo de: docs/supabase_schema.sql
Clique: Run
```

### 5. Atualizar main.dart
```dart
// Ver: docs/MAIN_DART_INTEGRATION.md
// Copie o exemplo completo
```

## 📁 Arquivos Importantes

| Arquivo | Descrição |
|---------|-----------|
| `docs/SUPABASE_SETUP.md` | 📖 Guia detalhado setup |
| `docs/supabase_schema.sql` | 📊 Schema SQL (7 tabelas) |
| `docs/MAIN_DART_INTEGRATION.md` | 💻 Código main.dart |
| `docs/IMPLEMENTATION_GUIDE.md` | 🔧 Guia implementação |
| `.env.example` | ⚙️ Arquivo config |

## 🧪 Testar Sincronização

```dart
// No controller ou numa tela:
await controller.loadReminders(); // Carrega + sincroniza automaticamente
```

Monitor no Supabase:
```
Dashboard > reminders > Table Editor
// Veja seus lembretes aparecerem em tempo real!
```

## 🐛 Troubleshooting Rápido

| Problema | Solução |
|----------|---------|
| "Table not found" | Execute schema SQL (passo 4) |
| "Auth session missing" | App é offline-first, sync falha mas app funciona |
| "RLS policy violation" | Setup autenticação (próxima fase) |
| Dados não sincronizam | Verifique internet + credenciais .env |

## 📊 Tabelas Criadas

```
reminders                 - Lembretes ✅
breathing_sessions        - Respiração ✅
meditation_sessions       - Meditação ✅
wellness_goals           - Metas ✅
providers                - Fornecedores ✅
user_preferences         - Preferências ✅
wellness_tips            - Dicas ✅
```

## 🎯 Próximos Passos

1. ✅ Setup Supabase (5 min)
2. ✅ Integração main.dart (10 min)
3. ⏳ Autenticação (20 min) - *próxima fase*
4. ⏳ Breathing Sessions sync
5. ⏳ Real-time subscriptions

## 💡 Recurso Útil

```dart
// Debug: Verificar o que está sincronizando
print('Lembretes: ${controller.reminders.length}');
print('Carregando: ${controller.isLoading}');
print('Erro: ${controller.error}');
```

## 📞 Documentação Completa

👉 Veja `docs/SUPABASE_SETUP.md` para guia completo

---

**Tempo estimado**: 30 minutos até sincronização funcional! ⏱️
