package com.techzone.ecommerce.techzone.util;

import java.math.BigDecimal;
import java.util.regex.Pattern;

/**
 * Utilidad para validación de datos
 * @author TechZone Team
 */
public class ValidationUtil {

    // Expresiones regulares
    private static final Pattern EMAIL_PATTERN = Pattern.compile(
            "^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
    );

    private static final Pattern PHONE_PATTERN = Pattern.compile(
            "^[0-9\\-\\+\\(\\)\\s]{7,20}$"
    );

    private static final Pattern PASSWORD_PATTERN = Pattern.compile(
            "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d).{8,}$"
    );

    private static final Pattern ALPHANUMERIC_PATTERN = Pattern.compile(
            "^[a-zA-Z0-9]+$"
    );

    /**
     * Valida formato de email
     * @param email Email a validar
     * @return true si el formato es válido
     */
    public static boolean isValidEmail(String email) {
        if (email == null || email.trim().isEmpty()) {
            return false;
        }

        return EMAIL_PATTERN.matcher(email.trim()).matches();
    }

    /**
     * Valida formato de teléfono
     * @param phone Teléfono a validar
     * @return true si el formato es válido
     */
    public static boolean isValidPhone(String phone) {
        if (phone == null || phone.trim().isEmpty()) {
            return false;
        }

        return PHONE_PATTERN.matcher(phone.trim()).matches();
    }

    /**
     * Valida que la contraseña cumpla los requisitos de seguridad:
     * - Al menos 8 caracteres
     * - Al menos una mayúscula
     * - Al menos una minúscula
     * - Al menos un número
     *
     * @param password Contraseña a validar
     * @return true si cumple los requisitos
     */
    public static boolean isValidPassword(String password) {
        if (password == null || password.isEmpty()) {
            return false;
        }

        return PASSWORD_PATTERN.matcher(password).matches();
    }

    /**
     * Valida que una cadena no esté vacía
     * @param value Valor a validar
     * @return true si no es null ni está vacía
     */
    public static boolean isNotEmpty(String value) {
        return value != null && !value.trim().isEmpty();
    }

    /**
     * Valida que una cadena tenga una longitud específica
     * @param value Valor a validar
     * @param minLength Longitud mínima
     * @param maxLength Longitud máxima
     * @return true si la longitud está en el rango
     */
    public static boolean isValidLength(String value, int minLength, int maxLength) {
        if (value == null) {
            return false;
        }

        int length = value.length();
        return length >= minLength && length <= maxLength;
    }

    /**
     * Valida que un número esté en un rango
     * @param value Valor a validar
     * @param min Valor mínimo
     * @param max Valor máximo
     * @return true si está en el rango
     */
    public static boolean isInRange(int value, int min, int max) {
        return value >= min && value <= max;
    }

    /**
     * Valida que un BigDecimal esté en un rango
     * @param value Valor a validar
     * @param min Valor mínimo
     * @param max Valor máximo
     * @return true si está en el rango
     */
    public static boolean isInRange(BigDecimal value, BigDecimal min, BigDecimal max) {
        if (value == null) {
            return false;
        }

        boolean mayorIgualMin = min == null || value.compareTo(min) >= 0;
        boolean menorIgualMax = max == null || value.compareTo(max) <= 0;

        return mayorIgualMin && menorIgualMax;
    }

    /**
     * Sanitiza una cadena removiendo caracteres HTML
     * @param input Cadena a sanitizar
     * @return Cadena sanitizada
     */
    public static String sanitizeHtml(String input) {
        if (input == null) {
            return null;
        }

        // Remover tags HTML
        String sanitized = input.replaceAll("<[^>]*>", "");

        // Remover scripts
        sanitized = sanitized.replaceAll("(?i)<script[^>]*>.*?</script>", "");

        // Escapar caracteres especiales
        sanitized = sanitized.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#x27;")
                .replace("/", "&#x2F;");

        return sanitized.trim();
    }

    /**
     * Valida que un string sea numérico
     * @param str String a validar
     * @return true si es numérico
     */
    public static boolean isNumeric(String str) {
        if (str == null || str.isEmpty()) {
            return false;
        }

        try {
            Integer.parseInt(str);
            return true;
        } catch (NumberFormatException e) {
            return false;
        }
    }

    /**
     * Valida que un string sea numérico decimal
     * @param str String a validar
     * @return true si es numérico decimal
     */
    public static boolean isDecimal(String str) {
        if (str == null || str.isEmpty()) {
            return false;
        }

        try {
            new BigDecimal(str);
            return true;
        } catch (NumberFormatException e) {
            return false;
        }
    }

    /**
     * Valida que una cadena sea alfanumérica
     * @param str String a validar
     * @return true si es alfanumérica
     */
    public static boolean isAlphanumeric(String str) {
        if (str == null || str.isEmpty()) {
            return false;
        }

        return ALPHANUMERIC_PATTERN.matcher(str).matches();
    }

    /**
     * Valida que una URL tenga formato válido
     * @param url URL a validar
     * @return true si es válida
     */
    public static boolean isValidUrl(String url) {
        if (url == null || url.trim().isEmpty()) {
            return false;
        }

        try {
            new java.net.URL(url);
            return true;
        } catch (Exception e) {
            return false;
        }
    }

    /**
     * Valida que una lista no esté vacía
     * @param list Lista a validar
     * @return true si no es null ni está vacía
     */
    public static boolean isNotEmpty(java.util.List<?> list) {
        return list != null && !list.isEmpty();
    }

    /**
     * Convierte string a Integer de forma segura
     * @param str String a convertir
     * @param defaultValue Valor por defecto si falla
     * @return Integer o valor por defecto
     */
    public static Integer toInteger(String str, Integer defaultValue) {
        try {
            return Integer.parseInt(str);
        } catch (NumberFormatException e) {
            return defaultValue;
        }
    }

    /**
     * Convierte string a BigDecimal de forma segura
     * @param str String a convertir
     * @param defaultValue Valor por defecto si falla
     * @return BigDecimal o valor por defecto
     */
    public static BigDecimal toBigDecimal(String str, BigDecimal defaultValue) {
        try {
            return new BigDecimal(str);
        } catch (NumberFormatException e) {
            return defaultValue;
        }
    }

    /**
     * Trunca una cadena a una longitud máxima
     * @param str Cadena a truncar
     * @param maxLength Longitud máxima
     * @return Cadena truncada
     */
    public static String truncate(String str, int maxLength) {
        if (str == null) {
            return null;
        }

        if (str.length() <= maxLength) {
            return str;
        }

        return str.substring(0, maxLength - 3) + "...";
    }

    /**
     * Constructor privado para prevenir instanciación
     */
    private ValidationUtil() {
        throw new UnsupportedOperationException("Clase de utilidad, no instanciar");
    }
}