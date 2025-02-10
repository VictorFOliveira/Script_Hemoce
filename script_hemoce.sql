create database hemoce; 

-- Criando o usuário victor_oliveira com a senha
CREATE USER victor_oliveira WITH ENCRYPTED PASSWORD '12345';

-- Criando o role desenvolvedor
CREATE ROLE desenvolvedor;

-- Atribuindo o role desenvolvedor ao usuário victor_oliveira
GRANT desenvolvedor TO victor_oliveira;

-- Concedendo permissão de conectar no banco de dados 'hemoce' para o role desenvolvedor
GRANT CONNECT ON DATABASE hemoce TO desenvolvedor;

-- Concedendo permissões de SELECT, INSERT, UPDATE, DELETE e LOGIN nas tabelas do esquema public para o role desenvolvedor
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO desenvolvedor;

-- Garantindo que o role desenvolvedor tenha permissão de login
ALTER ROLE desenvolvedor LOGIN;

begin;

create table if not exists Doadores( -- tem procedure
    doador_id serial primary key,
    nome varchar(100) not null,
    cpf varchar(14) not null unique,
    telefone varchar(20) not null,
    email varchar(100) not null unique,
    tipo_sangue char(3) not null,
    data_ultima_doacao date, -- trigger para incrementar // funcionando
    quantidade_doacoes integer  -- trigger para incrementar // funcionando
);

create table if not exists Endereco_doadores( -- tem procedure
    endereco_id serial primary key,
    doador_id integer not null,
    estado char(2) not null,
    cidade varchar(50) not null,
    rua varchar(100) not null,
    numero varchar(10),
    complemento varchar(50),
    foreign key(doador_id) REFERENCES Doadores(doador_id) ON DELETE CASCADE
);

create table if not exists Profissionais(
    profissional_id serial primary key,
    nome varchar(100) not null,
    registro_profissional varchar(30) not null unique
);


create table if not exists profissionais_centros( 
    profissional_id integer not null,
    centro_id integer not null,
    primary key(profissional_id, centro_id), 
    foreign key(profissional_id) REFERENCES profissionais(profissional_id) ON DELETE CASCADE,
    Foreign Key (centro_id) REFERENCES centro_doacao(centro_id)ON DELETE CASCADE

); -- criada trigger 


create table if not exists centro_doacao( -- tem procedure
    centro_id serial primary key,
    nome varchar(100) not null,
    quantidade_max_dia integer default 140,
    qnt_profissionais_permitidos integer default 20,
    profissionais_contratados integer, --trigger // funcionando
    n_doacoes_realizadas_dia integer -- trigger 
);

create table if not exists entrevista( -- tem procedure para insert 
    entrevista_id serial primary key,
    doador_id integer not null,
    tem_doencas_diabetes boolean not null,
    ja_teve_ist boolean not null,
    qnt_parceiros_sexuais integer not null,
    data_entrevista TIMESTAMP default CURRENT_TIMESTAMP,
    tatto_6_meses boolean not null,
    piercing_6_meses boolean not null,
    apto varchar(20) check(apto in('aprovado', 'reprovado')),
    foreign key(doador_id) REFERENCES doadores(doador_id)ON DELETE CASCADE
);

create table if not exists doacao(
    doacao_id serial primary key,
    centro_id integer not null,
    entrevista_id integer not null,
    profissional_id integer not null,
    data_doacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    qnt_doada_ml decimal(10,2) default 450.00,
    foreign key(centro_id) REFERENCES centro_doacao(centro_id) ON DELETE CASCADE,
    foreign key(entrevista_id) REFERENCES entrevista(entrevista_id) ON DELETE CASCADE,
    foreign key(profissional_id) REFERENCES profissionais(profissional_id) ON DELETE CASCADE

);

create table if not exists estoque_sangue( -- trigger para incrementar 
    estoque_id serial primary key,
    centro_id integer not null,
    tipo_sangue char(3) check(tipo_sangue in('A+', 'B+', 'AB+', 'A-','B-','AB-','O+','O-'))not null,
    qnt_bolsas integer,
    foreign key(centro_id) REFERENCES centro_doacao(centro_id) ON DELETE CASCADE
);

commit;

-- inserts serão adicionados com o usuário criado -- 

