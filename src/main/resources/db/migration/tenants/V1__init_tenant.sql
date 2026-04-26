-- 1. Tabela de Clientes (Agora com dados obrigatórios para Boleto Registrado e NF-e)
CREATE TABLE cliente (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nome VARCHAR(150) NOT NULL,
    documento VARCHAR(14) NOT NULL UNIQUE, 
    email VARCHAR(100) NOT NULL,
    telefone VARCHAR(20),
    
    -- Dados de Endereço (Essenciais para gateways financeiros)
    cep VARCHAR(8),
    logradouro VARCHAR(150),
    numero VARCHAR(20),
    complemento VARCHAR(100),
    bairro VARCHAR(100),
    cidade VARCHAR(100),
    uf VARCHAR(2),

    ativo BOOLEAN NOT NULL DEFAULT TRUE, 
    data_cadastro TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    data_atualizacao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 2. Tabela de Cobranças (Composição de valor e integração com Gateway)
CREATE TABLE cobranca (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    cliente_id UUID NOT NULL,
    descricao VARCHAR(255) NOT NULL,
    
    -- Composição de Valores
    valor_original NUMERIC(15, 2) NOT NULL, 
    valor_multa NUMERIC(15, 2) DEFAULT 0.00,
    valor_juros NUMERIC(15, 2) DEFAULT 0.00,
    valor_desconto NUMERIC(15, 2) DEFAULT 0.00,
    
    data_vencimento DATE NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'PENDENTE',
    
    -- Dados do Gateway Externo (Asaas, MercadoPago, etc)
    gateway_id VARCHAR(100), -- ID da cobrança lá no banco externo
    link_fatura VARCHAR(255), -- URL para o cliente imprimir o boleto
    linha_digitavel VARCHAR(100),
    pix_copia_cola TEXT,
    
    ativo BOOLEAN NOT NULL DEFAULT TRUE,
    data_criacao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    data_atualizacao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_cobranca_cliente FOREIGN KEY (cliente_id) REFERENCES cliente(id) ON DELETE RESTRICT,
    CONSTRAINT chk_cobranca_status CHECK (status IN ('PENDENTE', 'PAGA', 'VENCIDA', 'CANCELADA', 'FALHA'))
);

-- 3. Tabela de Pagamentos (Com status de ciclo de vida)
CREATE TABLE pagamento (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    cobranca_id UUID NOT NULL,
    valor_pago NUMERIC(15, 2) NOT NULL,
    data_pagamento TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    metodo VARCHAR(50) NOT NULL, 
    
    -- Rastreabilidade
    gateway_transacao_id VARCHAR(100), 
    status VARCHAR(30) NOT NULL DEFAULT 'APROVADO', -- PROCESSANDO, APROVADO, RECUSADO, ESTORNADO
    
    CONSTRAINT fk_pagamento_cobranca FOREIGN KEY (cobranca_id) REFERENCES cobranca(id) ON DELETE RESTRICT,
    CONSTRAINT chk_pagamento_metodo CHECK (metodo IN ('PIX', 'BOLETO', 'CARTAO_CREDITO')),
    CONSTRAINT chk_pagamento_status CHECK (status IN ('PROCESSANDO', 'APROVADO', 'RECUSADO', 'ESTORNADO'))
);

-- 4. Índices de Performance
CREATE INDEX idx_cobranca_status ON cobranca(status) WHERE ativo = TRUE;
CREATE INDEX idx_cobranca_cliente ON cobranca(cliente_id) WHERE ativo = TRUE;
CREATE INDEX idx_cobranca_gateway_id ON cobranca(gateway_id); -- Muito usado por Webhooks
CREATE INDEX idx_cliente_documento ON cliente(documento) WHERE ativo = TRUE;

-- 5. Tabela de Assinaturas (Contratos de Recorrência)
CREATE TABLE assinatura (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    cliente_id UUID NOT NULL,
    plano_nome VARCHAR(100) NOT NULL,
    valor NUMERIC(15, 2) NOT NULL,
    ciclo VARCHAR(20) NOT NULL, -- MENSAL, TRIMESTRAL, ANUAL
    dia_vencimento INTEGER NOT NULL, -- Ex: dia 10 de todo mês
    proximo_vencimento DATE NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'ATIVA', -- ATIVA, SUSPENSA, CANCELADA
    data_criacao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    data_atualizacao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_assinatura_cliente FOREIGN KEY (cliente_id) REFERENCES cliente(id) ON DELETE RESTRICT,
    CONSTRAINT chk_assinatura_ciclo CHECK (ciclo IN ('SEMANAL', 'MENSAL', 'TRIMESTRAL', 'SEMESTRAL', 'ANUAL')),
    CONSTRAINT chk_assinatura_status CHECK (status IN ('ATIVA', 'SUSPENSA', 'CANCELADA'))
);

-- Alteração na tabela Cobrança (Para ligar a cobrança à assinatura que a gerou)
-- OBS: Adicione esta coluna na sua tabela de 'cobranca'
-- assinatura_id UUID,
-- CONSTRAINT fk_cobranca_assinatura FOREIGN KEY (assinatura_id) REFERENCES assinatura(id) ON DELETE SET NULL


-- 6. Tabela de Notificações (Régua de Cobrança / Log de Envios)
CREATE TABLE notificacao_cobranca (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    cobranca_id UUID NOT NULL,
    tipo_canal VARCHAR(20) NOT NULL, -- EMAIL, WHATSAPP, SMS
    tipo_aviso VARCHAR(50) NOT NULL, -- LEMBRETE_VENCIMENTO, COBRANCA_ATRASADA, RECIBO_PAGAMENTO
    status_envio VARCHAR(20) NOT NULL DEFAULT 'PENDENTE', -- PENDENTE, ENVIADO, FALHA
    data_envio TIMESTAMP,
    mensagem_erro TEXT,
    
    CONSTRAINT fk_notificacao_cobranca FOREIGN KEY (cobranca_id) REFERENCES cobranca(id) ON DELETE CASCADE
);

-- 7. Tabela de Webhooks (Auditoria e Segurança Transacional)
CREATE TABLE webhook_log (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    gateway VARCHAR(50) NOT NULL, -- ASAAS, MERCADO_PAGO, STRIPE
    evento_tipo VARCHAR(100) NOT NULL, -- Ex: payment.created, payment.updated
    payload JSONB NOT NULL, -- Guarda o JSON original que veio do gateway inteiro!
    status_processamento VARCHAR(20) NOT NULL DEFAULT 'PENDENTE', -- PENDENTE, PROCESSADO, ERRO
    tentativas INTEGER DEFAULT 0,
    mensagem_erro TEXT,
    data_recebimento TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    data_processamento TIMESTAMP
);

-- Índices adicionais cruciais
CREATE INDEX idx_assinatura_vencimento ON assinatura(proximo_vencimento) WHERE status = 'ATIVA';
CREATE INDEX idx_webhook_status ON webhook_log(status_processamento);