package com.techzone.ecommerce.techzone.dao;

import com.techzone.ecommerce.techzone.config.DatabaseConnection;
import com.techzone.ecommerce.techzone.model.Resena;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

/**
 * DAO para la gestión de reseñas de productos
 * @author TechZone Team
 */
public class ResenaDAO {

    private final DatabaseConnection dbConnection;

    public ResenaDAO() {
        this.dbConnection = DatabaseConnection.getInstance();
    }

    // ==================== CREATE ====================

    /**
     * Crea una nueva reseña
     */
    public int crear(Resena resena) throws SQLException {
        String sql = "INSERT INTO resenas (id_producto, id_usuario, calificacion, comentario, fecha) " +
                "VALUES (?, ?, ?, ?, ?)";

        try (Connection conn = dbConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            pstmt.setInt(1, resena.getIdProducto());
            pstmt.setInt(2, resena.getIdUsuario());
            pstmt.setInt(3, resena.getCalificacion());
            pstmt.setString(4, resena.getComentario());
            pstmt.setTimestamp(5, Timestamp.valueOf(resena.getFecha()));

            int affectedRows = pstmt.executeUpdate();

            if (affectedRows == 0) {
                throw new SQLException("No se pudo crear la reseña");
            }

            try (ResultSet generatedKeys = pstmt.getGeneratedKeys()) {
                if (generatedKeys.next()) {
                    int id = generatedKeys.getInt(1);
                    resena.setIdResena(id);
                    return id;
                }
            }

            throw new SQLException("No se pudo obtener el ID generado");
        }
    }

    // ==================== READ ====================

