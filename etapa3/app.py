# -*- coding: utf-8 -*-

# ####################################################################
# # Programa de Acesso ao Banco de Dados Instagram
# # Disciplina: Fundamentos de Bancos de Dados
# # Alunos: Guilherme Cirumbolo e Pedro Alles
# ####################################################################

import psycopg2
import sys

# --- CONFIGURAÇÃO DA CONEXÃO COM O BANCO DE DADOS ---
#  comando docker para criacao de imagem:
# docker run --name postgres-db -v postgres-db:/var/lib/postgresql/data -e POSTGRES_PASSWORD=fundamentos -e POSTGRES_USER=postgres -e POSTGRES_DB=postgres -p 5432:5432 -d postgres:latest
DB_CONFIG = {
    "dbname": "postgres",
    "user": "postgres",
    "password": "fundamentos",
    "host": "localhost",
    "port": "5432"
}

# --- DEFINIÇÃO DAS CONSULTAS SQL ---
# Armazenar as consultas em um dicionário facilita a organização e chamada.
QUERIES = {
    1: "SELECT legenda, data_publicacao, autor_username FROM v_postagens_detalhadas ORDER BY data_publicacao DESC LIMIT 5;",
    2: "SELECT legenda, data_publicacao FROM v_postagens_detalhadas WHERE autor_username = %s;",
    3: "SELECT h.texto AS hashtag, COUNT(ph.id_postagem) AS numero_de_utilizacoes FROM Hashtag h JOIN Postagem_Hashtag ph ON h.id_hashtag = ph.id_hashtag GROUP BY h.texto ORDER BY numero_de_utilizacoes DESC;",
    4: "SELECT u.username AS perfil, COUNT(s.id_seguidor) AS numero_de_seguidores FROM Seguir s JOIN Perfil p ON s.id_seguido = p.id_usuario JOIN Usuario u ON p.id_usuario = u.id_usuario GROUP BY u.username ORDER BY numero_de_seguidores DESC;",
    5: "SELECT u.username AS autor, COUNT(p.id_postagem) AS total_postagens FROM Usuario u JOIN Postagem p ON u.id_usuario = p.id_perfil GROUP BY u.username HAVING COUNT(p.id_postagem) > 1 ORDER BY total_postagens DESC;",
    6: "SELECT username FROM Usuario WHERE id_usuario NOT IN (SELECT DISTINCT id_perfil FROM Postagem);",
    7: "SELECT p.legenda, COUNT(c.id_perfil) AS total_curtidas FROM Postagem p JOIN Curtida c ON p.id_postagem = c.id_postagem GROUP BY p.id_postagem, p.legenda HAVING COUNT(c.id_perfil) = (SELECT MAX(contagens.total) FROM (SELECT COUNT(id_postagem) AS total FROM Curtida GROUP BY id_postagem) AS contagens);",
    8: "SELECT u.username AS super_fa FROM Usuario u JOIN Curtida c ON u.id_usuario = c.id_perfil WHERE c.id_postagem IN (SELECT id_postagem FROM Postagem WHERE id_perfil = (SELECT id_usuario FROM Usuario WHERE username = 'f1')) GROUP BY u.username HAVING COUNT(DISTINCT c.id_postagem) = (SELECT COUNT(*) FROM Postagem WHERE id_perfil = (SELECT id_usuario FROM Usuario WHERE username = 'f1'));",
    9: "SELECT u.username AS comentarista, c.texto, c.data_comentario FROM Comentario c JOIN Usuario u ON c.id_perfil = u.id_usuario WHERE c.id_postagem = %s ORDER BY c.data_comentario ASC;",
    10: "SELECT u.username, CASE WHEN f.id_media IS NOT NULL THEN 'Foto' WHEN v.id_media IS NOT NULL THEN 'Vídeo' END AS tipo_media, COUNT(*) AS quantidade FROM Postagem p JOIN Usuario u ON p.id_perfil = u.id_usuario LEFT JOIN Foto f ON p.id_media = f.id_media LEFT JOIN Video v ON p.id_media = v.id_media GROUP BY u.username, tipo_media ORDER BY u.username, tipo_media;"
}

