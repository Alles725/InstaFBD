-- ####################################################################
-- # Script de Visão e Consultas (SQL) para o Banco de Dados Instagram
-- # Disciplina: Fundamentos de Bancos de Dados
-- ####################################################################


-- ####################################################################
-- # Definição da Visão
-- ####################################################################

-- ENUNCIADO DA VISÃO:
-- Nome: v_postagens_detalhadas
-- Descrição: Esta visão foi criada para fornecer uma perspectiva consolidada e de fácil
-- acesso sobre cada postagem. Ela une as tabelas Postagem, Perfil e Usuario para
-- exibir, em uma única consulta, os detalhes essenciais da postagem (como id, legenda
-- e data), o nome de usuário (username) do autor e a descrição do seu perfil. A sua
-- principal utilidade é eliminar a necessidade de realizar junções repetitivas dessas
-- três tabelas em consultas frequentes, simplificando a análise de conteúdo e autoria.
--
CREATE VIEW v_postagens_detalhadas AS
SELECT
    p.id_postagem,
    p.legenda,
    p.data_publicacao,
    u.username AS autor_username,
    pr.descricao AS autor_descricao,
    p.id_perfil AS autor_id_perfil
FROM
    Postagem p
JOIN
    Perfil pr ON p.id_perfil = pr.id_usuario
JOIN
    Usuario u ON pr.id_usuario = u.id_usuario;


-- ####################################################################
-- # Elaboração das 10 Consultas
-- ####################################################################

-- ====================================================================
-- Primeira consulta utilizando a VISÃO
-- ====================================================================
-- ENUNCIADO: Listar as 5 postagens mais recentes da plataforma, mostrando a legenda, a data de publicação e o nome de usuário do autor.
-- A consulta demonstra a utilidade da visão para acessar rapidamente informações combinadas de postagens e seus autores.

SELECT
    legenda,
    data_publicacao,
    autor_username
FROM
    v_postagens_detalhadas
ORDER BY
    data_publicacao DESC
LIMIT 5;


-- ====================================================================
-- Segunda consulta utilizando a VISÃO
-- ====================================================================
-- ENUNCIADO: Encontrar todas as postagens feitas pelo autor com nome de usuário 'alan_turing', mostrando a legenda e a data de cada postagem.
-- Esta consulta mostra como a visão simplifica a busca por todas as publicações de um autor específico.

SELECT
    legenda,
    data_publicacao
FROM
    v_postagens_detalhadas
WHERE
    autor_username = 'alan_turing';


-- ====================================================================
-- Consulta com GROUP BY
-- ====================================================================
-- ENUNCIADO: Contar o número de vezes que cada hashtag foi utilizada nas postagens, listando as mais populares primeiro.
-- Esta consulta é útil para identificar os tópicos mais discutidos na plataforma.

SELECT
    h.texto AS hashtag,
    COUNT(ph.id_postagem) AS numero_de_utilizacoes
FROM
    Hashtag h
JOIN
    Postagem_Hashtag ph ON h.id_hashtag = ph.id_hashtag
GROUP BY
    h.texto
ORDER BY
    numero_de_utilizacoes DESC;


-- ====================================================================
-- Outra consulta com GROUP BY
-- ====================================================================
-- ENUNCIADO: Calcular o número de seguidores de cada perfil, exibindo o nome de usuário e a contagem. Listar os perfis com mais seguidores primeiro.
-- Esta consulta ajuda a identificar os usuários mais influentes da plataforma.

SELECT
    u.username AS perfil,
    COUNT(s.id_seguidor) AS numero_de_seguidores
FROM
    Seguir s
JOIN
    Perfil p ON s.id_seguido = p.id_usuario
JOIN
    Usuario u ON p.id_usuario = u.id_usuario
GROUP BY
    u.username
ORDER BY
    numero_de_seguidores DESC;


-- ====================================================================
-- Consulta com GROUP BY e HAVING
-- ====================================================================
-- ENUNCIADO: Identificar os autores mais ativos, listando os nomes de usuário e a quantidade de postagens de todos que publicaram mais de uma vez.
-- O HAVING é necessário para filtrar os grupos com base na contagem de postagens.

SELECT
    u.username AS autor,
    COUNT(p.id_postagem) AS total_postagens
