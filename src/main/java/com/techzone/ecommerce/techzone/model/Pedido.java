package com.techzone.ecommerce.techzone.model;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.Date;

/**
 * Modelo para representar un pedido
 * @author TechZone Team
 */
public class Pedido {

    private int idPedido;
    private int idUsuario;
    private LocalDateTime fechaPedido;
    private String estado; // PENDIENTE, PROCESANDO, ENVIADO, ENTREGADO, CANCELADO
    private BigDecimal total;
    private String direccionEnvio;
    private String metodoPago;
    private String notas;

    // Relación con Usuario (para joins)
    private Usuario usuario;

    // Constructores
    public Pedido() {
        this.fechaPedido = LocalDateTime.now();
        this.estado = "PENDIENTE";
    }

    public Pedido(int idUsuario, BigDecimal total, String direccionEnvio, String metodoPago) {
        this();
        this.idUsuario = idUsuario;
        this.total = total;
        this.direccionEnvio = direccionEnvio;
        this.metodoPago = metodoPago;
    }

    // Métodos de utilidad

    /**
     * Obtiene la fecha del pedido como Date (para compatibilidad con JSTL)
     */
    public Date getFechaPedidoAsDate() {
        if (fechaPedido != null) {
            return java.sql.Timestamp.valueOf(fechaPedido);
        }
        return null;
    }

    /**
     * Verifica si el pedido se puede cancelar
     */
    public boolean esCancelable() {
        return "PENDIENTE".equals(estado) || "PROCESANDO".equals(estado);
    }

    /**
     * Verifica si el pedido está completado
     */
    public boolean estaCompletado() {
        return "ENTREGADO".equals(estado);
    }

    /**
     * Verifica si el pedido está cancelado
     */
    public boolean estaCancelado() {
        return "CANCELADO".equals(estado);
    }

    /**
     * Obtiene el color del estado para la UI
     */
    public String getColorEstado() {
        switch (estado) {
            case "PENDIENTE":
                return "#ffbb33";
            case "PROCESANDO":
                return "#00d4ff";
            case "ENVIADO":
                return "#0099cc";
            case "ENTREGADO":
                return "#00C851";
            case "CANCELADO":
                return "#ff4444";
            default:
                return "#b0b0b0";
        }
    }

    // Getters y Setters

    public int getIdPedido() {
        return idPedido;
    }

    public void setIdPedido(int idPedido) {
        this.idPedido = idPedido;
    }

    public int getIdUsuario() {
        return idUsuario;
    }

    public void setIdUsuario(int idUsuario) {
        this.idUsuario = idUsuario;
    }

    public LocalDateTime getFechaPedido() {
        return fechaPedido;
    }

    public void setFechaPedido(LocalDateTime fechaPedido) {
        this.fechaPedido = fechaPedido;
    }

    public String getEstado() {
        return estado;
    }

    public void setEstado(String estado) {
        this.estado = estado;
    }

    public BigDecimal getTotal() {
        return total;
    }

    public void setTotal(BigDecimal total) {
        this.total = total;
    }

    public String getDireccionEnvio() {
        return direccionEnvio;
    }

    public void setDireccionEnvio(String direccionEnvio) {
        this.direccionEnvio = direccionEnvio;
    }

    public String getMetodoPago() {
        return metodoPago;
    }

    public void setMetodoPago(String metodoPago) {
        this.metodoPago = metodoPago;
    }

    public String getNotas() {
        return notas;
    }

    public void setNotas(String notas) {
        this.notas = notas;
    }

    public Usuario getUsuario() {
        return usuario;
    }

    public void setUsuario(Usuario usuario) {
        this.usuario = usuario;
    }

    @Override
    public String toString() {
        return "Pedido{" +
                "idPedido=" + idPedido +
                ", idUsuario=" + idUsuario +
                ", fechaPedido=" + fechaPedido +
                ", estado='" + estado + '\'' +
                ", total=" + total +
                ", direccionEnvio='" + direccionEnvio + '\'' +
                ", metodoPago='" + metodoPago + '\'' +
                '}';
    }
}