    /**
     * Busca una reseña por su ID
     */
    public Optional<Resena> buscarPorId(int id) throws SQLException {
        String sql = "SELECT * FROM resenas WHERE id_resena = ?";

        try (Connection conn = dbConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, id);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return Optional.of(mapearResena(rs));
                }
            }
        }

        return Optional.empty();
    }

    /**
     * Obtiene todas las reseñas de un producto
     */
    public List<Resena> obtenerPorProducto(int idProducto) throws SQLException {
        String sql = "SELECT * FROM resenas WHERE id_producto = ? ORDER BY fecha DESC";
        List<Resena> resenas = new ArrayList<>();

        try (Connection conn = dbConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, idProducto);

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    resenas.add(mapearResena(rs));
                }
            }
        }

        return resenas;
    }

    /**
     * Obtiene reseñas con información de usuario (JOIN)
     */
    public List<Resena> obtenerConUsuarioPorProducto(int idProducto) throws SQLException {
        String sql = "SELECT r.*, u.nombre, u.apellido, u.email " +
                "FROM resenas r " +
                "INNER JOIN usuarios u ON r.id_usuario = u.id_usuario " +
                "WHERE r.id_producto = ? " +
                "ORDER BY r.fecha DESC";
        List<Resena> resenas = new ArrayList<>();

        try (Connection conn = dbConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, idProducto);

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    resenas.add(mapearResena(rs));
                }
            }
        }

        return resenas;
    }

    /**
     * Obtiene todas las reseñas de un usuario
     */
    public List<Resena> obtenerPorUsuario(int idUsuario) throws SQLException {
        String sql = "SELECT * FROM resenas WHERE id_usuario = ? ORDER BY fecha DESC";
        List<Resena> resenas = new ArrayList<>();

        try (Connection conn = dbConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, idUsuario);

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    resenas.add(mapearResena(rs));
                }
            }
        }

        return resenas;
    }

    /**
     * Obtiene reseñas por calificación
     */
    public List<Resena> obtenerPorCalificacion(int idProducto, int calificacion) throws SQLException {
        String sql = "SELECT * FROM resenas WHERE id_producto = ? AND calificacion = ? " +
                "ORDER BY fecha DESC";
        List<Resena> resenas = new ArrayList<>();

        try (Connection conn = dbConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, idProducto);
            pstmt.setInt(2, calificacion);

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    resenas.add(mapearResena(rs));
                }
            }
        }

        return resenas;
    }

    /**
     * Obtiene las reseñas más recientes
     */
    public List<Resena> obtenerRecientes(int limite) throws SQLException {
        String sql = "SELECT * FROM resenas ORDER BY fecha DESC LIMIT ?";
        List<Resena> resenas = new ArrayList<>();

        try (Connection conn = dbConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, limite);

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    resenas.add(mapearResena(rs));
                }
            }
        }

        return resenas;
    }

    // ==================== UPDATE ====================

    /**
     * Actualiza una reseña existente
     */
    public boolean actualizar(Resena resena) throws SQLException {
        String sql = "UPDATE resenas SET calificacion=?, comentario=? WHERE id_resena=?";

        try (Connection conn = dbConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, resena.getCalificacion());
            pstmt.setString(2, resena.getComentario());
            pstmt.setInt(3, resena.getIdResena());

            return pstmt.executeUpdate() > 0;
        }
    }

    // ==================== DELETE ====================

    /**
     * Elimina una reseña
     */
    public boolean eliminar(int idResena) throws SQLException {
        String sql = "DELETE FROM resenas WHERE id_resena = ?";

        try (Connection conn = dbConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, idResena);
            return pstmt.executeUpdate() > 0;
        }
    }

    /**
     * Elimina todas las reseñas de un producto
     */
    public boolean eliminarPorProducto(int idProducto) throws SQLException {
        String sql = "DELETE FROM resenas WHERE id_producto = ?";

        try (Connection conn = dbConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, idProducto);
            return pstmt.executeUpdate() > 0;
        }
    }

    /**
     * Elimina todas las reseñas de un usuario
     */
    public boolean eliminarPorUsuario(int idUsuario) throws SQLException {
        String sql = "DELETE FROM resenas WHERE id_usuario = ?";

        try (Connection conn = dbConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, idUsuario);
            return pstmt.executeUpdate() > 0;
        }
    }

    // ==================== UTILIDADES ====================

    /**
     * Cuenta las reseñas de un producto
     */
    public int contarPorProducto(int idProducto) throws SQLException {
        String sql = "SELECT COUNT(*) FROM resenas WHERE id_producto = ?";

        try (Connection conn = dbConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, idProducto);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }

        return 0;
    }

    /**
     * Calcula la calificación promedio de un producto
     */
    public double calcularPromedioCalificacion(int idProducto) throws SQLException {
        String sql = "SELECT AVG(calificacion) FROM resenas WHERE id_producto = ?";

        try (Connection conn = dbConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, idProducto);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getDouble(1);
                }
            }
        }

        return 0.0;
    }

    /**
     * Verifica si un usuario ya ha reseñado un producto
     */
    public boolean yaReseno(int idUsuario, int idProducto) throws SQLException {
        String sql = "SELECT COUNT(*) FROM resenas WHERE id_usuario = ? AND id_producto = ?";

        try (Connection conn = dbConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, idUsuario);
            pstmt.setInt(2, idProducto);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        }

        return false;
    }

    /**
     * Obtiene la distribución de calificaciones de un producto
     */
    public int[] obtenerDistribucionCalificaciones(int idProducto) throws SQLException {
        int[] distribucion = new int[5]; // [0] = 1 estrella, [4] = 5 estrellas
        String sql = "SELECT calificacion, COUNT(*) as cantidad FROM resenas " +
                "WHERE id_producto = ? GROUP BY calificacion";

        try (Connection conn = dbConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, idProducto);

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    int calificacion = rs.getInt("calificacion");
                    int cantidad = rs.getInt("cantidad");
                    if (calificacion >= 1 && calificacion <= 5) {
                        distribucion[calificacion - 1] = cantidad;
                    }
                }
            }
        }

        return distribucion;
    }

    // ==================== MAPEO ====================

    /**
     * Mapea un ResultSet a un objeto Resena
     */
    private Resena mapearResena(ResultSet rs) throws SQLException {
        Resena resena = new Resena();

        resena.setIdResena(rs.getInt("id_resena"));
        resena.setIdProducto(rs.getInt("id_producto"));
        resena.setIdUsuario(rs.getInt("id_usuario"));
        resena.setCalificacion(rs.getInt("calificacion"));
        resena.setComentario(rs.getString("comentario"));

        Timestamp timestamp = rs.getTimestamp("fecha");
        if (timestamp != null) {
            resena.setFecha(timestamp.toLocalDateTime());
        }

        return resena;
    }
}