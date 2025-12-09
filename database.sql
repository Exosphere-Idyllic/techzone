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
-- ========================================
-- SCRIPT COMPLETO DE INSERCIONES
-- BASE DE DATOS: ecommerce_tech
-- ========================================
-- NOTA: Las categorías ya están insertadas
-- Este script incluye: Usuarios, Productos, Imágenes, Pedidos, Detalles y Reseñas

-- ========================================
-- PRODUCTOS - LAPTOPS (20 productos)
-- ========================================
INSERT INTO productos (id_categoria, nombre, descripcion, precio, stock, marca, modelo, especificaciones, descuento) VALUES
                                                                                                                         (1, 'Dell Inspiron 15', 'Laptop versátil para trabajo y entretenimiento', 899.99, 15, 'Dell', 'Inspiron 15 3520', 'Intel Core i5-1235U, 8GB RAM, 256GB SSD, 15.6" FHD', 10.00),
                                                                                                                         (1, 'HP Pavilion 14', 'Laptop compacta y potente', 749.99, 20, 'HP', 'Pavilion 14-dv2000', 'AMD Ryzen 5 5625U, 8GB RAM, 512GB SSD, 14" FHD', 5.00),
                                                                                                                         (1, 'Lenovo ThinkPad E14', 'Laptop profesional para negocios', 1099.99, 10, 'Lenovo', 'ThinkPad E14 Gen 4', 'Intel Core i7-1255U, 16GB RAM, 512GB SSD, 14" FHD', 0.00),
                                                                                                                         (1, 'ASUS VivoBook 15', 'Laptop elegante y asequible', 599.99, 25, 'ASUS', 'VivoBook 15 X515', 'Intel Core i3-1115G4, 8GB RAM, 256GB SSD, 15.6" HD', 15.00),
                                                                                                                         (1, 'Acer Aspire 5', 'Excelente relación calidad-precio', 679.99, 18, 'Acer', 'Aspire 5 A515-57', 'Intel Core i5-1235U, 8GB RAM, 512GB SSD, 15.6" FHD', 8.00),
                                                                                                                         (1, 'MacBook Air M2', 'Ultrabook premium de Apple', 1299.99, 8, 'Apple', 'MacBook Air M2 2023', 'Apple M2 chip, 8GB RAM, 256GB SSD, 13.6" Liquid Retina', 0.00),
                                                                                                                         (1, 'MSI Modern 14', 'Laptop moderna para profesionales', 849.99, 12, 'MSI', 'Modern 14 C12M', 'Intel Core i7-1255U, 16GB RAM, 512GB SSD, 14" FHD', 10.00),
                                                                                                                         (1, 'Huawei MateBook D15', 'Laptop con diseño elegante', 729.99, 14, 'Huawei', 'MateBook D15 2023', 'Intel Core i5-1135G7, 8GB RAM, 512GB SSD, 15.6" FHD', 12.00),
                                                                                                                         (1, 'Samsung Galaxy Book2', 'Laptop ligera y portátil', 999.99, 9, 'Samsung', 'Galaxy Book2 360', 'Intel Core i5-1235U, 8GB RAM, 256GB SSD, 13.3" FHD Touchscreen', 5.00),
                                                                                                                         (1, 'HP Envy 13', 'Laptop premium ultradelgada', 1149.99, 7, 'HP', 'Envy 13-ba1000', 'Intel Core i7-1165G7, 16GB RAM, 512GB SSD, 13.3" FHD', 0.00),
                                                                                                                         (1, 'Lenovo IdeaPad 3', 'Laptop económica y confiable', 499.99, 30, 'Lenovo', 'IdeaPad 3 15ITL6', 'Intel Core i3-1115G4, 4GB RAM, 256GB SSD, 15.6" HD', 20.00),
                                                                                                                         (1, 'Dell XPS 13', 'Ultrabook de alto rendimiento', 1599.99, 5, 'Dell', 'XPS 13 9320', 'Intel Core i7-1260P, 16GB RAM, 512GB SSD, 13.4" FHD+', 0.00),
                                                                                                                         (1, 'ASUS TUF Gaming F15', 'Laptop gaming asequible', 1099.99, 11, 'ASUS', 'TUF Gaming F15 FX507', 'Intel Core i5-11400H, 8GB RAM, 512GB SSD, GTX 1650, 15.6" FHD 144Hz', 15.00),
                                                                                                                         (1, 'Acer Swift 3', 'Laptop ultraportátil', 799.99, 16, 'Acer', 'Swift 3 SF314-512', 'Intel Core i5-1240P, 8GB RAM, 512GB SSD, 14" FHD', 10.00),
                                                                                                                         (1, 'HP ProBook 450', 'Laptop empresarial robusta', 949.99, 13, 'HP', 'ProBook 450 G9', 'Intel Core i5-1235U, 8GB RAM, 256GB SSD, 15.6" FHD', 5.00),
                                                                                                                         (1, 'Lenovo Yoga 7i', 'Laptop convertible 2 en 1', 1199.99, 8, 'Lenovo', 'Yoga 7i 14"', 'Intel Core i7-1255U, 16GB RAM, 512GB SSD, 14" FHD Touchscreen', 0.00),
                                                                                                                         (1, 'ASUS ZenBook 14', 'Ultrabook elegante', 1049.99, 10, 'ASUS', 'ZenBook 14 UX425', 'Intel Core i7-1165G7, 16GB RAM, 512GB SSD, 14" FHD', 8.00),
                                                                                                                         (1, 'MSI Prestige 14', 'Laptop profesional de diseño', 1349.99, 6, 'MSI', 'Prestige 14 Evo A11M', 'Intel Core i7-1185G7, 16GB RAM, 512GB SSD, 14" FHD', 0.00),
                                                                                                                         (1, 'Acer Nitro 5', 'Laptop gaming de entrada', 899.99, 14, 'Acer', 'Nitro 5 AN515-58', 'Intel Core i5-12500H, 8GB RAM, 512GB SSD, RTX 3050, 15.6" FHD 144Hz', 12.00),
                                                                                                                         (1, 'Dell Latitude 5420', 'Laptop empresarial duradera', 1249.99, 7, 'Dell', 'Latitude 5420', 'Intel Core i7-1185G7, 16GB RAM, 512GB SSD, 14" FHD', 0.00);

