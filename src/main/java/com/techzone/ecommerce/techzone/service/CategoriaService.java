package com.techzone.ecommerce.techzone.service;

import com.techzone.ecommerce.techzone.service.ServiceException;
import com.techzone.ecommerce.techzone.dao.CategoriaDAO;
import com.techzone.ecommerce.techzone.model.Categoria;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.sql.SQLException;
import java.util.List;
import java.util.Optional;

/**
 * Servicio para la gestión de categorías
 * Contiene la lógica de negocio para operaciones con categorías
 *
 * @author TechZone Team
 */
public class CategoriaService {

    private static final Logger logger = LoggerFactory.getLogger(CategoriaService.class);
    private final CategoriaDAO categoriaDAO;

    public CategoriaService() {
        this.categoriaDAO = new CategoriaDAO();
    }

    // Constructor para inyección de dependencias (testing)
    public CategoriaService(CategoriaDAO categoriaDAO) {
        this.categoriaDAO = categoriaDAO;
    }

    // ==================== CREATE ====================

    /**
     * Crea una nueva categoría
     * Valida que el nombre no esté vacío y que no exista ya
     */
    public int crearCategoria(Categoria categoria) throws ServiceException {
        logger.debug("Intentando crear categoría: {}", categoria.getNombre());

        try {
            // Validaciones
            validarCategoria(categoria);

            // Verificar que no exista una categoría con el mismo nombre
            if (categoriaDAO.existeNombre(categoria.getNombre())) {
                throw new ServiceException("Ya existe una categoría con el nombre: " + categoria.getNombre());
            }

            // Crear la categoría
            int idGenerado = categoriaDAO.crear(categoria);
            logger.info("Categoría creada exitosamente - ID: {}, Nombre: {}",
                    idGenerado, categoria.getNombre());

            return idGenerado;

        } catch (SQLException e) {
            logger.error("Error al crear categoría: {}", e.getMessage(), e);
            throw new ServiceException("Error al crear la categoría: " + e.getMessage());
        }
    }

    // ==================== READ ====================

    /**
     * Obtiene una categoría por su ID
     */
    public Optional<Categoria> obtenerCategoriaPorId(int id) throws ServiceException {
        logger.debug("Buscando categoría con ID: {}", id);

        try {
            if (id <= 0) {
                throw new ServiceException("El ID de la categoría debe ser mayor a 0");
            }

            Optional<Categoria> categoria = categoriaDAO.buscarPorId(id);

            if (categoria.isPresent()) {
                logger.debug("Categoría encontrada: {}", categoria.get().getNombre());
            } else {
                logger.debug("No se encontró categoría con ID: {}", id);
            }

            return categoria;

        } catch (SQLException e) {
            logger.error("Error al buscar categoría por ID {}: {}", id, e.getMessage(), e);
            throw new ServiceException("Error al buscar la categoría: " + e.getMessage());
        }
    }

    /**
     * Obtiene una categoría por su nombre
     */
    public Optional<Categoria> obtenerCategoriaPorNombre(String nombre) throws ServiceException {
        logger.debug("Buscando categoría con nombre: {}", nombre);

        try {
            if (nombre == null || nombre.trim().isEmpty()) {
                throw new ServiceException("El nombre de la categoría no puede estar vacío");
            }

            return categoriaDAO.buscarPorNombre(nombre.trim());

        } catch (SQLException e) {
            logger.error("Error al buscar categoría por nombre {}: {}", nombre, e.getMessage(), e);
            throw new ServiceException("Error al buscar la categoría: " + e.getMessage());
        }
    }

    /**
     * Obtiene todas las categorías
     */
    public List<Categoria> obtenerTodasCategorias() throws ServiceException {
        logger.debug("Obteniendo todas las categorías");

        try {
            List<Categoria> categorias = categoriaDAO.obtenerTodas();
            logger.debug("Se encontraron {} categorías", categorias.size());
            return categorias;

        } catch (SQLException e) {
            logger.error("Error al obtener todas las categorías: {}", e.getMessage(), e);
            throw new ServiceException("Error al obtener las categorías: " + e.getMessage());
        }
    }

