package com.techzone.ecommerce.techzone.dao;

import com.techzone.ecommerce.techzone.config.DatabaseConnection;
import com.techzone.ecommerce.techzone.model.Usuario;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

/**
 * DAO para la gestión de usuarios
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
     * Obtiene todos los usuarios
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
     * Obtiene usuarios por rol
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
     * Obtiene usuarios activos
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
     * Actualiza un usuario existente
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
     * Actualiza la contraseña de un usuario
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
     * Elimina un usuario (físicamente)
     */
    public boolean eliminar(int idUsuario) throws SQLException {
        String sql = "DELETE FROM usuarios WHERE id_usuario = ?";

        try (Connection conn = dbConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, idUsuario);
            return pstmt.executeUpdate() > 0;
        }
    }

    // ==================== UTILIDADES ====================

    /**
     * Verifica si un email ya está registrado
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
     * Cuenta el total de usuarios
     */
    public int contarUsuarios() throws SQLException {
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
     * Valida las credenciales de un usuario (login)
     */
    public Optional<Usuario> validarCredenciales(String email, String password) throws SQLException {
        String sql = "SELECT * FROM usuarios WHERE email = ? AND password = ? AND estado = 'ACTIVO'";

        try (Connection conn = dbConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, email);
            pstmt.setString(2, password); // En producción, usar hash

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return Optional.of(mapearUsuario(rs));
                }
            }
        }

        return Optional.empty();
    }

    // ==================== MAPEO ====================

    /**
     * Mapea un ResultSet a un objeto Usuario
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
}