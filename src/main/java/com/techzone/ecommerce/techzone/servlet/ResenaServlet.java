package com.techzone.ecommerce.techzone.servlet;

import com.techzone.ecommerce.techzone.service.ServiceException;
import com.techzone.ecommerce.techzone.model.Resena;
import com.techzone.ecommerce.techzone.service.ResenaService;
import com.techzone.ecommerce.techzone.service.ResenaService.EstadisticasResenas;
import com.techzone.ecommerce.techzone.service.ResenaService.ResenasPaginadas;
import com.techzone.ecommerce.techzone.service.ResenaService.VerificacionResena;
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
import java.util.List;

/**
 * Servlet para gestión de reseñas de productos
 * Algunas rutas requieren autenticación
 * 
 * @author TechZone Team
 */
@WebServlet(name = "ResenaServlet", urlPatterns = {
        "/resena/crear",
        "/resena/actualizar",
        "/resena/eliminar",
        "/resenas/producto",
        "/resenas/usuario",
        "/resena/verificar"
})
public class ResenaServlet extends HttpServlet {

    private static final Logger logger = LoggerFactory.getLogger(ResenaServlet.class);
    private ResenaService resenaService;

    // Configuración de paginación
    private static final int RESENAS_POR_PAGINA = 10;

    @Override
    public void init() throws ServletException {
        super.init();
        this.resenaService = new ResenaService();
        logger.info("ResenaServlet inicializado");
    }

    // ==================== MÉTODO GET ====================

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String path = request.getServletPath();
        logger.debug("GET request: {}", path);

