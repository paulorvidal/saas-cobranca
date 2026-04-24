package br.com.paulovidal.saas_cobranca.tenant;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import jakarta.persistence.PreUpdate;
import java.time.LocalDateTime;

@Entity
@Table(name = "tenant", schema = "public")
public class Tenant {

    @Id
    @Column(length = 50)
    private String id;

    @Column(name = "nome_empresa", nullable = false, length = 100)
    private String nomeEmpresa;

    @Column(name = "schema_name", nullable = false, unique = true, length = 50)
    private String schemaName;

    @Column(name = "email_contato", nullable = false, length = 100)
    private String emailContato;

    @Column(name = "plano_assinatura", nullable = false, length = 30)
    private String planoAssinatura;

    @Column(nullable = false)
    private boolean ativo;

    @Column(name = "data_criacao", insertable = false, updatable = false)
    private LocalDateTime dataCriacao;

    @Column(name = "data_atualizacao")
    private LocalDateTime dataAtualizacao;

    protected Tenant() {
    }

    /**
     * Construtor oficial para o nascimento do Tenant no sistema.
     */
    public Tenant(String id, String nomeEmpresa, String schemaName, String emailContato) {
        if (nomeEmpresa == null || nomeEmpresa.trim().isEmpty()) {
            throw new IllegalArgumentException("O nome da empresa não pode ser vazio.");
        }
        if (schemaName == null || schemaName.trim().isEmpty()) {
            throw new IllegalArgumentException("O nome do schema não pode ser vazio.");
        }
        if (emailContato == null || !emailContato.contains("@")) {
            throw new IllegalArgumentException("E-mail de contato inválido.");
        }

        this.id = id;
        this.nomeEmpresa = nomeEmpresa;
        this.schemaName = schemaName.toLowerCase();
        this.emailContato = emailContato;

        this.planoAssinatura = "BASIC";
        this.ativo = true;
        this.dataAtualizacao = LocalDateTime.now();
    }

    public void atualizarNomeEmpresa(String novoNome) {
        if (novoNome == null || novoNome.trim().isEmpty()) {
            throw new IllegalArgumentException("O novo nome da empresa é inválido.");
        }
        this.nomeEmpresa = novoNome;
    }

    public void atualizarEmailContato(String novoEmail) {
        if (novoEmail == null || !novoEmail.contains("@")) {
            throw new IllegalArgumentException("Formato de e-mail inválido.");
        }
        this.emailContato = novoEmail;
    }

    public void alterarPlano(String novoPlano) {
        if (novoPlano == null || novoPlano.trim().isEmpty()) {
            throw new IllegalArgumentException("O plano informado é inválido.");
        }
        this.planoAssinatura = novoPlano.toUpperCase();
    }

    public void suspenderAcesso() {
        this.ativo = false;
    }

    public void reativarAcesso() {
        this.ativo = true;
    }

    /**
     * Este método é chamado automaticamente pelo Hibernate SEMPRE que essa entidade
     * for sofrer um UPDATE no banco de dados.
     */
    @PreUpdate
    protected void onUpdate() {
        this.dataAtualizacao = LocalDateTime.now();
    }

    public String getId() {
        return id;
    }

    public String getNomeEmpresa() {
        return nomeEmpresa;
    }

    public String getSchemaName() {
        return schemaName;
    }

    public String getEmailContato() {
        return emailContato;
    }

    public String getPlanoAssinatura() {
        return planoAssinatura;
    }

    public boolean isAtivo() {
        return ativo;
    }

    public LocalDateTime getDataCriacao() {
        return dataCriacao;
    }

    public LocalDateTime getDataAtualizacao() {
        return dataAtualizacao;
    }
}