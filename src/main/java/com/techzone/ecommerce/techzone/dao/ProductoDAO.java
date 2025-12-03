package com.techzone.ecommerce.techzone.dao;

import com.techzone.ecommerce.techzone.config.DatabaseConnection;
import com.techzone.ecommerce.techzone.model.Producto;

import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

/**
 * DAO para la gestión de productos
 * @author TechZone Team
 */
public class ProductoDAO {

    private final DatabaseConnection dbConnection;

    public ProductoDAO() {
        this.dbConnection = DatabaseConnection.getInstance();
    }

    // ==================== CREATE ====================

    /**
     * Crea un nuevo producto
     */
    public int crear(Producto producto) throws SQLException {
        String sql = "INSERT INTO productos (id_categoria, nombre, descripcion, precio, stock, marca, " +
                "modelo, especificaciones, estado, fecha_registro, descuento) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = dbConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            pstmt.setInt(1, producto.getIdCategoria());
            pstmt.setString(2, producto.getNombre());
            pstmt.setString(3, producto.getDescripcion());
            pstmt.setBigDecimal(4, producto.getPrecio());
            pstmt.setInt(5, producto.getStock());
            pstmt.setString(6, producto.getMarca());
            pstmt.setString(7, producto.getModelo());
            pstmt.setString(8, producto.getEspecificaciones());
            pstmt.setString(9, producto.getEstado().name());
            pstmt.setTimestamp(10, Timestamp.valueOf(producto.getFechaRegistro()));
            pstmt.setBigDecimal(11, producto.getDescuento());

            int affectedRows = pstmt.executeUpdate();

            if (affectedRows == 0) {
                throw new SQLException("No se pudo crear el producto");
            }

            try (ResultSet generatedKeys = pstmt.getGeneratedKeys()) {
                if (generatedKeys.next()) {
                    int id = generatedKeys.getInt(1);
                    producto.setIdProducto(id);
                    return id;
                }
            }

            throw new SQLException("No se pudo obtener el ID generado");
        }
    }

    // ==================== READ ====================

    /**
     * Busca un producto por su ID
     */
    public Optional<Producto> buscarPorId(int id) throws SQLException {
        String sql = "SELECT * FROM productos WHERE id_producto = ?";

        try (Connection conn = dbConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, id);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return Optional.of(mapearProducto(rs));
                }
            }
        }

        return Optional.empty();
    }

    /**
     * Obtiene todos los productos
     */
    public List<Producto> obtenerTodos() throws SQLException {
        String sql = "SELECT * FROM productos ORDER BY fecha_registro DESC";
        List<Producto> productos = new ArrayList<>();

        try (Connection conn = dbConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {

            while (rs.next()) {
                productos.add(mapearProducto(rs));
            }
        }

        return productos;
    }

    /**
     * Obtiene productos por categoría
     */
    public List<Producto> obtenerPorCategoria(int idCategoria) throws SQLException {
        String sql = "SELECT * FROM productos WHERE id_categoria = ? ORDER BY nombre";
        List<Producto> productos = new ArrayList<>();

        try (Connection conn = dbConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, idCategoria);

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    productos.add(mapearProducto(rs));
                }
            }
        }

        return productos;
    }

    /**
     * Obtiene productos disponibles (con stock)
     */
    public List<Producto> obtenerDisponibles() throws SQLException {
        String sql = "SELECT * FROM productos WHERE estado = 'DISPONIBLE' AND stock > 0 ORDER BY nombre";
        List<Producto> productos = new ArrayList<>();

        try (Connection conn = dbConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {

            while (rs.next()) {
                productos.add(mapearProducto(rs));
            }
        }

        return productos;
    }

    /**
     * Busca productos por nombre (búsqueda parcial)
     */
    public List<Producto> buscarPorNombre(String nombre) throws SQLException {
        String sql = "SELECT * FROM productos WHERE nombre LIKE ? ORDER BY nombre";
        List<Producto> productos = new ArrayList<>();

        try (Connection conn = dbConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, "%" + nombre + "%");

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    productos.add(mapearProducto(rs));
                }
            }
        }

        return productos;
    }

    /**
     * Obtiene productos con descuento
     */
    public List<Producto> obtenerConDescuento() throws SQLException {
        String sql = "SELECT * FROM productos WHERE descuento > 0 AND estado = 'DISPONIBLE' " +
                "ORDER BY descuento DESC";
        List<Producto> productos = new ArrayList<>();

        try (Connection conn = dbConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {

            while (rs.next()) {
                productos.add(mapearProducto(rs));
            }
        }

        return productos;
    }

    /**
     * Obtiene productos más recientes
     */
    public List<Producto> obtenerMasRecientes(int limite) throws SQLException {
        String sql = "SELECT * FROM productos WHERE estado = 'DISPONIBLE' " +
                "ORDER BY fecha_registro DESC LIMIT ?";
        List<Producto> productos = new ArrayList<>();

        try (Connection conn = dbConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, limite);

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    productos.add(mapearProducto(rs));
                }
            }
        }

        return productos;
    }

    // ==================== UPDATE ====================

    /**
     * Actualiza un producto existente
     */
    public boolean actualizar(Producto producto) throws SQLException {
        String sql = "UPDATE productos SET id_categoria=?, nombre=?, descripcion=?, precio=?, " +
                "stock=?, marca=?, modelo=?, especificaciones=?, estado=?, descuento=? " +
                "WHERE id_producto=?";

        try (Connection conn = dbConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, producto.getIdCategoria());
            pstmt.setString(2, producto.getNombre());
            pstmt.setString(3, producto.getDescripcion());
            pstmt.setBigDecimal(4, producto.getPrecio());
            pstmt.setInt(5, producto.getStock());
            pstmt.setString(6, producto.getMarca());
            pstmt.setString(7, producto.getModelo());
            pstmt.setString(8, producto.getEspecificaciones());
            pstmt.setString(9, producto.getEstado().name());
            pstmt.setBigDecimal(10, producto.getDescuento());
            pstmt.setInt(11, producto.getIdProducto());

            return pstmt.executeUpdate() > 0;
        }
    }

    /**
     * Actualiza el stock de un producto
     */
    public boolean actualizarStock(int idProducto, int nuevoStock) throws SQLException {
        String sql = "UPDATE productos SET stock = ? WHERE id_producto = ?";

        try (Connection conn = dbConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, nuevoStock);
            pstmt.setInt(2, idProducto);

            return pstmt.executeUpdate() > 0;
        }
    }

    /**
     * Reduce el stock de un producto (para compras)
     */
    public boolean reducirStock(int idProducto, int cantidad) throws SQLException {
        String sql = "UPDATE productos SET stock = stock - ? WHERE id_producto = ? AND stock >= ?";

        try (Connection conn = dbConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, cantidad);
            pstmt.setInt(2, idProducto);
            pstmt.setInt(3, cantidad);

            return pstmt.executeUpdate() > 0;
        }
    }

    /**
     * Actualiza el estado de un producto
     */
    public boolean actualizarEstado(int idProducto, Producto.EstadoProducto estado) throws SQLException {
        String sql = "UPDATE productos SET estado = ? WHERE id_producto = ?";

        try (Connection conn = dbConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, estado.name());
            pstmt.setInt(2, idProducto);

            return pstmt.executeUpdate() > 0;
        }
    }

    // ==================== DELETE ====================

    /**
     * Elimina un producto
     */
    public boolean eliminar(int idProducto) throws SQLException {
        String sql = "DELETE FROM productos WHERE id_producto = ?";

        try (Connection conn = dbConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, idProducto);
            return pstmt.executeUpdate() > 0;
        }
    }

    // ==================== UTILIDADES ====================

    /**
     * Cuenta el total de productos
     */
    public int contarProductos() throws SQLException {
        String sql = "SELECT COUNT(*) FROM productos";

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
     * Verifica si hay stock disponible
     */
    public boolean verificarStock(int idProducto, int cantidadRequerida) throws SQLException {
        String sql = "SELECT stock FROM productos WHERE id_producto = ?";

        try (Connection conn = dbConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, idProducto);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("stock") >= cantidadRequerida;
                }
            }
        }

        return false;
    }

    // ==================== MAPEO ====================

    /**
     * Mapea un ResultSet a un objeto Producto
     */
    private Producto mapearProducto(ResultSet rs) throws SQLException {
        Producto producto = new Producto();

        producto.setIdProducto(rs.getInt("id_producto"));
        producto.setIdCategoria(rs.getInt("id_categoria"));
        producto.setNombre(rs.getString("nombre"));
        producto.setDescripcion(rs.getString("descripcion"));
        producto.setPrecio(rs.getBigDecimal("precio"));
        producto.setStock(rs.getInt("stock"));
        producto.setMarca(rs.getString("marca"));
        producto.setModelo(rs.getString("modelo"));
        producto.setEspecificaciones(rs.getString("especificaciones"));
        producto.setEstado(Producto.EstadoProducto.valueOf(rs.getString("estado")));

        Timestamp timestamp = rs.getTimestamp("fecha_registro");
        if (timestamp != null) {
            producto.setFechaRegistro(timestamp.toLocalDateTime());
        }

        BigDecimal descuento = rs.getBigDecimal("descuento");
        producto.setDescuento(descuento != null ? descuento : BigDecimal.ZERO);

        return producto;
    }
}