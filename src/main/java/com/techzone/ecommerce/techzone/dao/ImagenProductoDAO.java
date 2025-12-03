package com.techzone.ecommerce.techzone.dao;

import com.techzone.ecommerce.techzone.config.DatabaseConnection;
import com.techzone.ecommerce.techzone.model.ImagenProducto;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

/**
 * DAO para la gestión de imágenes de productos
 * @author TechZone Team
 */
public class ImagenProductoDAO {

    private final DatabaseConnection dbConnection;

    public ImagenProductoDAO() {
        this.dbConnection = DatabaseConnection.getInstance();
    }

    // ==================== CREATE ====================

    /**
     * Crea una nueva imagen de producto
     */
    public int crear(ImagenProducto imagen) throws SQLException {
        String sql = "INSERT INTO imagenes_producto (id_producto, url_imagen, es_principal, orden, fecha_subida) " +
                "VALUES (?, ?, ?, ?, ?)";

        try (Connection conn = dbConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            pstmt.setInt(1, imagen.getIdProducto());
            pstmt.setString(2, imagen.getUrlImagen());
            pstmt.setBoolean(3, imagen.getEsPrincipal());
            pstmt.setInt(4, imagen.getOrden());
            pstmt.setTimestamp(5, Timestamp.valueOf(imagen.getFechaSubida()));

            int affectedRows = pstmt.executeUpdate();

            if (affectedRows == 0) {
                throw new SQLException("No se pudo crear la imagen");
            }

            try (ResultSet generatedKeys = pstmt.getGeneratedKeys()) {
                if (generatedKeys.next()) {
                    int id = generatedKeys.getInt(1);
                    imagen.setIdImagen(id);
                    return id;
                }
            }

            throw new SQLException("No se pudo obtener el ID generado");
        }
    }

