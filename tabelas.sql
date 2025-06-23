-- ####################################################################
-- # Script de Criação de Tabelas (DDL) para o Banco de Dados Instagram
-- # Disciplina: Fundamentos de Bancos de Dados
-- # Alunos: Guilherme Cirumbolo e Pedro Alles
-- ####################################################################

-- A ordem de criação respeita as dependências de chaves estrangeiras.
-- Tabelas sem dependências são criadas primeiro.

-- Tabela para armazenar os dados dos usuários.
CREATE TABLE Usuario (
    id_usuario SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    senha VARCHAR(255) NOT NULL, -- Armazenar como hash
    nascimento DATE NOT NULL
);

-- Tabela para armazenar localizações geográficas.
CREATE TABLE Localizacao (
    id_local SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL
);

-- Tabela para armazenar as hashtags.
CREATE TABLE Hashtag (
    id_hashtag SERIAL PRIMARY KEY,
    texto VARCHAR(50) UNIQUE NOT NULL
);

-- Tabela para o perfil público dos usuários.
-- O id_usuario é PK e FK, garantindo o relacionamento 1:1 com Usuario.
CREATE TABLE Perfil (
    id_usuario INT PRIMARY KEY,
    foto VARCHAR(255),
    descricao TEXT,
    CONSTRAINT fk_perfil_usuario FOREIGN KEY (id_usuario) REFERENCES Usuario(id_usuario) ON DELETE CASCADE
);

-- Tabela para a superclasse Mídia.
CREATE TABLE Midia (
    id_media SERIAL PRIMARY KEY,
    uri_media VARCHAR(255) NOT NULL
);

-- Tabela para a subclasse Foto, especialização de Mídia.
CREATE TABLE Foto (
    id_media INT PRIMARY KEY,
    formato VARCHAR(10),
    CONSTRAINT fk_foto_midia FOREIGN KEY (id_media) REFERENCES Midia(id_media) ON DELETE CASCADE
);

-- Tabela para a subclasse Vídeo, especialização de Mídia.
CREATE TABLE Video (
    id_media INT PRIMARY KEY,
    duracao_segundos INT,
    CONSTRAINT fk_video_midia FOREIGN KEY (id_media) REFERENCES Midia(id_media) ON DELETE CASCADE
);

-- Tabela principal para as postagens.
CREATE TABLE Postagem (
    id_postagem SERIAL PRIMARY KEY,
    url_post VARCHAR(255) UNIQUE NOT NULL,
    legenda TEXT,
    data_publicacao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    id_perfil INT NOT NULL,
    id_local INT, -- Pode ser nulo
    id_media INT UNIQUE NOT NULL,
    CONSTRAINT fk_postagem_perfil FOREIGN KEY (id_perfil) REFERENCES Perfil(id_usuario) ON DELETE CASCADE,
    CONSTRAINT fk_postagem_localizacao FOREIGN KEY (id_local) REFERENCES Localizacao(id_local) ON DELETE SET NULL,
    CONSTRAINT fk_postagem_midia FOREIGN KEY (id_media) REFERENCES Midia(id_media) ON DELETE RESTRICT
);

-- Tabela para os comentários nas postagens.
CREATE TABLE Comentario (
    id_comentario SERIAL PRIMARY KEY,
    texto TEXT NOT NULL,
    data_comentario TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    id_perfil INT NOT NULL,
    id_postagem INT NOT NULL,
    CONSTRAINT fk_comentario_perfil FOREIGN KEY (id_perfil) REFERENCES Perfil(id_usuario) ON DELETE CASCADE,
    CONSTRAINT fk_comentario_postagem FOREIGN KEY (id_postagem) REFERENCES Postagem(id_postagem) ON DELETE CASCADE
);

-- Tabela associativa para o relacionamento N:M de seguir.
CREATE TABLE Seguir (
    id_seguidor INT NOT NULL,
    id_seguido INT NOT NULL,
    data_seguindo TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_seguidor, id_seguido),
    CONSTRAINT fk_seguir_seguidor FOREIGN KEY (id_seguidor) REFERENCES Perfil(id_usuario) ON DELETE CASCADE,
    CONSTRAINT fk_seguir_seguido FOREIGN KEY (id_seguido) REFERENCES Perfil(id_usuario) ON DELETE CASCADE
);

-- Tabela associativa para o relacionamento N:M de curtidas.
CREATE TABLE Curtida (
    id_perfil INT NOT NULL,
    id_postagem INT NOT NULL,
    data_curtida TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_perfil, id_postagem),
    CONSTRAINT fk_curtida_perfil FOREIGN KEY (id_perfil) REFERENCES Perfil(id_usuario) ON DELETE CASCADE,
    CONSTRAINT fk_curtida_postagem FOREIGN KEY (id_postagem) REFERENCES Postagem(id_postagem) ON DELETE CASCADE
);

-- Tabela associativa para o relacionamento N:M entre Postagem e Hashtag.
CREATE TABLE Postagem_Hashtag (
    id_postagem INT NOT NULL,
    id_hashtag INT NOT NULL,
    PRIMARY KEY (id_postagem, id_hashtag),
    CONSTRAINT fk_postagem_hashtag_postagem FOREIGN KEY (id_postagem) REFERENCES Postagem(id_postagem) ON DELETE CASCADE,
    CONSTRAINT fk_postagem_hashtag_hashtag FOREIGN KEY (id_hashtag) REFERENCES Hashtag(id_hashtag) ON DELETE CASCADE
);
