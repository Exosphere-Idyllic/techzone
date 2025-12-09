package com.techzone.ecommerce.techzone.service;

import com.techzone.ecommerce.techzone.service.ServiceException;
import com.techzone.ecommerce.techzone.dao.CarritoDAO;
import com.techzone.ecommerce.techzone.dao.ProductoDAO;
import com.techzone.ecommerce.techzone.model.Carrito;
import com.techzone.ecommerce.techzone.model.Producto;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.math.BigDecimal;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

/**
 * Servicio de lógica de negocio para gestión del carrito de compras
 * @author TechZone Team
 */
public class CarritoService {

    private static final Logger logger = LoggerFactory.getLogger(CarritoService.class);
    private final CarritoDAO carritoDAO;
    private final ProductoDAO productoDAO;
    private static final int CANTIDAD_MAXIMA_POR_PRODUCTO = 10;

    public CarritoService() {
        this.carritoDAO = new CarritoDAO();
        this.productoDAO = new ProductoDAO();
    }

    // ==================== GESTIÓN DEL CARRITO ====================

    /**
     * Agrega un producto al carrito del usuario
     * @param idUsuario ID del usuario
     * @param idProducto ID del producto
     * @param cantidad Cantidad a agregar
     */
    public void agregarAlCarrito(int idUsuario, int idProducto, int cantidad)
            throws ServiceException {
        logger.info("Agregando producto {} al carrito del usuario {}", idProducto, idUsuario);

        try {
            // Validar cantidad
            if (cantidad <= 0) {
                throw new ServiceException("La cantidad debe ser mayor a cero");
            }

            if (cantidad > CANTIDAD_MAXIMA_POR_PRODUCTO) {
                throw new ServiceException(
                        "No puedes agregar más de " + CANTIDAD_MAXIMA_POR_PRODUCTO +
                                " unidades de un producto"
                );
            }

            // Verificar que el producto existe y está disponible
            Optional<Producto> productoOpt = productoDAO.buscarPorId(idProducto);
            if (!productoOpt.isPresent()) {
                throw new ServiceException("El producto no existe");
            }

            Producto producto = productoOpt.get();

            if (producto.getEstado() != Producto.EstadoProducto.DISPONIBLE) {
                throw new ServiceException("El producto no está disponible");
            }

            // Verificar stock disponible
            if (!productoDAO.verificarStock(idProducto, cantidad)) {
                throw new ServiceException(
                        "Stock insuficiente. Disponible: " + producto.getStock()
                );
            }

            // Verificar si el producto ya está en el carrito
            Optional<Carrito> carritoExistente = carritoDAO.buscarPorUsuarioYProducto(
                    idUsuario, idProducto
            );

            if (carritoExistente.isPresent()) {
                // Actualizar cantidad
                Carrito carrito = carritoExistente.get();
                int nuevaCantidad = carrito.getCantidad() + cantidad;

                // Verificar límite máximo
                if (nuevaCantidad > CANTIDAD_MAXIMA_POR_PRODUCTO) {
                    throw new ServiceException(
                            "No puedes tener más de " + CANTIDAD_MAXIMA_POR_PRODUCTO +
                                    " unidades de este producto en el carrito"
                    );
                }

                // Verificar stock para la nueva cantidad
                if (!productoDAO.verificarStock(idProducto, nuevaCantidad)) {
                    throw new ServiceException(
                            "Stock insuficiente para agregar esta cantidad. Disponible: " +
                                    producto.getStock()
                    );
                }

                carritoDAO.actualizarCantidad(carrito.getIdCarrito(), nuevaCantidad);
                logger.info("Cantidad actualizada en el carrito");

            } else {
                // Agregar nuevo item
                Carrito nuevoItem = new Carrito(idUsuario, idProducto, cantidad);
                carritoDAO.agregar(nuevoItem);
                logger.info("Producto agregado al carrito exitosamente");
            }

        } catch (SQLException e) {
            logger.error("Error al agregar al carrito", e);
            throw new ServiceException("Error al agregar al carrito", e);
        }
    }

