Hemoce - Sistema de Gestão de Doações de Sangue
Descrição
Este repositório contém o código SQL para a criação de um banco de dados para gestão de doações de sangue, envolvendo doadores, centros de doação, profissionais, entrevistas, doações e o estoque de sangue. O sistema também inclui funções, triggers e procedimentos armazenados para garantir a integridade dos dados, otimizar o processo de doação e realizar manutenção no banco de dados.

Pré-requisitos
PostgreSQL instalado.
Acesso ao terminal do banco de dados.
Acesso com privilégios administrativos para criar banco de dados, usuários e roles.
Passo a Passo
1. Criação do Banco de Dados
Crie o banco de dados hemoce:

CREATE DATABASE hemoce;
2. Criação do Usuário e Roles
Crie o usuário victor_oliveira com a senha 12345:


CREATE USER victor_oliveira WITH ENCRYPTED PASSWORD '12345';
Crie a role desenvolvedor e atribua permissões:

sql
Copiar
Editar
CREATE ROLE desenvolvedor;
GRANT desenvolvedor TO victor_oliveira;
Conceda permissões ao usuário para o banco de dados e tabelas:


GRANT CONNECT ON DATABASE hemoce TO desenvolvedor;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO desenvolvedor;
ALTER ROLE desenvolvedor LOGIN;
3. Criação das Tabelas
As seguintes tabelas serão criadas para armazenar dados sobre doadores, centros de doação, profissionais, entrevistas e doações:

Tabelas Principais:
Doadores: Armazena informações sobre os doadores.

CREATE TABLE IF NOT EXISTS Doadores (
    doador_id serial PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cpf VARCHAR(14) NOT NULL UNIQUE,
    telefone VARCHAR(20) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    tipo_sangue CHAR(3) NOT NULL,
    data_ultima_doacao DATE,
    quantidade_doacoes INTEGER
);
Endereço dos Doadores: Relaciona os doadores aos seus respectivos endereços.

CREATE TABLE IF NOT EXISTS Endereco_doadores (
    endereco_id serial PRIMARY KEY,
    doador_id INTEGER NOT NULL,
    estado CHAR(2) NOT NULL,
    cidade VARCHAR(50) NOT NULL,
    rua VARCHAR(100) NOT NULL,
    numero VARCHAR(10),
    complemento VARCHAR(50),
    FOREIGN KEY(doador_id) REFERENCES Doadores(doador_id) ON DELETE CASCADE
);
Profissionais: Contém informações sobre os profissionais de saúde responsáveis pelas doações.

CREATE TABLE IF NOT EXISTS Profissionais (
    profissional_id serial PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    registro_profissional VARCHAR(30) NOT NULL UNIQUE
);
Centros de Doação: Armazena dados sobre os centros onde as doações acontecem.

CREATE TABLE IF NOT EXISTS centro_doacao (
    centro_id serial PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    quantidade_max_dia INTEGER DEFAULT 140,
    qnt_profissionais_permitidos INTEGER DEFAULT 20,
    profissionais_contratados INTEGER,
    n_doacoes_realizadas_dia INTEGER
);
Entrevistas: Contém informações sobre a entrevista realizada com o doador, verificando sua aptidão para doar sangue.

CREATE TABLE IF NOT EXISTS entrevista (
    entrevista_id serial PRIMARY KEY,
    doador_id INTEGER NOT NULL,
    tem_doencas_diabetes BOOLEAN NOT NULL,
    ja_teve_ist BOOLEAN NOT NULL,
    qnt_parceiros_sexuais INTEGER NOT NULL,
    data_entrevista TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    tatto_6_meses BOOLEAN NOT NULL,
    piercing_6_meses BOOLEAN NOT NULL,
    apto VARCHAR(20) CHECK(apto IN ('aprovado', 'reprovado')),
    FOREIGN KEY(doador_id) REFERENCES doadores(doador_id) ON DELETE CASCADE
);
Doações: Contém os registros das doações feitas pelos doadores.

CREATE TABLE IF NOT EXISTS doacao (
    doacao_id serial PRIMARY KEY,
    centro_id INTEGER NOT NULL,
    entrevista_id INTEGER NOT NULL,
    profissional_id INTEGER NOT NULL,
    data_doacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    qnt_doada_ml DECIMAL(10,2) DEFAULT 450.00,
    FOREIGN KEY(centro_id) REFERENCES centro_doacao(centro_id) ON DELETE CASCADE,
    FOREIGN KEY(entrevista_id) REFERENCES entrevista(entrevista_id) ON DELETE CASCADE,
    FOREIGN KEY(profissional_id) REFERENCES profissionais(profissional_id) ON DELETE CASCADE
);
Estoque de Sangue: Armazena a quantidade de bolsas de sangue disponíveis em cada centro de doação.

CREATE TABLE IF NOT EXISTS estoque_sangue (
    estoque_id serial PRIMARY KEY,
    centro_id INTEGER NOT NULL,
    tipo_sangue CHAR(3) CHECK(tipo_sangue IN ('A+', 'B+', 'AB+', 'A-', 'B-', 'AB-', 'O+', 'O-')) NOT NULL,
    qnt_bolsas INTEGER,
    FOREIGN KEY(centro_id) REFERENCES centro_doacao(centro_id) ON DELETE CASCADE
);
4. Procedimentos Armazenados
Criação de procedimentos para inserção de dados nas tabelas. Exemplos de procedimentos:

Inserção de Entrevista: Insere informações de entrevista e determina a aptidão do doador.

CREATE OR REPLACE PROCEDURE insert_entrevista( ... );
Inserção de Doador: Insere um novo doador e o seu endereço associado.

CREATE OR REPLACE PROCEDURE insert_doador( ... );
Realizar Doação: Registra uma doação realizada.

CREATE OR REPLACE PROCEDURE realizar_doacao( ... );
5. Triggers
A seguir, são criadas triggers para automatizar certas ações, como atualizar os dados após uma doação ou alterar o estoque de sangue:

Trigger para verificação da aptidão do doador:

CREATE OR REPLACE FUNCTION verificar_doacao_apto() RETURNS TRIGGER AS $$ ... $$;
CREATE TRIGGER trigger_verificar_apto_do_doador BEFORE INSERT ON doacao FOR EACH ROW EXECUTE FUNCTION verificar_doacao_apto();
Trigger para atualizar o estoque de sangue:

CREATE OR REPLACE FUNCTION incrementar_estoque_sangue() RETURNS TRIGGER AS $$ ... $$;
CREATE TRIGGER trigger_incrementar_estoque_sangue AFTER INSERT ON doacao FOR EACH ROW EXECUTE FUNCTION incrementar_estoque_sangue();
Trigger para atualizar dados do doador após a doação:

CREATE OR REPLACE FUNCTION atualizar_dados_doadores() RETURNS TRIGGER AS $$ ... $$;
CREATE TRIGGER atualizar_doador_apos_doacao AFTER INSERT ON doacao FOR EACH ROW EXECUTE FUNCTION atualizar_dados_doadores();
6. Backup e Manutenção
Agendamento de backup e manutenção periódica usando cron:

Backup Completo:

pg_dump -U postgres -h localhost -p 5432 -F c -b -v -f hemoce_backup.dump hemoce
Agendar o Backup Diariamente às 10h:

0 10 * * * pg_dump -U postgres -h localhost -p 5432 -F c -b -v -f /home/victor_oliveira/backups/hemoce_backup_$(date +%Y%m%d).dump hemoce
Usar o Vacuum Analyze para Otimização:

0 10 * * * psql -U postgres -h localhost -p 5432 -d hemoce -c "VACUUM ANALYZE"
