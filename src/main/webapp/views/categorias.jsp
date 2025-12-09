<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Categorías - TechZone</title>

    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

    <style>
        :root {
            --primary-color: #00d4ff;
            --primary-hover: #00b8e6;
            --secondary-color: #0099cc;
            --dark-color: #1a1a1a;
            --darker-color: #0a0a0a;
            --light-color: #2a2a2a;
            --border-color: #333333;
            --text-primary: #ffffff;
            --text-secondary: #b0b0b0;
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            background-color: var(--darker-color);
            color: var(--text-primary);
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            padding-right: 220px;
        }

        .categories-container {
            max-width: 1400px;
            margin: 0 auto;
            padding: 40px 20px 60px;
        }

        /* Header */
        .page-header {
            text-align: center;
            margin-bottom: 60px;
        }

        .page-title {
            font-size: 3rem;
            font-weight: bold;
            margin-bottom: 15px;
            background: linear-gradient(135deg, var(--primary-color), var(--secondary-color));
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }

        .page-subtitle {
            font-size: 1.2rem;
            color: var(--text-secondary);
            max-width: 600px;
            margin: 0 auto;
            line-height: 1.6;
        }

        /* Stats Bar */
        .stats-bar {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            margin-bottom: 50px;
        }

        .stat-card {
            background: var(--dark-color);
            border: 1px solid var(--border-color);
            border-radius: 15px;
            padding: 25px;
            text-align: center;
            transition: all 0.3s ease;
        }

        .stat-card:hover {
            transform: translateY(-5px);
            border-color: var(--primary-color);
            box-shadow: 0 10px 30px rgba(0, 212, 255, 0.2);
        }

        .stat-icon {
            width: 50px;
            height: 50px;
            margin: 0 auto 15px;
            display: flex;
            align-items: center;
            justify-content: center;
            background: linear-gradient(135deg, var(--primary-color), var(--secondary-color));
            border-radius: 12px;
        }

        .stat-icon svg {
            width: 30px;
            height: 30px;
            fill: #000;
        }

        .stat-value {
            font-size: 2.5rem;
            font-weight: bold;
            color: var(--primary-color);
            margin-bottom: 5px;
        }

        .stat-label {
            font-size: 0.95rem;
            color: var(--text-secondary);
            text-transform: uppercase;
            letter-spacing: 1px;
        }

        /* Categories Grid */
        .categories-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
            gap: 30px;
            margin-bottom: 60px;
        }

        /* Category Card */
        .category-card {
            background: var(--dark-color);
            border: 1px solid var(--border-color);
            border-radius: 20px;
            overflow: hidden;
            transition: all 0.4s ease;
            cursor: pointer;
            position: relative;
        }

        .category-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: linear-gradient(135deg, rgba(0, 212, 255, 0.1) 0%, transparent 100%);
            opacity: 0;
            transition: opacity 0.4s ease;
            pointer-events: none;
        }

        .category-card:hover {
            transform: translateY(-10px);
            border-color: var(--primary-color);
            box-shadow: 0 20px 50px rgba(0, 212, 255, 0.3);
        }

        .category-card:hover::before {
            opacity: 1;
        }

        .category-image-wrapper {
            height: 200px;
            background: var(--light-color);
            display: flex;
            align-items: center;
            justify-content: center;
            position: relative;
            overflow: hidden;
        }

        .category-image-wrapper::after {
            content: '';
            position: absolute;
            bottom: 0;
            left: 0;
            right: 0;
            height: 100px;
            background: linear-gradient(to top, var(--dark-color), transparent);
        }

        .category-image {
            width: 100%;
            height: 100%;
            object-fit: cover;
            transition: transform 0.4s ease;
        }

        .category-card:hover .category-image {
            transform: scale(1.15);
        }

        .category-icon {
            width: 100px;
            height: 100px;
            fill: var(--primary-color);
            opacity: 0.5;
            transition: all 0.4s ease;
        }

        .category-card:hover .category-icon {
            opacity: 0.8;
            transform: scale(1.1);
        }

        .category-content {
            padding: 25px;
            position: relative;
        }

        .category-header {
            display: flex;
            justify-content: space-between;
            align-items: start;
            margin-bottom: 15px;
        }

        .category-name {
            font-size: 1.5rem;
            font-weight: bold;
            color: var(--text-primary);
            margin-bottom: 8px;
        }

        .category-badge {
            background: linear-gradient(135deg, var(--primary-color), var(--secondary-color));
            color: #000;
            padding: 6px 12px;
            border-radius: 20px;
            font-size: 0.8rem;
            font-weight: 700;
            white-space: nowrap;
        }

        .category-description {
            font-size: 0.95rem;
            color: var(--text-secondary);
            line-height: 1.6;
            margin-bottom: 20px;
            display: -webkit-box;
            -webkit-line-clamp: 2;
            -webkit-box-orient: vertical;
            overflow: hidden;
        }

        .category-stats {
            display: flex;
            gap: 20px;
            margin-bottom: 20px;
            padding: 15px;
            background: rgba(0, 212, 255, 0.05);
            border-radius: 10px;
        }

        .category-stat {
            display: flex;
            align-items: center;
            gap: 8px;
            font-size: 0.9rem;
        }

        .category-stat svg {
            width: 18px;
            height: 18px;
            fill: var(--primary-color);
        }

        .category-stat-value {
            font-weight: 600;
            color: var(--text-primary);
        }

        .category-stat-label {
            color: var(--text-secondary);
        }

        .category-footer {
            display: flex;
            gap: 10px;
        }

        .btn-view-category {
            flex: 1;
            padding: 12px 20px;
            background: linear-gradient(135deg, var(--primary-color), var(--secondary-color));
            color: #000;
            border: none;
            border-radius: 10px;
            font-weight: 700;
            font-size: 0.95rem;
            cursor: pointer;
            transition: all 0.3s ease;
            text-align: center;
            text-decoration: none;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
        }

        .btn-view-category:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 20px rgba(0, 212, 255, 0.4);
        }

        .btn-view-category svg {
            width: 18px;
            height: 18px;
            fill: currentColor;
        }

        .btn-favorite {
            padding: 12px;
            background: rgba(255, 255, 255, 0.05);
            border: 1px solid var(--border-color);
            border-radius: 10px;
            cursor: pointer;
            transition: all 0.3s ease;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .btn-favorite:hover {
            background: rgba(255, 255, 255, 0.1);
            border-color: var(--primary-color);
            transform: scale(1.1);
        }

        .btn-favorite svg {
            width: 20px;
            height: 20px;
            fill: var(--text-secondary);
            transition: fill 0.3s ease;
        }

        .btn-favorite:hover svg {
            fill: var(--primary-color);
        }

        .btn-favorite.favorited svg {
            fill: #ff4444;
        }

        /* Featured Categories */
        .featured-section {
            margin-bottom: 60px;
        }

        .section-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 30px;
        }

        .section-title {
            font-size: 2rem;
            font-weight: bold;
            color: var(--text-primary);
        }

        .featured-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
            gap: 25px;
        }

        .featured-card {
            background: linear-gradient(135deg, var(--dark-color), var(--light-color));
            border: 1px solid var(--border-color);
            border-radius: 15px;
            padding: 30px;
            text-align: center;
            transition: all 0.3s ease;
            cursor: pointer;
        }

        .featured-card:hover {
            transform: translateY(-5px);
            border-color: var(--primary-color);
            box-shadow: 0 15px 40px rgba(0, 212, 255, 0.3);
        }

        .featured-icon {
            width: 80px;
            height: 80px;
            margin: 0 auto 20px;
            display: flex;
            align-items: center;
            justify-content: center;
            background: linear-gradient(135deg, var(--primary-color), var(--secondary-color));
            border-radius: 20px;
            transition: transform 0.3s ease;
        }

        .featured-card:hover .featured-icon {
            transform: scale(1.1) rotate(5deg);
        }

        .featured-icon svg {
            width: 50px;
            height: 50px;
            fill: #000;
        }

        .featured-name {
            font-size: 1.3rem;
            font-weight: bold;
            margin-bottom: 10px;
            color: var(--text-primary);
        }

        .featured-count {
            font-size: 1rem;
            color: var(--text-secondary);
            margin-bottom: 15px;
        }

        .featured-link {
            color: var(--primary-color);
            text-decoration: none;
            font-weight: 600;
            transition: color 0.3s ease;
        }

        .featured-link:hover {
            color: var(--primary-hover);
        }

        /* Empty State */
        .empty-state {
            text-align: center;
            padding: 80px 20px;
            background: var(--dark-color);
            border-radius: 15px;
            border: 1px solid var(--border-color);
        }

        .empty-icon {
            font-size: 5rem;
            color: var(--text-secondary);
            margin-bottom: 20px;
            opacity: 0.5;
        }

        .empty-title {
            font-size: 1.8rem;
            font-weight: bold;
            margin-bottom: 10px;
            color: var(--text-primary);
        }

        .empty-text {
            color: var(--text-secondary);
            margin-bottom: 25px;
        }

        /* Responsive */
        @media (max-width: 768px) {
            body {
                padding-right: 0;
            }

            .categories-container {
                padding: 20px 15px;
            }

            .page-title {
                font-size: 2rem;
            }

            .page-subtitle {
                font-size: 1rem;
            }

            .categories-grid {
                grid-template-columns: 1fr;
                gap: 20px;
            }

            .stats-bar {
                grid-template-columns: 1fr;
            }

            .category-image-wrapper {
                height: 150px;
            }

            .section-title {
                font-size: 1.5rem;
            }

            .featured-grid {
                grid-template-columns: 1fr;
            }
        }

        @media (max-width: 480px) {
            .category-stats {
                flex-direction: column;
                gap: 10px;
            }

            .category-footer {
                flex-direction: column;
            }

            .stat-value {
                font-size: 2rem;
            }
        }
    </style>