begin;
-- doadores 
INSERT INTO doadores (nome, cpf, telefone, email, tipo_sangue, data_ultima_doacao, quantidade_doacoes)
VALUES
('João Silva', '123.456.789-00', '(11) 98765-4321', 'joao.silva@email.com', 'O+', '2024-10-15', 5),
('Maria Oliveira', '234.567.890-01', '(21) 91234-5678', 'maria.oliveira@email.com', 'A-', '2023-08-20', 3),
('Pedro Santos', '345.678.901-02', '(31) 93456-7890', 'pedro.santos@email.com', 'B+', '2023-11-10', 2),
('Ana Costa', '456.789.012-03', '(41) 95678-1234', 'ana.costa@email.com', 'AB-', '2022-06-14', 4),
('Lucas Almeida', '567.890.123-04', '(51) 97654-3210', 'lucas.almeida@email.com', 'O-', '2024-01-03', 1),
('Carla Souza', '678.901.234-05', '(61) 96432-1098', 'carla.souza@email.com', 'A+', '2023-05-22', 6),
('Roberto Pereira', '789.012.345-06', '(71) 98321-4321', 'roberto.pereira@email.com', 'B-', '2024-02-10', 7),
('Fernanda Lima', '890.123.456-07', '(81) 99876-5432', 'fernanda.lima@email.com', 'AB+', '2023-09-09', 2),
('Ricardo Martins', '901.234.567-08', '(91) 96543-2109', 'ricardo.martins@email.com', 'O+', '2024-03-15', 3),
('Juliana Rocha', '012.345.678-09', '(11) 97321-6543', 'juliana.rocha@email.com', 'A-', '2023-12-01', 4);

-- endereço dos doadores 
INSERT INTO Endereco_doadores (doador_id, estado, cidade, rua, numero, complemento)
VALUES
(1, 'SP', 'São Paulo', 'Rua da Paz', '123', 'Apto 101'),
(2, 'RJ', 'Rio de Janeiro', 'Avenida Atlântica', '456', 'Bloco B, 2º andar'),
(3, 'MG', 'Belo Horizonte', 'Rua Goiás', '789', 'Casa 3'),
(4, 'PR', 'Curitiba', 'Rua XV de Novembro', '1010', 'Perto do Mercado Municipal'),
(5, 'RS', 'Porto Alegre', 'Avenida Ipiranga', '212', 'Conjunto Residencial'),
(6, 'DF', 'Brasília', 'Setor Comercial Sul', '232', 'Sala 12'),
(7, 'BA', 'Salvador', 'Rua das Palmeiras', '343', 'Casa Verde'),
(8, 'PE', 'Recife', 'Avenida Boa Viagem', '454', 'Prédio Rosa, 5º andar'),
(9, 'PA', 'Belém', 'Travessa 14 de Março', '565', 'Apartamento 204'),
(10, 'CE', 'Fortaleza', 'Rua José de Alencar', '676', 'Casa com quintal');

-- profissionais 
INSERT INTO Profissionais (nome, registro_profissional)
VALUES
('Dr. Ana Silva', '12345-SP'),
('Dr. João Souza', '23456-MG'),
('Dra. Maria Oliveira', '34567-RJ'),
('Dr. Pedro Santos', '45678-PR'),
('Dra. Fernanda Costa', '56789-BA'),
('Dr. Carlos Almeida', '67890-RS'),
('Dra. Beatriz Martins', '78901-DF'),
('Dr. Felipe Pereira', '89012-CE'),
('Dra. Carla Rodrigues', '90123-PE'),
('Dr. Marcos Gomes', '01234-MT');
 
-- centros de doação 
 INSERT INTO centro_doacao (nome, profissionais_contratados, n_doacoes_realizadas_dia)
VALUES
('Centro de Doação São Paulo', 20, 0),
('Centro de Doação Rio de Janeiro', 18, 0),
('Centro de Doação Brasília', 22, 0),
('Centro de Doação Belo Horizonte', 19, 0),
('Centro de Doação Porto Alegre', 17, 0),
('Centro de Doação Salvador', 21, 0),
('Centro de Doação Fortaleza', 16, 0),
('Centro de Doação Curitiba', 23, 0),
('Centro de Doação Recife', 20, 0),
('Centro de Doação Manaus', 15, 0);

-- estoque de sangue
INSERT INTO estoque_sangue (centro_id, tipo_sangue, qnt_bolsas)
VALUES
(1, 'A+', 30),
(2, 'B+', 40),
(3, 'AB+', 35),
(4, 'A-', 25),
(5, 'B-', 20),
(6, 'O+', 50),
(7, 'O-', 15),
(8, 'A+', 40),
(9, 'B+', 45),
(10, 'AB-', 30);

commit;



-- Procedure insert entrevista -- 

create or replace procedure insert_entrevista( -- inserido
    p_doador_id integer,
    p_tem_diabete boolean,
    p_ja_teve_ist boolean,
    p_qnt_parceiros_sexuais integer,
    p_tatto_6_meses boolean,
    p_piercing_6_meses boolean
)
language PLPGSQL
as $$

DECLARE

v_apto varchar;

begin 

v_apto := 'aprovado';

