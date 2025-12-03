package com.techzone.ecommerce.techzone.dao;

import com.techzone.ecommerce.techzone.config.DatabaseConnection;
import com.techzone.ecommerce.techzone.model.Pedido;

import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

/**
 * DAO para la gestión de pedidos
 * @author TechZone Team
 */
public class PedidoDAO {

    private final DatabaseConnection dbConnection;

    public PedidoDAO() {
        this.dbConnection = DatabaseConnection.getInstance();
    }

    // ==================== CREATE ====================

    /**
     * Crea un nuevo pedido
     */
    public int crear(Pedido pedido) throws SQLException {
        String sql = "INSERT INTO pedidos (id_usuario, fecha_pedido, total, estado, " +
                "direccion_envio, metodo_pago) VALUES (?, ?, ?, ?, ?, ?)";

        try (Connection conn = dbConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            pstmt.setInt(1, pedido.getIdUsuario());
            pstmt.setTimestamp(2, Timestamp.valueOf(pedido.getFechaPedido()));
            pstmt.setBigDecimal(3, pedido.getTotal());
            pstmt.setString(4, pedido.getEstado().name());
            pstmt.setString(5, pedido.getDireccionEnvio());
            pstmt.setString(6, pedido.getMetodoPago());

            int affectedRows = pstmt.executeUpdate();

            if (affectedRows == 0) {
                throw new SQLException("No se pudo crear el pedido");
            }

            try (ResultSet generatedKeys = pstmt.getGeneratedKeys()) {
                if (generatedKeys.next()) {
                    int id = generatedKeys.getInt(1);
                    pedido.setIdPedido(id);
                    return id;
                }
            }

            throw new SQLException("No se pudo obtener el ID generado");
        }
    }

    // ==================== READ ====================

