package com.techzone.ecommerce.techzone.servlet;

import com.techzone.ecommerce.techzone.dao.CategoriaDAO;
import com.techzone.ecommerce.techzone.dao.ProductoDAO;
import com.techzone.ecommerce.techzone.model.Categoria;
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

/**
 * Servlet para gestión pública de categorías
 *
 * @author TechZone Team
 */
@WebServlet(name = "CategoriaServlet", urlPatterns = {
        "/categorias"
})
public class CategoriaServlet extends HttpServlet {

    private static final Logger logger = LoggerFactory.getLogger(CategoriaServlet.class);
    private CategoriaDAO categoriaDAO;
    private ProductoDAO productoDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        this.categoriaDAO = new CategoriaDAO();
        this.productoDAO = new ProductoDAO();
        logger.info("CategoriaServlet inicializado");
    }

    // ==================== MÉTODO GET ====================

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String path = request.getServletPath();
        logger.debug("GET request: {}", path);

        try {
            switch (path) {
                case "/categorias":
                    listarCategorias(request, response);
                    break;
                default:
                    response.sendError(HttpServletResponse.SC_NOT_FOUND);
            }
        } catch (Exception e) {
            logger.error("Error en GET {}: {}", path, e.getMessage(), e);
            request.setAttribute("error", "Error al cargar las categorías");
            request.getRequestDispatcher("/views/error.jsp").forward(request, response);
        }
    }

    // ==================== MÉTODOS PRIVADOS ====================

    /**
     * Lista todas las categorías activas con conteo de productos
     */
    private void listarCategorias(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            // Obtener categorías activas
            List<Categoria> categorias = categoriaDAO.obtenerActivas();

            // Crear lista con información adicional (conteo de productos)
            List<CategoriaInfo> categoriasInfo = new ArrayList<>();

            for (Categoria categoria : categorias) {
                int cantidadProductos = productoDAO.contarPorCategoria(categoria.getIdCategoria());

                CategoriaInfo info = new CategoriaInfo();
                info.categoria = categoria;
                info.cantidadProductos = cantidadProductos;

                categoriasInfo.add(info);
            }

            // Enviar a la vista
            request.setAttribute("categorias", categoriasInfo);
            request.setAttribute("totalCategorias", categoriasInfo.size());

            logger.debug("Listando {} categorías activas", categoriasInfo.size());

            request.getRequestDispatcher("/views/categorias.jsp").forward(request, response);

        } catch (SQLException e) {
            logger.error("Error al listar categorías: {}", e.getMessage());
            request.setAttribute("error", "Error al cargar las categorías");
            request.getRequestDispatcher("/views/categorias.jsp").forward(request, response);
        }
    }

    // ==================== CLASE AUXILIAR ====================

    /**
     * Clase para agrupar información de categoría con cantidad de productos
     */
    public static class CategoriaInfo {
        public Categoria categoria;
        public int cantidadProductos;

        public Categoria getCategoria() {
            return categoria;
        }

        public int getCantidadProductos() {
            return cantidadProductos;
        }
    }
}