package com.techzone.ecommerce.techzone.service;

import com.techzone.ecommerce.techzone.dao.CategoriaDAO;
import com.techzone.ecommerce.techzone.dao.ImagenProductoDAO;
import com.techzone.ecommerce.techzone.dao.ProductoDAO;
import com.techzone.ecommerce.techzone.model.Categoria;
import com.techzone.ecommerce.techzone.model.ImagenProducto;
import com.techzone.ecommerce.techzone.model.Producto;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.math.BigDecimal;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

/**
 * Servicio de lógica de negocio para gestión de productos
 * Capa intermedia entre servlets y DAOs
 *
 * @author TechZone Team
 * @version 2.0 - Compatible con Producto v2.0 y ProductoServlet optimizado
 */
public class ProductoService {

    private static final Logger logger = LoggerFactory.getLogger(ProductoService.class);
    private final ProductoDAO productoDAO;
    private final CategoriaDAO categoriaDAO;
    private final ImagenProductoDAO imagenDAO;

    public ProductoService() {
        this.productoDAO = new ProductoDAO();
        this.categoriaDAO = new CategoriaDAO();
        this.imagenDAO = new ImagenProductoDAO();
        logger.debug("ProductoService inicializado");
    }

    // ==================== MÉTODOS PARA HOME SERVLET ====================

    /**
     * Obtiene los productos más recientes con límite especificado
     * Usado en la página principal para mostrar productos destacados
     *
     * @param limite Número máximo de productos a retornar
     * @return Lista de productos recientes
     * @throws ServiceException Si hay error en la consulta
     */
    public List<Producto> obtenerProductosRecientes(int limite) throws ServiceException {
        logger.debug("Obteniendo {} productos más recientes", limite);

        try {
            if (limite <= 0) {
                throw new ServiceException("El límite debe ser mayor a 0");
            }

            List<Producto> productos = productoDAO.obtenerMasRecientes(limite);

            logger.debug("Se obtuvieron {} productos recientes", productos.size());
            return productos;

        } catch (SQLException e) {
            logger.error("Error al obtener productos recientes: {}", e.getMessage(), e);
            throw new ServiceException("Error al obtener productos recientes: " + e.getMessage());
        }
    }

    /**
     * Obtiene productos que tienen descuento activo
     * Usado en la página principal para mostrar ofertas
     *
     * @param limite Número máximo de productos a retornar
     * @return Lista de productos con descuento ordenados por porcentaje de descuento
     * @throws ServiceException Si hay error en la consulta
     */
    public List<Producto> obtenerProductosConDescuento(int limite) throws ServiceException {
        logger.debug("Obteniendo {} productos con descuento", limite);

        try {
            if (limite <= 0) {
                throw new ServiceException("El límite debe ser mayor a 0");
            }

            List<Producto> productos = productoDAO.obtenerConDescuento();

            // Limitar la cantidad de productos retornados
            if (productos.size() > limite) {
                productos = productos.subList(0, limite);
            }

            logger.debug("Se obtuvieron {} productos con descuento", productos.size());
            return productos;

        } catch (SQLException e) {
            logger.error("Error al obtener productos con descuento: {}", e.getMessage(), e);
            throw new ServiceException("Error al obtener productos con descuento: " + e.getMessage());
        }
    }

    // ==================== GESTIÓN DE PRODUCTOS ====================

    /**
     * Crea un nuevo producto con sus imágenes
     *
     * @param producto Producto a crear
     * @return ID del producto creado
     * @throws ServiceException Si hay error en la operación
     */
    /**
     * Crea un nuevo producto (versión simple sin imágenes múltiples)
     * Usado por AdminServlet
     *
     * @param producto Producto a crear
     * @return ID del producto creado
     * @throws ServiceException Si hay error en la operación
     */
    public int crearProducto(Producto producto) throws ServiceException {
        logger.info("Creando producto: {}", producto.getNombre());

        try {
            // Validar datos del producto
            validarProducto(producto);

            // Verificar que la categoría existe
            Optional<Categoria> categoria = categoriaDAO.buscarPorId(producto.getIdCategoria());
            if (!categoria.isPresent()) {
                throw new ServiceException("La categoría seleccionada no existe");
            }

            // Establecer valores por defecto
            if (producto.getEstado() == null) {
                producto.setEstado(Producto.EstadoProducto.DISPONIBLE);
            }

            if (producto.getDescuento() == null) {
                producto.setDescuento(BigDecimal.ZERO);
            }

            // Crear producto
            int idProducto = productoDAO.crear(producto);
            producto.setIdProducto(idProducto);

            logger.info("Producto creado exitosamente con ID: {}", idProducto);
            return idProducto;

        } catch (SQLException e) {
            logger.error("Error al crear producto", e);
            throw new ServiceException("Error al crear producto: " + e.getMessage());
        }
    }

