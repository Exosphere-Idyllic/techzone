package com.techzone.ecommerce.techzone.service;

import com.techzone.ecommerce.techzone.service.ServiceException;
import com.techzone.ecommerce.techzone.dao.ImagenDAO;
import com.techzone.ecommerce.techzone.model.Imagen;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.sql.SQLException;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

public class ImagenService {

    private static final Logger logger = LoggerFactory.getLogger(ImagenService.class);
    private final ImagenDAO imagenDAO;

    public ImagenService() {
        this.imagenDAO = new ImagenDAO();
    }

    /**
     * ✅ MÉTODO CLAVE: Obtiene imágenes para múltiples productos de una sola vez
     * Esto reduce 80+ queries a solo 1 query
     */
    public Map<Integer, List<Imagen>> obtenerImagenesPorProductos(List<Integer> idsProductos)
            throws ServiceException {
        try {
            if (idsProductos == null || idsProductos.isEmpty()) {
                return Map.of();
            }

            logger.debug("Obteniendo imágenes para {} productos", idsProductos.size());

            // UNA SOLA consulta para todos los productos
            List<Imagen> todasLasImagenes = imagenDAO.obtenerPorProductos(idsProductos);

            // Agrupar por ID de producto
            Map<Integer, List<Imagen>> mapa = todasLasImagenes.stream()
                    .collect(Collectors.groupingBy(Imagen::getIdProducto));

            logger.debug("Se obtuvieron {} imágenes en total", todasLasImagenes.size());

            return mapa;

        } catch (SQLException e) {
            logger.error("Error al obtener imágenes: {}", e.getMessage(), e);
            throw new ServiceException("Error al obtener las imágenes: " + e.getMessage());
        }
    }

    public List<Imagen> obtenerPorProducto(int idProducto) throws ServiceException {
        try {
            return imagenDAO.obtenerPorProducto(idProducto);
        } catch (SQLException e) {
            logger.error("Error al obtener imágenes del producto {}: {}", idProducto, e.getMessage());
            throw new ServiceException("Error al obtener las imágenes: " + e.getMessage());
        }
    }

    public Imagen obtenerPrincipal(int idProducto) throws ServiceException {
        try {
            return imagenDAO.obtenerPrincipal(idProducto).orElse(null);
        } catch (SQLException e) {
            logger.error("Error al obtener imagen principal del producto {}: {}", idProducto, e.getMessage());
            throw new ServiceException("Error al obtener la imagen principal: " + e.getMessage());
        }
    }
}