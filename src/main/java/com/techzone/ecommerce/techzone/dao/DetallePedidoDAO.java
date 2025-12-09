package com.techzone.ecommerce.techzone.dao;

import com.techzone.ecommerce.techzone.config.DatabaseConnection;
import com.techzone.ecommerce.techzone.model.DetallePedido;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

/**
 * DAO para la gestión de detalles de pedidos
 * @author TechZone Team
 */
public class DetallePedidoDAO {

    private final DatabaseConnection dbConnection;

    public DetallePedidoDAO() {
        this.dbConnection = DatabaseConnection.getInstance();
    }

    // ==================== CREATE ====================

    /**
     * Crea un nuevo detalle de pedido
     */
    public int crear(DetallePedido detalle) throws SQLException {
        String sql = "INSERT INTO detalle_pedido (id_pedido, id_producto, cantidad, " +
                "precio_unitario, subtotal) VALUES (?, ?, ?, ?, ?)";

        try (Connection conn = dbConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            pstmt.setInt(1, detalle.getIdPedido());
            pstmt.setInt(2, detalle.getIdProducto());
            pstmt.setInt(3, detalle.getCantidad());
            pstmt.setBigDecimal(4, detalle.getPrecioUnitario());
            pstmt.setBigDecimal(5, detalle.getSubtotal());

            int affectedRows = pstmt.executeUpdate();

            if (affectedRows == 0) {
                throw new SQLException("No se pudo crear el detalle del pedido");
            }

            try (ResultSet generatedKeys = pstmt.getGeneratedKeys()) {
                if (generatedKeys.next()) {
                    int id = generatedKeys.getInt(1);
                    detalle.setIdDetalle(id);
                    return id;
                }
            }

            throw new SQLException("No se pudo obtener el ID generado");
        }
    }

    /**
     * Crea múltiples detalles de pedido en una transacción
     */
    public boolean crearMultiples(List<DetallePedido> detalles) throws SQLException {
        String sql = "INSERT INTO detalle_pedido (id_pedido, id_producto, cantidad, " +
                "precio_unitario, subtotal) VALUES (?, ?, ?, ?, ?)";

        Connection conn = null;
        PreparedStatement pstmt = null;

        try {
            conn = dbConnection.getConnection();
            conn.setAutoCommit(false); // Iniciar transacción

            pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);

            for (DetallePedido detalle : detalles) {
                pstmt.setInt(1, detalle.getIdPedido());
                pstmt.setInt(2, detalle.getIdProducto());
                pstmt.setInt(3, detalle.getCantidad());
                pstmt.setBigDecimal(4, detalle.getPrecioUnitario());
                pstmt.setBigDecimal(5, detalle.getSubtotal());
                pstmt.addBatch();
            }

            pstmt.executeBatch();
            conn.commit(); // Confirmar transacción

            return true;

        } catch (SQLException e) {
            if (conn != null) {
                conn.rollback(); // Revertir cambios en caso de error
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
     * Busca un detalle por su ID
     */
    public Optional<DetallePedido> buscarPorId(int id) throws SQLException {
        String sql = "SELECT * FROM detalle_pedido WHERE id_detalle = ?";

        try (Connection conn = dbConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, id);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return Optional.of(mapearDetalle(rs));
                }
            }
        }

