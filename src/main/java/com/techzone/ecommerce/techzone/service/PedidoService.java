package com.techzone.ecommerce.techzone.service;

import com.techzone.ecommerce.techzone.config.DatabaseConnection;
import com.techzone.ecommerce.techzone.dao.*;
import com.techzone.ecommerce.techzone.model.*;

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

    private final PedidoDAO pedidoDAO;
    private final DetallePedidoDAO detalleDAO;
    private final ProductoDAO productoDAO;
    private final CarritoDAO carritoDAO;

    public PedidoService() {
        this.pedidoDAO = new PedidoDAO();
        this.detalleDAO = new DetallePedidoDAO();
        this.productoDAO = new ProductoDAO();
        this.carritoDAO = new CarritoDAO();
    }

    // ==================== CREACIÓN DE PEDIDOS ====================

    /**
     * Crea un pedido completo desde el carrito del usuario
     * Esta operación es transaccional
     */
    public int crearPedidoDesdeCarrito(int idUsuario, String direccionEnvio,
                                       String metodoPago, String notas)
            throws ServiceException {

        Connection conn = null;

        try {
            // Obtener conexión para transacción
            conn = DatabaseConnection.getInstance().getConnection();
            conn.setAutoCommit(false);

            // 1. Obtener items del carrito
            List<Carrito> itemsCarrito = carritoDAO.obtenerPorUsuario(idUsuario);

            if (itemsCarrito.isEmpty()) {
                throw new ServiceException("El carrito está vacío");
            }

            // 2. Validar datos del pedido
            if (direccionEnvio == null || direccionEnvio.trim().isEmpty()) {
                throw new ServiceException("La dirección de envío es requerida");
            }

            if (metodoPago == null || metodoPago.trim().isEmpty()) {
                throw new ServiceException("El método de pago es requerido");
            }

            // 3. Crear detalles y calcular total
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

                // Verificar stock
                if (producto.getStock() < item.getCantidad()) {
                    conn.rollback();
                    throw new ServiceException(
                            "Stock insuficiente para " + producto.getNombre() +
                                    ". Disponible: " + producto.getStock()
                    );
                }

                // Calcular precio con descuento
                BigDecimal precioUnitario = producto.getPrecio();

                if (producto.getDescuento() != null &&
                        producto.getDescuento().compareTo(BigDecimal.ZERO) > 0) {
                    BigDecimal descuento = precioUnitario
                            .multiply(producto.getDescuento())
                            .divide(new BigDecimal(100));
                    precioUnitario = precioUnitario.subtract(descuento);
                }

                BigDecimal subtotal = precioUnitario.multiply(new BigDecimal(item.getCantidad()));

                // Crear detalle (sin ID de pedido aún)
                DetallePedido detalle = new DetallePedido();
                detalle.setIdProducto(item.getIdProducto());
                detalle.setCantidad(item.getCantidad());
                detalle.setPrecioUnitario(precioUnitario);
                detalle.setSubtotal(subtotal);

                detalles.add(detalle);
                total = total.add(subtotal);
            }

            // 4. Crear el pedido
            Pedido pedido = new Pedido();
            pedido.setIdUsuario(idUsuario);
            pedido.setDireccionEnvio(direccionEnvio);
            pedido.setMetodoPago(metodoPago);
            pedido.setTotal(total);
            pedido.setEstado("PENDIENTE");
            pedido.setNotas(notas);

            int idPedido = pedidoDAO.crear(pedido);

            // 5. Asignar ID de pedido a los detalles
            for (DetallePedido detalle : detalles) {
                detalle.setIdPedido(idPedido);
            }

            // 6. Insertar detalles del pedido
            boolean detallesCreados = detalleDAO.crearMultiples(detalles);
            if (!detallesCreados) {
                conn.rollback();
                throw new ServiceException("Error al crear detalles del pedido");
            }

            // 7. Reducir stock de productos
            for (DetallePedido detalle : detalles) {
                Optional<Producto> productoOpt = productoDAO.buscarPorId(detalle.getIdProducto());
                if (productoOpt.isPresent()) {
                    Producto producto = productoOpt.get();
                    int nuevoStock = producto.getStock() - detalle.getCantidad();
                    producto.setStock(nuevoStock);
                    productoDAO.actualizar(producto);
                }
            }

            // 8. Vaciar carrito del usuario
            carritoDAO.vaciarCarrito(idUsuario);

            // 9. Commit de la transacción
            conn.commit();

            return idPedido;

        } catch (SQLException e) {
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
            throw new ServiceException("Error al crear pedido: " + e.getMessage(), e);

        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                } catch (SQLException e) {
                    e.printStackTrace();
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

            // Obtener detalles
            List<DetallePedido> detalles = detalleDAO.obtenerPorPedido(idPedido);

            // Enriquecer detalles con productos
            for (DetallePedido detalle : detalles) {
                Optional<Producto> producto = productoDAO.buscarPorId(detalle.getIdProducto());
                detalle.setProducto(producto.orElse(null));
            }

            return new PedidoCompleto(pedido, detalles);

        } catch (SQLException e) {
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
            throw new ServiceException("Error al obtener historial de pedidos", e);
        }
    }

    /**
     * Obtiene pedidos por estado
     */
    public List<Pedido> obtenerPorEstado(String estado) throws ServiceException {
        try {
            return pedidoDAO.obtenerPorEstado(estado);
        } catch (SQLException e) {
            throw new ServiceException("Error al obtener pedidos", e);
        }
    }

    /**
     * Obtiene todos los pedidos
     */
    public List<Pedido> obtenerTodosPedidos() throws ServiceException {
        try {
            return pedidoDAO.obtenerTodos();
        } catch (SQLException e) {
            throw new ServiceException("Error al obtener pedidos", e);
        }
    }

    // ==================== ACTUALIZACIÓN DE PEDIDOS ====================

    /**
     * Actualiza el estado de un pedido
     */
    public void actualizarEstado(int idPedido, String nuevoEstado) throws ServiceException {
        try {
            // Verificar que el pedido existe
            Optional<Pedido> pedidoOpt = pedidoDAO.buscarPorId(idPedido);
            if (!pedidoOpt.isPresent()) {
                throw new ServiceException("Pedido no encontrado");
            }

            Pedido pedido = pedidoOpt.get();
            String estadoActual = pedido.getEstado();

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

        } catch (SQLException e) {
            throw new ServiceException("Error al actualizar estado del pedido", e);
        }
    }

    /**
     * Cancela un pedido
     */
    public void cancelarPedido(int idPedido) throws ServiceException {
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
            if ("ENTREGADO".equals(pedido.getEstado())) {
                throw new ServiceException("No se puede cancelar un pedido ya entregado");
            }

            if ("CANCELADO".equals(pedido.getEstado())) {
                throw new ServiceException("El pedido ya está cancelado");
            }

            // Obtener detalles
            List<DetallePedido> detalles = detalleDAO.obtenerPorPedido(idPedido);

            // Restaurar stock
            for (DetallePedido detalle : detalles) {
                Optional<Producto> productoOpt = productoDAO.buscarPorId(detalle.getIdProducto());
                if (productoOpt.isPresent()) {
                    Producto producto = productoOpt.get();
                    int nuevoStock = producto.getStock() + detalle.getCantidad();
                    producto.setStock(nuevoStock);
                    productoDAO.actualizar(producto);
                }
            }

            // Actualizar estado a cancelado
            pedidoDAO.actualizarEstado(idPedido, "CANCELADO");

            conn.commit();

        } catch (SQLException e) {
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
            throw new ServiceException("Error al cancelar pedido", e);

        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }
    }

    // ==================== ESTADÍSTICAS ====================

    /**
     * Cuenta el total de pedidos de un usuario
     */
    public int contarPedidosUsuario(int idUsuario) throws ServiceException {
        try {
            return pedidoDAO.contarPorUsuario(idUsuario);
        } catch (SQLException e) {
            throw new ServiceException("Error al contar pedidos", e);
        }
    }

    /**
     * Cuenta pedidos por estado
     */
    public int contarPedidosPorEstado(String estado) throws ServiceException {
        try {
            return pedidoDAO.contarPorEstado(estado);
        } catch (SQLException e) {
            throw new ServiceException("Error al contar pedidos por estado", e);
        }
    }

    // ==================== UTILIDADES PRIVADAS ====================

    /**
     * Valida si una transición de estado es válida
     */
    private boolean esTransicionValida(String actual, String nuevo) {
        // Desde CANCELADO no se puede cambiar
        if ("CANCELADO".equals(actual)) {
            return false;
        }

        // Desde ENTREGADO solo se puede pasar a CANCELADO (devolución)
        if ("ENTREGADO".equals(actual)) {
            return "CANCELADO".equals(nuevo);
        }

        // Siempre se puede cancelar
        if ("CANCELADO".equals(nuevo)) {
            return true;
        }

        // Flujo normal: PENDIENTE -> PROCESANDO -> ENVIADO -> ENTREGADO
        switch (actual) {
            case "PENDIENTE":
                return "PROCESANDO".equals(nuevo);
            case "PROCESANDO":
                return "ENVIADO".equals(nuevo);
            case "ENVIADO":
                return "ENTREGADO".equals(nuevo);
            default:
                return false;
        }
    }

    // ==================== CLASES INTERNAS ====================

    /**
     * Clase para representar un pedido completo con todos sus detalles
     */
    public static class PedidoCompleto {
        private final Pedido pedido;
        private final List<DetallePedido> detalles;

        public PedidoCompleto(Pedido pedido, List<DetallePedido> detalles) {
            this.pedido = pedido;
            this.detalles = detalles;
        }

        public Pedido getPedido() {
            return pedido;
        }

        public List<DetallePedido> getDetalles() {
            return detalles;
        }

        public int getCantidadItems() {
            return detalles.size();
        }

        public int getCantidadTotal() {
            int total = 0;
            for (DetallePedido detalle : detalles) {
                total += detalle.getCantidad();
            }
            return total;
        }
    }
}