    /**
     * Obtiene un producto por ID (versión simple)
     *
     * @param idProducto ID del producto
     * @return Producto o null si no existe
     * @throws ServiceException Si hay error en la operación
     */
    public Producto obtenerProductoPorId(int idProducto) throws ServiceException {
        try {
            Optional<Producto> productoOpt = productoDAO.buscarPorId(idProducto);

            if (productoOpt.isPresent()) {
                Producto producto = productoOpt.get();

                // Cargar categoría
                Optional<Categoria> categoria = categoriaDAO.buscarPorId(producto.getIdCategoria());
                producto.setCategoria(categoria.orElse(null));

                return producto;
            }

            return null;

        } catch (SQLException e) {
            logger.error("Error al obtener producto por ID", e);
            throw new ServiceException("Error al obtener producto: " + e.getMessage());
        }
    }

    /**
     * Cuenta productos sin stock (stock = 0)
     *
     * @return Número de productos sin stock
     * @throws ServiceException Si hay error en la operación
     */
    public int contarProductosSinStock() throws ServiceException {
        try {
            return productoDAO.contarBajoStock(0);
        } catch (SQLException e) {
            logger.error("Error al contar productos sin stock: {}", e.getMessage());
            throw new ServiceException("Error al contar productos sin stock: " + e.getMessage());
        }
    }

    /**
     * Actualiza un producto existente
     *
     * @param producto Producto con datos actualizados
     * @throws ServiceException Si hay error en la operación
     */
    public void actualizarProducto(Producto producto) throws ServiceException {
        logger.info("Actualizando producto: {}", producto.getIdProducto());

        try {
            // Verificar que el producto existe
            Optional<Producto> productoExistente = productoDAO.buscarPorId(producto.getIdProducto());
            if (!productoExistente.isPresent()) {
                throw new ServiceException("Producto no encontrado");
            }

            // Validar datos
            validarProducto(producto);

            // Verificar categoría
            Optional<Categoria> categoria = categoriaDAO.buscarPorId(producto.getIdCategoria());
            if (!categoria.isPresent()) {
                throw new ServiceException("La categoría seleccionada no existe");
            }

            // Actualizar
            boolean actualizado = productoDAO.actualizar(producto);

            if (!actualizado) {
                throw new ServiceException("No se pudo actualizar el producto");
            }

            logger.info("Producto actualizado exitosamente");

        } catch (SQLException e) {
            logger.error("Error al actualizar producto", e);
            throw new ServiceException("Error al actualizar producto: " + e.getMessage());
        }
    }

    /**
     * Elimina un producto
     *
     * @param idProducto ID del producto a eliminar
     * @throws ServiceException Si hay error en la operación
     */
    public void eliminarProducto(int idProducto) throws ServiceException {
        logger.info("Eliminando producto: {}", idProducto);

        try {
            // Verificar que existe
            Optional<Producto> producto = productoDAO.buscarPorId(idProducto);
            if (!producto.isPresent()) {
                throw new ServiceException("Producto no encontrado");
            }

            // Eliminar (las imágenes se eliminan en cascada)
            boolean eliminado = productoDAO.eliminar(idProducto);

            if (!eliminado) {
                throw new ServiceException("No se pudo eliminar el producto");
            }

            logger.info("Producto eliminado exitosamente");

        } catch (SQLException e) {
            logger.error("Error al eliminar producto", e);
            throw new ServiceException("Error al eliminar producto: " + e.getMessage());
        }
    }

    // ==================== CONSULTAS DE PRODUCTOS ====================

