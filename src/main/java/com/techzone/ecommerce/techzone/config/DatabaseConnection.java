package com.techzone.ecommerce.techzone.config;

import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;

/**
 * Clase para gestionar la conexión a la base de datos MySQL
 * Implementa el patrón Singleton
 *
 * @author TechZone Team
 * @version 1.0
 */
public class DatabaseConnection {

    private static DatabaseConnection instance;
    private Connection connection;
    private String url;
    private String user;
    private String password;
    private String driver;

    /**
     * Constructor privado para el patrón Singleton
     */
    private DatabaseConnection() {
        try {
            // Cargar propiedades desde db.properties
            loadProperties();

            // Cargar el driver de MySQL
            Class.forName(driver);

            System.out.println("✅ Driver MySQL cargado correctamente");

        } catch (ClassNotFoundException e) {
            System.err.println("❌ Error: Driver MySQL no encontrado");
            e.printStackTrace();
        } catch (IOException e) {
            System.err.println("❌ Error: No se pudo cargar db.properties");
            e.printStackTrace();
        }
    }

    /**
     * Cargar propiedades desde el archivo db.properties
     */
    private void loadProperties() throws IOException {
        Properties props = new Properties();

        // Intentar cargar desde resources
        try (InputStream input = getClass().getClassLoader()
                .getResourceAsStream("db.properties")) {

            if (input == null) {
                System.err.println("❌ Error: Archivo db.properties no encontrado");
                throw new IOException("db.properties no encontrado en resources");
            }

            props.load(input);

            // Asignar valores
            this.url = props.getProperty("db.url");
            this.user = props.getProperty("db.user");
            this.password = props.getProperty("db.password");
            this.driver = props.getProperty("db.driver");

            System.out.println("✅ Propiedades de BD cargadas correctamente");
            System.out.println("📍 URL: " + this.url);
            System.out.println("👤 Usuario: " + this.user);

        }
    }

    /**
     * Obtener la instancia única de DatabaseConnection (Singleton)
     *
     * @return Instancia de DatabaseConnection
     */
    public static DatabaseConnection getInstance() {
        if (instance == null) {
            synchronized (DatabaseConnection.class) {
                if (instance == null) {
                    instance = new DatabaseConnection();
                }
            }
        }
        return instance;
    }

    /**
     * Obtener una conexión a la base de datos
     *
     * @return Objeto Connection
     * @throws SQLException Si hay error en la conexión
     */
    public Connection getConnection() throws SQLException {
        if (connection == null || connection.isClosed()) {
            try {
                connection = DriverManager.getConnection(url, user, password);
                System.out.println("✅ Conexión establecida con la base de datos");
            } catch (SQLException e) {
                System.err.println("❌ Error al conectar con la base de datos");
                System.err.println("   URL: " + url);
                System.err.println("   Usuario: " + user);
                throw e;
            }
        }
        return connection;
    }

    /**
     * Cerrar la conexión a la base de datos
     */
    public void closeConnection() {
        try {
            if (connection != null && !connection.isClosed()) {
                connection.close();
                System.out.println("✅ Conexión cerrada correctamente");
            }
        } catch (SQLException e) {
            System.err.println("❌ Error al cerrar la conexión");
            e.printStackTrace();
        }
    }

    /**
     * Verificar si la conexión está activa
     *
     * @return true si está activa, false si no
     */
    public boolean isConnectionValid() {
        try {
            return connection != null && !connection.isClosed() && connection.isValid(2);
        } catch (SQLException e) {
            return false;
        }
    }

    /**
     * Método para probar la conexión
     *
     * @return true si la conexión es exitosa
     */
    public boolean testConnection() {
        try {
            Connection conn = getConnection();
            if (conn != null && !conn.isClosed()) {
                System.out.println("✅ Test de conexión EXITOSO");
                System.out.println("   Database: " + conn.getCatalog());
                return true;
            }
        } catch (SQLException e) {
            System.err.println("❌ Test de conexión FALLIDO");
            e.printStackTrace();
        }
        return false;
    }
}