    /**
     * Busca un pedido por su ID
     */
    public Optional<Pedido> buscarPorId(int id) throws SQLException {
        String sql = "SELECT * FROM pedidos WHERE id_pedido = ?";

        try (Connection conn = dbConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, id);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return Optional.of(mapearPedido(rs));
                }
            }
        }

        return Optional.empty();
    }

    /**
     * Obtiene todos los pedidos
     */
    public List<Pedido> obtenerTodos() throws SQLException {
        String sql = "SELECT * FROM pedidos ORDER BY fecha_pedido DESC";
        List<Pedido> pedidos = new ArrayList<>();

        try (Connection conn = dbConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {

            while (rs.next()) {
                pedidos.add(mapearPedido(rs));
            }
        }

        return pedidos;
    }

    /**
     * Obtiene pedidos por usuario
     */
    public List<Pedido> obtenerPorUsuario(int idUsuario) throws SQLException {
        String sql = "SELECT * FROM pedidos WHERE id_usuario = ? ORDER BY fecha_pedido DESC";
        List<Pedido> pedidos = new ArrayList<>();

        try (Connection conn = dbConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, idUsuario);

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    pedidos.add(mapearPedido(rs));
                }
            }
        }

        return pedidos;
    }

    /**
     * Obtiene pedidos por estado
     */
    public List<Pedido> obtenerPorEstado(Pedido.EstadoPedido estado) throws SQLException {
        String sql = "SELECT * FROM pedidos WHERE estado = ? ORDER BY fecha_pedido DESC";
        List<Pedido> pedidos = new ArrayList<>();

        try (Connection conn = dbConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, estado.name());

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    pedidos.add(mapearPedido(rs));
                }
            }
        }

        return pedidos;
    }

    /**
     * Obtiene pedidos recientes (últimos N pedidos)
     */
    public List<Pedido> obtenerRecientes(int limite) throws SQLException {
        String sql = "SELECT * FROM pedidos ORDER BY fecha_pedido DESC LIMIT ?";
        List<Pedido> pedidos = new ArrayList<>();

        try (Connection conn = dbConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, limite);

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    pedidos.add(mapearPedido(rs));
                }
            }
        }

        return pedidos;
    }

    // ==================== UPDATE ====================

    /**
     * Actualiza un pedido existente
     */
    public boolean actualizar(Pedido pedido) throws SQLException {
        String sql = "UPDATE pedidos SET id_usuario=?, total=?, estado=?, " +
                "direccion_envio=?, metodo_pago=? WHERE id_pedido=?";

        try (Connection conn = dbConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, pedido.getIdUsuario());
            pstmt.setBigDecimal(2, pedido.getTotal());
            pstmt.setString(3, pedido.getEstado().name());
            pstmt.setString(4, pedido.getDireccionEnvio());
            pstmt.setString(5, pedido.getMetodoPago());
            pstmt.setInt(6, pedido.getIdPedido());

            return pstmt.executeUpdate() > 0;
        }
    }

    /**
     * Actualiza el estado de un pedido
     */
    public boolean actualizarEstado(int idPedido, Pedido.EstadoPedido estado) throws SQLException {
        String sql = "UPDATE pedidos SET estado = ? WHERE id_pedido = ?";

        try (Connection conn = dbConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, estado.name());
            pstmt.setInt(2, idPedido);

            return pstmt.executeUpdate() > 0;
        }
    }

    /**
     * Actualiza el total del pedido
     */
    public boolean actualizarTotal(int idPedido, BigDecimal total) throws SQLException {
        String sql = "UPDATE pedidos SET total = ? WHERE id_pedido = ?";

        try (Connection conn = dbConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setBigDecimal(1, total);
            pstmt.setInt(2, idPedido);

            return pstmt.executeUpdate() > 0;
        }
    }

    // ==================== DELETE ====================

    /**
     * Elimina un pedido (y sus detalles en cascada)
     */
    public boolean eliminar(int idPedido) throws SQLException {
        String sql = "DELETE FROM pedidos WHERE id_pedido = ?";

        try (Connection conn = dbConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, idPedido);
            return pstmt.executeUpdate() > 0;
        }
    }

    // ==================== UTILIDADES ====================

    /**
     * Cuenta el total de pedidos
     */
    public int contarPedidos() throws SQLException {
        String sql = "SELECT COUNT(*) FROM pedidos";

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
     * Cuenta pedidos por usuario
     */
    public int contarPedidosPorUsuario(int idUsuario) throws SQLException {
        String sql = "SELECT COUNT(*) FROM pedidos WHERE id_usuario = ?";

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
     * Calcula el total de ventas
     */
    public BigDecimal calcularTotalVentas() throws SQLException {
        String sql = "SELECT SUM(total) FROM pedidos WHERE estado IN ('ENTREGADO', 'ENVIADO')";

        try (Connection conn = dbConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {

            if (rs.next()) {
                BigDecimal total = rs.getBigDecimal(1);
                return total != null ? total : BigDecimal.ZERO;
            }
        }

        return BigDecimal.ZERO;
    }

    /**
     * Calcula el total de ventas por usuario
     */
    public BigDecimal calcularTotalVentasPorUsuario(int idUsuario) throws SQLException {
        String sql = "SELECT SUM(total) FROM pedidos WHERE id_usuario = ? " +
                "AND estado IN ('ENTREGADO', 'ENVIADO')";

        try (Connection conn = dbConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, idUsuario);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    BigDecimal total = rs.getBigDecimal(1);
                    return total != null ? total : BigDecimal.ZERO;
                }
            }
        }

        return BigDecimal.ZERO;
    }

    // ==================== MAPEO ====================

    /**
     * Mapea un ResultSet a un objeto Pedido
     */
    private Pedido mapearPedido(ResultSet rs) throws SQLException {
        Pedido pedido = new Pedido();

        pedido.setIdPedido(rs.getInt("id_pedido"));
        pedido.setIdUsuario(rs.getInt("id_usuario"));

        Timestamp timestamp = rs.getTimestamp("fecha_pedido");
        if (timestamp != null) {
            pedido.setFechaPedido(timestamp.toLocalDateTime());
        }

        pedido.setTotal(rs.getBigDecimal("total"));
        pedido.setEstado(Pedido.EstadoPedido.valueOf(rs.getString("estado")));
        pedido.setDireccionEnvio(rs.getString("direccion_envio"));
        pedido.setMetodoPago(rs.getString("metodo_pago"));

        return pedido;
    }
}