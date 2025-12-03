package com.techzone.ecommerce.techzone.model;

import java.io.Serializable;
import java.time.LocalDateTime;
import java.util.Objects;

public class Usuario implements Serializable {

    private static final long serialVersionUID = 1L;

    private Integer idUsuario;
    private String nombre;
    private String apellido;
    private String email;
    private String password;
    private RolUsuario rol;
    private EstadoUsuario estado;
    private LocalDateTime fechaRegistro;
    private String telefono;
    private String direccion;

    public enum RolUsuario {
        ADMIN, CLIENTE, VENDEDOR
    }

    public enum EstadoUsuario {
        ACTIVO, INACTIVO, SUSPENDIDO
    }

    // Constructor vacío
    public Usuario() {
        this.fechaRegistro = LocalDateTime.now();
        this.estado = EstadoUsuario.ACTIVO;
    }

    // Constructor con parámetros principales
    public Usuario(String nombre, String apellido, String email, String password, RolUsuario rol) {
        this();
        this.nombre = nombre;
        this.apellido = apellido;
        this.email = email;
        this.password = password;
        this.rol = rol;
    }

    // Getters y Setters
    public Integer getIdUsuario() {
        return idUsuario;
    }

    public void setIdUsuario(Integer idUsuario) {
        this.idUsuario = idUsuario;
    }

    public String getNombre() {
        return nombre;
    }

    public void setNombre(String nombre) {
        this.nombre = nombre;
    }

    public String getApellido() {
        return apellido;
    }

    public void setApellido(String apellido) {
        this.apellido = apellido;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public RolUsuario getRol() {
        return rol;
    }

    public void setRol(RolUsuario rol) {
        this.rol = rol;
    }

    public EstadoUsuario getEstado() {
        return estado;
    }

    public void setEstado(EstadoUsuario estado) {
        this.estado = estado;
    }

    public LocalDateTime getFechaRegistro() {
        return fechaRegistro;
    }

    public void setFechaRegistro(LocalDateTime fechaRegistro) {
        this.fechaRegistro = fechaRegistro;
    }

    public String getTelefono() {
        return telefono;
    }

    public void setTelefono(String telefono) {
        this.telefono = telefono;
    }

    public String getDireccion() {
        return direccion;
    }

    public void setDireccion(String direccion) {
        this.direccion = direccion;
    }

    // Método auxiliar para obtener el nombre completo
    public String getNombreCompleto() {
        return nombre + " " + apellido;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        Usuario usuario = (Usuario) o;
        return Objects.equals(idUsuario, usuario.idUsuario) &&
                Objects.equals(email, usuario.email);
    }

    @Override
    public int hashCode() {
        return Objects.hash(idUsuario, email);
    }

    @Override
    public String toString() {
        return "Usuario{" +
                "idUsuario=" + idUsuario +
                ", nombre='" + nombre + '\'' +
                ", apellido='" + apellido + '\'' +
                ", email='" + email + '\'' +
                ", rol=" + rol +
                ", estado=" + estado +
                '}';
    }
}