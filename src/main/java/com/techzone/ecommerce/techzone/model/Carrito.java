package com.techzone.ecommerce.techzone.model;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * Modelo para representar un item del carrito de compras
 * @author TechZone Team
 */
public class Carrito {

    private int idCarrito;
    private int idUsuario;
    private int idProducto;
    private int cantidad;
    private LocalDateTime fechaAgregado;

    // Relación con Producto (para joins)
    private Producto producto;

    // Constructores
    public Carrito() {
        this.fechaAgregado = LocalDateTime.now();
    }

    public Carrito(int idUsuario, int idProducto, int cantidad) {
        this.idUsuario = idUsuario;
        this.idProducto = idProducto;
        this.cantidad = cantidad;
        this.fechaAgregado = LocalDateTime.now();
    }

    // Métodos de cálculo

    /**
     * Calcula el subtotal del item (precio x cantidad)
     */
    public BigDecimal getSubtotal() {
        if (producto != null) {
            BigDecimal precioUnitario = producto.getPrecio();

            // Aplicar descuento si existe
            if (producto.getDescuento() != null && producto.getDescuento().compareTo(BigDecimal.ZERO) > 0) {
                BigDecimal descuento = precioUnitario.multiply(producto.getDescuento())
                        .divide(new BigDecimal(100));
                precioUnitario = precioUnitario.subtract(descuento);
            }

            return precioUnitario.multiply(new BigDecimal(cantidad));
        }
        return BigDecimal.ZERO;
    }

    /**
     * Obtiene el precio unitario con descuento aplicado
     */
    public BigDecimal getPrecioUnitarioConDescuento() {
        if (producto != null) {
            BigDecimal precioUnitario = producto.getPrecio();

            if (producto.getDescuento() != null && producto.getDescuento().compareTo(BigDecimal.ZERO) > 0) {
                BigDecimal descuento = precioUnitario.multiply(producto.getDescuento())
                        .divide(new BigDecimal(100));
                precioUnitario = precioUnitario.subtract(descuento);
            }

            return precioUnitario;
        }
        return BigDecimal.ZERO;
    }

    // Getters y Setters

    public int getIdCarrito() {
        return idCarrito;
    }

    public void setIdCarrito(int idCarrito) {
        this.idCarrito = idCarrito;
    }

    public int getIdUsuario() {
        return idUsuario;
    }

    public void setIdUsuario(int idUsuario) {
        this.idUsuario = idUsuario;
    }

    public int getIdProducto() {
        return idProducto;
    }

    public void setIdProducto(int idProducto) {
        this.idProducto = idProducto;
    }

    public int getCantidad() {
        return cantidad;
    }

    public void setCantidad(int cantidad) {
        this.cantidad = cantidad;
    }

    public LocalDateTime getFechaAgregado() {
        return fechaAgregado;
    }

    public void setFechaAgregado(LocalDateTime fechaAgregado) {
        this.fechaAgregado = fechaAgregado;
    }

    public Producto getProducto() {
        return producto;
    }

    public void setProducto(Producto producto) {
        this.producto = producto;
    }

    @Override
    public String toString() {
        return "Carrito{" +
                "idCarrito=" + idCarrito +
                ", idUsuario=" + idUsuario +
                ", idProducto=" + idProducto +
                ", cantidad=" + cantidad +
                ", fechaAgregado=" + fechaAgregado +
                ", producto=" + (producto != null ? producto.getNombre() : "null") +
                '}';
    }
}