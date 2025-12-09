package com.techzone.ecommerce.techzone.servlet;

import com.techzone.ecommerce.techzone.model.Usuario;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

/**
 * Servlet para gestionar el perfil del usuario
 *
 * @author TechZone Team
 * @version 1.0
 */
@WebServlet("/perfil")
public class PerfilServlet extends HttpServlet {

    /**
     * Muestra la página de perfil del usuario
     * GET /perfil
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Obtener la sesión
        HttpSession session = request.getSession(false);

        // Verificar si el usuario está autenticado
        if (session == null || session.getAttribute("usuario") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // Obtener el usuario de la sesión
        Usuario usuario = (Usuario) session.getAttribute("usuario");

        // El usuario ya está en la sesión, no necesitamos agregarlo de nuevo
        // Pero podríamos actualizar sus datos desde la BD si es necesario

        // Forward a la vista de perfil
        request.getRequestDispatcher("/views/usuario/perfil.jsp").forward(request, response);
    }

    /**
     * Maneja la actualización del perfil del usuario
     * POST /perfil/actualizar
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Este método se maneja en ActualizarPerfilServlet
        // Redirigir si llega aquí por error
        response.sendRedirect(request.getContextPath() + "/perfil");
    }
}