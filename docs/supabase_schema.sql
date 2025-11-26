-- ============================================================================
-- ZenBreak Supabase Schema
-- Tema: Meditação, Respiração e Bem-estar
-- ============================================================================

-- ============================================================================
-- 1. TABELA: reminders (Lembretes/Lembretes de Mindfulness)
-- ============================================================================
-- Armazena lembretes para sessões de respiração, meditação, hidratação, etc.
CREATE TABLE reminders (
  id BIGSERIAL PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  description TEXT NOT NULL,
  scheduled_at TIMESTAMPTZ NOT NULL,
  type VARCHAR(50) NOT NULL DEFAULT 'custom' CHECK (type IN ('breathing', 'hydration', 'posture', 'meditation', 'custom')),
  priority VARCHAR(20) NOT NULL DEFAULT 'medium' CHECK (priority IN ('low', 'medium', 'high')),
  is_active BOOLEAN NOT NULL DEFAULT true,
  metadata JSONB,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  
  CONSTRAINT reminder_title_not_empty CHECK (title <> ''),
  CONSTRAINT reminder_scheduled_at_future CHECK (scheduled_at > NOW())
);

-- Índices para melhor performance
CREATE INDEX idx_reminders_user_id ON reminders(user_id);
CREATE INDEX idx_reminders_scheduled_at ON reminders(scheduled_at);
CREATE INDEX idx_reminders_type ON reminders(type);
CREATE INDEX idx_reminders_priority ON reminders(priority);
CREATE INDEX idx_reminders_is_active ON reminders(is_active);
CREATE INDEX idx_reminders_user_scheduled ON reminders(user_id, scheduled_at);

-- ============================================================================
-- 2. TABELA: breathing_sessions (Sessões de Respiração)
-- ============================================================================
-- Registra histórico de sessões de respiração realizadas
CREATE TABLE breathing_sessions (
  id BIGSERIAL PRIMARY KEY,
  duration_seconds INT NOT NULL CHECK (duration_seconds > 0),
  technique VARCHAR(100) NOT NULL DEFAULT 'box_breathing',
  cycles_completed INT NOT NULL DEFAULT 0,
  rating INT CHECK (rating >= 1 AND rating <= 5),
  notes TEXT,
  completed_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  
  CONSTRAINT valid_session_duration CHECK (duration_seconds <= 3600)
);

CREATE INDEX idx_breathing_sessions_user_id ON breathing_sessions(user_id);
CREATE INDEX idx_breathing_sessions_completed_at ON breathing_sessions(completed_at);

-- ============================================================================
-- 3. TABELA: meditation_sessions (Sessões de Meditação)
-- ============================================================================
-- Registra histórico de sessões de meditação
CREATE TABLE meditation_sessions (
  id BIGSERIAL PRIMARY KEY,
  duration_seconds INT NOT NULL CHECK (duration_seconds > 0),
  meditation_type VARCHAR(100) NOT NULL DEFAULT 'mindfulness',
  mood_before VARCHAR(50),
  mood_after VARCHAR(50),
  notes TEXT,
  completed_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  
  CONSTRAINT valid_meditation_duration CHECK (duration_seconds <= 3600)
);

CREATE INDEX idx_meditation_sessions_user_id ON meditation_sessions(user_id);
CREATE INDEX idx_meditation_sessions_completed_at ON meditation_sessions(completed_at);

-- ============================================================================
-- 4. TABELA: wellness_goals (Metas de Bem-estar)
-- ============================================================================
-- Define metas de bem-estar (ex: 3 sessões por semana)
CREATE TABLE wellness_goals (
  id BIGSERIAL PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  description TEXT,
  goal_type VARCHAR(100) NOT NULL CHECK (goal_type IN ('daily', 'weekly', 'monthly')),
  target_sessions INT NOT NULL CHECK (target_sessions > 0),
  category VARCHAR(100) NOT NULL CHECK (category IN ('breathing', 'meditation', 'hydration', 'posture', 'general')),
  progress_sessions INT NOT NULL DEFAULT 0,
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  deadline TIMESTAMPTZ,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  
  CONSTRAINT valid_goal_title CHECK (title <> '')
);

CREATE INDEX idx_wellness_goals_user_id ON wellness_goals(user_id);
CREATE INDEX idx_wellness_goals_is_active ON wellness_goals(is_active);

-- ============================================================================
-- 5. TABELA: providers (Fornecedores de Bem-estar)
-- ============================================================================
-- Armazena informações sobre fornecedores/recursos de bem-estar
CREATE TABLE providers (
  id BIGSERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  image_url VARCHAR(500),
  brand_color_hex VARCHAR(7),
  rating DECIMAL(2,1) CHECK (rating >= 0 AND rating <= 5),
  distance_km DECIMAL(8,2),
  status VARCHAR(50) NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'inactive')),
  metadata JSONB,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ,
  
  CONSTRAINT valid_provider_name CHECK (name <> '')
);

CREATE INDEX idx_providers_status ON providers(status);
CREATE INDEX idx_providers_rating ON providers(rating);

