package com.techzone.ecommerce.techzone.servlet;

import com.google.protobuf.ServiceException;
import com.techzone.ecommerce.techzone.model.Categoria;
import com.techzone.ecommerce.techzone.model.Producto;
import com.techzone.ecommerce.techzone.service.CategoriaService;
import com.techzone.ecommerce.techzone.service.ProductoService;
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
 * Servlet para la página principal del e-commerce
 * Muestra productos destacados, ofertas y categorías
 *
 * @author TechZone Team
 */
@WebServlet(name = "HomeServlet", urlPatterns = {"", "/"})
public class HomeServlet extends HttpServlet {

    private static final Logger logger = LoggerFactory.getLogger(HomeServlet.class);
    private ProductoService productoService;
    private CategoriaService categoriaService;

    @Override
    public void init() throws ServletException {
        super.init();
        this.productoService = new ProductoService();
        this.categoriaService = new CategoriaService();
        logger.info("HomeServlet inicializado");
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        logger.debug("Cargando página principal");

        try {
            // 1. Obtener todas las categorías para el menú
            List<Categoria> categorias = categoriaService.obtenerCategoriasActivas();
            request.setAttribute("categorias", categorias);

            // 2. Obtener productos más recientes (destacados)
            List<Producto> productosDestacados = productoService.obtenerProductosRecientes(8);
            request.setAttribute("productosDestacados", productosDestacados);

            // 3. Obtener productos con descuento (ofertas)
            List<Producto> productosOferta = productoService.obtenerProductosConDescuento(4);
            request.setAttribute("productosOferta", productosOferta);

            // 4. Obtener categorías más populares (primeras 6)
            List<Categoria> categoriasDestacadas = categorias.size() > 6
                    ? categorias.subList(0, 6)
                    : categorias;
            request.setAttribute("categoriasDestacadas", categoriasDestacadas);

            logger.debug("Página principal cargada - {} productos destacados, {} ofertas, {} categorías",
                    productosDestacados.size(), productosOferta.size(), categorias.size());

            // 5. Forward a la vista
            request.getRequestDispatcher("/index.jsp").forward(request, response);

        } catch (ServiceException e) {
            logger.error("Error al cargar página principal: {}", e.getMessage(), e);
            request.setAttribute("error", "Error al cargar la página principal");
            request.getRequestDispatcher("/views/error.jsp").forward(request, response);
        }
    }
}