    /**
     * Obtiene un producto por ID con su categoría e imágenes
     *
     * @param idProducto ID del producto
     * @return ProductoCompleto con producto, imágenes y categoría
     * @throws ServiceException Si hay error en la operación
     */
    public ProductoCompleto obtenerProductoCompleto(int idProducto) throws ServiceException {
        try {
            // Obtener producto
            Optional<Producto> productoOpt = productoDAO.buscarPorId(idProducto);
            if (!productoOpt.isPresent()) {
                throw new ServiceException("Producto no encontrado");
            }

            Producto producto = productoOpt.get();

            // Obtener categoría
            Optional<Categoria> categoria = categoriaDAO.buscarPorId(producto.getIdCategoria());
            producto.setCategoria(categoria.orElse(null));

            // Obtener imágenes
            List<ImagenProducto> imagenes = imagenDAO.obtenerPorProducto(idProducto);

            // Obtener imagen principal
            Optional<ImagenProducto> imagenPrincipal = imagenDAO.obtenerPrincipalPorProducto(idProducto);

            return new ProductoCompleto(producto, imagenes, imagenPrincipal.orElse(null));

        } catch (SQLException e) {
            logger.error("Error al obtener producto completo", e);
            throw new ServiceException("Error al obtener producto: " + e.getMessage());
        }
    }

    /**
     * Busca productos con filtros y paginación
     *
     * @param filtros Objeto FiltroProductos con criterios de búsqueda
     * @return ResultadoBusqueda con productos y metadatos de paginación
     * @throws ServiceException Si hay error en la operación
     */
    public ResultadoBusqueda buscarProductos(FiltroProductos filtros) throws ServiceException {
        try {
            List<Producto> productos;

            // Aplicar filtros
            if (filtros.getIdCategoria() != null) {
                productos = productoDAO.obtenerPorCategoria(filtros.getIdCategoria());
            } else if (filtros.getTerminoBusqueda() != null && !filtros.getTerminoBusqueda().isEmpty()) {
                productos = productoDAO.buscarPorNombre(filtros.getTerminoBusqueda());
            } else if (filtros.isSoloConDescuento()) {
                productos = productoDAO.obtenerConDescuento();
            } else if (filtros.isSoloDisponibles()) {
                productos = productoDAO.obtenerDisponibles();
            } else {
                productos = productoDAO.obtenerTodos();
            }

            // Cargar categoría para cada producto
            for (Producto producto : productos) {
                Optional<Categoria> categoria = categoriaDAO.buscarPorId(producto.getIdCategoria());
                producto.setCategoria(categoria.orElse(null));
            }

            // Aplicar filtro de precio si está definido
            if (filtros.getPrecioMinimo() != null || filtros.getPrecioMaximo() != null) {
                productos = filtrarPorRangoPrecio(productos,
                        filtros.getPrecioMinimo(), filtros.getPrecioMaximo());
            }

            // Ordenar
            productos = ordenarProductos(productos, filtros.getOrden());

            // Calcular paginación
            int totalProductos = productos.size();
            int totalPaginas = (int) Math.ceil((double) totalProductos / filtros.getProductosPorPagina());

            // Aplicar paginación
            int inicio = (filtros.getPagina() - 1) * filtros.getProductosPorPagina();
            int fin = Math.min(inicio + filtros.getProductosPorPagina(), totalProductos);

            List<Producto> productosPaginados = productos.subList(
                    Math.max(0, inicio),
                    Math.max(0, fin)
            );

            return new ResultadoBusqueda(productosPaginados, totalProductos,
                    filtros.getPagina(), totalPaginas);

        } catch (SQLException e) {
            logger.error("Error al buscar productos", e);
            throw new ServiceException("Error al buscar productos: " + e.getMessage());
        }
    }

    // ==================== GESTIÓN DE STOCK ====================

    /**
     * Verifica si hay stock suficiente de un producto
     *
     * @param idProducto ID del producto
     * @param cantidad Cantidad requerida
     * @return true si hay stock suficiente
     * @throws ServiceException Si hay error en la operación
     */
    public boolean verificarDisponibilidad(int idProducto, int cantidad) throws ServiceException {
        try {
            return productoDAO.verificarStock(idProducto, cantidad);
        } catch (SQLException e) {
            logger.error("Error al verificar disponibilidad", e);
            throw new ServiceException("Error al verificar disponibilidad: " + e.getMessage());
        }
    }

