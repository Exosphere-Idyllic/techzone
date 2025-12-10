package com.techzone.ecommerce.techzone.service;

import com.techzone.ecommerce.techzone.dao.*;
import com.techzone.ecommerce.techzone.model.*;

import java.sql.SQLException;
import java.util.List;
import java.util.Optional;

/**
 * Servicio de lógica de negocio para gestión de reseñas
 * @author TechZone Team
 */
public class ResenaService {

    private final ResenaDAO resenaDAO;
    private final ProductoDAO productoDAO;
    private final UsuarioDAO usuarioDAO;
    private final DetallePedidoDAO detalleDAO;
    private final PedidoDAO pedidoDAO;

    public ResenaService() {
        this.resenaDAO = new ResenaDAO();
        this.productoDAO = new ProductoDAO();
        this.usuarioDAO = new UsuarioDAO();
        this.detalleDAO = new DetallePedidoDAO();
        this.pedidoDAO = new PedidoDAO();
    }

    // ==================== CREACIÓN Y GESTIÓN DE RESEÑAS ====================

    /**
     * Crea una nueva reseña de producto
     * @param resena Reseña a crear
     * @param verificarCompra Si es true, verifica que el usuario haya comprado el producto
     */
    public int crearResena(Resena resena, boolean verificarCompra) throws ServiceException {
        try {
            // Validar reseña
            validarResena(resena);

            // Verificar que el producto existe
            Optional<Producto> producto = productoDAO.buscarPorId(resena.getIdProducto());
            if (!producto.isPresent()) {
                throw new ServiceException("El producto no existe");
            }

            // Verificar que el usuario existe
            Optional<Usuario> usuario = usuarioDAO.buscarPorId(resena.getIdUsuario());
            if (!usuario.isPresent()) {
                throw new ServiceException("El usuario no existe");
            }

            // Verificar que no haya reseñado antes
            if (resenaDAO.yaReseno(resena.getIdUsuario(), resena.getIdProducto())) {
                throw new ServiceException("Ya has reseñado este producto");
            }

            // Verificar que haya comprado el producto (opcional)
            if (verificarCompra) {
                if (!haCompradoProducto(resena.getIdUsuario(), resena.getIdProducto())) {
                    throw new ServiceException(
                            "Solo puedes reseñar productos que has comprado"
                    );
                }
            }

            // Sanitizar comentario
            if (resena.getComentario() != null) {
                resena.setComentario(sanitizarComentario(resena.getComentario()));
            }

            // Crear reseña
            int idResena = resenaDAO.crear(resena);
            return idResena;

        } catch (SQLException e) {
            throw new ServiceException("Error al crear reseña", e);
        }
    }

    /**
     * Actualiza una reseña existente
     */
    public void actualizarResena(Resena resena, int idUsuarioActualizador)
            throws ServiceException {
        try {
            // Verificar que la reseña existe
            Optional<Resena> resenaExistente = resenaDAO.buscarPorId(resena.getIdResena());
            if (!resenaExistente.isPresent()) {
                throw new ServiceException("Reseña no encontrada");
            }

            // Verificar que el usuario es el autor
            if (resenaExistente.get().getIdUsuario() != idUsuarioActualizador) {
                throw new ServiceException("No tienes permiso para editar esta reseña");
            }

            // Validar nueva reseña
            if (resena.getCalificacion() < 1 || resena.getCalificacion() > 5) {
                throw new ServiceException("La calificación debe estar entre 1 y 5");
            }

            // Sanitizar comentario
            if (resena.getComentario() != null) {
                resena.setComentario(sanitizarComentario(resena.getComentario()));
            }

            // Actualizar
            boolean actualizado = resenaDAO.actualizar(resena);
            if (!actualizado) {
                throw new ServiceException("No se pudo actualizar la reseña");
            }

        } catch (SQLException e) {
            throw new ServiceException("Error al actualizar reseña", e);
        }
    }

    /**
     * Elimina una reseña
     */
    public void eliminarResena(int idResena, int idUsuarioEliminador) throws ServiceException {
        try {
            // Verificar que existe
            Optional<Resena> resena = resenaDAO.buscarPorId(idResena);
            if (!resena.isPresent()) {
                throw new ServiceException("Reseña no encontrada");
            }

            // Verificar permisos
            if (resena.get().getIdUsuario() != idUsuarioEliminador) {
                throw new ServiceException("No tienes permiso para eliminar esta reseña");
            }

            // Eliminar
            boolean eliminado = resenaDAO.eliminar(idResena);
            if (!eliminado) {
                throw new ServiceException("No se pudo eliminar la reseña");
            }

        } catch (SQLException e) {
            throw new ServiceException("Error al eliminar reseña", e);
        }
    }

    // ==================== CONSULTAS DE RESEÑAS ====================