-- ========================================
-- PRODUCTOS - CELULARES (20 productos)
-- ========================================
INSERT INTO productos (id_categoria, nombre, descripcion, precio, stock, marca, modelo, especificaciones, descuento) VALUES
                                                                                                                         (2, 'iPhone 14 Pro', 'Smartphone premium de Apple', 1199.99, 12, 'Apple', 'iPhone 14 Pro', 'A16 Bionic, 128GB, 6.1" Super Retina XDR, Cámara 48MP', 0.00),
                                                                                                                         (2, 'Samsung Galaxy S23', 'Flagship Android con S Pen', 999.99, 15, 'Samsung', 'Galaxy S23', 'Snapdragon 8 Gen 2, 8GB RAM, 256GB, 6.1" AMOLED, Cámara 50MP', 5.00),
                                                                                                                         (2, 'Xiaomi 13 Pro', 'Smartphone potente y asequible', 799.99, 20, 'Xiaomi', '13 Pro', 'Snapdragon 8 Gen 2, 12GB RAM, 256GB, 6.73" AMOLED, Cámara 50MP', 10.00),
                                                                                                                         (2, 'Google Pixel 7', 'Mejor cámara computacional', 699.99, 18, 'Google', 'Pixel 7', 'Google Tensor G2, 8GB RAM, 128GB, 6.3" OLED, Cámara 50MP', 8.00),
                                                                                                                         (2, 'OnePlus 11', 'Flagship killer 2023', 749.99, 14, 'OnePlus', '11', 'Snapdragon 8 Gen 2, 8GB RAM, 128GB, 6.7" AMOLED 120Hz, Cámara 50MP', 12.00),
                                                                                                                         (2, 'Motorola Edge 40', 'Smartphone elegante y rápido', 599.99, 22, 'Motorola', 'Edge 40', 'MediaTek Dimensity 8020, 8GB RAM, 256GB, 6.55" OLED, Cámara 50MP', 15.00),
                                                                                                                         (2, 'Huawei P60 Pro', 'Fotografía profesional', 899.99, 10, 'Huawei', 'P60 Pro', 'Snapdragon 8+ Gen 1, 8GB RAM, 256GB, 6.67" OLED, Cámara 48MP', 0.00),
                                                                                                                         (2, 'Samsung Galaxy A54', 'Gama media premium', 449.99, 28, 'Samsung', 'Galaxy A54', 'Exynos 1380, 8GB RAM, 128GB, 6.4" AMOLED, Cámara 50MP', 10.00),
                                                                                                                         (2, 'iPhone 13', 'iPhone del año anterior', 799.99, 16, 'Apple', 'iPhone 13', 'A15 Bionic, 128GB, 6.1" Super Retina XDR, Cámara 12MP', 15.00),
                                                                                                                         (2, 'Xiaomi Redmi Note 12 Pro', 'Mejor relación calidad-precio', 349.99, 35, 'Xiaomi', 'Redmi Note 12 Pro', 'MediaTek Dimensity 1080, 8GB RAM, 256GB, 6.67" AMOLED, Cámara 50MP', 20.00),
                                                                                                                         (2, 'Realme GT 3', 'Carga rápida ultrarrápida', 649.99, 12, 'Realme', 'GT 3', 'Snapdragon 8+ Gen 1, 12GB RAM, 256GB, 6.74" AMOLED 144Hz, Cámara 50MP', 8.00),
                                                                                                                         (2, 'OPPO Find X5 Pro', 'Diseño premium con Hasselblad', 999.99, 9, 'OPPO', 'Find X5 Pro', 'Snapdragon 8 Gen 1, 12GB RAM, 256GB, 6.7" AMOLED, Cámara 50MP', 5.00),
                                                                                                                         (2, 'Sony Xperia 1 V', 'Smartphone para creadores', 1299.99, 6, 'Sony', 'Xperia 1 V', 'Snapdragon 8 Gen 2, 12GB RAM, 256GB, 6.5" 4K OLED, Cámara 48MP', 0.00),
                                                                                                                         (2, 'Nothing Phone 2', 'Diseño único transparente', 699.99, 14, 'Nothing', 'Phone 2', 'Snapdragon 8+ Gen 1, 12GB RAM, 256GB, 6.7" OLED 120Hz, Cámara 50MP', 10.00),
                                                                                                                         (2, 'Asus ROG Phone 7', 'Gaming phone definitivo', 1099.99, 7, 'Asus', 'ROG Phone 7', 'Snapdragon 8 Gen 2, 16GB RAM, 512GB, 6.78" AMOLED 165Hz, Cámara 50MP', 0.00),
                                                                                                                         (2, 'Vivo X90 Pro', 'Cámara Zeiss avanzada', 849.99, 11, 'Vivo', 'X90 Pro', 'MediaTek Dimensity 9200, 12GB RAM, 256GB, 6.78" AMOLED, Cámara 50MP', 8.00),
                                                                                                                         (2, 'Honor Magic 5 Pro', 'Flagship asequible', 799.99, 13, 'Honor', 'Magic 5 Pro', 'Snapdragon 8 Gen 2, 12GB RAM, 512GB, 6.81" OLED, Cámara 50MP', 12.00),
                                                                                                                         (2, 'Google Pixel 7a', 'Pixel económico', 499.99, 24, 'Google', 'Pixel 7a', 'Google Tensor G2, 8GB RAM, 128GB, 6.1" OLED 90Hz, Cámara 64MP', 15.00),
                                                                                                                         (2, 'Samsung Galaxy Z Fold 5', 'Smartphone plegable premium', 1799.99, 4, 'Samsung', 'Galaxy Z Fold 5', 'Snapdragon 8 Gen 2, 12GB RAM, 256GB, 7.6" AMOLED plegable, Cámara 50MP', 0.00),
                                                                                                                         (2, 'Xiaomi Poco F5', 'Gaming asequible', 399.99, 26, 'Xiaomi', 'Poco F5', 'Snapdragon 7+ Gen 2, 8GB RAM, 256GB, 6.67" AMOLED 120Hz, Cámara 64MP', 18.00);

