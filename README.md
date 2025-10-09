# ZenBreak (scaffold)

Este repositório contém um scaffold funcional do app ZenBreak conforme PRD fornecido.

Funcionalidades implementadas nesta versão:
- Splash com decisão de rota (demo/policy/home)
- Sessão demonstrativa simples (BreathingSession)
- Viewer de políticas (carrega assets/markdown) que exige scroll até o final para habilitar aceite
- Agendamento simples de lembrete (persistido em SharedPreferences)
- Home com botão central para iniciar pausa e menu para revogar aceite/ver políticas
- `PrefsService` isolando o acesso ao `SharedPreferences`

Como rodar (PowerShell):

```powershell
flutter pub get
flutter analyze
flutter run -d <device>
```

Notas:
- As notificações reais não foram implementadas aqui; apenas persistência do lembrete.
- Ícone e `flutter_launcher_icons` não foram configurados automaticamente.
# ZenBreak — Pausas de Respiração (Ready-to-open)

Este pacote contém o código-fonte do app ZenBreak inspirado na estrutura do
repositório indicado (aplicativo_receitas_culinarias). Para abrir e executar:

1. Extraia/abra esta pasta no VSCode.
2. No terminal do VSCode execute:
   flutter create .
   flutter pub get
   flutter run

Observações:
- ApplicationId sugerido: com.example.zenbreak
- minSdkVersion recomendado: 21
