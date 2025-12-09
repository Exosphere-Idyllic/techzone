package com.techzone.ecommerce.techzone.servlet;

import com.techzone.ecommerce.techzone.service.ServiceException;
import com.techzone.ecommerce.techzone.model.Categoria;
import com.techzone.ecommerce.techzone.model.Imagen;
import com.techzone.ecommerce.techzone.model.Producto;
import com.techzone.ecommerce.techzone.service.CategoriaService;
import com.techzone.ecommerce.techzone.service.ImagenService;
import com.techzone.ecommerce.techzone.service.ProductoService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet(name = "HomeServlet", urlPatterns = {"", "/"})
public class HomeServlet extends HttpServlet {

    private static final Logger logger = LoggerFactory.getLogger(HomeServlet.class);
    private ProductoService productoService;
    private CategoriaService categoriaService;
    private ImagenService imagenService; // NUEVO

    @Override
    public void init() throws ServletException {
        super.init();
        this.productoService = new ProductoService();
        this.categoriaService = new CategoriaService();
        this.imagenService = new ImagenService(); // ✅ NUEVO
        logger.info("HomeServlet inicializado");
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        logger.debug("Cargando página principal");

        try {
            // 1. Obtener categorías
            List<Categoria> categorias = categoriaService.obtenerCategoriasActivas();
            request.setAttribute("categorias", categorias);

            // 2. Obtener productos destacados
            List<Producto> productosDestacados = productoService.obtenerProductosRecientes(8);
            request.setAttribute("productosDestacados", productosDestacados);

            // 3. Obtener productos en oferta
            List<Producto> productosOferta = productoService.obtenerProductosConDescuento(4);
            request.setAttribute("productosOferta", productosOferta);

// ✅ 4. CARGAR TODAS LAS IMÁGENES CON UN SOLO QUERY
            List<Integer> todosLosIds = new ArrayList<>();
            productosDestacados.forEach(p -> todosLosIds.add(p.getIdProducto()));
            productosOferta.forEach(p -> {
                if (!todosLosIds.contains(p.getIdProducto())) {
                    todosLosIds.add(p.getIdProducto());
                }
            });

            if (!todosLosIds.isEmpty()) {
                Map<Integer, List<Imagen>> imagenesMap = imagenService.obtenerImagenesPorProductos(todosLosIds);
                request.setAttribute("imagenesMap", imagenesMap);
                logger.debug("Cargadas imágenes para {} productos", todosLosIds.size());
            } else {
                request.setAttribute("imagenesMap", new HashMap<>());
            }

            // 5. Categorías destacadas
            List<Categoria> categoriasDestacadas = categorias.size() > 6
                    ? categorias.subList(0, 6)
                    : categorias;
            request.setAttribute("categoriasDestacadas", categoriasDestacadas);

            logger.debug("Página principal cargada - {} productos destacados, {} ofertas, {} categorías",
                    productosDestacados.size(), productosOferta.size(), categorias.size());

            // 6. Forward a la vista
            request.getRequestDispatcher("/index.jsp").forward(request, response);

        } catch (ServiceException | ProductoService.ServiceException e) {
            logger.error("Error al cargar página principal: {}", e.getMessage(), e);
            request.setAttribute("error", "Error al cargar la página principal");
            request.getRequestDispatcher("/views/error.jsp").forward(request, response);
        }
    }
}