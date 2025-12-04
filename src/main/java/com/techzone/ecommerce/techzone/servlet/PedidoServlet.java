package com.techzone.ecommerce.techzone.servlet;

import com.google.protobuf.ServiceException;
import com.techzone.ecommerce.techzone.model.Pedido;
import com.techzone.ecommerce.techzone.model.Usuario;
import com.techzone.ecommerce.techzone.service.CarritoService;
import com.techzone.ecommerce.techzone.service.CarritoService.CarritoCompleto;
import com.techzone.ecommerce.techzone.service.PedidoService;
import com.techzone.ecommerce.techzone.service.PedidoService.PedidoCompleto;
import com.techzone.ecommerce.techzone.util.SessionUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;
import java.util.List;

/**
 * Servlet para gestión de pedidos: checkout, crear, historial, detalle
 * Requiere autenticación (protegido por AuthenticationFilter)
 * 
 * @author TechZone Team
 */
@WebServlet(name = "PedidoServlet", urlPatterns = {
        "/checkout",
        "/pedido/crear",
        "/pedido/confirmacion",
        "/pedidos",
        "/pedido/detalle",
        "/pedido/cancelar"
})
public class PedidoServlet extends HttpServlet {

    private static final Logger logger = LoggerFactory.getLogger(PedidoServlet.class);
    private PedidoService pedidoService;
    private CarritoService carritoService;

    @Override
    public void init() throws ServletException {
        super.init();
        this.pedidoService = new PedidoService();
        this.carritoService = new CarritoService();
        logger.info("PedidoServlet inicializado");
    }

    // ==================== MÉTODO GET ====================

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String path = request.getServletPath();
        logger.debug("GET request: {}", path);

        // Verificar autenticación
        if (!SessionUtil.isAuthenticated(request)) {
            SessionUtil.setReturnUrl(request, path);
            response.sendRedirect(request.getContextPath() + "/login?error=sesion_requerida");
            return;
        }