-- ========================================
-- PRODUCTOS - ACCESORIOS (15 productos)
-- ========================================
INSERT INTO productos (id_categoria, nombre, descripcion, precio, stock, marca, modelo, especificaciones, descuento) VALUES
                                                                                                                         (3, 'Funda iPhone 14 Pro', 'Protección premium para iPhone', 29.99, 50, 'Apple', 'Silicone Case', 'Silicona líquida, Compatible con MagSafe', 0.00),
                                                                                                                         (3, 'Cargador Rápido 65W', 'Cargador GaN ultracompacto', 39.99, 40, 'Anker', 'PowerPort III', 'GaN, 65W, USB-C PD 3.0, Plegable', 10.00),
                                                                                                                         (3, 'Cable USB-C a Lightning', 'Cable certificado MFi', 19.99, 60, 'Belkin', 'BOOST↑CHARGE', '1.2m, MFi certified, Carga rápida', 5.00),
                                                                                                                         (3, 'Protector de Pantalla', 'Vidrio templado 9H', 14.99, 80, 'Spigen', 'Glas.tR EZ Fit', 'Vidrio templado, Instalación fácil, Anti-huellas', 15.00),
                                                                                                                         (3, 'Soporte para Laptop', 'Elevador ergonómico ajustable', 34.99, 35, 'Rain Design', 'mStand', 'Aluminio, Ajustable, Compatible con 11-17"', 8.00),
                                                                                                                         (3, 'Hub USB-C 7 en 1', 'Adaptador multifunción', 49.99, 28, 'Anker', 'PowerExpand 7-in-1', 'HDMI 4K, USB 3.0 x3, USB-C PD, SD/MicroSD', 12.00),
                                                                                                                         (3, 'Mouse Inalámbrico', 'Mouse ergonómico silencioso', 24.99, 45, 'Logitech', 'M330 Silent Plus', 'Inalámbrico, Silencioso 90%, 24 meses batería', 10.00),
                                                                                                                         (3, 'Teclado Mecánico RGB', 'Teclado gaming premium', 89.99, 22, 'Razer', 'BlackWidow V3', 'Switches mecánicos, RGB Chroma, Cable USB-C', 15.00),
                                                                                                                         (3, 'Webcam Full HD', 'Cámara web para videoconferencias', 59.99, 30, 'Logitech', 'C920 HD Pro', '1080p 30fps, Autofocus, Micrófono estéreo', 8.00),
                                                                                                                         (3, 'Batería Externa 20000mAh', 'Power bank de alta capacidad', 44.99, 38, 'Anker', 'PowerCore 20100', '20000mAh, Carga rápida, 2 puertos USB', 12.00),
                                                                                                                         (3, 'Mica Hidrogel Galaxy S23', 'Protección curva total', 12.99, 55, 'Ringke', 'ID Film', 'Hidrogel, Cobertura completa, Instalación húmeda', 10.00),
                                                                                                                         (3, 'Stylus para iPad', 'Lápiz óptico de precisión', 79.99, 20, 'Apple', 'Apple Pencil 2nd Gen', 'Rechazo de palma, Carga magnética, Presión sensible', 0.00),
                                                                                                                         (3, 'Anillo de Luz LED', 'Ring light para fotografía', 34.99, 25, 'Neewer', 'Ring Light 10"', '10", 3 modos de luz, Control remoto Bluetooth', 15.00),
                                                                                                                         (3, 'Adaptador HDMI a USB-C', 'Conversor de video', 17.99, 42, 'uni', 'USB-C to HDMI', '4K@60Hz, Plug and play, Compatible Thunderbolt 3', 8.00),
                                                                                                                         (3, 'Organizador de Cables', 'Clips de gestión de cables', 9.99, 70, 'JOTO', 'Cable Management', 'Pack de 6, Adhesivo 3M, Múltiples tamaños', 20.00);