    /**
     * Obtiene reseñas de un producto con paginación
     */
    public ResenasPaginadas obtenerResenasPorProducto(int idProducto, int pagina, int porPagina)
            throws ServiceException {
        try {
            // Obtener todas las reseñas del producto
            List<Resena> todasResenas = resenaDAO.obtenerConUsuarioPorProducto(idProducto);

            // Enriquecer con información de usuarios
            for (Resena resena : todasResenas) {
                Optional<Usuario> usuario = usuarioDAO.buscarPorId(resena.getIdUsuario());
                resena.setUsuario(usuario.orElse(null));
            }

            // Calcular estadísticas
            int totalResenas = todasResenas.size();
            double promedioCalificacion = resenaDAO.calcularPromedioCalificacion(idProducto);
            int[] distribucion = resenaDAO.obtenerDistribucionCalificaciones(idProducto);

            // Aplicar paginación
            int totalPaginas = (int) Math.ceil((double) totalResenas / porPagina);
            int inicio = (pagina - 1) * porPagina;
            int fin = Math.min(inicio + porPagina, totalResenas);

            List<Resena> resenasPaginadas = todasResenas.subList(
                    Math.max(0, inicio),
                    Math.max(0, fin)
            );

            return new ResenasPaginadas(
                    resenasPaginadas,
                    totalResenas,
                    pagina,
                    totalPaginas,
                    promedioCalificacion,
                    distribucion
            );

        } catch (SQLException e) {
            throw new ServiceException("Error al obtener reseñas", e);
        }
    }

    /**
     * Obtiene reseñas por calificación específica
     */
    public List<Resena> obtenerPorCalificacion(int idProducto, int calificacion)
            throws ServiceException {
        try {
            if (calificacion < 1 || calificacion > 5) {
                throw new ServiceException("La calificación debe estar entre 1 y 5");
            }

            return resenaDAO.obtenerPorCalificacion(idProducto, calificacion);

        } catch (SQLException e) {
            throw new ServiceException("Error al obtener reseñas", e);
        }
    }

    /**
     * Obtiene todas las reseñas de un usuario
     */
    public List<Resena> obtenerResenasPorUsuario(int idUsuario) throws ServiceException {
        try {
            List<Resena> resenas = resenaDAO.obtenerPorUsuario(idUsuario);

            // Enriquecer con información de productos
            for (Resena resena : resenas) {
                Optional<Producto> producto = productoDAO.buscarPorId(resena.getIdProducto());
                resena.setProducto(producto.orElse(null));
            }

            return resenas;

        } catch (SQLException e) {
            throw new ServiceException("Error al obtener reseñas del usuario", e);
        }
    }

    /**
     * Obtiene las reseñas más recientes del sitio
     */
    public List<Resena> obtenerResenasRecientes(int limite) throws ServiceException {
        try {
            List<Resena> resenas = resenaDAO.obtenerRecientes(limite);

            // Enriquecer con productos y usuarios
            for (Resena resena : resenas) {
                Optional<Producto> producto = productoDAO.buscarPorId(resena.getIdProducto());
                resena.setProducto(producto.orElse(null));

                Optional<Usuario> usuario = usuarioDAO.buscarPorId(resena.getIdUsuario());
                resena.setUsuario(usuario.orElse(null));
            }

            return resenas;

        } catch (SQLException e) {
            throw new ServiceException("Error al obtener reseñas recientes", e);
        }
    }

    // ==================== ESTADÍSTICAS ====================

    /**
     * Obtiene estadísticas de reseñas de un producto
     */
    public EstadisticasResenas obtenerEstadisticas(int idProducto) throws ServiceException {
        try {
            int totalResenas = resenaDAO.contarPorProducto(idProducto);
            double promedio = resenaDAO.calcularPromedioCalificacion(idProducto);
            int[] distribucion = resenaDAO.obtenerDistribucionCalificaciones(idProducto);

            return new EstadisticasResenas(totalResenas, promedio, distribucion);

        } catch (SQLException e) {
            throw new ServiceException("Error al obtener estadísticas", e);
        }
    }

    /**
     * Verifica si un usuario puede reseñar un producto
     */
    public VerificacionResena puedeResenar(int idUsuario, int idProducto) throws ServiceException {
        try {
            // Verificar si ya reseñó
            boolean yaReseno = resenaDAO.yaReseno(idUsuario, idProducto);
            if (yaReseno) {
                return new VerificacionResena(false, "Ya has reseñado este producto");
            }

            // Verificar si compró el producto
            boolean compro = haCompradoProducto(idUsuario, idProducto);
            if (!compro) {
                return new VerificacionResena(false,
                        "Solo puedes reseñar productos que has comprado");
            }

            return new VerificacionResena(true, "Puedes reseñar este producto");

        } catch (SQLException e) {
            throw new ServiceException("Error al verificar permisos", e);
        }
    }

    // ==================== UTILIDADES PRIVADAS ====================

