# ZenBreak — Pausas de Respiração Consciente

App de meditação e respiração construído com Flutter seguindo **Clean Architecture** para máxima escalabilidade e manutenibilidade.

## Funcionalidades Implementadas

### Core
- ✅ Splash com decisão de rota (demo/policy/home)
- ✅ Sessão de respiração com animação de pulsação + timer MM:SS
- ✅ Seleção de duração customizada (MM:SS)
- ✅ Picker de cores para tema personalizado (8 cores presets)
- ✅ Viewer de políticas com scroll obrigatório para aceite
- ✅ Agendamento de lembretes (persistido em SharedPreferences)
- ✅ Menu settings e visualização de políticas na home
- ✅ PrefsService com reatividade (ChangeNotifier)

### Providers (Fornecedores)
- ✅ Listagem de fornecedores com paginação (20 por página)
- ✅ Busca por nome ou tags
- ✅ Filtro por status (active/inactive)
- ✅ Ordenação (nome, rating, distância, data atualização)
- ✅ Swipe-to-delete com undo
- ✅ Mock data para testes

## Arquitetura Implementada: Clean Architecture

O projeto segue **Clean Architecture** com separação clara entre camadas de domínio, dados e apresentação.

### Estrutura de Pastas

```
lib/
├── features/
│   └── providers/                    # Feature de Fornecedores
│       ├── domain/                   # Lógica de negócio pura
│       │   ├── entities/
│       │   │   └── provider.dart     # Entidade Provider com validações
│       │   └── repositories/
│       │       └── providers_repository.dart  # Interface abstrata
│       │
│       ├── data/                     # Implementação de persistência
│       │   ├── datasources/
│       │   │   ├── providers_local_data_source.dart       # Interface
│       │   │   └── providers_local_data_source_impl.dart  # SharedPrefs
│       │   ├── repositories/
│       │   │   └── providers_repository_impl.dart  # Implementação
│       │   └── mappers/
│       │       └── provider_mapper.dart  # DTO ↔ Entity
│       │
│       ├── infrastructure/           # Detalhes técnicos
│       │   ├── dtos/
│       │   │   └── provider_dto.dart  # Serialização JSON
│       │   └── dao/
│       │       └── providers_local_dao.dart  # Acesso SharedPrefs
│       │
│       └── presentation/             # UI e lógica de apresentação
│           ├── pages/
│           │   └── fornecedores_page.dart
│           ├── controllers/
│           │   └── fornecedores_controller.dart  # Business logic
│           ├── widgets/
│           │   └── fornecedor_list_item.dart
│           └── utils/
│               └── mock_data.dart
│
├── pages/
│   ├── home_page.dart
│   ├── demo_page.dart
│   ├── splash_page.dart
│   ├── policy_viewer_page.dart
│   └── reminder_page.dart
│
├── widgets/
│   ├── breathing_session.dart        # Animação pulsação + timer
│   └── dismissible_card.dart         # Swipe-to-delete reutilizável
│
├── services/
│   └── prefs_service.dart            # Singleton com ChangeNotifier
│
└── main.dart
```

### Fluxo de Dados

#### 📥 Leitura (Carregamento de Fornecedores)

```
FornecedoresPage (UI)
    ↓ initState()
FornecedoresController (ChangeNotifier)
    ↓ loadProviders()
ProvidersRepository.getAll()
    ↓
ProvidersLocalDataSource.getAll()
    ↓ (SharedPreferences)
ProvidersDTO[] → ProviderMapper.fromDtoList()
    ↓
Provider[] (Entities) → notifyListeners()
    ↓
FornecedoresPage rebuild com dados filtrados
```

#### 📤 Escrita (Operações CRUD)

```
FornecedoresPage (User Action: delete)
    ↓
FornecedoresController.deleteProvider(id)
    ↓
ProvidersRepository.delete(id)
    ↓
ProvidersLocalDataSource.delete(id)
    ↓ (SharedPreferences)
notifyListeners()
    ↓
FornecedoresPage re-renderiza lista
```

### Benefícios da Arquitetura

| Benefício | Implementação |
|-----------|---------------|
| **Testabilidade** | Domain layer sem deps externas |
| **Manutenibilidade** | Responsabilidades bem separadas |
| **Escalabilidade** | Fácil adicionar API remota |
| **Flexibilidade** | Trocar SharedPrefs → Firebase |
| **Reusabilidade** | Mesma lógica para web/desktop |

---

## Como Rodar

### Requisitos
- Flutter 3.0+ instalado e configurado
- Dart 3.0+
- Dispositivo físico ou emulador Android/iOS/macOS/Windows/Linux

### Passos

```powershell
# 1. Clonar repositório
git clone https://github.com/vitorthome-crypto/appZenBreak.git
cd appZenBreak

# 2. Instalar dependências
flutter pub get

# 3. Analisar código
flutter analyze

# 4. Rodar no dispositivo
flutter run -d <device>

# Ou no modo release
flutter run --release
```

### Plataformas Suportadas
- ✅ Android
- ✅ iOS
- ✅ macOS
- ✅ Windows
- ✅ Linux
- ✅ Web

## Stack Tecnológico

- **Framework**: Flutter + Dart
- **State Management**: Provider (ChangeNotifier)
- **Persistência**: SharedPreferences
- **Arquitetura**: Clean Architecture (Domain/Data/Presentation)
- **UI**: Material Design 3
- **Temas**: Cores customizáveis (8 presets)

## Estrutura de Branches Git

```
main (produção)
```

### Política de Commits
- Formato: `type: description`
- Tipos: `feat:`, `fix:`, `refactor:`, `docs:`, `chore:`
- Exemplo: `refactor: implement Clean Architecture for providers feature`

## Dependências Principais

```yaml
flutter:
  sdk: flutter

provider: ^6.0.5              # State management
shared_preferences: ^2.0.15   # Persistência local
flutter_markdown: ^0.6.0      # Renderização de markdown
dots_indicator: ^2.1.0        # Indicador de páginas
flutter_local_notifications: ^12.0.4  # Notificações locais
```

## Documentação

- 📖 **[ARCHITECTURE.md](./ARCHITECTURE.md)** - Documentação detalhada de Clean Architecture
- 📋 **[ZenBreakPRD.md](./ZenBreakPRD.md)** - Product Requirements Document

## Próximos Passos

- [ ] Implementar testes unitários para domain layer
- [ ] Adicionar testes de integração para repositories
- [ ] Service Locator (get_it) para injeção de dependências
- [ ] API remota para sincronização de fornecedores
- [ ] Notificações push reais
- [ ] Analytics e rastreamento de sessões

## Licença

Este projeto está sob licença MIT. Veja [LICENSE](./LICENSE) para detalhes.

## Autor

- **Vitor Thomé** - [@vitorthome-crypto](https://github.com/vitorthome-crypto)
