package com.techzone.ecommerce.techzone.service;

import com.google.protobuf.ServiceException;
import com.techzone.ecommerce.techzone.dao.UsuarioDAO;
import com.techzone.ecommerce.techzone.model.Usuario;
import com.techzone.ecommerce.techzone.util.PasswordUtil;
import com.techzone.ecommerce.techzone.util.ValidationUtil;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.sql.SQLException;
import java.util.List;
import java.util.Optional;

/**
 * Servicio de lógica de negocio para gestión de usuarios
 * @author TechZone Team
 */
public class UsuarioService {

    private static final Logger logger = LoggerFactory.getLogger(UsuarioService.class);
    private final UsuarioDAO usuarioDAO;

    public UsuarioService() {
        this.usuarioDAO = new UsuarioDAO();
    }

    // ==================== REGISTRO Y AUTENTICACIÓN ====================

    /**
     * Registra un nuevo usuario en el sistema
     * @param usuario Usuario a registrar (con password en texto plano)
     * @param confirmPassword Confirmación de contraseña
     * @return ID del usuario creado
     * @throws ServiceException Si hay error en validación o creación
     */
    public int registrarUsuario(Usuario usuario, String confirmPassword) throws ServiceException {
        logger.info("Iniciando registro de usuario: {}", usuario.getEmail());

        try {
            // Validación de datos básicos
            validarDatosUsuario(usuario);

            // Validar formato de email
            if (!ValidationUtil.isValidEmail(usuario.getEmail())) {
                throw new ServiceException("El formato del email no es válido");
            }

            // Validar que el email no exista
            if (usuarioDAO.existeEmail(usuario.getEmail())) {
                throw new ServiceException("El email ya está registrado");
            }

            // Validar contraseñas
            if (!usuario.getPassword().equals(confirmPassword)) {
                throw new ServiceException("Las contraseñas no coinciden");
            }

            if (!ValidationUtil.isValidPassword(usuario.getPassword())) {
                throw new ServiceException(
                        "La contraseña debe tener al menos 8 caracteres, " +
                                "incluyendo mayúsculas, minúsculas y números"
                );
            }

            // Hash de la contraseña
            String passwordHash = PasswordUtil.hashPassword(usuario.getPassword());
            usuario.setPassword(passwordHash);

            // Establecer valores por defecto
            if (usuario.getRol() == null) {
                usuario.setRol(Usuario.RolUsuario.CLIENTE);
            }
            usuario.setEstado(Usuario.EstadoUsuario.ACTIVO);

            // Crear usuario
            int idUsuario = usuarioDAO.crear(usuario);

            logger.info("Usuario registrado exitosamente con ID: {}", idUsuario);
            return idUsuario;

        } catch (SQLException e) {
            logger.error("Error al registrar usuario", e);
            throw new ServiceException("Error al registrar usuario: " + e.getMessage(), e);
        }
    }

    /**
     * Autentica un usuario con email y contraseña
     * @param email Email del usuario
     * @param password Contraseña en texto plano
     * @return Usuario autenticado si las credenciales son válidas
     * @throws ServiceException Si las credenciales son inválidas
     */
    public Usuario autenticarUsuario(String email, String password) throws ServiceException {
        logger.info("Intento de autenticación para: {}", email);

        try {
            // Validar campos no vacíos
            if (email == null || email.trim().isEmpty()) {
                throw new ServiceException("El email es requerido");
            }

            if (password == null || password.isEmpty()) {
                throw new ServiceException("La contraseña es requerida");
            }

            // Buscar usuario por email
            Optional<Usuario> usuarioOpt = usuarioDAO.buscarPorEmail(email);

            if (!usuarioOpt.isPresent()) {
                logger.warn("Intento de login con email no registrado: {}", email);
                throw new ServiceException("Email o contraseña incorrectos");
            }

            Usuario usuario = usuarioOpt.get();

            // Verificar estado activo
            if (usuario.getEstado() != Usuario.EstadoUsuario.ACTIVO) {
                logger.warn("Intento de login con cuenta inactiva: {}", email);
                throw new ServiceException("La cuenta está " + usuario.getEstado().name().toLowerCase());
            }

            // Verificar contraseña
            if (!PasswordUtil.checkPassword(password, usuario.getPassword())) {
                logger.warn("Intento de login con contraseña incorrecta: {}", email);
                throw new ServiceException("Email o contraseña incorrectos");
            }

            logger.info("Usuario autenticado exitosamente: {}", email);
            return usuario;

        } catch (SQLException e) {
            logger.error("Error al autenticar usuario", e);
            throw new ServiceException("Error al autenticar usuario", e);
        }
    }

    // ==================== GESTIÓN DE PERFIL ====================