    /**
     * Actualiza la cantidad de un producto en el carrito
     */
    public void actualizarCantidad(int idCarrito, int nuevaCantidad) throws ServiceException {
        logger.info("Actualizando cantidad del item {} a {}", idCarrito, nuevaCantidad);

        try {
            // Validar cantidad
            if (nuevaCantidad <= 0) {
                throw new ServiceException("La cantidad debe ser mayor a cero");
            }

            if (nuevaCantidad > CANTIDAD_MAXIMA_POR_PRODUCTO) {
                throw new ServiceException(
                        "No puedes tener más de " + CANTIDAD_MAXIMA_POR_PRODUCTO + " unidades"
                );
            }

            // Obtener item del carrito
            Optional<Carrito> carritoOpt = carritoDAO.buscarPorId(idCarrito);
            if (!carritoOpt.isPresent()) {
                throw new ServiceException("Item del carrito no encontrado");
            }

            Carrito carrito = carritoOpt.get();

            // Verificar stock disponible
            if (!productoDAO.verificarStock(carrito.getIdProducto(), nuevaCantidad)) {
                Optional<Producto> producto = productoDAO.buscarPorId(carrito.getIdProducto());
                throw new ServiceException(
                        "Stock insuficiente. Disponible: " +
                                (producto.isPresent() ? producto.get().getStock() : 0)
                );
            }

            // Actualizar
            boolean actualizado = carritoDAO.actualizarCantidad(idCarrito, nuevaCantidad);

            if (!actualizado) {
                throw new ServiceException("No se pudo actualizar la cantidad");
            }

            logger.info("Cantidad actualizada exitosamente");

        } catch (SQLException e) {
            logger.error("Error al actualizar cantidad", e);
            throw new ServiceException("Error al actualizar cantidad", e);
        }
    }

    /**
     * Elimina un producto del carrito
     */
    public void eliminarDelCarrito(int idCarrito) throws ServiceException {
        logger.info("Eliminando item {} del carrito", idCarrito);

        try {
            boolean eliminado = carritoDAO.eliminar(idCarrito);

            if (!eliminado) {
                throw new ServiceException("No se pudo eliminar el producto del carrito");
            }

            logger.info("Producto eliminado del carrito exitosamente");

        } catch (SQLException e) {
            logger.error("Error al eliminar del carrito", e);
            throw new ServiceException("Error al eliminar del carrito", e);
        }
    }

    /**
     * Vacía completamente el carrito de un usuario
     */
    public void vaciarCarrito(int idUsuario) throws ServiceException {
        logger.info("Vaciando carrito del usuario {}", idUsuario);

        try {
            boolean vaciado = carritoDAO.vaciarCarrito(idUsuario);

            if (!vaciado) {
                logger.warn("No se encontraron items para eliminar en el carrito");
            }

            logger.info("Carrito vaciado exitosamente");

        } catch (SQLException e) {
            logger.error("Error al vaciar carrito", e);
            throw new ServiceException("Error al vaciar carrito", e);
        }
    }

    // ==================== CONSULTAS DEL CARRITO ====================

