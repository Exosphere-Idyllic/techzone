package com.techzone.ecommerce.techzone.servlet;

import com.techzone.ecommerce.techzone.model.Usuario;
import com.techzone.ecommerce.techzone.service.UsuarioService;
import com.techzone.ecommerce.techzone.util.PasswordUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

/**
 * Servlet para cambiar la contraseña del usuario
 *
 * @author TechZone Team
 * @version 1.0
 */
@WebServlet("/perfil/cambiar-password")
public class CambiarPasswordServlet extends HttpServlet {

    private UsuarioService usuarioService;

    @Override
    public void init() throws ServletException {
        // Inicializar el servicio (ajustar según tu implementación)
        // usuarioService = new UsuarioService();
    }

    /**
     * Cambia la contraseña del usuario
     * POST /perfil/cambiar-password
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Configurar encoding
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        // Obtener la sesión
        HttpSession session = request.getSession(false);

        // Verificar autenticación
        if (session == null || session.getAttribute("usuario") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // Obtener usuario actual
        Usuario usuario = (Usuario) session.getAttribute("usuario");

        try {
            // Obtener datos del formulario
            String passwordActual = request.getParameter("passwordActual");
            String passwordNueva = request.getParameter("passwordNueva");
            String passwordConfirmar = request.getParameter("passwordConfirmar");

            // Validar campos requeridos
            if (passwordActual == null || passwordActual.isEmpty() ||
                    passwordNueva == null || passwordNueva.isEmpty() ||
                    passwordConfirmar == null || passwordConfirmar.isEmpty()) {

                request.setAttribute("error", "Todos los campos son obligatorios");
                request.setAttribute("tabActiva", "password");
                request.getRequestDispatcher("/views/usuario/perfil.jsp").forward(request, response);
                return;
            }

            // Validar longitud mínima
            if (passwordNueva.length() < 8) {
                request.setAttribute("error", "La nueva contraseña debe tener al menos 8 caracteres");
                request.setAttribute("tabActiva", "password");
                request.getRequestDispatcher("/views/usuario/perfil.jsp").forward(request, response);
                return;
            }

            // Validar que las contraseñas coincidan
            if (!passwordNueva.equals(passwordConfirmar)) {
                request.setAttribute("error", "Las contraseñas nuevas no coinciden");
                request.setAttribute("tabActiva", "password");
                request.getRequestDispatcher("/views/usuario/perfil.jsp").forward(request, response);
                return;
            }

            // Verificar contraseña actual
            // IMPORTANTE: Cuando implementes PasswordUtil, descomentar esta validación
            /*
            if (!PasswordUtil.checkPassword(passwordActual, usuario.getPassword())) {
                request.setAttribute("error", "La contraseña actual es incorrecta");
                request.setAttribute("tabActiva", "password");
                request.getRequestDispatcher("/views/usuario/perfil.jsp").forward(request, response);
                return;
            }
            */

            // TEMPORAL: Validación simple mientras no tenemos PasswordUtil
            // En producción, SIEMPRE usar hashing (BCrypt, SHA-256, etc.)
            if (!passwordActual.equals(usuario.getPassword())) {
                request.setAttribute("error", "La contraseña actual es incorrecta");
                request.setAttribute("tabActiva", "password");
                request.getRequestDispatcher("/views/usuario/perfil.jsp").forward(request, response);
                return;
            }

            // Hashear la nueva contraseña
            // String hashedPassword = PasswordUtil.hashPassword(passwordNueva);
            // usuario.setPassword(hashedPassword);

            // TEMPORAL: Sin hashing (NO USAR EN PRODUCCIÓN)
            usuario.setPassword(passwordNueva);

            // Actualizar en base de datos
            // usuarioService.actualizarPassword(usuario.getIdUsuario(), hashedPassword);

            // Actualizar en sesión
            session.setAttribute("usuario", usuario);

            // Mensaje de éxito
            request.setAttribute("mensaje", "Contraseña actualizada correctamente");
            request.setAttribute("tabActiva", "password");

        } catch (Exception e) {
            request.setAttribute("error", "Error al cambiar la contraseña: " + e.getMessage());
            request.setAttribute("tabActiva", "password");
        }

        // Forward de vuelta a la vista
        request.getRequestDispatcher("/views/usuario/perfil.jsp").forward(request, response);
    }
}