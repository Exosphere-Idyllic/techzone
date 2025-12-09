package com.techzone.ecommerce.techzone.servlet;

import com.techzone.ecommerce.techzone.model.Usuario;
import com.techzone.ecommerce.techzone.service.UsuarioService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

/**
 * Servlet para actualizar la información del perfil del usuario
 *
 * @author TechZone Team
 * @version 1.0
 */
@WebServlet("/perfil/actualizar")
public class ActualizarPerfilServlet extends HttpServlet {

    private UsuarioService usuarioService;

    @Override
    public void init() throws ServletException {
        // Inicializar el servicio (ajustar según tu implementación)
        // usuarioService = new UsuarioService();
    }

    /**
     * Actualiza la información personal del usuario
     * POST /perfil/actualizar
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Configurar encoding para caracteres especiales
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
            String nombre = request.getParameter("nombre");
            String apellido = request.getParameter("apellido");
            String email = request.getParameter("email");
            String telefono = request.getParameter("telefono");
            String direccion = request.getParameter("direccion");

            // Validar campos requeridos
            if (nombre == null || nombre.trim().isEmpty() ||
                    apellido == null || apellido.trim().isEmpty() ||
                    email == null || email.trim().isEmpty()) {

                request.setAttribute("error", "Nombre, apellido y email son obligatorios");
                request.setAttribute("tabActiva", "info");
                request.getRequestDispatcher("/views/usuario/perfil.jsp").forward(request, response);
                return;
            }

            // Validar formato de email
            if (!email.matches("^[A-Za-z0-9+_.-]+@(.+)$")) {
                request.setAttribute("error", "Email inválido");
                request.setAttribute("tabActiva", "info");
                request.getRequestDispatcher("/views/usuario/perfil.jsp").forward(request, response);
                return;
            }

            // Si cambió el email, verificar que no exista
            if (!email.equals(usuario.getEmail())) {
                // Usuario existente = usuarioService.obtenerPorEmail(email);
                // if (existente != null) {
                //     request.setAttribute("error", "El email ya está en uso");
                //     request.setAttribute("tabActiva", "info");
                //     request.getRequestDispatcher("/views/usuario/perfil.jsp").forward(request, response);
                //     return;
                // }
            }

            // Actualizar datos del usuario
            usuario.setNombre(nombre.trim());
            usuario.setApellido(apellido.trim());
            usuario.setEmail(email.trim());
            usuario.setTelefono(telefono != null ? telefono.trim() : null);
            usuario.setDireccion(direccion != null ? direccion.trim() : null);

            // Guardar en base de datos
            // usuarioService.actualizar(usuario);

            // TEMPORAL: Como no tenemos el service implementado aún,
            // solo actualizamos en sesión
            session.setAttribute("usuario", usuario);

            // Mensaje de éxito
            request.setAttribute("mensaje", "Perfil actualizado correctamente");
            request.setAttribute("tabActiva", "info");

        } catch (Exception e) {
            request.setAttribute("error", "Error al actualizar el perfil: " + e.getMessage());
            request.setAttribute("tabActiva", "info");
        }

        // Forward de vuelta a la vista
        request.getRequestDispatcher("/views/usuario/perfil.jsp").forward(request, response);
    }
}