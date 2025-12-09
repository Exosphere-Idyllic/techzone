package com.techzone.ecommerce.techzone.servlet;

import com.techzone.ecommerce.techzone.service.ServiceException;
import com.techzone.ecommerce.techzone.service.CarritoService;
import com.techzone.ecommerce.techzone.service.CarritoService.CarritoCompleto;
import com.techzone.ecommerce.techzone.util.SessionUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;
import java.io.PrintWriter;

/**
 * Servlet para gestión del carrito de compras
 * Requiere autenticación (protegido por AuthenticationFilter)
 * 
 * @author TechZone Team
 */
@WebServlet(name = "CarritoServlet", urlPatterns = {
        "/carrito",
        "/carrito/agregar",
        "/carrito/actualizar",
        "/carrito/eliminar",
        "/carrito/vaciar",
        "/carrito/contador"
})
public class CarritoServlet extends HttpServlet {

    private static final Logger logger = LoggerFactory.getLogger(CarritoServlet.class);
    private CarritoService carritoService;

    @Override
    public void init() throws ServletException {
        super.init();
        this.carritoService = new CarritoService();
        logger.info("CarritoServlet inicializado");
    }

    // ==================== MÉTODO GET ====================

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String path = request.getServletPath();
        logger.debug("GET request: {}", path);

        // Verificar autenticación
        if (!SessionUtil.isAuthenticated(request)) {
            response.sendRedirect(request.getContextPath() + "/login?error=sesion_requerida");
            return;
        }