-- ============================================================================
-- 6. TABELA: user_preferences (Preferências do Usuário)
-- ============================================================================
-- Armazena preferências personalizadas do usuário
CREATE TABLE user_preferences (
  id BIGSERIAL PRIMARY KEY,
  user_id UUID UNIQUE REFERENCES auth.users(id) ON DELETE CASCADE,
  preferred_session_duration INT NOT NULL DEFAULT 300 CHECK (preferred_session_duration > 0),
  favorite_breathing_technique VARCHAR(100) DEFAULT 'box_breathing',
  notifications_enabled BOOLEAN NOT NULL DEFAULT true,
  reminder_time TIME DEFAULT '09:00:00',
  theme VARCHAR(50) DEFAULT 'light' CHECK (theme IN ('light', 'dark')),
  language VARCHAR(20) DEFAULT 'pt-BR',
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_user_preferences_user_id ON user_preferences(user_id);

-- ============================================================================
-- 7. TABELA: wellness_tips (Dicas de Bem-estar)
-- ============================================================================
-- Base de conhecimento com dicas de respiração, meditação, etc.
CREATE TABLE wellness_tips (
  id BIGSERIAL PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  content TEXT NOT NULL,
  category VARCHAR(100) NOT NULL CHECK (category IN ('breathing', 'meditation', 'hydration', 'posture', 'sleep')),
  difficulty VARCHAR(50) DEFAULT 'beginner' CHECK (difficulty IN ('beginner', 'intermediate', 'advanced')),
  duration_seconds INT,
  image_url VARCHAR(500),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  is_published BOOLEAN NOT NULL DEFAULT false
);

CREATE INDEX idx_wellness_tips_category ON wellness_tips(category);
CREATE INDEX idx_wellness_tips_is_published ON wellness_tips(is_published);

-- ============================================================================
-- 8. TABELA: historico_usuario (Histórico de Meditação do Usuário)
-- ============================================================================
-- Registra cada sessão de meditação: quantas vezes meditou e quanto tempo
CREATE TABLE historico_usuario (
  id BIGSERIAL PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  duracao_segundos INT NOT NULL CHECK (duracao_segundos > 0),
  meditacao_id BIGINT,
  data_sessao TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  
  CONSTRAINT valid_historico_duration CHECK (duracao_segundos <= 3600)
);

-- Índices para melhor performance
CREATE INDEX idx_historico_usuario_user_id ON historico_usuario(user_id);
CREATE INDEX idx_historico_usuario_data_sessao ON historico_usuario(data_sessao);
CREATE INDEX idx_historico_usuario_user_data ON historico_usuario(user_id, data_sessao);
CREATE INDEX idx_historico_usuario_meditacao_id ON historico_usuario(meditacao_id);

-- ============================================================================
-- Row Level Security (RLS) Policies
-- ============================================================================

-- Ativar RLS para tabelas com dados do usuário
ALTER TABLE reminders ENABLE ROW LEVEL SECURITY;
ALTER TABLE breathing_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE meditation_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE wellness_goals ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_preferences ENABLE ROW LEVEL SECURITY;
ALTER TABLE historico_usuario ENABLE ROW LEVEL SECURITY;

-- Políticas para reminders
CREATE POLICY "Reminders - Usuários veem apenas seus próprios" ON reminders
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Reminders - Usuários criam seus próprios" ON reminders
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Reminders - Usuários atualizam seus próprios" ON reminders
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Reminders - Usuários deletam seus próprios" ON reminders
  FOR DELETE USING (auth.uid() = user_id);

-- Políticas para breathing_sessions
CREATE POLICY "Breathing sessions - Usuários veem apenas seus próprios" ON breathing_sessions
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Breathing sessions - Usuários criam seus próprios" ON breathing_sessions
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Políticas para meditation_sessions
CREATE POLICY "Meditation sessions - Usuários veem apenas seus próprios" ON meditation_sessions
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Meditation sessions - Usuários criam seus próprios" ON meditation_sessions
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Políticas para wellness_goals
CREATE POLICY "Wellness goals - Usuários veem apenas seus próprios" ON wellness_goals
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Wellness goals - Usuários criam seus próprios" ON wellness_goals
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Políticas para user_preferences
CREATE POLICY "User preferences - Usuários veem apenas seus próprios" ON user_preferences
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "User preferences - Usuários atualizam seus próprios" ON user_preferences
  FOR UPDATE USING (auth.uid() = user_id);

-- Políticas para historico_usuario
CREATE POLICY "Historico usuario - Usuários veem apenas seus próprios" ON historico_usuario
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Historico usuario - Usuários criam seus próprios" ON historico_usuario
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Providers: leitura pública, criação restrita
CREATE POLICY "Providers - Públicos para leitura" ON providers
  FOR SELECT USING (true);

-- ============================================================================
-- COMENTÁRIOS DESCRITIVOS
-- ============================================================================
COMMENT ON TABLE reminders IS 'Lembretes para sessões de bem-estar (respiração, meditação, etc.)';
COMMENT ON TABLE breathing_sessions IS 'Histórico de sessões de respiração realizadas pelo usuário';
COMMENT ON TABLE meditation_sessions IS 'Histórico de sessões de meditação realizadas pelo usuário';
COMMENT ON TABLE wellness_goals IS 'Metas de bem-estar pessoais do usuário';
COMMENT ON TABLE providers IS 'Fornecedores e recursos de bem-estar';
COMMENT ON TABLE user_preferences IS 'Preferências personalizadas do usuário';
COMMENT ON TABLE wellness_tips IS 'Base de conhecimento com dicas de bem-estar';
COMMENT ON TABLE historico_usuario IS 'Histórico de sessões de meditação: quantas vezes o usuário meditou e o tempo total gasto';

COMMENT ON COLUMN reminders.type IS 'Tipo de lembrete: respiração, hidratação, postura, meditação ou customizado';
COMMENT ON COLUMN breathing_sessions.technique IS 'Técnica de respiração: box breathing, 4-7-8, nasal alternada, etc.';
COMMENT ON COLUMN meditation_sessions.meditation_type IS 'Tipo de meditação: mindfulness, visualização, body scan, etc.';
COMMENT ON COLUMN wellness_goals.goal_type IS 'Periodicidade da meta: diária, semanal ou mensal';
COMMENT ON COLUMN wellness_tips.difficulty IS 'Nível de dificuldade da dica para usuário iniciante/intermediário/avançado';
