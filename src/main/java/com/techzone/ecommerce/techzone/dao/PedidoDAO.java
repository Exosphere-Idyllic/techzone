package com.techzone.ecommerce.techzone.dao;

import com.techzone.ecommerce.techzone.config.DatabaseConnection;
import com.techzone.ecommerce.techzone.model.Pedido;

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
        String sql = "INSERT INTO pedidos (id_usuario, fecha_pedido, estado, total, " +
                "direccion_envio, metodo_pago, notas) VALUES (?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = dbConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            pstmt.setInt(1, pedido.getIdUsuario());
            pstmt.setTimestamp(2, Timestamp.valueOf(pedido.getFechaPedido()));
            pstmt.setString(3, pedido.getEstado());
            pstmt.setBigDecimal(4, pedido.getTotal());
            pstmt.setString(5, pedido.getDireccionEnvio());
            pstmt.setString(6, pedido.getMetodoPago());
            pstmt.setString(7, pedido.getNotas());

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
     * Obtiene todos los pedidos de un usuario
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
     * Obtiene todos los pedidos
     */
    public List<Pedido> obtenerTodos() throws SQLException {
        String sql = "SELECT * FROM pedidos ORDER BY fecha_pedido DESC";
        List<Pedido> pedidos = new ArrayList<>();

        try (Connection conn = dbConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {

            while (rs.next()) {
                pedidos.add(mapearPedido(rs));
            }
        }

        return pedidos;
    }

    /**
     * Obtiene pedidos por estado
     */
    public List<Pedido> obtenerPorEstado(String estado) throws SQLException {
        String sql = "SELECT * FROM pedidos WHERE estado = ? ORDER BY fecha_pedido DESC";
        List<Pedido> pedidos = new ArrayList<>();

        try (Connection conn = dbConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, estado);

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
     * Actualiza un pedido
     */
    public boolean actualizar(Pedido pedido) throws SQLException {
        String sql = "UPDATE pedidos SET id_usuario=?, fecha_pedido=?, estado=?, " +
                "total=?, direccion_envio=?, metodo_pago=?, notas=? WHERE id_pedido=?";

        try (Connection conn = dbConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, pedido.getIdUsuario());
            pstmt.setTimestamp(2, Timestamp.valueOf(pedido.getFechaPedido()));
            pstmt.setString(3, pedido.getEstado());
            pstmt.setBigDecimal(4, pedido.getTotal());
            pstmt.setString(5, pedido.getDireccionEnvio());
            pstmt.setString(6, pedido.getMetodoPago());
            pstmt.setString(7, pedido.getNotas());
            pstmt.setInt(8, pedido.getIdPedido());

            return pstmt.executeUpdate() > 0;
        }
    }

    /**
     * Actualiza el estado de un pedido
     */
    public boolean actualizarEstado(int idPedido, String nuevoEstado) throws SQLException {
        String sql = "UPDATE pedidos SET estado = ? WHERE id_pedido = ?";

        try (Connection conn = dbConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, nuevoEstado);
            pstmt.setInt(2, idPedido);

            return pstmt.executeUpdate() > 0;
        }
    }

    // ==================== DELETE ====================

    /**
     * Elimina un pedido (generalmente no se usa, se cambia estado)
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
     * Cuenta los pedidos de un usuario
     */
    public int contarPorUsuario(int idUsuario) throws SQLException {
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
     * Cuenta pedidos por estado
     */
    public int contarPorEstado(String estado) throws SQLException {
        String sql = "SELECT COUNT(*) FROM pedidos WHERE estado = ?";

        try (Connection conn = dbConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, estado);

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

        pedido.setEstado(rs.getString("estado"));
        pedido.setTotal(rs.getBigDecimal("total"));
        pedido.setDireccionEnvio(rs.getString("direccion_envio"));
        pedido.setMetodoPago(rs.getString("metodo_pago"));
        pedido.setNotas(rs.getString("notas"));

        return pedido;
    }
}