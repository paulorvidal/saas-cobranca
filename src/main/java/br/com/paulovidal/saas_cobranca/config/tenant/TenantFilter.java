package br.com.paulovidal.saas_cobranca.config.tenant;

import java.io.IOException;
import java.util.Arrays;
import java.util.List;

import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@Component
public class TenantFilter extends OncePerRequestFilter {

    private static final String TENANT_HEADER = "X-Tenant-ID";

    // Lista VIP: Rotas que NÃO precisam de Tenant (Login, Swagger, etc)
    private static final List<String> ROTAS_PUBLICAS = Arrays.asList(
            "/api/auth/login",
            "/v3/api-docs",
            "/swagger-ui");

    /**
     * O Spring chama esse método antes. Se retornar TRUE, ele pula o filtro.
     */
    @Override
    protected boolean shouldNotFilter(HttpServletRequest request) throws ServletException {
        String path = request.getRequestURI();
        // Verifica se a rota atual está na nossa Lista VIP
        return ROTAS_PUBLICAS.stream().anyMatch(path::startsWith);
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request,
            HttpServletResponse response,
            FilterChain filterChain) throws ServletException, IOException {

        String tenantId = request.getHeader(TENANT_HEADER);

        // Fail Fast: Se chegou aqui, é porque a rota exige Tenant. Se não tem, barramos
        // na porta!
        if (tenantId == null || tenantId.trim().isEmpty()) {
            logger.error("Acesso negado: Header " + TENANT_HEADER + " ausente.");

            // Retorna o status 400 (Bad Request) direto, sem chamar o filterChain
            response.sendError(HttpServletResponse.SC_BAD_REQUEST,
                    "O Header " + TENANT_HEADER + " é obrigatório para esta rota.");
            return; // Encerra a execução do filtro aqui mesmo!
        }

        // Se tem o Tenant, guarda no "cofre" (bolso do garçom)
        TenantContext.setCurrentTenant(tenantId);

        try {
            // Libera a requisição para continuar seu caminho
            filterChain.doFilter(request, response);
        } finally {
            // Limpeza obrigatória para evitar vazamento de dados entre empresas
            TenantContext.clear();
        }
    }
}