## 0) Metadados do Projeto
- **Nome do Produto/Projeto**: ZenBreak — Pausas de Respiração
- **Responsável**: Vitor Thomé
- **Curso/Disciplina**: Desenvolvimento de Aplicações (Flutter)
- **Versão do PRD**: v1.0
- **Data**: 2025-10-07

---

## 1) Visão Geral
**Resumo**: O ZenBreak é um aplicativo simples e leve que conduz o usuário por sessões curtas de respiração guiada para aliviar o estresse durante os estudos. Na primeira execução, apresenta uma sessão demonstrativa local e oferece a opção de agendar lembretes futuros, respeitando políticas e consentimentos.

**Problemas que ataca**: excesso de estresse em estudantes, dificuldade em criar pausas conscientes, e desmotivação para cuidar do bem-estar mental durante os estudos.

**Resultado desejado**: incentivar pausas rápidas e conscientes, oferecendo uma experiência calma e intuitiva desde a primeira execução, com identidade serena e sem fricção.

---

## 2) Personas & Cenários de Primeiro Acesso
- **Persona principal**: Aluno de graduação sob estresse, com rotina intensa de estudos e dificuldades em manter o foco.
- **Cenário (happy path)**: abrir app → splash decide rota → sessão demonstrativa de 2 min → convite para agendar lembrete → fim da introdução.
- **Cenários alternativos**:
  - **Pular demonstração** e agendar lembrete depois.
  - **Recusar lembrete** e usar o app manualmente.
  - **Rever políticas** antes de ativar lembretes.
---

## 3) Identidade do Tema (Design)
### 3.1 Paleta e Direção Visual
- **Primária**: Cyan 500 `#06B6D4`
- **Secundária**: Violet 600 `#7C3AED`
- **Acento**: Amber 500 `#F59E0B`
- **Superfície**: `#FFFFFF`
- **Texto**: `#0F172A`
- Direção: **minimalista suave**, transições fluidas, sensação de leveza e foco na respiração.;
  **useMaterial3: true;** derivar esquema de cores sem valores mágicos diretos em widgets.

### 3.2 Tipografia
- Títulos: `headlineSmall`com peso 600 (tranquilo, mas legível)
- Corpo: `bodyLarge`/`bodyMedium`
- Escalabilidade: compativel com **text scaling** (≥ 1.3) sem distorções.

### 3.3 Iconografia & Ilustrações
- Ícones suaves (círculos, ondas, respiração); estilo outline limpo.
- Ícone principal: círculo/onda calma; usado também em animações da sessão.
- Ilustrações minimalistas com gradientes leves em cyan e violeta, sem textos.

### 3.4 Prompts (imagens/ícone)
- **Ícone do app**: “Círculo com ondas suaves irradiando do centro, estilo flat e vetorial, sem texto, fundo branco, paleta Cyan/Violet, atmosfera calma e meditativa, bordas suaves, 1024×1024.”
- **Hero/empty**: “Ilustração flat minimalista de pessoa sentada respirando profundamente com ondas de ar e círculos concêntricos em cyan e violeta, fundo claro, sem texto.”

**Entrega de identidade**: grade de cores (hex), 2–3 referências (moodboard)grade de cores (hex), moodboard com 2 referências e prompt aprovado.

---

## 4) Jornada de Primeira Execução (Fluxo Base)
### 4.1 Splash
- Exibe o ícone ZenBreak com transição suave; decide rota (primeira execução ou sessão demonstrativa).

### 4.2 Sessão Demonstrativa (2 min)
1. Tela com círculo respiratório animado (inspira/expira).
2. Mensagens curtas: “Inspire fundo...”, “Segure...”, “Expire lentamente...”.
3. Barra de progresso circular.
4. Ao fim: convite para agendar lembrete diário.

### 4.3 Agendar Lembrete
- Pergunta: “Quer fazer uma pausa Zen amanhã neste horário?”
- Opções: Sim, quero (agenda local, sem notificações push) / Mais tarde.
- Após consentimento e políticas, ativa notificações reais.

### 4.4 Políticas e Consentimento (somente após ativar lembretes)
- Visualização de Privacidade e Termos (Markdown local).
- Scroll obrigatório até o fim para habilitar “Marcar como lido”.
- Checkbox “Li e concordo com as políticas do ZenBreak”.
- Persistência da versão e data de aceite.

### 4.5 Home & Sessões
- Tela com botão central “Iniciar pausa de respiração”.
- **Menu secundário:** Histórico, Configurações (revogar aceite, ajustar lembrete).
---

