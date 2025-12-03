package com.techzone.ecommerce.techzone.model;

import java.io.Serializable;
import java.time.LocalDateTime;
import java.util.Objects;

public class ImagenProducto implements Serializable {

    private static final long serialVersionUID = 1L;

    private Integer idImagen;
    private Integer idProducto;
    private String urlImagen;
    private Boolean esPrincipal;
    private Integer orden;
    private LocalDateTime fechaSubida;

    // Campo adicional para joins (no se guarda en DB)
    private transient Producto producto;

    public ImagenProducto() {
        this.fechaSubida = LocalDateTime.now();
        this.esPrincipal = false;
        this.orden = 0;
    }

    public ImagenProducto(Integer idProducto, String urlImagen, Boolean esPrincipal, Integer orden) {
        this();
        this.idProducto = idProducto;
        this.urlImagen = urlImagen;
        this.esPrincipal = esPrincipal;
        this.orden = orden;
    }

    // Getters y Setters
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

    public Producto getProducto() {
        return producto;
    }

    public void setProducto(Producto producto) {
        this.producto = producto;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        ImagenProducto that = (ImagenProducto) o;
        return Objects.equals(idImagen, that.idImagen);
    }

    @Override
    public int hashCode() {
        return Objects.hash(idImagen);
    }

    @Override
    public String toString() {
        return "ImagenProducto{" +
                "idImagen=" + idImagen +
                ", urlImagen='" + urlImagen + '\'' +
                ", esPrincipal=" + esPrincipal +
                ", orden=" + orden +
                '}';
    }
}