-- ========================================
-- PRODUCTOS - GAMING (15 productos)
-- ========================================
INSERT INTO productos (id_categoria, nombre, descripcion, precio, stock, marca, modelo, especificaciones, descuento) VALUES
                                                                                                                         (4, 'PlayStation 5', 'Consola de última generación', 499.99, 8, 'Sony', 'PS5 Standard', '825GB SSD, Ray tracing, 4K 120Hz, DualSense incluido', 0.00),
                                                                                                                         (4, 'Xbox Series X', 'La Xbox más potente', 499.99, 10, 'Microsoft', 'Series X', '1TB SSD, 4K 120fps, Ray tracing, Game Pass compatible', 0.00),
                                                                                                                         (4, 'Nintendo Switch OLED', 'Consola híbrida mejorada', 349.99, 15, 'Nintendo', 'Switch OLED', 'Pantalla OLED 7", 64GB, Dock LAN, Joy-Con incluidos', 5.00),
                                                                                                                         (4, 'Control DualSense', 'Control PS5 con haptic feedback', 69.99, 25, 'Sony', 'DualSense', 'Retroalimentación háptica, Gatillos adaptativos, USB-C', 10.00),
                                                                                                                         (4, 'Headset Gaming Inalámbrico', 'Auriculares 7.1 surround', 149.99, 18, 'SteelSeries', 'Arctis 7P+', 'Inalámbrico 2.4GHz, 30h batería, Compatible PS5/PC', 12.00),
                                                                                                                         (4, 'Silla Gaming Ergonómica', 'Silla profesional reclinable', 299.99, 12, 'Secretlab', 'Titan Evo 2022', 'Cuero PU, Reclinable 165°, Soporte lumbar magnético', 0.00),
                                                                                                                         (4, 'Monitor Gaming 27" 165Hz', 'Panel IPS QHD', 329.99, 14, 'ASUS', 'TUF Gaming VG27AQ', '27" QHD, 165Hz, 1ms, G-Sync Compatible, HDR10', 15.00),
                                                                                                                         (4, 'Teclado Mecánico Gaming', 'Teclado compacto 60%', 119.99, 20, 'Corsair', 'K65 RGB Mini', '60%, Switches Cherry MX Speed, RGB, Cable trenzado', 10.00),
                                                                                                                         (4, 'Mouse Gaming RGB', 'Sensor óptico 25600 DPI', 79.99, 28, 'Logitech', 'G502 HERO', '25600 DPI, 11 botones programables, RGB LIGHTSYNC', 8.00),
                                                                                                                         (4, 'Volante Racing Profesional', 'Fuerza directa 2.5 Nm', 349.99, 7, 'Logitech', 'G923', 'Force feedback, Pedales, Compatible PS5/Xbox/PC', 0.00),
                                                                                                                         (4, 'Capturadora 4K60', 'Graba gameplay en 4K', 199.99, 11, 'Elgato', 'HD60 X', '4K60 HDR10, Pass-through, USB 3.0, OBS compatible', 10.00),
                                                                                                                         (4, 'Micrófono Streaming USB', 'Micrófono condensador cardioide', 129.99, 16, 'Blue', 'Yeti', 'USB, 3 cápsulas, Monitoreo cero latencia, Soporte incluido', 12.00),
                                                                                                                         (4, 'Alfombrilla Gaming XXL', 'Mousepad extendido', 29.99, 35, 'Razer', 'Gigantus V2', '940x410mm, Base antideslizante, Superficie texturizada', 15.00),
                                                                                                                         (4, 'SSD Externo 1TB PS5', 'Almacenamiento extra certificado', 159.99, 13, 'Samsung', '980 PRO NVMe', '1TB, 7000MB/s lectura, Disipador incluido', 8.00),
                                                                                                                         (4, 'Mando Pro Controller', 'Control premium para Switch', 69.99, 22, 'Nintendo', 'Pro Controller', 'Inalámbrico, 40h batería, HD Rumble, NFC', 10.00);

-- ========================================
-- PRODUCTOS - AUDIO (15 productos)
-- ========================================
INSERT INTO productos (id_categoria, nombre, descripcion, precio, stock, marca, modelo, especificaciones, descuento) VALUES
                                                                                                                         (5, 'AirPods Pro 2da Gen', 'Auriculares TWS con ANC', 249.99, 18, 'Apple', 'AirPods Pro 2', 'ANC adaptativo, Audio espacial, H2 chip, 6h batería', 0.00),
                                                                                                                         (5, 'Sony WH-1000XM5', 'Auriculares over-ear premium', 399.99, 12, 'Sony', 'WH-1000XM5', 'ANC líder, LDAC, 30h batería, Plegables', 5.00),
                                                                                                                         (5, 'Samsung Galaxy Buds2 Pro', 'Earbuds con audio 360', 229.99, 20, 'Samsung', 'Galaxy Buds2 Pro', 'ANC, Audio 360, IPX7, 8h batería', 10.00),
                                                                                                                         (5, 'Bose QuietComfort 45', 'Legendaria cancelación de ruido', 329.99, 15, 'Bose', 'QC45', 'ANC premium, 24h batería, Controles táctiles', 8.00),
                                                                                                                         (5, 'JBL Flip 6', 'Parlante portátil resistente', 129.99, 25, 'JBL', 'Flip 6', 'IP67, 12h batería, PartyBoost, USB-C', 12.00),
                                                                                                                         (5, 'Beats Studio Buds', 'Earbuds con diseño compacto', 149.99, 22, 'Beats', 'Studio Buds', 'ANC, Audio espacial, IPX4, 8h batería', 15.00),
                                                                                                                         (5, 'Sennheiser Momentum 4', 'Audiófila con 60h batería', 379.99, 9, 'Sennheiser', 'Momentum 4 Wireless', 'ANC adaptativo, aptX Adaptive, 60h batería', 0.00),
                                                                                                                         (5, 'Soundbar Samsung Q700B', 'Barra de sonido 3.1.2', 549.99, 8, 'Samsung', 'HW-Q700B', '3.1.2 canales, Dolby Atmos, 320W, Subwoofer inalámbrico', 10.00),
                                                                                                                         (5, 'Audífonos Gamer HyperX', 'Headset competitivo', 99.99, 28, 'HyperX', 'Cloud II', '7.1 surround, Micrófono desmontable, Almohadillas memory foam', 15.00),
                                                                                                                         (5, 'Parlante JBL Charge 5', 'Power bank + speaker', 179.99, 17, 'JBL', 'Charge 5', 'IP67, 20h batería, USB charge-out, PartyBoost', 8.00),
                                                                                                                         (5, 'Xiaomi Redmi Buds 4 Pro', 'TWS asequibles con ANC', 79.99, 35, 'Xiaomi', 'Redmi Buds 4 Pro', 'ANC dual, LHDC 4.0, 9h batería, IPX4', 20.00),
                                                                                                                         (5, 'Bose SoundLink Revolve+', 'Parlante 360° premium', 299.99, 11, 'Bose', 'SoundLink Revolve+', 'Sonido 360°, IPX4, 17h batería, Asa integrada', 10.00),
                                                                                                                         (5, 'Audio-Technica ATH-M50x', 'Audífonos de estudio', 169.99, 16, 'Audio-Technica', 'ATH-M50x', 'Monitor profesional, Cable desmontable, 45mm drivers', 5.00),
                                                                                                                         (5, 'Anker Soundcore Life Q30', 'ANC accesible', 79.99, 30, 'Anker', 'Soundcore Life Q30', 'ANC híbrido, 40h batería, App EQ, Hi-Res Audio', 18.00),
                                                                                                                         (5, 'Marshall Emberton II', 'Parlante portátil retro', 169.99, 13, 'Marshall', 'Emberton II', 'True Stereophonic, 30h batería, IP67, Diseño icónico', 12.00);

