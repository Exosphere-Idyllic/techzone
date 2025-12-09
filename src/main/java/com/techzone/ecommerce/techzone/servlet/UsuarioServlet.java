package com.techzone.ecommerce.techzone.servlet;

import com.google.protobuf.ServiceException;
import com.techzone.ecommerce.techzone.model.Usuario;
import com.techzone.ecommerce.techzone.service.UsuarioService;
import com.techzone.ecommerce.techzone.util.SessionUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;

/**
 * Servlet para gestión de usuarios: registro, login, logout, perfil
 * Maneja todas las operaciones relacionadas con usuarios
 *
 * @author TechZone Team
 */
@WebServlet(name = "UsuarioServlet", urlPatterns = {
        "/login",
        "/logout",
        "/registro",
        "/perfil",
        "/perfil/actualizar",
        "/perfil/cambiar-password"
})
public class UsuarioServlet extends HttpServlet {

    private static final Logger logger = LoggerFactory.getLogger(UsuarioServlet.class);
    private UsuarioService usuarioService;

    @Override
    public void init() throws ServletException {
        super.init();
        this.usuarioService = new UsuarioService();
        logger.info("UsuarioServlet inicializado");
    }

    // ==================== MÉTODO GET ====================

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String path = request.getServletPath();
        logger.debug("GET request: {}", path);