        try {
            switch (path) {
                case "/resenas/producto":
                    listarResenasPorProducto(request, response);
                    break;
                case "/resenas/usuario":
                    listarResenasPorUsuario(request, response);
                    break;
                case "/resena/verificar":
                    verificarPuedeResenar(request, response);
                    break;
                default:
                    response.sendError(HttpServletResponse.SC_NOT_FOUND);
            }
        } catch (Exception e) {
            logger.error("Error en GET {}: {}", path, e.getMessage(), e);
            if (isAjaxRequest(request)) {
                enviarRespuestaJson(response, false, "Error al procesar la solicitud", null);
            } else {
                request.setAttribute("error", "Error al procesar la solicitud");
                request.getRequestDispatcher("/views/error.jsp").forward(request, response);
            }
        }
    }

    // ==================== MÉTODO POST ====================

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String path = request.getServletPath();
        logger.debug("POST request: {}", path);

        // Verificar autenticación para rutas que lo requieren
        if (!SessionUtil.isAuthenticated(request)) {
            if (isAjaxRequest(request)) {
                enviarRespuestaJson(response, false, "Debes iniciar sesión para realizar esta acción", null);
                return;
            }
            SessionUtil.setReturnUrl(request, request.getHeader("Referer"));
            response.sendRedirect(request.getContextPath() + "/login?error=sesion_requerida");
            return;
        }

        try {
            switch (path) {
                case "/resena/crear":
                    crearResena(request, response);
                    break;
                case "/resena/actualizar":
                    actualizarResena(request, response);
                    break;
                case "/resena/eliminar":
                    eliminarResena(request, response);
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
                request.getRequestDispatcher("/views/error.jsp").forward(request, response);
            }
        }
    }

    // ==================== MÉTODOS GET ====================

    /**
     * Lista las reseñas de un producto específico
     */
    private void listarResenasPorProducto(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idProductoParam = request.getParameter("idProducto");

        if (idProductoParam == null || idProductoParam.isEmpty()) {
            if (isAjaxRequest(request)) {
                enviarRespuestaJson(response, false, "Producto no especificado", null);
            } else {
                response.sendRedirect(request.getContextPath() + "/productos");
            }
            return;
        }

        try {
            int idProducto = Integer.parseInt(idProductoParam);
            int pagina = obtenerPagina(request);
            String filtroCalificacion = request.getParameter("calificacion");

            // Obtener reseñas paginadas
            ResenasPaginadas resultado;

            if (filtroCalificacion != null && !filtroCalificacion.isEmpty()) {
                // Filtrar por calificación específica
                int calificacion = Integer.parseInt(filtroCalificacion);
                List<Resena> resenasFiltradas = resenaService.obtenerPorCalificacion(idProducto, calificacion);
                
                // Crear resultado manual para filtro
                EstadisticasResenas stats = resenaService.obtenerEstadisticas(idProducto);
                resultado = new ResenasPaginadas(
                        resenasFiltradas,
                        resenasFiltradas.size(),
                        1,
                        1,
                        stats.getPromedioCalificacion(),
                        stats.getDistribucionEstrellas()
                );
            } else {
                resultado = resenaService.obtenerResenasPorProducto(idProducto, pagina, RESENAS_POR_PAGINA);
            }

            // Verificar si el usuario actual puede reseñar
            boolean puedeResenar = false;
            if (SessionUtil.isAuthenticated(request)) {
                Integer idUsuario = SessionUtil.getIdUsuario(request);
                VerificacionResena verificacion = resenaService.puedeResenar(idUsuario, idProducto);
                puedeResenar = verificacion.isPuede();
                request.setAttribute("mensajeVerificacion", verificacion.getMensaje());
            }

            // Si es AJAX, devolver JSON
            if (isAjaxRequest(request)) {
                enviarResenasPaginadasJson(response, resultado, puedeResenar);
                return;
            }

            // Enviar datos a la vista
            request.setAttribute("resenas", resultado.getResenas());
            request.setAttribute("totalResenas", resultado.getTotalResenas());
            request.setAttribute("paginaActual", resultado.getPaginaActual());
            request.setAttribute("totalPaginas", resultado.getTotalPaginas());
            request.setAttribute("promedioCalificacion", resultado.getPromedioCalificacion());
            request.setAttribute("distribucionEstrellas", resultado.getDistribucionEstrellas());
            request.setAttribute("idProducto", idProducto);
            request.setAttribute("puedeResenar", puedeResenar);
            request.setAttribute("filtroCalificacion", filtroCalificacion);

            logger.debug("Listando {} reseñas para producto {}", resultado.getTotalResenas(), idProducto);

            request.getRequestDispatcher("/views/resenas-producto.jsp").forward(request, response);

        } catch (NumberFormatException e) {
            logger.warn("ID de producto inválido: {}", idProductoParam);
            if (isAjaxRequest(request)) {
                enviarRespuestaJson(response, false, "ID de producto inválido", null);
            } else {
                response.sendRedirect(request.getContextPath() + "/productos");
            }
        } catch (ServiceException e) {
            logger.error("Error al listar reseñas: {}", e.getMessage());
            if (isAjaxRequest(request)) {
                enviarRespuestaJson(response, false, e.getMessage(), null);
            } else {
                request.setAttribute("error", "Error al cargar las reseñas");
                request.getRequestDispatcher("/views/error.jsp").forward(request, response);
            }
        }
    }

    /**
     * Lista las reseñas del usuario autenticado
     */
    private void listarResenasPorUsuario(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Verificar autenticación
        if (!SessionUtil.isAuthenticated(request)) {
            response.sendRedirect(request.getContextPath() + "/login?error=sesion_requerida");
            return;
        }

        Integer idUsuario = SessionUtil.getIdUsuario(request);

        try {
            List<Resena> resenas = resenaService.obtenerResenasPorUsuario(idUsuario);

            request.setAttribute("resenas", resenas);
            request.setAttribute("totalResenas", resenas.size());

            logger.debug("Listando {} reseñas del usuario {}", resenas.size(), idUsuario);

            request.getRequestDispatcher("/views/mis-resenas.jsp").forward(request, response);

        } catch (ServiceException e) {
            logger.error("Error al listar reseñas del usuario: {}", e.getMessage());
            request.setAttribute("error", "Error al cargar tus reseñas");
            request.getRequestDispatcher("/views/mis-resenas.jsp").forward(request, response);
        }
    }

    /**
     * Verifica si el usuario puede reseñar un producto (AJAX)
     */
    private void verificarPuedeResenar(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        String idProductoParam = request.getParameter("idProducto");

        if (idProductoParam == null || idProductoParam.isEmpty()) {
            enviarRespuestaJson(response, false, "Producto no especificado", null);
            return;
        }

        // Si no está autenticado
        if (!SessionUtil.isAuthenticated(request)) {
            enviarVerificacionJson(response, false, "Debes iniciar sesión para reseñar");
            return;
        }

        try {
            int idProducto = Integer.parseInt(idProductoParam);
            Integer idUsuario = SessionUtil.getIdUsuario(request);

            VerificacionResena verificacion = resenaService.puedeResenar(idUsuario, idProducto);

            enviarVerificacionJson(response, verificacion.isPuede(), verificacion.getMensaje());

        } catch (NumberFormatException e) {
            enviarRespuestaJson(response, false, "ID de producto inválido", null);
        } catch (ServiceException e) {
            enviarRespuestaJson(response, false, e.getMessage(), null);
        }
    }

    // ==================== MÉTODOS POST ====================

    /**
     * Crea una nueva reseña
     */
    private void crearResena(HttpServletRequest request, HttpServletResponse response)
            throws IOException, ServletException {

        Integer idUsuario = SessionUtil.getIdUsuario(request);

        String idProductoParam = request.getParameter("idProducto");
        String calificacionParam = request.getParameter("calificacion");
        String comentario = request.getParameter("comentario");

        // Validaciones básicas
        if (idProductoParam == null || idProductoParam.isEmpty()) {
            manejarErrorResena(request, response, "Producto no especificado", null);
            return;
        }

        if (calificacionParam == null || calificacionParam.isEmpty()) {
            manejarErrorResena(request, response, "La calificación es requerida", idProductoParam);
            return;
        }

        try {
            int idProducto = Integer.parseInt(idProductoParam);
            int calificacion = Integer.parseInt(calificacionParam);

            // Validar calificación
            if (calificacion < 1 || calificacion > 5) {
                manejarErrorResena(request, response, "La calificación debe ser entre 1 y 5", idProductoParam);
                return;
            }

            // Crear objeto reseña
            Resena resena = new Resena();
            resena.setIdProducto(idProducto);
            resena.setIdUsuario(idUsuario);
            resena.setCalificacion(calificacion);
            resena.setComentario(comentario != null ? comentario.trim() : null);

            // Crear reseña (con verificación de compra)
            int idResena = resenaService.crearResena(resena, true);

            logger.info("Reseña {} creada para producto {} por usuario {}", idResena, idProducto, idUsuario);

            if (isAjaxRequest(request)) {
                // Obtener estadísticas actualizadas
                EstadisticasResenas stats = resenaService.obtenerEstadisticas(idProducto);
                enviarResenaCreadadJson(response, idResena, stats);
            } else {
                SessionUtil.setFlashMessage(request, "success", "¡Gracias por tu reseña!");
                response.sendRedirect(request.getContextPath() + "/producto/detalle?id=" + idProducto);
            }

        } catch (NumberFormatException e) {
            logger.warn("Parámetros inválidos: idProducto={}, calificacion={}", idProductoParam, calificacionParam);
            manejarErrorResena(request, response, "Parámetros inválidos", idProductoParam);
        } catch (ServiceException e) {
            logger.error("Error al crear reseña: {}", e.getMessage());
            manejarErrorResena(request, response, e.getMessage(), idProductoParam);
        }
    }

    /**
     * Actualiza una reseña existente
     */
    private void actualizarResena(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        Integer idUsuario = SessionUtil.getIdUsuario(request);

        String idResenaParam = request.getParameter("idResena");
        String calificacionParam = request.getParameter("calificacion");
        String comentario = request.getParameter("comentario");

        if (idResenaParam == null || calificacionParam == null) {
            if (isAjaxRequest(request)) {
                enviarRespuestaJson(response, false, "Parámetros incompletos", null);
            } else {
                response.sendRedirect(request.getContextPath() + "/resenas/usuario");
            }
            return;
        }

        try {
            int idResena = Integer.parseInt(idResenaParam);
            int calificacion = Integer.parseInt(calificacionParam);

            // Validar calificación
            if (calificacion < 1 || calificacion > 5) {
                if (isAjaxRequest(request)) {
                    enviarRespuestaJson(response, false, "La calificación debe ser entre 1 y 5", null);
                } else {
                    SessionUtil.setFlashMessage(request, "error", "La calificación debe ser entre 1 y 5");
                    response.sendRedirect(request.getContextPath() + "/resenas/usuario");
                }
                return;
            }

            // Crear objeto reseña para actualizar
            Resena resena = new Resena();
            resena.setIdResena(idResena);
            resena.setCalificacion(calificacion);
            resena.setComentario(comentario != null ? comentario.trim() : null);

            // Actualizar
            resenaService.actualizarResena(resena, idUsuario);

            logger.info("Reseña {} actualizada por usuario {}", idResena, idUsuario);

            if (isAjaxRequest(request)) {
                enviarRespuestaJson(response, true, "Reseña actualizada correctamente", null);
            } else {
                SessionUtil.setFlashMessage(request, "success", "Reseña actualizada correctamente");
                response.sendRedirect(request.getContextPath() + "/resenas/usuario");
            }

        } catch (NumberFormatException e) {
            if (isAjaxRequest(request)) {
                enviarRespuestaJson(response, false, "Parámetros inválidos", null);
            } else {
                response.sendRedirect(request.getContextPath() + "/resenas/usuario");
            }
        } catch (ServiceException e) {
            logger.error("Error al actualizar reseña: {}", e.getMessage());
            if (isAjaxRequest(request)) {
                enviarRespuestaJson(response, false, e.getMessage(), null);
            } else {
                SessionUtil.setFlashMessage(request, "error", e.getMessage());
                response.sendRedirect(request.getContextPath() + "/resenas/usuario");
            }
        }
    }

    /**
     * Elimina una reseña
     */
    private void eliminarResena(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        Integer idUsuario = SessionUtil.getIdUsuario(request);
        String idResenaParam = request.getParameter("idResena");

        if (idResenaParam == null || idResenaParam.isEmpty()) {
            if (isAjaxRequest(request)) {
                enviarRespuestaJson(response, false, "Reseña no especificada", null);
            } else {
                response.sendRedirect(request.getContextPath() + "/resenas/usuario");
            }
            return;
        }

        try {
            int idResena = Integer.parseInt(idResenaParam);

            // Eliminar reseña
            resenaService.eliminarResena(idResena, idUsuario);

            logger.info("Reseña {} eliminada por usuario {}", idResena, idUsuario);

            if (isAjaxRequest(request)) {
                enviarRespuestaJson(response, true, "Reseña eliminada correctamente", null);
            } else {
                SessionUtil.setFlashMessage(request, "success", "Reseña eliminada correctamente");
                response.sendRedirect(request.getContextPath() + "/resenas/usuario");
            }

        } catch (NumberFormatException e) {
            if (isAjaxRequest(request)) {
                enviarRespuestaJson(response, false, "ID de reseña inválido", null);
            } else {
                response.sendRedirect(request.getContextPath() + "/resenas/usuario");
            }
        } catch (ServiceException e) {
            logger.error("Error al eliminar reseña: {}", e.getMessage());
            if (isAjaxRequest(request)) {
                enviarRespuestaJson(response, false, e.getMessage(), null);
            } else {
                SessionUtil.setFlashMessage(request, "error", e.getMessage());
                response.sendRedirect(request.getContextPath() + "/resenas/usuario");
            }
        }
    }

    // ==================== MÉTODOS AUXILIARES ====================

    /**
     * Obtiene el número de página del request
     */
    private int obtenerPagina(HttpServletRequest request) {
        String paginaParam = request.getParameter("pagina");
        if (paginaParam != null && !paginaParam.isEmpty()) {
            try {
                int pagina = Integer.parseInt(paginaParam);
                return Math.max(1, pagina);
            } catch (NumberFormatException e) {
                // Ignorar, usar página 1
            }
        }
        return 1;
    }

    /**
     * Verifica si es una petición AJAX
     */
    private boolean isAjaxRequest(HttpServletRequest request) {
        String xRequestedWith = request.getHeader("X-Requested-With");
        return "XMLHttpRequest".equals(xRequestedWith);
    }

    /**
     * Maneja errores en la creación de reseñas
     */
    private void manejarErrorResena(HttpServletRequest request, HttpServletResponse response,
                                     String mensaje, String idProducto) throws IOException, ServletException {
        if (isAjaxRequest(request)) {
            enviarRespuestaJson(response, false, mensaje, null);
        } else {
            SessionUtil.setFlashMessage(request, "error", mensaje);
            if (idProducto != null) {
                response.sendRedirect(request.getContextPath() + "/producto/detalle?id=" + idProducto);
            } else {
                response.sendRedirect(request.getContextPath() + "/productos");
            }
        }
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

    /**
     * Envía respuesta JSON de verificación
     */
    private void enviarVerificacionJson(HttpServletResponse response, boolean puede, String mensaje)
            throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        String json = String.format(
                "{\"success\":true,\"puede\":%b,\"mensaje\":\"%s\"}",
                puede,
                mensaje.replace("\"", "\\\"")
        );

        PrintWriter out = response.getWriter();
        out.print(json);
        out.flush();
    }

    /**
     * Envía respuesta JSON con reseñas paginadas
     */
    private void enviarResenasPaginadasJson(HttpServletResponse response, ResenasPaginadas resultado,
                                             boolean puedeResenar) throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        StringBuilder json = new StringBuilder();
        json.append("{");
        json.append("\"success\":true,");
        json.append("\"totalResenas\":").append(resultado.getTotalResenas()).append(",");
        json.append("\"paginaActual\":").append(resultado.getPaginaActual()).append(",");
        json.append("\"totalPaginas\":").append(resultado.getTotalPaginas()).append(",");
        json.append("\"promedioCalificacion\":").append(String.format("%.1f", resultado.getPromedioCalificacion())).append(",");
        json.append("\"puedeResenar\":").append(puedeResenar).append(",");
        json.append("\"resenas\":[");

        List<Resena> resenas = resultado.getResenas();
        for (int i = 0; i < resenas.size(); i++) {
            Resena r = resenas.get(i);
            if (i > 0) json.append(",");
            json.append("{");
            json.append("\"idResena\":").append(r.getIdResena()).append(",");
            json.append("\"calificacion\":").append(r.getCalificacion()).append(",");
            json.append("\"comentario\":\"").append(r.getComentario() != null ? r.getComentario().replace("\"", "\\\"") : "").append("\",");
            json.append("\"fecha\":\"").append(r.getFecha().toString()).append("\"");
            if (r.getUsuario() != null) {
                json.append(",\"nombreUsuario\":\"").append(r.getUsuario().getNombreCompleto().replace("\"", "\\\"")).append("\"");
            }
            json.append("}");
        }

        json.append("]}");

        PrintWriter out = response.getWriter();
        out.print(json.toString());
        out.flush();
    }

    /**
     * Envía respuesta JSON cuando se crea una reseña
     */
    private void enviarResenaCreadadJson(HttpServletResponse response, int idResena,
                                          EstadisticasResenas stats) throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        String json = String.format(
                "{\"success\":true,\"mensaje\":\"¡Gracias por tu reseña!\",\"idResena\":%d," +
                        "\"nuevoPromedio\":%.1f,\"totalResenas\":%d}",
                idResena,
                stats.getPromedioCalificacion(),
                stats.getTotalResenas()
        );

        PrintWriter out = response.getWriter();
        out.print(json);
        out.flush();
    }
}
