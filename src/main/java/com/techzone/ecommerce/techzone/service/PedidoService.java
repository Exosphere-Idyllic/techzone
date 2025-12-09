package com.techzone.ecommerce.techzone.service;

import com.techzone.ecommerce.techzone.service.ServiceException;
import com.techzone.ecommerce.techzone.config.DatabaseConnection;
import com.techzone.ecommerce.techzone.dao.*;
import com.techzone.ecommerce.techzone.model.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

/**
 * Servicio de lógica de negocio para gestión de pedidos
 * @author TechZone Team
 */
public class PedidoService {

    private static final Logger logger = LoggerFactory.getLogger(PedidoService.class);
    private final PedidoDAO pedidoDAO;
    private final DetallePedidoDAO detalleDAO;
    private final ProductoDAO productoDAO;
    private final CarritoDAO carritoDAO;
    private final UsuarioDAO usuarioDAO;

    public PedidoService() {
        this.pedidoDAO = new PedidoDAO();
        this.detalleDAO = new DetallePedidoDAO();
        this.productoDAO = new ProductoDAO();
        this.carritoDAO = new CarritoDAO();
        this.usuarioDAO = new UsuarioDAO();
    }

    // ==================== CREACIÓN DE PEDIDOS ====================

    /**
     * Crea un pedido completo desde el carrito del usuario
     * Esta operación es transaccional y compleja
     */
    public int crearPedidoDesdeCarrito(int idUsuario, String direccionEnvio, String metodoPago)
            throws ServiceException {
        logger.info("Creando pedido para usuario {} desde carrito", idUsuario);

        Connection conn = null;

        try {
            // Obtener conexión para transacción
            conn = DatabaseConnection.getInstance().getConnection();
            conn.setAutoCommit(false);

            // 1. Verificar que el usuario existe
            Optional<Usuario> usuario = usuarioDAO.buscarPorId(idUsuario);
            if (!usuario.isPresent()) {
                throw new ServiceException("Usuario no encontrado");
            }

            // 2. Obtener items del carrito
            List<Carrito> itemsCarrito = carritoDAO.obtenerPorUsuario(idUsuario);

            if (itemsCarrito.isEmpty()) {
                throw new ServiceException("El carrito está vacío");
            }

            // 3. Validar datos del pedido
            if (direccionEnvio == null || direccionEnvio.trim().isEmpty()) {
                throw new ServiceException("La dirección de envío es requerida");
            }

            if (metodoPago == null || metodoPago.trim().isEmpty()) {
                throw new ServiceException("El método de pago es requerido");
            }

            // 4. Crear detalles y calcular total
            List<DetallePedido> detalles = new ArrayList<>();
            BigDecimal total = BigDecimal.ZERO;

            for (Carrito item : itemsCarrito) {
                Optional<Producto> productoOpt = productoDAO.buscarPorId(item.getIdProducto());

                if (!productoOpt.isPresent()) {
                    conn.rollback();
                    throw new ServiceException(
                            "Producto ID " + item.getIdProducto() + " no encontrado"
                    );
                }

                Producto producto = productoOpt.get();

                // Verificar disponibilidad
                if (producto.getEstado() != Producto.EstadoProducto.DISPONIBLE) {
                    conn.rollback();
                    throw new ServiceException(
                            "El producto " + producto.getNombre() + " no está disponible"
                    );
                }

                // Verificar stock
                if (!productoDAO.verificarStock(item.getIdProducto(), item.getCantidad())) {
                    conn.rollback();
                    throw new ServiceException(
                            "Stock insuficiente para " + producto.getNombre() +
                                    ". Disponible: " + producto.getStock()
                    );
                }

                // Calcular precio con descuento
                BigDecimal precioUnitario = producto.getPrecioConDescuento();
                BigDecimal subtotal = precioUnitario.multiply(new BigDecimal(item.getCantidad()));

                // Crear detalle (sin ID de pedido aún)
                DetallePedido detalle = new DetallePedido(
                        null, // Se asignará después
                        item.getIdProducto(),
                        item.getCantidad(),
                        precioUnitario
                );

                detalles.add(detalle);
                total = total.add(subtotal);
            }

            // 5. Crear el pedido
            Pedido pedido = new Pedido(idUsuario, direccionEnvio, metodoPago);
            pedido.setTotal(total);
            pedido.setEstado(Pedido.EstadoPedido.PENDIENTE);

            int idPedido = pedidoDAO.crear(pedido);
            logger.info("Pedido creado con ID: {}", idPedido);

            // 6. Asignar ID de pedido a los detalles
            for (DetallePedido detalle : detalles) {
                detalle.setIdPedido(idPedido);
            }

            // 7. Insertar detalles del pedido
            boolean detallesCreados = detalleDAO.crearMultiples(detalles);
            if (!detallesCreados) {
                conn.rollback();
                throw new ServiceException("Error al crear detalles del pedido");
            }

            logger.info("Detalles del pedido creados: {} items", detalles.size());

            // 8. Reducir stock de productos
            for (DetallePedido detalle : detalles) {
                boolean stockReducido = productoDAO.reducirStock(
                        detalle.getIdProducto(),
                        detalle.getCantidad()
                );

                if (!stockReducido) {
                    conn.rollback();
                    throw new ServiceException(
                            "Error al reducir stock del producto ID " + detalle.getIdProducto()
                    );
                }
            }

            logger.info("Stock actualizado para {} productos", detalles.size());

            // 9. Vaciar carrito del usuario
            boolean carritoVaciado = carritoDAO.vaciarCarrito(idUsuario);
            logger.info("Carrito vaciado: {}", carritoVaciado);

            // 10. Commit de la transacción
            conn.commit();
            logger.info("Pedido {} creado exitosamente", idPedido);

            return idPedido;

        } catch (SQLException e) {
            if (conn != null) {
                try {
                    conn.rollback();
                    logger.error("Transacción revertida debido a error", e);
                } catch (SQLException ex) {
                    logger.error("Error al hacer rollback", ex);
                }
            }
            logger.error("Error al crear pedido", e);
            throw new ServiceException("Error al crear pedido: " + e.getMessage(), e);

        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (SQLException e) {
                    logger.error("Error al cerrar conexión", e);
                }
            }
        }
    }

    /**
     * Crea un pedido directo (sin carrito, por ejemplo desde admin)
     */
    public int crearPedidoDirecto(int idUsuario, List<ItemPedido> items,
                                  String direccionEnvio, String metodoPago)
            throws ServiceException {
        logger.info("Creando pedido directo para usuario {}", idUsuario);

        Connection conn = null;

        try {
            conn = DatabaseConnection.getInstance().getConnection();
            conn.setAutoCommit(false);

            // Validaciones básicas
            if (items == null || items.isEmpty()) {
                throw new ServiceException("El pedido debe tener al menos un producto");
            }

            if (direccionEnvio == null || direccionEnvio.trim().isEmpty()) {
                throw new ServiceException("La dirección de envío es requerida");
            }

            // Crear detalles y calcular total
            List<DetallePedido> detalles = new ArrayList<>();
            BigDecimal total = BigDecimal.ZERO;

            for (ItemPedido item : items) {
                Optional<Producto> productoOpt = productoDAO.buscarPorId(item.getIdProducto());

                if (!productoOpt.isPresent()) {
                    conn.rollback();
                    throw new ServiceException("Producto ID " + item.getIdProducto() + " no existe");
                }

                Producto producto = productoOpt.get();

                // Verificar stock
                if (!productoDAO.verificarStock(item.getIdProducto(), item.getCantidad())) {
                    conn.rollback();
                    throw new ServiceException(
                            "Stock insuficiente para " + producto.getNombre()
                    );
                }

                BigDecimal precioUnitario = producto.getPrecioConDescuento();
                BigDecimal subtotal = precioUnitario.multiply(new BigDecimal(item.getCantidad()));

                DetallePedido detalle = new DetallePedido(
                        null,
                        item.getIdProducto(),
                        item.getCantidad(),
                        precioUnitario
                );

                detalles.add(detalle);
                total = total.add(subtotal);
            }

            // Crear pedido
            Pedido pedido = new Pedido(idUsuario, direccionEnvio, metodoPago);
            pedido.setTotal(total);
            pedido.setEstado(Pedido.EstadoPedido.PENDIENTE);

            int idPedido = pedidoDAO.crear(pedido);

            // Asignar ID a detalles
            for (DetallePedido detalle : detalles) {
                detalle.setIdPedido(idPedido);
            }

            // Insertar detalles
            detalleDAO.crearMultiples(detalles);

            // Reducir stock
            for (DetallePedido detalle : detalles) {
                productoDAO.reducirStock(detalle.getIdProducto(), detalle.getCantidad());
            }

            conn.commit();
            logger.info("Pedido directo {} creado exitosamente", idPedido);

            return idPedido;

        } catch (SQLException e) {
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    logger.error("Error al hacer rollback", ex);
                }
            }
            logger.error("Error al crear pedido directo", e);
            throw new ServiceException("Error al crear pedido", e);

        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (SQLException e) {
                    logger.error("Error al cerrar conexión", e);
                }
            }
        }
    }

    // ==================== CONSULTAS DE PEDIDOS ====================

    /**
     * Obtiene un pedido completo con sus detalles y productos
     */
    public PedidoCompleto obtenerPedidoCompleto(int idPedido) throws ServiceException {
        try {
            // Obtener pedido
            Optional<Pedido> pedidoOpt = pedidoDAO.buscarPorId(idPedido);
            if (!pedidoOpt.isPresent()) {
                throw new ServiceException("Pedido no encontrado");
            }

            Pedido pedido = pedidoOpt.get();

            // Obtener usuario
            Optional<Usuario> usuario = usuarioDAO.buscarPorId(pedido.getIdUsuario());
            pedido.setUsuario(usuario.orElse(null));

            // Obtener detalles
            List<DetallePedido> detalles = detalleDAO.obtenerPorPedido(idPedido);

            // Enriquecer detalles con productos
            for (DetallePedido detalle : detalles) {
                Optional<Producto> producto = productoDAO.buscarPorId(detalle.getIdProducto());
                detalle.setProducto(producto.orElse(null));
            }

            pedido.setDetalles(detalles);

            return new PedidoCompleto(pedido, detalles);

        } catch (SQLException e) {
            logger.error("Error al obtener pedido completo", e);
            throw new ServiceException("Error al obtener pedido", e);
        }
    }

    /**
     * Obtiene el historial de pedidos de un usuario
     */
    public List<Pedido> obtenerHistorialUsuario(int idUsuario) throws ServiceException {
        try {
            return pedidoDAO.obtenerPorUsuario(idUsuario);
        } catch (SQLException e) {
            logger.error("Error al obtener historial", e);
            throw new ServiceException("Error al obtener historial de pedidos", e);
        }
    }

    /**
     * Obtiene pedidos por estado (para admin)
     */
    public List<Pedido> obtenerPorEstado(Pedido.EstadoPedido estado) throws ServiceException {
        try {
            return pedidoDAO.obtenerPorEstado(estado);
        } catch (SQLException e) {
            logger.error("Error al obtener pedidos por estado", e);
            throw new ServiceException("Error al obtener pedidos", e);
        }
    }

    /**
     * Obtiene todos los pedidos (para admin)
     */
    public List<Pedido> obtenerTodosPedidos() throws ServiceException {
        try {
            return pedidoDAO.obtenerTodos();
        } catch (SQLException e) {
            logger.error("Error al obtener todos los pedidos", e);
            throw new ServiceException("Error al obtener pedidos", e);
        }
    }

    // ==================== ACTUALIZACIÓN DE PEDIDOS ====================

    /**
     * Actualiza el estado de un pedido
     */
    public void actualizarEstado(int idPedido, Pedido.EstadoPedido nuevoEstado, int idUsuarioActualizador)
            throws ServiceException {
        logger.info("Actualizando estado del pedido {} a {} por usuario {}",
                idPedido, nuevoEstado, idUsuarioActualizador);

        try {
            // Verificar que el pedido existe
            Optional<Pedido> pedidoOpt = pedidoDAO.buscarPorId(idPedido);
            if (!pedidoOpt.isPresent()) {
                throw new ServiceException("Pedido no encontrado");
            }

            Pedido pedido = pedidoOpt.get();
            Pedido.EstadoPedido estadoActual = pedido.getEstado();

            // Validar transición de estado
            if (!esTransicionValida(estadoActual, nuevoEstado)) {
                throw new ServiceException(
                        "No se puede cambiar de " + estadoActual + " a " + nuevoEstado
                );
            }

            // Actualizar estado
            boolean actualizado = pedidoDAO.actualizarEstado(idPedido, nuevoEstado);

            if (!actualizado) {
                throw new ServiceException("No se pudo actualizar el estado del pedido");
            }

            logger.info("Estado del pedido actualizado exitosamente");

            // Aquí se podría enviar notificación por email

        } catch (SQLException e) {
            logger.error("Error al actualizar estado", e);
            throw new ServiceException("Error al actualizar estado del pedido", e);
        }
    }

    /**
     * Cancela un pedido
     */
    public void cancelarPedido(int idPedido, String motivo, int idUsuario) throws ServiceException {
        logger.info("Cancelando pedido {} por usuario {}", idPedido, idUsuario);

        Connection conn = null;

        try {
            conn = DatabaseConnection.getInstance().getConnection();
            conn.setAutoCommit(false);

            // Obtener pedido
            Optional<Pedido> pedidoOpt = pedidoDAO.buscarPorId(idPedido);
            if (!pedidoOpt.isPresent()) {
                throw new ServiceException("Pedido no encontrado");
            }

            Pedido pedido = pedidoOpt.get();

            // Verificar que se puede cancelar
            if (pedido.getEstado() == Pedido.EstadoPedido.ENTREGADO) {
                throw new ServiceException("No se puede cancelar un pedido ya entregado");
            }

            if (pedido.getEstado() == Pedido.EstadoPedido.CANCELADO) {
                throw new ServiceException("El pedido ya está cancelado");
            }

            // Obtener detalles
            List<DetallePedido> detalles = detalleDAO.obtenerPorPedido(idPedido);

            // Restaurar stock
            for (DetallePedido detalle : detalles) {
                Optional<Producto> producto = productoDAO.buscarPorId(detalle.getIdProducto());
                if (producto.isPresent()) {
                    int nuevoStock = producto.get().getStock() + detalle.getCantidad();
                    productoDAO.actualizarStock(detalle.getIdProducto(), nuevoStock);
                }
            }

            // Actualizar estado a cancelado
            pedidoDAO.actualizarEstado(idPedido, Pedido.EstadoPedido.CANCELADO);

            conn.commit();
            logger.info("Pedido cancelado exitosamente");

        } catch (SQLException e) {
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    logger.error("Error al hacer rollback", ex);
                }
            }
            logger.error("Error al cancelar pedido", e);
            throw new ServiceException("Error al cancelar pedido", e);

        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (SQLException e) {
                    logger.error("Error al cerrar conexión", e);
                }
            }
        }
    }

    // ==================== ESTADÍSTICAS ====================

    /**
     * Obtiene estadísticas de pedidos
     */
    public EstadisticasPedidos obtenerEstadisticas() throws ServiceException {
        try {
            int totalPedidos = pedidoDAO.contarPedidos();
            BigDecimal totalVentas = pedidoDAO.calcularTotalVentas();

            List<Pedido> pendientes = pedidoDAO.obtenerPorEstado(Pedido.EstadoPedido.PENDIENTE);
            List<Pedido> procesando = pedidoDAO.obtenerPorEstado(Pedido.EstadoPedido.PROCESANDO);
            List<Pedido> enviados = pedidoDAO.obtenerPorEstado(Pedido.EstadoPedido.ENVIADO);

            return new EstadisticasPedidos(
                    totalPedidos,
                    totalVentas,
                    pendientes.size(),
                    procesando.size(),
                    enviados.size()
            );

        } catch (SQLException e) {
            logger.error("Error al obtener estadísticas", e);
            throw new ServiceException("Error al obtener estadísticas", e);
        }
    }

    // ==================== UTILIDADES PRIVADAS ====================

    /**
     * Valida si una transición de estado es válida
     */
    private boolean esTransicionValida(Pedido.EstadoPedido actual, Pedido.EstadoPedido nuevo) {
        // Desde CANCELADO no se puede cambiar
        if (actual == Pedido.EstadoPedido.CANCELADO) {
            return false;
        }

        // Desde ENTREGADO solo se puede pasar a CANCELADO (devolución)
        if (actual == Pedido.EstadoPedido.ENTREGADO) {
            return nuevo == Pedido.EstadoPedido.CANCELADO;
        }

        // Flujo normal: PENDIENTE -> PROCESANDO -> ENVIADO -> ENTREGADO
        // Siempre se puede cancelar
        if (nuevo == Pedido.EstadoPedido.CANCELADO) {
            return true;
        }

        switch (actual) {
            case PENDIENTE:
                return nuevo == Pedido.EstadoPedido.PROCESANDO;
            case PROCESANDO:
                return nuevo == Pedido.EstadoPedido.ENVIADO;
            case ENVIADO:
                return nuevo == Pedido.EstadoPedido.ENTREGADO;
            default:
                return false;
        }
    }

    // ==================== CLASES INTERNAS ====================

    public static class PedidoCompleto {
        private final Pedido pedido;
        private final List<DetallePedido> detalles;

        public PedidoCompleto(Pedido pedido, List<DetallePedido> detalles) {
            this.pedido = pedido;
            this.detalles = detalles;
        }

        public Pedido getPedido() { return pedido; }
        public List<DetallePedido> getDetalles() { return detalles; }
        public int getCantidadItems() { return detalles.size(); }
        public int getCantidadTotal() {
            return detalles.stream().mapToInt(DetallePedido::getCantidad).sum();
        }
    }

    public static class ItemPedido {
        private final int idProducto;
        private final int cantidad;

        public ItemPedido(int idProducto, int cantidad) {
            this.idProducto = idProducto;
            this.cantidad = cantidad;
        }

        public int getIdProducto() { return idProducto; }
        public int getCantidad() { return cantidad; }
    }

    public static class EstadisticasPedidos {
        private final int totalPedidos;
        private final BigDecimal totalVentas;
        private final int pedidosPendientes;
        private final int pedidosProcesando;
        private final int pedidosEnviados;

        public EstadisticasPedidos(int totalPedidos, BigDecimal totalVentas,
                                   int pedidosPendientes, int pedidosProcesando,
                                   int pedidosEnviados) {
            this.totalPedidos = totalPedidos;
            this.totalVentas = totalVentas;
            this.pedidosPendientes = pedidosPendientes;
            this.pedidosProcesando = pedidosProcesando;
            this.pedidosEnviados = pedidosEnviados;
        }

        public int getTotalPedidos() { return totalPedidos; }
        public BigDecimal getTotalVentas() { return totalVentas; }
        public int getPedidosPendientes() { return pedidosPendientes; }
        public int getPedidosProcesando() { return pedidosProcesando; }
        public int getPedidosEnviados() { return pedidosEnviados; }
    }
    // ==================== MÉTODOS PARA ADMINISTRACIÓN ====================

    /**
     * Cuenta el total de pedidos en el sistema
     *
     * @return Número total de pedidos
     * @throws ServiceException Si hay error en la consulta
     */
    public int contarPedidosTotales() throws ServiceException {
        try {
            return pedidoDAO.contarTodos();
        } catch (SQLException e) {
            logger.error("Error al contar pedidos: {}", e.getMessage());
            throw new ServiceException("Error al contar pedidos");
        }
    }

    /**
     * Cuenta pedidos filtrados por estado
     *
     * @param estado Estado del pedido a contar
     * @return Número de pedidos con ese estado
     * @throws ServiceException Si hay error en la consulta
     */
    public int contarPedidosPorEstado(Pedido.EstadoPedido estado) throws ServiceException {
        try {
            return pedidoDAO.contarPorEstado(estado);
        } catch (SQLException e) {
            logger.error("Error al contar pedidos por estado: {}", e.getMessage());
            throw new ServiceException("Error al contar pedidos por estado");
        }
    }

    /**
     * Cuenta pedidos realizados en el día actual
     *
     * @return Número de pedidos de hoy
     * @throws ServiceException Si hay error en la consulta
     */
    public int contarPedidosHoy() throws ServiceException {
        try {
            return pedidoDAO.contarHoy();
        } catch (SQLException e) {
            logger.error("Error al contar pedidos de hoy: {}", e.getMessage());
            throw new ServiceException("Error al contar pedidos de hoy");
        }
    }

    /**
     * Obtiene los últimos N pedidos del sistema
     * Útil para mostrar en dashboards
     *
     * @param limite Número máximo de pedidos a retornar
     * @return Lista de pedidos recientes
     * @throws ServiceException Si hay error en la consulta
     */
    public List<Pedido> obtenerUltimosPedidos(int limite) throws ServiceException {
        try {
            return pedidoDAO.obtenerUltimos(limite);
        } catch (SQLException e) {
            logger.error("Error al obtener últimos pedidos: {}", e.getMessage());
            throw new ServiceException("Error al obtener últimos pedidos");
        }
    }

    /**
     * Obtiene estadísticas completas de ventas
     * Incluye totales de ventas, ticket promedio, etc.
     *
     * @return Objeto con estadísticas de ventas
     * @throws ServiceException Si hay error en la consulta
     */
    public EstadisticasVentas obtenerEstadisticasVentas() throws ServiceException {
        try {
            EstadisticasVentas stats = new EstadisticasVentas();

            // Ventas totales
            stats.setTotalVentas(pedidoDAO.calcularTotalVentas().doubleValue());

            // Ventas del día
            stats.setVentasHoy(pedidoDAO.calcularVentasHoy().doubleValue());

            // Ventas del mes
            stats.setVentasMes(pedidoDAO.calcularVentasMes().doubleValue());

            // Pedidos completados (ENTREGADO + ENVIADO)
            stats.setPedidosCompletados(
                    pedidoDAO.contarPorEstado(Pedido.EstadoPedido.ENTREGADO) +
                            pedidoDAO.contarPorEstado(Pedido.EstadoPedido.ENVIADO)
            );

            // Pedidos cancelados
            stats.setPedidosCancelados(
                    pedidoDAO.contarPorEstado(Pedido.EstadoPedido.CANCELADO)
            );

            // Ticket promedio
            stats.setTicketPromedio(pedidoDAO.calcularTicketPromedio().doubleValue());

            return stats;

        } catch (SQLException e) {
            logger.error("Error al obtener estadísticas de ventas: {}", e.getMessage());
            throw new ServiceException("Error al obtener estadísticas de ventas");
        }
    }

    /**
     * Clase para estadísticas de ventas
     * Utilizada en el dashboard administrativo
     */
    public static class EstadisticasVentas {
        private double totalVentas;
        private double ventasHoy;
        private double ventasMes;
        private int pedidosCompletados;
        private int pedidosCancelados;
        private double ticketPromedio;

        // Getters y setters
        public double getTotalVentas() { return totalVentas; }
        public void setTotalVentas(double totalVentas) {
            this.totalVentas = totalVentas;
        }

        public double getVentasHoy() { return ventasHoy; }
        public void setVentasHoy(double ventasHoy) {
            this.ventasHoy = ventasHoy;
        }

        public double getVentasMes() { return ventasMes; }
        public void setVentasMes(double ventasMes) {
            this.ventasMes = ventasMes;
        }

        public int getPedidosCompletados() { return pedidosCompletados; }
        public void setPedidosCompletados(int pedidosCompletados) {
            this.pedidosCompletados = pedidosCompletados;
        }

        public int getPedidosCancelados() { return pedidosCancelados; }
        public void setPedidosCancelados(int pedidosCancelados) {
            this.pedidosCancelados = pedidosCancelados;
        }

        public double getTicketPromedio() { return ticketPromedio; }
        public void setTicketPromedio(double ticketPromedio) {
            this.ticketPromedio = ticketPromedio;
        }
    }
}
