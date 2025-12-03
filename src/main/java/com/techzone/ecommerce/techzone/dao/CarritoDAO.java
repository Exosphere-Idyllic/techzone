package com.techzone.ecommerce.techzone.dao;

import com.techzone.ecommerce.techzone.config.DatabaseConnection;
import com.techzone.ecommerce.techzone.model.Carrito;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

/**
 * DAO para la gestión del carrito de compras
 * @author TechZone Team
 */
public class CarritoDAO {

    private final DatabaseConnection dbConnection;

    public CarritoDAO() {
        this.dbConnection = DatabaseConnection.getInstance();
    }

    // ==================== CREATE ====================

    /**
     * Agrega un producto al carrito
     */
    public int agregar(Carrito carrito) throws SQLException {
        String sql = "INSERT INTO carrito (id_usuario, id_producto, cantidad, fecha_agregado) " +
                "VALUES (?, ?, ?, ?)";

        try (Connection conn = dbConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            pstmt.setInt(1, carrito.getIdUsuario());
            pstmt.setInt(2, carrito.getIdProducto());
            pstmt.setInt(3, carrito.getCantidad());
            pstmt.setTimestamp(4, Timestamp.valueOf(carrito.getFechaAgregado()));

            int affectedRows = pstmt.executeUpdate();

            if (affectedRows == 0) {
                throw new SQLException("No se pudo agregar al carrito");
            }

            try (ResultSet generatedKeys = pstmt.getGeneratedKeys()) {
                if (generatedKeys.next()) {
                    int id = generatedKeys.getInt(1);
                    carrito.setIdCarrito(id);
                    return id;
                }
            }

            throw new SQLException("No se pudo obtener el ID generado");
        }
    }

    /**
     * Agrega o actualiza un producto en el carrito
     * Si ya existe, suma la cantidad
     */
    public boolean agregarOActualizar(int idUsuario, int idProducto, int cantidad) throws SQLException {
        // Verificar si ya existe
        Optional<Carrito> existente = buscarPorUsuarioYProducto(idUsuario, idProducto);

        if (existente.isPresent()) {
            // Si existe, actualizar la cantidad
            Carrito carrito = existente.get();
            return actualizarCantidad(carrito.getIdCarrito(), carrito.getCantidad() + cantidad);
        } else {
            // Si no existe, crear nuevo
            Carrito nuevoCarrito = new Carrito(idUsuario, idProducto, cantidad);
            agregar(nuevoCarrito);
            return true;
        }
    }

    // ==================== READ ====================

