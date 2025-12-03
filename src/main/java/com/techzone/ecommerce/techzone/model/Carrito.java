package com.techzone.ecommerce.techzone.model;

import java.io.Serializable;
import java.time.LocalDateTime;
import java.util.Objects;

public class Carrito implements Serializable {

    private static final long serialVersionUID = 1L;

    private Integer idCarrito;
    private Integer idUsuario;
    private Integer idProducto;
    private Integer cantidad;
    private LocalDateTime fechaAgregado;

    // Campos adicionales para joins (no se guardan en DB)
    private transient Usuario usuario;
    private transient Producto producto;

    public Carrito() {
        this.fechaAgregado = LocalDateTime.now();
    }

    public Carrito(Integer idUsuario, Integer idProducto, Integer cantidad) {
        this();
        this.idUsuario = idUsuario;
        this.idProducto = idProducto;
        this.cantidad = cantidad;
    }

    // Getters y Setters
    public Integer getIdCarrito() {
        return idCarrito;
    }

    public void setIdCarrito(Integer idCarrito) {
        this.idCarrito = idCarrito;
    }

    public Integer getIdUsuario() {
        return idUsuario;
    }

    public void setIdUsuario(Integer idUsuario) {
        this.idUsuario = idUsuario;
    }

    public Integer getIdProducto() {
        return idProducto;
    }

    public void setIdProducto(Integer idProducto) {
        this.idProducto = idProducto;
    }

    public Integer getCantidad() {
        return cantidad;
    }

    public void setCantidad(Integer cantidad) {
        this.cantidad = cantidad;
    }

    public LocalDateTime getFechaAgregado() {
        return fechaAgregado;
    }

    public void setFechaAgregado(LocalDateTime fechaAgregado) {
        this.fechaAgregado = fechaAgregado;
    }

    public Usuario getUsuario() {
        return usuario;
    }

    public void setUsuario(Usuario usuario) {
        this.usuario = usuario;
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
        Carrito carrito = (Carrito) o;
        return Objects.equals(idCarrito, carrito.idCarrito);
    }

    @Override
    public int hashCode() {
        return Objects.hash(idCarrito);
    }

    @Override
    public String toString() {
        return "Carrito{" +
                "idCarrito=" + idCarrito +
                ", cantidad=" + cantidad +
                ", fechaAgregado=" + fechaAgregado +
                '}';
    }
}