    /**
     * Obtiene el carrito completo de un usuario con totales calculados
     */
    public CarritoCompleto obtenerCarritoCompleto(int idUsuario) throws ServiceException {
        try {
            // Obtener items del carrito
            List<Carrito> items = carritoDAO.obtenerPorUsuario(idUsuario);

            if (items.isEmpty()) {
                return new CarritoCompleto(new ArrayList<>(), BigDecimal.ZERO,
                        BigDecimal.ZERO, BigDecimal.ZERO, 0, new ArrayList<>());
            }

            // Enriquecer items con información de productos
            List<ItemCarrito> itemsCompletos = new ArrayList<>();
            BigDecimal subtotal = BigDecimal.ZERO;
            BigDecimal totalDescuentos = BigDecimal.ZERO;
            int cantidadTotal = 0;
            List<String> problemas = new ArrayList<>();

            for (Carrito item : items) {
                Optional<Producto> productoOpt = productoDAO.buscarPorId(item.getIdProducto());

                if (!productoOpt.isPresent()) {
                    problemas.add("Producto ID " + item.getIdProducto() + " no encontrado");
                    continue;
                }

                Producto producto = productoOpt.get();

                // Verificar disponibilidad
                if (producto.getEstado() != Producto.EstadoProducto.DISPONIBLE) {
                    problemas.add(producto.getNombre() + " ya no está disponible");
                    continue;
                }

                // Verificar stock
                if (producto.getStock() < item.getCantidad()) {
                    problemas.add(
                            producto.getNombre() + ": stock insuficiente. Disponible: " +
                                    producto.getStock()
                    );
                    continue;
                }

                // Calcular precios
                BigDecimal precioUnitario = producto.getPrecio();
                BigDecimal precioConDescuento = producto.getPrecioConDescuento();
                BigDecimal subtotalItem = precioConDescuento.multiply(
                        new BigDecimal(item.getCantidad())
                );
                BigDecimal descuentoItem = precioUnitario.subtract(precioConDescuento)
                        .multiply(new BigDecimal(item.getCantidad()));

                // Crear item completo
                ItemCarrito itemCompleto = new ItemCarrito(
                        item,
                        producto,
                        precioUnitario,
                        precioConDescuento,
                        subtotalItem,
                        descuentoItem
                );

                itemsCompletos.add(itemCompleto);
                subtotal = subtotal.add(subtotalItem);
                totalDescuentos = totalDescuentos.add(descuentoItem);
                cantidadTotal += item.getCantidad();
            }

            BigDecimal total = subtotal;

            return new CarritoCompleto(
                    itemsCompletos,
                    subtotal,
                    totalDescuentos,
                    total,
                    cantidadTotal,
                    problemas
            );

        } catch (SQLException e) {
            logger.error("Error al obtener carrito completo", e);
            throw new ServiceException("Error al obtener carrito", e);
        }
    }

    /**
     * Obtiene el número de items en el carrito
     */
    public int contarItemsCarrito(int idUsuario) throws ServiceException {
        try {
            return carritoDAO.contarItemsPorUsuario(idUsuario);
        } catch (SQLException e) {
            logger.error("Error al contar items del carrito", e);
            throw new ServiceException("Error al contar items del carrito", e);
        }
    }

    /**
     * Obtiene la cantidad total de productos en el carrito
     */
    public int contarCantidadTotal(int idUsuario) throws ServiceException {
        try {
            return carritoDAO.contarCantidadTotalPorUsuario(idUsuario);
        } catch (SQLException e) {
            logger.error("Error al contar cantidad total", e);
            throw new ServiceException("Error al contar cantidad total", e);
        }
    }

    // ==================== VALIDACIONES ====================

    /**
     * Valida el carrito antes de proceder al checkout
     * @return Lista de problemas encontrados (vacía si todo está bien)
     */
    public List<String> validarCarrito(int idUsuario) throws ServiceException {
        logger.info("Validando carrito del usuario {}", idUsuario);

        List<String> problemas = new ArrayList<>();

        try {
            List<Carrito> items = carritoDAO.obtenerPorUsuario(idUsuario);

            if (items.isEmpty()) {
                problemas.add("El carrito está vacío");
                return problemas;
            }

            for (Carrito item : items) {
                Optional<Producto> productoOpt = productoDAO.buscarPorId(item.getIdProducto());

                if (!productoOpt.isPresent()) {
                    problemas.add("Producto ID " + item.getIdProducto() + " no existe");
                    continue;
                }

                Producto producto = productoOpt.get();

                // Verificar estado
                if (producto.getEstado() != Producto.EstadoProducto.DISPONIBLE) {
                    problemas.add(
                            producto.getNombre() + " no está disponible actualmente"
                    );
                }

                // Verificar stock
                if (producto.getStock() < item.getCantidad()) {
                    problemas.add(
                            producto.getNombre() + ": stock insuficiente. " +
                                    "Solicitado: " + item.getCantidad() + ", " +
                                    "Disponible: " + producto.getStock()
                    );
                }
            }

            return problemas;

        } catch (SQLException e) {
            logger.error("Error al validar carrito", e);
            throw new ServiceException("Error al validar carrito", e);
        }
    }