    /**
     * Actualiza el stock de un producto
     *
     * @param idProducto ID del producto
     * @param nuevoStock Nuevo valor de stock
     * @throws ServiceException Si hay error en la operación
     */
    public void actualizarStock(int idProducto, int nuevoStock) throws ServiceException {
        logger.info("Actualizando stock del producto {} a {}", idProducto, nuevoStock);

        try {
            if (nuevoStock < 0) {
                throw new ServiceException("El stock no puede ser negativo");
            }

            boolean actualizado = productoDAO.actualizarStock(idProducto, nuevoStock);

            if (!actualizado) {
                throw new ServiceException("No se pudo actualizar el stock");
            }

            // Actualizar estado si se agotó
            if (nuevoStock == 0) {
                productoDAO.actualizarEstado(idProducto, Producto.EstadoProducto.AGOTADO);
            } else {
                // Reactivar si estaba agotado
                Optional<Producto> producto = productoDAO.buscarPorId(idProducto);
                if (producto.isPresent() &&
                        producto.get().getEstado() == Producto.EstadoProducto.AGOTADO) {
                    productoDAO.actualizarEstado(idProducto, Producto.EstadoProducto.DISPONIBLE);
                }
            }

            logger.info("Stock actualizado exitosamente");

        } catch (SQLException e) {
            logger.error("Error al actualizar stock", e);
            throw new ServiceException("Error al actualizar stock: " + e.getMessage());
        }
    }

    /**
     * Reduce el stock de un producto (para ventas)
     *
     * @param idProducto ID del producto
     * @param cantidad Cantidad a reducir
     * @return true si se pudo reducir, false si no hay stock suficiente
     * @throws ServiceException Si hay error en la operación
     */
    public boolean reducirStock(int idProducto, int cantidad) throws ServiceException {
        logger.info("Reduciendo stock del producto {} en {}", idProducto, cantidad);

        try {
            if (cantidad <= 0) {
                throw new ServiceException("La cantidad debe ser mayor a cero");
            }

            // Verificar stock antes de reducir
            if (!productoDAO.verificarStock(idProducto, cantidad)) {
                logger.warn("Stock insuficiente para producto {}", idProducto);
                return false;
            }

            // Reducir stock
            boolean reducido = productoDAO.reducirStock(idProducto, cantidad);

            if (reducido) {
                // Verificar si quedó en cero
                Optional<Producto> producto = productoDAO.buscarPorId(idProducto);
                if (producto.isPresent() && producto.get().getStock() == 0) {
                    productoDAO.actualizarEstado(idProducto, Producto.EstadoProducto.AGOTADO);
                }
            }

            return reducido;

        } catch (SQLException e) {
            logger.error("Error al reducir stock", e);
            throw new ServiceException("Error al reducir stock: " + e.getMessage());
        }
    }

    // ==================== GESTIÓN DE IMÁGENES ====================

    /**
     * Agrega múltiples imágenes a un producto
     *
     * @param idProducto ID del producto
     * @param urlImagenes Lista de URLs de imágenes
     * @throws SQLException Si hay error en la operación
     */
    private void agregarImagenesAProducto(int idProducto, List<String> urlImagenes)
            throws SQLException {
        List<ImagenProducto> imagenes = new ArrayList<>();

        for (int i = 0; i < urlImagenes.size(); i++) {
            ImagenProducto imagen = new ImagenProducto(
                    idProducto,
                    urlImagenes.get(i),
                    i == 0, // La primera es principal
                    i       // Orden
            );
            imagenes.add(imagen);
        }

        imagenDAO.crearMultiples(imagenes);
    }

    /**
     * Agrega una imagen a un producto
     *
     * @param idProducto ID del producto
     * @param urlImagen URL de la imagen
     * @param esPrincipal Si es imagen principal
     * @throws ServiceException Si hay error en la operación
     */
    public void agregarImagen(int idProducto, String urlImagen, boolean esPrincipal)
            throws ServiceException {
        try {
            int orden = imagenDAO.obtenerSiguienteOrden(idProducto);

            ImagenProducto imagen = new ImagenProducto(idProducto, urlImagen, esPrincipal, orden);
            imagenDAO.crear(imagen);

            if (esPrincipal) {
                imagenDAO.establecerComoPrincipal(imagen.getIdImagen(), idProducto);
            }

        } catch (SQLException e) {
            logger.error("Error al agregar imagen", e);
            throw new ServiceException("Error al agregar imagen: " + e.getMessage());
        }
    }

