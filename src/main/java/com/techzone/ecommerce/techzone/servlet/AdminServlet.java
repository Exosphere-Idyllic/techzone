package com.techzone.ecommerce.techzone.servlet;

import com.google.protobuf.ServiceException;
import com.techzone.ecommerce.techzone.model.Pedido;
import com.techzone.ecommerce.techzone.model.Producto;
import com.techzone.ecommerce.techzone.model.Usuario;
import com.techzone.ecommerce.techzone.service.PedidoService;
import com.techzone.ecommerce.techzone.service.ProductoService;
import com.techzone.ecommerce.techzone.service.UsuarioService;
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
 * Servlet para el panel de administración
 * Requiere rol ADMIN (protegido por AuthenticationFilter)
 *
 * @author TechZone Team
 */
@WebServlet(name = "AdminServlet", urlPatterns = {
        "/admin/dashboard",
        "/admin/productos",
        "/admin/pedidos",
        "/admin/usuarios",
        "/admin/estadisticas"
})
public class AdminServlet extends HttpServlet {

    private static final Logger logger = LoggerFactory.getLogger(AdminServlet.class);
    private ProductoService productoService;
    private PedidoService pedidoService;
    private UsuarioService usuarioService;

    @Override
    public void init() throws ServletException {
        super.init();
        this.productoService = new ProductoService();
        this.pedidoService = new PedidoService();
        this.usuarioService = new UsuarioService();
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

    // ==================== MÉTODOS PRIVADOS ====================

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
            data.totalPedidos = pedidoService.contarPedidosTotales();
            data.pedidosPendientes = pedidoService.contarPedidosPorEstado(Pedido.EstadoPedido.PENDIENTE);
            data.pedidosHoy = pedidoService.contarPedidosHoy();

            // Contar usuarios
            data.totalUsuarios = usuarioService.contarUsuariosActivos();
            data.usuariosNuevosHoy = usuarioService.contarUsuariosNuevosHoy();

            // Obtener últimos pedidos
            List<Pedido> ultimosPedidos = pedidoService.obtenerUltimosPedidos(5);

            // Obtener productos bajo stock
            List<Producto> productosBajoStock = productoService.obtenerProductosBajoStock(10, 5);

            // Enviar a la vista
            request.setAttribute("data", data);
            request.setAttribute("ultimosPedidos", ultimosPedidos);
            request.setAttribute("productosBajoStock", productosBajoStock);

            logger.debug("Dashboard cargado - {} productos, {} pedidos, {} usuarios",
                    data.totalProductos, data.totalPedidos, data.totalUsuarios);

            request.getRequestDispatcher("/views/admin/dashboard.jsp").forward(request, response);

        } catch (ServiceException e) {
            logger.error("Error al cargar dashboard: {}", e.getMessage());
            request.setAttribute("error", "Error al cargar el dashboard");
            request.getRequestDispatcher("/views/admin/dashboard.jsp").forward(request, response);
        }
    }

    /**
     * Lista todos los productos para administración
     */
    private void listarProductosAdmin(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            String filtro = request.getParameter("filtro"); // activos, inactivos, todos

            ProductoService.FiltroProductos filtros = new ProductoService.FiltroProductos();
            filtros.setProductosPorPagina(50); // Más productos en admin

            if ("activos".equals(filtro)) {
                filtros.setSoloDisponibles(true);
            } else if ("inactivos".equals(filtro)) {
                filtros.setSoloDisponibles(false);
            }
            // "todos" no necesita filtro especial

            ProductoService.ResultadoBusqueda resultado = productoService.buscarProductos(filtros);

            request.setAttribute("productos", resultado.getProductos());
            request.setAttribute("totalProductos", resultado.getTotalProductos());
            request.setAttribute("filtroActual", filtro);

            logger.debug("Admin listando {} productos (filtro: {})",
                    resultado.getTotalProductos(), filtro);

            request.getRequestDispatcher("/views/admin/productos.jsp").forward(request, response);

        } catch (ServiceException e) {
            logger.error("Error al listar productos admin: {}", e.getMessage());
            request.setAttribute("error", "Error al cargar los productos");
            request.getRequestDispatcher("/views/admin/productos.jsp").forward(request, response);
        }
    }

    /**
     * Lista todos los pedidos para administración
     */
    private void listarPedidosAdmin(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            String estadoFiltro = request.getParameter("estado");

            List<Pedido> pedidos;

            if (estadoFiltro != null && !estadoFiltro.isEmpty() && !"todos".equals(estadoFiltro)) {
                Pedido.EstadoPedido estado = Pedido.EstadoPedido.valueOf(estadoFiltro.toUpperCase());
                pedidos = pedidoService.obtenerPedidosPorEstado(estado);
            } else {
                pedidos = pedidoService.obtenerTodosPedidos();
            }

            request.setAttribute("pedidos", pedidos);
            request.setAttribute("totalPedidos", pedidos.size());
            request.setAttribute("estadoFiltro", estadoFiltro);

            logger.debug("Admin listando {} pedidos (estado: {})",
                    pedidos.size(), estadoFiltro);

            request.getRequestDispatcher("/views/admin/pedidos.jsp").forward(request, response);

        } catch (ServiceException | IllegalArgumentException e) {
            logger.error("Error al listar pedidos admin: {}", e.getMessage());
            request.setAttribute("error", "Error al cargar los pedidos");
            request.getRequestDispatcher("/views/admin/pedidos.jsp").forward(request, response);
        }
    }

    /**
     * Lista todos los usuarios para administración
     */
    private void listarUsuariosAdmin(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            String rolFiltro = request.getParameter("rol");

            List<Usuario> usuarios;

            if (rolFiltro != null && !rolFiltro.isEmpty() && !"todos".equals(rolFiltro)) {
                Usuario.RolUsuario rol = Usuario.RolUsuario.valueOf(rolFiltro.toUpperCase());
                usuarios = usuarioService.obtenerUsuariosPorRol(rol);
            } else {
                usuarios = usuarioService.obtenerTodosUsuarios();
            }

            request.setAttribute("usuarios", usuarios);
            request.setAttribute("totalUsuarios", usuarios.size());
            request.setAttribute("rolFiltro", rolFiltro);

            logger.debug("Admin listando {} usuarios (rol: {})",
                    usuarios.size(), rolFiltro);

            request.getRequestDispatcher("/views/admin/usuarios.jsp").forward(request, response);

        } catch (ServiceException | IllegalArgumentException e) {
            logger.error("Error al listar usuarios admin: {}", e.getMessage());
            request.setAttribute("error", "Error al cargar los usuarios");
            request.getRequestDispatcher("/views/admin/usuarios.jsp").forward(request, response);
        }
    }

    /**
     * Muestra estadísticas detalladas
     */
    private void mostrarEstadisticas(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            // Obtener estadísticas de ventas
            PedidoService.EstadisticasVentas ventas = pedidoService.obtenerEstadisticasVentas();

            // Obtener estadísticas de productos
            ProductoService.EstadisticasProductos productos = productoService.obtenerEstadisticasProductos();

            request.setAttribute("ventas", ventas);
            request.setAttribute("productos", productos);

            logger.debug("Estadísticas cargadas");

            request.getRequestDispatcher("/views/admin/estadisticas.jsp").forward(request, response);

        } catch (ServiceException e) {
            logger.error("Error al cargar estadísticas: {}", e.getMessage());
            request.setAttribute("error", "Error al cargar las estadísticas");
            request.getRequestDispatcher("/views/admin/estadisticas.jsp").forward(request, response);
        }
    }

    // ==================== CLASES AUXILIARES ====================

    /**
     * Datos para el dashboard
     */
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

    /**
     * Estadísticas de ventas
     */
    public static class EstadisticasVentas {
        public double totalVentas;
        public double ventasHoy;
        public double ventasMes;
        public int pedidosCompletados;
        public int pedidosCancelados;
        public double ticketPromedio;
    }

    /**
     * Estadísticas de productos
     */
    public static class EstadisticasProductos {
        public int totalProductos;
        public int productosActivos;
        public int productosInactivos;
        public int productosSinStock;
        public int productosBajoStock;
        public double valorInventario;
    }
}