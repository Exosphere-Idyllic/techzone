package com.techzone.ecommerce.techzone.filter;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;

/**

 Filtro para establecer la codificación UTF-8 en todas las peticiones y respuestas.
 Esto asegura que los caracteres especiales (ñ, tildes, etc.) se manejen correctamente.
 @author TechZone Team*/
@WebFilter(filterName = "EncodingFilter", urlPatterns = {"/*"})
public class EncodingFilter implements Filter {

    private static final Logger logger = LoggerFactory.getLogger(EncodingFilter.class);
    private static final String ENCODING = "UTF-8";

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        logger.info("EncodingFilter inicializado con codificación: {}", ENCODING);
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;

        // Establecer codificación en request
        if (request.getCharacterEncoding() == null) {
            request.setCharacterEncoding(ENCODING);
        }

        // Establecer codificación en response
        response.setCharacterEncoding(ENCODING);
        httpResponse.setHeader("Content-Type", "text/html; charset=UTF-8");

        // Continuar con la cadena de filtros
        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {
        logger.info("EncodingFilter destruido");
    }
}