        try {
            switch (path) {
                case "/login":
                    mostrarLogin(request, response);
                    break;
                case "/registro":
                    mostrarRegistro(request, response);
                    break;
                case "/logout":
                    procesarLogout(request, response);
                    break;
                case "/perfil":
                    mostrarPerfil(request, response);
                    break;
                default:
                    response.sendError(HttpServletResponse.SC_NOT_FOUND);
            }
        } catch (Exception e) {
            logger.error("Error en GET {}: {}", path, e.getMessage(), e);
            request.setAttribute("error", "Error al procesar la solicitud");
            request.getRequestDispatcher("/views/error.jsp").forward(request, response);
        }
    }

    // ==================== MÉTODO POST ====================

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String path = request.getServletPath();
        logger.debug("POST request: {}", path);

        try {
            switch (path) {
                case "/login":
                    procesarLogin(request, response);
                    break;
                case "/registro":
                    procesarRegistro(request, response);
                    break;
                case "/perfil/actualizar":
                    procesarActualizarPerfil(request, response);
                    break;
                case "/perfil/cambiar-password":
                    procesarCambiarPassword(request, response);
                    break;
                default:
                    response.sendError(HttpServletResponse.SC_NOT_FOUND);
            }
        } catch (Exception e) {
            logger.error("Error en POST {}: {}", path, e.getMessage(), e);
            request.setAttribute("error", "Error al procesar la solicitud");
            request.getRequestDispatcher("/views/error.jsp").forward(request, response);
        }
    }

    // ==================== MÉTODOS GET ====================

    /**
     * Muestra el formulario de login
     */
    private void mostrarLogin(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Si ya está autenticado, redirigir al inicio
        if (SessionUtil.isAuthenticated(request)) {
            response.sendRedirect(request.getContextPath() + "/");
            return;
        }

        // Verificar si hay mensaje de la URL
        String mensaje = request.getParameter("mensaje");
        String error = request.getParameter("error");

        if ("registro_exitoso".equals(mensaje)) {
            request.setAttribute("mensaje", "¡Registro exitoso! Ahora puedes iniciar sesión.");
        } else if ("sesion_cerrada".equals(mensaje)) {
            request.setAttribute("mensaje", "Has cerrado sesión correctamente.");
        } else if ("sesion_requerida".equals(error)) {
            request.setAttribute("error", "Debes iniciar sesión para acceder a esa página.");
        }

        request.getRequestDispatcher("/views/login.jsp").forward(request, response);
    }

    /**
     * Muestra el formulario de registro
     */
    private void mostrarRegistro(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Si ya está autenticado, redirigir al inicio
        if (SessionUtil.isAuthenticated(request)) {
            response.sendRedirect(request.getContextPath() + "/");
            return;
        }

        request.getRequestDispatcher("/views/registro.jsp").forward(request, response);
    }

    /**
     * Muestra el perfil del usuario
     */
    private void mostrarPerfil(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Verificar autenticación (el filtro ya lo hace, pero por seguridad)
        if (!SessionUtil.isAuthenticated(request)) {
            response.sendRedirect(request.getContextPath() + "/login?error=sesion_requerida");
            return;
        }

        try {
            Integer idUsuario = SessionUtil.getIdUsuario(request);

            // Obtener usuario actualizado de la base de datos
            Usuario usuario = usuarioService.obtenerUsuarioPorId(idUsuario);

            // Actualizar usuario en sesión
            request.getSession().setAttribute("usuario", usuario);

            logger.debug("Mostrando perfil de usuario ID: {}", idUsuario);

            request.getRequestDispatcher("/views/usuario/perfil.jsp").forward(request, response);

        } catch (ServiceException e) {
            logger.error("Error al obtener perfil: {}", e.getMessage());
            request.setAttribute("error", "Error al cargar el perfil");
            request.getRequestDispatcher("/views/usuario/perfil.jsp").forward(request, response);
        }
    }

    // ==================== MÉTODOS POST ====================

    /**
     * Procesa el formulario de login
     */
    private void procesarLogin(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String recordar = request.getParameter("recordar");

        logger.info("Intento de login: {}", email);

        // Validaciones básicas
        if (email == null || email.trim().isEmpty()) {
            request.setAttribute("error", "El email es requerido");
            request.getRequestDispatcher("/views/login.jsp").forward(request, response);
            return;
        }

        if (password == null || password.isEmpty()) {
            request.setAttribute("error", "La contraseña es requerida");
            request.setAttribute("email", email);
            request.getRequestDispatcher("/views/login.jsp").forward(request, response);
            return;
        }

        try {
            // Autenticar usuario
            Usuario usuario = usuarioService.autenticarUsuario(email, password);

            // Crear sesión
            boolean mantenerSesion = "on".equals(recordar) || "true".equals(recordar);
            SessionUtil.createSession(request, usuario, mantenerSesion);

            logger.info("Login exitoso: {}", email);

            // Redirigir según rol o URL de retorno
            String returnUrl = SessionUtil.getReturnUrl(request);

            if (returnUrl != null && !returnUrl.isEmpty()) {
                response.sendRedirect(request.getContextPath() + returnUrl);
            } else if (SessionUtil.isAdmin(request)) {
                response.sendRedirect(request.getContextPath() + "/admin/dashboard");
            } else {
                response.sendRedirect(request.getContextPath() + "/");
            }

        } catch (ServiceException e) {
            logger.warn("Login fallido para {}: {}", email, e.getMessage());
            request.setAttribute("error", e.getMessage());
            request.setAttribute("email", email);
            request.getRequestDispatcher("/views/login.jsp").forward(request, response);
        }
    }

    /**
     * Procesa el formulario de registro
     */
    private void procesarRegistro(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Obtener parámetros
        String nombre = request.getParameter("nombre");
        String apellido = request.getParameter("apellido");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");
        String telefono = request.getParameter("telefono");
        String direccion = request.getParameter("direccion");

        logger.info("Intento de registro: {}", email);

        try {
            // Crear objeto usuario
            Usuario nuevoUsuario = new Usuario();
            nuevoUsuario.setNombre(nombre);
            nuevoUsuario.setApellido(apellido);
            nuevoUsuario.setEmail(email);
            nuevoUsuario.setPassword(password);
            nuevoUsuario.setTelefono(telefono);
            nuevoUsuario.setDireccion(direccion);
            nuevoUsuario.setRol(Usuario.RolUsuario.CLIENTE);

            // Registrar
            int idUsuario = usuarioService.registrarUsuario(nuevoUsuario, confirmPassword);

            logger.info("Registro exitoso - ID: {}, Email: {}", idUsuario, email);

            // Redirigir a login con mensaje de éxito
            response.sendRedirect(request.getContextPath() + "/login?mensaje=registro_exitoso");

        } catch (ServiceException e) {
            logger.warn("Registro fallido para {}: {}", email, e.getMessage());

            // Devolver datos al formulario (excepto contraseñas)
            request.setAttribute("error", e.getMessage());
            request.setAttribute("nombre", nombre);
            request.setAttribute("apellido", apellido);
            request.setAttribute("email", email);
            request.setAttribute("telefono", telefono);
            request.setAttribute("direccion", direccion);

            request.getRequestDispatcher("/views/registro.jsp").forward(request, response);
        }
    }

    /**
     * Procesa el cierre de sesión
     */
    private void procesarLogout(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        String email = "";
        if (SessionUtil.isAuthenticated(request)) {
            Usuario usuario = SessionUtil.getUsuario(request).orElse(null);
            if (usuario != null) {
                email = usuario.getEmail();
            }
        }

        SessionUtil.destroySession(request);
        logger.info("Logout exitoso: {}", email);

        response.sendRedirect(request.getContextPath() + "/login?mensaje=sesion_cerrada");
    }

    /**
     * Procesa la actualización del perfil
     */
    private void procesarActualizarPerfil(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!SessionUtil.isAuthenticated(request)) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        Integer idUsuario = SessionUtil.getIdUsuario(request);

        String nombre = request.getParameter("nombre");
        String apellido = request.getParameter("apellido");
        String email = request.getParameter("email");
        String telefono = request.getParameter("telefono");
        String direccion = request.getParameter("direccion");

        logger.debug("Actualizando perfil de usuario ID: {}", idUsuario);

        try {
            // Obtener usuario actual para mantener datos que no se modifican
            Usuario usuarioActual = usuarioService.obtenerUsuarioPorId(idUsuario);

            // Actualizar datos
            usuarioActual.setNombre(nombre);
            usuarioActual.setApellido(apellido);
            usuarioActual.setEmail(email);
            usuarioActual.setTelefono(telefono);
            usuarioActual.setDireccion(direccion);

            usuarioService.actualizarPerfil(usuarioActual);

            // Actualizar sesión
            SessionUtil.updateSession(request, usuarioActual);

            logger.info("Perfil actualizado: {}", email);

            request.setAttribute("mensaje", "Perfil actualizado correctamente");
            request.setAttribute("tabActiva", "info");
            request.getRequestDispatcher("/views/usuario/perfil.jsp").forward(request, response);

        } catch (ServiceException e) {
            logger.error("Error al actualizar perfil: {}", e.getMessage());

            request.setAttribute("error", e.getMessage());
            request.setAttribute("tabActiva", "info");

            // Intentar cargar usuario actual
            try {
                Usuario usuario = usuarioService.obtenerUsuarioPorId(idUsuario);
                request.getSession().setAttribute("usuario", usuario);
            } catch (ServiceException ex) {
                logger.error("Error al recargar usuario: {}", ex.getMessage());
            }

            request.getRequestDispatcher("/views/usuario/perfil.jsp").forward(request, response);
        }
    }

    /**
     * Procesa el cambio de contraseña
     */
    private void procesarCambiarPassword(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!SessionUtil.isAuthenticated(request)) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        Integer idUsuario = SessionUtil.getIdUsuario(request);

        String passwordActual = request.getParameter("passwordActual");
        String nuevaPassword = request.getParameter("nuevaPassword");
        String confirmarPassword = request.getParameter("confirmarPassword");

        logger.debug("Cambiando contraseña para usuario ID: {}", idUsuario);

        try {
            usuarioService.cambiarPassword(idUsuario, passwordActual, nuevaPassword, confirmarPassword);

            logger.info("Contraseña cambiada para usuario ID: {}", idUsuario);

            request.setAttribute("mensaje", "Contraseña actualizada correctamente");
            request.setAttribute("tabActiva", "password");
            request.getRequestDispatcher("/views/usuario/perfil.jsp").forward(request, response);

        } catch (ServiceException e) {
            logger.error("Error al cambiar contraseña: {}", e.getMessage());

            request.setAttribute("error", e.getMessage());
            request.setAttribute("tabActiva", "password");
            request.getRequestDispatcher("/views/usuario/perfil.jsp").forward(request, response);
        }
    }
}