## 5) Requisitos Funcionais (RF)
- **RF‑1** Exibir sessão demonstrativa de respiração (2 min) na primeira execução.
- **RF‑2** Agendar lembrete local após demonstração (sem notificações push antes do aceite).
- **RF‑3** Visualizar políticas em Markdown com progresso e botão “Marcar como lido”.
- **RF‑4** Consentimento habilitado somente após leitura completa dos dois documentos.
- **RF‑5** Decisão de rota no Splash baseada em flags: **demo_completed, policies_version_accepted**.
- **RF‑6** Revogação de aceite com confirmação + opção Desfazer.
- **RF‑7** Versão das políticas persistida com timestamp `ISO8601`.
- **RF‑8** Ícone gerado via `flutter_launcher_icons` (PNG 1024×1024).

---

## 6) Requisitos Não Funcionais (RNF)
- **A11Y**: alvos ≥ **48dp**, foco visível, **Semantics**, contraste AA;
- **Arquitetura**: **UI → Service → Storage**; sem uso direto de `SharedPreferences` na UI.
- **Performance**: animações ~400ms; leves, sem travamentos durante respiração.
- **Privacidade (LGPD)**: consentimento claro antes de lembretes e notificações.
- **Testabilidade**: PrefsService mockável, dependências injetáveis.

---

## 7) Dados & Persistência (chaves)
- `demo_completed`: bool
- `privacy_read_v1`: bool
- `terms_read_v1`: bool
- `policies_version_acceptedstring`: (ex.: `v1`)
- `accepted_at`: string (ISO8601)
- `reminder_scheduled`: bool
- `reminder_time`: string (HH:mm)

**Serviço**: `PrefsService` com get/set/clear; `isAccepted()`, `isDemoDone()`, `scheduleReminder`.

---

## 8) Roteamento
- `/` → **Splash** (decide)
- `/demo` → Sessão demonstrativa de respiração
- `reminder` → Tela de agendamento
- `/policy-viewer` → viewer markdown reutilizável
- `/home` → tela inicial

---

## 9) Critérios de Aceite
1. Sessão de respiração guiada de 2 min executa com feedback visual e sonoro.
2. Após conclusão, app oferece lembrete (sem notificação push antes de aceite).
3. Viewer de políticas possui barra de progresso e botão “Marcar como lido”.
4. Checkbox de aceite habilita somente após leitura dupla.
5. Splash direciona corretamente conforme estado (**demo_completed** e **policies_version_accepted**).
6. Revogação exibe confirmação e SnackBar com Desfazer.
7. UI acessa storage apenas via **PrefsService**.
8. Ícone oficial gerado e aplicado.

---

## 10) Protocolo de QA (testes manuais)
- **Fluxo limpo**: splash → demo → lembrete → políticas → home.
- **Pular lembrete**: não agenda notificação, mas permite acesso manual.
- **Leitura parcial**: não habilita aceite.
- **Reabertura**: vai direto à Home se aceite existe.
- **Revogação com Desfazer**: mantém aceite ativo.
- **Revogação sem Desfazer**: volta ao fluxo legal.
- **A11Y**: testado com escala de fonte 1.3+ e alto contraste.

---

## 11) Riscos & Decisões
- **Risco**: animações pesadas em aparelhos simples → **Mitigação**: usar `policies_verAnimatedContainer/TweenAnimationBuildersion_accepted`.
- **Risco**: notificações antes de consentimento → **Mitigação**: lembretes apenas locais.
- **Decisão**: esconder notificações reais até aceite explícito.
- **Decisão**: design “respirável”, foco em clareza e calma visual.

---

## 12) Entregáveis
1. PRD preenchido
2. Implementação funcional: sessão demonstrativa + agendamento + consentimento.
3. Evidências (prints) dos estados: splash, demo, lembrete, políticas, home.
4. Ícone gerado (comando flutter_launcher_icons).

---

## 13) Backlog de Evolução (opcional)
- Áudio ambiente durante respiração (sons naturais).
- Estatísticas de pausas realizadas.
- Sincronização com calendário (Google Calendar).
- Temas claro/escuro automáticos.

---

## 14) Referências internas
- **BreathingSessionWidget** com animação circular.
- **PrefsService** centralizado.
- Viewer de políticas com progresso.
- Splash com decisão de rota.
- Revogação com **SnackBar** e **Desfazer**.
- Ícone via **flutter_launcher_icons**.

---

### Checklist de Conformidade (colar no PR)
- [ ] Sessão demonstrativa de 2 min
- [ ] Lembrete local configurável
- [ ] Viewer com progresso e aceite
- [ ] Aceite apenas após leitura dupla
- [ ] Splash decide rota por flags
- [ ] Revogação com confirmação + Desfazer
- [ ] Sem SharedPreferences na UI
- [ ] Ícone gerado
- [ ] A11Y (48dp, contraste, text scaling)