        try {
            switch (path) {
                case "/checkout":
                    mostrarCheckout(request, response);
                    break;
                case "/pedido/confirmacion":
                    mostrarConfirmacion(request, response);
                    break;
                case "/pedidos":
                    listarPedidos(request, response);
                    break;
                case "/pedido/detalle":
                    verDetallePedido(request, response);
                    break;
                default:
                    response.sendError(HttpServletResponse.SC_NOT_FOUND);
            }
        } catch (Exception e) {
            logger.error("Error en GET {}: {}", path, e.getMessage(), e);
            request.setAttribute("error", "Error al procesar la solicitud");
            request.getRequestDispatcher("/views/error.jsp").forward(request, response);
        }
    }

    // ==================== MÉTODO POST ====================

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String path = request.getServletPath();
        logger.debug("POST request: {}", path);

        // Verificar autenticación
        if (!SessionUtil.isAuthenticated(request)) {
            response.sendRedirect(request.getContextPath() + "/login?error=sesion_requerida");
            return;
        }

        try {
            switch (path) {
                case "/pedido/crear":
                    crearPedido(request, response);
                    break;
                case "/pedido/cancelar":
                    cancelarPedido(request, response);
                    break;
                default:
                    response.sendError(HttpServletResponse.SC_NOT_FOUND);
            }
        } catch (Exception e) {
            logger.error("Error en POST {}: {}", path, e.getMessage(), e);
            request.setAttribute("error", "Error al procesar la solicitud");
            request.getRequestDispatcher("/views/error.jsp").forward(request, response);
        }
    }

    // ==================== MÉTODOS GET ====================

    /**
     * Muestra la página de checkout
     */
    private void mostrarCheckout(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Integer idUsuario = SessionUtil.getIdUsuario(request);

        try {
            // Obtener carrito completo
            CarritoCompleto carrito = carritoService.obtenerCarritoCompleto(idUsuario);

            // Verificar que el carrito no esté vacío
            if (carrito.estaVacio()) {
                SessionUtil.setFlashMessage(request, "warning", "Tu carrito está vacío");
                response.sendRedirect(request.getContextPath() + "/carrito");
                return;
            }

            // Verificar si hay problemas con los productos
            if (carrito.tieneProblemas()) {
                request.setAttribute("advertencias", carrito.getProblemas());
            }

            // Validar el carrito antes del checkout
            List<String> erroresValidacion = carritoService.validarCarrito(idUsuario);
            if (!erroresValidacion.isEmpty() && !erroresValidacion.get(0).equals("El carrito está vacío")) {
                request.setAttribute("erroresValidacion", erroresValidacion);
            }

            // Obtener datos del usuario para prellenar
            Usuario usuario = SessionUtil.getUsuario(request).orElse(null);

            // Enviar datos a la vista
            request.setAttribute("carrito", carrito);
            request.setAttribute("items", carrito.getItems());
            request.setAttribute("subtotal", carrito.getSubtotal());
            request.setAttribute("totalDescuentos", carrito.getTotalDescuentos());
            request.setAttribute("total", carrito.getTotal());
            request.setAttribute("cantidadItems", carrito.getCantidadTotal());
            request.setAttribute("usuario", usuario);

            logger.debug("Mostrando checkout para usuario {}: {} items, total ${}",
                    idUsuario, carrito.getCantidadTotal(), carrito.getTotal());

            request.getRequestDispatcher("/views/checkout.jsp").forward(request, response);

        } catch (ServiceException e) {
            logger.error("Error al mostrar checkout: {}", e.getMessage());
            SessionUtil.setFlashMessage(request, "error", "Error al cargar el checkout");
            response.sendRedirect(request.getContextPath() + "/carrito");
        }
    }

    /**
     * Muestra la página de confirmación de pedido
     */
    private void mostrarConfirmacion(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idPedidoParam = request.getParameter("id");

        if (idPedidoParam == null || idPedidoParam.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/pedidos");
            return;
        }

        try {
            int idPedido = Integer.parseInt(idPedidoParam);
            Integer idUsuario = SessionUtil.getIdUsuario(request);

            // Obtener pedido completo
            PedidoCompleto pedidoCompleto = pedidoService.obtenerPedidoCompleto(idPedido);

            // Verificar que el pedido pertenece al usuario
            if (!pedidoCompleto.getPedido().getIdUsuario().equals(idUsuario)) {
                logger.warn("Usuario {} intentó ver pedido {} de otro usuario",
                        idUsuario, idPedido);
                response.sendRedirect(request.getContextPath() + "/pedidos");
                return;
            }

            // Enviar datos a la vista
            request.setAttribute("pedido", pedidoCompleto.getPedido());
            request.setAttribute("detalles", pedidoCompleto.getDetalles());
            request.setAttribute("cantidadItems", pedidoCompleto.getCantidadItems());
            request.setAttribute("esConfirmacion", true);

            logger.debug("Mostrando confirmación del pedido {}", idPedido);

            request.getRequestDispatcher("/views/pedido-confirmacion.jsp").forward(request, response);

        } catch (NumberFormatException e) {
            logger.warn("ID de pedido inválido: {}", idPedidoParam);
            response.sendRedirect(request.getContextPath() + "/pedidos");
        } catch (ServiceException e) {
            logger.error("Error al mostrar confirmación: {}", e.getMessage());
            request.setAttribute("error", "Pedido no encontrado");
            request.getRequestDispatcher("/views/error.jsp").forward(request, response);
        }
    }

    /**
     * Lista el historial de pedidos del usuario
     */
    private void listarPedidos(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Integer idUsuario = SessionUtil.getIdUsuario(request);

        try {
            // Obtener pedidos del usuario
            List<Pedido> pedidos = pedidoService.obtenerHistorialUsuario(idUsuario);

            // Enviar datos a la vista
            request.setAttribute("pedidos", pedidos);
            request.setAttribute("totalPedidos", pedidos.size());

            logger.debug("Listando {} pedidos del usuario {}", pedidos.size(), idUsuario);

            request.getRequestDispatcher("/views/mis-pedidos.jsp").forward(request, response);

        } catch (ServiceException e) {
            logger.error("Error al listar pedidos: {}", e.getMessage());
            request.setAttribute("error", "Error al cargar los pedidos");
            request.getRequestDispatcher("/views/mis-pedidos.jsp").forward(request, response);
        }
    }

    /**
     * Muestra el detalle de un pedido específico
     */
    private void verDetallePedido(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idPedidoParam = request.getParameter("id");

        if (idPedidoParam == null || idPedidoParam.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/pedidos");
            return;
        }

        try {
            int idPedido = Integer.parseInt(idPedidoParam);
            Integer idUsuario = SessionUtil.getIdUsuario(request);

            // Obtener pedido completo
            PedidoCompleto pedidoCompleto = pedidoService.obtenerPedidoCompleto(idPedido);

            // Verificar que el pedido pertenece al usuario (o es admin)
            if (!pedidoCompleto.getPedido().getIdUsuario().equals(idUsuario) 
                    && !SessionUtil.isAdmin(request)) {
                logger.warn("Usuario {} intentó ver pedido {} de otro usuario",
                        idUsuario, idPedido);
                response.sendRedirect(request.getContextPath() + "/pedidos");
                return;
            }

            // Enviar datos a la vista
            request.setAttribute("pedido", pedidoCompleto.getPedido());
            request.setAttribute("detalles", pedidoCompleto.getDetalles());
            request.setAttribute("cantidadItems", pedidoCompleto.getCantidadItems());
            request.setAttribute("cantidadTotal", pedidoCompleto.getCantidadTotal());

            logger.debug("Mostrando detalle del pedido {}", idPedido);

            request.getRequestDispatcher("/views/pedido-detalle.jsp").forward(request, response);

        } catch (NumberFormatException e) {
            logger.warn("ID de pedido inválido: {}", idPedidoParam);
            response.sendRedirect(request.getContextPath() + "/pedidos");
        } catch (ServiceException e) {
            logger.error("Error al ver detalle del pedido: {}", e.getMessage());
            request.setAttribute("error", "Pedido no encontrado");
            request.getRequestDispatcher("/views/error.jsp").forward(request, response);
        }
    }

    // ==================== MÉTODOS POST ====================

    /**
     * Crea un nuevo pedido desde el carrito
     */
    private void crearPedido(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Integer idUsuario = SessionUtil.getIdUsuario(request);

        // Obtener datos del formulario
        String direccionEnvio = request.getParameter("direccionEnvio");
        String metodoPago = request.getParameter("metodoPago");
        String notas = request.getParameter("notas");

        // Validaciones básicas
        if (direccionEnvio == null || direccionEnvio.trim().isEmpty()) {
            request.setAttribute("error", "La dirección de envío es requerida");
            mostrarCheckout(request, response);
            return;
        }

        if (metodoPago == null || metodoPago.trim().isEmpty()) {
            request.setAttribute("error", "El método de pago es requerido");
            mostrarCheckout(request, response);
            return;
        }

        // Validar método de pago permitido
        if (!esMetodoPagoValido(metodoPago)) {
            request.setAttribute("error", "Método de pago no válido");
            mostrarCheckout(request, response);
            return;
        }

        try {
            // Validar carrito antes de crear pedido
            List<String> errores = carritoService.validarCarrito(idUsuario);
            if (!errores.isEmpty()) {
                request.setAttribute("erroresValidacion", errores);
                mostrarCheckout(request, response);
                return;
            }

            // Crear el pedido
            int idPedido = pedidoService.crearPedidoDesdeCarrito(
                    idUsuario,
                    direccionEnvio.trim(),
                    metodoPago
            );

            // Limpiar contador de carrito en sesión
            SessionUtil.setItemsCarrito(request, 0);

            logger.info("Pedido {} creado exitosamente para usuario {}", idPedido, idUsuario);

            // Redirigir a confirmación
            response.sendRedirect(request.getContextPath() + "/pedido/confirmacion?id=" + idPedido);

        } catch (ServiceException e) {
            logger.error("Error al crear pedido: {}", e.getMessage());
            request.setAttribute("error", e.getMessage());
            mostrarCheckout(request, response);
        }
    }

    /**
     * Cancela un pedido existente
     */
    private void cancelarPedido(HttpServletRequest request, HttpServletResponse response)
            throws IOException, ServletException {

        Integer idUsuario = SessionUtil.getIdUsuario(request);
        String idPedidoParam = request.getParameter("idPedido");
        String motivo = request.getParameter("motivo");

        if (idPedidoParam == null || idPedidoParam.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/pedidos");
            return;
        }

        try {
            int idPedido = Integer.parseInt(idPedidoParam);

            // Verificar que el pedido pertenece al usuario
            PedidoCompleto pedidoCompleto = pedidoService.obtenerPedidoCompleto(idPedido);
            
            if (!pedidoCompleto.getPedido().getIdUsuario().equals(idUsuario) 
                    && !SessionUtil.isAdmin(request)) {
                logger.warn("Usuario {} intentó cancelar pedido {} de otro usuario",
                        idUsuario, idPedido);
                SessionUtil.setFlashMessage(request, "error", "No tienes permiso para cancelar este pedido");
                response.sendRedirect(request.getContextPath() + "/pedidos");
                return;
            }

            // Cancelar el pedido
            pedidoService.cancelarPedido(idPedido, motivo, idUsuario);

            logger.info("Pedido {} cancelado por usuario {}", idPedido, idUsuario);

            SessionUtil.setFlashMessage(request, "success", "Pedido cancelado correctamente");
            response.sendRedirect(request.getContextPath() + "/pedido/detalle?id=" + idPedido);

        } catch (NumberFormatException e) {
            logger.warn("ID de pedido inválido: {}", idPedidoParam);
            response.sendRedirect(request.getContextPath() + "/pedidos");
        } catch (ServiceException e) {
            logger.error("Error al cancelar pedido: {}", e.getMessage());
            SessionUtil.setFlashMessage(request, "error", e.getMessage());
            response.sendRedirect(request.getContextPath() + "/pedidos");
        }
    }

    // ==================== MÉTODOS AUXILIARES ====================

    /**
     * Valida si el método de pago es válido
     */
    private boolean esMetodoPagoValido(String metodoPago) {
        if (metodoPago == null) {
            return false;
        }

        switch (metodoPago.toUpperCase()) {
            case "EFECTIVO":
            case "TARJETA_CREDITO":
            case "TARJETA_DEBITO":
            case "TRANSFERENCIA":
            case "PAYPAL":
                return true;
            default:
                return false;
        }
    }
}
