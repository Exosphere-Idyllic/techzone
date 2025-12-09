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
public class ServiceException extends Exception {

    private static final long serialVersionUID = 1L;

    /**
     * Código de error opcional para categorizar el tipo de excepción
     */
    private String errorCode;

    /**
     * Constructor básico con mensaje
     *
     * @param message Mensaje descriptivo del error
     */
    public ServiceException(String message) {
        super(message);
    }

    /**
     * Constructor con mensaje y causa raíz
     * Útil para wrappear excepciones de capas inferiores (DAO, SQL, etc.)
     *
     * @param message Mensaje descriptivo del error
     * @param cause Excepción original que causó este error
     */
    public ServiceException(String message, Throwable cause) {
        super(message, cause);
    }

    /**
     * Constructor con mensaje y código de error
     *
     * @param message Mensaje descriptivo del error
     * @param errorCode Código de error para clasificación
     */
    public ServiceException(String message, String errorCode) {
        super(message);
        this.errorCode = errorCode;
    }

    /**
     * Constructor completo con mensaje, causa y código de error
     *
     * @param message Mensaje descriptivo del error
     * @param cause Excepción original que causó este error
     * @param errorCode Código de error para clasificación
     */
    public ServiceException(String message, Throwable cause, String errorCode) {
        super(message, cause);
        this.errorCode = errorCode;
    }

    /**
     * Obtiene el código de error asociado a esta excepción
     *
     * @return Código de error o null si no se especificó
     */
    public String getErrorCode() {
        return errorCode;
    }

    /**
     * Establece el código de error
     *
     * @param errorCode Código de error
     */
    public void setErrorCode(String errorCode) {
        this.errorCode = errorCode;
    }

    /**
     * Verifica si esta excepción tiene un código de error asociado
     *
     * @return true si tiene código de error, false si no
     */
    public boolean hasErrorCode() {
        return errorCode != null && !errorCode.isEmpty();
    }

    @Override
    public String toString() {
        if (hasErrorCode()) {
            return "ServiceException [" + errorCode + "]: " + getMessage();
        }
        return "ServiceException: " + getMessage();
    }
}