</head>
<body>
<!-- Include Header -->
<%@ include file="/views/components/header.jsp" %>

<div class="categories-container">
    <!-- Page Header -->
    <div class="page-header">
        <h1 class="page-title">Explora Nuestras Categorías</h1>
        <p class="page-subtitle">
            Descubre la mejor tecnología organizada en categorías especializadas
            para que encuentres exactamente lo que necesitas
        </p>
    </div>

    <!-- Stats Bar -->
    <div class="stats-bar">
        <div class="stat-card">
            <div class="stat-icon">
                <svg viewBox="0 0 24 24">
                    <path d="M12 2l-5.5 9h11L12 2zm0 3.84L13.93 9h-3.87L12 5.84zM17.5 13c-2.49 0-4.5 2.01-4.5 4.5s2.01 4.5 4.5 4.5 4.5-2.01 4.5-4.5-2.01-4.5-4.5-4.5zm0 7c-1.38 0-2.5-1.12-2.5-2.5s1.12-2.5 2.5-2.5 2.5 1.12 2.5 2.5-1.12 2.5-2.5 2.5zM3 21.5h8v-8H3v8zm2-6h4v4H5v-4z"/>
                </svg>
            </div>
            <div class="stat-value">${totalCategorias}</div>
            <div class="stat-label">Categorías</div>
        </div>

        <div class="stat-card">
            <div class="stat-icon">
                <svg viewBox="0 0 24 24">
                    <path d="M19 3H5c-1.11 0-2 .9-2 2v14c0 1.1.89 2 2 2h14c1.11 0 2-.9 2-2V5c0-1.1-.89-2-2-2zm-9 14l-5-5 1.41-1.41L10 14.17l7.59-7.59L19 8l-9 9z"/>
                </svg>
            </div>
            <div class="stat-value">${totalProductos}</div>
            <div class="stat-label">Productos</div>
        </div>

        <div class="stat-card">
            <div class="stat-icon">
                <svg viewBox="0 0 24 24">
                    <path d="M21.41 11.58l-9-9C12.05 2.22 11.55 2 11 2H4c-1.1 0-2 .9-2 2v7c0 .55.22 1.05.59 1.42l9 9c.36.36.86.58 1.41.58.55 0 1.05-.22 1.41-.59l7-7c.37-.36.59-.86.59-1.41 0-.55-.23-1.06-.59-1.42zM5.5 7C4.67 7 4 6.33 4 5.5S4.67 4 5.5 4 7 4.67 7 5.5 6.33 7 5.5 7z"/>
                </svg>
            </div>
            <div class="stat-value">${productosEnOferta}</div>
            <div class="stat-label">En Oferta</div>
        </div>

        <div class="stat-card">
            <div class="stat-icon">
                <svg viewBox="0 0 24 24">
                    <path d="M12 2L2 7l10 5 10-5-10-5zM2 17l10 5 10-5M2 12l10 5 10-5"/>
                </svg>
            </div>
            <div class="stat-value">${totalMarcas}</div>
            <div class="stat-label">Marcas</div>
        </div>
    </div>

    <!-- Featured Categories -->
    <c:if test="${not empty categoriasDestacadas}">
        <div class="featured-section">
            <div class="section-header">
                <h2 class="section-title">Categorías Destacadas</h2>
            </div>

            <div class="featured-grid">
                <c:forEach items="${categoriasDestacadas}" var="categoria">
                    <div class="featured-card" onclick="window.location.href='${pageContext.request.contextPath}/productos/categoria?id=${categoria.idCategoria}'">
                        <div class="featured-icon">
                            <svg viewBox="0 0 24 24">
                                <path d="M20 6h-2.18c.11-.31.18-.65.18-1 0-1.66-1.34-3-3-3-1.05 0-1.96.54-2.5 1.35l-.5.67-.5-.68C10.96 2.54 10.05 2 9 2 7.34 2 6 3.34 6 5c0 .35.07.69.18 1H4c-1.11 0-1.99.89-1.99 2L2 19c0 1.11.89 2 2 2h16c1.11 0 2-.89 2-2V8c0-1.11-.89-2-2-2zm-5-2c.55 0 1 .45 1 1s-.45 1-1 1-1-.45-1-1 .45-1 1-1zM9 4c.55 0 1 .45 1 1s-.45 1-1 1-1-.45-1-1 .45-1 1-1zm11 15H4v-2h16v2zm0-5H4V8h5.08L7 10.83 8.62 12 11 8.76l1-1.36 1 1.36L15.38 12 17 10.83 14.92 8H20v6z"/>
                            </svg>
                        </div>
                        <h3 class="featured-name">${categoria.nombre}</h3>
                        <p class="featured-count">${categoria.cantidadProductos} productos</p>
                        <a href="${pageContext.request.contextPath}/productos/categoria?id=${categoria.idCategoria}"
                           class="featured-link">
                            Explorar <i class="fas fa-arrow-right"></i>
                        </a>
                    </div>
                </c:forEach>
            </div>
        </div>
    </c:if>

    <!-- All Categories -->
    <div class="section-header">
        <h2 class="section-title">Todas las Categorías</h2>
    </div>

    <c:choose>
        <c:when test="${empty categorias}">
            <div class="empty-state">
                <div class="empty-icon">
                    <i class="fas fa-folder-open"></i>
                </div>
                <h2 class="empty-title">No hay categorías disponibles</h2>
                <p class="empty-text">
                    Estamos trabajando en agregar nuevas categorías. Vuelve pronto.
                </p>
            </div>
        </c:when>
        <c:otherwise>
            <div class="categories-grid">
                <c:forEach items="${categorias}" var="categoria">
                    <div class="category-card">
                        <div class="category-image-wrapper">
                            <c:choose>
                                <c:when test="${not empty categoria.imagen}">
                                    <img src="${pageContext.request.contextPath}/uploads/${categoria.imagen}"
                                         alt="${categoria.nombre}"
                                         class="category-image">
                                </c:when>
                                <c:otherwise>
                                    <svg class="category-icon" viewBox="0 0 24 24">
                                        <path d="M12 2l-5.5 9h11L12 2zm0 3.84L13.93 9h-3.87L12 5.84zM17.5 13c-2.49 0-4.5 2.01-4.5 4.5s2.01 4.5 4.5 4.5 4.5-2.01 4.5-4.5-2.01-4.5-4.5-4.5zm0 7c-1.38 0-2.5-1.12-2.5-2.5s1.12-2.5 2.5-2.5 2.5 1.12 2.5 2.5-1.12 2.5-2.5 2.5zM3 21.5h8v-8H3v8zm2-6h4v4H5v-4z"/>
                                    </svg>
                                </c:otherwise>
                            </c:choose>
                        </div>

                        <div class="category-content">
                            <div class="category-header">
                                <div>
                                    <h3 class="category-name">${categoria.nombre}</h3>
                                </div>
                                <span class="category-badge">
                                    ${categoria.cantidadProductos} items
                                </span>
                            </div>

                            <c:if test="${not empty categoria.descripcion}">
                                <p class="category-description">${categoria.descripcion}</p>
                            </c:if>

                            <div class="category-stats">
                                <div class="category-stat">
                                    <svg viewBox="0 0 24 24">
                                        <path d="M4 6h16v2H4zm0 5h16v2H4zm0 5h16v2H4z"/>
                                    </svg>
                                    <span class="category-stat-value">${categoria.cantidadProductos}</span>
                                    <span class="category-stat-label">productos</span>
                                </div>

                                <c:if test="${not empty categoria.productosEnOferta && categoria.productosEnOferta > 0}">
                                    <div class="category-stat">
                                        <svg viewBox="0 0 24 24">
                                            <path d="M21.41 11.58l-9-9C12.05 2.22 11.55 2 11 2H4c-1.1 0-2 .9-2 2v7c0 .55.22 1.05.59 1.42l9 9c.36.36.86.58 1.41.58.55 0 1.05-.22 1.41-.59l7-7c.37-.36.59-.86.59-1.41 0-.55-.23-1.06-.59-1.42zM5.5 7C4.67 7 4 6.33 4 5.5S4.67 4 5.5 4 7 4.67 7 5.5 6.33 7 5.5 7z"/>
                                        </svg>
                                        <span class="category-stat-value">${categoria.productosEnOferta}</span>
                                        <span class="category-stat-label">ofertas</span>
                                    </div>
                                </c:if>
                            </div>

                            <div class="category-footer">
                                <a href="${pageContext.request.contextPath}/productos/categoria?id=${categoria.idCategoria}"
                                   class="btn-view-category">
                                    <span>Explorar Categoría</span>
                                    <svg viewBox="0 0 24 24">
                                        <path d="M12 4l-1.41 1.41L16.17 11H4v2h12.17l-5.58 5.59L12 20l8-8z"/>
                                    </svg>
                                </a>

                                <button class="btn-favorite" title="Agregar a favoritos">
                                    <svg viewBox="0 0 24 24">
                                        <path d="M16.5 3c-1.74 0-3.41.81-4.5 2.09C10.91 3.81 9.24 3 7.5 3 4.42 3 2 5.42 2 8.5c0 3.78 3.4 6.86 8.55 11.54L12 21.35l1.45-1.32C18.6 15.36 22 12.28 22 8.5 22 5.42 19.58 3 16.5 3zm-4.4 15.55l-.1.1-.1-.1C7.14 14.24 4 11.39 4 8.5 4 6.5 5.5 5 7.5 5c1.54 0 3.04.99 3.57 2.36h1.87C13.46 5.99 14.96 5 16.5 5c2 0 3.5 1.5 3.5 3.5 0 2.89-3.14 5.74-7.9 10.05z"/>
                                    </svg>
                                </button>
                            </div>
                        </div>
                    </div>
                </c:forEach>
            </div>
        </c:otherwise>
    </c:choose>
