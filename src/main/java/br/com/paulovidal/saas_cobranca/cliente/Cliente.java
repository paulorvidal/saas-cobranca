package br.com.paulovidal.saas_cobranca.cliente;

import java.time.LocalDateTime;
import java.util.UUID;

import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name = "cliente")
public class Cliente {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(nullable = false, length = 150)
    private String nome;

    @Column(nullable = false, unique = true, length = 14)
    private String documento;

    @Column(nullable = false, length = 100)
    private String email;

    @Column(length = 20)
    private String telefone;

    // --- Dados de Endereço ---
    @Column(length = 8)
    private String cep;

    @Column(length = 150)
    private String logradouro;

    @Column(length = 20)
    private String numero;

    @Column(length = 100)
    private String complemento;

    @Column(length = 100)
    private String bairro;

    @Column(length = 100)
    private String cidade;

    @Column(length = 2)
    private String uf;

    // --- Controle do Sistema ---
    @Column(nullable = false)
    private Boolean ativo = true;

    @CreationTimestamp
    @Column(name = "data_cadastro", updatable = false)
    private LocalDateTime dataCadastro;

    @UpdateTimestamp
    @Column(name = "data_atualizacao")
    private LocalDateTime dataAtualizacao;

    protected Cliente() {
    }

    public Cliente(String nome, String documento, String email, String telefone,
            String cep, String logradouro, String numero, String complemento,
            String bairro, String cidade, String uf) {

        // 1. Fail Fast: Validações de integridade
        if (nome == null || nome.trim().isEmpty()) {
            throw new IllegalArgumentException("O nome do cliente é obrigatório.");
        }
        if (documento == null || documento.trim().isEmpty()) {
            throw new IllegalArgumentException("O documento (CPF/CNPJ) é obrigatório.");
        }
        if (email == null || !email.contains("@")) {
            throw new IllegalArgumentException("Um e-mail válido é obrigatório.");
        }

        // 2. Atribuição de dados e limpeza de formatação
        this.nome = nome;
        this.documento = removerFormatacaoDocumento(documento); // Salva apenas os números
        this.email = email;
        this.telefone = telefone;

        // 3. Endereço
        this.cep = cep != null ? cep.replace("-", "") : null;
        this.logradouro = logradouro;
        this.numero = numero;
        this.complemento = complemento;
        this.bairro = bairro;
        this.cidade = cidade;
        this.uf = uf != null ? uf.toUpperCase() : null;

        // 4. Regra de negócio padrão
        this.ativo = true;
    }

    private String removerFormatacaoDocumento(String doc) {
        return doc.replaceAll("[^0-9]", ""); // Remove pontos, traços e barras
    }

}