    /**
     * Obtiene un usuario por su ID
     */
    public Usuario obtenerUsuarioPorId(int idUsuario) throws ServiceException {
        try {
            Optional<Usuario> usuario = usuarioDAO.buscarPorId(idUsuario);

            if (!usuario.isPresent()) {
                throw new ServiceException("Usuario no encontrado");
            }

            return usuario.get();

        } catch (SQLException e) {
            logger.error("Error al obtener usuario", e);
            throw new ServiceException("Error al obtener usuario", e);
        }
    }

    /**
     * Actualiza el perfil de un usuario
     * @param usuario Usuario con datos actualizados (sin cambiar password)
     */
    public void actualizarPerfil(Usuario usuario) throws ServiceException {
        logger.info("Actualizando perfil de usuario: {}", usuario.getIdUsuario());

        try {
            // Validar que el usuario existe
            Optional<Usuario> usuarioExistente = usuarioDAO.buscarPorId(usuario.getIdUsuario());
            if (!usuarioExistente.isPresent()) {
                throw new ServiceException("Usuario no encontrado");
            }

            // Validar datos
            validarDatosUsuario(usuario);

            // Verificar que el email no esté en uso por otro usuario
            Optional<Usuario> usuarioPorEmail = usuarioDAO.buscarPorEmail(usuario.getEmail());
            if (usuarioPorEmail.isPresent() &&
                    !usuarioPorEmail.get().getIdUsuario().equals(usuario.getIdUsuario())) {
                throw new ServiceException("El email ya está en uso por otro usuario");
            }

            // Preservar la contraseña actual (no se cambia en actualización de perfil)
            usuario.setPassword(usuarioExistente.get().getPassword());

            // Actualizar
            boolean actualizado = usuarioDAO.actualizar(usuario);

            if (!actualizado) {
                throw new ServiceException("No se pudo actualizar el perfil");
            }

            logger.info("Perfil actualizado exitosamente");

        } catch (SQLException e) {
            logger.error("Error al actualizar perfil", e);
            throw new ServiceException("Error al actualizar perfil", e);
        }
    }

    /**
     * Cambia la contraseña de un usuario
     */
    public void cambiarPassword(int idUsuario, String passwordActual,
                                String nuevaPassword, String confirmarPassword)
            throws ServiceException {
        logger.info("Cambiando contraseña para usuario: {}", idUsuario);

        try {
            // Obtener usuario
            Optional<Usuario> usuarioOpt = usuarioDAO.buscarPorId(idUsuario);
            if (!usuarioOpt.isPresent()) {
                throw new ServiceException("Usuario no encontrado");
            }

            Usuario usuario = usuarioOpt.get();

            // Verificar contraseña actual
            if (!PasswordUtil.checkPassword(passwordActual, usuario.getPassword())) {
                throw new ServiceException("La contraseña actual es incorrecta");
            }

            // Validar nueva contraseña
            if (!nuevaPassword.equals(confirmarPassword)) {
                throw new ServiceException("Las contraseñas nuevas no coinciden");
            }

            if (!ValidationUtil.isValidPassword(nuevaPassword)) {
                throw new ServiceException(
                        "La contraseña debe tener al menos 8 caracteres, " +
                                "incluyendo mayúsculas, minúsculas y números"
                );
            }

            // Hash de nueva contraseña
            String nuevoHash = PasswordUtil.hashPassword(nuevaPassword);

            // Actualizar
            boolean actualizado = usuarioDAO.actualizarPassword(idUsuario, nuevoHash);

            if (!actualizado) {
                throw new ServiceException("No se pudo cambiar la contraseña");
            }

            logger.info("Contraseña cambiada exitosamente");

        } catch (SQLException e) {
            logger.error("Error al cambiar contraseña", e);
            throw new ServiceException("Error al cambiar contraseña", e);
        }
    }

    // ==================== GESTIÓN ADMINISTRATIVA ====================

    /**
     * Lista todos los usuarios (solo admin)
     */
    public List<Usuario> listarTodosLosUsuarios() throws ServiceException {
        try {
            return usuarioDAO.obtenerTodos();
        } catch (SQLException e) {
            logger.error("Error al listar usuarios", e);
            throw new ServiceException("Error al listar usuarios", e);
        }
    }

    /**
     * Lista usuarios por rol
     */
    public List<Usuario> listarUsuariosPorRol(Usuario.RolUsuario rol) throws ServiceException {
        try {
            return usuarioDAO.obtenerPorRol(rol);
        } catch (SQLException e) {
            logger.error("Error al listar usuarios por rol", e);
            throw new ServiceException("Error al listar usuarios por rol", e);
        }
    }

