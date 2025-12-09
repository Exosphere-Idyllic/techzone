<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${producto.nombre} - TechZone</title>

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
            --success-color: #00C851;
            --warning-color: #ffbb33;
            --danger-color: #ff4444;
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

        .detail-container {
            max-width: 1400px;
            margin: 0 auto;
            padding: 40px 20px 60px;
        }

        /* Breadcrumb */
        .breadcrumb {
            display: flex;
            gap: 10px;
            margin-bottom: 30px;
            color: var(--text-secondary);
            font-size: 0.9rem;
            flex-wrap: wrap;
        }

        .breadcrumb a {
            color: var(--primary-color);
            text-decoration: none;
        }

        .breadcrumb a:hover {
            color: var(--primary-hover);
        }

        /* Product Main */
        .product-main {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 50px;
            margin-bottom: 60px;
        }

        /* Gallery */
        .product-gallery {
            background: var(--dark-color);
            border-radius: 15px;
            padding: 30px;
            border: 1px solid var(--border-color);
        }

        .main-image-wrapper {
            width: 100%;
            height: 500px;
            background: var(--darker-color);
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            margin-bottom: 20px;
            overflow: hidden;
            position: relative;
        }

        .main-image {
            max-width: 100%;
            max-height: 100%;
            object-fit: contain;
        }

        .zoom-icon {
            position: absolute;
            top: 15px;
            right: 15px;
            background: rgba(0, 0, 0, 0.7);
            color: white;
            padding: 10px;
            border-radius: 8px;
            cursor: pointer;
            transition: all 0.3s ease;
        }

        .zoom-icon:hover {
            background: var(--primary-color);
            color: #000;
        }

        .thumbnail-list {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(80px, 1fr));
            gap: 10px;
        }

        .thumbnail {
            width: 100%;
            height: 80px;
            background: var(--darker-color);
            border: 2px solid var(--border-color);
            border-radius: 8px;
            cursor: pointer;
            overflow: hidden;
            transition: all 0.3s ease;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .thumbnail:hover,
        .thumbnail.active {
            border-color: var(--primary-color);
            transform: scale(1.05);
        }

        .thumbnail img {
            width: 100%;
            height: 100%;
            object-fit: contain;
        }

        /* Product Info */
        .product-info {
            display: flex;
            flex-direction: column;
        }

        .product-badge {
            display: inline-block;
            padding: 6px 15px;
            border-radius: 20px;
            font-size: 0.8rem;
            font-weight: 700;
            text-transform: uppercase;
            margin-bottom: 15px;
            width: fit-content;
        }

        .badge-new {
            background: linear-gradient(135deg, var(--primary-color), var(--secondary-color));
            color: #000;
        }

        .badge-sale {
            background: linear-gradient(135deg, #ff4444, #cc0000);
            color: #fff;
        }

        .product-title {
            font-size: 2.5rem;
            font-weight: bold;
            margin-bottom: 15px;
            line-height: 1.3;
        }

        .product-meta {
            display: flex;
            gap: 20px;
            margin-bottom: 20px;
            padding-bottom: 20px;
            border-bottom: 1px solid var(--border-color);
            flex-wrap: wrap;
        }

        .meta-item {
            display: flex;
            align-items: center;
            gap: 8px;
            font-size: 0.95rem;
            color: var(--text-secondary);
        }

        .meta-item svg {
            width: 18px;
            height: 18px;
            fill: var(--primary-color);
        }

        .rating-stars {
            display: flex;
            gap: 3px;
        }

        .star {
            color: #ffc107;
            font-size: 1rem;
        }

        .star.empty {
            color: #444;
        }

        .rating-text {
            margin-left: 5px;
        }

        /* Price Section */
        .price-section {
            background: var(--dark-color);
            padding: 25px;
            border-radius: 12px;
            margin-bottom: 25px;
            border: 1px solid var(--border-color);
        }

        .price-main {
            font-size: 3rem;
            font-weight: bold;
            color: var(--primary-color);
            margin-bottom: 10px;
        }

        .price-original {
            font-size: 1.5rem;
            color: var(--text-secondary);
            text-decoration: line-through;
            margin-right: 15px;
        }

        .price-discount {
            display: inline-block;
            background: var(--danger-color);
            color: #fff;
            padding: 5px 12px;
            border-radius: 6px;
            font-weight: 700;
            font-size: 0.9rem;
        }

        .savings {
            color: var(--success-color);
            font-size: 0.95rem;
            margin-top: 10px;
        }

        /* Stock Info */
        .stock-info {
            display: flex;
            align-items: center;
            gap: 10px;
            padding: 15px;
            background: rgba(0, 200, 81, 0.1);
            border: 1px solid var(--success-color);
            border-radius: 10px;
            margin-bottom: 25px;
        }

        .stock-info.low-stock {
            background: rgba(255, 187, 51, 0.1);
            border-color: var(--warning-color);
        }

        .stock-info.out-of-stock {
            background: rgba(255, 68, 68, 0.1);
            border-color: var(--danger-color);
        }

        .stock-icon {
            font-size: 1.5rem;
        }

        .stock-text {
            font-weight: 600;
        }

        /* Quantity Selector */
        .quantity-section {
            margin-bottom: 25px;
        }

        .quantity-label {
            font-weight: 600;
            margin-bottom: 10px;
            display: block;
        }

        .quantity-selector {
            display: flex;
            align-items: center;
            gap: 15px;
        }

        .quantity-controls {
            display: flex;
            align-items: center;
            background: var(--dark-color);
            border: 1px solid var(--border-color);
            border-radius: 10px;
            overflow: hidden;
        }

        .qty-btn {
            padding: 12px 20px;
            background: transparent;
            border: none;
            color: var(--text-primary);
            font-size: 1.2rem;
            cursor: pointer;
            transition: all 0.3s ease;
        }

        .qty-btn:hover {
            background: var(--primary-color);
            color: #000;
        }

        .qty-btn:disabled {
            opacity: 0.3;
            cursor: not-allowed;
        }

        .qty-input {
            width: 60px;
            text-align: center;
            background: transparent;
            border: none;
            border-left: 1px solid var(--border-color);
            border-right: 1px solid var(--border-color);
            color: var(--text-primary);
            font-size: 1.1rem;
            font-weight: 600;
            padding: 12px 0;
        }

        .stock-available {
            color: var(--text-secondary);
            font-size: 0.9rem;
        }

        /* Action Buttons */
        .action-buttons {
            display: flex;
            gap: 15px;
            margin-bottom: 30px;
        }

        .btn-primary {
            flex: 1;
            padding: 18px 30px;
            background: linear-gradient(135deg, var(--primary-color), var(--secondary-color));
            border: none;
            border-radius: 10px;
            color: #000;
            font-size: 1.1rem;
            font-weight: 700;
            cursor: pointer;
            transition: all 0.3s ease;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
            text-transform: uppercase;
            box-shadow: 0 10px 30px rgba(0, 212, 255, 0.3);
        }

        .btn-primary:hover {
            transform: translateY(-3px);
            box-shadow: 0 15px 40px rgba(0, 212, 255, 0.5);
        }

        .btn-primary:disabled {
            opacity: 0.5;
            cursor: not-allowed;
            transform: none;
        }

        .btn-secondary {
            padding: 18px;
            background: var(--dark-color);
            border: 1px solid var(--border-color);
            border-radius: 10px;
            color: var(--text-primary);
            cursor: pointer;
            transition: all 0.3s ease;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .btn-secondary:hover {
            background: var(--light-color);
            border-color: var(--primary-color);
            transform: scale(1.05);
        }

        .btn-secondary svg {
            width: 24px;
            height: 24px;
            fill: currentColor;
        }

        /* Features */
        .features-list {
            list-style: none;
            display: grid;
            gap: 12px;
            margin-bottom: 30px;
        }

        .feature-item {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 12px;
            background: rgba(0, 212, 255, 0.05);
            border-radius: 8px;
        }

        .feature-icon {
            width: 24px;
            height: 24px;
            fill: var(--primary-color);
            flex-shrink: 0;
        }

        /* Tabs Section */
        .tabs-section {
            background: var(--dark-color);
            border-radius: 15px;
            padding: 30px;
            margin-bottom: 60px;
            border: 1px solid var(--border-color);
        }

        .tabs-nav {
            display: flex;
            gap: 10px;
            border-bottom: 2px solid var(--border-color);
            margin-bottom: 30px;
            overflow-x: auto;
        }

        .tab-btn {
            padding: 15px 25px;
            background: transparent;
            border: none;
            border-bottom: 3px solid transparent;
            color: var(--text-secondary);
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            white-space: nowrap;
        }

        .tab-btn:hover {
            color: var(--text-primary);
        }

        .tab-btn.active {
            color: var(--primary-color);
            border-bottom-color: var(--primary-color);
        }

        .tab-content {
            display: none;
        }

        .tab-content.active {
            display: block;
            animation: fadeIn 0.3s ease;
        }

        @keyframes fadeIn {
            from { opacity: 0; }
            to { opacity: 1; }
        }

        .description-content {
            line-height: 1.8;
            color: var(--text-secondary);
        }

        .description-content h3 {
            color: var(--text-primary);
            margin: 20px 0 10px;
        }

        .description-content ul {
            padding-left: 20px;
        }

        .description-content li {
            margin-bottom: 8px;
        }

        /* Specifications Table */
        .specs-table {
            width: 100%;
            border-collapse: collapse;
        }

        .specs-table tr {
            border-bottom: 1px solid var(--border-color);
        }

        .specs-table td {
            padding: 15px;
        }

        .specs-table td:first-child {
            font-weight: 600;
            color: var(--text-primary);
            width: 30%;
        }

        .specs-table td:last-child {
            color: var(--text-secondary);
        }

        /* Reviews */
        .reviews-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 30px;
            flex-wrap: wrap;
            gap: 20px;
        }

        .reviews-summary {
            display: flex;
            align-items: center;
            gap: 20px;
        }

        .rating-big {
            font-size: 3rem;
            font-weight: bold;
            color: var(--primary-color);
        }

        .rating-details {
            display: flex;
            flex-direction: column;
            gap: 5px;
        }

        .btn-write-review {
            padding: 12px 25px;
            background: var(--primary-color);
            color: #000;
            border: none;
            border-radius: 8px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
        }

        .btn-write-review:hover {
            background: var(--primary-hover);
            transform: translateY(-2px);
        }

        .review-item {
            padding: 20px;
            background: rgba(255, 255, 255, 0.03);
            border-radius: 10px;
            margin-bottom: 15px;
        }

        .review-header {
            display: flex;
            justify-content: space-between;
            margin-bottom: 10px;
        }

        .review-author {
            font-weight: 600;
        }

        .review-date {
            color: var(--text-secondary);
            font-size: 0.85rem;
        }

        .review-text {
            color: var(--text-secondary);
            line-height: 1.6;
        }

        /* Related Products */
        .related-section {
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
        }

        .btn-view-all {
            color: var(--primary-color);
            text-decoration: none;
            font-weight: 600;
            transition: color 0.3s ease;
        }

        .btn-view-all:hover {
            color: var(--primary-hover);
        }

        .products-carousel {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
            gap: 30px;
        }

        /* Alert */
        .alert {
            padding: 15px 20px;
            border-radius: 10px;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .alert-success {
            background: rgba(0, 200, 81, 0.1);
            border: 1px solid var(--success-color);
            color: #51cf66;
        }

        .alert-danger {
            background: rgba(255, 68, 68, 0.1);
            border: 1px solid var(--danger-color);
            color: #ff6b6b;
        }

        /* Responsive */
        @media (max-width: 1024px) {
            .product-main {
                grid-template-columns: 1fr;
            }
        }

        @media (max-width: 768px) {
            body {
                padding-right: 0;
            }

            .detail-container {
                padding: 20px 15px;
            }

            .product-title {
                font-size: 1.8rem;
            }

            .price-main {
                font-size: 2.2rem;
            }

            .main-image-wrapper {
                height: 350px;
            }

            .action-buttons {
                flex-direction: column;
            }
        }

        @media (max-width: 480px) {
            .tabs-nav {
                flex-direction: column;
            }

            .tab-btn {
                text-align: left;
            }

            .quantity-selector {
                flex-direction: column;
                align-items: flex-start;
            }
        }
    </style>
</head>
<body>
<!-- Include Header -->
<%@ include file="/views/components/header.jsp" %>

<div class="detail-container">
    <!-- Breadcrumb -->
    <nav class="breadcrumb">
        <a href="${pageContext.request.contextPath}/">Inicio</a>
        <span>/</span>
        <a href="${pageContext.request.contextPath}/productos">Productos</a>
        <span>/</span>
        <c:if test="${not empty producto.categoria}">
            <a href="${pageContext.request.contextPath}/productos?categoria=${producto.categoria.idCategoria}">
                    ${producto.categoria.nombre}
            </a>
            <span>/</span>
        </c:if>
        <span>${producto.nombre}</span>
    </nav>

    <!-- Messages -->
    <c:if test="${not empty mensaje}">
        <div class="alert alert-success">
            <i class="fas fa-check-circle"></i>
            <span>${mensaje}</span>
        </div>
    </c:if>

    <c:if test="${not empty error}">
        <div class="alert alert-danger">
            <i class="fas fa-exclamation-circle"></i>
            <span>${error}</span>
        </div>
    </c:if>

    <!-- Product Main -->
    <div class="product-main">
        <!-- Gallery -->
        <div class="product-gallery">
            <div class="main-image-wrapper" id="mainImageWrapper">
                <c:choose>
                    <c:when test="${not empty imagenPrincipal}">
                        <img src="${pageContext.request.contextPath}/uploads/${imagenPrincipal}"
                             alt="${producto.nombre}"
                             class="main-image"
                             id="mainImage">
                        <div class="zoom-icon" onclick="zoomImage()">
                            <i class="fas fa-search-plus"></i>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <svg width="200" height="200" viewBox="0 0 24 24" fill="#444">
                            <path d="M21 19V5c0-1.1-.9-2-2-2H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2zM8.5 13.5l2.5 3.01L14.5 12l4.5 6H5l3.5-4.5z"/>
                        </svg>
                    </c:otherwise>
                </c:choose>
            </div>

            <c:if test="${not empty imagenes}">
                <div class="thumbnail-list">
                    <c:forEach items="${imagenes}" var="imagen" varStatus="status">
                        <div class="thumbnail ${status.index == 0 ? 'active' : ''}"
                             onclick="changeImage('${pageContext.request.contextPath}/uploads/${imagen.urlImagen}', this)">
                            <img src="${pageContext.request.contextPath}/uploads/${imagen.urlImagen}"
                                 alt="Imagen ${status.index + 1}">
                        </div>
                    </c:forEach>
                </div>
            </c:if>
        </div>

        <!-- Product Info -->
        <div class="product-info">
            <!-- Badge -->
            <c:if test="${not empty producto.esNuevo && producto.esNuevo}">
                <span class="product-badge badge-new">Nuevo</span>
            </c:if>
            <c:if test="${not empty producto.descuento && producto.descuento > 0}">
                <span class="product-badge badge-sale">-${producto.descuento}% OFF</span>
            </c:if>

            <!-- Title -->
            <h1 class="product-title">${producto.nombre}</h1>

            <!-- Meta -->
            <div class="product-meta">
                <c:if test="${not empty producto.marca}">
                    <div class="meta-item">
                        <svg viewBox="0 0 24 24">
                            <path d="M12 2L2 7l10 5 10-5-10-5zM2 17l10 5 10-5M2 12l10 5 10-5"/>
                        </svg>
                        <span>Marca: <strong>${producto.marca}</strong></span>
                    </div>
                </c:if>

                <c:if test="${not empty producto.categoria}">
                    <div class="meta-item">
                        <svg viewBox="0 0 24 24">
                            <path d="M12 2l-5.5 9h11L12 2zm0 3.84L13.93 9h-3.87L12 5.84zM17.5 13c-2.49 0-4.5 2.01-4.5 4.5s2.01 4.5 4.5 4.5 4.5-2.01 4.5-4.5-2.01-4.5-4.5-4.5zm0 7c-1.38 0-2.5-1.12-2.5-2.5s1.12-2.5 2.5-2.5 2.5 1.12 2.5 2.5-1.12 2.5-2.5 2.5zM3 21.5h8v-8H3v8zm2-6h4v4H5v-4z"/>
                        </svg>
                        <span>${producto.categoria.nombre}</span>
                    </div>
                </c:if>

                <c:if test="${not empty producto.promedioCalificacion && producto.promedioCalificacion > 0}">
                    <div class="meta-item">
                        <div class="rating-stars">
                            <c:forEach begin="1" end="5" var="i">
                                <span class="star ${i <= producto.promedioCalificacion ? '' : 'empty'}">★</span>
                            </c:forEach>
                        </div>
                        <span class="rating-text">
                            ${producto.promedioCalificacion} (${producto.totalCalificaciones} reseñas)
                        </span>
                    </div>
                </c:if>

                <div class="meta-item">
                    <svg viewBox="0 0 24 24">
                        <path d="M12 2C8.13 2 5 5.13 5 9c0 5.25 7 13 7 13s7-7.75 7-13c0-3.87-3.13-7-7-7zm0 9.5c-1.38 0-2.5-1.12-2.5-2.5s1.12-2.5 2.5-2.5 2.5 1.12 2.5 2.5-1.12 2.5-2.5 2.5z"/>
                    </svg>
                    <span>SKU: ${producto.idProducto}</span>
                </div>
            </div>

            <!-- Price -->
            <div class="price-section">
                <div class="price-main">
                    $<fmt:formatNumber value="${producto.precio}" pattern="#,##0.00"/>
                </div>
                <c:if test="${not empty producto.precioOriginal && producto.precioOriginal > producto.precio}">
                    <div>
                        <span class="price-original">
                            $<fmt:formatNumber value="${producto.precioOriginal}" pattern="#,##0.00"/>
                        </span>
                        <span class="price-discount">-${producto.descuento}%</span>
                    </div>
                    <div class="savings">
                        Ahorras: $<fmt:formatNumber value="${producto.precioOriginal - producto.precio}" pattern="#,##0.00"/>
                    </div>
                </c:if>
            </div>

            <!-- Stock -->
            <div class="stock-info ${producto.stock == 0 ? 'out-of-stock' : (producto.stock <= 5 ? 'low-stock' : '')}">
                <c:choose>
                    <c:when test="${producto.stock == 0}">
                        <i class="fas fa-times-circle stock-icon" style="color: var(--danger-color);"></i>
                        <span class="stock-text" style="color: var(--danger-color);">Producto agotado</span>
                    </c:when>
                    <c:when test="${producto.stock <= 5}">
                        <i class="fas fa-exclamation-triangle stock-icon" style="color: var(--warning-color);"></i>
                        <span class="stock-text" style="color: var(--warning-color);">
                            ¡Últimas ${producto.stock} unidades disponibles!
                        </span>
                    </c:when>
                    <c:otherwise>
                        <i class="fas fa-check-circle stock-icon" style="color: var(--success-color);"></i>
                        <span class="stock-text" style="color: var(--success-color);">
                            En stock (${producto.stock} disponibles)
                        </span>
                    </c:otherwise>
                </c:choose>
            </div>

            <!-- Quantity -->
            <c:if test="${producto.stock > 0}">
                <div class="quantity-section">
                    <label class="quantity-label">Cantidad:</label>
                    <div class="quantity-selector">
                        <div class="quantity-controls">
                            <button type="button" class="qty-btn" onclick="decreaseQuantity()">
                                <i class="fas fa-minus"></i>
                            </button>
                            <input type="number"
                                   id="quantity"
                                   class="qty-input"
                                   value="1"
                                   min="1"
                                   max="${producto.stock}"
                                   readonly>
                            <button type="button" class="qty-btn" onclick="increaseQuantity()">
                                <i class="fas fa-plus"></i>
                            </button>
                        </div>
                        <span class="stock-available">${producto.stock} disponibles</span>
                    </div>
                </div>
            </c:if>

            <!-- Actions -->
            <form action="${pageContext.request.contextPath}/carrito/agregar" method="POST" id="addToCartForm">
                <input type="hidden" name="idProducto" value="${producto.idProducto}">
                <input type="hidden" name="cantidad" id="cantidadInput" value="1">

                <div class="action-buttons">
                    <button type="submit"
                            class="btn-primary"
                    ${producto.stock == 0 ? 'disabled' : ''}>
                        <i class="fas fa-shopping-cart"></i>
                        <span>${producto.stock == 0 ? 'Agotado' : 'Agregar al Carrito'}</span>
                    </button>

                    <button type="button" class="btn-secondary" title="Agregar a favoritos">
                        <i class="far fa-heart"></i>
                    </button>

                    <button type="button" class="btn-secondary" title="Compartir">
                        <i class="fas fa-share-alt"></i>
                    </button>
                </div>
            </form>

            <!-- Features -->
            <ul class="features-list">
                <li class="feature-item">
                    <svg class="feature-icon" viewBox="0 0 24 24">
                        <path d="M12 1L3 5v6c0 5.55 3.84 10.74 9 12 5.16-1.26 9-6.45 9-12V5l-9-4zm0 10.99h7c-.53 4.12-3.28 7.79-7 8.94V12H5V6.3l7-3.11v8.8z"/>
                    </svg>
                    <span>Garantía oficial del fabricante</span>
                </li>
                <li class="feature-item">
                    <svg class="feature-icon" viewBox="0 0 24 24">
                        <path d="M18 6h-2c0-2.21-1.79-4-4-4S8 3.79 8 6H6c-1.1 0-2 .9-2 2v12c0 1.1.9 2 2 2h12c1.1 0 2-.9 2-2V8c0-1.1-.9-2-2-2zm-6-2c1.1 0 2 .9 2 2h-4c0-1.1.9-2 2-2zm6 16H6V8h2v2c0 .55.45 1 1 1s1-.45 1-1V8h4v2c0 .55.45 1 1 1s1-.45 1-1V8h2v12z"/>
                    </svg>
                    <span>Envío gratis en compras mayores a $50</span>
                </li>
                <li class="feature-item">
                    <svg class="feature-icon" viewBox="0 0 24 24">
                        <path d="M9 11H7v2h2v-2zm4 0h-2v2h2v-2zm4 0h-2v2h2v-2zm2-7h-1V2h-2v2H8V2H6v2H5c-1.11 0-1.99.9-1.99 2L3 20c0 1.1.89 2 2 2h14c1.1 0 2-.9 2-2V6c0-1.1-.9-2-2-2zm0 16H5V9h14v11z"/>
                    </svg>
                    <span>Devolución gratis dentro de 30 días</span>
                </li>
                <li class="feature-item">
                    <svg class="feature-icon" viewBox="0 0 24 24">
                        <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-2 15l-5-5 1.41-1.41L10 14.17l7.59-7.59L19 8l-9 9z"/>
                    </svg>
                    <span>Producto 100% original</span>
                </li>
            </ul>
        </div>
    </div>

    <!-- Tabs Section -->
    <div class="tabs-section">
        <div class="tabs-nav">
            <button class="tab-btn active" onclick="openTab(event, 'description')">
                Descripción
            </button>
            <button class="tab-btn" onclick="openTab(event, 'specifications')">
                Especificaciones
            </button>
            <button class="tab-btn" onclick="openTab(event, 'reviews')">
                Reseñas (${producto.totalCalificaciones})
            </button>
        </div>

        <!-- Description Tab -->
        <div id="description" class="tab-content active">
            <div class="description-content">
                <c:choose>
                    <c:when test="${not empty producto.descripcionLarga}">
                        ${producto.descripcionLarga}
                    </c:when>
                    <c:otherwise>
                        <p>${producto.descripcion}</p>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>

        <!-- Specifications Tab -->
        <div id="specifications" class="tab-content">
            <table class="specs-table">
                <c:if test="${not empty producto.marca}">
                    <tr>
                        <td>Marca</td>
                        <td>${producto.marca}</td>
                    </tr>
                </c:if>
                <c:if test="${not empty producto.modelo}">
                    <tr>
                        <td>Modelo</td>
                        <td>${producto.modelo}</td>
                    </tr>
                </c:if>
                <c:if test="${not empty producto.categoria}">
                    <tr>
                        <td>Categoría</td>
                        <td>${producto.categoria.nombre}</td>
                    </tr>
                </c:if>
                <tr>
                    <td>SKU</td>
                    <td>${producto.idProducto}</td>
                </tr>
                <tr>
                    <td>Disponibilidad</td>
                    <td>
                        <c:choose>
                            <c:when test="${producto.stock > 0}">
                                En stock (${producto.stock} unidades)
                            </c:when>
                            <c:otherwise>
                                Agotado
                            </c:otherwise>
                        </c:choose>
                    </td>
                </tr>
                <c:if test="${not empty producto.peso}">
                    <tr>
                        <td>Peso</td>
                        <td>${producto.peso} kg</td>
                    </tr>
                </c:if>
                <c:if test="${not empty producto.dimensiones}">
                    <tr>
                        <td>Dimensiones</td>
                        <td>${producto.dimensiones}</td>
                    </tr>
                </c:if>
            </table>
        </div>

        <!-- Reviews Tab -->
        <div id="reviews" class="tab-content">
            <div class="reviews-header">
                <c:if test="${not empty producto.promedioCalificacion && producto.promedioCalificacion > 0}">
                    <div class="reviews-summary">
                        <div class="rating-big">${producto.promedioCalificacion}</div>
                        <div class="rating-details">
                            <div class="rating-stars">
                                <c:forEach begin="1" end="5" var="i">
                                    <span class="star ${i <= producto.promedioCalificacion ? '' : 'empty'}">★</span>
                                </c:forEach>
                            </div>
                            <div>${producto.totalCalificaciones} reseñas</div>
                        </div>
                    </div>
                </c:if>

                <c:if test="${not empty sessionScope.usuario}">
                    <button class="btn-write-review" onclick="window.location.href='${pageContext.request.contextPath}/producto/resena?id=${producto.idProducto}'">
                        <i class="fas fa-pencil-alt"></i> Escribir Reseña
                    </button>
                </c:if>
            </div>

            <c:choose>
                <c:when test="${not empty reseñas}">
                    <c:forEach items="${reseñas}" var="resena">
                        <div class="review-item">
                            <div class="review-header">
                                <div>
                                    <div class="review-author">${resena.usuario.nombreCompleto}</div>
                                    <div class="rating-stars" style="margin-top: 5px;">
                                        <c:forEach begin="1" end="5" var="i">
                                            <span class="star ${i <= resena.calificacion ? '' : 'empty'}">★</span>
                                        </c:forEach>
                                    </div>
                                </div>
                                <div class="review-date">
                                    <fmt:formatDate value="${resena.fechaCreacion}" pattern="dd/MM/yyyy"/>
                                </div>
                            </div>
                            <c:if test="${not empty resena.titulo}">
                                <div style="font-weight: 600; margin-bottom: 8px;">${resena.titulo}</div>
                            </c:if>
                            <div class="review-text">${resena.comentario}</div>
                        </div>
                    </c:forEach>
                </c:when>
                <c:otherwise>
                    <p style="text-align: center; color: var(--text-secondary); padding: 40px 0;">
                        Aún no hay reseñas para este producto. ¡Sé el primero en opinar!
                    </p>
                </c:otherwise>
            </c:choose>
        </div>
    </div>

    <!-- Related Products -->
    <c:if test="${not empty productosRelacionados}">
        <section class="related-section">
            <div class="section-header">
                <h2 class="section-title">Productos Relacionados</h2>
                <a href="${pageContext.request.contextPath}/productos?categoria=${producto.categoria.idCategoria}"
                   class="btn-view-all">
                    Ver todos <i class="fas fa-arrow-right"></i>
                </a>
            </div>

            <div class="products-carousel">
                <c:forEach items="${productosRelacionados}" var="productoRel" end="3">
                    <c:set var="producto" value="${productoRel}" scope="request"/>
                    <jsp:include page="/views/components/producto-card.jsp"/>
                </c:forEach>
            </div>
        </section>
    </c:if>
</div>

<!-- Include Footer -->
<%@ include file="/views/components/footer.jsp" %>

<script>
    // Quantity controls
    function increaseQuantity() {
        const input = document.getElementById('quantity');
        const max = parseInt(input.max);
        const current = parseInt(input.value);

        if (current < max) {
            input.value = current + 1;
            document.getElementById('cantidadInput').value = current + 1;
        }
    }

    function decreaseQuantity() {
        const input = document.getElementById('quantity');
        const current = parseInt(input.value);

        if (current > 1) {
            input.value = current - 1;
            document.getElementById('cantidadInput').value = current - 1;
        }
    }

    // Change main image
    function changeImage(imageSrc, thumbnail) {
        document.getElementById('mainImage').src = imageSrc;

        // Update active thumbnail
        document.querySelectorAll('.thumbnail').forEach(t => t.classList.remove('active'));
        thumbnail.classList.add('active');
    }

    // Zoom image (simple implementation)
    function zoomImage() {
        const image = document.getElementById('mainImage');
        if (image) {
            window.open(image.src, '_blank');
        }
    }

    // Tabs
    function openTab(evt, tabName) {
        // Hide all tab contents
        const tabContents = document.getElementsByClassName('tab-content');
        for (let i = 0; i < tabContents.length; i++) {
            tabContents[i].classList.remove('active');
        }

        // Remove active class from all buttons
        const tabBtns = document.getElementsByClassName('tab-btn');
        for (let i = 0; i < tabBtns.length; i++) {
            tabBtns[i].classList.remove('active');
        }

        // Show current tab and mark button as active
        document.getElementById(tabName).classList.add('active');
        evt.currentTarget.classList.add('active');
    }

    // Update quantity on form submit
    document.getElementById('addToCartForm').addEventListener('submit', function() {
        const quantity = document.getElementById('quantity').value;
        document.getElementById('cantidadInput').value = quantity;
    });

    // Auto-hide alerts
    setTimeout(function() {
        const alerts = document.querySelectorAll('.alert');
        alerts.forEach(alert => {
            alert.style.transition = 'opacity 0.5s';
            alert.style.opacity = '0';
            setTimeout(() => alert.remove(), 500);
        });
    }, 5000);
</script>
</body>
</html>