# ====================================================================
# 1. ESTABELECENDO A CONEXÃO COM O BANCO DE DADOS
# ====================================================================
def conectar_banco(config):
    conn = None
    try:
        print("A conectar-se à base de dados PostgreSQL...")
        conn = psycopg2.connect(**config)
        print("Conexão bem-sucedida!")
        return conn
    except psycopg2.OperationalError as e:
        print(f"Erro ao conectar-se: {e}", file=sys.stderr)
        return None

# ====================================================================
# 2. PREPARANDO E ENVIANDO CONSULTAS (COM E SEM PARÂMETROS)
# ====================================================================
def executar_consulta(conn, sql, params=None, fetch=True):
    try:
        # O 'with conn.cursor()' garante que o cursor seja fechado
        # automaticamente no final do bloco, liberando recursos.
        with conn.cursor() as cur:
            # cur.execute é o comando que envia o SQL e os parâmetros
            # para o banco de dados.
            cur.execute(sql, params)
            
            # Se a consulta for do tipo SELECT (fetch=True), processamos o retorno.
            if fetch:
                # cur.description contém metadados sobre as colunas do resultado.
                # Usamos isso para obter os nomes das colunas.
                if cur.description is None:
                    return [], []
                colunas = [desc[0] for desc in cur.description]
                
                # cur.fetchall() busca todas as linhas do resultado da consulta
                # e as retorna como uma lista de tuplas.
                resultados = cur.fetchall()
                return resultados, colunas
            
            return None, None # Para INSERT/UPDATE sem retorno
            
    except psycopg2.Error as e:
        # Em caso de erro na execução do SQL (ex: violação de chave primária),
        # a exceção é capturada, uma mensagem é exibida, e a transação
        # é revertida com conn.rollback() para manter a consistência do banco.
        print(f"Erro ao executar o comando: {e}", file=sys.stderr)
        conn.rollback()
        return None, None

# ====================================================================
# 3. PROCESSANDO O RETORNO DAS CONSULTAS
# ====================================================================
def exibir_resultados(resultados, colunas):
    """
    Recebe os resultados (lista de tuplas) e os nomes das colunas
    e os imprime em um formato de tabela legível no console.
    """
    if resultados is None:
        return
    
    if not resultados:
        print("\nNenhum resultado encontrado.")
        return

    # Imprime o cabeçalho da tabela
    print("\n--- RESULTADOS ---")
    print(" | ".join(colunas))
    # Cria uma linha separadora dinâmica baseada no tamanho dos nomes das colunas
    print("-" * (sum(len(str(c)) for c in colunas) + 3 * len(colunas)))

    # Itera sobre cada linha (tupla) nos resultados e a imprime
    for linha in resultados:
        print(" | ".join(str(item) for item in linha))
    print("------------------")

