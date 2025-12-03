package com.techzone.ecommerce.techzone.config;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

/**
 * Clase para probar la conexión a la base de datos
 *
 * @author TechZone Team
 */
public class TestConnection {

    public static void main(String[] args) {
        System.out.println("========================================");
        System.out.println("  TEST DE CONEXIÓN - TechZone E-commerce");
        System.out.println("========================================");

        DatabaseConnection dbConnection = DatabaseConnection.getInstance();

        try {
            // Test 1: Obtener conexión
            System.out.println("📋 Test 1: Obtener conexión...");
            Connection conn = dbConnection.getConnection();

            if (conn != null) {
                System.out.println("✅ Conexión obtenida exitosamente\n");

                // Test 2: Verificar base de datos
                System.out.println("📋 Test 2: Verificar base de datos...");
                System.out.println("   Database: " + conn.getCatalog());
                System.out.println("   Autocommit: " + conn.getAutoCommit());
                System.out.println("✅ Base de datos verificada\n");

                // Test 3: Consulta simple
                System.out.println("📋 Test 3: Ejecutar consulta de prueba...");
                Statement stmt = conn.createStatement();

                // Contar usuarios
                ResultSet rs1 = stmt.executeQuery("SELECT COUNT(*) as total FROM usuarios");
                if (rs1.next()) {
                    System.out.println("   👥 Total usuarios: " + rs1.getInt("total"));
                }

                // Contar productos
                ResultSet rs2 = stmt.executeQuery("SELECT COUNT(*) as total FROM productos");
                if (rs2.next()) {
                    System.out.println("   📦 Total productos: " + rs2.getInt("total"));
                }

                // Contar categorías
                ResultSet rs3 = stmt.executeQuery("SELECT COUNT(*) as total FROM categorias");
                if (rs3.next()) {
                    System.out.println("   🏷  Total categorías: " + rs3.getInt("total"));
                }

                System.out.println("✅ Consultas ejecutadas correctamente\n");

                // Test 4: Listar categorías
                System.out.println("📋 Test 4: Listar categorías...");
                ResultSet rs4 = stmt.executeQuery("SELECT id_categoria, nombre FROM categorias");

                while (rs4.next()) {
                    System.out.println("   " + rs4.getInt("id_categoria") +
                            ". " + rs4.getString("nombre"));
                }

                System.out.println("✅ Categorías listadas correctamente\n");

                // Cerrar recursos
                rs1.close();
                rs2.close();
                rs3.close();
                rs4.close();
                stmt.close();

                System.out.println("========================================");
                System.out.println("  ✅ TODOS LOS TESTS PASARON EXITOSAMENTE");
                System.out.println("========================================");

            } else {
                System.out.println("❌ No se pudo obtener la conexión");
            }

        } catch (SQLException e) {
            System.out.println("\n========================================");
            System.out.println("  ❌ ERROR EN LA CONEXIÓN");
            System.out.println("========================================");
            System.err.println("Mensaje: " + e.getMessage());
            System.err.println("SQL State: " + e.getSQLState());
            System.err.println("Error Code: " + e.getErrorCode());
            e.printStackTrace();
        } finally {
            dbConnection.closeConnection();
        }
    }
}