    /**
     * Elimina una imagen de un producto
     *
     * @param idImagen ID de la imagen
     * @throws ServiceException Si hay error en la operación
     */
    public void eliminarImagen(int idImagen) throws ServiceException {
        try {
            boolean eliminada = imagenDAO.eliminar(idImagen);

            if (!eliminada) {
                throw new ServiceException("No se pudo eliminar la imagen");
            }

        } catch (SQLException e) {
            logger.error("Error al eliminar imagen", e);
            throw new ServiceException("Error al eliminar imagen: " + e.getMessage());
        }
    }

    // ==================== UTILIDADES PRIVADAS ====================

    /**
     * Valida los datos de un producto
     *
     * @param producto Producto a validar
     * @throws ServiceException Si la validación falla
     */
    private void validarProducto(Producto producto) throws ServiceException {
        if (producto.getNombre() == null || producto.getNombre().trim().isEmpty()) {
            throw new ServiceException("El nombre del producto es requerido");
        }

        if (producto.getIdCategoria() == null) {
            throw new ServiceException("La categoría es requerida");
        }

        if (producto.getPrecio() == null || producto.getPrecio().compareTo(BigDecimal.ZERO) <= 0) {
            throw new ServiceException("El precio debe ser mayor a cero");
        }

        if (producto.getStock() == null || producto.getStock() < 0) {
            throw new ServiceException("El stock no puede ser negativo");
        }

        if (producto.getDescuento() != null) {
            if (producto.getDescuento().compareTo(BigDecimal.ZERO) < 0 ||
                    producto.getDescuento().compareTo(new BigDecimal("100")) > 0) {
                throw new ServiceException("El descuento debe estar entre 0 y 100");
            }
        }
    }

    /**
     * Filtra productos por rango de precio
     *
     * @param productos Lista de productos
     * @param minimo Precio mínimo
     * @param maximo Precio máximo
     * @return Lista filtrada
     */
    private List<Producto> filtrarPorRangoPrecio(List<Producto> productos,
                                                  BigDecimal minimo, BigDecimal maximo) {
        List<Producto> filtrados = new ArrayList<>();

        for (Producto producto : productos) {
            BigDecimal precio = producto.getPrecioConDescuento();
            boolean cumpleMinimo = minimo == null || precio.compareTo(minimo) >= 0;
            boolean cumpleMaximo = maximo == null || precio.compareTo(maximo) <= 0;

            if (cumpleMinimo && cumpleMaximo) {
                filtrados.add(producto);
            }
        }

        return filtrados;
    }

    /**
     * Ordena la lista de productos según el criterio especificado
     *
     * @param productos Lista de productos
     * @param orden Criterio de ordenamiento
     * @return Lista ordenada
     */
    private List<Producto> ordenarProductos(List<Producto> productos, OrdenProducto orden) {
        if (orden == null) {
            return productos;
        }

        List<Producto> ordenados = new ArrayList<>(productos);

        switch (orden) {
            case PRECIO_ASC:
                ordenados.sort((p1, p2) -> p1.getPrecio().compareTo(p2.getPrecio()));
                break;
            case PRECIO_DESC:
                ordenados.sort((p1, p2) -> p2.getPrecio().compareTo(p1.getPrecio()));
                break;
            case NOMBRE_ASC:
                ordenados.sort((p1, p2) -> p1.getNombre().compareTo(p2.getNombre()));
                break;
            case NOMBRE_DESC:
                ordenados.sort((p1, p2) -> p2.getNombre().compareTo(p1.getNombre()));
                break;
            case MAS_RECIENTE:
                ordenados.sort((p1, p2) -> p2.getFechaRegistro().compareTo(p1.getFechaRegistro()));
                break;
        }

        return ordenados;
    }

    // ==================== MÉTODOS PARA ADMINISTRACIÓN ====================