-- ========================================
-- PRODUCTOS - HARDWARE/SOBREMESA (15 productos)
-- ========================================
INSERT INTO productos (id_categoria, nombre, descripcion, precio, stock, marca, modelo, especificaciones, descuento) VALUES
                                                                                                                         (6, 'Procesador AMD Ryzen 7 5800X', 'CPU de 8 núcleos para gaming', 299.99, 14, 'AMD', 'Ryzen 7 5800X', '8 núcleos, 16 hilos, 3.8GHz base, 4.7GHz boost, AM4', 10.00),
                                                                                                                         (6, 'Intel Core i7-13700K', 'CPU híbrida de 13a gen', 419.99, 10, 'Intel', 'Core i7-13700K', '16 núcleos, 24 hilos, 3.4GHz base, 5.4GHz boost, LGA1700', 5.00),
                                                                                                                         (6, 'Tarjeta Gráfica RTX 4070', 'GPU para gaming 1440p', 599.99, 8, 'NVIDIA', 'GeForce RTX 4070', '12GB GDDR6X, DLSS 3, Ray tracing, PCIe 4.0', 0.00),
                                                                                                                         (6, 'Placa Madre ASUS ROG', 'Motherboard gaming AM4', 249.99, 12, 'ASUS', 'ROG Strix B550-F', 'AM4, PCIe 4.0, WiFi 6, RGB Aura Sync', 8.00),
                                                                                                                         (6, 'Memoria RAM Corsair 32GB', 'Kit DDR4 de alto rendimiento', 129.99, 20, 'Corsair', 'Vengeance RGB Pro', '32GB (2x16GB), DDR4-3600, CL18, RGB', 12.00),
                                                                                                                         (6, 'SSD NVMe Samsung 1TB', 'Almacenamiento ultrarrápido', 99.99, 25, 'Samsung', '980 PRO', '1TB, 7000MB/s lectura, PCIe 4.0 x4, NVMe 1.3c', 15.00),
                                                                                                                         (6, 'Fuente Modular 850W Gold', 'PSU eficiente certificada', 149.99, 16, 'Corsair', 'RM850x', '850W, 80 Plus Gold, Modular, Silenciosa', 10.00),
                                                                                                                         (6, 'Gabinete NZXT H510 Elite', 'Case con vidrio templado', 169.99, 11, 'NZXT', 'H510 Elite', 'ATX, Vidrio templado, RGB, Cable management', 8.00),
                                                                                                                         (6, 'Cooler Líquido AIO 240mm', 'Refrigeración líquida RGB', 119.99, 18, 'Corsair', 'iCUE H100i RGB', '240mm, 2400 RPM, RGB, Compatible Intel/AMD', 12.00),
                                                                                                                         (6, 'Monitor 4K 32" IPS', 'Pantalla profesional UHD', 449.99, 9, 'LG', '32UN880-B', '32" 4K UHD, IPS, HDR10, USB-C, Brazo ergonómico', 10.00),
                                                                                                                         (6, 'Tarjeta de Sonido USB', 'DAC/AMP para audiophiles', 199.99, 13, 'Creative', 'Sound BlasterX G6', 'DAC 32-bit/384kHz, Amp 600Ω, Virtual 7.1', 5.00),
                                                                                                                         (6, 'Disco Duro 4TB', 'HDD para almacenamiento masivo', 89.99, 22, 'Seagate', 'BarraCuda', '4TB, 5400 RPM, 256MB caché, SATA 6Gb/s', 15.00),
                                                                                                                         (6, 'WiFi 6 PCIe Card', 'Tarjeta WiFi de nueva generación', 59.99, 19, 'TP-Link', 'Archer TX55E', 'WiFi 6E, AX3000, Bluetooth 5.2, PCIe', 10.00),
                                                                                                                         (6, 'Kit Ventiladores RGB 120mm', 'Pack de 3 fans con controlador', 69.99, 24, 'Cooler Master', 'MasterFan SF120R', '3x 120mm, RGB ARGB, Control remoto, Silenciosos', 18.00),
                                                                                                                         (6, 'Pasta Térmica Premium', 'Compuesto térmico de alto rendimiento', 12.99, 40, 'Thermal Grizzly', 'Kryonaut', '1g, 12.5 W/mK, No conductiva, Fácil aplicación', 0.00);

