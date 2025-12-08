<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>TechZone - Tu Tienda de Tecnología</title>

    <!-- CSS - Usando rutas absolutas desde el contexto -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/sidebar.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/footer.css">

    <style>
        /* Estilos específicos para index */
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
            background-color: #0a0a0a;
            color: #ffffff;
            padding-right: 220px; /* Espacio para sidebar */
        }

        /* Hero Section */
        .hero {
            height: 80vh;
            background: linear-gradient(135deg, #1a1a1a 0%, #2a2a2a 100%);
            display: flex;
            align-items: center;
            justify-content: center;
            text-align: center;
            padding: 40px 20px;
            position: relative;
            overflow: hidden;
        }

        .hero::before {
            content: '';
            position: absolute;
            width: 500px;
            height: 500px;
            background: radial-gradient(circle, rgba(0, 212, 255, 0.1) 0%, transparent 70%);
            top: -250px;
            right: -250px;
            animation: pulse 4s infinite;
        }

        @keyframes pulse {
            0%, 100% { transform: scale(1); opacity: 0.5; }
            50% { transform: scale(1.2); opacity: 0.8; }
        }

        .hero-content {
            max-width: 800px;
            position: relative;
            z-index: 1;
        }

        .hero h1 {
            font-size: 4rem;
            font-weight: 700;
            margin-bottom: 20px;
            background: linear-gradient(135deg, #00d4ff, #0099cc);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }

        .hero p {
            font-size: 1.5rem;
            color: #b0b0b0;
            margin-bottom: 30px;
        }

        .hero-buttons {
            display: flex;
            gap: 20px;
            justify-content: center;
            flex-wrap: wrap;
        }

        .btn {
            padding: 15px 40px;
            border-radius: 10px;
            text-decoration: none;
            font-weight: 600;
            font-size: 1rem;
            transition: all 0.3s ease;
            display: inline-flex;
            align-items: center;
            gap: 10px;
        }

        .btn-primary {
            background: linear-gradient(135deg, #00d4ff, #0099cc);
            color: #000;
            box-shadow: 0 10px 30px rgba(0, 212, 255, 0.3);
        }

        .btn-primary:hover {
            transform: translateY(-3px);
            box-shadow: 0 15px 40px rgba(0, 212, 255, 0.5);
        }

        .btn-secondary {
            background: transparent;
            color: #00d4ff;
            border: 2px solid #00d4ff;
        }

        .btn-secondary:hover {
            background: #00d4ff;
            color: #000;
        }

        /* Sections */
        .section {
            padding: 80px 20px;
            max-width: 1400px;
            margin: 0 auto;
        }

        .section-header {
            text-align: center;
            margin-bottom: 50px;
        }

        .section-title {
            font-size: 2.5rem;
            font-weight: 700;
            margin-bottom: 15px;
        }

        .section-subtitle {
            font-size: 1.1rem;
            color: #b0b0b0;
        }

        /* Products Grid */
        .products-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
            gap: 30px;
        }

        .product-card {
            background: #1a1a1a;
            border: 1px solid #333;
            border-radius: 15px;
            padding: 20px;
            transition: all 0.3s ease;
            cursor: pointer;
        }

        .product-card:hover {
            transform: translateY(-5px);
            border-color: #00d4ff;
            box-shadow: 0 10px 30px rgba(0, 212, 255, 0.2);
        }

        .product-image {
            width: 100%;
            height: 200px;
            background: #2a2a2a;
            border-radius: 10px;
            margin-bottom: 15px;
            display: flex;
            align-items: center;
            justify-content: center;
            overflow: hidden;
        }

        .product-image img {
            max-width: 100%;
            max-height: 100%;
            object-fit: contain;
        }

        .product-info {
            text-align: center;
        }

        .product-name {
            font-size: 1.1rem;
            font-weight: 600;
            margin-bottom: 10px;
            color: #fff;
        }

        .product-price {
            font-size: 1.5rem;
            font-weight: 700;
            color: #00d4ff;
            margin-bottom: 15px;
        }

        .product-btn {
            width: 100%;
            padding: 12px;
            background: linear-gradient(135deg, #00d4ff, #0099cc);
            border: none;
            border-radius: 8px;
            color: #000;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
        }

        .product-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 20px rgba(0, 212, 255, 0.4);
        }

        /* Categories */
        .categories-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
        }

        .category-card {
            background: linear-gradient(135deg, #1a1a1a 0%, #2a2a2a 100%);
            border: 1px solid #333;
            border-radius: 15px;
            padding: 30px;
            text-align: center;
            transition: all 0.3s ease;
            cursor: pointer;
        }

        .category-card:hover {
            transform: scale(1.05);
            border-color: #00d4ff;
        }

        .category-icon {
            width: 60px;
            height: 60px;
            margin: 0 auto 15px;
            background: linear-gradient(135deg, #00d4ff, #0099cc);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .category-icon svg {
            width: 30px;
            height: 30px;
            fill: #000;
        }

        .category-name {
            font-size: 1.2rem;
            font-weight: 600;
            color: #fff;
        }

        /* Responsive */
        @media (max-width: 768px) {
            body {
                padding-right: 0;
            }

            .hero h1 {
                font-size: 2.5rem;
            }

            .hero p {
                font-size: 1.1rem;
            }

            .hero-buttons {
                flex-direction: column;
            }

            .section {
                padding: 50px 15px;
            }

            .section-title {
                font-size: 2rem;
            }

            .products-grid {
                grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
                gap: 20px;
            }
        }
    </style>
</head>
<body>
<!-- Sidebar/Header -->
<jsp:include page="/views/components/header.jsp" />

<!-- Hero Section -->
<section class="hero">
    <div class="hero-content">
        <h1>TECH<span style="color: #00d4ff;">ZONE</span></h1>
        <p>La mejor tecnología al mejor precio</p>
        <div class="hero-buttons">
            <a href="${pageContext.request.contextPath}/productos" class="btn btn-primary">
                <span>Ver Catálogo</span>
                <svg width="20" height="20" viewBox="0 0 24 24" fill="currentColor">
                    <path d="M12 4l-1.41 1.41L16.17 11H4v2h12.17l-5.58 5.59L12 20l8-8z"/>
                </svg>
            </a>
            <a href="${pageContext.request.contextPath}/productos/ofertas" class="btn btn-secondary">
                Ver Ofertas
            </a>
        </div>
    </div>
</section>

<!-- Featured Products -->
<section class="section">
    <div class="section-header">
        <h2 class="section-title">Productos Destacados</h2>
        <p class="section-subtitle">Los mejores productos de tecnología</p>
    </div>

    <div class="products-grid">
        <c:choose>
            <c:when test="${not empty productosDestacados}">
                <c:forEach items="${productosDestacados}" var="producto">
                    <div class="product-card" onclick="location.href='${pageContext.request.contextPath}/producto/detalle?id=${producto.idProducto}'">
                        <div class="product-image">
                            <c:choose>
                                <c:when test="${not empty producto.imagenPrincipal}">
                                    <img src="${pageContext.request.contextPath}/uploads/${producto.imagenPrincipal}"
                                         alt="${producto.nombre}">
                                </c:when>
                                <c:otherwise>
                                    <svg width="80" height="80" viewBox="0 0 24 24" fill="#333">
                                        <path d="M21 19V5c0-1.1-.9-2-2-2H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2zM8.5 13.5l2.5 3.01L14.5 12l4.5 6H5l3.5-4.5z"/>
                                    </svg>
                                </c:otherwise>
                            </c:choose>
                        </div>
                        <div class="product-info">
                            <h3 class="product-name">${producto.nombre}</h3>
                            <div class="product-price">$${producto.precio}</div>
                            <button class="product-btn">Ver Detalles</button>
                        </div>
                    </div>
                </c:forEach>
            </c:when>
            <c:otherwise>
                <!-- Productos de ejemplo si no hay datos -->
                <c:forEach begin="1" end="4">
                    <div class="product-card">
                        <div class="product-image">
                            <svg width="80" height="80" viewBox="0 0 24 24" fill="#333">
                                <path d="M21 19V5c0-1.1-.9-2-2-2H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2zM8.5 13.5l2.5 3.01L14.5 12l4.5 6H5l3.5-4.5z"/>
                            </svg>
                        </div>
                        <div class="product-info">
                            <h3 class="product-name">Producto Ejemplo</h3>
                            <div class="product-price">$999.99</div>
                            <button class="product-btn">Ver Detalles</button>
                        </div>
                    </div>
                </c:forEach>
            </c:otherwise>
        </c:choose>
    </div>
</section>

<!-- Categories -->
<section class="section" style="background: #0f0f0f;">
    <div class="section-header">
        <h2 class="section-title">Categorías</h2>
        <p class="section-subtitle">Explora nuestras categorías</p>
    </div>

    <div class="categories-grid">
        <c:choose>
            <c:when test="${not empty categorias}">
                <c:forEach items="${categorias}" var="categoria" end="5">
                    <div class="category-card" onclick="location.href='${pageContext.request.contextPath}/productos/categoria?id=${categoria.idCategoria}'">
                        <div class="category-icon">
                            <svg viewBox="0 0 24 24">
                                <path d="M12 2l-5.5 9h11L12 2zm0 3.84L13.93 9h-3.87L12 5.84zM17.5 13c-2.49 0-4.5 2.01-4.5 4.5s2.01 4.5 4.5 4.5 4.5-2.01 4.5-4.5-2.01-4.5-4.5-4.5zm0 7c-1.38 0-2.5-1.12-2.5-2.5s1.12-2.5 2.5-2.5 2.5 1.12 2.5 2.5-1.12 2.5-2.5 2.5zM3 21.5h8v-8H3v8zm2-6h4v4H5v-4z"/>
                            </svg>
                        </div>
                        <h3 class="category-name">${categoria.nombre}</h3>
                    </div>
                </c:forEach>
            </c:when>
            <c:otherwise>
                <!-- Categorías de ejemplo -->
                <c:forEach items="${['Laptops', 'Smartphones', 'Tablets', 'Accesorios', 'Audio', 'Gaming']}" var="catName">
                    <div class="category-card">
                        <div class="category-icon">
                            <svg viewBox="0 0 24 24">
                                <path d="M12 2l-5.5 9h11L12 2zm0 3.84L13.93 9h-3.87L12 5.84zM17.5 13c-2.49 0-4.5 2.01-4.5 4.5s2.01 4.5 4.5 4.5 4.5-2.01 4.5-4.5-2.01-4.5-4.5-4.5zm0 7c-1.38 0-2.5-1.12-2.5-2.5s1.12-2.5 2.5-2.5 2.5 1.12 2.5 2.5-1.12 2.5-2.5 2.5zM3 21.5h8v-8H3v8zm2-6h4v4H5v-4z"/>
                            </svg>
                        </div>
                        <h3 class="category-name">${catName}</h3>
                    </div>
                </c:forEach>
            </c:otherwise>
        </c:choose>
    </div>
</section>

<!-- Footer -->
<jsp:include page="/views/components/footer.jsp" />
</body>
</html>