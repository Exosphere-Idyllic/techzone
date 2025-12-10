package com.techzone.ecommerce.techzone.servlet;

import com.techzone.ecommerce.techzone.dao.CarritoDAO;
import com.techzone.ecommerce.techzone.dao.DetallePedidoDAO;
import com.techzone.ecommerce.techzone.dao.PedidoDAO;
import com.techzone.ecommerce.techzone.dao.ProductoDAO;
import com.techzone.ecommerce.techzone.model.*;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.SQLException;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

/**
 * Servlet para gestionar el proceso de checkout
 */
@WebServlet(name = "CheckoutServlet", urlPatterns = {
        "/checkout",
        "/checkout/procesar"
})
public class CheckoutServlet extends HttpServlet {

    private CarritoDAO carritoDAO;
    private ProductoDAO productoDAO;
    private PedidoDAO pedidoDAO;
    private DetallePedidoDAO detallePedidoDAO;

    @Override
    public void init() throws ServletException {
        carritoDAO = new CarritoDAO();
        productoDAO = new ProductoDAO();
        pedidoDAO = new PedidoDAO();
        detallePedidoDAO = new DetallePedidoDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        Usuario usuario = (Usuario) session.getAttribute("usuario");

        if (usuario == null) {
            response.sendRedirect(request.getContextPath() + "/login?redirect=checkout");
            return;
        }

        try {
            // Obtener items del carrito
            List<Carrito> items = carritoDAO.obtenerConProductosPorUsuario(usuario.getIdUsuario());

            if (items.isEmpty()) {
                session.setAttribute("error", "Tu carrito está vacío");
                response.sendRedirect(request.getContextPath() + "/carrito");
                return;
            }

            // Cargar información completa de productos
            for (Carrito item : items) {
                Producto producto = productoDAO.buscarPorId(item.getIdProducto()).orElse(null);
                item.setProducto(producto);
            }

            // Calcular totales
            BigDecimal subtotal = BigDecimal.ZERO;
            BigDecimal totalDescuentos = BigDecimal.ZERO;

            for (Carrito item : items) {
                if (item.getProducto() != null) {
                    BigDecimal precioUnitario = item.getProducto().getPrecio();
                    BigDecimal subtotalItem = precioUnitario.multiply(new BigDecimal(item.getCantidad()));
                    subtotal = subtotal.add(subtotalItem);

                    // Calcular descuento
                    if (item.getProducto().getDescuento() != null &&
                            item.getProducto().getDescuento().compareTo(BigDecimal.ZERO) > 0) {
                        BigDecimal descuento = subtotalItem.multiply(item.getProducto().getDescuento())
                                .divide(new BigDecimal(100));
                        totalDescuentos = totalDescuentos.add(descuento);
                    }
                }
            }

            BigDecimal subtotalConDescuento = subtotal.subtract(totalDescuentos);
            BigDecimal iva = subtotalConDescuento.multiply(new BigDecimal("0.15"));
            BigDecimal total = subtotalConDescuento.add(iva);

            // Crear objeto resumen para la vista
            CarritoServlet.CarritoResumen carritoResumen = new CarritoServlet.CarritoResumen(items);

            request.setAttribute("carrito", carritoResumen);
            request.setAttribute("subtotal", subtotal);
            request.setAttribute("total", total);

            request.getRequestDispatcher("/views/carrito/checkout.jsp").forward(request, response);

        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Error al cargar el checkout");
            request.getRequestDispatcher("/views/error.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String path = request.getServletPath();

        if ("/checkout/procesar".equals(path)) {
            procesarPedido(request, response);
        }
    }

    /**
     * Procesa el pedido y crea el registro en la base de datos
     */
    private void procesarPedido(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        Usuario usuario = (Usuario) session.getAttribute("usuario");

        if (usuario == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        try {
            // Obtener datos del formulario
            String nombre = request.getParameter("nombre");
            String apellido = request.getParameter("apellido");
            String direccion = request.getParameter("direccion");
            String ciudad = request.getParameter("ciudad");
            String codigoPostal = request.getParameter("codigoPostal");
            String telefono = request.getParameter("telefono");
            String email = request.getParameter("email");
            String metodoPago = request.getParameter("metodoPago");
            String notas = request.getParameter("notas");

            // Validaciones básicas
            if (nombre == null || nombre.trim().isEmpty() ||
                    apellido == null || apellido.trim().isEmpty() ||
                    direccion == null || direccion.trim().isEmpty() ||
                    ciudad == null || ciudad.trim().isEmpty() ||
                    telefono == null || telefono.trim().isEmpty() ||
                    email == null || email.trim().isEmpty() ||
                    metodoPago == null || metodoPago.trim().isEmpty()) {

                request.setAttribute("error", "Por favor completa todos los campos obligatorios");
                doGet(request, response);
                return;
            }

            // Obtener items del carrito
            List<Carrito> items = carritoDAO.obtenerConProductosPorUsuario(usuario.getIdUsuario());

            if (items.isEmpty()) {
                request.setAttribute("error", "Tu carrito está vacío");
                response.sendRedirect(request.getContextPath() + "/carrito");
                return;
            }

            // Cargar productos completos
            for (Carrito item : items) {
                Producto producto = productoDAO.buscarPorId(item.getIdProducto())
                        .orElseThrow(() -> new IllegalArgumentException("Producto no encontrado"));
                item.setProducto(producto);

                // Validar stock
                if (item.getCantidad() > producto.getStock()) {
                    request.setAttribute("error", "Stock insuficiente para " + producto.getNombre());
                    doGet(request, response);
                    return;
                }
            }

            // Calcular totales
            BigDecimal subtotal = BigDecimal.ZERO;
            BigDecimal totalDescuentos = BigDecimal.ZERO;

            for (Carrito item : items) {
                BigDecimal precioUnitario = item.getProducto().getPrecio();
                BigDecimal subtotalItem = precioUnitario.multiply(new BigDecimal(item.getCantidad()));
                subtotal = subtotal.add(subtotalItem);

                if (item.getProducto().getDescuento() != null &&
                        item.getProducto().getDescuento().compareTo(BigDecimal.ZERO) > 0) {
                    BigDecimal descuento = subtotalItem.multiply(item.getProducto().getDescuento())
                            .divide(new BigDecimal(100));
                    totalDescuentos = totalDescuentos.add(descuento);
                }
            }

            BigDecimal subtotalConDescuento = subtotal.subtract(totalDescuentos);
            BigDecimal iva = subtotalConDescuento.multiply(new BigDecimal("0.15"));
            BigDecimal total = subtotalConDescuento.add(iva);

            // Construir dirección completa
            String direccionCompleta = String.format("%s, %s, %s",
                    direccion,
                    ciudad,
                    codigoPostal != null && !codigoPostal.isEmpty() ? codigoPostal : "N/A"
            );

            // Crear el pedido
            Pedido pedido = new Pedido();
            pedido.setIdUsuario(usuario.getIdUsuario());
            pedido.setFechaPedido(LocalDateTime.now());
            pedido.setEstado("PENDIENTE");
            pedido.setTotal(total);
            pedido.setDireccionEnvio(direccionCompleta);
            pedido.setMetodoPago(metodoPago);

            if (notas != null && !notas.trim().isEmpty()) {
                pedido.setNotas(notas);
            }

            int idPedido = pedidoDAO.crear(pedido);
            pedido.setIdPedido(idPedido);

            // Crear los detalles del pedido
            List<DetallePedido> detalles = new ArrayList<>();

            for (Carrito item : items) {
                Producto producto = item.getProducto();
                BigDecimal precioUnitario = producto.getPrecio();

                // Aplicar descuento si existe
                if (producto.getDescuento() != null && producto.getDescuento().compareTo(BigDecimal.ZERO) > 0) {
                    BigDecimal descuento = precioUnitario.multiply(producto.getDescuento())
                            .divide(new BigDecimal(100));
                    precioUnitario = precioUnitario.subtract(descuento);
                }

                BigDecimal subtotalDetalle = precioUnitario.multiply(new BigDecimal(item.getCantidad()));

                DetallePedido detalle = new DetallePedido();
                detalle.setIdPedido(idPedido);
                detalle.setIdProducto(producto.getIdProducto());
                detalle.setCantidad(item.getCantidad());
                detalle.setPrecioUnitario(precioUnitario);
                detalle.setSubtotal(subtotalDetalle);
                detalle.setProducto(producto);

                detalles.add(detalle);
            }

            // Guardar detalles del pedido
            detallePedidoDAO.crearMultiples(detalles);

            // Actualizar stock de productos
            for (Carrito item : items) {
                Producto producto = item.getProducto();
                int nuevoStock = producto.getStock() - item.getCantidad();
                producto.setStock(nuevoStock);
                productoDAO.actualizar(producto);
            }

            // Vaciar el carrito
            carritoDAO.vaciarCarrito(usuario.getIdUsuario());
            session.setAttribute("cantidadCarrito", 0);

            // Guardar información en sesión para la confirmación
            session.setAttribute("pedido", pedido);
            session.setAttribute("detalles", detalles);

            // Redirigir a página de confirmación
            response.sendRedirect(request.getContextPath() + "/checkout/confirmacion");

        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Error al procesar el pedido. Por favor intenta nuevamente.");
            doGet(request, response);
        } catch (IllegalArgumentException e) {
            request.setAttribute("error", e.getMessage());
            doGet(request, response);
        }
    }
}