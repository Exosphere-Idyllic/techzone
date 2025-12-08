package com.techzone.ecommerce.techzone.dao;

import com.techzone.ecommerce.techzone.config.DatabaseConnection;
import com.techzone.ecommerce.techzone.model.Usuario;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

/**
 * DAO para la gestión de usuarios
 * Proporciona operaciones CRUD, autenticación y consultas estadísticas
 *
 * @author TechZone Team
 */
public class UsuarioDAO {

    private final DatabaseConnection dbConnection;

    public UsuarioDAO() {
        this.dbConnection = DatabaseConnection.getInstance();
    }

    // ==================== CREATE ====================

    /**
     * Crea un nuevo usuario en la base de datos
     * NOTA: En producción, asegurarse de que password esté hasheado
     *
     * @param usuario Objeto Usuario con los datos a insertar
     * @return ID del usuario creado
     * @throws SQLException Si hay error en la operación
     */
    public int crear(Usuario usuario) throws SQLException {
        String sql = "INSERT INTO usuarios (nombre, apellido, email, password, rol, estado, " +
                "fecha_registro, telefono, direccion) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = dbConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            pstmt.setString(1, usuario.getNombre());
            pstmt.setString(2, usuario.getApellido());
            pstmt.setString(3, usuario.getEmail());
            pstmt.setString(4, usuario.getPassword());
            pstmt.setString(5, usuario.getRol().name());
            pstmt.setString(6, usuario.getEstado().name());
            pstmt.setTimestamp(7, Timestamp.valueOf(usuario.getFechaRegistro()));
            pstmt.setString(8, usuario.getTelefono());
            pstmt.setString(9, usuario.getDireccion());

            int affectedRows = pstmt.executeUpdate();

            if (affectedRows == 0) {
                throw new SQLException("No se pudo crear el usuario");
            }

            try (ResultSet generatedKeys = pstmt.getGeneratedKeys()) {
                if (generatedKeys.next()) {
                    int id = generatedKeys.getInt(1);
                    usuario.setIdUsuario(id);
                    return id;
                }
            }

            throw new SQLException("No se pudo obtener el ID generado");
        }
    }

    // ==================== READ ====================

    /**
     * Busca un usuario por su ID
     *
     * @param id ID del usuario a buscar
     * @return Optional con el usuario si existe
     * @throws SQLException Si hay error en la consulta
     */
    public Optional<Usuario> buscarPorId(int id) throws SQLException {
        String sql = "SELECT * FROM usuarios WHERE id_usuario = ?";

        try (Connection conn = dbConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, id);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return Optional.of(mapearUsuario(rs));
                }
            }
        }

        return Optional.empty();
    }

    /**
     * Busca un usuario por su email
     * Útil para login y validación de email único
     *
     * @param email Email del usuario
     * @return Optional con el usuario si existe
     * @throws SQLException Si hay error en la consulta
     */
    public Optional<Usuario> buscarPorEmail(String email) throws SQLException {
        String sql = "SELECT * FROM usuarios WHERE email = ?";

        try (Connection conn = dbConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, email);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return Optional.of(mapearUsuario(rs));
                }
            }
        }

        return Optional.empty();
    }

    /**
     * Obtiene todos los usuarios ordenados por fecha de registro
     *
     * @return Lista de todos los usuarios
     * @throws SQLException Si hay error en la consulta
     */
    public List<Usuario> obtenerTodos() throws SQLException {
        String sql = "SELECT * FROM usuarios ORDER BY fecha_registro DESC";
        List<Usuario> usuarios = new ArrayList<>();

        try (Connection conn = dbConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {

            while (rs.next()) {
                usuarios.add(mapearUsuario(rs));
            }
        }

        return usuarios;
    }

    /**
     * Obtiene usuarios filtrados por rol
     *
     * @param rol Rol a filtrar (ADMIN, CLIENTE, VENDEDOR)
     * @return Lista de usuarios con ese rol
     * @throws SQLException Si hay error en la consulta
     */
    public List<Usuario> obtenerPorRol(Usuario.RolUsuario rol) throws SQLException {
        String sql = "SELECT * FROM usuarios WHERE rol = ? ORDER BY nombre, apellido";
        List<Usuario> usuarios = new ArrayList<>();

        try (Connection conn = dbConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, rol.name());

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    usuarios.add(mapearUsuario(rs));
                }
            }
        }

        return usuarios;
    }

    /**
     * Obtiene solo usuarios con estado ACTIVO
     *
     * @return Lista de usuarios activos
     * @throws SQLException Si hay error en la consulta
     */
    public List<Usuario> obtenerActivos() throws SQLException {
        String sql = "SELECT * FROM usuarios WHERE estado = 'ACTIVO' ORDER BY nombre, apellido";
        List<Usuario> usuarios = new ArrayList<>();

        try (Connection conn = dbConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {

            while (rs.next()) {
                usuarios.add(mapearUsuario(rs));
            }
        }

        return usuarios;
    }

    // ==================== UPDATE ====================

    /**
     * Actualiza todos los campos de un usuario existente
     *
     * @param usuario Objeto Usuario con los datos actualizados
     * @return true si se actualizó correctamente
     * @throws SQLException Si hay error en la operación
     */
    public boolean actualizar(Usuario usuario) throws SQLException {
        String sql = "UPDATE usuarios SET nombre=?, apellido=?, email=?, password=?, rol=?, " +
                "estado=?, telefono=?, direccion=? WHERE id_usuario=?";

        try (Connection conn = dbConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, usuario.getNombre());
            pstmt.setString(2, usuario.getApellido());
            pstmt.setString(3, usuario.getEmail());
            pstmt.setString(4, usuario.getPassword());
            pstmt.setString(5, usuario.getRol().name());
            pstmt.setString(6, usuario.getEstado().name());
            pstmt.setString(7, usuario.getTelefono());
            pstmt.setString(8, usuario.getDireccion());
            pstmt.setInt(9, usuario.getIdUsuario());

            return pstmt.executeUpdate() > 0;
        }
    }

    /**
     * Actualiza el estado de un usuario
     * Útil para activar/desactivar cuentas
     *
     * @param idUsuario ID del usuario
     * @param estado Nuevo estado
     * @return true si se actualizó correctamente
     * @throws SQLException Si hay error en la operación
     */
    public boolean actualizarEstado(int idUsuario, Usuario.EstadoUsuario estado) throws SQLException {
        String sql = "UPDATE usuarios SET estado = ? WHERE id_usuario = ?";

        try (Connection conn = dbConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, estado.name());
            pstmt.setInt(2, idUsuario);

            return pstmt.executeUpdate() > 0;
        }
    }

    /**
     * Actualiza solo la contraseña de un usuario
     * NOTA: Asegurarse de que el nuevo password esté hasheado
     *
     * @param idUsuario ID del usuario
     * @param nuevoPassword Nueva contraseña (hasheada)
     * @return true si se actualizó correctamente
     * @throws SQLException Si hay error en la operación
     */
    public boolean actualizarPassword(int idUsuario, String nuevoPassword) throws SQLException {
        String sql = "UPDATE usuarios SET password = ? WHERE id_usuario = ?";

        try (Connection conn = dbConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, nuevoPassword);
            pstmt.setInt(2, idUsuario);

            return pstmt.executeUpdate() > 0;
        }
    }

    // ==================== DELETE ====================

    /**
     * Elimina un usuario de la base de datos (físicamente)
     * CUIDADO: Esta operación es irreversible
     * Considerar usar actualizarEstado(id, INACTIVO) en su lugar
     *
     * @param idUsuario ID del usuario a eliminar
     * @return true si se eliminó correctamente
     * @throws SQLException Si hay error en la operación
     */
    public boolean eliminar(int idUsuario) throws SQLException {
        String sql = "DELETE FROM usuarios WHERE id_usuario = ?";

        try (Connection conn = dbConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, idUsuario);
            return pstmt.executeUpdate() > 0;
        }
    }

    // ==================== AUTENTICACIÓN ====================

    /**
     * Valida las credenciales de un usuario para login
     * NOTA: En producción, comparar password hasheado
     * Solo retorna usuarios con estado ACTIVO
     *
     * @param email Email del usuario
     * @param password Contraseña (en texto plano o hash según implementación)
     * @return Optional con el usuario si las credenciales son válidas
     * @throws SQLException Si hay error en la consulta
     */
    public Optional<Usuario> validarCredenciales(String email, String password) throws SQLException {
        String sql = "SELECT * FROM usuarios WHERE email = ? AND password = ? AND estado = 'ACTIVO'";

        try (Connection conn = dbConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, email);
            pstmt.setString(2, password);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return Optional.of(mapearUsuario(rs));
                }
            }
        }

        return Optional.empty();
    }

    // ==================== UTILIDADES Y CONTADORES ====================

    /**
     * Verifica si un email ya está registrado
     * Útil para validación durante el registro
     *
     * @param email Email a verificar
     * @return true si el email ya existe
     * @throws SQLException Si hay error en la consulta
     */
    public boolean existeEmail(String email) throws SQLException {
        String sql = "SELECT COUNT(*) FROM usuarios WHERE email = ?";

        try (Connection conn = dbConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, email);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        }

        return false;
    }

    /**
     * Cuenta el total de usuarios en el sistema
     *
     * @return Número total de usuarios
     * @throws SQLException Si hay error en la consulta
     */
    public int contarTodos() throws SQLException {
        String sql = "SELECT COUNT(*) FROM usuarios";

        try (Connection conn = dbConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {

            if (rs.next()) {
                return rs.getInt(1);
            }
        }

        return 0;
    }

    /**
     * Cuenta solo los usuarios con estado ACTIVO
     *
     * @return Número de usuarios activos
     * @throws SQLException Si hay error en la consulta
     */
    public int contarActivos() throws SQLException {
        String sql = "SELECT COUNT(*) FROM usuarios WHERE estado = 'ACTIVO'";

        try (Connection conn = dbConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {

            if (rs.next()) {
                return rs.getInt(1);
            }
        }

        return 0;
    }

    /**
     * Cuenta usuarios registrados hoy
     * Útil para dashboards y estadísticas
     *
     * @return Número de nuevos usuarios hoy
     * @throws SQLException Si hay error en la consulta
     */
    public int contarNuevosHoy() throws SQLException {
        String sql = "SELECT COUNT(*) FROM usuarios WHERE DATE(fecha_registro) = CURDATE()";

        try (Connection conn = dbConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {

            if (rs.next()) {
                return rs.getInt(1);
            }
        }

        return 0;
    }

    /**
     * Cuenta usuarios por rol
     *
     * @param rol Rol a contar
     * @return Número de usuarios con ese rol
     * @throws SQLException Si hay error en la consulta
     */
    public int contarPorRol(Usuario.RolUsuario rol) throws SQLException {
        String sql = "SELECT COUNT(*) FROM usuarios WHERE rol = ?";

        try (Connection conn = dbConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, rol.name());

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }

        return 0;
    }

    // ==================== MAPEO ====================

    /**
     * Mapea un ResultSet a un objeto Usuario
     * Convierte cada columna de la BD al campo correspondiente del modelo
     *
     * @param rs ResultSet con los datos del usuario
     * @return Objeto Usuario mapeado
     * @throws SQLException Si hay error al leer los datos
     */
    private Usuario mapearUsuario(ResultSet rs) throws SQLException {
        Usuario usuario = new Usuario();

        usuario.setIdUsuario(rs.getInt("id_usuario"));
        usuario.setNombre(rs.getString("nombre"));
        usuario.setApellido(rs.getString("apellido"));
        usuario.setEmail(rs.getString("email"));
        usuario.setPassword(rs.getString("password"));
        usuario.setRol(Usuario.RolUsuario.valueOf(rs.getString("rol")));
        usuario.setEstado(Usuario.EstadoUsuario.valueOf(rs.getString("estado")));

        Timestamp timestamp = rs.getTimestamp("fecha_registro");
        if (timestamp != null) {
            usuario.setFechaRegistro(timestamp.toLocalDateTime());
        }

        usuario.setTelefono(rs.getString("telefono"));
        usuario.setDireccion(rs.getString("direccion"));

        return usuario;
    }
    public int contarUsuarios() throws SQLException {
          return contarTodos();
    }
}