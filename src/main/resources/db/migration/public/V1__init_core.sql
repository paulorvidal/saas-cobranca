-- V1__init_core
-- Habilita funções de criptografia e UUID no banco de dados (nível global)
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Tabela central que controla quem são as empresas assinantes do SaaS
CREATE TABLE tenant (
    id VARCHAR(50) PRIMARY KEY,
    nome_empresa VARCHAR(100) NOT NULL,
    schema_name VARCHAR(50) NOT NULL UNIQUE,
    email_contato VARCHAR(100) NOT NULL,
    plano_assinatura VARCHAR(30) NOT NULL DEFAULT 'BASIC',
    ativo BOOLEAN NOT NULL DEFAULT TRUE,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);