-- ========================================
-- IMÁGENES DE PRODUCTOS
-- ========================================

-- LAPTOPS (Productos 1-20) - Inserción manual detallada
INSERT INTO imagenes_producto (id_producto, url_imagen, es_principal, orden) VALUES
                                                                                 (1, '/uploads/laptops/dell-inspiron-15-1.jpg', TRUE, 1),
                                                                                 (1, '/uploads/laptops/dell-inspiron-15-2.jpg', FALSE, 2),
                                                                                 (1, '/uploads/laptops/dell-inspiron-15-3.jpg', FALSE, 3),
                                                                                 (2, '/uploads/laptops/hp-pavilion-14-1.jpg', TRUE, 1),
                                                                                 (2, '/uploads/laptops/hp-pavilion-14-2.jpg', FALSE, 2),
                                                                                 (2, '/uploads/laptops/hp-pavilion-14-3.jpg', FALSE, 3),
                                                                                 (3, '/uploads/laptops/lenovo-thinkpad-e14-1.jpg', TRUE, 1),
                                                                                 (3, '/uploads/laptops/lenovo-thinkpad-e14-2.jpg', FALSE, 2),
                                                                                 (3, '/uploads/laptops/lenovo-thinkpad-e14-3.jpg', FALSE, 3),
                                                                                 (4, '/uploads/laptops/asus-vivobook-15-1.jpg', TRUE, 1),
                                                                                 (4, '/uploads/laptops/asus-vivobook-15-2.jpg', FALSE, 2),
                                                                                 (4, '/uploads/laptops/asus-vivobook-15-3.jpg', FALSE, 3),
                                                                                 (5, '/uploads/laptops/acer-aspire-5-1.jpg', TRUE, 1),
                                                                                 (5, '/uploads/laptops/acer-aspire-5-2.jpg', FALSE, 2),
                                                                                 (5, '/uploads/laptops/acer-aspire-5-3.jpg', FALSE, 3),
                                                                                 (6, '/uploads/laptops/macbook-air-m2-1.jpg', TRUE, 1),
                                                                                 (6, '/uploads/laptops/macbook-air-m2-2.jpg', FALSE, 2),
                                                                                 (6, '/uploads/laptops/macbook-air-m2-3.jpg', FALSE, 3),
                                                                                 (7, '/uploads/laptops/msi-modern-14-1.jpg', TRUE, 1),
                                                                                 (7, '/uploads/laptops/msi-modern-14-2.jpg', FALSE, 2),
                                                                                 (7, '/uploads/laptops/msi-modern-14-3.jpg', FALSE, 3),
                                                                                 (8, '/uploads/laptops/huawei-matebook-d15-1.jpg', TRUE, 1),
                                                                                 (8, '/uploads/laptops/huawei-matebook-d15-2.jpg', FALSE, 2),
                                                                                 (8, '/uploads/laptops/huawei-matebook-d15-3.jpg', FALSE, 3),
                                                                                 (9, '/uploads/laptops/samsung-galaxy-book2-1.jpg', TRUE, 1),
                                                                                 (9, '/uploads/laptops/samsung-galaxy-book2-2.jpg', FALSE, 2),
                                                                                 (9, '/uploads/laptops/samsung-galaxy-book2-3.jpg', FALSE, 3),
                                                                                 (10, '/uploads/laptops/hp-envy-13-1.jpg', TRUE, 1),
                                                                                 (10, '/uploads/laptops/hp-envy-13-2.jpg', FALSE, 2),
                                                                                 (10, '/uploads/laptops/hp-envy-13-3.jpg', FALSE, 3),
                                                                                 (11, '/uploads/laptops/lenovo-ideapad-3-1.jpg', TRUE, 1),
                                                                                 (11, '/uploads/laptops/lenovo-ideapad-3-2.jpg', FALSE, 2),
                                                                                 (11, '/uploads/laptops/lenovo-ideapad-3-3.jpg', FALSE, 3),
                                                                                 (12, '/uploads/laptops/dell-xps-13-1.jpg', TRUE, 1),
                                                                                 (12, '/uploads/laptops/dell-xps-13-2.jpg', FALSE, 2),
                                                                                 (12, '/uploads/laptops/dell-xps-13-3.jpg', FALSE, 3),
                                                                                 (13, '/uploads/laptops/asus-tuf-gaming-f15-1.jpg', TRUE, 1),
                                                                                 (13, '/uploads/laptops/asus-tuf-gaming-f15-2.jpg', FALSE, 2),
                                                                                 (13, '/uploads/laptops/asus-tuf-gaming-f15-3.jpg', FALSE, 3),
                                                                                 (14, '/uploads/laptops/acer-swift-3-1.jpg', TRUE, 1),
                                                                                 (14, '/uploads/laptops/acer-swift-3-2.jpg', FALSE, 2),
                                                                                 (14, '/uploads/laptops/acer-swift-3-3.jpg', FALSE, 3),
                                                                                 (15, '/uploads/laptops/hp-probook-450-1.jpg', TRUE, 1),
                                                                                 (15, '/uploads/laptops/hp-probook-450-2.jpg', FALSE, 2),
                                                                                 (15, '/uploads/laptops/hp-probook-450-3.jpg', FALSE, 3),
                                                                                 (16, '/uploads/laptops/lenovo-yoga-7i-1.jpg', TRUE, 1),
                                                                                 (16, '/uploads/laptops/lenovo-yoga-7i-2.jpg', FALSE, 2),
                                                                                 (16, '/uploads/laptops/lenovo-yoga-7i-3.jpg', FALSE, 3),
                                                                                 (17, '/uploads/laptops/asus-zenbook-14-1.jpg', TRUE, 1),
                                                                                 (17, '/uploads/laptops/asus-zenbook-14-2.jpg', FALSE, 2),
                                                                                 (17, '/uploads/laptops/asus-zenbook-14-3.jpg', FALSE, 3),
                                                                                 (18, '/uploads/laptops/msi-prestige-14-1.jpg', TRUE, 1),
                                                                                 (18, '/uploads/laptops/msi-prestige-14-2.jpg', FALSE, 2),
                                                                                 (18, '/uploads/laptops/msi-prestige-14-3.jpg', FALSE, 3),
                                                                                 (19, '/uploads/laptops/acer-nitro-5-1.jpg', TRUE, 1),
                                                                                 (19, '/uploads/laptops/acer-nitro-5-2.jpg', FALSE, 2),
                                                                                 (19, '/uploads/laptops/acer-nitro-5-3.jpg', FALSE, 3),
                                                                                 (20, '/uploads/laptops/dell-latitude-5420-1.jpg', TRUE, 1),
                                                                                 (20, '/uploads/laptops/dell-latitude-5420-2.jpg', FALSE, 2),
                                                                                 (20, '/uploads/laptops/dell-latitude-5420-3.jpg', FALSE, 3);

