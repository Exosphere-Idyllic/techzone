package com.techzone.ecommerce.techzone.service;

/**
 * Excepción personalizada para errores en la capa de servicio
 *
 * Esta excepción se lanza cuando ocurren errores de lógica de negocio
 * o problemas al procesar operaciones en los servicios.
 *
 * Es una excepción checked (hereda de Exception) que obliga a los métodos
 * a declararla o manejarla explícitamente.
 *
 * @author TechZone Team
 * @version 1.0
 */
/**
 * Excepción personalizada para errores en la capa de servicio
 * @author TechZone Team
 */
public class ServiceException extends Exception {

    public ServiceException(String message) {
        super(message);
    }

    public ServiceException(String message, Throwable cause) {
        super(message, cause);
    }

    public ServiceException(Throwable cause) {
        super(cause);
    }
}