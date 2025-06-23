-- ####################################################################
-- # Script de Inserção de Dados (DML) para o Banco de Dados Instagram
-- # Disciplina: Fundamentos de Bancos de Dados
-- # Alunos: Guilherme Cirumbolo e Pedro Alles
-- ####################################################################

-- A ordem das inserções respeita as dependências de chaves estrangeiras.

-- ====================================================================
-- Inserir 10 Usuários e seus respectivos Perfis
-- ====================================================================

-- Inserindo os usuários na tabela Usuario
-- A senha 'senha123' é apenas um exemplo.
INSERT INTO Usuario (username, email, senha, nascimento) VALUES
('f1', 'contato@formula1.com', 'senha123', '1950-05-13'),
('charles_leclerc', 'lec@ferrari.com', 'senha123', '1997-10-16'),
('max_verstappen', 'ver@redbull.com', 'senha123', '1997-09-30'),
('lewis_hamilton', 'ham@ferrari.com', 'senha123', '1985-01-07'),
('lando_norris', 'nor@mclaren.com', 'senha123', '1999-11-13'),
('oscar_piastri', 'pia@mclaren.com', 'senha123', '2001-04-06'),
('bruno_costa', 'bruno.costa@email.com', 'senha123', '2001-03-15'),
('alan_turing', 'turing@bletchleypark.uk', 'senha123', '1912-06-23'),
('albert_einstein', 'einstein@princeton.edu', 'senha123', '1879-03-14'),
('stephen_hawking', 'hawking@cam.ac.uk', 'senha123', '1942-01-08');

-- Inserindo os perfis correspondentes
-- O id_usuario deve corresponder à ordem de inserção na tabela Usuario (1 a 10)
INSERT INTO Perfil (id_usuario, foto, descricao) VALUES
(1, 'https://example.com/f1.jpg', 'FORMULA 1®. It''s All To Drive For!'),
(2, 'https://example.com/leclerc.jpg', 'F1 Driver for Scuderia Ferrari.'),
(3, 'https://example.com/verstappen.jpg', 'F1 Driver for Red Bull Racing.'),
(4, 'https://example.com/hamilton.jpg', '7-Time F1 World Champion.'),
(5, 'https://example.com/norris.jpg', 'F1 Driver for McLaren.'),
(6, 'https://example.com/piastri.jpg', 'F1 Driver for McLaren.'),
(7, NULL, 'Programador front-end.'),
(8, 'https://example.com/turing.jpg', 'Pai da computação e decifrador de códigos.'),
(9, 'https://example.com/einstein.jpg', 'Físico teórico. E=mc²'),
(10, 'https://example.com/hawking.jpg', 'Físico teórico, cosmólogo e autor de best-sellers.');

-- ====================================================================
-- Inserir Localizações e Hashtags
-- ====================================================================

-- Inserindo localizações diversas
INSERT INTO Localizacao (nome) VALUES
('Monaco, Monaco'),
('Silverstone, UK'),
('Princeton, USA'),
('Cambridge, UK'),
('Bletchley Park, UK'),
('Maranello, Italy'),
('Autódromo de Interlagos, Brazil'),
('Melbourne, Australia'),
('Berlin, Germany');

-- Inserindo hashtags diversas
INSERT INTO Hashtag (texto) VALUES
('F1'),
('Formula1'),
('ScuderiaFerrari'),
('MercedesAMGF1'),
('RedBullRacing'),
('McLaren'),
('Physics'),
('ComputerScience'),
('Relativity'),
('BlackHole'),
('Enigma'),
('TBT');

-- ====================================================================
-- Inserir Mídias (Fotos e Vídeos)
-- ====================================================================

-- Inserindo na tabela Mídia genérica primeiro
INSERT INTO Midia (uri_media) VALUES
('https://example.com/media/01.jpg'), ('https://example.com/media/02.jpg'),
('https://example.com/media/03.jpg'), ('https://example.com/media/04.mp4'),
('https://example.com/media/05.jpg'), ('https://example.com/media/06.mp4'),
('https://example.com/media/07.jpg'), ('https://example.com/media/08.jpg'),
('https://example.com/media/09.jpg'), ('https://example.com/media/10.jpg'),
('https://example.com/media/11.mp4'), ('https://example.com/media/12.jpg'),
('https://example.com/media/13.jpg'), ('https://example.com/media/14.jpg'),
('https://example.com/media/15.mp4');

-- Inserindo nas tabelas especializadas (Foto e Vídeo)
-- Fotos
INSERT INTO Foto (id_media, formato) VALUES
(1, 'JPG'), (2, 'JPG'), (3, 'PNG'), (5, 'JPG'), (7, 'JPG'),
(8, 'PNG'), (9, 'JPG'), (10, 'JPG'), (12, 'JPG'), (13, 'JPG'), (14, 'PNG');

-- Vídeos
INSERT INTO Video (id_media, duracao_segundos) VALUES
(4, 58), (6, 123), (11, 32), (15, 88);


-- ====================================================================
-- Inserir Postagens
-- ====================================================================