    /**
     * Obtiene solo las categorías activas
     */
    public List<Categoria> obtenerCategoriasActivas() throws ServiceException {
        logger.debug("Obteniendo categorías activas");

        try {
            List<Categoria> categorias = categoriaDAO.obtenerActivas();
            logger.debug("Se encontraron {} categorías activas", categorias.size());
            return categorias;

        } catch (SQLException e) {
            logger.error("Error al obtener categorías activas: {}", e.getMessage(), e);
            throw new ServiceException("Error al obtener las categorías activas: " + e.getMessage());
        }
    }

    // ==================== UPDATE ====================

    /**
     * Actualiza una categoría existente
     */
    public boolean actualizarCategoria(Categoria categoria) throws ServiceException {
        logger.debug("Intentando actualizar categoría ID: {}", categoria.getIdCategoria());

        try {
            // Validaciones
            if (categoria.getIdCategoria() == null || categoria.getIdCategoria() <= 0) {
                throw new ServiceException("El ID de la categoría es inválido");
            }

            validarCategoria(categoria);

            // Verificar que la categoría existe
            Optional<Categoria> categoriaExistente = categoriaDAO.buscarPorId(categoria.getIdCategoria());
            if (categoriaExistente.isEmpty()) {
                throw new ServiceException("No existe una categoría con el ID: " + categoria.getIdCategoria());
            }

            // Verificar que el nombre no esté duplicado (excepto para la misma categoría)
            Optional<Categoria> categoriaMismoNombre = categoriaDAO.buscarPorNombre(categoria.getNombre());
            if (categoriaMismoNombre.isPresent() &&
                    !categoriaMismoNombre.get().getIdCategoria().equals(categoria.getIdCategoria())) {
                throw new ServiceException("Ya existe otra categoría con el nombre: " + categoria.getNombre());
            }

            // Actualizar
            boolean actualizado = categoriaDAO.actualizar(categoria);

            if (actualizado) {
                logger.info("Categoría actualizada exitosamente - ID: {}, Nombre: {}",
                        categoria.getIdCategoria(), categoria.getNombre());
            }

            return actualizado;

        } catch (SQLException e) {
            logger.error("Error al actualizar categoría: {}", e.getMessage(), e);
            throw new ServiceException("Error al actualizar la categoría: " + e.getMessage());
        }
    }

    /**
     * Cambia el estado de una categoría (ACTIVA/INACTIVA)
     */
    public boolean cambiarEstadoCategoria(int idCategoria, Categoria.EstadoCategoria nuevoEstado)
            throws ServiceException {
        logger.debug("Cambiando estado de categoría ID {} a {}", idCategoria, nuevoEstado);

        try {
            if (idCategoria <= 0) {
                throw new ServiceException("El ID de la categoría debe ser mayor a 0");
            }

            if (nuevoEstado == null) {
                throw new ServiceException("El estado no puede ser nulo");
            }

            // Verificar que la categoría existe
            Optional<Categoria> categoria = categoriaDAO.buscarPorId(idCategoria);
            if (categoria.isEmpty()) {
                throw new ServiceException("No existe una categoría con el ID: " + idCategoria);
            }

            // Si se está desactivando, verificar que no tenga productos asociados
            if (nuevoEstado == Categoria.EstadoCategoria.INACTIVO) {
                int cantidadProductos = categoriaDAO.contarProductosPorCategoria(idCategoria);
                if (cantidadProductos > 0) {
                    throw new ServiceException(
                            "No se puede desactivar la categoría porque tiene " +
                                    cantidadProductos + " producto(s) asociado(s)");
                }
            }

            boolean actualizado = categoriaDAO.actualizarEstado(idCategoria, nuevoEstado);

            if (actualizado) {
                logger.info("Estado de categoría {} cambiado a {}", idCategoria, nuevoEstado);
            }

            return actualizado;

        } catch (SQLException e) {
            logger.error("Error al cambiar estado de categoría: {}", e.getMessage(), e);
            throw new ServiceException("Error al cambiar el estado de la categoría: " + e.getMessage());
        }
    }

    // ==================== DELETE ====================