    /**
     * Busca un item del carrito por ID
     */
    public Optional<Carrito> buscarPorId(int id) throws SQLException {
        String sql = "SELECT * FROM carrito WHERE id_carrito = ?";

        try (Connection conn = dbConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, id);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return Optional.of(mapearCarrito(rs));
                }
            }
        }

        return Optional.empty();
    }

    /**
     * Busca un item específico del carrito por usuario y producto
     */
    public Optional<Carrito> buscarPorUsuarioYProducto(int idUsuario, int idProducto) throws SQLException {
        String sql = "SELECT * FROM carrito WHERE id_usuario = ? AND id_producto = ?";

        try (Connection conn = dbConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, idUsuario);
            pstmt.setInt(2, idProducto);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return Optional.of(mapearCarrito(rs));
                }
            }
        }

        return Optional.empty();
    }

    /**
     * Obtiene todos los items del carrito de un usuario
     */
    public List<Carrito> obtenerPorUsuario(int idUsuario) throws SQLException {
        String sql = "SELECT * FROM carrito WHERE id_usuario = ? ORDER BY fecha_agregado DESC";
        List<Carrito> carritos = new ArrayList<>();

        try (Connection conn = dbConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, idUsuario);

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    carritos.add(mapearCarrito(rs));
                }
            }
        }

        return carritos;
    }

    /**
     * Obtiene el carrito con información de productos (JOIN)
     */
    public List<Carrito> obtenerConProductosPorUsuario(int idUsuario) throws SQLException {
        String sql = "SELECT c.*, p.nombre, p.precio, p.stock, p.marca, p.modelo, p.descuento " +
                "FROM carrito c " +
                "INNER JOIN productos p ON c.id_producto = p.id_producto " +
                "WHERE c.id_usuario = ? " +
                "ORDER BY c.fecha_agregado DESC";
        List<Carrito> carritos = new ArrayList<>();

        try (Connection conn = dbConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, idUsuario);

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    carritos.add(mapearCarrito(rs));
                }
            }
        }

        return carritos;
    }

    // ==================== UPDATE ====================

    /**
     * Actualiza un item del carrito
     */
    public boolean actualizar(Carrito carrito) throws SQLException {
        String sql = "UPDATE carrito SET id_usuario=?, id_producto=?, cantidad=? WHERE id_carrito=?";

        try (Connection conn = dbConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, carrito.getIdUsuario());
            pstmt.setInt(2, carrito.getIdProducto());
            pstmt.setInt(3, carrito.getCantidad());
            pstmt.setInt(4, carrito.getIdCarrito());

            return pstmt.executeUpdate() > 0;
        }
    }

    /**
     * Actualiza la cantidad de un producto en el carrito
     */
    public boolean actualizarCantidad(int idCarrito, int nuevaCantidad) throws SQLException {
        String sql = "UPDATE carrito SET cantidad = ? WHERE id_carrito = ?";

        try (Connection conn = dbConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, nuevaCantidad);
            pstmt.setInt(2, idCarrito);

            return pstmt.executeUpdate() > 0;
        }
    }

    // ==================== DELETE ====================

    /**
     * Elimina un item del carrito
     */
    public boolean eliminar(int idCarrito) throws SQLException {
        String sql = "DELETE FROM carrito WHERE id_carrito = ?";

        try (Connection conn = dbConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, idCarrito);
            return pstmt.executeUpdate() > 0;
        }
    }

    /**
     * Elimina un producto específico del carrito de un usuario
     */
    public boolean eliminarPorUsuarioYProducto(int idUsuario, int idProducto) throws SQLException {
        String sql = "DELETE FROM carrito WHERE id_usuario = ? AND id_producto = ?";

        try (Connection conn = dbConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, idUsuario);
            pstmt.setInt(2, idProducto);
            return pstmt.executeUpdate() > 0;
        }
    }

    /**
     * Vacía todo el carrito de un usuario
     */
    public boolean vaciarCarrito(int idUsuario) throws SQLException {
        String sql = "DELETE FROM carrito WHERE id_usuario = ?";

        try (Connection conn = dbConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, idUsuario);
            return pstmt.executeUpdate() > 0;
        }
    }

    // ==================== UTILIDADES ====================

    /**
     * Cuenta los items en el carrito de un usuario
     */
    public int contarItemsPorUsuario(int idUsuario) throws SQLException {
        String sql = "SELECT COUNT(*) FROM carrito WHERE id_usuario = ?";

        try (Connection conn = dbConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, idUsuario);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }

        return 0;
    }

    /**
     * Cuenta la cantidad total de productos en el carrito
     */
    public int contarCantidadTotalPorUsuario(int idUsuario) throws SQLException {
        String sql = "SELECT SUM(cantidad) FROM carrito WHERE id_usuario = ?";

        try (Connection conn = dbConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, idUsuario);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }

        return 0;
    }

    /**
     * Verifica si un producto ya está en el carrito
     */
    public boolean existeEnCarrito(int idUsuario, int idProducto) throws SQLException {
        String sql = "SELECT COUNT(*) FROM carrito WHERE id_usuario = ? AND id_producto = ?";

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

    // ==================== MAPEO ====================

    /**
     * Mapea un ResultSet a un objeto Carrito
     */
    private Carrito mapearCarrito(ResultSet rs) throws SQLException {
        Carrito carrito = new Carrito();

        carrito.setIdCarrito(rs.getInt("id_carrito"));
        carrito.setIdUsuario(rs.getInt("id_usuario"));
        carrito.setIdProducto(rs.getInt("id_producto"));
        carrito.setCantidad(rs.getInt("cantidad"));

        Timestamp timestamp = rs.getTimestamp("fecha_agregado");
        if (timestamp != null) {
            carrito.setFechaAgregado(timestamp.toLocalDateTime());
        }

        return carrito;
    }
}