    /**
     * Cuenta el total de productos en el sistema
     *
     * @return Número total de productos
     * @throws ServiceException Si hay error en la operación
     */
    public int contarProductos() throws ServiceException {
        try {
            return productoDAO.contarTodos();
        } catch (SQLException e) {
            logger.error("Error al contar productos: {}", e.getMessage());
            throw new ServiceException("Error al contar productos: " + e.getMessage());
        }
    }

    /**
     * Cuenta productos con estado DISPONIBLE
     *
     * @return Número de productos activos
     * @throws ServiceException Si hay error en la operación
     */
    public int contarProductosActivos() throws ServiceException {
        try {
            return productoDAO.contarActivos();
        } catch (SQLException e) {
            logger.error("Error al contar productos activos: {}", e.getMessage());
            throw new ServiceException("Error al contar productos activos: " + e.getMessage());
        }
    }

    /**
     * Cuenta productos con stock bajo el mínimo especificado
     *
     * @param stockMinimo Stock mínimo
     * @return Número de productos con stock bajo
     * @throws ServiceException Si hay error en la operación
     */
    public int contarProductosBajoStock(int stockMinimo) throws ServiceException {
        try {
            return productoDAO.contarBajoStock(stockMinimo);
        } catch (SQLException e) {
            logger.error("Error al contar productos bajo stock: {}", e.getMessage());
            throw new ServiceException("Error al contar productos bajo stock: " + e.getMessage());
        }
    }

    /**
     * Obtiene lista de productos con stock bajo el mínimo
     *
     * @param stockMinimo Stock mínimo
     * @param limite Límite de resultados
     * @return Lista de productos con stock bajo
     * @throws ServiceException Si hay error en la operación
     */
    public List<Producto> obtenerProductosBajoStock(int stockMinimo, int limite)
            throws ServiceException {
        try {
            return productoDAO.obtenerBajoStock(stockMinimo, limite);
        } catch (SQLException e) {
            logger.error("Error al obtener productos bajo stock: {}", e.getMessage());
            throw new ServiceException("Error al obtener productos bajo stock: " + e.getMessage());
        }
    }

    /**
     * Obtiene estadísticas completas de productos
     *
     * @return EstadisticasProductos con métricas del sistema
     * @throws ServiceException Si hay error en la operación
     */
    public EstadisticasProductos obtenerEstadisticasProductos() throws ServiceException {
        try {
            EstadisticasProductos stats = new EstadisticasProductos();

            stats.setTotalProductos(productoDAO.contarTodos());
            stats.setProductosActivos(productoDAO.contarActivos());

            int total = stats.getTotalProductos();
            int activos = stats.getProductosActivos();
            stats.setProductosInactivos(total - activos);

            stats.setProductosSinStock(productoDAO.contarBajoStock(0));
            stats.setProductosBajoStock(productoDAO.contarBajoStock(10));
            stats.setValorInventario(productoDAO.calcularValorInventario().doubleValue());

            return stats;

        } catch (SQLException e) {
            logger.error("Error al obtener estadísticas de productos: {}", e.getMessage());
            throw new ServiceException("Error al obtener estadísticas de productos: " + e.getMessage());
        }
    }

    // ==================== CLASES INTERNAS ====================

    /**
     * Clase contenedora para producto completo con imágenes
     */
    public static class ProductoCompleto {
        private final Producto producto;
        private final List<ImagenProducto> imagenes;
        private final ImagenProducto imagenPrincipal;

        public ProductoCompleto(Producto producto, List<ImagenProducto> imagenes,
                                ImagenProducto imagenPrincipal) {
            this.producto = producto;
            this.imagenes = imagenes;
            this.imagenPrincipal = imagenPrincipal;
        }

        public Producto getProducto() { return producto; }
        public List<ImagenProducto> getImagenes() { return imagenes; }
        public ImagenProducto getImagenPrincipal() { return imagenPrincipal; }
    }



    /**
     * Clase para filtros de búsqueda de productos
     */
    public static class FiltroProductos {
        private Integer idCategoria;
        private String terminoBusqueda;
        private BigDecimal precioMinimo;
        private BigDecimal precioMaximo;
        private boolean soloDisponibles = true;
        private boolean soloConDescuento = false;
        private OrdenProducto orden = OrdenProducto.MAS_RECIENTE;
        private int pagina = 1;
        private int productosPorPagina = 12;