</div>

<!-- Include Footer -->
<%@ include file="/views/components/footer.jsp" %>

<script>
    // Marcar categoría activa en el sidebar
    document.addEventListener('DOMContentLoaded', function() {
        const categoriasLink = document.querySelector('a[href*="/categorias"]');
        if (categoriasLink) {
            categoriasLink.classList.add('active');
        }
    });

    // Agregar a favoritos
    document.querySelectorAll('.btn-favorite').forEach(btn => {
        btn.addEventListener('click', function(e) {
            e.stopPropagation();
            this.classList.toggle('favorited');

            const svg = this.querySelector('svg');
            if (this.classList.contains('favorited')) {
                svg.innerHTML = '<path d="M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z"/>';
            } else {
                svg.innerHTML = '<path d="M16.5 3c-1.74 0-3.41.81-4.5 2.09C10.91 3.81 9.24 3 7.5 3 4.42 3 2 5.42 2 8.5c0 3.78 3.4 6.86 8.55 11.54L12 21.35l1.45-1.32C18.6 15.36 22 12.28 22 8.5 22 5.42 19.58 3 16.5 3zm-4.4 15.55l-.1.1-.1-.1C7.14 14.24 4 11.39 4 8.5 4 6.5 5.5 5 7.5 5c1.54 0 3.04.99 3.57 2.36h1.87C13.46 5.99 14.96 5 16.5 5c2 0 3.5 1.5 3.5 3.5 0 2.89-3.14 5.74-7.9 10.05z"/>';
            }
        });
    });

    // Smooth scroll
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function (e) {
            e.preventDefault();
            const target = document.querySelector(this.getAttribute('href'));
            if (target) {
                target.scrollIntoView({
                    behavior: 'smooth',
                    block: 'start'
                });
            }
        });
    });
</script>
</body>
</html>