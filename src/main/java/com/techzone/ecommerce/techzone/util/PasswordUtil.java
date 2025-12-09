package com.techzone.ecommerce.techzone.util;

import org.mindrot.jbcrypt.BCrypt;

/**
 * Utilidad para manejo seguro de contraseñas usando BCrypt
 * @author TechZone Team
 */
public class PasswordUtil {

    // Número de rondas de hashing (más alto = más seguro pero más lento)
    private static final int ROUNDS = 12;

    /**
     * Genera un hash seguro de la contraseña
     * @param plainTextPassword Contraseña en texto plano
     * @return Hash BCrypt de la contraseña
     */
    public static String hashPassword(String plainTextPassword) {
        if (plainTextPassword == null || plainTextPassword.isEmpty()) {
            throw new IllegalArgumentException("La contraseña no puede estar vacía");
        }

        return BCrypt.hashpw(plainTextPassword, BCrypt.gensalt(ROUNDS));
    }

    /**
     * Verifica si una contraseña coincide con un hash
     * @param plainTextPassword Contraseña en texto plano
     * @param hashedPassword Hash almacenado
     * @return true si la contraseña es correcta
     */
    public static boolean checkPassword(String plainTextPassword, String hashedPassword) {
        if (plainTextPassword == null || hashedPassword == null) {
            return false;
        }

        try {
            return BCrypt.checkpw(plainTextPassword, hashedPassword);
        } catch (Exception e) {
            // Si hay error al verificar (hash inválido), retornar false
            return false;
        }
    }

    /**
     * Constructor privado para prevenir instanciación
     */
    private PasswordUtil() {
        throw new UnsupportedOperationException("Clase de utilidad, no instanciar");
    }
}