package com.techzone.ecommerce.techzone.model;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.Objects;

public class Producto implements Serializable {

    private static final long serialVersionUID = 1L;

    private Integer idProducto;
    private Integer idCategoria;
    private String nombre;
    private String descripcion;
    private BigDecimal precio;
    private Integer stock;
    private String marca;
    private String modelo;
    private String especificaciones;
    private EstadoProducto estado;
    private LocalDateTime fechaRegistro;
    private BigDecimal descuento;

    // Campo adicional para joins (no se guarda en DB)
    private transient Categoria categoria;

    public enum EstadoProducto {
        DISPONIBLE, AGOTADO, DESCONTINUADO
    }

    public Producto() {
        this.fechaRegistro = LocalDateTime.now();
        this.estado = EstadoProducto.DISPONIBLE;
        this.descuento = BigDecimal.ZERO;
    }

    public Producto(String nombre, BigDecimal precio, Integer stock, Integer idCategoria) {
        this();
        this.nombre = nombre;
        this.precio = precio;
        this.stock = stock;
        this.idCategoria = idCategoria;
    }

    // Getters y Setters
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
    }

    public Categoria getCategoria() {
        return categoria;
    }

    public void setCategoria(Categoria categoria) {
        this.categoria = categoria;
    }

    // Métodos auxiliares
    public BigDecimal getPrecioConDescuento() {
        if (descuento != null && descuento.compareTo(BigDecimal.ZERO) > 0) {
            BigDecimal descuentoDecimal = descuento.divide(new BigDecimal("100"));
            BigDecimal montoDescuento = precio.multiply(descuentoDecimal);
            return precio.subtract(montoDescuento);
        }
        return precio;
    }

    public boolean tieneStock() {
        return stock != null && stock > 0;
    }

    public boolean tieneDescuento() {
        return descuento != null && descuento.compareTo(BigDecimal.ZERO) > 0;
    }

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
                '}';
    }
}