package com.techzone.ecommerce.techzone.config;

import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;
import java.util.logging.Logger;

/**
 * Clase para gestionar la conexión a la base de datos MySQL
 * Implementa el patrón Singleton
 *
 * @author TechZone Team
 * @version 1.0
 */
public class DatabaseConnection {

    private static final Logger LOGGER = Logger.getLogger(DatabaseConnection.class.getName());
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

            LOGGER.info("Driver MySQL cargado correctamente");

        } catch (ClassNotFoundException e) {
            LOGGER.severe("Error: Driver MySQL no encontrado");
            e.printStackTrace();
        } catch (IOException e) {
            LOGGER.severe("Error: No se pudo cargar db.properties");
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
                LOGGER.severe("Error: Archivo db.properties no encontrado");
                throw new IOException("db.properties no encontrado en resources");
            }

            props.load(input);

            // Asignar valores
            this.url = props.getProperty("db.url");
            this.user = props.getProperty("db.user");
            this.password = props.getProperty("db.password");
            this.driver = props.getProperty("db.driver");

            LOGGER.info("Propiedades de BD cargadas correctamente");
            LOGGER.info("URL: " + this.url);
            LOGGER.info("Usuario: " + this.user);

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
     * Reutiliza la conexión existente si está activa
     *
     * @return Objeto Connection
     * @throws SQLException Si hay error en la conexión
     */
    public Connection getConnection() throws SQLException {
        // Verificar si la conexión existe y está activa
        if (connection == null || connection.isClosed() || !connection.isValid(2)) {
            try {
                connection = DriverManager.getConnection(url, user, password);
                LOGGER.info("Conexion establecida con la base de datos");
            } catch (SQLException e) {
                LOGGER.severe("Error al conectar con la base de datos");
                LOGGER.severe("URL: " + url);
                LOGGER.severe("Usuario: " + user);
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
                LOGGER.info("Conexion cerrada correctamente");
            }
        } catch (SQLException e) {
            LOGGER.severe("Error al cerrar la conexion");
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
                LOGGER.info("Test de conexion EXITOSO");
                LOGGER.info("Database: " + conn.getCatalog());
                return true;
            }
        } catch (SQLException e) {
            LOGGER.severe("Test de conexion FALLIDO");
            e.printStackTrace();
        }
        return false;
    }
}