-- CELULARES, ACCESORIOS, GAMING, AUDIO Y HARDWARE (Productos 21-100) - Inserción dinámica
INSERT INTO imagenes_producto (id_producto, url_imagen, es_principal, orden)
SELECT
    p.id_producto,
    CONCAT(
            CASE
                WHEN p.id_categoria = 2 THEN '/uploads/celulares/'
                WHEN p.id_categoria = 3 THEN '/uploads/accesorios/'
                WHEN p.id_categoria = 4 THEN '/uploads/gaming/'
                WHEN p.id_categoria = 5 THEN '/uploads/audio/'
                WHEN p.id_categoria = 6 THEN '/uploads/hardware/'
                END,
            LOWER(REPLACE(REPLACE(REPLACE(REPLACE(p.nombre, ' ', '-'), '/', '-'), '+', 'plus'), '"', '')),
            '-', n.num, '.jpg'
    ) as url_imagen,
    CASE WHEN n.num = 1 THEN TRUE ELSE FALSE END as es_principal,
    n.num as orden
FROM productos p
         CROSS JOIN (
    SELECT 1 AS num
    UNION ALL SELECT 2
    UNION ALL SELECT 3
) n
WHERE p.id_categoria IN (2, 3, 4, 5, 6)
ORDER BY p.id_producto, n.num;

-- ========================================
-- PEDIDOS Y DETALLES DE PEDIDO
-- ========================================

-- Pedido 1: Usuario Juan Pérez
INSERT INTO pedidos (id_usuario, total, estado, direccion_envio, metodo_pago)
VALUES (2, 2379.96, 'ENTREGADO', 'Av. Amazonas N34-451, Quito', 'Tarjeta de crédito');

INSERT INTO detalle_pedido (id_pedido, id_producto, cantidad, precio_unitario, subtotal) VALUES
                                                                                             (1, 6, 1, 1299.99, 1299.99),   -- MacBook Air M2
                                                                                             (1, 21, 1, 1199.99, 1199.99),  -- iPhone 14 Pro
                                                                                             (1, 41, 2, 29.99, 59.99),      -- Funda iPhone 14 Pro (x2)
                                                                                             (1, 43, 1, 19.99, 19.99);      -- Cable USB-C a Lightning

-- Pedido 2: Usuario María González
INSERT INTO pedidos (id_usuario, total, estado, direccion_envio, metodo_pago)
VALUES (3, 734.97, 'PROCESANDO', 'Calle García Moreno, Centro Histórico, Quito', 'PayPal');

INSERT INTO detalle_pedido (id_pedido, id_producto, cantidad, precio_unitario, subtotal) VALUES
                                                                                             (2, 4, 1, 599.99, 599.99),     -- ASUS VivoBook 15
                                                                                             (2, 50, 1, 44.99, 44.99),      -- Batería Externa 20000mAh
                                                                                             (2, 47, 1, 24.99, 24.99),      -- Mouse Inalámbrico
                                                                                             (2, 44, 3, 14.99, 44.97),      -- Protector de Pantalla (x3)
                                                                                             (2, 43, 1, 19.99, 19.99);      -- Cable USB-C a Lightning

-- Pedido 3: Usuario Juan Pérez (segundo pedido)
INSERT INTO pedidos (id_usuario, total, estado, direccion_envio, metodo_pago)
VALUES (2, 829.97, 'ENVIADO', 'Av. Amazonas N34-451, Quito', 'Tarjeta de débito');

INSERT INTO detalle_pedido (id_pedido, id_producto, cantidad, precio_unitario, subtotal) VALUES
                                                                                             (3, 56, 1, 499.99, 499.99),    -- PlayStation 5
                                                                                             (3, 59, 1, 69.99, 69.99),      -- Control DualSense
                                                                                             (3, 62, 1, 329.99, 329.99);    -- Monitor Gaming 27" 165Hz

-- Pedido 4: Usuario Carlos Rodríguez
INSERT INTO pedidos (id_usuario, total, estado, direccion_envio, metodo_pago)
VALUES (4, 1248.96, 'PENDIENTE', 'Av. 6 de Diciembre, Quito', 'Transferencia bancaria');

