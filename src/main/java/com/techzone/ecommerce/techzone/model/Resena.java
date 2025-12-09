package com.techzone.ecommerce.techzone.model;

import java.io.Serializable;
import java.time.LocalDateTime;
import java.util.Objects;

public class Resena implements Serializable {

    private static final long serialVersionUID = 1L;

    private Integer idResena;
    private Integer idProducto;
    private Integer idUsuario;
    private Integer calificacion;
    private String comentario;
    private LocalDateTime fecha;

    // Campos adicionales para joins (no se guardan en DB)
    private transient Producto producto;
    private transient Usuario usuario;

    public Resena() {
        this.fecha = LocalDateTime.now();
    }

    public Resena(Integer idProducto, Integer idUsuario, Integer calificacion, String comentario) {
        this();
        this.idProducto = idProducto;
        this.idUsuario = idUsuario;
        this.calificacion = calificacion;
        this.comentario = comentario;
    }

    // Getters y Setters
    public Integer getIdResena() {
        return idResena;
    }

    public void setIdResena(Integer idResena) {
        this.idResena = idResena;
    }

    public Integer getIdProducto() {
        return idProducto;
    }

    public void setIdProducto(Integer idProducto) {
        this.idProducto = idProducto;
    }

    public Integer getIdUsuario() {
        return idUsuario;
    }

    public void setIdUsuario(Integer idUsuario) {
        this.idUsuario = idUsuario;
    }

    public Integer getCalificacion() {
        return calificacion;
    }

    public void setCalificacion(Integer calificacion) {
        // Validar que la calificación esté entre 1 y 5
        if (calificacion != null && (calificacion < 1 || calificacion > 5)) {
            throw new IllegalArgumentException("La calificación debe estar entre 1 y 5");
        }
        this.calificacion = calificacion;
    }

    public String getComentario() {
        return comentario;
    }

    public void setComentario(String comentario) {
        this.comentario = comentario;
    }

    public LocalDateTime getFecha() {
        return fecha;
    }

    public void setFecha(LocalDateTime fecha) {
        this.fecha = fecha;
    }

    public Producto getProducto() {
        return producto;
    }

    public void setProducto(Producto producto) {
        this.producto = producto;
    }

    public Usuario getUsuario() {
        return usuario;
    }

    public void setUsuario(Usuario usuario) {
        this.usuario = usuario;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        Resena resena = (Resena) o;
        return Objects.equals(idResena, resena.idResena);
    }

    @Override
    public int hashCode() {
        return Objects.hash(idResena);
    }

    @Override
    public String toString() {
        return "Resena{" +
                "idResena=" + idResena +
                ", calificacion=" + calificacion +
                ", fecha=" + fecha +
                '}';
    }
}