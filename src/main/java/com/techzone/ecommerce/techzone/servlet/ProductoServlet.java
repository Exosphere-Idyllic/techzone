package com.techzone.ecommerce.techzone.servlet;

import com.google.protobuf.ServiceException;
import com.techzone.ecommerce.techzone.model.Categoria;
import com.techzone.ecommerce.techzone.model.Producto;
import com.techzone.ecommerce.techzone.service.ProductoService;
import com.techzone.ecommerce.techzone.service.ProductoService.FiltroProductos;
import com.techzone.ecommerce.techzone.service.ProductoService.OrdenProducto;
import com.techzone.ecommerce.techzone.service.ProductoService.ProductoCompleto;
import com.techzone.ecommerce.techzone.service.ProductoService.ResultadoBusqueda;
import com.techzone.ecommerce.techzone.dao.CategoriaDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.SQLException;
import java.util.List;

/**
 * Servlet para gestión pública de productos: listar, detalle, buscar, filtrar
 * 
 * @author TechZone Team
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

    // ==================== MÉTODOS PRIVADOS ====================

    /**
     * Lista todos los productos con paginación y ordenamiento
     */
    private void listarProductos(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            // Obtener parámetros de paginación y ordenamiento
            int pagina = obtenerPagina(request);
            String orden = request.getParameter("orden");

            // Configurar filtros
            FiltroProductos filtros = new FiltroProductos();
            filtros.setPagina(pagina);
            filtros.setProductosPorPagina(PRODUCTOS_POR_PAGINA);
            filtros.setSoloDisponibles(true);

            // Aplicar ordenamiento
            if (orden != null && !orden.isEmpty()) {
                filtros.setOrden(parseOrden(orden));
            }

            // Buscar productos
            ResultadoBusqueda resultado = productoService.buscarProductos(filtros);

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
     * Muestra el detalle de un producto específico
     */
    private void verDetalle(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idParam = request.getParameter("id");

        // Validar parámetro
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
     * Busca productos por término de búsqueda
     */
    private void buscarProductos(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String termino = request.getParameter("q");
        int pagina = obtenerPagina(request);
        String orden = request.getParameter("orden");

        // Si no hay término, redirigir a lista general
        if (termino == null || termino.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/productos");
            return;
        }

        try {
            // Configurar filtros
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
     * Lista productos por categoría
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

            // Obtener información de la categoría
            Categoria categoria = categoriaDAO.buscarPorId(idCategoria)
                    .orElse(null);

            if (categoria == null) {
                logger.warn("Categoría no encontrada: {}", idCategoria);
                response.sendRedirect(request.getContextPath() + "/productos");
                return;
            }

            // Configurar filtros
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
     * Lista productos en oferta (con descuento)
     */
    private void listarOfertas(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            int pagina = obtenerPagina(request);
            String orden = request.getParameter("orden");

            // Configurar filtros
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
     * Carga las categorías activas para el menú lateral
     */
    private void cargarCategorias(HttpServletRequest request) {
        try {
            List<Categoria> categorias = categoriaDAO.obtenerActivas();
            request.setAttribute("categorias", categorias);
        } catch (SQLException e) {
            logger.error("Error al cargar categorías: {}", e.getMessage());
            // No es crítico, continuar sin categorías
        }
    }

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
     * Convierte el parámetro de orden al enum correspondiente
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
