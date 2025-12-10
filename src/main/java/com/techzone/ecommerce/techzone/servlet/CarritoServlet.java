package com.techzone.ecommerce.techzone.servlet;

import com.techzone.ecommerce.techzone.dao.CarritoDAO;
import com.techzone.ecommerce.techzone.dao.ProductoDAO;
import com.techzone.ecommerce.techzone.model.Carrito;
import com.techzone.ecommerce.techzone.model.Producto;
import com.techzone.ecommerce.techzone.model.Usuario;
import com.techzone.ecommerce.techzone.service.CarritoService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.SQLException;
import java.util.List;

/**
 * Servlet para gestionar el carrito de compras
 */
@WebServlet(name = "CarritoServlet", urlPatterns = {
        "/carrito",
        "/carrito/agregar",
        "/carrito/actualizar",
        "/carrito/eliminar",
        "/carrito/vaciar"
})
public class CarritoServlet extends HttpServlet {

    private CarritoDAO carritoDAO;
    private ProductoDAO productoDAO;
    private CarritoService carritoService;

    @Override
    public void init() throws ServletException {
        carritoDAO = new CarritoDAO();
        productoDAO = new ProductoDAO();
        carritoService = new CarritoService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String path = request.getServletPath();

        try {
            if ("/carrito".equals(path)) {
                mostrarCarrito(request, response);
            }
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Error al cargar el carrito");
            request.getRequestDispatcher("/views/error.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String path = request.getServletPath();

        try {
            switch (path) {
                case "/carrito/agregar":
                    agregarAlCarrito(request, response);
                    break;
                case "/carrito/actualizar":
                    actualizarCantidad(request, response);
                    break;
                case "/carrito/eliminar":
                    eliminarDelCarrito(request, response);
                    break;
                case "/carrito/vaciar":
                    vaciarCarrito(request, response);
                    break;
                default:
                    response.sendRedirect(request.getContextPath() + "/carrito");
            }
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Error al procesar la solicitud");
            doGet(request, response);
        }
    }

    /**
     * Muestra el carrito de compras
     */
    private void mostrarCarrito(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {

        HttpSession session = request.getSession();
        Usuario usuario = (Usuario) session.getAttribute("usuario");

        if (usuario == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // Obtener items del carrito con información de productos
        List<Carrito> items = carritoDAO.obtenerConProductosPorUsuario(usuario.getIdUsuario());

        // Cargar información completa de cada producto
        for (Carrito item : items) {
            Producto producto = productoDAO.buscarPorId(item.getIdProducto()).orElse(null);
            item.setProducto(producto);
        }

        // Crear objeto CarritoResumen para la vista
        CarritoResumen carritoResumen = new CarritoResumen(items);

        request.setAttribute("carrito", carritoResumen);
        request.getRequestDispatcher("/views/carrito/ver-carrito.jsp").forward(request, response);
    }

    /**
     * Agrega un producto al carrito
     */
    private void agregarAlCarrito(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {

        HttpSession session = request.getSession();
        Usuario usuario = (Usuario) session.getAttribute("usuario");

        if (usuario == null) {
            response.sendRedirect(request.getContextPath() + "/login?redirect=carrito");
            return;
        }

        try {
            int idProducto = Integer.parseInt(request.getParameter("idProducto"));
            int cantidad = Integer.parseInt(request.getParameter("cantidad"));

            // Validar producto y stock
            Producto producto = productoDAO.buscarPorId(idProducto)
                    .orElseThrow(() -> new IllegalArgumentException("Producto no encontrado"));

            if (cantidad <= 0) {
                session.setAttribute("error", "Cantidad inválida");
                response.sendRedirect(request.getContextPath() + "/producto?id=" + idProducto);
                return;
            }

            if (cantidad > producto.getStock()) {
                session.setAttribute("error", "Stock insuficiente. Solo hay " + producto.getStock() + " unidades disponibles");
                response.sendRedirect(request.getContextPath() + "/producto?id=" + idProducto);
                return;
            }

            // Agregar o actualizar en el carrito
            boolean agregado = carritoDAO.agregarOActualizar(
                    usuario.getIdUsuario(),
                    idProducto,
                    cantidad
            );

            if (agregado) {
                session.setAttribute("mensaje", "Producto agregado al carrito");
            } else {
                session.setAttribute("error", "No se pudo agregar al carrito");
            }

            // Actualizar contador del carrito en sesión
            actualizarContadorCarrito(session, usuario.getIdUsuario());

        } catch (NumberFormatException e) {
            session.setAttribute("error", "Datos inválidos");
        } catch (IllegalArgumentException e) {
            session.setAttribute("error", e.getMessage());
        }

        String referer = request.getHeader("Referer");
        if (referer != null && !referer.isEmpty()) {
            response.sendRedirect(referer);
        } else {
            response.sendRedirect(request.getContextPath() + "/productos");
        }
    }

    /**
     * Actualiza la cantidad de un producto en el carrito
     */
    private void actualizarCantidad(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {

        HttpSession session = request.getSession();
        Usuario usuario = (Usuario) session.getAttribute("usuario");

        if (usuario == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        try {
            int idProducto = Integer.parseInt(request.getParameter("idProducto"));
            String accion = request.getParameter("accion");

            // Buscar el item en el carrito
            Carrito item = carritoDAO.buscarPorUsuarioYProducto(
                    usuario.getIdUsuario(),
                    idProducto
            ).orElse(null);

            if (item == null) {
                session.setAttribute("error", "Producto no encontrado en el carrito");
                response.sendRedirect(request.getContextPath() + "/carrito");
                return;
            }

            // Validar stock
            Producto producto = productoDAO.buscarPorId(idProducto)
                    .orElseThrow(() -> new IllegalArgumentException("Producto no encontrado"));

            int nuevaCantidad = item.getCantidad();

            if ("incrementar".equals(accion)) {
                nuevaCantidad++;
            } else if ("decrementar".equals(accion)) {
                nuevaCantidad--;
            }

            // Validaciones
            if (nuevaCantidad <= 0) {
                // Si la cantidad es 0 o menos, eliminar del carrito
                carritoDAO.eliminar(item.getIdCarrito());
                session.setAttribute("mensaje", "Producto eliminado del carrito");
            } else if (nuevaCantidad > producto.getStock()) {
                session.setAttribute("error", "Stock insuficiente. Solo hay " + producto.getStock() + " unidades disponibles");
            } else {
                // Actualizar cantidad
                boolean actualizado = carritoDAO.actualizarCantidad(item.getIdCarrito(), nuevaCantidad);
                if (actualizado) {
                    session.setAttribute("mensaje", "Cantidad actualizada");
                } else {
                    session.setAttribute("error", "No se pudo actualizar la cantidad");
                }
            }

            // Actualizar contador del carrito
            actualizarContadorCarrito(session, usuario.getIdUsuario());

        } catch (NumberFormatException e) {
            session.setAttribute("error", "Datos inválidos");
        } catch (IllegalArgumentException e) {
            session.setAttribute("error", e.getMessage());
        }

        response.sendRedirect(request.getContextPath() + "/carrito");
    }

    /**
     * Elimina un producto del carrito
     */
    private void eliminarDelCarrito(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {

        HttpSession session = request.getSession();
        Usuario usuario = (Usuario) session.getAttribute("usuario");

        if (usuario == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        try {
            int idProducto = Integer.parseInt(request.getParameter("idProducto"));

            boolean eliminado = carritoDAO.eliminarPorUsuarioYProducto(
                    usuario.getIdUsuario(),
                    idProducto
            );

            if (eliminado) {
                session.setAttribute("mensaje", "Producto eliminado del carrito");
            } else {
                session.setAttribute("error", "No se pudo eliminar el producto");
            }

            // Actualizar contador del carrito
            actualizarContadorCarrito(session, usuario.getIdUsuario());

        } catch (NumberFormatException e) {
            session.setAttribute("error", "Datos inválidos");
        }

        response.sendRedirect(request.getContextPath() + "/carrito");
    }

    /**
     * Vacía el carrito completamente
     */
    private void vaciarCarrito(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {

        HttpSession session = request.getSession();
        Usuario usuario = (Usuario) session.getAttribute("usuario");

        if (usuario == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        boolean vaciado = carritoDAO.vaciarCarrito(usuario.getIdUsuario());

        if (vaciado) {
            session.setAttribute("mensaje", "Carrito vaciado");
        } else {
            session.setAttribute("error", "No se pudo vaciar el carrito");
        }

        // Actualizar contador del carrito
        session.setAttribute("cantidadCarrito", 0);

        response.sendRedirect(request.getContextPath() + "/carrito");
    }

    /**
     * Actualiza el contador del carrito en la sesión
     */
    private void actualizarContadorCarrito(HttpSession session, int idUsuario) throws SQLException {
        int cantidadTotal = carritoDAO.contarCantidadTotalPorUsuario(idUsuario);
        session.setAttribute("cantidadCarrito", cantidadTotal);
    }

    /**
     * Clase interna para representar el resumen del carrito
     */
    public static class CarritoResumen {
        private List<Carrito> items;
        private BigDecimal subtotal;
        private BigDecimal totalDescuentos;
        private int cantidadTotal;

        public CarritoResumen(List<Carrito> items) {
            this.items = items;
            calcularTotales();
        }

        private void calcularTotales() {
            subtotal = BigDecimal.ZERO;
            totalDescuentos = BigDecimal.ZERO;
            cantidadTotal = 0;

            for (Carrito item : items) {
                if (item.getProducto() != null) {
                    BigDecimal precioUnitario = item.getProducto().getPrecio();
                    BigDecimal subtotalItem = precioUnitario.multiply(new BigDecimal(item.getCantidad()));
                    subtotal = subtotal.add(subtotalItem);

                    // Calcular descuento si existe
                    if (item.getProducto().getDescuento() != null &&
                            item.getProducto().getDescuento().compareTo(BigDecimal.ZERO) > 0) {
                        BigDecimal descuento = subtotalItem.multiply(item.getProducto().getDescuento())
                                .divide(new BigDecimal(100));
                        totalDescuentos = totalDescuentos.add(descuento);
                    }

                    cantidadTotal += item.getCantidad();
                }
            }
        }

        // Getters
        public List<Carrito> getItems() { return items; }
        public BigDecimal getSubtotal() { return subtotal; }
        public BigDecimal getTotalDescuentos() { return totalDescuentos; }
        public int getCantidadTotal() { return cantidadTotal; }
    }
}