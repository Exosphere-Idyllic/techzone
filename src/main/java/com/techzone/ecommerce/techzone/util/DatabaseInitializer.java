package com.techzone.ecommerce.techzone.util;

import com.techzone.ecommerce.techzone.dao.UsuarioDAO;
import com.techzone.ecommerce.techzone.model.Usuario;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.sql.SQLException;
import java.util.Optional;

/**
 * Inicializador de datos de la base de datos
 * Crea usuarios por defecto con contraseñas encriptadas usando BCrypt
 *
 * @author TechZone Team
 */
public class DatabaseInitializer {

    private static final Logger logger = LoggerFactory.getLogger(DatabaseInitializer.class);
    private final UsuarioDAO usuarioDAO;

    public DatabaseInitializer() {
        this.usuarioDAO = new UsuarioDAO();
    }

    /**
     * Inicializa los usuarios por defecto del sistema
     * Solo crea usuarios si no existen
     */
    public void inicializarUsuarios() {
        logger.info("Iniciando inicialización de usuarios...");

        try {
            // 1. USUARIO ADMIN
            crearUsuarioSiNoExiste(
                    "admin@ecommerce.com",
                    "Admin",
                    "Sistema",
                    "admin123",
                    Usuario.RolUsuario.ADMIN,
                    "0999999999",
                    "Quito, Ecuador"
            );

            // 2. USUARIO CLIENTE 1
            crearUsuarioSiNoExiste(
                    "juan.perez@mail.com",
                    "Juan",
                    "Pérez",
                    "cliente123",
                    Usuario.RolUsuario.CLIENTE,
                    "0998888888",
                    "Av. Amazonas N34-451, Quito"
            );

            // 3. USUARIO CLIENTE 2
            crearUsuarioSiNoExiste(
                    "maria.gonzalez@mail.com",
                    "María",
                    "González",
                    "cliente123",
                    Usuario.RolUsuario.CLIENTE,
                    "0997777777",
                    "Calle García Moreno, Centro Histórico, Quito"
            );

            // 4. USUARIO VENDEDOR
            crearUsuarioSiNoExiste(
                    "carlos.rodriguez@mail.com",
                    "Carlos",
                    "Rodríguez",
                    "vendedor123",
                    Usuario.RolUsuario.VENDEDOR,
                    "0996666666",
                    "Av. 6 de Diciembre, Quito"
            );

            logger.info("Inicialización de usuarios completada exitosamente");

        } catch (Exception e) {
            logger.error("Error al inicializar usuarios: {}", e.getMessage(), e);
        }
    }

    /**
     * Crea un usuario solo si no existe en la base de datos
     */
    private void crearUsuarioSiNoExiste(
            String email,
            String nombre,
            String apellido,
            String passwordPlain,
            Usuario.RolUsuario rol,
            String telefono,
            String direccion
    ) throws SQLException {

        // Verificar si el usuario ya existe
        Optional<Usuario> usuarioExistente = usuarioDAO.buscarPorEmail(email);

        if (usuarioExistente.isPresent()) {
            logger.info("Usuario {} ya existe, omitiendo creación", email);
            return;
        }

        // Crear nuevo usuario
        Usuario usuario = new Usuario();
        usuario.setNombre(nombre);
        usuario.setApellido(apellido);
        usuario.setEmail(email);

        // ✅ ENCRIPTAR CONTRASEÑA CON BCRYPT
        String hashedPassword = PasswordUtil.hashPassword(passwordPlain);
        usuario.setPassword(hashedPassword);

        usuario.setRol(rol);
        usuario.setEstado(Usuario.EstadoUsuario.ACTIVO);
        usuario.setTelefono(telefono);
        usuario.setDireccion(direccion);

        // Guardar en la base de datos
        int idCreado = usuarioDAO.crear(usuario);

        logger.info("Usuario creado exitosamente: {} (ID: {})", email, idCreado);
        logger.debug("Password hash generado para {}: {}", email, hashedPassword.substring(0, 20) + "...");
    }

    /**
     * Método main para ejecutar la inicialización manualmente
     * Útil para setup inicial o re-inicialización
     */
    public static void main(String[] args) {
        logger.info("=================================================");
        logger.info("  INICIALIZACIÓN DE BASE DE DATOS - USUARIOS");
        logger.info("=================================================");

        DatabaseInitializer initializer = new DatabaseInitializer();
        initializer.inicializarUsuarios();

        logger.info("=================================================");
        logger.info("  PROCESO COMPLETADO");
        logger.info("=================================================");
        logger.info("");
        logger.info("Credenciales de acceso:");
        logger.info("  Admin:    admin@ecommerce.com / admin123");
        logger.info("  Cliente:  juan.perez@mail.com / cliente123");
        logger.info("  Vendedor: carlos.rodriguez@mail.com / vendedor123");
    }
}