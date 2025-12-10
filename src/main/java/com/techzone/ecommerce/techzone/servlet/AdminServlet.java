package com.techzone.ecommerce.techzone.servlet;

import com.techzone.ecommerce.techzone.service.ServiceException;
import com.techzone.ecommerce.techzone.model.Categoria;
import com.techzone.ecommerce.techzone.model.Pedido;
import com.techzone.ecommerce.techzone.model.Producto;
import com.techzone.ecommerce.techzone.model.Usuario;
import com.techzone.ecommerce.techzone.service.CategoriaService;
import com.techzone.ecommerce.techzone.service.PedidoService;
import com.techzone.ecommerce.techzone.service.ProductoService;
import com.techzone.ecommerce.techzone.service.UsuarioService;
import com.techzone.ecommerce.techzone.util.SessionUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.File;
import java.io.IOException;
import java.math.BigDecimal;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.List;
import java.util.UUID;

/**
 * Servlet para el panel de administración completo
 * Requiere rol ADMIN (protegido por AuthenticationFilter)
 *
 * @author TechZone Team
 */
@WebServlet(name = "AdminServlet", urlPatterns = {
        "/admin/dashboard",
        "/admin/productos",
        "/admin/productos/nuevo",
        "/admin/productos/editar",
        "/admin/productos/eliminar",
        "/admin/productos/guardar",
        "/admin/pedidos",
        "/admin/usuarios",
        "/admin/estadisticas"
})
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024 * 2,  // 2MB
        maxFileSize = 1024 * 1024 * 10,       // 10MB
        maxRequestSize = 1024 * 1024 * 50     // 50MB
)
public class AdminServlet extends HttpServlet {

    private static final Logger logger = LoggerFactory.getLogger(AdminServlet.class);
    private static final String UPLOAD_DIR = "uploads/productos";

    private ProductoService productoService;
    private PedidoService pedidoService;
    private UsuarioService usuarioService;
    private CategoriaService categoriaService;

    @Override
    public void init() throws ServletException {
        super.init();
        this.productoService = new ProductoService();
        this.pedidoService = new PedidoService();
        this.usuarioService = new UsuarioService();
        this.categoriaService = new CategoriaService();
        logger.info("AdminServlet inicializado");
    }

    // ==================== MÉTODO GET ====================

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String path = request.getServletPath();
        logger.debug("GET request: {}", path);

        // Verificar que es admin
        if (!SessionUtil.isAdmin(request)) {
            logger.warn("Acceso denegado a admin panel - Usuario no es admin");
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Acceso denegado");
            return;
        }

