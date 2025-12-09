<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Catálogo de Productos - TechZone</title>

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

        .catalog-container {
            max-width: 1600px;
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
        }

        .breadcrumb a {
            color: var(--primary-color);
            text-decoration: none;
            transition: color 0.3s ease;
        }

        .breadcrumb a:hover {
            color: var(--primary-hover);
        }

        /* Header */
        .catalog-header {
            margin-bottom: 40px;
        }

        .catalog-title {
            font-size: 2.5rem;
            font-weight: bold;
            margin-bottom: 10px;
            background: linear-gradient(135deg, var(--primary-color), var(--secondary-color));
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }

        .catalog-subtitle {
            font-size: 1.1rem;
            color: var(--text-secondary);
        }

        /* Main Layout */
        .catalog-layout {
            display: grid;
            grid-template-columns: 280px 1fr;
            gap: 30px;
        }

        /* Sidebar Filters */
        .filters-sidebar {
            background: var(--dark-color);
            border-radius: 15px;
            padding: 25px;
            border: 1px solid var(--border-color);
            height: fit-content;
            position: sticky;
            top: 20px;
        }

        .filters-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 25px;
            padding-bottom: 15px;
            border-bottom: 2px solid var(--border-color);
        }

        .filters-title {
            font-size: 1.2rem;
            font-weight: bold;
            color: var(--text-primary);
        }

        .btn-clear-filters {
            background: transparent;
            border: none;
            color: var(--primary-color);
            font-size: 0.85rem;
            cursor: pointer;
            font-weight: 600;
            transition: color 0.3s ease;
        }

        .btn-clear-filters:hover {
            color: var(--primary-hover);
        }

        .filter-group {
            margin-bottom: 25px;
        }

        .filter-group-title {
            font-weight: 600;
            margin-bottom: 15px;
            color: var(--text-primary);
            font-size: 0.95rem;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .filter-group-title svg {
            width: 18px;
            height: 18px;
            fill: var(--primary-color);
        }

        /* Search Filter */
        .search-input {
            width: 100%;
            padding: 10px 15px;
            background: rgba(255, 255, 255, 0.05);
            border: 1px solid var(--border-color);
            border-radius: 8px;
            color: var(--text-primary);
            font-size: 0.9rem;
            transition: all 0.3s ease;
        }

        .search-input:focus {
            outline: none;
            background: rgba(255, 255, 255, 0.08);
            border-color: var(--primary-color);
            box-shadow: 0 0 0 3px rgba(0, 212, 255, 0.1);
        }

        .search-input::placeholder {
            color: rgba(255, 255, 255, 0.3);
        }

        /* Price Range */
        .price-inputs {
            display: grid;
            grid-template-columns: 1fr auto 1fr;
            gap: 10px;
            align-items: center;
        }

        .price-input {
            padding: 8px 12px;
            background: rgba(255, 255, 255, 0.05);
            border: 1px solid var(--border-color);
            border-radius: 6px;
            color: var(--text-primary);
            font-size: 0.85rem;
        }

        .price-separator {
            color: var(--text-secondary);
            font-weight: bold;
        }

        /* Checkbox Filters */
        .filter-options {
            display: flex;
            flex-direction: column;
            gap: 10px;
            max-height: 200px;
            overflow-y: auto;
            padding-right: 5px;
        }

        .filter-options::-webkit-scrollbar {
            width: 6px;
        }

        .filter-options::-webkit-scrollbar-track {
            background: rgba(255, 255, 255, 0.05);
            border-radius: 3px;
        }

        .filter-options::-webkit-scrollbar-thumb {
            background: var(--primary-color);
            border-radius: 3px;
        }

        .filter-option {
            display: flex;
            align-items: center;
            gap: 10px;
            cursor: pointer;
            padding: 8px;
            border-radius: 6px;
            transition: background 0.3s ease;
        }

        .filter-option:hover {
            background: rgba(255, 255, 255, 0.05);
        }

        .filter-checkbox {
            width: 18px;
            height: 18px;
            border: 2px solid var(--border-color);
            border-radius: 4px;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: all 0.3s ease;
        }

        .filter-option input[type="checkbox"] {
            display: none;
        }

        .filter-option input[type="checkbox"]:checked + .filter-checkbox {
            background: var(--primary-color);
            border-color: var(--primary-color);
        }

        .filter-option input[type="checkbox"]:checked + .filter-checkbox::after {
            content: '✓';
            color: #000;
            font-weight: bold;
            font-size: 0.85rem;
        }

        .filter-label {
            flex: 1;
            font-size: 0.9rem;
            color: var(--text-secondary);
        }

        .filter-count {
            font-size: 0.8rem;
            color: var(--text-secondary);
            background: rgba(255, 255, 255, 0.05);
            padding: 2px 8px;
            border-radius: 10px;
        }

        /* Products Section */
        .products-section {
            display: flex;
            flex-direction: column;
        }

        /* Toolbar */
        .products-toolbar {
            background: var(--dark-color);
            border-radius: 15px;
            padding: 20px 25px;
            margin-bottom: 30px;
            border: 1px solid var(--border-color);
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 20px;
        }

        .results-info {
            font-size: 0.95rem;
            color: var(--text-secondary);
        }

        .results-count {
            color: var(--primary-color);
            font-weight: bold;
        }

        .toolbar-actions {
            display: flex;
            gap: 15px;
            align-items: center;
        }

        .view-toggle {
            display: flex;
            gap: 5px;
            background: rgba(255, 255, 255, 0.05);
            padding: 5px;
            border-radius: 8px;
        }

        .view-btn {
            background: transparent;
            border: none;
            padding: 8px 12px;
            cursor: pointer;
            border-radius: 6px;
            transition: all 0.3s ease;
            color: var(--text-secondary);
        }

        .view-btn:hover,
        .view-btn.active {
            background: var(--primary-color);
            color: #000;
        }

        .view-btn svg {
            width: 20px;
            height: 20px;
            fill: currentColor;
        }

        .sort-select {
            padding: 10px 35px 10px 15px;
            background: rgba(255, 255, 255, 0.05);
            border: 1px solid var(--border-color);
            border-radius: 8px;
            color: var(--text-primary);
            font-size: 0.9rem;
            cursor: pointer;
            appearance: none;
            background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='%2300d4ff'%3E%3Cpath d='M7 10l5 5 5-5z'/%3E%3C/svg%3E");
            background-repeat: no-repeat;
            background-position: right 10px center;
            background-size: 20px;
        }

        .sort-select:focus {
            outline: none;
            border-color: var(--primary-color);
            box-shadow: 0 0 0 3px rgba(0, 212, 255, 0.1);
        }

        /* Products Grid */
        .products-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
            gap: 30px;
            margin-bottom: 40px;
        }

        .products-grid.list-view {
            grid-template-columns: 1fr;
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

        .btn-clear-all {
            background: linear-gradient(135deg, var(--primary-color), var(--secondary-color));
            color: #000;
            padding: 12px 30px;
            border: none;
            border-radius: 8px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            box-shadow: 0 5px 15px rgba(0, 212, 255, 0.3);
        }

        .btn-clear-all:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 20px rgba(0, 212, 255, 0.4);
        }

        /* Pagination */
        .pagination {
            display: flex;
            justify-content: center;
            gap: 10px;
            flex-wrap: wrap;
        }

        .page-btn {
            padding: 10px 18px;
            background: var(--dark-color);
            border: 1px solid var(--border-color);
            color: var(--text-primary);
            border-radius: 8px;
            cursor: pointer;
            font-weight: 600;
            transition: all 0.3s ease;
            text-decoration: none;
        }

        .page-btn:hover {
            background: var(--light-color);
            border-color: var(--primary-color);
            transform: translateY(-2px);
        }

        .page-btn.active {
            background: linear-gradient(135deg, var(--primary-color), var(--secondary-color));
            color: #000;
            border-color: transparent;
        }

        .page-btn:disabled {
            opacity: 0.5;
            cursor: not-allowed;
            transform: none;
        }

        /* Loading State */
        .loading-overlay {
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: rgba(10, 10, 10, 0.8);
            display: none;
            align-items: center;
            justify-content: center;
            z-index: 9999;
        }

        .loading-overlay.active {
            display: flex;
        }

        .loading-spinner {
            width: 50px;
            height: 50px;
            border: 4px solid rgba(0, 212, 255, 0.2);
            border-top-color: var(--primary-color);
            border-radius: 50%;
            animation: spin 1s linear infinite;
        }

        @keyframes spin {
            to { transform: rotate(360deg); }
        }

        /* Mobile Filters Toggle */
        .mobile-filters-toggle {
            display: none;
            width: 100%;
            padding: 15px;
            background: var(--dark-color);
            border: 1px solid var(--border-color);
            border-radius: 10px;
            color: var(--text-primary);
            font-weight: 600;
            margin-bottom: 20px;
            cursor: pointer;
            transition: all 0.3s ease;
        }

        .mobile-filters-toggle:hover {
            background: var(--light-color);
            border-color: var(--primary-color);
        }

        /* Responsive */
        @media (max-width: 1200px) {
            body {
                padding-right: 0;
            }
            
            .catalog-layout {
                grid-template-columns: 1fr;
            }

            .filters-sidebar {
                position: static;
                display: none;
            }

            .mobile-filters-toggle {
                display: block;
            }

            .filters-sidebar.mobile-open {
                display: block;
                margin-bottom: 30px;
                position: relative;
            }
        }

        @media (max-width: 768px) {
            .catalog-container {
                padding: 20px 15px;
            }

            .catalog-title {
                font-size: 2rem;
            }

            .products-toolbar {
                flex-direction: column;
                gap: 15px;
                padding: 15px;
            }

            .toolbar-actions {
                width: 100%;
                flex-wrap: wrap;
                gap: 10px;
            }

            .products-grid {
                grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
                gap: 15px;
            }
            
            .results-info {
                width: 100%;
                text-align: center;
            }
        }

        @media (max-width: 480px) {
            .products-grid {
                grid-template-columns: 1fr;
            }

            .price-inputs {
                grid-template-columns: 1fr;
            }

            .price-separator {
                display: none;
            }
            
            .view-toggle {
                flex: 1;
            }
            
            .sort-select {
                flex: 1;
                min-width: 150px;
            }
        }
    </style>