    /**
     * Elimina una categoría
     * Solo si no tiene productos asociados
     */
    public boolean eliminarCategoria(int idCategoria) throws ServiceException {
        logger.debug("Intentando eliminar categoría ID: {}", idCategoria);

        try {
            if (idCategoria <= 0) {
                throw new ServiceException("El ID de la categoría debe ser mayor a 0");
            }

            // Verificar que la categoría existe
            Optional<Categoria> categoria = categoriaDAO.buscarPorId(idCategoria);
            if (categoria.isEmpty()) {
                throw new ServiceException("No existe una categoría con el ID: " + idCategoria);
            }

            // Verificar que no tenga productos asociados
            int cantidadProductos = categoriaDAO.contarProductosPorCategoria(idCategoria);
            if (cantidadProductos > 0) {
                throw new ServiceException(
                        "No se puede eliminar la categoría porque tiene " +
                                cantidadProductos + " producto(s) asociado(s). " +
                                "Elimine primero los productos o cambie su categoría.");
            }

            // Eliminar
            boolean eliminado = categoriaDAO.eliminar(idCategoria);

            if (eliminado) {
                logger.info("Categoría eliminada exitosamente - ID: {}", idCategoria);
            }

            return eliminado;

        } catch (SQLException e) {
            logger.error("Error al eliminar categoría: {}", e.getMessage(), e);
            throw new ServiceException("Error al eliminar la categoría: " + e.getMessage());
        }
    }

    // ==================== UTILIDADES ====================

    /**
     * Cuenta el total de categorías en el sistema
     */
    public int contarCategorias() throws ServiceException {
        try {
            return categoriaDAO.contarCategorias();
        } catch (SQLException e) {
            logger.error("Error al contar categorías: {}", e.getMessage(), e);
            throw new ServiceException("Error al contar las categorías: " + e.getMessage());
        }
    }

    /**
     * Cuenta cuántos productos tiene una categoría
     */
    public int contarProductosPorCategoria(int idCategoria) throws ServiceException {
        try {
            if (idCategoria <= 0) {
                throw new ServiceException("El ID de la categoría debe ser mayor a 0");
            }

            return categoriaDAO.contarProductosPorCategoria(idCategoria);

        } catch (SQLException e) {
            logger.error("Error al contar productos de categoría: {}", e.getMessage(), e);
            throw new ServiceException("Error al contar los productos: " + e.getMessage());
        }
    }

    /**
     * Verifica si existe una categoría con el nombre dado
     */
    public boolean existeNombreCategoria(String nombre) throws ServiceException {
        try {
            if (nombre == null || nombre.trim().isEmpty()) {
                return false;
            }

            return categoriaDAO.existeNombre(nombre.trim());

        } catch (SQLException e) {
            logger.error("Error al verificar existencia de categoría: {}", e.getMessage(), e);
            throw new ServiceException("Error al verificar la categoría: " + e.getMessage());
        }
    }


    /**
     * ✅ MÉTODO OPCIONAL: Para usar en CategoriaService.java
     * Obtiene categorías activas con el conteo de productos
     */
    public List<Categoria> obtenerCategoriasActivasConConteo() throws ServiceException {
        logger.debug("Obteniendo categorías activas con conteo de productos");

        try {
            List<Categoria> categorias = categoriaDAO.obtenerActivasConConteo();
            logger.debug("Se encontraron {} categorías activas con conteo", categorias.size());
            return categorias;

        } catch (SQLException e) {
            logger.error("Error al obtener categorías activas con conteo: {}", e.getMessage(), e);
            throw new ServiceException("Error al obtener las categorías activas: " + e.getMessage());
        }
    }

    // ==================== VALIDACIONES ====================

    /**
     * Valida los datos de una categoría
     */
    private void validarCategoria(Categoria categoria) throws ServiceException {
        if (categoria == null) {
            throw new ServiceException("La categoría no puede ser nula");
        }

        if (categoria.getNombre() == null || categoria.getNombre().trim().isEmpty()) {
            throw new ServiceException("El nombre de la categoría no puede estar vacío");
        }

        if (categoria.getNombre().length() < 3) {
            throw new ServiceException("El nombre de la categoría debe tener al menos 3 caracteres");
        }

        if (categoria.getNombre().length() > 100) {
            throw new ServiceException("El nombre de la categoría no puede exceder 100 caracteres");
        }

        if (categoria.getDescripcion() != null && categoria.getDescripcion().length() > 500) {
            throw new ServiceException("La descripción no puede exceder 500 caracteres");
        }

        if (categoria.getEstado() == null) {
            categoria.setEstado(Categoria.EstadoCategoria.ACTIVO);
        }
    }
}
