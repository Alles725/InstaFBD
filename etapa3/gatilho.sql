-- ####################################################################
-- # Script do Gatilho e Função Armazenada para o Banco de Dados Instagram
-- # Disciplina: Fundamentos de Bancos de Dados
-- # Alunos: Guilherme Cirumbolo e Pedro Alles
-- # SGBD Alvo: PostgreSQL
-- ####################################################################

-- ####################################################################
-- # DESCRIÇÃO
-- ####################################################################
--
-- Este script implementa um mecanismo para rastrear a atividade dos
-- usuários na plataforma.
--
-- Propósito: Manter um registro da data e hora da última vez que um
-- usuário interagiu com o sistema, seja criando uma postagem, fazendo
-- um comentário ou curtindo uma publicação.
--
-- Componentes:
-- 1. ALTER TABLE: Modifica a tabela 'Perfil' para adicionar uma nova
--    coluna chamada 'data_ultima_atividade'.
-- 2. Stored Procedure (Função): 'atualizar_ultima_atividade()' é a
--    função que contém a lógica para atualizar a nova coluna.
-- 3. Triggers (Gatilhos): Três gatilhos que disparam a função
--    automaticamente após inserções nas tabelas 'Postagem',
--    'Comentario' e 'Curtida'.
--
-- ####################################################################


-- PASSO 1: Modificação da Tabela 'Perfil'
-- --------------------------------------------------------------------
-- Adiciona a coluna para rastrear a data e hora da última atividade do perfil.
-- O valor padrão CURRENT_TIMESTAMP é usado para preencher a coluna para
-- os perfis que já existem no banco de dados.

ALTER TABLE Perfil
ADD COLUMN data_ultima_atividade TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP;


-- PASSO 2: Criação da Stored Procedure (Função do Gatilho)
-- --------------------------------------------------------------------
-- Esta função em PL/pgSQL será chamada pelos gatilhos. Sua responsabilidade é
-- atualizar a coluna 'data_ultima_atividade' na tabela 'Perfil'
-- para o perfil que realizou a ação (post, comentário ou curtida).

CREATE OR REPLACE FUNCTION atualizar_ultima_atividade()
RETURNS TRIGGER AS $$
BEGIN
    -- Atualiza a data da última atividade do perfil que realizou a ação.
    -- A coluna NEW.id_perfil existe em Postagem, Comentario e Curtida,
    -- tornando esta função reutilizável para os três gatilhos.
    UPDATE Perfil
    SET data_ultima_atividade = NOW()
    WHERE id_usuario = NEW.id_perfil;

    -- Retorna NEW para indicar que a operação de INSERT original pode continuar.
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


-- PASSO 3: Criação e Vinculação dos Gatilhos
-- --------------------------------------------------------------------
-- Três gatilhos são criados, um para cada tabela de ação do usuário.
-- Cada gatilho é configurado para disparar a função 'atualizar_ultima_atividade()'
-- após uma nova linha ser inserida na respectiva tabela.

-- Gatilho para novas postagens
CREATE TRIGGER trg_atividade_postagem
AFTER INSERT ON Postagem
FOR EACH ROW
EXECUTE FUNCTION atualizar_ultima_atividade();

-- Gatilho para novos comentários
CREATE TRIGGER trg_atividade_comentario
AFTER INSERT ON Comentario
FOR EACH ROW
EXECUTE FUNCTION atualizar_ultima_atividade();

-- Gatilho para novas curtidas
CREATE TRIGGER trg_atividade_curtida
AFTER INSERT ON Curtida
FOR EACH ROW
EXECUTE FUNCTION atualizar_ultima_atividade();