INSERT INTO Postagem (url_post, legenda, data_publicacao, id_perfil, id_local, id_media) VALUES
('/post/001', 'Race week in Monaco!', '2024-05-20 10:00:00', 1, 1, 1),
('/post/002', 'Pole position! Great job from the team.', '2024-05-25 18:00:00', 2, 1, 2),
('/post/003', 'A beautiful day in Maranello.', '2024-04-10 15:20:00', 2, 6, 3),
('/post/004', 'Onboard lap at Silverstone.', '2024-07-05 11:30:00', 4, 2, 4),
('/post/005', 'Back to Bletchley Park. Where it all began.', '2023-09-01 12:00:00', 8, 5, 5),
('/post/006', 'A quick overview of the Enigma machine.', '2023-09-02 14:00:00', 8, 5, 6),
('/post/007', 'Thinking about the universe.', '2021-01-08 18:45:00', 10, 4, 7),
('/post/008', 'The theory of general relativity, summarized.', '2020-11-25 09:12:00', 9, 3, 8),
('/post/009', 'Throwback to winning my first championship!', '2023-11-15 13:00:00', 3, 7, 9),
('/post/010', 'Just a regular day at the office.', '2024-06-15 16:25:00', 7, NULL, 10),
('/post/011', 'Funny moments from the last race.', '2024-06-01 20:00:00', 5, NULL, 11),
('/post/012', 'Podium finish! So happy for the team.', '2024-07-07 17:00:00', 6, 2, 12),
('/post/013', 'A thought on spacetime.', '1947-03-10 11:00:00', 9, 9, 13),
('/post/014', 'Another great season starts!', '2024-03-02 08:00:00', 1, 8, 14),
('/post/015', 'What is a black hole?', '2022-05-20 22:10:00', 10, 4, 15);


-- ====================================================================
-- Popular a relação Seguir
-- ====================================================================

-- id_seguidor, id_seguido
INSERT INTO Seguir (id_seguidor, id_seguido) VALUES
-- Pilotos seguindo a F1
(2, 1), (3, 1), (4, 1), (5, 1), (6, 1),
-- F1 seguindo os pilotos
(1, 2), (1, 3), (1, 4), (1, 5), (1, 6),
-- Relações entre pilotos
(5, 6), (6, 5), -- Colegas de equipe
(2, 3), -- Rivais
(5, 4), -- Admiração
-- Cientistas seguindo-se
(8, 9), (8, 10),
(9, 8), (9, 10),
(10, 8), (10, 9),
-- Programador seguindo o cientista da computação
(7, 8),
-- Relação cruzada
(4, 10); -- Lewis Hamilton segue Stephen Hawking


-- ====================================================================
-- Popular as Curtidas
-- ====================================================================

-- id_perfil, id_postagem
INSERT INTO Curtida (id_perfil, id_postagem) VALUES
-- Post 1 (by F1) - Popular
(2, 1), (3, 1), (4, 1), (5, 1), (6, 1), (7, 1),
-- Post 2 (by Leclerc) - Rival e colega curtem
(3, 2), (6, 2), (1, 2),
-- Post 4 (by Hamilton) - Outros pilotos curtem
(2, 4), (3, 4), (5, 4), (6, 4),
-- Post 5 (by Turing) - Cientistas e programador curtem
(7, 5), (9, 5), (10, 5),
-- Post 8 (by Einstein) - Muito popular
(2, 8), (4, 8), (7, 8), (8, 8), (10, 8),
-- Post 9 (by Verstappen) - Popular entre pilotos
(2, 9), (4, 9), (5, 9), (6, 9),
-- Post 10 (by Bruno) - Pouco popular
(6, 10),
-- Post 12 (by Piastri) - Companheiro de equipe curte
(5, 12), (1, 12),
-- Post 14 (by F1) - Curtido por todos os pilotos para o teste da consulta TODOS
(2, 14), (3, 14), (4, 14), (5, 14), (6, 14),
-- Post 15 (by Hawking) - Cientistas curtem
(8, 15), (9, 15);


-- ====================================================================
-- Popular os Comentários
-- ====================================================================

-- id_perfil, id_postagem, texto
INSERT INTO Comentario (id_perfil, id_postagem, texto) VALUES
-- Conversas em posts
(3, 2, 'Good lap.'),
(5, 2, 'Forza Ferrari!'),
(7, 5, 'The foundation of everything I do! Incredible.'),
(9, 5, 'A fascinating machine. It changed the course of history.'),
(10, 8, 'A revolutionary idea that reshaped our understanding of the cosmos.'),
(5, 11, 'lol I remember that!'),
(6, 11, 'Hahaha, good times.'),
(1, 12, 'Congratulations on the podium, Oscar!'),
(8, 13, 'Indeed. The fabric of reality is a curious thing.'),
(4, 3, 'Bella macchina!');


-- ====================================================================
-- Popular a Postagem_Hashtag
-- ====================================================================

-- id_postagem, id_hashtag
INSERT INTO Postagem_Hashtag (id_postagem, id_hashtag) VALUES
-- Post 1: F1 (1), Formula1 (2)
(1, 1), (1, 2),
-- Post 2: F1 (1), ScuderiaFerrari (3)
(2, 1), (2, 3),
-- Post 3: ScuderiaFerrari (3)
(3, 3),
-- Post 4: F1 (1), MercedesAMGF1 (4)
(4, 1), (4, 4),
-- Post 5: ComputerScience (8), Enigma (11), TBT (12)
(5, 8), (5, 11), (5, 12),
-- Post 6: ComputerScience (8), Enigma (11)
(6, 8), (6, 11),
-- Post 7: Physics (7), BlackHole (10)
(7, 7), (7, 10),
-- Post 8: Physics (7), Relativity (9)
(8, 7), (8, 9),
-- Post 9: F1 (1), RedBullRacing (5), TBT (12)
(9, 1), (9, 5), (9, 12),
-- Post 11: F1 (1), McLaren (6)
(11, 1), (11, 6),
-- Post 12: F1 (1), McLaren (6)
(12, 1), (12, 6),
-- Post 13: Physics (7), Relativity (9)
(13, 7), (13, 9),
-- Post 14: F1 (1), Formula1 (2)
(14, 1), (14, 2),
-- Post 15: Physics (7), BlackHole (10)
(15, 7), (15, 10);