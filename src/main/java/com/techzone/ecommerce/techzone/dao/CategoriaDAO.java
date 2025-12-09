package com.techzone.ecommerce.techzone.dao;

import com.techzone.ecommerce.techzone.config.DatabaseConnection;
import com.techzone.ecommerce.techzone.model.Categoria;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

/**
 * DAO para la gestión de categorías
 * @author TechZone Team
 */
public class CategoriaDAO {

    private final DatabaseConnection dbConnection;

    public CategoriaDAO() {
        this.dbConnection = DatabaseConnection.getInstance();
    }

    // ==================== CREATE ====================

    /**
     * Crea una nueva categoría
     */
    public int crear(Categoria categoria) throws SQLException {
        String sql = "INSERT INTO categorias (nombre, descripcion, estado) VALUES (?, ?, ?)";

        try (Connection conn = dbConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            pstmt.setString(1, categoria.getNombre());
            pstmt.setString(2, categoria.getDescripcion());
            pstmt.setString(3, categoria.getEstado().name());

            int affectedRows = pstmt.executeUpdate();

            if (affectedRows == 0) {
                throw new SQLException("No se pudo crear la categoría");
            }

            try (ResultSet generatedKeys = pstmt.getGeneratedKeys()) {
                if (generatedKeys.next()) {
                    int id = generatedKeys.getInt(1);
                    categoria.setIdCategoria(id);
                    return id;
                }
            }

            throw new SQLException("No se pudo obtener el ID generado");
        }
    }

    // ==================== READ ====================

    /**
     * Busca una categoría por su ID
     */
    public Optional<Categoria> buscarPorId(int id) throws SQLException {
        String sql = "SELECT * FROM categorias WHERE id_categoria = ?";

        try (Connection conn = dbConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, id);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return Optional.of(mapearCategoria(rs));
                }
            }
        }

        return Optional.empty();
    }

    /**
     * Busca una categoría por su nombre
     */
    public Optional<Categoria> buscarPorNombre(String nombre) throws SQLException {
        String sql = "SELECT * FROM categorias WHERE nombre = ?";

        try (Connection conn = dbConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, nombre);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return Optional.of(mapearCategoria(rs));
                }
            }
        }

        return Optional.empty();
    }

    /**
     * Obtiene todas las categorías
     */
    public List<Categoria> obtenerTodas() throws SQLException {
        String sql = "SELECT * FROM categorias ORDER BY nombre";
        List<Categoria> categorias = new ArrayList<>();

        try (Connection conn = dbConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {

            while (rs.next()) {
                categorias.add(mapearCategoria(rs));
            }
        }

        return categorias;
    }
    /**
     * Obtiene las categorías activas
     */
    public List<Categoria> obtenerActivas() throws SQLException {
        String sql = "SELECT * FROM categorias WHERE estado = 'ACTIVO' ORDER BY nombre";
        List<Categoria> categorias = new ArrayList<>();

        try (Connection conn = dbConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {

            while (rs.next()) {
                categorias.add(mapearCategoria(rs));
            }
        }

        return categorias;
    }

    // ==================== UPDATE ====================

    /**
     * Actualiza una categoría existente
     */
    public boolean actualizar(Categoria categoria) throws SQLException {
        String sql = "UPDATE categorias SET nombre=?, descripcion=?, estado=? WHERE id_categoria=?";

        try (Connection conn = dbConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, categoria.getNombre());
            pstmt.setString(2, categoria.getDescripcion());
            pstmt.setString(3, categoria.getEstado().name());
            pstmt.setInt(4, categoria.getIdCategoria());

            return pstmt.executeUpdate() > 0;
        }
    }

    /**
     * Actualiza el estado de una categoría
     */
    public boolean actualizarEstado(int idCategoria, Categoria.EstadoCategoria estado) throws SQLException {
        String sql = "UPDATE categorias SET estado = ? WHERE id_categoria = ?";

        try (Connection conn = dbConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, estado.name());
            pstmt.setInt(2, idCategoria);

            return pstmt.executeUpdate() > 0;
        }
    }

    // ==================== DELETE ====================

    /**
     * Elimina una categoría
     */
    public boolean eliminar(int idCategoria) throws SQLException {
        String sql = "DELETE FROM categorias WHERE id_categoria = ?";

        try (Connection conn = dbConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, idCategoria);
            return pstmt.executeUpdate() > 0;
        }
    }

    // ==================== UTILIDADES ====================

    /**
     * Verifica si una categoría existe por nombre
     */
    public boolean existeNombre(String nombre) throws SQLException {
        String sql = "SELECT COUNT(*) FROM categorias WHERE nombre = ?";

        try (Connection conn = dbConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, nombre);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        }

        return false;
    }

    /**
     * Cuenta el total de categorías
     */
    public int contarCategorias() throws SQLException {
        String sql = "SELECT COUNT(*) FROM categorias";

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
     * Cuenta productos por categoría
     */
    public int contarProductosPorCategoria(int idCategoria) throws SQLException {
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

    // ==================== MAPEO ====================

    /**
     * Mapea un ResultSet a un objeto Categoria
     */
    private Categoria mapearCategoria(ResultSet rs) throws SQLException {
        Categoria categoria = new Categoria();

        categoria.setIdCategoria(rs.getInt("id_categoria"));
        categoria.setNombre(rs.getString("nombre"));
        categoria.setDescripcion(rs.getString("descripcion"));
        categoria.setEstado(
                Categoria.EstadoCategoria.valueOf(
                        rs.getString("estado").trim().toUpperCase()
                )
        );

        return categoria;
    }

    public List<Categoria> obtenerActivasConConteo() throws SQLException {
        String sql = """
        SELECT c.id_categoria, c.nombre, c.descripcion, c.estado,
               COUNT(p.id_producto) as cantidad_productos
        FROM categorias c
        LEFT JOIN productos p ON c.id_categoria = p.id_categoria 
                                AND p.estado = 'DISPONIBLE'
        WHERE c.estado = 'ACTIVO'
        GROUP BY c.id_categoria, c.nombre, c.descripcion, c.estado
        ORDER BY c.nombre
        """;

        List<Categoria> categorias = new ArrayList<>();

        try (Connection conn = dbConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {

            while (rs.next()) {
                Categoria categoria = new Categoria();
                categoria.setIdCategoria(rs.getInt("id_categoria"));
                categoria.setNombre(rs.getString("nombre"));
                categoria.setDescripcion(rs.getString("descripcion"));
                categoria.setEstado(
                        Categoria.EstadoCategoria.valueOf(
                                rs.getString("estado").trim().toUpperCase()
                        )
                );
                //  Asignar el conteo de productos
                categoria.setCantidadProductos(rs.getInt("cantidad_productos"));

                categorias.add(categoria);
            }
        }

        return categorias;
    }
}