    /**
     * Limpia items no disponibles del carrito
     */
    public int limpiarItemsNoDisponibles(int idUsuario) throws ServiceException {
        logger.info("Limpiando items no disponibles del carrito del usuario {}", idUsuario);

        int itemsEliminados = 0;

        try {
            List<Carrito> items = carritoDAO.obtenerPorUsuario(idUsuario);

            for (Carrito item : items) {
                Optional<Producto> productoOpt = productoDAO.buscarPorId(item.getIdProducto());

                boolean eliminar = false;

                if (!productoOpt.isPresent()) {
                    eliminar = true;
                } else {
                    Producto producto = productoOpt.get();

                    // Eliminar si no está disponible o no hay stock
                    if (producto.getEstado() != Producto.EstadoProducto.DISPONIBLE ||
                            producto.getStock() == 0) {
                        eliminar = true;
                    }
                    // Ajustar cantidad si el stock es menor
                    else if (producto.getStock() < item.getCantidad()) {
                        carritoDAO.actualizarCantidad(item.getIdCarrito(), producto.getStock());
                    }
                }

                if (eliminar) {
                    carritoDAO.eliminar(item.getIdCarrito());
                    itemsEliminados++;
                }
            }

            logger.info("Items eliminados: {}", itemsEliminados);
            return itemsEliminados;

        } catch (SQLException e) {
            logger.error("Error al limpiar items no disponibles", e);
            throw new ServiceException("Error al limpiar carrito", e);
        }
    }

    // ==================== CLASES INTERNAS ====================

    public static class CarritoCompleto {
        private final List<ItemCarrito> items;
        private final BigDecimal subtotal;
        private final BigDecimal totalDescuentos;
        private final BigDecimal total;
        private final int cantidadTotal;
        private final List<String> problemas;

        public CarritoCompleto(List<ItemCarrito> items, BigDecimal subtotal,
                               BigDecimal totalDescuentos, BigDecimal total,
                               int cantidadTotal, List<String> problemas) {
            this.items = items;
            this.subtotal = subtotal;
            this.totalDescuentos = totalDescuentos;
            this.total = total;
            this.cantidadTotal = cantidadTotal;
            this.problemas = problemas;
        }

        public List<ItemCarrito> getItems() { return items; }
        public BigDecimal getSubtotal() { return subtotal; }
        public BigDecimal getTotalDescuentos() { return totalDescuentos; }
        public BigDecimal getTotal() { return total; }
        public int getCantidadTotal() { return cantidadTotal; }
        public List<String> getProblemas() { return problemas; }
        public boolean tieneProblemas() { return !problemas.isEmpty(); }
        public boolean estaVacio() { return items.isEmpty(); }
    }

    public static class ItemCarrito {
        private final Carrito carrito;
        private final Producto producto;
        private final BigDecimal precioUnitario;
        private final BigDecimal precioConDescuento;
        private final BigDecimal subtotal;
        private final BigDecimal descuento;

        public ItemCarrito(Carrito carrito, Producto producto,
                           BigDecimal precioUnitario, BigDecimal precioConDescuento,
                           BigDecimal subtotal, BigDecimal descuento) {
            this.carrito = carrito;
            this.producto = producto;
            this.precioUnitario = precioUnitario;
            this.precioConDescuento = precioConDescuento;
            this.subtotal = subtotal;
            this.descuento = descuento;
        }

        public Carrito getCarrito() { return carrito; }
        public Producto getProducto() { return producto; }
        public BigDecimal getPrecioUnitario() { return precioUnitario; }
        public BigDecimal getPrecioConDescuento() { return precioConDescuento; }
        public BigDecimal getSubtotal() { return subtotal; }
        public BigDecimal getDescuento() { return descuento; }
        public boolean tieneDescuento() {
            return descuento.compareTo(BigDecimal.ZERO) > 0;
        }
    }
}