FROM
    Usuario u
JOIN
    Postagem p ON u.id_usuario = p.id_perfil
GROUP BY
    u.username
HAVING
    COUNT(p.id_postagem) > 1
ORDER BY
    total_postagens DESC;


-- ====================================================================
-- Consulta com SUBQUERY
-- ====================================================================
-- ENUNCIADO: Listar todos os usuários que nunca fizeram uma postagem, mostrando o seu username.
-- Esta consulta necessita de uma subquery para primeiro encontrar todos os IDs de usuários que postaram, para depois selecionar aqueles que não estão nessa lista.

SELECT
    username
FROM
    Usuario
WHERE
    id_usuario NOT IN (SELECT DISTINCT id_perfil FROM Postagem);


-- ====================================================================
-- Outra consulta com SUBQUERY
-- ====================================================================
-- ENUNCIADO: Encontrar a postagem (ou postagens) com o maior número de curtidas, exibindo sua legenda e a contagem de curtidas.
-- Esta consulta necessita de uma subquery para primeiro determinar qual é o número máximo de curtidas que uma postagem recebeu, para depois encontrar qual postagem atinge esse valor.

SELECT
    p.legenda,
    COUNT(c.id_perfil) AS total_curtidas
FROM
    Postagem p
JOIN
    Curtida c ON p.id_postagem = c.id_postagem
GROUP BY
    p.id_postagem, p.legenda
HAVING
    COUNT(c.id_perfil) = (
        SELECT MAX(contagens.total)
        FROM (
            SELECT COUNT(id_postagem) AS total
            FROM Curtida
            GROUP BY id_postagem
        ) AS contagens
    );


-- ====================================================================
-- Consulta com TODOS/NENHUM (divisão relacional)
-- ====================================================================
-- ENUNCIADO: Identificar os 'super fãs', que são os utilizadores que curtiram TODAS as publicações feitas pelo perfil 'f1'.
-- Esta consulta demonstra a operação de divisão relacional, verificando se a contagem de posts curtidos por um utilizador é igual ao total de posts do autor alvo.

SELECT
    u.username AS super_fa
FROM
    Usuario u
JOIN
    Curtida c ON u.id_usuario = c.id_perfil
WHERE
    c.id_postagem IN (SELECT id_postagem FROM Postagem WHERE id_perfil = (SELECT id_usuario FROM Usuario WHERE username = 'f1'))
GROUP BY
    u.username
HAVING
    COUNT(DISTINCT c.id_postagem) = (
        SELECT COUNT(*) FROM Postagem WHERE id_perfil = (SELECT id_usuario FROM Usuario WHERE username = 'f1')
    );


-- ====================================================================
-- Consulta Variada
-- ====================================================================
-- ENUNCIADO: Listar todos os comentários de uma postagem específica (a postagem com id 2), exibindo o texto do comentário, a data e o nome de usuário de quem comentou.
-- Esta consulta é útil para visualizar a thread de discussão de uma publicação.

SELECT
    u.username AS comentarista,
    c.texto,
    c.data_comentario
FROM
    Comentario c
JOIN
    Usuario u ON c.id_perfil = u.id_usuario
WHERE
    c.id_postagem = 2
ORDER BY
    c.data_comentario ASC;


-- ====================================================================
-- Outra consulta Variada
-- ====================================================================
-- ENUNCIADO: Mostrar um resumo do tipo de conteúdo que cada utilizador publica, listando o nome de utilizador, o tipo de mídia (Foto ou Vídeo) e a contagem de cada tipo.
-- Esta consulta é útil para entender o comportamento de postagem dos utilizadores.

SELECT
    u.username,
    CASE
        WHEN f.id_media IS NOT NULL THEN 'Foto'
        WHEN v.id_media IS NOT NULL THEN 'Vídeo'
    END AS tipo_media,
    COUNT(*) AS quantidade
FROM
    Postagem p
JOIN
    Usuario u ON p.id_perfil = u.id_usuario
LEFT JOIN
    Foto f ON p.id_media = f.id_media
LEFT JOIN
    Video v ON p.id_media = v.id_media
GROUP BY
    u.username, tipo_media
ORDER BY
    u.username, tipo_media;