    /**
     * Valida los datos de una reseña
     */
    private void validarResena(Resena resena) throws ServiceException {
        if (resena.getIdProducto() == null || resena.getIdProducto() <= 0) {
            throw new ServiceException("El ID del producto es requerido");
        }

        if (resena.getIdUsuario() == null || resena.getIdUsuario() <= 0) {
            throw new ServiceException("El ID del usuario es requerido");
        }

        if (resena.getCalificacion() == null) {
            throw new ServiceException("La calificación es requerida");
        }

        if (resena.getCalificacion() < 1 || resena.getCalificacion() > 5) {
            throw new ServiceException("La calificación debe estar entre 1 y 5 estrellas");
        }

        if (resena.getComentario() != null && resena.getComentario().length() > 1000) {
            throw new ServiceException("El comentario es demasiado largo (máximo 1000 caracteres)");
        }
    }

    /**
     * Sanitiza el comentario para evitar HTML/scripts maliciosos
     */
    private String sanitizarComentario(String comentario) {
        if (comentario == null) {
            return null;
        }

        // Eliminar tags HTML
        comentario = comentario.replaceAll("<[^>]*>", "");

        // Eliminar espacios múltiples
        comentario = comentario.replaceAll("\\s+", " ");

        // Trim
        comentario = comentario.trim();

        return comentario;
    }

    /**
     * Verifica si un usuario ha comprado un producto
     * ✅ CORREGIDO: Usa String en lugar de enum
     */
    private boolean haCompradoProducto(int idUsuario, int idProducto) throws SQLException {
        List<DetallePedido> detalles = detalleDAO.obtenerPorProducto(idProducto);

        for (DetallePedido detalle : detalles) {
            Optional<Pedido> pedidoOpt = pedidoDAO.buscarPorId(detalle.getIdPedido());

            if (pedidoOpt.isPresent()) {
                Pedido pedido = pedidoOpt.get();

                // Verificar que el pedido pertenece al usuario
                if (pedido.getIdUsuario() == idUsuario) {
                    // ✅ CORREGIDO: Usar String en lugar de enum
                    if ("ENTREGADO".equals(pedido.getEstado())) {
                        return true;
                    }
                }
            }
        }

        return false;
    }

    // ==================== CLASES INTERNAS ====================

    /**
     * Clase para manejar reseñas con paginación
     */
    public static class ResenasPaginadas {
        private final List<Resena> resenas;
        private final int totalResenas;
        private final int paginaActual;
        private final int totalPaginas;
        private final double promedioCalificacion;
        private final int[] distribucionEstrellas;

        public ResenasPaginadas(List<Resena> resenas, int totalResenas,
                                int paginaActual, int totalPaginas,
                                double promedioCalificacion, int[] distribucionEstrellas) {
            this.resenas = resenas;
            this.totalResenas = totalResenas;
            this.paginaActual = paginaActual;
            this.totalPaginas = totalPaginas;
            this.promedioCalificacion = promedioCalificacion;
            this.distribucionEstrellas = distribucionEstrellas;
        }

        public List<Resena> getResenas() { return resenas; }
        public int getTotalResenas() { return totalResenas; }
        public int getPaginaActual() { return paginaActual; }
        public int getTotalPaginas() { return totalPaginas; }
        public double getPromedioCalificacion() { return promedioCalificacion; }
        public int[] getDistribucionEstrellas() { return distribucionEstrellas; }
        public boolean tienePaginaAnterior() { return paginaActual > 1; }
        public boolean tienePaginaSiguiente() { return paginaActual < totalPaginas; }
    }

    /**
     * Clase para estadísticas de reseñas
     */
    public static class EstadisticasResenas {
        private final int totalResenas;
        private final double promedioCalificacion;
        private final int[] distribucionEstrellas;

        public EstadisticasResenas(int totalResenas, double promedioCalificacion,
                                   int[] distribucionEstrellas) {
            this.totalResenas = totalResenas;
            this.promedioCalificacion = promedioCalificacion;
            this.distribucionEstrellas = distribucionEstrellas;
        }

        public int getTotalResenas() { return totalResenas; }
        public double getPromedioCalificacion() { return promedioCalificacion; }
        public int[] getDistribucionEstrellas() { return distribucionEstrellas; }

        public int getEstrellas5() { return distribucionEstrellas[4]; }
        public int getEstrellas4() { return distribucionEstrellas[3]; }
        public int getEstrellas3() { return distribucionEstrellas[2]; }
        public int getEstrellas2() { return distribucionEstrellas[1]; }
        public int getEstrellas1() { return distribucionEstrellas[0]; }

        public int getPorcentajeEstrellas(int estrellas) {
            if (totalResenas == 0) return 0;
            return (int) ((distribucionEstrellas[estrellas - 1] * 100.0) / totalResenas);
        }
    }

    /**
     * Clase para verificación de permisos de reseña
     */
    public static class VerificacionResena {
        private final boolean puede;
        private final String mensaje;

        public VerificacionResena(boolean puede, String mensaje) {
            this.puede = puede;
            this.mensaje = mensaje;
        }

        public boolean isPuede() { return puede; }
        public String getMensaje() { return mensaje; }
    }
}