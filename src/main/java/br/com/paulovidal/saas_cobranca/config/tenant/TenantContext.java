package br.com.paulovidal.saas_cobranca.config.tenant;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public final class TenantContext {
    private static final Logger logger = LoggerFactory.getLogger(TenantContext.class);
    // o InheritableThreadLocal permite que as filhas herdem o contexto
    private static final ThreadLocal<String> currentTenant = new InheritableThreadLocal<>();

    private TenantContext() {
    }

    public static void setCurrentTenant(String tenantId) {
        logger.debug("Definindo tenant context para: {}", tenantId);
        currentTenant.set(tenantId);
    }

    public static String getCurrentTenant() {
        return currentTenant.get();
    }

    // Limpar o contexto é OBRIGATÓRIO por questões de segurança.
    public static void clear() {
        currentTenant.remove();
        logger.debug("Tenant context limpo!");
    }

}