</head>
<body>
<!-- Include Header -->
<%@ include file="/views/components/header.jsp" %>

<!-- Loading Overlay -->
<div class="loading-overlay" id="loadingOverlay">
    <div class="loading-spinner"></div>
</div>

<div class="catalog-container">
    <!-- Breadcrumb -->
    <nav class="breadcrumb">
        <a href="${pageContext.request.contextPath}/">Inicio</a>
        <span>/</span>
        <span>Catálogo</span>
        <c:if test="${not empty categoriaActual}">
            <span>/</span>
            <span>${categoriaActual.nombre}</span>
        </c:if>
    </nav>

    <!-- Header -->
    <div class="catalog-header">
        <h1 class="catalog-title">
            <c:choose>
                <c:when test="${not empty categoriaActual}">
                    ${categoriaActual.nombre}
                </c:when>
                <c:otherwise>
                    Catálogo de Productos
                </c:otherwise>
            </c:choose>
        </h1>
        <p class="catalog-subtitle">
            Descubre nuestra selección de productos tecnológicos
        </p>
    </div>

    <!-- Mobile Filters Toggle -->
    <button class="mobile-filters-toggle" onclick="toggleMobileFilters()">
        <i class="fas fa-filter"></i> Filtros
    </button>

    <!-- Main Layout -->
    <div class="catalog-layout">
        <!-- Filters Sidebar -->
        <aside class="filters-sidebar" id="filtersSidebar">
            <div class="filters-header">
                <h2 class="filters-title">Filtros</h2>
                <button class="btn-clear-filters" onclick="clearAllFilters()">
                    Limpiar todo
                </button>
            </div>

            <form id="filtersForm" method="GET" action="${pageContext.request.contextPath}/productos">
                <!-- Search Filter -->
                <div class="filter-group">
                    <div class="filter-group-title">
                        <svg viewBox="0 0 24 24">
                            <path d="M15.5 14h-.79l-.28-.27C15.41 12.59 16 11.11 16 9.5 16 5.91 13.09 3 9.5 3S3 5.91 3 9.5 5.91 16 9.5 16c1.61 0 3.09-.59 4.23-1.57l.27.28v.79l5 4.99L20.49 19l-4.99-5zm-6 0C7.01 14 5 11.99 5 9.5S7.01 5 9.5 5 14 7.01 14 9.5 11.99 14 9.5 14z"/>
                        </svg>
                        Buscar
                    </div>
                    <input type="text" 
                           name="buscar" 
                           class="search-input" 
                           placeholder="Nombre del producto..."
                           value="${param.buscar}">
                </div>

                <!-- Price Range -->
                <div class="filter-group">
                    <div class="filter-group-title">
                        <svg viewBox="0 0 24 24">
                            <path d="M11.8 10.9c-2.27-.59-3-1.2-3-2.15 0-1.09 1.01-1.85 2.7-1.85 1.78 0 2.44.85 2.5 2.1h2.21c-.07-1.72-1.12-3.3-3.21-3.81V3h-3v2.16c-1.94.42-3.5 1.68-3.5 3.61 0 2.31 1.91 3.46 4.7 4.13 2.5.6 3 1.48 3 2.41 0 .69-.49 1.79-2.7 1.79-2.06 0-2.87-.92-2.98-2.1h-2.2c.12 2.19 1.76 3.42 3.68 3.83V21h3v-2.15c1.95-.37 3.5-1.5 3.5-3.55 0-2.84-2.43-3.81-4.7-4.4z"/>
                        </svg>
                        Rango de Precio
                    </div>
                    <div class="price-inputs">
                        <input type="number" 
                               name="precioMin" 
                               class="price-input" 
                               placeholder="Mín"
                               value="${param.precioMin}"
                               min="0"
                               step="0.01">
                        <span class="price-separator">-</span>
                        <input type="number" 
                               name="precioMax" 
                               class="price-input" 
                               placeholder="Máx"
                               value="${param.precioMax}"
                               min="0"
                               step="0.01">
                    </div>
                </div>

                <!-- Categories -->
                <div class="filter-group">
                    <div class="filter-group-title">
                        <svg viewBox="0 0 24 24">
                            <path d="M12 2l-5.5 9h11L12 2zm0 3.84L13.93 9h-3.87L12 5.84zM17.5 13c-2.49 0-4.5 2.01-4.5 4.5s2.01 4.5 4.5 4.5 4.5-2.01 4.5-4.5-2.01-4.5-4.5-4.5zm0 7c-1.38 0-2.5-1.12-2.5-2.5s1.12-2.5 2.5-2.5 2.5 1.12 2.5 2.5-1.12 2.5-2.5 2.5zM3 21.5h8v-8H3v8zm2-6h4v4H5v-4z"/>
                        </svg>
                        Categorías
                    </div>
                    <div class="filter-options">
                        <c:forEach items="${categorias}" var="categoria">
                            <label class="filter-option">
                                <input type="checkbox" 
                                       name="categoria" 
                                       value="${categoria.idCategoria}"
                                       ${param.categoria == categoria.idCategoria ? 'checked' : ''}>
                                <span class="filter-checkbox"></span>
                                <span class="filter-label">${categoria.nombre}</span>
                                <span class="filter-count">${categoria.cantidadProductos}</span>
                            </label>
                        </c:forEach>
                    </div>
                </div>

                <!-- Brands -->
                <c:if test="${not empty marcas}">
                    <div class="filter-group">
                        <div class="filter-group-title">
                            <svg viewBox="0 0 24 24">
                                <path d="M12 2L2 7l10 5 10-5-10-5zM2 17l10 5 10-5M2 12l10 5 10-5"/>
                            </svg>
                            Marcas
                        </div>
                        <div class="filter-options">
                            <c:forEach items="${marcas}" var="marca">
                                <label class="filter-option">
                                    <input type="checkbox" 
                                           name="marca" 
                                           value="${marca.nombre}">
                                    <span class="filter-checkbox"></span>
                                    <span class="filter-label">${marca.nombre}</span>
                                    <span class="filter-count">${marca.cantidad}</span>
                                </label>
                            </c:forEach>
                        </div>
                    </div>
                </c:if>

                <!-- Stock Status -->
                <div class="filter-group">
                    <div class="filter-group-title">
                        <svg viewBox="0 0 24 24">
                            <path d="M20 6h-2.18c.11-.31.18-.65.18-1 0-1.66-1.34-3-3-3-1.05 0-1.96.54-2.5 1.35l-.5.67-.5-.68C10.96 2.54 10.05 2 9 2 7.34 2 6 3.34 6 5c0 .35.07.69.18 1H4c-1.11 0-1.99.89-1.99 2L2 19c0 1.11.89 2 2 2h16c1.11 0 2-.89 2-2V8c0-1.11-.89-2-2-2zm-5-2c.55 0 1 .45 1 1s-.45 1-1 1-1-.45-1-1 .45-1 1-1zM9 4c.55 0 1 .45 1 1s-.45 1-1 1-1-.45-1-1 .45-1 1-1zm11 15H4v-2h16v2zm0-5H4V8h5.08L7 10.83 8.62 12 11 8.76l1-1.36 1 1.36L15.38 12 17 10.83 14.92 8H20v6z"/>
                        </svg>
                        Disponibilidad
                    </div>
                    <div class="filter-options">
                        <label class="filter-option">
                            <input type="checkbox" name="stock" value="disponible">
                            <span class="filter-checkbox"></span>
                            <span class="filter-label">En stock</span>
                        </label>
                        <label class="filter-option">
                            <input type="checkbox" name="stock" value="agotado">
                            <span class="filter-checkbox"></span>
                            <span class="filter-label">Agotado</span>
                        </label>
                    </div>
                </div>

                <!-- Apply Filters Button -->
                <button type="submit" class="btn-clear-all" style="width: 100%; margin-top: 20px;">
                    <i class="fas fa-check"></i> Aplicar Filtros
                </button>
            </form>
        </aside>

        <!-- Products Section -->
        <main class="products-section">
            <!-- Toolbar -->
            <div class="products-toolbar">
                <div class="results-info">
                    Mostrando <span class="results-count">${totalProductos}</span> productos
                    <c:if test="${not empty param.buscar}">
                        para "<strong>${param.buscar}</strong>"
                    </c:if>
                </div>

                <div class="toolbar-actions">
                    <!-- View Toggle -->
                    <div class="view-toggle">
                        <button class="view-btn active"
                                onclick="setView('grid')"
                                id="gridViewBtn"
                                title="Vista en cuadrícula">
                            <svg viewBox="0 0 24 24">
                                <path d="M4 11h5V5H4v6zm0 7h5v-6H4v6zm6 0h5v-6h-5v6zm6 0h5v-6h-5v6zm-6-7h5V5h-5v6zm6-6v6h5V5h-5z"/>
                            </svg>
                        </button>
                        <button class="view-btn"
                                onclick="setView('list')"
                                id="listViewBtn"
                                title="Vista en lista">
                            <svg viewBox="0 0 24 24">
                                <path d="M3 13h2v-2H3v2zm0 4h2v-2H3v2zm0-8h2V7H3v2zm4 4h14v-2H7v2zm0 4h14v-2H7v2zM7 7v2h14V7H7z"/>
                            </svg>
                        </button>
                    </div>

                    <!-- Sort -->
                    <select class="sort-select" name="orden" onchange="this.form.submit()">
                        <option value="recientes" ${param.orden == 'recientes' ? 'selected' : ''}>
                            Más recientes
                        </option>
                        <option value="precio-asc" ${param.orden == 'precio-asc' ? 'selected' : ''}>
                            Precio: menor a mayor
                        </option>
                        <option value="precio-desc" ${param.orden == 'precio-desc' ? 'selected' : ''}>
                            Precio: mayor a menor
                        </option>
                        <option value="nombre" ${param.orden == 'nombre' ? 'selected' : ''}>
                            Nombre A-Z
                        </option>
                        <option value="populares" ${param.orden == 'populares' ? 'selected' : ''}>
                            Más populares
                        </option>
                    </select>
                </div>

                    <!-- Products Grid -->
                    <c:choose>
                    <c:when test="${empty productos or productos.size() == 0}">
                    <div class="empty-state">
                        <div class="empty-icon">
                            <i class="fas fa-box-open"></i>
                        </div>
                        <h2 class="empty-title">No se encontraron productos</h2>
                        <p class="empty-text">
                            <c:choose>
                                <c:when test="${not empty param.buscar or not empty param.categoria or not empty param.precioMin or not empty param.precioMax}">
                                    Intenta ajustar tus filtros de búsqueda
                                </c:when>
                                <c:otherwise>
                                    No hay productos disponibles en este momento
                                </c:otherwise>
                            </c:choose>
                        </p>
                        <c:if test="${not empty param.buscar or not empty param.categoria or not empty param.precioMin or not empty param.precioMax}">
                            <button class="btn-clear-all" onclick="clearAllFilters()">
                                <i class="fas fa-redo"></i> Limpiar filtros
                            </button>
                        </c:if>
                    </div>
                    </c:when>
                    <c:otherwise>
                    <div class="products-grid" id="productsGrid">
                        <c:forEach items="${productos}" var="producto">
                            <%@ include file="/views/components/producto-card.jsp" %>
                        </c:forEach>
                    </div>

                    <!-- Pagination -->
                    <c:if test="${totalPaginas > 1}">
                    <div class="pagination">
                        <c:if test="${paginaActual > 1}">
                            <a href="?pagina=${paginaActual - 1}${parametrosUrl}" class="page-btn">
                                <i class="fas fa-chevron-left"></i>
                            </a>
                        </c:if>

                        <c:forEach begin="1" end="${totalPaginas}" var="i">
                            <c:choose>
                                <c:when test="${i == paginaActual}">
                                    <span class="page-btn active">${i}</span>
                                </c:when>
                                <c:when test="${i <= 3 or i >= totalPaginas - 2 or (i >= paginaActual - 1 and i <= paginaActual + 1)}">
                                    <a href="?pagina=${i}${parametrosUrl}" class="page-btn">${i}</a>
                                </c:when>
                                <c:when test="${i == 4 or i == totalPaginas - 3}">
                                    <span class="page-btn" style="pointer-events: none;">...</span>
                                </c:when>
                            </c:choose>
                        </c:forEach>

                        <c:if test="${paginaActual < totalPaginas}">
                            <a href="?pagina=${paginaActual + 1}${parametrosUrl}" class="page-btn">
                                <i class="fas fa-chevron-right"></i>
                            </a>
                        </c:if>
                    </div>
                    </c:if>
                    </c:otherwise>
                    </c:choose>
        </main>
    </div>
