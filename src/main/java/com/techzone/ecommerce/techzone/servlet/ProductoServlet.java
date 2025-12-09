package com.techzone.ecommerce.techzone.servlet;

import com.techzone.ecommerce.techzone.service.ProductoService.ServiceException;
import com.techzone.ecommerce.techzone.dao.CategoriaDAO;
import com.techzone.ecommerce.techzone.model.Categoria;
import com.techzone.ecommerce.techzone.model.Imagen;
import com.techzone.ecommerce.techzone.model.Producto;
import com.techzone.ecommerce.techzone.service.ImagenService;
import com.techzone.ecommerce.techzone.service.ProductoService;
import com.techzone.ecommerce.techzone.service.ProductoService.FiltroProductos;
import com.techzone.ecommerce.techzone.service.ProductoService.OrdenProducto;
import com.techzone.ecommerce.techzone.service.ProductoService.ProductoCompleto;
import com.techzone.ecommerce.techzone.service.ProductoService.ResultadoBusqueda;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * Servlet para gestión pública de productos: listar, detalle, buscar, filtrar
 *
 * VERSIÓN 2.0 - OPTIMIZADA:
 * - Carga imágenes en batch (1 query para todos los productos)
 * - Categorías vienen del DAO con JOINs
 * - Reduce de 100+ conexiones a solo 3
 *
 * @author TechZone Team
 * @version 2.0 - Optimizado con batch loading
 */
@WebServlet(name = "ProductoServlet", urlPatterns = {
        "/productos",
        "/producto/detalle",
        "/productos/buscar",
        "/productos/categoria",
        "/productos/ofertas"
})
public class ProductoServlet extends HttpServlet {

    private static final Logger logger = LoggerFactory.getLogger(ProductoServlet.class);
    private ProductoService productoService;
    private CategoriaDAO categoriaDAO;

    // Configuración de paginación
    private static final int PRODUCTOS_POR_PAGINA = 12;

    @Override
    public void init() throws ServletException {
        super.init();
        this.productoService = new ProductoService();
        this.categoriaDAO = new CategoriaDAO();
        logger.info("ProductoServlet inicializado");
    }

    // ==================== MÉTODO GET ====================

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String path = request.getServletPath();
        logger.debug("GET request: {}", path);

