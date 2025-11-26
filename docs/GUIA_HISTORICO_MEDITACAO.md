# Guia: Histórico de Meditação - ZenBreak

## 📋 Visão Geral

O sistema de histórico de meditação rastreia cada sessão de meditação do usuário, permitindo:
- ✅ Registrar automaticamente o tempo gasto em cada meditação
- ✅ Acompanhar quantas vezes o usuário meditou
- ✅ Calcular tempo total gasto em meditação
- ✅ Visualizar histórico de sessões

## 🗄️ Estrutura do Banco de Dados

### Tabela: `historico_usuario`

```sql
CREATE TABLE historico_usuario (
  id BIGSERIAL PRIMARY KEY,                          -- ID único da sessão
  user_id UUID NOT NULL REFERENCES auth.users(id),   -- Usuário autenticado
  duracao_segundos INT NOT NULL,                     -- Duração em segundos
  meditacao_id BIGINT,                               -- ID da meditação (opcional)
  data_sessao TIMESTAMPTZ NOT NULL DEFAULT NOW(),    -- Quando a sessão ocorreu
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),     -- Quando foi registrada
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),     -- Última atualização
);
```

**Índices para Performance:**
- `idx_historico_usuario_user_id` - Buscar sessões por usuário (rápido)
- `idx_historico_usuario_data_sessao` - Ordenar por data
- `idx_historico_usuario_user_data` - Consultas filtradas por usuário + data

**Row Level Security (RLS):**
- Usuários só podem ver suas próprias sessões
- Usuários só podem criar registros para si mesmos

## 📁 Estrutura de Arquivos

```
lib/
├── features/historico/
│   ├── data/
│   │   ├── datasources/
│   │   │   ├── historico_remote_data_source.dart          (interface)
│   │   │   └── historico_remote_data_source_impl.dart     (Supabase)
│   │   └── repositories/
│   │       └── historico_repository_impl.dart              (implementação)
│   ├── domain/
│   │   └── repositories/
│   │       └── historico_repository.dart                   (interface)
│   └── presentation/
│       └── controllers/
│           └── historico_controller.dart                   (Provider)
│
├── widgets/
│   ├── breathing_session.dart                              (original - sem histórico)
│   ├── breathing_session_with_history.dart                 (novo - com histórico)
│   └── estatisticas_meditacao_widget.dart                  (exibe estatísticas)
│
└── pages/
    └── meditation_history_demo_page.dart                   (página demo)
```

## 🔌 Como Usar

### 1. **Iniciar uma Sessão com Histórico**

Use `BreathingSessionWithHistory` em vez de `BreathingSession`:

```dart
import 'package:provider/provider.dart';
import 'widgets/breathing_session_with_history.dart';

// Na sua página/widget:
BreathingSessionWithHistory(
  durationSeconds: 300,        // 5 minutos
  meditacao_id: 42,            // ID da meditação (opcional)
  onFinished: () {
    // Callback quando termina (já salvou automaticamente)
    print('Meditação finalizada e registrada!');
  },
)
```

**O que acontece automaticamente:**
1. Quando o timer termina, `onFinished` é chamado
2. `HistoricoController.salvarSessao()` é invocado
3. A sessão é salva no Supabase
4. Um Snackbar confirma o salvamento
5. As estatísticas são atualizadas

### 2. **Exibir Estatísticas**

Use `EstatisticasMeditacaoWidget`:

```dart
import 'widgets/estatisticas_meditacao_widget.dart';

// Na sua página:
const EstatisticasMeditacaoWidget()
```

Isso exibe:
- "Você meditou X vezes totalizando Y minutos"
- Card com ícones e números

### 3. **Usar o Controller Manualmente**

Se precisar controlar o histórico programaticamente:

```dart
import 'package:provider/provider.dart';

// Em um Widget/State:
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    Provider.of<HistoricoController>(context, listen: false)
      .carregarEstatisticas();
  });
}

@override
Widget build(BuildContext context) {
  return Consumer<HistoricoController>(
    builder: (context, historicoController, child) {
      if (historicoController.carregando) {
        return const CircularProgressIndicator();
      }

      if (historicoController.erro != null) {
        return Text('Erro: ${historicoController.erro}');
      }

      final stats = historicoController.estatisticas;
      return Text(
        'Meditou ${stats.totalVezes} vezes = ${stats.totalMinutos} min',
      );
    },
  );
}
```

