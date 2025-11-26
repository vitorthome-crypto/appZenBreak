-- =====================================================
-- MIGRAÇÃO: Adicionar suporte a sessões parciais (canceladas)
-- =====================================================
-- 
-- Esta migração adiciona a coluna 'parcial' à tabela 'historico_usuario'
-- para marcas sessões que foram canceladas pelo usuário.
-- 
-- Data: 26 de novembro de 2025
-- Descrição: Sessões parciais são gravadas quando o usuário clica em
--            "Cancelar" durante uma pausa, armazenando o tempo decorrido.

-- 1. Adicionar coluna 'parcial' (não-destrutivo, padrão false)
ALTER TABLE public.historico_usuario
ADD COLUMN IF NOT EXISTS parcial boolean NOT NULL DEFAULT false;

-- =====================================================
-- POLÍTICAS RLS (Row Level Security)
-- =====================================================
-- 
-- Se você quer que o app funcione SEM autenticação (acesso público),
-- descomente as policies abaixo. CUIDADO: isso tornará a tabela legível
-- e inserível por qualquer cliente que use a anon key.
-- 
-- Se preferir manter privacidade, NÃO descomente estas policies.
-- Em vez disso, implemente autenticação no app.

-- Habilitar RLS na tabela (se ainda não estiver habilitado)
-- ALTER TABLE public.historico_usuario ENABLE ROW LEVEL SECURITY;

-- Permitir SELECT público (ler todas as sessões)
-- CREATE POLICY public_select_historico
-- ON public.historico_usuario
-- FOR SELECT
-- USING (true);

-- Permitir INSERT público (criar novas sessões)
-- CREATE POLICY public_insert_historico
-- ON public.historico_usuario
-- FOR INSERT
-- WITH CHECK (true);

-- =====================================================
-- COMO APLICAR ESTA MIGRAÇÃO
-- =====================================================
-- 
-- 1. Acesse o Supabase Console: https://app.supabase.com
-- 2. Selecione seu projeto (appZenBreak)
-- 3. Vá para "SQL Editor" no menu esquerdo
-- 4. Clique em "+ New Query"
-- 5. Cole o comando ALTER TABLE acima (linhas 14-16)
-- 6. Clique em "Run"
-- 
-- (Opcional) Se quiser permitir acesso público:
-- 7. Cole as policies comentadas acima (descomente-as)
-- 8. Clique em "Run"
-- 
-- Pronto! A coluna será criada e as policies estarão habilitadas.