IF p_tem_diabete = TRUE OR p_ja_teve_ist = TRUE or p_qnt_parceiros_sexuais > 3 or p_tatto_6_meses = TRUE or p_piercing_6_meses = TRUE THEN
    v_apto := 'reprovado';
end if;


INSERT INTO entrevista (doador_id,tem_doencas_diabetes,ja_teve_ist,qnt_parceiros_sexuais,
tatto_6_meses, piercing_6_meses, apto)
values(p_doador_id, p_tem_diabete,p_ja_teve_ist,p_qnt_parceiros_sexuais, p_tatto_6_meses,p_piercing_6_meses,v_apto);
end;
$$;

-- procedure insert doador 

create or replace procedure insert_doador( -- inserido
    p_nome varchar, 
    p_cpf varchar,
    p_telefone varchar,
    p_email varchar,
    p_tipo_sangue varchar,
    -- endereco 
    p_doador_id integer,
    p_estado char,
    p_cidade VARCHAR,
    p_rua varchar,
    p_numero varchar,
    p_complemento varchar
)

language plpgsql
as $$

declare 

v_doador_id integer;

begin 

insert into doadores(nome, cpf, telefone, email, tipo_sangue)
values (p_nome, p_cpf, p_telefone, p_email, p_tipo_sangue)
returning doador_id into v_doador_id;

insert into Endereco_doadores(doador_id, estado, cidade, rua, numero, complemento)
values(v_doador_id, p_estado, p_cidade, p_rua, p_numero, p_complemento);
end;
$$;


-- procedure insert Profissionais --

create or replace procedure insert_profissionais( -- inserido 
    p_profissional_id integer,
    p_centro_id integer
)
language plpgsql 
as $$

begin 

insert into profissionais_centro(profissional_id, centro_id)
values(p_profissional_id, p_centro_id);
end;
$$;


create or replace procedure insert_centro( -- inserido
    p_nome varchar
)
language plpgsql as $$ 

declare 

v_centro_id integer;

begin 

insert into centro_doacao(nome)
values(p_nome)
returning centro_id into v_centro_id;

end;
$$;

create or replace procedure insert_profissional_centro( -- inserido 
    p_profissional_id integer,
    p_centro_id integer
)

language plpgsql as $$

begin 

insert into profissionais_centros(profissional_id, centro_id)
values(p_profissional_id, p_centro_id);
end;
$$;


create or replace procedure realizar_doacao(
    p_centro_id integer,
    p_entrevista_id integer,
    p_profissional_id integer
)

language plpgsql as $$

begin

insert into doacao(centro_id, entrevista_id, profissional_id)
values(p_centro_id, p_entrevista_id, p_profissional_id);

end;
$$;


-- trigger 

create or replace FUNCTION verificar_doacao_apto() -- inserido no banco
returns TRIGGER as $$
begin 

if(select apto from entrevista where entrevista_id = new.entrevista_id) = 'reprovado' THEN
    raise EXCEPTION ' Doador nao esta apto para doacao';
end if;

return new;
end;
$$ language plpgsql;

create trigger trigger_verificar_apto_do_doador -- inserido no banco 
before insert on doacao
for each row
execute function verificar_doacao_apto();

 ------------------------------------------------------------------

create or replace function incrementar_estoque_sangue() -- inserido
returns trigger as $$
begin

update estoque_sangue
set qnt_bolsas = qnt_bolsas +1
where centro_id = new.centro_id
AND tipo_sangue = (SELECT tipo_sangue FROM entrevista WHERE entrevista_id = NEW.entrevista_id);

if not found THEN
insert into estoque_sangue(centro_id, tipo_sangue, qnt_bolsas)
values(
    new.centro_id, (select tipo_sangue from entrevista where entrevista_id = new.entrevista_id),
    1
);
end if;

return new;
end;
$$ language plpgsql;

create trigger trigger_incrementar_estoque_sangue -- inserido
after insert on doacao
for each row
execute function incrementar_estoque_sangue();


create or replace function atualizar_dados_doadores() -- inserido
returns trigger as $$ 
BEGIN

update doadores
SET
data_ultima_doacao = current_Date,
quantidade_doacoes = quantidade_doacoes +1
where doador_id = new.doador_id;

return new;
end;
$$ language plpgsql;

create trigger atualizar_doador_apos_doacao -- inserido
after insert on doacao
for each row
execute function atualizar_dados_doadores();

create or replace function atualizar_profissionais_centro_doacao() -- inserido 
returns trigger as  $$

begin 

update centro_doacao
set profissionais_contratados = profissionais_contratados +1
where centro_id = new.centro_id;

return new;
end;
$$ language plpgsql;

create trigger trigger_atualiza_profissionais_centro
after insert on profissionais_centros
for EACH ROW
execute function atualizar_profissionais_centro_doacao();


