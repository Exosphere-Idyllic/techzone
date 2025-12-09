package com.techzone.ecommerce.techzone.model;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Objects;

/**
 * Modelo de entidad Producto
 * Representa un producto en el sistema de e-commerce
 *
 * @author TechZone Team
 * @version 2.1 - Agregado campo precioOriginal para mostrar descuentos
 */
public class Producto implements Serializable {

    private static final long serialVersionUID = 1L;

    // ==================== CAMPOS DE BASE DE DATOS ====================

    /** ID único del producto (Primary Key) */
    private Integer idProducto;

    /** ID de la categoría a la que pertenece (Foreign Key) */
    private Integer idCategoria;

    /** Nombre del producto */
    private String nombre;

    /** Descripción detallada del producto */
    private String descripcion;

    /** Precio base del producto sin descuento */
    private BigDecimal precio;

    /** Cantidad disponible en inventario */
    private Integer stock;

    /** Marca del producto */
    private String marca;

    /** Modelo específico del producto */
    private String modelo;

    /** Especificaciones técnicas en formato texto */
    private String especificaciones;

    /** Estado actual del producto (DISPONIBLE, AGOTADO, DESCONTINUADO) */
    private EstadoProducto estado;

    /** Fecha y hora de registro del producto */
    private LocalDateTime fechaRegistro;

    /** Porcentaje de descuento (0-100) */
    private BigDecimal descuento;

    // ==================== CAMPOS TRANSIENT (NO SE PERSISTEN EN DB) ====================

    /**
     * URL/ruta de la imagen principal del producto
     * Se llena dinámicamente desde la tabla imagenes_productos
     * Facilita el acceso rápido desde JSP sin iterar la lista de imágenes
     */
    private transient String imagenPrincipal;

    /**
     * Lista completa de todas las imágenes del producto
     * Se carga mediante JOIN o consulta batch optimizada
     * Útil para galerías de productos
     */
    private transient List<Imagen> imagenes;

    /**
     * Objeto Categoria completo asociado al producto
     * Se carga mediante JOIN para evitar queries adicionales (N+1)
     * Permite acceder a categoria.nombre sin consultas extra
     */
    private transient Categoria categoria;

    /**
     * Promedio de calificaciones del producto (escala 1-5)
     * Calculado desde la tabla reseñas/calificaciones
     * Campo calculado, no almacenado directamente
     */
    private transient Double promedioCalificacion;

    /**
     * Cantidad total de calificaciones/reseñas recibidas
     * Usado para mostrar "basado en X opiniones"
     */
    private transient Integer totalCalificaciones;

    /**
     * ✅ NUEVO: Precio original antes del descuento
     * Este campo se calcula automáticamente y es igual al precio base
     * cuando hay descuento. Si no hay descuento, es null.
     * Útil para mostrar "precio tachado" en la UI
     */
    private transient BigDecimal precioOriginal;

    // ==================== ENUM ====================

    /**
     * Estados posibles de un producto
     */
    public enum EstadoProducto {
        /** Producto disponible para compra */
        DISPONIBLE,

        /** Producto sin stock disponible */
        AGOTADO,

        /** Producto ya no se comercializa */
        DESCONTINUADO
    }

    // ==================== CONSTRUCTORES ====================

    /**
     * Constructor por defecto
     * Inicializa valores predeterminados
     */
    public Producto() {
        this.fechaRegistro = LocalDateTime.now();
        this.estado = EstadoProducto.DISPONIBLE;
        this.descuento = BigDecimal.ZERO;
    }

    /**
     * Constructor con campos esenciales
     *
     * @param nombre Nombre del producto
     * @param precio Precio del producto
     * @param stock Stock inicial
     * @param idCategoria Categoría del producto
     */
    public Producto(String nombre, BigDecimal precio, Integer stock, Integer idCategoria) {
        this();
        this.nombre = nombre;
        this.precio = precio;
        this.stock = stock;
        this.idCategoria = idCategoria;
        // Calcular precio original automáticamente
        this.actualizarPrecioOriginal();
    }

    // ==================== GETTERS Y SETTERS - CAMPOS DB ====================

    public Integer getIdProducto() {
        return idProducto;
    }

    public void setIdProducto(Integer idProducto) {
        this.idProducto = idProducto;
    }

    public Integer getIdCategoria() {
        return idCategoria;
    }

    public void setIdCategoria(Integer idCategoria) {
        this.idCategoria = idCategoria;
    }

    public String getNombre() {
        return nombre;
    }

    public void setNombre(String nombre) {
        this.nombre = nombre;
    }

    public String getDescripcion() {
        return descripcion;
    }

