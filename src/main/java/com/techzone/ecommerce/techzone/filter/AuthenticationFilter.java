package com.techzone.ecommerce.techzone.filter;

import com.techzone.ecommerce.techzone.util.SessionUtil;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;

/**
 * Filtro de autenticación para proteger rutas que requieren login.
 * Redirige al login si el usuario no está autenticado.
 * 
 * @author TechZone Team
 */
@WebFilter(filterName = "AuthenticationFilter", urlPatterns = {"/*"})
public class AuthenticationFilter implements Filter {

    private static final Logger logger = LoggerFactory.getLogger(AuthenticationFilter.class);

    // Rutas que requieren autenticación
    private static final Set<String> PROTECTED_PATHS = new HashSet<>(Arrays.asList(
            "/carrito",
            "/checkout",
            "/pedido",
            "/pedidos",
            "/perfil",
            "/resena"
    ));

    // Rutas de administrador
    private static final Set<String> ADMIN_PATHS = new HashSet<>(Arrays.asList(
            "/admin"
    ));

    // Recursos estáticos (no filtrar)
    private static final Set<String> STATIC_RESOURCES = new HashSet<>(Arrays.asList(
            ".css", ".js", ".png", ".jpg", ".jpeg", ".gif", ".ico", ".woff", ".woff2", ".ttf"
    ));

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        logger.info("AuthenticationFilter inicializado");
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;

        String path = httpRequest.getServletPath();
        String contextPath = httpRequest.getContextPath();

        // Permitir recursos estáticos
        if (isStaticResource(path)) {
            chain.doFilter(request, response);
            return;
        }

        logger.debug("Verificando autenticación para: {}", path);

        // Verificar si es ruta de admin
        if (isAdminPath(path)) {
            if (!SessionUtil.isAuthenticated(httpRequest)) {
                logger.warn("Acceso denegado a {} - Usuario no autenticado", path);
                SessionUtil.setReturnUrl(httpRequest, path);
                httpResponse.sendRedirect(contextPath + "/login?error=sesion_requerida");
                return;
            }

            if (!SessionUtil.isAdmin(httpRequest)) {
                logger.warn("Acceso denegado a {} - Usuario no es admin", path);
                httpResponse.sendRedirect(contextPath + "/?error=acceso_denegado");
                return;
            }
        }

        // Verificar si es ruta protegida
        if (isProtectedPath(path)) {
            if (!SessionUtil.isAuthenticated(httpRequest)) {
                logger.warn("Acceso denegado a {} - Usuario no autenticado", path);
                SessionUtil.setReturnUrl(httpRequest, path);
                httpResponse.sendRedirect(contextPath + "/login?error=sesion_requerida");
                return;
            }
        }

        // Continuar con la petición
        chain.doFilter(request, response);
    }

    /**
     * Verifica si la ruta requiere autenticación
     */
    private boolean isProtectedPath(String path) {
        for (String protectedPath : PROTECTED_PATHS) {
            if (path.startsWith(protectedPath)) {
                return true;
            }
        }
        return false;
    }

    /**
     * Verifica si la ruta es de administrador
     */
    private boolean isAdminPath(String path) {
        for (String adminPath : ADMIN_PATHS) {
            if (path.startsWith(adminPath)) {
                return true;
            }
        }
        return false;
    }

    /**
     * Verifica si es un recurso estático
     */
    private boolean isStaticResource(String path) {
        if (path == null) {
            return false;
        }
        
        String lowerPath = path.toLowerCase();
        for (String extension : STATIC_RESOURCES) {
            if (lowerPath.endsWith(extension)) {
                return true;
            }
        }
        
        // También permitir carpetas de recursos
        return lowerPath.startsWith("/css/") ||
               lowerPath.startsWith("/js/") ||
               lowerPath.startsWith("/images/") ||
               lowerPath.startsWith("/assets/") ||
               lowerPath.startsWith("/uploads/");
    }

    @Override
    public void destroy() {
        logger.info("AuthenticationFilter destruido");
    }
}
