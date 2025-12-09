package com.techzone.ecommerce.techzone.model;

import java.io.Serializable;
import java.time.LocalDateTime;
import java.util.Objects;

/**
 * Modelo para la entidad ImagenProducto
 * Representa las imágenes asociadas a los productos
 *
 * @author TechZone Team
 */
public class Imagen implements Serializable {

    private static final long serialVersionUID = 1L;

    private Integer idImagen;
    private Integer idProducto;
    private String urlImagen;
    private Boolean esPrincipal;
    private Integer orden;
    private LocalDateTime fechaSubida;

    // ==================== CONSTRUCTORES ====================

    public Imagen() {
        this.orden = 0;
        this.esPrincipal = false;
        this.fechaSubida = LocalDateTime.now();
    }

    public Imagen(Integer idProducto, String urlImagen) {
        this();
        this.idProducto = idProducto;
        this.urlImagen = urlImagen;
    }

    public Imagen(Integer idProducto, String urlImagen, Integer orden, Boolean esPrincipal) {
        this.idProducto = idProducto;
        this.urlImagen = urlImagen;
        this.orden = orden;
        this.esPrincipal = esPrincipal;
        this.fechaSubida = LocalDateTime.now();
    }

    // ==================== GETTERS Y SETTERS ====================

    public Integer getIdImagen() {
        return idImagen;
    }

    public void setIdImagen(Integer idImagen) {
        this.idImagen = idImagen;
    }

    public Integer getIdProducto() {
        return idProducto;
    }

    public void setIdProducto(Integer idProducto) {
        this.idProducto = idProducto;
    }

    public String getUrlImagen() {
        return urlImagen;
    }

    public void setUrlImagen(String urlImagen) {
        this.urlImagen = urlImagen;
    }

    public Boolean getEsPrincipal() {
        return esPrincipal;
    }

    public void setEsPrincipal(Boolean esPrincipal) {
        this.esPrincipal = esPrincipal;
    }

    public Integer getOrden() {
        return orden;
    }

    public void setOrden(Integer orden) {
        this.orden = orden;
    }

    public LocalDateTime getFechaSubida() {
        return fechaSubida;
    }

    public void setFechaSubida(LocalDateTime fechaSubida) {
        this.fechaSubida = fechaSubida;
    }

    // ==================== MÉTODOS DE UTILIDAD ====================

    /**
     * Obtiene la URL completa de la imagen con el context path
     */
    public String getUrlCompleta(String contextPath) {
        if (urlImagen == null) {
            return null;
        }
        if (urlImagen.startsWith("http://") || urlImagen.startsWith("https://")) {
            return urlImagen;
        }
        return contextPath + urlImagen;
    }

    /**
     * Verifica si la imagen es válida
     */
    public boolean esValida() {
        return idProducto != null &&
                urlImagen != null && !urlImagen.trim().isEmpty();
    }

    /**
     * Obtiene la extensión del archivo de la URL
     */
    public String getExtension() {
        if (urlImagen == null || !urlImagen.contains(".")) {
            return "";
        }
        return urlImagen.substring(urlImagen.lastIndexOf(".") + 1).toLowerCase();
    }

    /**
     * Verifica si es una imagen válida por extensión
     */
    public boolean esFormatoValido() {
        String ext = getExtension();
        return ext.equals("jpg") || ext.equals("jpeg") ||
                ext.equals("png") || ext.equals("gif") ||
                ext.equals("webp");
    }

    /**
     * Obtiene el nombre del archivo de la URL
     */
    public String getNombreArchivo() {
        if (urlImagen == null || !urlImagen.contains("/")) {
            return urlImagen;
        }
        return urlImagen.substring(urlImagen.lastIndexOf("/") + 1);
    }

    // ==================== EQUALS, HASHCODE Y TOSTRING ====================

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        Imagen imagen = (Imagen) o;
        return Objects.equals(idImagen, imagen.idImagen);
    }

    @Override
    public int hashCode() {
        return Objects.hash(idImagen);
    }

    @Override
    public String toString() {
        return "Imagen{" +
                "idImagen=" + idImagen +
                ", idProducto=" + idProducto +
                ", urlImagen='" + urlImagen + '\'' +
                ", orden=" + orden +
                ", esPrincipal=" + esPrincipal +
                '}';
    }
}