## 🚀 Métodos do Controller

### `salvarSessao()`
```dart
Future<void> salvarSessao({
  required int duracao_segundos,
  int? meditacao_id,
})
```
- Salva uma nova sessão
- Atualiza as estatísticas automaticamente
- Notifica listeners

### `carregarEstatisticas()`
```dart
Future<void> carregarEstatisticas()
```
- Busca total de vezes e minutos do usuário
- Atualiza `estatisticas`
- Define `carregando` e `erro`

### `carregarSessoes()`
```dart
Future<void> carregarSessoes()
```
- Busca todas as sessões ordenadas por data (mais recentes primeiro)
- Atualiza `sessoes`

### Getters
```dart
EstatisticasMeditacao get estatisticas    // Dados de vezes/minutos
bool get carregando                        // Indica carregamento
String? get erro                           // Mensagem de erro (ou null)
List<Map<String, dynamic>> get sessoes     // Lista de todas as sessões
```

## 🧪 Página Demo

Acesse `/meditation-history-demo` para testar:

```dart
// Em main.dart ou navigation:
Navigator.pushNamed(context, '/meditation-history-demo');
```

Funcionalidades:
- Botão "Iniciar Meditação (3 min)"
- Mostra estatísticas do usuário
- Lista de sessões com datas formatadas
- Mensagem de confirmação ao salvar

## 📊 Fluxo de Dados

```
1. Usuário inicia meditação (BreathingSessionWithHistory)
                    ↓
2. Timer termina → onFinished() chamado
                    ↓
3. HistoricoController.salvarSessao() executado
                    ↓
4. HistoricoRepository.salvarSessao() chamado
                    ↓
5. HistoricoRemoteDataSourceImpl.salvarSessao() (Supabase)
                    ↓
6. INSERT INTO historico_usuario (user_id, duracao_segundos, meditacao_id, ...)
                    ↓
7. Snackbar confirma
                    ↓
8. carregarEstatisticas() atualiza dados exibidos
```

## 🔒 Segurança

- **RLS Policies:** Cada usuário só vê/cria seus próprios registros
- **user_id:** Sempre preenchido com `auth.currentUser.id`
- **Supabase Auth:** Requerido para salvar dados

## 🐛 Troubleshooting

### "Usuário não autenticado"
- Certifique-se que o usuário fez login via Supabase Auth
- Verifique se `Supabase.instance.client.auth.currentUser` não é `null`

### "Erro ao salvar sessão"
- Verifique logs com `debugPrint('[HistoricoController]...')`
- Confira se a tabela `historico_usuario` existe no Supabase
- Verifique RLS policies

### Estatísticas não atualizam
- Chame `carregarEstatisticas()` manualmente
- Verificar se há dados no Supabase

## 📝 Exemplo Completo

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'widgets/breathing_session_with_history.dart';
import 'widgets/estatisticas_meditacao_widget.dart';

class MinhaTeladeMeditacao extends StatefulWidget {
  @override
  State<MinhaTeladeMeditacao> createState() => _MinhaTeladeMeditacaoState();
}

class _MinhaTeladeMeditacaoState extends State<MinhaTeladeMeditacao> {
  bool meditando = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Meditação')),
      body: meditando
          ? BreathingSessionWithHistory(
              durationSeconds: 300,
              onFinished: () {
                setState(() => meditando = false);
              },
            )
          : Column(
              children: [
                const EstatisticasMeditacaoWidget(),
                ElevatedButton(
                  onPressed: () => setState(() => meditando = true),
                  child: const Text('Iniciar'),
                ),
              ],
            ),
    );
  }
}
```

## 🎯 Próximos Passos

1. Integrar em `home_page.dart` para mostrar estatísticas no perfil
2. Adicionar filtros por período (hoje, semana, mês)
3. Criar gráficos de progresso
4. Adicionar medalhas/achievements por milestones
5. Sincronização offline com local persistence

---

**Data:** 25 de novembro de 2025  
**Versão:** 1.0