    /**
     * Cambia el estado de un usuario (activar/desactivar/suspender)
     */
    public void cambiarEstadoUsuario(int idUsuario, Usuario.EstadoUsuario nuevoEstado)
            throws ServiceException {
        logger.info("Cambiando estado de usuario {} a {}", idUsuario, nuevoEstado);

        try {
            boolean actualizado = usuarioDAO.actualizarEstado(idUsuario, nuevoEstado);

            if (!actualizado) {
                throw new ServiceException("No se pudo cambiar el estado del usuario");
            }

            logger.info("Estado de usuario actualizado exitosamente");

        } catch (SQLException e) {
            logger.error("Error al cambiar estado de usuario", e);
            throw new ServiceException("Error al cambiar estado de usuario", e);
        }
    }

    /**
     * Elimina un usuario (solo admin, con precaución)
     */
    public void eliminarUsuario(int idUsuario) throws ServiceException {
        logger.warn("Eliminando usuario: {}", idUsuario);

        try {
            // Verificar que el usuario existe
            Optional<Usuario> usuario = usuarioDAO.buscarPorId(idUsuario);
            if (!usuario.isPresent()) {
                throw new ServiceException("Usuario no encontrado");
            }

            // Eliminar
            boolean eliminado = usuarioDAO.eliminar(idUsuario);

            if (!eliminado) {
                throw new ServiceException("No se pudo eliminar el usuario");
            }

            logger.info("Usuario eliminado exitosamente");

        } catch (SQLException e) {
            logger.error("Error al eliminar usuario", e);
            throw new ServiceException("Error al eliminar usuario: " + e.getMessage(), e);
        }
    }

    // ==================== UTILIDADES ====================

    /**
     * Obtiene estadísticas de usuarios
     */
    public UsuarioStats obtenerEstadisticas() throws ServiceException {
        try {
            int totalUsuarios = usuarioDAO.contarUsuarios();
            List<Usuario> activos = usuarioDAO.obtenerActivos();
            List<Usuario> clientes = usuarioDAO.obtenerPorRol(Usuario.RolUsuario.CLIENTE);
            List<Usuario> admins = usuarioDAO.obtenerPorRol(Usuario.RolUsuario.ADMIN);

            return new UsuarioStats(
                    totalUsuarios,
                    activos.size(),
                    clientes.size(),
                    admins.size()
            );

        } catch (SQLException e) {
            logger.error("Error al obtener estadísticas", e);
            throw new ServiceException("Error al obtener estadísticas", e);
        }
    }

    /**
     * Verifica si un email está disponible para registro
     */
    public boolean emailDisponible(String email) throws ServiceException {
        try {
            return !usuarioDAO.existeEmail(email);
        } catch (SQLException e) {
            logger.error("Error al verificar email", e);
            throw new ServiceException("Error al verificar email", e);
        }
    }

    // ==================== VALIDACIONES PRIVADAS ====================

    /**
     * Valida los datos básicos de un usuario
     */
    private void validarDatosUsuario(Usuario usuario) throws ServiceException {
        if (usuario.getNombre() == null || usuario.getNombre().trim().isEmpty()) {
            throw new ServiceException("El nombre es requerido");
        }

        if (usuario.getApellido() == null || usuario.getApellido().trim().isEmpty()) {
            throw new ServiceException("El apellido es requerido");
        }

        if (usuario.getEmail() == null || usuario.getEmail().trim().isEmpty()) {
            throw new ServiceException("El email es requerido");
        }

        if (usuario.getPassword() == null || usuario.getPassword().isEmpty()) {
            throw new ServiceException("La contraseña es requerida");
        }

        // Validar longitudes
        if (usuario.getNombre().length() > 100) {
            throw new ServiceException("El nombre es demasiado largo (máximo 100 caracteres)");
        }

        if (usuario.getApellido().length() > 100) {
            throw new ServiceException("El apellido es demasiado largo (máximo 100 caracteres)");
        }

        if (usuario.getEmail().length() > 150) {
            throw new ServiceException("El email es demasiado largo (máximo 150 caracteres)");
        }

        // Validar teléfono si está presente
        if (usuario.getTelefono() != null && !usuario.getTelefono().isEmpty()) {
            if (!ValidationUtil.isValidPhone(usuario.getTelefono())) {
                throw new ServiceException("El formato del teléfono no es válido");
            }
        }
    }

    // ==================== CLASE INTERNA DE ESTADÍSTICAS ====================

    public static class UsuarioStats {
        private final int totalUsuarios;
        private final int usuariosActivos;
        private final int totalClientes;
        private final int totalAdmins;

        public UsuarioStats(int totalUsuarios, int usuariosActivos,
                            int totalClientes, int totalAdmins) {
            this.totalUsuarios = totalUsuarios;
            this.usuariosActivos = usuariosActivos;
            this.totalClientes = totalClientes;
            this.totalAdmins = totalAdmins;
        }

        public int getTotalUsuarios() { return totalUsuarios; }
        public int getUsuariosActivos() { return usuariosActivos; }
        public int getTotalClientes() { return totalClientes; }
        public int getTotalAdmins() { return totalAdmins; }
    }
}