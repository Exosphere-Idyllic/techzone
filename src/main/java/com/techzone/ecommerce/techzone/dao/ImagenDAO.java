package com.techzone.ecommerce.techzone.dao;

import com.techzone.ecommerce.techzone.config.DatabaseConnection;
import com.techzone.ecommerce.techzone.model.Imagen;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

/**
 * DAO para la gestión de imágenes de productos
 * Tabla: imagenes_producto
 *
 * @author TechZone Team
 */
public class ImagenDAO {

    private final DatabaseConnection dbConnection;

    public ImagenDAO() {
        this.dbConnection = DatabaseConnection.getInstance();
    }

    // ==================== CREATE ====================

    public int crear(Imagen imagen) throws SQLException {
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

    // ==================== READ ====================

    public Optional<Imagen> buscarPorId(int id) throws SQLException {
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
    public List<Imagen> obtenerPorProducto(int idProducto) throws SQLException {
        String sql = "SELECT * FROM imagenes_producto WHERE id_producto = ? ORDER BY orden ASC";
        List<Imagen> imagenes = new ArrayList<>();

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
     * ✅ CLAVE: Obtiene imágenes de múltiples productos con UN SOLO QUERY
     * Esto reduce de 80+ queries a solo 1 query
     */
    public List<Imagen> obtenerPorProductos(List<Integer> idsProductos) throws SQLException {
        if (idsProductos == null || idsProductos.isEmpty()) {
            return new ArrayList<>();
        }

        // Crear placeholders: ?,?,?
        String placeholders = String.join(",",
                idsProductos.stream().map(id -> "?").toArray(String[]::new));

        String sql = "SELECT * FROM imagenes_producto WHERE id_producto IN (" + placeholders + ") " +
                "ORDER BY id_producto, orden ASC";

        List<Imagen> imagenes = new ArrayList<>();

        try (Connection conn = dbConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            // Setear cada ID
            for (int i = 0; i < idsProductos.size(); i++) {
                pstmt.setInt(i + 1, idsProductos.get(i));
            }

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
    public Optional<Imagen> obtenerPrincipal(int idProducto) throws SQLException {
        String sql = "SELECT * FROM imagenes_producto WHERE id_producto = ? AND es_principal = TRUE";

        try (Connection conn = dbConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, idProducto);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return Optional.of(mapearImagen(rs));
                }
            }
        }

        return obtenerPrimera(idProducto);
    }

    /**
     * Obtiene la primera imagen del producto
     */
    public Optional<Imagen> obtenerPrimera(int idProducto) throws SQLException {
        String sql = "SELECT * FROM imagenes_producto WHERE id_producto = ? ORDER BY orden ASC LIMIT 1";

        try (Connection conn = dbConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, idProducto);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return Optional.of(mapearImagen(rs));
                }
            }
        }

        return Optional.empty();
    }

    // ==================== UPDATE ====================

    public boolean actualizar(Imagen imagen) throws SQLException {
        String sql = "UPDATE imagenes_producto SET url_imagen=?, es_principal=?, orden=? WHERE id_imagen=?";

        try (Connection conn = dbConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, imagen.getUrlImagen());
            pstmt.setBoolean(2, imagen.getEsPrincipal());
            pstmt.setInt(3, imagen.getOrden());
            pstmt.setInt(4, imagen.getIdImagen());

            return pstmt.executeUpdate() > 0;
        }
    }

    /**
     * Establece una imagen como principal (y desmarca las demás del producto)
     */
    public boolean establecerComoPrincipal(int idImagen, int idProducto) throws SQLException {
        Connection conn = null;

        try {
            conn = dbConnection.getConnection();
            conn.setAutoCommit(false);

            // Desmarcar todas como principal
            String sql1 = "UPDATE imagenes_producto SET es_principal = FALSE WHERE id_producto = ?";
            try (PreparedStatement pstmt1 = conn.prepareStatement(sql1)) {
                pstmt1.setInt(1, idProducto);
                pstmt1.executeUpdate();
            }

            // Marcar la seleccionada como principal
            String sql2 = "UPDATE imagenes_producto SET es_principal = TRUE WHERE id_imagen = ?";
            try (PreparedStatement pstmt2 = conn.prepareStatement(sql2)) {
                pstmt2.setInt(1, idImagen);
                pstmt2.executeUpdate();
            }

            conn.commit();
            return true;

        } catch (SQLException e) {
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
            throw e;
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }
    }

    // ==================== DELETE ====================

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

    // ==================== MAPEO ====================

    private Imagen mapearImagen(ResultSet rs) throws SQLException {
        Imagen imagen = new Imagen();

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