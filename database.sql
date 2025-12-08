-- ========================================
-- BASE DE DATOS: E-COMMERCE TECNOLÓGICO
-- Script corregido - Usuarios se crean desde Java
-- ========================================

DROP DATABASE IF EXISTS ecommerce_tech;
CREATE DATABASE ecommerce_tech CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE ecommerce_tech;

-- ========================================
-- TABLA: USUARIOS
-- ========================================
CREATE TABLE usuarios (
    id_usuario INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,  -- BCrypt genera hashes de ~60 caracteres
    rol ENUM('ADMIN', 'CLIENTE', 'VENDEDOR') DEFAULT 'CLIENTE',
    estado ENUM('ACTIVO', 'INACTIVO') DEFAULT 'ACTIVO',
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    telefono VARCHAR(20),
    direccion TEXT,
    INDEX idx_email (email),
    INDEX idx_rol (rol)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ========================================
-- TABLA: CATEGORIAS
-- ========================================
CREATE TABLE categorias (
    id_categoria INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    descripcion TEXT,
    estado ENUM('ACTIVO', 'INACTIVO') DEFAULT 'ACTIVO',
    INDEX idx_nombre (nombre)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ========================================
-- TABLA: PRODUCTOS
-- ========================================
CREATE TABLE productos (
    id_producto INT PRIMARY KEY AUTO_INCREMENT,
    id_categoria INT NOT NULL,
    nombre VARCHAR(200) NOT NULL,
    descripcion TEXT,
    precio DECIMAL(10, 2) NOT NULL,
    stock INT DEFAULT 0,
    marca VARCHAR(100),
    modelo VARCHAR(100),
    especificaciones TEXT,
    estado ENUM('DISPONIBLE', 'AGOTADO', 'DESCONTINUADO') DEFAULT 'DISPONIBLE',
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    descuento DECIMAL(5, 2) DEFAULT 0.00,
    FOREIGN KEY (id_categoria) REFERENCES categorias(id_categoria) ON DELETE RESTRICT,
    INDEX idx_categoria (id_categoria),
    INDEX idx_nombre (nombre),
    INDEX idx_precio (precio),
    INDEX idx_estado (estado),
    FULLTEXT idx_busqueda (nombre, descripcion, marca, modelo)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ========================================
-- TABLA: IMAGENES_PRODUCTO
-- ========================================
CREATE TABLE imagenes_producto (
    id_imagen INT PRIMARY KEY AUTO_INCREMENT,
    id_producto INT NOT NULL,
    url_imagen VARCHAR(255) NOT NULL,
    es_principal BOOLEAN DEFAULT FALSE,
    orden INT DEFAULT 0,
    fecha_subida TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_producto) REFERENCES productos(id_producto) ON DELETE CASCADE,
    INDEX idx_producto (id_producto),
    INDEX idx_principal (id_producto, es_principal)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ========================================
-- TABLA: PEDIDOS
-- ========================================
CREATE TABLE pedidos (
    id_pedido INT PRIMARY KEY AUTO_INCREMENT,
    id_usuario INT NOT NULL,
    fecha_pedido TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total DECIMAL(10, 2) NOT NULL,
    estado ENUM('PENDIENTE', 'PROCESANDO', 'ENVIADO', 'ENTREGADO', 'CANCELADO') DEFAULT 'PENDIENTE',
    direccion_envio TEXT NOT NULL,
    metodo_pago VARCHAR(50),
    FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario) ON DELETE RESTRICT,
    INDEX idx_usuario (id_usuario),
    INDEX idx_estado (estado),
    INDEX idx_fecha (fecha_pedido)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ========================================
-- TABLA: DETALLE_PEDIDO
-- ========================================
CREATE TABLE detalle_pedido (
    id_detalle INT PRIMARY KEY AUTO_INCREMENT,
    id_pedido INT NOT NULL,
    id_producto INT NOT NULL,
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(10, 2) NOT NULL,
    subtotal DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (id_pedido) REFERENCES pedidos(id_pedido) ON DELETE CASCADE,
    FOREIGN KEY (id_producto) REFERENCES productos(id_producto) ON DELETE RESTRICT,
    INDEX idx_pedido (id_pedido),
    INDEX idx_producto (id_producto)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ========================================
-- TABLA: CARRITO
-- ========================================
CREATE TABLE carrito (
    id_carrito INT PRIMARY KEY AUTO_INCREMENT,
    id_usuario INT NOT NULL,
    id_producto INT NOT NULL,
    cantidad INT DEFAULT 1,
    fecha_agregado TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario) ON DELETE CASCADE,
    FOREIGN KEY (id_producto) REFERENCES productos(id_producto) ON DELETE CASCADE,
    UNIQUE KEY unique_carrito (id_usuario, id_producto),
    INDEX idx_usuario (id_usuario)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ========================================
-- TABLA: RESEÑAS
-- ========================================
CREATE TABLE resenas (
    id_resena INT PRIMARY KEY AUTO_INCREMENT,
    id_producto INT NOT NULL,
    id_usuario INT NOT NULL,
    calificacion INT NOT NULL CHECK (calificacion BETWEEN 1 AND 5),
    comentario TEXT,
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_producto) REFERENCES productos(id_producto) ON DELETE CASCADE,
    FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario) ON DELETE CASCADE,
    INDEX idx_producto (id_producto),
    INDEX idx_usuario (id_usuario),
    INDEX idx_calificacion (calificacion)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ========================================
-- DATOS INICIALES: CATEGORÍAS
-- ========================================
INSERT INTO categorias (nombre, descripcion, estado) VALUES
('Laptops', 'Computadoras portátiles de diferentes marcas y especificaciones', 'ACTIVO'),
('Celulares', 'Teléfonos inteligentes y smartphones', 'ACTIVO'),
('Accesorios', 'Accesorios para dispositivos electrónicos', 'ACTIVO'),
('Gaming', 'Equipos y accesorios para videojuegos', 'ACTIVO'),
('Audio', 'Auriculares, parlantes y equipos de sonido', 'ACTIVO'),
('Hardware/Sobremesa', 'Componentes y equipos de escritorio', 'ACTIVO');

-- ========================================
-- NOTA IMPORTANTE SOBRE USUARIOS
-- ========================================
-- Los usuarios deben ser creados desde Java usando PasswordUtil.hashPassword()
-- Ejemplo de código Java para crear el usuario admin:
--
-- Usuario admin = new Usuario();
-- admin.setNombre("Admin");
-- admin.setApellido("Sistema");
-- admin.setEmail("admin@ecommerce.com");
-- admin.setPassword(PasswordUtil.hashPassword("admin123"));
-- admin.setRol(Usuario.RolUsuario.ADMIN);
-- usuarioDAO.crear(admin);

-- Continúa con el resto del script (productos, imágenes, etc.)
-- [El resto del script se mantiene igual...]