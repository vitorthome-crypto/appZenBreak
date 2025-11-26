# 🧘 ZenBreak - Guia de Configuração Supabase

## 📋 Visão Geral

Este documento descreve como configurar o Supabase para sincronizar dados de lembretes, sessões de respiração/meditação e metas de bem-estar.

## 🚀 Pré-requisitos

- Conta no [Supabase](https://supabase.com)
- Projeto Supabase criado
- Chaves de API (URL e Anon Key)
- Flutter 3.0+

## 📊 Schema do Banco de Dados

O projeto inclui 7 tabelas principais:

### 1. **reminders** - Lembretes de Bem-estar
Armazena lembretes para sessões de respiração, meditação, hidratação, postura.

```
Campos:
- id (PK)
- title: Título do lembrete (ex: "Respiração Profunda")
- description: Descrição detalhada
- scheduled_at: Data/hora agendada
- type: breathing | hydration | posture | meditation | custom
- priority: low | medium | high
- is_active: Ativo/Inativo
- metadata: JSONB com dados adicionais
- user_id: Referência ao usuário (FK)
```

### 2. **breathing_sessions** - Sessões de Respiração
Histórico de sessões de respiração realizadas.

```
Campos:
- id (PK)
- duration_seconds: Duração em segundos
- technique: box_breathing | 4-7-8 | nasal_alternada | etc
- cycles_completed: Ciclos completados
- rating: 1-5 (avaliação)
- notes: Notas do usuário
- completed_at: Quando foi completada
- user_id: Referência ao usuário (FK)
```

### 3. **meditation_sessions** - Sessões de Meditação
Histórico de sessões de meditação realizadas.

```
Campos:
- id (PK)
- duration_seconds: Duração em segundos
- meditation_type: mindfulness | visualização | body_scan | etc
- mood_before: Humor antes
- mood_after: Humor depois
- notes: Notas do usuário
- completed_at: Quando foi completada
- user_id: Referência ao usuário (FK)
```

### 4. **wellness_goals** - Metas de Bem-estar
Metas pessoais (ex: 3 sessões por semana).

```
Campos:
- id (PK)
- title: Título da meta
- goal_type: daily | weekly | monthly
- target_sessions: Número de sessões alvo
- category: breathing | meditation | hydration | posture | general
- progress_sessions: Sessões completadas
- is_active: Ativa/Inativa
- deadline: Prazo limite
- user_id: Referência ao usuário (FK)
```

### 5. **providers** - Fornecedores de Bem-estar
Recursos e fornecedores de bem-estar.

```
Campos:
- id (PK)
- name: Nome do fornecedor
- description: Descrição
- image_url: URL da imagem
- brand_color_hex: Cor da marca (#RRGGBB)
- rating: 0-5 (avaliação)
- distance_km: Distância em km
- status: active | inactive
- metadata: JSONB com dados adicionais
```

### 6. **user_preferences** - Preferências do Usuário
Configurações personalizadas.

```
Campos:
- id (PK)
- user_id: Referência ao usuário (FK, UNIQUE)
- preferred_session_duration: Duração preferida (segundos)
- favorite_breathing_technique: Técnica favorita
- notifications_enabled: Notificações ativas?
- reminder_time: Horário dos lembretes (HH:MM:SS)
- theme: light | dark
- language: Idioma (pt-BR, en-US, etc)
```

### 7. **wellness_tips** - Dicas de Bem-estar
Base de conhecimento com dicas.

```
Campos:
- id (PK)
- title: Título da dica
- content: Conteúdo completo
- category: breathing | meditation | hydration | posture | sleep
- difficulty: beginner | intermediate | advanced
- duration_seconds: Duração sugerida
- image_url: URL da imagem
- is_published: Publicada?
```

## 🔧 Passos de Configuração

### 1️⃣ Criar Projeto no Supabase

1. Acesse [Supabase Dashboard](https://app.supabase.com)
2. Clique em "New project"
3. Preencha os dados:
   - **Name**: ZenBreak
   - **Database Password**: Use uma senha forte
   - **Region**: Escolha a mais próxima (ex: South America - São Paulo)
4. Clique "Create new project"

### 2️⃣ Executar o Schema SQL

1. Vá para "SQL Editor" no dashboard
2. Clique "New query"
3. Cole o conteúdo de `docs/supabase_schema.sql`
4. Clique "Run"

### 3️⃣ Obter Credenciais

1. Vá para "Project Settings" → "API"
2. Copie:
   - **URL**: `https://[project-id].supabase.co`
   - **anon public**: `eyJ0eXAi...` (sua chave pública)

### 4️⃣ Configurar Autenticação

No Supabase Dashboard:

1. Vá para "Authentication" → "Providers"
2. Ative os provedores desejados:
   - ✅ Email (padrão)
   - ✅ Google (opcional)
   - ✅ GitHub (opcional)

### 5️⃣ Atualizar Variáveis de Ambiente

Crie/atualize o arquivo `.env`:

```env
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
```

## 🔐 Segurança - Row Level Security (RLS)

Todas as tabelas com dados de usuário têm RLS ativado:

- **Lembretes**: Cada usuário vê apenas seus próprios
- **Sessões**: Cada usuário vê apenas suas próprias
- **Metas**: Cada usuário vê apenas suas próprias
- **Preferências**: Cada usuário vê apenas suas próprias
- **Providers**: Públicos para leitura (qualquer um pode ver)

## 📱 Integração no Flutter

### Reminders com Supabase

```dart
// 1. Inicializar o datasource remoto
final supabaseClient = SupabaseService.client;
final remoteDataSource = RemindersRemoteDataSourceImpl(
  supabaseClient: supabaseClient,
);

// 2. Criar repositório com sincronização
final repository = RemindersRepositoryImpl(
  localDataSource: localDataSource,
  remoteDataSource: remoteDataSource,
);

// 3. Controller carrega e sincroniza
await controller.loadReminders(); // Sincroniza automaticamente
```

## 🔄 Estratégia de Sincronização

O app usa **offline-first** com sincronização automática:

1. **Leitura**: Carrega do cache local, sincroniza em background
2. **Criação**: Salva localmente, envia ao servidor quando online
3. **Atualização**: Atualiza localmente, sincroniza quando online
4. **Conflito**: Usa timestamp (local vs remoto, mais recente vence)

## 📊 Exemplo de Dados

### Reminder
```json
{
  "id": 1,
  "title": "Sessão de Respiração",
  "description": "Realize 5 minutos de respiração profunda",
  "scheduled_at": "2025-01-15T14:30:00Z",
  "type": "breathing",
  "priority": "high",
  "is_active": true,
  "metadata": {
    "duration": 300,
    "technique": "box_breathing"
  }
}
```

### Breathing Session
```json
{
  "id": 1,
  "duration_seconds": 300,
  "technique": "box_breathing",
  "cycles_completed": 12,
  "rating": 5,
  "notes": "Muito relaxante!",
  "completed_at": "2025-01-15T14:30:00Z"
}
```

## 🐛 Troubleshooting

### Erro: "Auth session missing"
- Implemente autenticação no app
- Use `supabaseClient.auth.signUp()` ou `signIn()`

### Erro: "RLS policy violation"
- Verifique se o `user_id` está sendo enviado corretamente
- Verifique se o usuário está autenticado

### Erro: "Table not found"
- Verifique se o schema SQL foi executado completamente
- Verifique os nomes das tabelas (use snake_case)

### Conexão lenta
- Verifique a região do projeto (escolha a mais próxima)
- Adicione índices adicionais conforme necessário
- Considere usar cache local mais agressivamente

## 📚 Recursos Úteis

- [Supabase Docs](https://supabase.com/docs)
- [Supabase Flutter](https://supabase.com/docs/guides/getting-started/quickstarts/flutter)
- [PostgreSQL Docs](https://www.postgresql.org/docs/)
- [Row Level Security](https://supabase.com/docs/guides/auth/row-level-security)

## ✅ Checklist de Implementação

- [ ] Projeto Supabase criado
- [ ] Schema SQL executado
- [ ] Credenciais configuradas no `.env`
- [ ] Autenticação implementada
- [ ] RemoteDataSource criado
- [ ] Sincronização implementada
- [ ] Testes em desenvolvimento
- [ ] Testes em produção

## 🎯 Próximos Passos

1. Implementar autenticação (email/Google)
2. Adicionar sincronização automática em background
3. Implementar notificações push
4. Criar dashboard de estatísticas
5. Adicionar exportação de dados

---

**Dúvidas?** Consulte a documentação ou abra uma issue no repositório.