        public Integer getIdCategoria() { return idCategoria; }
        public void setIdCategoria(Integer idCategoria) { this.idCategoria = idCategoria; }

        public String getTerminoBusqueda() { return terminoBusqueda; }
        public void setTerminoBusqueda(String terminoBusqueda) {
            this.terminoBusqueda = terminoBusqueda;
        }

        public BigDecimal getPrecioMinimo() { return precioMinimo; }
        public void setPrecioMinimo(BigDecimal precioMinimo) {
            this.precioMinimo = precioMinimo;
        }

        public BigDecimal getPrecioMaximo() { return precioMaximo; }
        public void setPrecioMaximo(BigDecimal precioMaximo) {
            this.precioMaximo = precioMaximo;
        }

        public boolean isSoloDisponibles() { return soloDisponibles; }
        public void setSoloDisponibles(boolean soloDisponibles) {
            this.soloDisponibles = soloDisponibles;
        }

        public boolean isSoloConDescuento() { return soloConDescuento; }
        public void setSoloConDescuento(boolean soloConDescuento) {
            this.soloConDescuento = soloConDescuento;
        }

        public OrdenProducto getOrden() { return orden; }
        public void setOrden(OrdenProducto orden) { this.orden = orden; }

        public int getPagina() { return pagina; }
        public void setPagina(int pagina) { this.pagina = Math.max(1, pagina); }

        public int getProductosPorPagina() { return productosPorPagina; }
        public void setProductosPorPagina(int productosPorPagina) {
            this.productosPorPagina = productosPorPagina;
        }
    }

    /**
     * Clase para resultados de búsqueda con paginación
     */
    public static class ResultadoBusqueda {
        private final List<Producto> productos;
        private final int totalProductos;
        private final int paginaActual;
        private final int totalPaginas;

        public ResultadoBusqueda(List<Producto> productos, int totalProductos,
                                 int paginaActual, int totalPaginas) {
            this.productos = productos;
            this.totalProductos = totalProductos;
            this.paginaActual = paginaActual;
            this.totalPaginas = totalPaginas;
        }

        public List<Producto> getProductos() { return productos; }
        public int getTotalProductos() { return totalProductos; }
        public int getPaginaActual() { return paginaActual; }
        public int getTotalPaginas() { return totalPaginas; }
        public boolean tienePaginaAnterior() { return paginaActual > 1; }
        public boolean tienePaginaSiguiente() { return paginaActual < totalPaginas; }
    }

    /**
     * Enum para ordenamiento de productos
     */
    public enum OrdenProducto {
        PRECIO_ASC, 
        PRECIO_DESC, 
        NOMBRE_ASC, 
        NOMBRE_DESC, 
        MAS_RECIENTE
    }

    /**
     * Clase para estadísticas de productos
     */
    public static class EstadisticasProductos {
        private int totalProductos;
        private int productosActivos;
        private int productosInactivos;
        private int productosSinStock;
        private int productosBajoStock;
        private double valorInventario;

        public int getTotalProductos() { return totalProductos; }
        public void setTotalProductos(int totalProductos) {
            this.totalProductos = totalProductos;
        }

        public int getProductosActivos() { return productosActivos; }
        public void setProductosActivos(int productosActivos) {
            this.productosActivos = productosActivos;
        }

        public int getProductosInactivos() { return productosInactivos; }
        public void setProductosInactivos(int productosInactivos) {
            this.productosInactivos = productosInactivos;
        }

        public int getProductosSinStock() { return productosSinStock; }
        public void setProductosSinStock(int productosSinStock) {
            this.productosSinStock = productosSinStock;
        }

        public int getProductosBajoStock() { return productosBajoStock; }
        public void setProductosBajoStock(int productosBajoStock) {
            this.productosBajoStock = productosBajoStock;
        }

        public double getValorInventario() { return valorInventario; }
        public void setValorInventario(double valorInventario) {
            this.valorInventario = valorInventario;
        }
    }

    /**
     * Excepción personalizada para errores de servicio
     */
    public static class ServiceException extends Exception {
        public ServiceException(String message) {
            super(message);
        }

        public ServiceException(String message, Throwable cause) {
            super(message, cause);
        }
    }
}
