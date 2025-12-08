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
 * Proporciona operaciones CRUD completas y métodos de consulta para productos
 *
 * @author TechZone Team
 */
public class ProductoDAO {

    private final DatabaseConnection dbConnection;

    public ProductoDAO() {
        this.dbConnection = DatabaseConnection.getInstance();
    }

    // ==================== CREATE ====================

    /**
     * Crea un nuevo producto en la base de datos
     *
     * @param producto Objeto Producto con los datos a insertar
     * @return ID del producto creado
     * @throws SQLException Si hay error en la operación de base de datos
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
     *
     * @param id ID del producto a buscar
     * @return Optional con el producto si existe, empty si no
     * @throws SQLException Si hay error en la consulta
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
     * Obtiene todos los productos ordenados por fecha de registro
     *
     * @return Lista de todos los productos
     * @throws SQLException Si hay error en la consulta
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
     * Obtiene productos filtrados por categoría
     *
     * @param idCategoria ID de la categoría
     * @return Lista de productos de la categoría
     * @throws SQLException Si hay error en la consulta
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
     * Obtiene productos disponibles con stock mayor a 0
     *
     * @return Lista de productos disponibles
     * @throws SQLException Si hay error en la consulta
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
     * Busca productos por nombre (búsqueda parcial con LIKE)
     *
     * @param nombre Término de búsqueda
     * @return Lista de productos que coinciden con el nombre
     * @throws SQLException Si hay error en la consulta
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
     * Obtiene productos que tienen descuento activo
     *
     * @return Lista de productos con descuento
     * @throws SQLException Si hay error en la consulta
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
     * Obtiene los productos más recientes
     *
     * @param limite Número máximo de productos a retornar
     * @return Lista de productos recientes
     * @throws SQLException Si hay error en la consulta
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

    /**
     * Obtiene productos con stock bajo el mínimo especificado
     * Útil para alertas de reabastecimiento
     *
     * @param stockMinimo Stock mínimo considerado como bajo
     * @param limite Número máximo de productos a retornar
     * @return Lista de productos con stock bajo
     * @throws SQLException Si hay error en la consulta
     */
    public List<Producto> obtenerBajoStock(int stockMinimo, int limite) throws SQLException {
        String sql = "SELECT * FROM productos WHERE stock <= ? AND estado = 'DISPONIBLE' " +
                "ORDER BY stock ASC LIMIT ?";
        List<Producto> productos = new ArrayList<>();

        try (Connection conn = dbConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, stockMinimo);
            pstmt.setInt(2, limite);

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
     * Actualiza todos los campos de un producto existente
     *
     * @param producto Objeto Producto con los datos actualizados
     * @return true si se actualizó correctamente, false si no
     * @throws SQLException Si hay error en la operación
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
     * Actualiza únicamente el stock de un producto
     *
     * @param idProducto ID del producto
     * @param nuevoStock Nuevo valor de stock
     * @return true si se actualizó correctamente
     * @throws SQLException Si hay error en la operación
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
     * Usa una condición WHERE para asegurar que hay stock suficiente
     *
     * @param idProducto ID del producto
     * @param cantidad Cantidad a reducir
     * @return true si se redujo el stock, false si no hay suficiente
     * @throws SQLException Si hay error en la operación
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
     *
     * @param idProducto ID del producto
     * @param estado Nuevo estado
     * @return true si se actualizó correctamente
     * @throws SQLException Si hay error en la operación
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
     * Elimina un producto de la base de datos
     * NOTA: Asegúrate de que no haya referencias en otras tablas
     *
     * @param idProducto ID del producto a eliminar
     * @return true si se eliminó correctamente
     * @throws SQLException Si hay error en la operación
     */
    public boolean eliminar(int idProducto) throws SQLException {
        String sql = "DELETE FROM productos WHERE id_producto = ?";

        try (Connection conn = dbConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, idProducto);
            return pstmt.executeUpdate() > 0;
        }
    }

    // ==================== UTILIDADES Y CONTADORES ====================

    /**
     * Cuenta el total de productos en la base de datos
     *
     * @return Número total de productos
     * @throws SQLException Si hay error en la consulta
     */
    public int contarTodos() throws SQLException {
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
     * Cuenta productos con estado DISPONIBLE
     *
     * @return Número de productos activos
     * @throws SQLException Si hay error en la consulta
     */
    public int contarActivos() throws SQLException {
        String sql = "SELECT COUNT(*) FROM productos WHERE estado = 'DISPONIBLE'";

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
     * Cuenta productos con stock bajo o igual al mínimo especificado
     *
     * @param stockMinimo Stock mínimo considerado como bajo
     * @return Número de productos con stock bajo
     * @throws SQLException Si hay error en la consulta
     */
    public int contarBajoStock(int stockMinimo) throws SQLException {
        String sql = "SELECT COUNT(*) FROM productos WHERE stock <= ? AND estado = 'DISPONIBLE'";

        try (Connection conn = dbConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, stockMinimo);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }

        return 0;
    }

    /**
     * Cuenta productos por categoría
     *
     * @param idCategoria ID de la categoría
     * @return Número de productos en esa categoría
     * @throws SQLException Si hay error en la consulta
     */
    public int contarPorCategoria(int idCategoria) throws SQLException {
        String sql = "SELECT COUNT(*) FROM productos WHERE id_categoria = ?";

        try (Connection conn = dbConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, idCategoria);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }

        return 0;
    }

    /**
     * Verifica si hay stock disponible para una cantidad requerida
     *
     * @param idProducto ID del producto
     * @param cantidadRequerida Cantidad que se necesita
     * @return true si hay stock suficiente, false si no
     * @throws SQLException Si hay error en la consulta
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

    /**
     * Calcula el valor total del inventario
     * Suma (precio * stock) de todos los productos disponibles
     *
     * @return Valor total del inventario
     * @throws SQLException Si hay error en la consulta
     */
    public BigDecimal calcularValorInventario() throws SQLException {
        String sql = "SELECT SUM(precio * stock) as valor_total FROM productos " +
                "WHERE estado = 'DISPONIBLE'";

        try (Connection conn = dbConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {

            if (rs.next()) {
                BigDecimal valor = rs.getBigDecimal("valor_total");
                return valor != null ? valor : BigDecimal.ZERO;
            }
        }

        return BigDecimal.ZERO;
    }

    // ==================== MAPEO ====================

    /**
     * Mapea un ResultSet a un objeto Producto
     * Convierte cada columna de la BD al campo correspondiente del modelo
     *
     * @param rs ResultSet con los datos del producto
     * @return Objeto Producto mapeado
     * @throws SQLException Si hay error al leer los datos
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