    /**
     * Crea múltiples imágenes para un producto
     */
    public boolean crearMultiples(List<ImagenProducto> imagenes) throws SQLException {
        String sql = "INSERT INTO imagenes_producto (id_producto, url_imagen, es_principal, orden, fecha_subida) " +
                "VALUES (?, ?, ?, ?, ?)";

        Connection conn = null;
        PreparedStatement pstmt = null;

        try {
            conn = dbConnection.getConnection();
            conn.setAutoCommit(false);

            pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);

            for (ImagenProducto imagen : imagenes) {
                pstmt.setInt(1, imagen.getIdProducto());
                pstmt.setString(2, imagen.getUrlImagen());
                pstmt.setBoolean(3, imagen.getEsPrincipal());
                pstmt.setInt(4, imagen.getOrden());
                pstmt.setTimestamp(5, Timestamp.valueOf(imagen.getFechaSubida()));
                pstmt.addBatch();
            }

            pstmt.executeBatch();
            conn.commit();

            return true;

        } catch (SQLException e) {
            if (conn != null) {
                conn.rollback();
            }
            throw e;
        } finally {
            if (conn != null) {
                conn.setAutoCommit(true);
            }
            if (pstmt != null) {
                pstmt.close();
            }
        }
    }

    // ==================== READ ====================

    /**
     * Busca una imagen por su ID
     */
    public Optional<ImagenProducto> buscarPorId(int id) throws SQLException {
        String sql = "SELECT * FROM imagenes_producto WHERE id_imagen = ?";

        try (Connection conn = dbConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, id);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return Optional.of(mapearImagen(rs));
                }
            }
        }

        return Optional.empty();
    }

    /**
     * Obtiene todas las imágenes de un producto
     */
    public List<ImagenProducto> obtenerPorProducto(int idProducto) throws SQLException {
        String sql = "SELECT * FROM imagenes_producto WHERE id_producto = ? ORDER BY orden, es_principal DESC";
        List<ImagenProducto> imagenes = new ArrayList<>();

        try (Connection conn = dbConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, idProducto);

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    imagenes.add(mapearImagen(rs));
                }
            }
        }

        return imagenes;
    }

    /**
     * Obtiene la imagen principal de un producto
     */
    public Optional<ImagenProducto> obtenerPrincipalPorProducto(int idProducto) throws SQLException {
        String sql = "SELECT * FROM imagenes_producto WHERE id_producto = ? AND es_principal = true LIMIT 1";

        try (Connection conn = dbConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, idProducto);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return Optional.of(mapearImagen(rs));
                }
            }
        }

        // Si no hay imagen principal, devolver la primera
        String sqlAlternativa = "SELECT * FROM imagenes_producto WHERE id_producto = ? ORDER BY orden LIMIT 1";

        try (Connection conn = dbConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sqlAlternativa)) {

            pstmt.setInt(1, idProducto);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return Optional.of(mapearImagen(rs));
                }
            }
        }

        return Optional.empty();
    }

    /**
     * Obtiene todas las imágenes
     */
    public List<ImagenProducto> obtenerTodas() throws SQLException {
        String sql = "SELECT * FROM imagenes_producto ORDER BY id_producto, orden";
        List<ImagenProducto> imagenes = new ArrayList<>();

        try (Connection conn = dbConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {

            while (rs.next()) {
                imagenes.add(mapearImagen(rs));
            }
        }

        return imagenes;
    }

    // ==================== UPDATE ====================

    /**
     * Actualiza una imagen existente
     */
    public boolean actualizar(ImagenProducto imagen) throws SQLException {
        String sql = "UPDATE imagenes_producto SET id_producto=?, url_imagen=?, es_principal=?, orden=? " +
                "WHERE id_imagen=?";

        try (Connection conn = dbConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, imagen.getIdProducto());
            pstmt.setString(2, imagen.getUrlImagen());
            pstmt.setBoolean(3, imagen.getEsPrincipal());
            pstmt.setInt(4, imagen.getOrden());
            pstmt.setInt(5, imagen.getIdImagen());

            return pstmt.executeUpdate() > 0;
        }
    }

    /**
     * Establece una imagen como principal (y desmarca las demás)
     */
    public boolean establecerComoPrincipal(int idImagen, int idProducto) throws SQLException {
        Connection conn = null;
        PreparedStatement pstmt1 = null;
        PreparedStatement pstmt2 = null;

        try {
            conn = dbConnection.getConnection();
            conn.setAutoCommit(false);

            // Desmarcar todas las imágenes del producto como principales
            String sql1 = "UPDATE imagenes_producto SET es_principal = false WHERE id_producto = ?";
            pstmt1 = conn.prepareStatement(sql1);
            pstmt1.setInt(1, idProducto);
            pstmt1.executeUpdate();

            // Marcar la imagen seleccionada como principal
            String sql2 = "UPDATE imagenes_producto SET es_principal = true WHERE id_imagen = ?";
            pstmt2 = conn.prepareStatement(sql2);
            pstmt2.setInt(1, idImagen);
            pstmt2.executeUpdate();

            conn.commit();
            return true;

        } catch (SQLException e) {
            if (conn != null) {
                conn.rollback();
            }
            throw e;
        } finally {
            if (conn != null) {
                conn.setAutoCommit(true);
            }
            if (pstmt1 != null) {
                pstmt1.close();
            }
            if (pstmt2 != null) {
                pstmt2.close();
            }
        }
    }

    /**
     * Actualiza el orden de una imagen
     */
    public boolean actualizarOrden(int idImagen, int nuevoOrden) throws SQLException {
        String sql = "UPDATE imagenes_producto SET orden = ? WHERE id_imagen = ?";

        try (Connection conn = dbConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, nuevoOrden);
            pstmt.setInt(2, idImagen);

            return pstmt.executeUpdate() > 0;
        }
    }

    // ==================== DELETE ====================

    /**
     * Elimina una imagen
     */
    public boolean eliminar(int idImagen) throws SQLException {
        String sql = "DELETE FROM imagenes_producto WHERE id_imagen = ?";

        try (Connection conn = dbConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, idImagen);
            return pstmt.executeUpdate() > 0;
        }
    }

    /**
     * Elimina todas las imágenes de un producto
     */
    public boolean eliminarPorProducto(int idProducto) throws SQLException {
        String sql = "DELETE FROM imagenes_producto WHERE id_producto = ?";

        try (Connection conn = dbConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, idProducto);
            return pstmt.executeUpdate() > 0;
        }
    }

    // ==================== UTILIDADES ====================

    /**
     * Cuenta las imágenes de un producto
     */
    public int contarPorProducto(int idProducto) throws SQLException {
        String sql = "SELECT COUNT(*) FROM imagenes_producto WHERE id_producto = ?";

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
     * Verifica si un producto tiene imágenes
     */
    public boolean tieneImagenes(int idProducto) throws SQLException {
        return contarPorProducto(idProducto) > 0;
    }

    /**
     * Obtiene el siguiente orden disponible para un producto
     */
    public int obtenerSiguienteOrden(int idProducto) throws SQLException {
        String sql = "SELECT MAX(orden) FROM imagenes_producto WHERE id_producto = ?";

        try (Connection conn = dbConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, idProducto);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) + 1;
                }
            }
        }

        return 0;
    }

    // ==================== MAPEO ====================

    /**
     * Mapea un ResultSet a un objeto ImagenProducto
     */
    private ImagenProducto mapearImagen(ResultSet rs) throws SQLException {
        ImagenProducto imagen = new ImagenProducto();

        imagen.setIdImagen(rs.getInt("id_imagen"));
        imagen.setIdProducto(rs.getInt("id_producto"));
        imagen.setUrlImagen(rs.getString("url_imagen"));
        imagen.setEsPrincipal(rs.getBoolean("es_principal"));
        imagen.setOrden(rs.getInt("orden"));

        Timestamp timestamp = rs.getTimestamp("fecha_subida");
        if (timestamp != null) {
            imagen.setFechaSubida(timestamp.toLocalDateTime());
        }

        return imagen;
    }
}