        try {
            switch (path) {
                case "/admin/dashboard":
                    mostrarDashboard(request, response);
                    break;
                case "/admin/productos":
                    listarProductosAdmin(request, response);
                    break;
                case "/admin/productos/nuevo":
                    mostrarFormularioNuevoProducto(request, response);
                    break;
                case "/admin/productos/editar":
                    mostrarFormularioEditarProducto(request, response);
                    break;
                case "/admin/productos/eliminar":
                    eliminarProducto(request, response);
                    break;
                case "/admin/pedidos":
                    listarPedidosAdmin(request, response);
                    break;
                case "/admin/usuarios":
                    listarUsuariosAdmin(request, response);
                    break;
                case "/admin/estadisticas":
                    mostrarEstadisticas(request, response);
                    break;
                default:
                    response.sendError(HttpServletResponse.SC_NOT_FOUND);
            }
        } catch (Exception e) {
            logger.error("Error en GET {}: {}", path, e.getMessage(), e);
            request.setAttribute("error", "Error al cargar la información");
            request.getRequestDispatcher("/views/admin/error.jsp").forward(request, response);
        }
    }

    // ==================== MÉTODO POST ====================

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String path = request.getServletPath();
        logger.debug("POST request: {}", path);

        // Verificar que es admin
        if (!SessionUtil.isAdmin(request)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Acceso denegado");
            return;
        }

        try {
            if ("/admin/productos/guardar".equals(path)) {
                guardarProducto(request, response);
            } else {
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
            }
        } catch (Exception e) {
            logger.error("Error en POST {}: {}", path, e.getMessage(), e);
            request.setAttribute("error", "Error al procesar la solicitud");
            response.sendRedirect(request.getContextPath() + "/admin/productos");
        }
    }

    // ==================== MÉTODOS PRIVADOS - DASHBOARD ====================

    /**
     * Muestra el dashboard principal del admin con resumen de datos
     */
    private void mostrarDashboard(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            // Obtener estadísticas generales
            DashboardData data = new DashboardData();

            // Contar productos
            data.totalProductos = productoService.contarProductos();
            data.productosActivos = productoService.contarProductosActivos();
            data.productosBajoStock = productoService.contarProductosBajoStock(10);

            // Contar pedidos
            data.totalPedidos = pedidoService.obtenerTodosPedidos().size();
            data.pedidosPendientes = pedidoService.contarPedidosPorEstado("PENDIENTE");
            data.pedidosHoy = 0; // TODO: Implementar

            // Contar usuarios
            data.totalUsuarios = usuarioService.obtenerTodosUsuarios().size();
            data.usuariosNuevosHoy = 0; // TODO: Implementar

            // Obtener últimos pedidos
            List<Pedido> ultimosPedidos = pedidoService.obtenerTodosPedidos();
            if (ultimosPedidos.size() > 5) {
                ultimosPedidos = ultimosPedidos.subList(0, 5);
            }

            // Obtener productos bajo stock
            List<Producto> productosBajoStock = productoService.obtenerProductosBajoStock(10, 5);

            // Enviar a la vista
            request.setAttribute("data", data);
            request.setAttribute("ultimosPedidos", ultimosPedidos);
            request.setAttribute("productosBajoStock", productosBajoStock);

            logger.debug("Dashboard cargado - {} productos, {} pedidos, {} usuarios",
                    data.totalProductos, data.totalPedidos, data.totalUsuarios);

            request.getRequestDispatcher("/views/admin/dashboard.jsp").forward(request, response);

        } catch (ServiceException | ProductoService.ServiceException e) {
            logger.error("Error al cargar dashboard: {}", e.getMessage());
            request.setAttribute("error", "Error al cargar el dashboard");
            request.getRequestDispatcher("/views/admin/dashboard.jsp").forward(request, response);
        }
    }

    // ==================== MÉTODOS PRIVADOS - PRODUCTOS ====================

    /**
     * Lista todos los productos para administración
     */
    private void listarProductosAdmin(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            String filtro = request.getParameter("filtro");
            String busqueda = request.getParameter("busqueda");
            String categoriaParam = request.getParameter("categoria");
            String estadoParam = request.getParameter("estado");
            String stockParam = request.getParameter("stock");

            // Crear filtros
            ProductoService.FiltroProductos filtros = new ProductoService.FiltroProductos();
            filtros.setProductosPorPagina(50);

            if (busqueda != null && !busqueda.trim().isEmpty()) {
                filtros.setTerminoBusqueda(busqueda.trim());
            }

            if (categoriaParam != null && !categoriaParam.trim().isEmpty()) {
                try {
                    filtros.setIdCategoria(Integer.parseInt(categoriaParam));
                } catch (NumberFormatException e) {
                    logger.warn("ID de categoría inválido: {}", categoriaParam);
                }
            }

            if ("activo".equals(estadoParam)) {
                filtros.setSoloDisponibles(true);
            } else if ("inactivo".equals(estadoParam)) {
                filtros.setSoloDisponibles(false);
            }

            // Buscar productos
            ProductoService.ResultadoBusqueda resultado = productoService.buscarProductos(filtros);

            // Obtener categorías para filtros
            List<Categoria> categorias = categoriaService.obtenerCategoriasActivas();

            // Estadísticas
            int totalProductos = productoService.contarProductos();
            int productosActivos = productoService.contarProductosActivos();
            int productosBajoStock = productoService.contarProductosBajoStock(10);
            int productosSinStock = productoService.contarProductosSinStock();

            // Enviar a la vista
            request.setAttribute("productos", resultado.getProductos());
            request.setAttribute("totalProductos", totalProductos);
            request.setAttribute("productosActivos", productosActivos);
            request.setAttribute("productosBajoStock", productosBajoStock);
            request.setAttribute("productosSinStock", productosSinStock);
            request.setAttribute("categorias", categorias);
            request.setAttribute("filtroActual", filtro);

            logger.debug("Admin listando {} productos", resultado.getTotalProductos());

            request.getRequestDispatcher("/views/admin/productos.jsp").forward(request, response);

        } catch (ProductoService.ServiceException | CategoriaService.ServiceException e) {
            logger.error("Error al listar productos admin: {}", e.getMessage());
            request.setAttribute("error", "Error al cargar los productos");
            request.getRequestDispatcher("/views/admin/productos.jsp").forward(request, response);
        }
    }

    /**
     * Muestra el formulario para crear un nuevo producto
     */
    private void mostrarFormularioNuevoProducto(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            List<Categoria> categorias = categoriaService.obtenerCategoriasActivas();
            request.setAttribute("categorias", categorias);
            request.setAttribute("accion", "nuevo");

            logger.debug("Mostrando formulario de nuevo producto");

            request.getRequestDispatcher("/views/admin/producto-form.jsp").forward(request, response);

        } catch (CategoriaService.ServiceException e) {
            logger.error("Error al cargar categorías: {}", e.getMessage());
            SessionUtil.setFlashMessage(request, "error", "Error al cargar el formulario");
            response.sendRedirect(request.getContextPath() + "/admin/productos");
        }
    }

    /**
     * Muestra el formulario para editar un producto existente
     */
    private void mostrarFormularioEditarProducto(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idParam = request.getParameter("id");

        if (idParam == null || idParam.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/productos");
            return;
        }

        try {
            int idProducto = Integer.parseInt(idParam);

            Producto producto = productoService.obtenerProductoPorId(idProducto);

            if (producto == null) {
                SessionUtil.setFlashMessage(request, "error", "Producto no encontrado");
                response.sendRedirect(request.getContextPath() + "/admin/productos");
                return;
            }

            List<Categoria> categorias = categoriaService.obtenerCategoriasActivas();

            request.setAttribute("producto", producto);
            request.setAttribute("categorias", categorias);
            request.setAttribute("accion", "editar");

            logger.debug("Mostrando formulario de edición para producto ID: {}", idProducto);

            request.getRequestDispatcher("/views/admin/producto-form.jsp").forward(request, response);

        } catch (NumberFormatException e) {
            logger.warn("ID de producto inválido: {}", idParam);
            response.sendRedirect(request.getContextPath() + "/admin/productos");
        } catch (ProductoService.ServiceException | CategoriaService.ServiceException e) {
            logger.error("Error al cargar producto: {}", e.getMessage());
            SessionUtil.setFlashMessage(request, "error", "Error al cargar el producto");
            response.sendRedirect(request.getContextPath() + "/admin/productos");
        }
    }

    /**
     * Guarda un producto (crear o actualizar)
     */
    private void guardarProducto(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String accion = request.getParameter("accion");
        boolean esNuevo = "nuevo".equals(accion);

        try {
            String idParam = request.getParameter("idProducto");
            String nombre = request.getParameter("nombre");
            String descripcion = request.getParameter("descripcion");
            String sku = request.getParameter("sku");
            String marca = request.getParameter("marca");
            String precioStr = request.getParameter("precio");
            String stockStr = request.getParameter("stock");
            String idCategoriaStr = request.getParameter("idCategoria");
            String activoStr = request.getParameter("activo");
            String descuentoStr = request.getParameter("descuento");

            // Validaciones
            if (nombre == null || nombre.trim().isEmpty()) {
                throw new IllegalArgumentException("El nombre es requerido");
            }
            if (sku == null || sku.trim().isEmpty()) {
                throw new IllegalArgumentException("El SKU es requerido");
            }
            if (precioStr == null || precioStr.trim().isEmpty()) {
                throw new IllegalArgumentException("El precio es requerido");
            }
            if (stockStr == null || stockStr.trim().isEmpty()) {
                throw new IllegalArgumentException("El stock es requerido");
            }
            if (idCategoriaStr == null || idCategoriaStr.trim().isEmpty()) {
                throw new IllegalArgumentException("La categoría es requerida");
            }

            // Parsear valores
            BigDecimal precio = new BigDecimal(precioStr);
            int stock = Integer.parseInt(stockStr);
            int idCategoria = Integer.parseInt(idCategoriaStr);
            boolean activo = "true".equals(activoStr);

            BigDecimal descuento = null;
            if (descuentoStr != null && !descuentoStr.trim().isEmpty()) {
                descuento = new BigDecimal(descuentoStr);
            }

            // Crear o actualizar producto
            Producto producto;

            if (esNuevo) {
                producto = new Producto();
            } else {
                int idProducto = Integer.parseInt(idParam);
                producto = productoService.obtenerProductoPorId(idProducto);
                if (producto == null) {
                    throw new IllegalArgumentException("Producto no encontrado");
                }
            }

            // Setear valores
            producto.setNombre(nombre.trim());
            producto.setDescripcion(descripcion != null ? descripcion.trim() : null);
            producto.setSku(sku.trim());
            producto.setMarca(marca != null ? marca.trim() : null);
            producto.setPrecio(precio);
            producto.setStock(stock);
            producto.setIdCategoria(idCategoria);
            producto.setActivo(activo);
            producto.setDescuento(descuento);

            // Procesar imagen
            Part imagePart = request.getPart("imagen");
            if (imagePart != null && imagePart.getSize() > 0) {
                String fileName = uploadImage(imagePart);
                producto.setImagenPrincipal(fileName);
            }

            // Guardar
            if (esNuevo) {
                int idNuevo = productoService.crearProducto(producto);
                logger.info("Producto creado con ID: {}", idNuevo);
                SessionUtil.setFlashMessage(request, "success", "Producto creado exitosamente");
            } else {
                productoService.actualizarProducto(producto);
                logger.info("Producto actualizado ID: {}", producto.getIdProducto());
                SessionUtil.setFlashMessage(request, "success", "Producto actualizado exitosamente");
            }

            response.sendRedirect(request.getContextPath() + "/admin/productos");

        } catch (IllegalArgumentException e) {
            logger.warn("Error de validación: {}", e.getMessage());
            SessionUtil.setFlashMessage(request, "error", e.getMessage());

            if (esNuevo) {
                response.sendRedirect(request.getContextPath() + "/admin/productos/nuevo");
            } else {
                String idParam = request.getParameter("idProducto");
                response.sendRedirect(request.getContextPath() + "/admin/productos/editar?id=" + idParam);
            }

        } catch (ProductoService.ServiceException e) {
            logger.error("Error al guardar producto: {}", e.getMessage());
            SessionUtil.setFlashMessage(request, "error", "Error al guardar el producto");
            response.sendRedirect(request.getContextPath() + "/admin/productos");
        }
    }

    /**
     * Elimina un producto
     */
    private void eliminarProducto(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        String idParam = request.getParameter("id");

        if (idParam == null || idParam.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/productos");
            return;
        }

        try {
            int idProducto = Integer.parseInt(idParam);

            Producto producto = productoService.obtenerProductoPorId(idProducto);

            if (producto == null) {
                SessionUtil.setFlashMessage(request, "error", "Producto no encontrado");
                response.sendRedirect(request.getContextPath() + "/admin/productos");
                return;
            }

            productoService.eliminarProducto(idProducto);

            logger.info("Producto eliminado ID: {}", idProducto);
            SessionUtil.setFlashMessage(request, "success", "Producto eliminado exitosamente");

        } catch (NumberFormatException e) {
            logger.warn("ID de producto inválido: {}", idParam);
            SessionUtil.setFlashMessage(request, "error", "ID de producto inválido");
        } catch (ProductoService.ServiceException e) {
            logger.error("Error al eliminar producto: {}", e.getMessage());
            SessionUtil.setFlashMessage(request, "error", e.getMessage());
        }

        response.sendRedirect(request.getContextPath() + "/admin/productos");
    }

    /**
     * Sube una imagen y retorna el nombre del archivo
     */
    private String uploadImage(Part imagePart) throws IOException {
        String originalFileName = Paths.get(imagePart.getSubmittedFileName()).getFileName().toString();
        String extension = originalFileName.substring(originalFileName.lastIndexOf("."));
        String uniqueFileName = UUID.randomUUID().toString() + extension;

        String uploadPath = getServletContext().getRealPath("") + File.separator + UPLOAD_DIR;
        File uploadDir = new File(uploadPath);

        if (!uploadDir.exists()) {
            uploadDir.mkdirs();
        }

        String filePath = uploadPath + File.separator + uniqueFileName;
        Files.copy(imagePart.getInputStream(), Paths.get(filePath), StandardCopyOption.REPLACE_EXISTING);

        logger.debug("Imagen guardada: {}", uniqueFileName);

        return uniqueFileName;
    }

    // ==================== MÉTODOS PRIVADOS - PEDIDOS ====================

    /**
     * Lista todos los pedidos para administración
     */
    private void listarPedidosAdmin(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            String estadoFiltro = request.getParameter("estado");

            List<Pedido> pedidos;

            if (estadoFiltro != null && !estadoFiltro.isEmpty() && !"todos".equals(estadoFiltro)) {
                pedidos = pedidoService.obtenerPorEstado(estadoFiltro.toUpperCase());
            } else {
                pedidos = pedidoService.obtenerTodosPedidos();
            }

            request.setAttribute("pedidos", pedidos);
            request.setAttribute("totalPedidos", pedidos.size());
            request.setAttribute("estadoFiltro", estadoFiltro);

            logger.debug("Admin listando {} pedidos (estado: {})",
                    pedidos.size(), estadoFiltro);

            request.getRequestDispatcher("/views/admin/pedidos.jsp").forward(request, response);

        } catch (ServiceException e) {
            logger.error("Error al listar pedidos admin: {}", e.getMessage());
            request.setAttribute("error", "Error al cargar los pedidos");
            request.getRequestDispatcher("/views/admin/pedidos.jsp").forward(request, response);
        }
    }

    // ==================== MÉTODOS PRIVADOS - USUARIOS ====================

    /**
     * Lista todos los usuarios para administración
     */
    private void listarUsuariosAdmin(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            String rolFiltro = request.getParameter("rol");

            List<Usuario> usuarios;

            if (rolFiltro != null && !rolFiltro.isEmpty() && !"todos".equals(rolFiltro)) {
                try {
                    Usuario.RolUsuario rol = Usuario.RolUsuario.valueOf(rolFiltro.toUpperCase());
                    usuarios = usuarioService.obtenerUsuariosPorRol(rol);
                } catch (IllegalArgumentException e) {
                    usuarios = usuarioService.obtenerTodosUsuarios();
                }
            } else {
                usuarios = usuarioService.obtenerTodosUsuarios();
            }

            request.setAttribute("usuarios", usuarios);
            request.setAttribute("totalUsuarios", usuarios.size());
            request.setAttribute("rolFiltro", rolFiltro);

            logger.debug("Admin listando {} usuarios (rol: {})",
                    usuarios.size(), rolFiltro);

            request.getRequestDispatcher("/views/admin/usuarios.jsp").forward(request, response);

        } catch (ServiceException e) {
            logger.error("Error al listar usuarios admin: {}", e.getMessage());
            request.setAttribute("error", "Error al cargar los usuarios");
            request.getRequestDispatcher("/views/admin/usuarios.jsp").forward(request, response);
        }
    }

    // ==================== MÉTODOS PRIVADOS - ESTADÍSTICAS ====================

    /**
     * Muestra estadísticas detalladas
     */
    private void mostrarEstadisticas(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            EstadisticasVentas ventas = new EstadisticasVentas();
            ventas.totalVentas = 0.0;
            ventas.ventasHoy = 0.0;
            ventas.ventasMes = 0.0;
            ventas.pedidosCompletados = 0;
            ventas.pedidosCancelados = 0;
            ventas.ticketPromedio = 0.0;

            EstadisticasProductos productos = new EstadisticasProductos();
            productos.totalProductos = productoService.contarProductos();
            productos.productosActivos = productoService.contarProductosActivos();
            productos.productosInactivos = productos.totalProductos - productos.productosActivos;
            productos.productosSinStock = productoService.contarProductosSinStock();
            productos.productosBajoStock = productoService.contarProductosBajoStock(10);
            productos.valorInventario = 0.0;

            request.setAttribute("ventas", ventas);
            request.setAttribute("productos", productos);

            logger.debug("Estadísticas cargadas");

            request.getRequestDispatcher("/views/admin/estadisticas.jsp").forward(request, response);

        } catch (ServiceException | ProductoService.ServiceException e) {
            logger.error("Error al cargar estadísticas: {}", e.getMessage());
            request.setAttribute("error", "Error al cargar las estadísticas");
            request.getRequestDispatcher("/views/admin/estadisticas.jsp").forward(request, response);
        }
    }

    // ==================== CLASES AUXILIARES ====================

    public static class DashboardData {
        public int totalProductos;
        public int productosActivos;
        public int productosBajoStock;
        public int totalPedidos;
        public int pedidosPendientes;
        public int pedidosHoy;
        public int totalUsuarios;
        public int usuariosNuevosHoy;
    }

    public static class EstadisticasVentas {
        public double totalVentas;
        public double ventasHoy;
        public double ventasMes;
        public int pedidosCompletados;
        public int pedidosCancelados;
        public double ticketPromedio;
    }

    public static class EstadisticasProductos {
        public int totalProductos;
        public int productosActivos;
        public int productosInactivos;
        public int productosSinStock;
        public int productosBajoStock;
        public double valorInventario;
    }
}