# ====================================================================
# 4. DISPARANDO O GATILHO E CONFIRMANDO SEU EFEITO
# ====================================================================
def demonstrar_gatilho(conn):
    """
    Demonstra o funcionamento do gatilho de atualização de atividade.
    """
    print("\n--- DEMONSTRAÇÃO DO GATILHO ---")
    username = input("Digite o username de um usuário para testar (ex: bruno_costa): ")
    
    sql_get_id = "SELECT id_usuario FROM Usuario WHERE username = %s;"
    resultados, _ = executar_consulta(conn, sql_get_id, (username,))
    if not resultados:
        print("Usuário não encontrado.")
        return
    user_id = resultados[0][0]

    # Passo 1: Mostra o estado ANTES da ação
    print(f"\n1. Verificando a última atividade de '{username}' ANTES da ação...")
    sql_get_atividade = "SELECT data_ultima_atividade FROM Perfil WHERE id_usuario = %s;"
    resultados, colunas = executar_consulta(conn, sql_get_atividade, (user_id,))
    exibir_resultados(resultados, colunas)

    # Passo 2: Executa a ação que dispara o gatilho
    try:
        post_id_para_curtir = int(input("\nDigite o ID de uma postagem para o usuário curtir (ex: 1): "))
        print(f"\n2. Executando a ação: '{username}' vai curtir a postagem {post_id_para_curtir}...")
        
        # O comando INSERT é enviado para o banco. Isso fará com que o gatilho
        # 'trg_atividade_curtida' seja disparado no SGBD.
        sql_insert_curtida = "INSERT INTO Curtida (id_perfil, id_postagem) VALUES (%s, %s);"
        executar_consulta(conn, sql_insert_curtida, (user_id, post_id_para_curtir), fetch=False)
        
        # Passo 3: Confirmação da Transação (COMMIT)
        # Por padrão, o psycopg2 inicia uma transação. Nenhuma alteração
        # (INSERT, UPDATE, DELETE) é salva permanentemente até que
        # conn.commit() seja chamado. Isso confirma a transação.
        conn.commit()
        print("Ação executada e transação confirmada (commit). O gatilho foi disparado no banco de dados.")

    except ValueError:
        print("ID da postagem inválido. A demonstração foi abortada.")
        return
    except psycopg2.Error as e:
        print("Não foi possível inserir a curtida. Verifique se o usuário já curtiu esta postagem.")
        return

    # Passo 4: Mostra o estado DEPOIS da ação, provando o efeito do gatilho.
    print(f"\n3. Verificando a última atividade de '{username}' DEPOIS da ação...")
    resultados, colunas = executar_consulta(conn, sql_get_atividade, (user_id,))
    exibir_resultados(resultados, colunas)
    print("\nObserve como a data/hora da última atividade foi atualizada pelo gatilho.")

# --- Interface Principal do Programa ---
def mostrar_menu():
    """Exibe o menu de opções."""
    print("\n--- MENU DE OPÇÕES ---")
    print("1. Listar as 5 postagens mais recentes.")
    print("2. Encontrar postagens de um autor (PARAMETRIZADA).")
    print("3. Contar utilizações de cada hashtag.")
    print("4. Calcular seguidores de cada perfil.")
    print("5. Identificar autores com mais de uma postagem.")
    print("6. Listar usuários que nunca postaram.")
    print("7. Encontrar a postagem com mais curtidas.")
    print("8. Identificar 'super fãs' do perfil 'f1'.")
    print("9. Listar comentários de uma postagem (PARAMETRIZADA).")
    print("10. Mostrar resumo de tipo de conteúdo por usuário.")
    print("\n11. Demonstrar funcionamento do gatilho de atividade.")
    print("\n0. Sair do programa.")

def main():
    """Função principal que gerencia o fluxo da aplicação."""
    print("Bem-vindo ao programa de gerenciamento do banco de dados do Instagram!")
    
    conn = None
    try:
        conn = conectar_banco(DB_CONFIG)
        if conn is None:
            sys.exit(1)

        while True:
            mostrar_menu()
            try:
                escolha = int(input("\nDigite o número da sua escolha: "))
                
                if escolha == 0:
                    break
                
                elif 1 <= escolha <= 10:
                    params = None
                    # Para as consultas parametrizadas, solicita a entrada do usuário.
                    if escolha == 2:
                        username = input("Digite o username do autor: ")
                        params = (username,) # Parâmetros devem ser uma tupla
                    elif escolha == 9:
                        try:
                            post_id = int(input("Digite o ID da postagem: "))
                            params = (post_id,)
                        except ValueError:
                            print("ID da postagem inválido. Deve ser um número.")
                            continue

                    sql = QUERIES.get(escolha)
                    resultados, colunas = executar_consulta(conn, sql, params)
                    exibir_resultados(resultados, colunas)

                elif escolha == 11:
                    demonstrar_gatilho(conn)
                else:
                    print("\nOpção inválida. Por favor, tente novamente.")

            except ValueError:
                print("\nEntrada inválida. Por favor, digite um número.")
            
            input("\nPressione Enter para continuar...")

    finally:
        # O bloco 'finally' garante que a conexão seja sempre fechada
        # ao final do programa, mesmo que ocorram erros.
        if conn is not None:
            conn.close()
            print("\nConexão com o banco de dados fechada. Adeus!")

if __name__ == "__main__":
    main()