        try {
            switch (path) {
                case "/carrito":
                    verCarrito(request, response);
                    break;
                case "/carrito/contador":
                    obtenerContador(request, response);
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
            // Si es AJAX, responder con JSON
            if (isAjaxRequest(request)) {
                enviarRespuestaJson(response, false, "Sesión expirada", null);
                return;
            }
            response.sendRedirect(request.getContextPath() + "/login?error=sesion_requerida");
            return;
        }

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
                    response.sendError(HttpServletResponse.SC_NOT_FOUND);
            }
        } catch (Exception e) {
            logger.error("Error en POST {}: {}", path, e.getMessage(), e);
            if (isAjaxRequest(request)) {
                enviarRespuestaJson(response, false, "Error al procesar la solicitud", null);
            } else {
                request.setAttribute("error", "Error al procesar la solicitud");
                response.sendRedirect(request.getContextPath() + "/carrito");
            }
        }
    }

    // ==================== MÉTODOS GET ====================

    /**
     * Muestra el carrito de compras
     */
    private void verCarrito(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Integer idUsuario = SessionUtil.getIdUsuario(request);

        try {
            // Obtener carrito completo
            CarritoCompleto carrito = carritoService.obtenerCarritoCompleto(idUsuario);

            // Actualizar contador en sesión
            SessionUtil.setItemsCarrito(request, carrito.getCantidadTotal());

            // Enviar datos a la vista
            request.setAttribute("carrito", carrito);
            request.setAttribute("items", carrito.getItems());
            request.setAttribute("subtotal", carrito.getSubtotal());
            request.setAttribute("totalDescuentos", carrito.getTotalDescuentos());
            request.setAttribute("total", carrito.getTotal());
            request.setAttribute("cantidadItems", carrito.getCantidadTotal());
            request.setAttribute("problemas", carrito.getProblemas());

            logger.debug("Carrito usuario {}: {} items, total ${}", 
                    idUsuario, carrito.getCantidadTotal(), carrito.getTotal());

            request.getRequestDispatcher("/views/carrito/ver-carrito.jsp").forward(request, response);

        } catch (ServiceException e) {
            logger.error("Error al obtener carrito: {}", e.getMessage());
            request.setAttribute("error", "Error al cargar el carrito");
            request.getRequestDispatcher("/views/carrito/ver-carrito.jsp").forward(request, response);
        }
    }

    /**
     * Obtiene el contador de items del carrito (para AJAX)
     */
    private void obtenerContador(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        Integer idUsuario = SessionUtil.getIdUsuario(request);

        try {
            int cantidad = carritoService.contarCantidadTotal(idUsuario);
            SessionUtil.setItemsCarrito(request, cantidad);
            enviarRespuestaJson(response, true, null, cantidad);

        } catch (ServiceException e) {
            logger.error("Error al obtener contador: {}", e.getMessage());
            enviarRespuestaJson(response, false, e.getMessage(), 0);
        }
    }

    // ==================== MÉTODOS POST ====================

    /**
     * Agrega un producto al carrito
     */
    private void agregarAlCarrito(HttpServletRequest request, HttpServletResponse response)
            throws IOException, ServletException {

        Integer idUsuario = SessionUtil.getIdUsuario(request);
        String idProductoParam = request.getParameter("idProducto");
        String cantidadParam = request.getParameter("cantidad");

        // Validar parámetros
        if (idProductoParam == null || idProductoParam.isEmpty()) {
            if (isAjaxRequest(request)) {
                enviarRespuestaJson(response, false, "Producto no especificado", null);
            } else {
                SessionUtil.setFlashMessage(request, "error", "Producto no especificado");
                response.sendRedirect(request.getContextPath() + "/productos");
            }
            return;
        }

        try {
            int idProducto = Integer.parseInt(idProductoParam);
            int cantidad = 1;

            if (cantidadParam != null && !cantidadParam.isEmpty()) {
                cantidad = Integer.parseInt(cantidadParam);
            }

            // Agregar al carrito
            carritoService.agregarAlCarrito(idUsuario, idProducto, cantidad);

            // Actualizar contador en sesión
            int nuevoContador = carritoService.contarCantidadTotal(idUsuario);
            SessionUtil.setItemsCarrito(request, nuevoContador);

            logger.info("Producto {} agregado al carrito del usuario {}", idProducto, idUsuario);

            if (isAjaxRequest(request)) {
                enviarRespuestaJson(response, true, "Producto agregado al carrito", nuevoContador);
            } else {
                SessionUtil.setFlashMessage(request, "success", "Producto agregado al carrito");
                
                // Redirigir a la página anterior o al carrito
                String referer = request.getHeader("Referer");
                if (referer != null && !referer.isEmpty()) {
                    response.sendRedirect(referer);
                } else {
                    response.sendRedirect(request.getContextPath() + "/carrito");
                }
            }

        } catch (NumberFormatException e) {
            logger.warn("Parámetros inválidos: idProducto={}, cantidad={}", idProductoParam, cantidadParam);
            if (isAjaxRequest(request)) {
                enviarRespuestaJson(response, false, "Parámetros inválidos", null);
            } else {
                SessionUtil.setFlashMessage(request, "error", "Parámetros inválidos");
                response.sendRedirect(request.getContextPath() + "/productos");
            }
        } catch (ServiceException e) {
            logger.error("Error al agregar al carrito: {}", e.getMessage());
            if (isAjaxRequest(request)) {
                enviarRespuestaJson(response, false, e.getMessage(), null);
            } else {
                SessionUtil.setFlashMessage(request, "error", e.getMessage());
                response.sendRedirect(request.getContextPath() + "/carrito");
            }
        }
    }

    /**
     * Actualiza la cantidad de un item en el carrito
     */
    private void actualizarCantidad(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        Integer idUsuario = SessionUtil.getIdUsuario(request);
        String idCarritoParam = request.getParameter("idCarrito");
        String cantidadParam = request.getParameter("cantidad");

        // Validar parámetros
        if (idCarritoParam == null || cantidadParam == null) {
            if (isAjaxRequest(request)) {
                enviarRespuestaJson(response, false, "Parámetros incompletos", null);
            } else {
                response.sendRedirect(request.getContextPath() + "/carrito");
            }
            return;
        }

        try {
            int idCarrito = Integer.parseInt(idCarritoParam);
            int cantidad = Integer.parseInt(cantidadParam);

            // Si cantidad es 0 o menor, eliminar el item
            if (cantidad <= 0) {
                carritoService.eliminarDelCarrito(idCarrito);
                logger.info("Item {} eliminado del carrito (cantidad 0)", idCarrito);
            } else {
                carritoService.actualizarCantidad(idCarrito, cantidad);
                logger.info("Item {} actualizado a cantidad {}", idCarrito, cantidad);
            }

            // Obtener nuevo total y contador
            CarritoCompleto carrito = carritoService.obtenerCarritoCompleto(idUsuario);
            SessionUtil.setItemsCarrito(request, carrito.getCantidadTotal());

            if (isAjaxRequest(request)) {
                // Enviar respuesta con datos actualizados
                String jsonData = String.format(
                        "{\"success\":true,\"cantidadTotal\":%d,\"subtotal\":%.2f,\"total\":%.2f}",
                        carrito.getCantidadTotal(),
                        carrito.getSubtotal(),
                        carrito.getTotal()
                );
                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");
                PrintWriter out = response.getWriter();
                out.print(jsonData);
                out.flush();
            } else {
                response.sendRedirect(request.getContextPath() + "/carrito");
            }

        } catch (NumberFormatException e) {
            logger.warn("Parámetros inválidos: idCarrito={}, cantidad={}", idCarritoParam, cantidadParam);
            if (isAjaxRequest(request)) {
                enviarRespuestaJson(response, false, "Parámetros inválidos", null);
            } else {
                response.sendRedirect(request.getContextPath() + "/carrito");
            }
        } catch (ServiceException e) {
            logger.error("Error al actualizar cantidad: {}", e.getMessage());
            if (isAjaxRequest(request)) {
                enviarRespuestaJson(response, false, e.getMessage(), null);
            } else {
                SessionUtil.setFlashMessage(request, "error", e.getMessage());
                response.sendRedirect(request.getContextPath() + "/carrito");
            }
        }
    }

    /**
     * Elimina un item del carrito
     */
    private void eliminarDelCarrito(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        Integer idUsuario = SessionUtil.getIdUsuario(request);
        String idCarritoParam = request.getParameter("idCarrito");

        // Validar parámetro
        if (idCarritoParam == null || idCarritoParam.isEmpty()) {
            if (isAjaxRequest(request)) {
                enviarRespuestaJson(response, false, "Item no especificado", null);
            } else {
                response.sendRedirect(request.getContextPath() + "/carrito");
            }
            return;
        }

        try {
            int idCarrito = Integer.parseInt(idCarritoParam);

            // Eliminar item
            carritoService.eliminarDelCarrito(idCarrito);

            // Actualizar contador en sesión
            int nuevoContador = carritoService.contarCantidadTotal(idUsuario);
            SessionUtil.setItemsCarrito(request, nuevoContador);

            logger.info("Item {} eliminado del carrito del usuario {}", idCarrito, idUsuario);

            if (isAjaxRequest(request)) {
                enviarRespuestaJson(response, true, "Producto eliminado", nuevoContador);
            } else {
                SessionUtil.setFlashMessage(request, "success", "Producto eliminado del carrito");
                response.sendRedirect(request.getContextPath() + "/carrito");
            }

        } catch (NumberFormatException e) {
            logger.warn("ID de carrito inválido: {}", idCarritoParam);
            if (isAjaxRequest(request)) {
                enviarRespuestaJson(response, false, "ID inválido", null);
            } else {
                response.sendRedirect(request.getContextPath() + "/carrito");
            }
        } catch (ServiceException e) {
            logger.error("Error al eliminar del carrito: {}", e.getMessage());
            if (isAjaxRequest(request)) {
                enviarRespuestaJson(response, false, e.getMessage(), null);
            } else {
                SessionUtil.setFlashMessage(request, "error", e.getMessage());
                response.sendRedirect(request.getContextPath() + "/carrito");
            }
        }
    }

    /**
     * Vacía completamente el carrito
     */
    private void vaciarCarrito(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        Integer idUsuario = SessionUtil.getIdUsuario(request);

        try {
            carritoService.vaciarCarrito(idUsuario);
            SessionUtil.setItemsCarrito(request, 0);

            logger.info("Carrito del usuario {} vaciado", idUsuario);

            if (isAjaxRequest(request)) {
                enviarRespuestaJson(response, true, "Carrito vaciado", 0);
            } else {
                SessionUtil.setFlashMessage(request, "success", "Carrito vaciado correctamente");
                response.sendRedirect(request.getContextPath() + "/carrito");
            }

        } catch (ServiceException e) {
            logger.error("Error al vaciar carrito: {}", e.getMessage());
            if (isAjaxRequest(request)) {
                enviarRespuestaJson(response, false, e.getMessage(), null);
            } else {
                SessionUtil.setFlashMessage(request, "error", e.getMessage());
                response.sendRedirect(request.getContextPath() + "/carrito");
            }
        }
    }

    // ==================== MÉTODOS AUXILIARES ====================

    /**
     * Verifica si es una petición AJAX
     */
    private boolean isAjaxRequest(HttpServletRequest request) {
        String xRequestedWith = request.getHeader("X-Requested-With");
        return "XMLHttpRequest".equals(xRequestedWith);
    }

    /**
     * Envía una respuesta JSON simple
     */
    private void enviarRespuestaJson(HttpServletResponse response, boolean success,
                                      String mensaje, Object data) throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        StringBuilder json = new StringBuilder();
        json.append("{");
        json.append("\"success\":").append(success);

        if (mensaje != null) {
            json.append(",\"mensaje\":\"").append(mensaje.replace("\"", "\\\"")).append("\"");
        }

        if (data != null) {
            json.append(",\"data\":").append(data);
        }

        json.append("}");

        PrintWriter out = response.getWriter();
        out.print(json.toString());
        out.flush();
    }
}