    public void setDescripcion(String descripcion) {
        this.descripcion = descripcion;
    }

    public BigDecimal getPrecio() {
        return precio;
    }

    public void setPrecio(BigDecimal precio) {
        this.precio = precio;
        // Al cambiar el precio, actualizar precio original
        this.actualizarPrecioOriginal();
    }

    public Integer getStock() {
        return stock;
    }

    public void setStock(Integer stock) {
        this.stock = stock;
    }

    public String getMarca() {
        return marca;
    }

    public void setMarca(String marca) {
        this.marca = marca;
    }

    public String getModelo() {
        return modelo;
    }

    public void setModelo(String modelo) {
        this.modelo = modelo;
    }

    public String getEspecificaciones() {
        return especificaciones;
    }

    public void setEspecificaciones(String especificaciones) {
        this.especificaciones = especificaciones;
    }

    public EstadoProducto getEstado() {
        return estado;
    }

    public void setEstado(EstadoProducto estado) {
        this.estado = estado;
    }

    public LocalDateTime getFechaRegistro() {
        return fechaRegistro;
    }

    public void setFechaRegistro(LocalDateTime fechaRegistro) {
        this.fechaRegistro = fechaRegistro;
    }

    public BigDecimal getDescuento() {
        return descuento;
    }

    public void setDescuento(BigDecimal descuento) {
        this.descuento = descuento;
        // Al cambiar el descuento, actualizar precio original
        this.actualizarPrecioOriginal();
    }

    // ==================== GETTERS Y SETTERS - CAMPOS TRANSIENT ====================

    public Categoria getCategoria() {
        return categoria;
    }

    public void setCategoria(Categoria categoria) {
        this.categoria = categoria;
    }

    public String getImagenPrincipal() {
        return imagenPrincipal;
    }

    public void setImagenPrincipal(String imagenPrincipal) {
        this.imagenPrincipal = imagenPrincipal;
    }

    public List<Imagen> getImagenes() {
        return imagenes;
    }

    /**
     * Establece la lista de imágenes del producto
     * Auto-establece imagenPrincipal si no está definida
     *
     * @param imagenes Lista de imágenes del producto
     */
    public void setImagenes(List<Imagen> imagenes) {
        this.imagenes = imagenes;
        // Auto-establecer la imagen principal si no está definida
        if (this.imagenPrincipal == null && imagenes != null && !imagenes.isEmpty()) {
            establecerImagenPrincipalDesdeImagenes();
        }
    }

    public Double getPromedioCalificacion() {
        return promedioCalificacion;
    }

    public void setPromedioCalificacion(Double promedioCalificacion) {
        this.promedioCalificacion = promedioCalificacion;
    }

    public Integer getTotalCalificaciones() {
        return totalCalificaciones;
    }

    public void setTotalCalificaciones(Integer totalCalificaciones) {
        this.totalCalificaciones = totalCalificaciones;
    }

    /**
     * ✅ NUEVO: Obtiene el precio original (antes del descuento)
     * 
     * @return Precio original o null si no hay descuento
     */
    public BigDecimal getPrecioOriginal() {
        return precioOriginal;
    }

    /**
     * ✅ NUEVO: Establece el precio original manualmente
     * Normalmente no es necesario ya que se calcula automáticamente
     * 
     * @param precioOriginal Precio original
     */
    public void setPrecioOriginal(BigDecimal precioOriginal) {
        this.precioOriginal = precioOriginal;
    }

    // ==================== MÉTODOS DE NEGOCIO ====================

    /**
     * ✅ ACTUALIZADO: Calcula el precio final con descuento aplicado
     * También actualiza el campo precioOriginal automáticamente
     *
     * @return Precio con descuento aplicado
     */
    public BigDecimal getPrecioConDescuento() {
        if (descuento != null && descuento.compareTo(BigDecimal.ZERO) > 0) {
            // Convertir porcentaje a decimal (ej: 15% -> 0.15)
            BigDecimal descuentoDecimal = descuento.divide(new BigDecimal("100"));
            // Calcular monto de descuento
            BigDecimal montoDescuento = precio.multiply(descuentoDecimal);
            // Restar del precio base
            return precio.subtract(montoDescuento);
        }
        return precio;
    }

    /**
     * ✅ NUEVO: Actualiza automáticamente el campo precioOriginal
     * Se llama cuando cambia el precio o el descuento
     * Si hay descuento > 0, precioOriginal = precio base
     * Si no hay descuento, precioOriginal = null
     */
    private void actualizarPrecioOriginal() {
        if (descuento != null && descuento.compareTo(BigDecimal.ZERO) > 0) {
            // Si hay descuento, el precio original es el precio sin descuento
            this.precioOriginal = this.precio;
        } else {
            // Si no hay descuento, no hay precio original a mostrar
            this.precioOriginal = null;
        }
    }