</div>

<!-- Include Footer -->
<%@ include file="/views/components/footer.jsp" %>

<script>
    // Mobile filters toggle
    function toggleMobileFilters() {
        const sidebar = document.getElementById('filtersSidebar');
        sidebar.classList.toggle('mobile-open');
    }

    // Clear all filters
    function clearAllFilters() {
        window.location.href = '${pageContext.request.contextPath}/productos';
    }

    // View toggle
    function setView(viewType) {
        const grid = document.getElementById('productsGrid');
        const gridBtn = document.getElementById('gridViewBtn');
        const listBtn = document.getElementById('listViewBtn');

        if (viewType === 'grid') {
            grid.classList.remove('list-view');
            gridBtn.classList.add('active');
            listBtn.classList.remove('active');
            localStorage.setItem('catalogView', 'grid');
        } else {
            grid.classList.add('list-view');
            listBtn.classList.add('active');
            gridBtn.classList.remove('active');
            localStorage.setItem('catalogView', 'list');
        }
    }

    // Restore view preference
    document.addEventListener('DOMContentLoaded', function() {
        const savedView = localStorage.getItem('catalogView');
        if (savedView === 'list') {
            setView('list');
        }

        // Auto-submit form on filter change
        const checkboxes = document.querySelectorAll('input[type="checkbox"]');
        checkboxes.forEach(checkbox => {
            checkbox.addEventListener('change', function() {
                // Optional: auto-submit on checkbox change
                // document.getElementById('filtersForm').submit();
            });
        });
    });

    // Show loading overlay on form submit
    document.getElementById('filtersForm').addEventListener('submit', function() {
        document.getElementById('loadingOverlay').classList.add('active');
    });

    // Hide loading on page load
    window.addEventListener('load', function() {
        document.getElementById('loadingOverlay').classList.remove('active');
    });
</script>
</body>
</html>