INSERT INTO detalle_pedido (id_pedido, id_producto, cantidad, precio_unitario, subtotal) VALUES
                                                                                             (4, 13, 1, 1099.99, 1099.99),  -- ASUS TUF Gaming F15
                                                                                             (4, 48, 1, 89.99, 89.99),      -- Teclado Mecánico RGB
                                                                                             (4, 47, 1, 24.99, 24.99),      -- Mouse Inalámbrico
                                                                                             (4, 68, 1, 29.99, 29.99);      -- Alfombrilla Gaming XXL

-- Pedido 5: Usuario María González (segundo pedido)
INSERT INTO pedidos (id_usuario, total, estado, direccion_envio, metodo_pago)
VALUES (3, 379.98, 'CANCELADO', 'Calle García Moreno, Centro Histórico, Quito', 'Tarjeta de crédito');

INSERT INTO detalle_pedido (id_pedido, id_producto, cantidad, precio_unitario, subtotal) VALUES
                                                                                             (5, 28, 1, 449.99, 449.99),    -- Samsung Galaxy A54
                                                                                             (5, 75, 1, 129.99, 129.99);    -- JBL Flip 6

-- ========================================
-- RESEÑAS DE PRODUCTOS
-- ========================================

INSERT INTO resenas (id_producto, id_usuario, calificacion, comentario) VALUES
-- Reseñas para MacBook Air M2
(6, 2, 5, 'Excelente laptop, muy rápida y el diseño es hermoso. La batería dura todo el día sin problemas.'),
(6, 3, 5, 'Perfecta para trabajo y uso diario. El chip M2 es increíblemente rápido.'),

-- Reseñas para iPhone 14 Pro
(21, 2, 5, 'El mejor iPhone hasta ahora, la cámara de 48MP es increíble y la Dynamic Island es muy útil.'),
(21, 4, 4, 'Excelente teléfono, aunque el precio es elevado. La calidad justifica la inversión.'),

-- Reseñas para ASUS VivoBook 15
(4, 3, 4, 'Buena laptop por el precio, aunque la pantalla podría ser mejor. Perfecta para estudiantes.'),
(4, 2, 4, 'Relación calidad-precio excelente. Ideal para tareas básicas y multimedia.'),

-- Reseñas para Dell Inspiron 15
(1, 3, 4, 'Cumple con lo esperado para trabajo básico y entretenimiento. Buen desempeño general.'),
(1, 4, 3, 'Buena laptop pero el teclado podría ser mejor. El precio es razonable.'),

-- Reseñas para PlayStation 5
(56, 2, 5, 'La PS5 es increíble, los juegos se ven espectaculares en 4K. El DualSense es revolucionario.'),
(56, 4, 5, 'Consola de nueva generación excepcional. Los tiempos de carga son casi inexistentes.'),

-- Reseñas para Samsung Galaxy S23
(22, 3, 5, 'Mejor Android del mercado. La cámara es excelente y la pantalla es hermosa.'),
(22, 4, 4, 'Muy buen teléfono, rápido y con gran autonomía. El tamaño es perfecto.'),

-- Reseñas para AirPods Pro 2da Gen
(71, 2, 5, 'Los mejores auriculares inalámbricos que he probado. La cancelación de ruido es perfecta.'),
(71, 3, 5, 'Calidad de sonido excepcional y muy cómodos. La batería dura todo el día.'),

-- Reseñas para ASUS TUF Gaming F15
(13, 4, 4, 'Buena laptop gaming por el precio. Corre todos los juegos actuales sin problemas.'),
(13, 2, 4, 'Excelente para gaming en 1080p. Se calienta un poco pero es normal en laptops gaming.'),

-- Reseñas para Monitor Gaming ASUS
(62, 2, 5, 'Monitor excelente para gaming. Los 165Hz hacen una diferencia notable en FPS.'),
(62, 4, 5, 'Calidad de imagen increíble y colores vibrantes. Vale cada centavo.'),

-- Reseñas para Xiaomi Redmi Note 12 Pro
(30, 3, 5, 'Increíble relación calidad-precio. No puedo creer lo que ofrece por este precio.'),
(30, 4, 4, 'Muy buen teléfono económico. La cámara sorprende para el rango de precio.'),

-- Reseñas para Teclado Mecánico Razer
(48, 4, 5, 'Teclado premium con excelente calidad de construcción. Los switches son perfectos.'),
(48, 2, 4, 'Muy buen teclado gaming, aunque un poco ruidoso. La iluminación RGB es espectacular.'),

-- Reseñas para Sony WH-1000XM5
(72, 3, 5, 'Los mejores auriculares con cancelación de ruido del mercado. Comodidad suprema.'),
(72, 2, 5, 'Calidad de audio excepcional. Perfectos para viajes largos y trabajo.'),

-- Reseñas para Procesador AMD Ryzen 7 5800X
(86, 4, 5, 'Excelente procesador para gaming y productividad. Gran rendimiento multinúcleo.'),
(86, 2, 4, 'Muy buen procesador, aunque calienta bastante. Necesita buen cooler.'),

-- Reseñas para RTX 4070
(88, 4, 5, 'Tarjeta gráfica excepcional para 1440p. El DLSS 3 es increíble.'),
(88, 2, 5, 'Rendimiento excelente en todos los juegos actuales. Muy eficiente.'),

-- Reseñas para Lenovo IdeaPad 3
(11, 3, 3, 'Laptop básica económica. Cumple para tareas sencillas pero no esperes maravillas.'),
(11, 4, 3, 'Buena para el precio, aunque un poco lenta para multitarea.');

-- ========================================
-- FIN DEL SCRIPT DE INSERCIONES
-- ========================================

-- Continúa con el resto del script (productos, imágenes, etc.)
-- [El resto del script se mantiene igual...]