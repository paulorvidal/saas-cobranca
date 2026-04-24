--  de UUIDs nativa
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- 1. Tabela de Clientes (Com Soft Delete)
CREATE TABLE cliente (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nome VARCHAR(150) NOT NULL,
    documento VARCHAR(14) NOT NULL UNIQUE, 
    email VARCHAR(100) NOT NULL,
    telefone VARCHAR(20),
    ativo BOOLEAN NOT NULL DEFAULT TRUE, 
    data_cadastro TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    data_atualizacao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 2. Tabela de Cobranças (Com Check Constraints e Numeric)
CREATE TABLE cobranca (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    cliente_id UUID NOT NULL,
    descricao VARCHAR(255) NOT NULL,
    valor NUMERIC(15, 2) NOT NULL, 
    data_vencimento DATE NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'PENDENTE',
    ativo BOOLEAN NOT NULL DEFAULT TRUE, -- SOFT DELETE
    data_criacao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    data_atualizacao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_cobranca_cliente FOREIGN KEY (cliente_id) REFERENCES cliente(id) ON DELETE RESTRICT,
    -- Trava de segurança no banco de dados
    CONSTRAINT chk_cobranca_status CHECK (status IN ('PENDENTE', 'PAGA', 'VENCIDA', 'CANCELADA'))
);

-- 3. Tabela de Pagamentos (Registro imutável)
CREATE TABLE pagamento (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    cobranca_id UUID NOT NULL,
    valor_pago NUMERIC(15, 2) NOT NULL,
    data_pagamento TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    metodo VARCHAR(50) NOT NULL, 
    codigo_transacao_externa VARCHAR(100), 
    
    CONSTRAINT fk_pagamento_cobranca FOREIGN KEY (cobranca_id) REFERENCES cobranca(id) ON DELETE RESTRICT,
    CONSTRAINT chk_pagamento_metodo CHECK (metodo IN ('PIX', 'BOLETO', 'CARTAO_CREDITO'))
);

-- 4. Índices de Performance (Otimizados para ignorar dados "deletados")
CREATE INDEX idx_cobranca_status ON cobranca(status) WHERE ativo = TRUE;
CREATE INDEX idx_cobranca_cliente ON cobranca(cliente_id) WHERE ativo = TRUE;
CREATE INDEX idx_cliente_documento ON cliente(documento) WHERE ativo = TRUE;