        return Optional.empty();
    }

    /**
     * Obtiene todos los detalles de un pedido
     */
    public List<DetallePedido> obtenerPorPedido(int idPedido) throws SQLException {
        String sql = "SELECT * FROM detalle_pedido WHERE id_pedido = ?";
        List<DetallePedido> detalles = new ArrayList<>();

        try (Connection conn = dbConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, idPedido);

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    detalles.add(mapearDetalle(rs));
                }
            }
        }

        return detalles;
    }

    /**
     * Obtiene detalles con información del producto (JOIN)
     */
    public List<DetallePedido> obtenerConProductoPorPedido(int idPedido) throws SQLException {
        String sql = "SELECT dp.*, p.nombre, p.marca, p.modelo " +
                "FROM detalle_pedido dp " +
                "INNER JOIN productos p ON dp.id_producto = p.id_producto " +
                "WHERE dp.id_pedido = ?";
        List<DetallePedido> detalles = new ArrayList<>();

        try (Connection conn = dbConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, idPedido);

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    detalles.add(mapearDetalle(rs));
                }
            }
        }

        return detalles;
    }

    /**
     * Obtiene detalles por producto (para ver historial de ventas)
     */
    public List<DetallePedido> obtenerPorProducto(int idProducto) throws SQLException {
        String sql = "SELECT * FROM detalle_pedido WHERE id_producto = ?";
        List<DetallePedido> detalles = new ArrayList<>();

        try (Connection conn = dbConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, idProducto);

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    detalles.add(mapearDetalle(rs));
                }
            }
        }

        return detalles;
    }

    // ==================== UPDATE ====================

    /**
     * Actualiza un detalle de pedido
     */
    public boolean actualizar(DetallePedido detalle) throws SQLException {
        String sql = "UPDATE detalle_pedido SET id_pedido=?, id_producto=?, cantidad=?, " +
                "precio_unitario=?, subtotal=? WHERE id_detalle=?";

        try (Connection conn = dbConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, detalle.getIdPedido());
            pstmt.setInt(2, detalle.getIdProducto());
            pstmt.setInt(3, detalle.getCantidad());
            pstmt.setBigDecimal(4, detalle.getPrecioUnitario());
            pstmt.setBigDecimal(5, detalle.getSubtotal());
            pstmt.setInt(6, detalle.getIdDetalle());

            return pstmt.executeUpdate() > 0;
        }
    }

    /**
     * Actualiza la cantidad y recalcula el subtotal
     */
    public boolean actualizarCantidad(int idDetalle, int nuevaCantidad) throws SQLException {
        String sql = "UPDATE detalle_pedido SET cantidad = ?, subtotal = precio_unitario * ? " +
                "WHERE id_detalle = ?";

        try (Connection conn = dbConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, nuevaCantidad);
            pstmt.setInt(2, nuevaCantidad);
            pstmt.setInt(3, idDetalle);

            return pstmt.executeUpdate() > 0;
        }
    }

    // ==================== DELETE ====================

    /**
     * Elimina un detalle de pedido
     */
    public boolean eliminar(int idDetalle) throws SQLException {
        String sql = "DELETE FROM detalle_pedido WHERE id_detalle = ?";

        try (Connection conn = dbConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, idDetalle);
            return pstmt.executeUpdate() > 0;
        }
    }

    /**
     * Elimina todos los detalles de un pedido
     */
    public boolean eliminarPorPedido(int idPedido) throws SQLException {
        String sql = "DELETE FROM detalle_pedido WHERE id_pedido = ?";

        try (Connection conn = dbConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, idPedido);
            return pstmt.executeUpdate() > 0;
        }
    }

    // ==================== UTILIDADES ====================

    /**
     * Cuenta los detalles de un pedido
     */
    public int contarDetallesPorPedido(int idPedido) throws SQLException {
        String sql = "SELECT COUNT(*) FROM detalle_pedido WHERE id_pedido = ?";

        try (Connection conn = dbConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, idPedido);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }

        return 0;
    }

    /**
     * Cuenta cuántas veces se ha vendido un producto
     */
    public int contarVentasPorProducto(int idProducto) throws SQLException {
        String sql = "SELECT SUM(cantidad) FROM detalle_pedido WHERE id_producto = ?";

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

    /**
     * Mapea un ResultSet a un objeto DetallePedido
     */
    private DetallePedido mapearDetalle(ResultSet rs) throws SQLException {
        DetallePedido detalle = new DetallePedido();

        detalle.setIdDetalle(rs.getInt("id_detalle"));
        detalle.setIdPedido(rs.getInt("id_pedido"));
        detalle.setIdProducto(rs.getInt("id_producto"));
        detalle.setCantidad(rs.getInt("cantidad"));
        detalle.setPrecioUnitario(rs.getBigDecimal("precio_unitario"));
        detalle.setSubtotal(rs.getBigDecimal("subtotal"));

        return detalle;
    }
}