        try {
            // Cargar categorías para el menú lateral (común a todas las vistas)
            cargarCategorias(request);

            switch (path) {
                case "/productos":
                    listarProductos(request, response);
                    break;
                case "/producto/detalle":
                    verDetalle(request, response);
                    break;
                case "/productos/buscar":
                    buscarProductos(request, response);
                    break;
                case "/productos/categoria":
                    listarPorCategoria(request, response);
                    break;
                case "/productos/ofertas":
                    listarOfertas(request, response);
                    break;
                default:
                    response.sendError(HttpServletResponse.SC_NOT_FOUND);
            }
        } catch (Exception e) {
            logger.error("Error en GET {}: {}", path, e.getMessage(), e);
            request.setAttribute("error", "Error al cargar los productos");
            request.getRequestDispatcher("/views/error.jsp").forward(request, response);
        }
    }

    // ==================== MÉTODOS PRIVADOS - ACCIONES ====================

    /**
     * ✅ OPTIMIZADO: Lista todos los productos con paginación y ordenamiento
     * Carga imágenes en batch para evitar N+1
     */
    private void listarProductos(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            // Obtener parámetros de paginación y ordenamiento
            int pagina = obtenerPagina(request);
            String orden = request.getParameter("orden");

            // Configurar filtros de búsqueda
            FiltroProductos filtros = new FiltroProductos();
            filtros.setPagina(pagina);
            filtros.setProductosPorPagina(PRODUCTOS_POR_PAGINA);
            filtros.setSoloDisponibles(true);

            // Aplicar ordenamiento si está especificado
            if (orden != null && !orden.isEmpty()) {
                filtros.setOrden(parseOrden(orden));
            }

            // Buscar productos (ya incluye categorías gracias a JOINs en DAO)
            ResultadoBusqueda resultado = productoService.buscarProductos(filtros);

            // ✅ OPTIMIZACIÓN: Cargar TODAS las imágenes en UN SOLO query
            cargarImagenesProductos(resultado.getProductos());

            // Enviar datos a la vista
            request.setAttribute("productos", resultado.getProductos());
            request.setAttribute("paginaActual", resultado.getPaginaActual());
            request.setAttribute("totalPaginas", resultado.getTotalPaginas());
            request.setAttribute("totalProductos", resultado.getTotalProductos());
            request.setAttribute("ordenActual", orden);
            request.setAttribute("titulo", "Todos los Productos");

            logger.debug("Listando {} productos, página {}/{}",
                    resultado.getProductos().size(), pagina, resultado.getTotalPaginas());

            request.getRequestDispatcher("/views/productos/catalogo.jsp").forward(request, response);

        } catch (ServiceException e) {
            logger.error("Error al listar productos: {}", e.getMessage());
            request.setAttribute("error", "Error al cargar los productos");
            request.getRequestDispatcher("/views/productos/catalogo.jsp").forward(request, response);
        }
    }

    /**
     * Muestra el detalle completo de un producto específico
     * Incluye imágenes, categoría y productos relacionados
     */
    private void verDetalle(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idParam = request.getParameter("id");

        // Validar que se proporcionó el ID
        if (idParam == null || idParam.isEmpty()) {
            logger.warn("Solicitud de detalle sin ID de producto");
            response.sendRedirect(request.getContextPath() + "/productos");
            return;
        }

        try {
            int idProducto = Integer.parseInt(idParam);

            // Obtener producto completo con imágenes y categoría
            ProductoCompleto productoCompleto = productoService.obtenerProductoCompleto(idProducto);

            // Obtener productos relacionados (misma categoría)
            FiltroProductos filtros = new FiltroProductos();
            filtros.setIdCategoria(productoCompleto.getProducto().getIdCategoria());
            filtros.setProductosPorPagina(4);
            filtros.setSoloDisponibles(true);

            ResultadoBusqueda relacionados = productoService.buscarProductos(filtros);

            // Filtrar el producto actual de los relacionados
            List<Producto> productosRelacionados = relacionados.getProductos().stream()
                    .filter(p -> !p.getIdProducto().equals(idProducto))
                    .limit(4)
                    .toList();

            // Enviar datos a la vista
            request.setAttribute("producto", productoCompleto.getProducto());
            request.setAttribute("imagenes", productoCompleto.getImagenes());
            request.setAttribute("imagenPrincipal", productoCompleto.getImagenPrincipal());
            request.setAttribute("productosRelacionados", productosRelacionados);

            logger.debug("Mostrando detalle del producto ID: {}", idProducto);

            request.getRequestDispatcher("/views/producto-detalle.jsp").forward(request, response);

        } catch (NumberFormatException e) {
            logger.warn("ID de producto inválido: {}", idParam);
            response.sendRedirect(request.getContextPath() + "/productos");
        } catch (ServiceException e) {
            logger.error("Error al obtener detalle del producto: {}", e.getMessage());
            request.setAttribute("error", "Producto no encontrado");
            request.getRequestDispatcher("/views/error.jsp").forward(request, response);
        }
    }

    /**
     * ✅ OPTIMIZADO: Busca productos por término de búsqueda
     */
    private void buscarProductos(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String termino = request.getParameter("q");
        int pagina = obtenerPagina(request);
        String orden = request.getParameter("orden");

        // Si no hay término de búsqueda, redirigir a lista general
        if (termino == null || termino.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/productos");
            return;
        }

        try {
            // Configurar filtros con término de búsqueda
            FiltroProductos filtros = new FiltroProductos();
            filtros.setTerminoBusqueda(termino.trim());
            filtros.setPagina(pagina);
            filtros.setProductosPorPagina(PRODUCTOS_POR_PAGINA);
            filtros.setSoloDisponibles(true);

            if (orden != null && !orden.isEmpty()) {
                filtros.setOrden(parseOrden(orden));
            }

            // Buscar productos
            ResultadoBusqueda resultado = productoService.buscarProductos(filtros);

            // ✅ Cargar imágenes en batch
            cargarImagenesProductos(resultado.getProductos());

            // Enviar datos a la vista
            request.setAttribute("productos", resultado.getProductos());
            request.setAttribute("paginaActual", resultado.getPaginaActual());
            request.setAttribute("totalPaginas", resultado.getTotalPaginas());
            request.setAttribute("totalProductos", resultado.getTotalProductos());
            request.setAttribute("terminoBusqueda", termino);
            request.setAttribute("ordenActual", orden);
            request.setAttribute("titulo", "Resultados para: " + termino);

            logger.debug("Búsqueda '{}': {} resultados", termino, resultado.getTotalProductos());

            request.getRequestDispatcher("/views/productos/catalogo.jsp").forward(request, response);

        } catch (ServiceException e) {
            logger.error("Error en búsqueda '{}': {}", termino, e.getMessage());
            request.setAttribute("error", "Error al realizar la búsqueda");
            request.setAttribute("terminoBusqueda", termino);
            request.getRequestDispatcher("/views/productos/catalogo.jsp").forward(request, response);
        }
    }

    /**
     * ✅ OPTIMIZADO: Lista productos por categoría específica
     */
    private void listarPorCategoria(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idParam = request.getParameter("id");

        // Validar parámetro
        if (idParam == null || idParam.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/productos");
            return;
        }

        try {
            int idCategoria = Integer.parseInt(idParam);
            int pagina = obtenerPagina(request);
            String orden = request.getParameter("orden");

            // Obtener información de la categoría para mostrar en el título
            Categoria categoria = categoriaDAO.buscarPorId(idCategoria)
                    .orElse(null);

            if (categoria == null) {
                logger.warn("Categoría no encontrada: {}", idCategoria);
                response.sendRedirect(request.getContextPath() + "/productos");
                return;
            }

            // Configurar filtros por categoría
            FiltroProductos filtros = new FiltroProductos();
            filtros.setIdCategoria(idCategoria);
            filtros.setPagina(pagina);
            filtros.setProductosPorPagina(PRODUCTOS_POR_PAGINA);
            filtros.setSoloDisponibles(true);

            if (orden != null && !orden.isEmpty()) {
                filtros.setOrden(parseOrden(orden));
            }

            // Buscar productos
            ResultadoBusqueda resultado = productoService.buscarProductos(filtros);

            // ✅ Cargar imágenes en batch
            cargarImagenesProductos(resultado.getProductos());

            // Enviar datos a la vista
            request.setAttribute("productos", resultado.getProductos());
            request.setAttribute("paginaActual", resultado.getPaginaActual());
            request.setAttribute("totalPaginas", resultado.getTotalPaginas());
            request.setAttribute("totalProductos", resultado.getTotalProductos());
            request.setAttribute("categoriaActual", categoria);
            request.setAttribute("ordenActual", orden);
            request.setAttribute("titulo", categoria.getNombre());

            logger.debug("Categoría '{}': {} productos", categoria.getNombre(), resultado.getTotalProductos());

            request.getRequestDispatcher("/views/productos/catalogo.jsp").forward(request, response);

        } catch (NumberFormatException e) {
            logger.warn("ID de categoría inválido: {}", idParam);
            response.sendRedirect(request.getContextPath() + "/productos");
        } catch (SQLException e) {
            logger.error("Error al obtener categoría: {}", e.getMessage());
            response.sendRedirect(request.getContextPath() + "/productos");
        } catch (ServiceException e) {
            logger.error("Error al listar por categoría: {}", e.getMessage());
            request.setAttribute("error", "Error al cargar los productos");
            request.getRequestDispatcher("/views/productos/catalogo.jsp").forward(request, response);
        }
    }

    /**
     * ✅ OPTIMIZADO: Lista productos en oferta (con descuento)
     */
    private void listarOfertas(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            int pagina = obtenerPagina(request);
            String orden = request.getParameter("orden");

            // Configurar filtros para solo productos con descuento
            FiltroProductos filtros = new FiltroProductos();
            filtros.setSoloConDescuento(true);
            filtros.setPagina(pagina);
            filtros.setProductosPorPagina(PRODUCTOS_POR_PAGINA);
            filtros.setSoloDisponibles(true);

            if (orden != null && !orden.isEmpty()) {
                filtros.setOrden(parseOrden(orden));
            }

            // Buscar productos
            ResultadoBusqueda resultado = productoService.buscarProductos(filtros);

            // ✅ Cargar imágenes en batch
            cargarImagenesProductos(resultado.getProductos());

            // Enviar datos a la vista
            request.setAttribute("productos", resultado.getProductos());
            request.setAttribute("paginaActual", resultado.getPaginaActual());
            request.setAttribute("totalPaginas", resultado.getTotalPaginas());
            request.setAttribute("totalProductos", resultado.getTotalProductos());
            request.setAttribute("ordenActual", orden);
            request.setAttribute("titulo", "Ofertas y Descuentos");
            request.setAttribute("esOfertas", true);

            logger.debug("Ofertas: {} productos con descuento", resultado.getTotalProductos());

            request.getRequestDispatcher("/views/productos/catalogo.jsp").forward(request, response);

        } catch (ServiceException e) {
            logger.error("Error al listar ofertas: {}", e.getMessage());
            request.setAttribute("error", "Error al cargar las ofertas");
            request.getRequestDispatcher("/views/productos/catalogo.jsp").forward(request, response);
        }
    }

    // ==================== MÉTODOS AUXILIARES ====================

    /**
     * ✅ MÉTODO CRÍTICO: Carga imágenes para una lista de productos en batch
     *
     * OPTIMIZACIÓN:
     * - Extrae IDs de todos los productos
     * - Hace UNA SOLA consulta para obtener TODAS las imágenes
     * - Asigna imágenes a cada producto en memoria
     * - Establece imagen principal automáticamente
     *
     * ANTES: N queries (1 por cada producto)
     * DESPUÉS: 1 query para todos los productos
     *
     * @param productos Lista de productos a los que cargar imágenes
     */
    private void cargarImagenesProductos(List<Producto> productos) {
        if (productos == null || productos.isEmpty()) {
            return;
        }

        try {
            // 1. Extraer IDs de todos los productos
            List<Integer> idsProductos = productos.stream()
                    .map(Producto::getIdProducto)
                    .toList();

            // 2. ✅ UNA SOLA consulta para TODAS las imágenes
            ImagenService imagenService = new ImagenService();
            Map<Integer, List<Imagen>> mapaImagenes =
                    imagenService.obtenerImagenesPorProductos(idsProductos);

            // 3. Asignar imágenes a cada producto
            for (Producto producto : productos) {
                List<Imagen> imagenesProducto = mapaImagenes.getOrDefault(
                        producto.getIdProducto(),
                        new ArrayList<>()
                );

                // Asignar lista completa de imágenes
                producto.setImagenes(imagenesProducto);

                // Establecer imagen principal (URL como String)
                if (!imagenesProducto.isEmpty()) {
                    // Buscar la imagen marcada como principal
                    String imgPrincipal = imagenesProducto.stream()
                            .filter(img -> img.getEsPrincipal() != null && img.getEsPrincipal())
                            .findFirst()
                            .map(Imagen::getUrlImagen)
                            .orElse(imagenesProducto.get(0).getUrlImagen());

                    producto.setImagenPrincipal(imgPrincipal);
                }
            }

            logger.debug("Cargadas imágenes para {} productos en una sola operación", productos.size());

        } catch (Exception e) {
            logger.error("Error al cargar imágenes de productos: {}", e.getMessage());
            // No lanzar excepción, continuar sin imágenes
            // La aplicación puede funcionar sin imágenes (mostrará placeholder)
        }
    }

    /**
     * Carga las categorías activas con conteo de productos para el menú lateral
     * Usa método optimizado que cuenta productos en un solo query (GROUP BY)
     */
    private void cargarCategorias(HttpServletRequest request) {
        try {
            // ✅ Usa método optimizado con conteo en un solo query
            List<Categoria> categorias = categoriaDAO.obtenerActivasConConteo();
            request.setAttribute("categorias", categorias);

            logger.debug("Cargadas {} categorías con conteo de productos", categorias.size());
        } catch (SQLException e) {
            logger.error("Error al cargar categorías: {}", e.getMessage());
            // No es crítico, continuar sin categorías en el menú
            request.setAttribute("categorias", new ArrayList<>());
        }
    }

    /**
     * Obtiene el número de página del request con validación
     * Retorna 1 si el parámetro es inválido o no está presente
     *
     * @param request HttpServletRequest con parámetros
     * @return Número de página (mínimo 1)
     */
    private int obtenerPagina(HttpServletRequest request) {
        String paginaParam = request.getParameter("pagina");
        if (paginaParam != null && !paginaParam.isEmpty()) {
            try {
                int pagina = Integer.parseInt(paginaParam);
                return Math.max(1, pagina); // No permitir páginas menores a 1
            } catch (NumberFormatException e) {
                // Parámetro inválido, usar página 1
            }
        }
        return 1;
    }

    /**
     * Convierte el parámetro de orden (String) al enum OrdenProducto
     *
     * @param orden String con el tipo de orden (ej: "precio_asc", "nombre_desc")
     * @return OrdenProducto correspondiente o MAS_RECIENTE por defecto
     */
    private OrdenProducto parseOrden(String orden) {
        if (orden == null || orden.isEmpty()) {
            return OrdenProducto.MAS_RECIENTE;
        }

        switch (orden.toLowerCase()) {
            case "precio_asc":
                return OrdenProducto.PRECIO_ASC;
            case "precio_desc":
                return OrdenProducto.PRECIO_DESC;
            case "nombre_asc":
                return OrdenProducto.NOMBRE_ASC;
            case "nombre_desc":
                return OrdenProducto.NOMBRE_DESC;
            case "reciente":
            default:
                return OrdenProducto.MAS_RECIENTE;
        }
    }
}
