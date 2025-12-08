package com.techzone.ecommerce.techzone.dao;

import com.techzone.ecommerce.techzone.config.DatabaseConnection;
import com.techzone.ecommerce.techzone.model.Pedido;

import java.math.BigDecimal;
import java.sql.*;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

/**
 * DAO para la gestión de pedidos
 * Proporciona operaciones CRUD y consultas estadísticas para pedidos
 *
 * @author TechZone Team
 */
public class PedidoDAO {

    private final DatabaseConnection dbConnection;

    public PedidoDAO() {
        this.dbConnection = DatabaseConnection.getInstance();
    }

    // ==================== CREATE ====================

    /**
     * Crea un nuevo pedido en la base de datos
     *
     * @param pedido Objeto Pedido con los datos a insertar
     * @return ID del pedido creado
     * @throws SQLException Si hay error en la operación
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
     *
     * @param id ID del pedido a buscar
     * @return Optional con el pedido si existe
     * @throws SQLException Si hay error en la consulta
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
     * Obtiene todos los pedidos ordenados por fecha descendente
     *
     * @return Lista de todos los pedidos
     * @throws SQLException Si hay error en la consulta
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
     * Obtiene todos los pedidos de un usuario específico
     *
     * @param idUsuario ID del usuario
     * @return Lista de pedidos del usuario
     * @throws SQLException Si hay error en la consulta
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
     * Obtiene pedidos filtrados por estado
     *
     * @param estado Estado del pedido a filtrar
     * @return Lista de pedidos con ese estado
     * @throws SQLException Si hay error en la consulta
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
     * Obtiene los N pedidos más recientes
     * Útil para mostrar en dashboards
     *
     * @param limite Número máximo de pedidos a retornar
     * @return Lista de pedidos recientes
     * @throws SQLException Si hay error en la consulta
     */
    public List<Pedido> obtenerUltimos(int limite) throws SQLException {
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
     * Actualiza todos los campos de un pedido existente
     *
     * @param pedido Objeto Pedido con los datos actualizados
     * @return true si se actualizó correctamente
     * @throws SQLException Si hay error en la operación
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
     * Actualiza únicamente el estado de un pedido
     *
     * @param idPedido ID del pedido
     * @param estado Nuevo estado
     * @return true si se actualizó correctamente
     * @throws SQLException Si hay error en la operación
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
     * Actualiza el total de un pedido
     *
     * @param idPedido ID del pedido
     * @param total Nuevo total
     * @return true si se actualizó correctamente
     * @throws SQLException Si hay error en la operación
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
     * Elimina un pedido de la base de datos
     * NOTA: Los detalles del pedido se eliminarán en cascada si está configurado
     *
     * @param idPedido ID del pedido a eliminar
     * @return true si se eliminó correctamente
     * @throws SQLException Si hay error en la operación
     */
    public boolean eliminar(int idPedido) throws SQLException {
        String sql = "DELETE FROM pedidos WHERE id_pedido = ?";

        try (Connection conn = dbConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, idPedido);
            return pstmt.executeUpdate() > 0;
        }
    }

    // ==================== CONTADORES ====================

    /**
     * Cuenta el total de pedidos en el sistema
     *
     * @return Número total de pedidos
     * @throws SQLException Si hay error en la consulta
     */
    public int contarTodos() throws SQLException {
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
     *
     * @param idUsuario ID del usuario
     * @return Número de pedidos del usuario
     * @throws SQLException Si hay error en la consulta
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
     *
     * @param estado Estado a contar
     * @return Número de pedidos con ese estado
     * @throws SQLException Si hay error en la consulta
     */
    public int contarPorEstado(Pedido.EstadoPedido estado) throws SQLException {
        String sql = "SELECT COUNT(*) FROM pedidos WHERE estado = ?";

        try (Connection conn = dbConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, estado.name());

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }

        return 0;
    }

    /**
     * Cuenta pedidos realizados hoy
     * Compara solo la fecha, ignora la hora
     *
     * @return Número de pedidos de hoy
     * @throws SQLException Si hay error en la consulta
     */
    public int contarHoy() throws SQLException {
        String sql = "SELECT COUNT(*) FROM pedidos WHERE DATE(fecha_pedido) = CURDATE()";

        try (Connection conn = dbConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {

            if (rs.next()) {
                return rs.getInt(1);
            }
        }

        return 0;
    }

    // ==================== ESTADÍSTICAS DE VENTAS ====================

    /**
     * Calcula el total de ventas de pedidos completados
     * Solo cuenta pedidos ENTREGADO y ENVIADO
     *
     * @return Suma total de ventas
     * @throws SQLException Si hay error en la consulta
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
     * Calcula las ventas del día actual
     *
     * @return Total de ventas de hoy
     * @throws SQLException Si hay error en la consulta
     */
    public BigDecimal calcularVentasHoy() throws SQLException {
        String sql = "SELECT SUM(total) FROM pedidos " +
                "WHERE DATE(fecha_pedido) = CURDATE() " +
                "AND estado IN ('ENTREGADO', 'ENVIADO', 'PROCESANDO')";

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
     * Calcula las ventas del mes actual
     *
     * @return Total de ventas del mes
     * @throws SQLException Si hay error en la consulta
     */
    public BigDecimal calcularVentasMes() throws SQLException {
        String sql = "SELECT SUM(total) FROM pedidos " +
                "WHERE YEAR(fecha_pedido) = YEAR(CURDATE()) " +
                "AND MONTH(fecha_pedido) = MONTH(CURDATE()) " +
                "AND estado IN ('ENTREGADO', 'ENVIADO', 'PROCESANDO')";

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
     * Calcula el ticket promedio (valor promedio por pedido)
     * Solo considera pedidos completados
     *
     * @return Valor promedio por pedido
     * @throws SQLException Si hay error en la consulta
     */
    public BigDecimal calcularTicketPromedio() throws SQLException {
        String sql = "SELECT AVG(total) FROM pedidos WHERE estado IN ('ENTREGADO', 'ENVIADO')";

        try (Connection conn = dbConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {

            if (rs.next()) {
                BigDecimal promedio = rs.getBigDecimal(1);
                return promedio != null ? promedio : BigDecimal.ZERO;
            }
        }

        return BigDecimal.ZERO;
    }

    /**
     * Calcula el total de ventas por usuario
     *
     * @param idUsuario ID del usuario
     * @return Total de ventas del usuario
     * @throws SQLException Si hay error en la consulta
     */
    public BigDecimal calcularVentasPorUsuario(int idUsuario) throws SQLException {
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
     * Convierte cada columna de la BD al campo correspondiente del modelo
     *
     * @param rs ResultSet con los datos del pedido
     * @return Objeto Pedido mapeado
     * @throws SQLException Si hay error al leer los datos
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