    /**
     * Verifica si el producto tiene stock disponible
     *
     * @return true si stock > 0, false en caso contrario
     */
    public boolean tieneStock() {
        return stock != null && stock > 0;
    }

    /**
     * Verifica si el producto tiene descuento activo
     *
     * @return true si descuento > 0, false en caso contrario
     */
    public boolean tieneDescuento() {
        return descuento != null && descuento.compareTo(BigDecimal.ZERO) > 0;
    }

    /**
     * ✅ NUEVO: Calcula el monto de ahorro por el descuento
     * 
     * @return Monto ahorrado o BigDecimal.ZERO si no hay descuento
     */
    public BigDecimal getMontoAhorro() {
        if (tieneDescuento()) {
            return precio.subtract(getPrecioConDescuento());
        }
        return BigDecimal.ZERO;
    }

    // ==================== MÉTODOS AUXILIARES - IMÁGENES ====================

    /**
     * Establece automáticamente la imagen principal desde la lista de imágenes
     * Busca la imagen marcada como principal, o usa la primera disponible
     * Se invoca automáticamente al setear la lista de imágenes
     */
    public void establecerImagenPrincipalDesdeImagenes() {
        if (imagenes == null || imagenes.isEmpty()) {
            this.imagenPrincipal = null;
            return;
        }

        // Buscar imagen marcada como principal
        this.imagenPrincipal = imagenes.stream()
                .filter(img -> img.getEsPrincipal() != null && img.getEsPrincipal())
                .findFirst()
                .map(Imagen::getUrlImagen)
                .orElse(imagenes.get(0).getUrlImagen()); // Si no hay principal, usar la primera
    }

    /**
     * Verifica si el producto tiene imágenes cargadas
     *
     * @return true si tiene al menos una imagen
     */
    public boolean tieneImagenes() {
        return imagenes != null && !imagenes.isEmpty();
    }

    /**
     * Obtiene la cantidad total de imágenes del producto
     *
     * @return Número de imágenes o 0 si no tiene
     */
    public int getCantidadImagenes() {
        return imagenes != null ? imagenes.size() : 0;
    }

    /**
     * Obtiene el objeto Imagen completo de la imagen principal
     * No solo la URL, sino el objeto con todos sus datos
     *
     * @return Objeto Imagen principal o null si no hay imágenes
     */
    public Imagen getImagenPrincipalObjeto() {
        if (imagenes == null || imagenes.isEmpty()) {
            return null;
        }

        return imagenes.stream()
                .filter(img -> img.getEsPrincipal() != null && img.getEsPrincipal())
                .findFirst()
                .orElse(imagenes.get(0));
    }

    // ==================== MÉTODOS AUXILIARES - CALIFICACIONES ====================

    /**
     * Verifica si el producto tiene calificaciones
     *
     * @return true si tiene calificaciones y el promedio es mayor a 0
     */
    public boolean tieneCalificaciones() {
        return promedioCalificacion != null && promedioCalificacion > 0;
    }

    /**
     * Obtiene el promedio de calificación redondeado
     * Útil para mostrar estrellas completas en la UI
     *
     * @return Promedio redondeado (1-5) o 0 si no tiene calificaciones
     */
    public int getPromedioRedondeado() {
        return promedioCalificacion != null ? (int) Math.round(promedioCalificacion) : 0;
    }

    /**
     * Obtiene texto descriptivo de la calificación
     *
     * @return Descripción textual de la calificación
     */
    public String getTextoCalificacion() {
        if (promedioCalificacion == null || promedioCalificacion == 0) {
            return "Sin calificaciones";
        }

        if (promedioCalificacion >= 4.5) return "Excelente";
        if (promedioCalificacion >= 3.5) return "Muy bueno";
        if (promedioCalificacion >= 2.5) return "Bueno";
        if (promedioCalificacion >= 1.5) return "Regular";
        return "Mejorable";
    }

    // ==================== EQUALS, HASHCODE Y TOSTRING ====================

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        Producto producto = (Producto) o;
        return Objects.equals(idProducto, producto.idProducto);
    }

    @Override
    public int hashCode() {
        return Objects.hash(idProducto);
    }

    @Override
    public String toString() {
        return "Producto{" +
                "idProducto=" + idProducto +
                ", nombre='" + nombre + '\'' +
                ", precio=" + precio +
                ", stock=" + stock +
                ", estado=" + estado +
                ", descuento=" + descuento +
                '}';
    }
}
