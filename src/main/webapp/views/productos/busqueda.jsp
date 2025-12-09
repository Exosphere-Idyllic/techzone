<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Búsqueda: ${param.q} - TechZone</title>

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

        .search-container {
            max-width: 1600px;
            margin: 0 auto;
            padding: 40px 20px 60px;
        }

        /* Search Header */
        .search-header {
            background: var(--dark-color);
            border-radius: 15px;
            padding: 40px;
            margin-bottom: 40px;
            border: 1px solid var(--border-color);
        }

        .search-title {
            font-size: 2rem;
            margin-bottom: 10px;
        }

        .search-query {
            color: var(--primary-color);
        }

        .search-results-info {
            color: var(--text-secondary);
            font-size: 1rem;
            margin-bottom: 30px;
        }

        /* Advanced Search Box */
        .search-box-advanced {
            position: relative;
        }

        .search-input-wrapper {
            display: flex;
            gap: 15px;
        }

        .search-input {
            flex: 1;
            padding: 18px 50px 18px 20px;
            background: rgba(255, 255, 255, 0.05);
            border: 2px solid var(--border-color);
            border-radius: 12px;
            color: var(--text-primary);
            font-size: 1.1rem;
            transition: all 0.3s ease;
        }

        .search-input:focus {
            outline: none;
            background: rgba(255, 255, 255, 0.08);
            border-color: var(--primary-color);
            box-shadow: 0 0 0 4px rgba(0, 212, 255, 0.1);
        }

        .search-icon {
            position: absolute;
            right: 20px;
            top: 50%;
            transform: translateY(-50%);
            color: var(--text-secondary);
            pointer-events: none;
        }

        .btn-search {
            padding: 18px 40px;
            background: linear-gradient(135deg, var(--primary-color), var(--secondary-color));
            border: none;
            border-radius: 12px;
            color: #000;
            font-weight: 700;
            font-size: 1.1rem;
            cursor: pointer;
            transition: all 0.3s ease;
            box-shadow: 0 5px 20px rgba(0, 212, 255, 0.3);
        }

        .btn-search:hover {
            transform: translateY(-3px);
            box-shadow: 0 10px 30px rgba(0, 212, 255, 0.5);
        }

        /* Autocomplete Suggestions */
        .search-suggestions {
            position: absolute;
            top: 100%;
            left: 0;
            right: 150px;
            background: var(--dark-color);
            border: 1px solid var(--border-color);
            border-radius: 12px;
            margin-top: 10px;
            max-height: 400px;
            overflow-y: auto;
            z-index: 1000;
            display: none;
            box-shadow: 0 10px 40px rgba(0, 0, 0, 0.5);
        }

        .search-suggestions.active {
            display: block;
        }

        .suggestion-item {
            padding: 15px 20px;
            cursor: pointer;
            transition: all 0.3s ease;
            display: flex;
            align-items: center;
            gap: 15px;
            border-bottom: 1px solid var(--border-color);
        }

        .suggestion-item:last-child {
            border-bottom: none;
        }

        .suggestion-item:hover {
            background: var(--light-color);
        }

        .suggestion-icon {
            width: 40px;
            height: 40px;
            background: var(--light-color);
            border-radius: 8px;
            display: flex;
            align-items: center;
            justify-content: center;
            flex-shrink: 0;
        }

        .suggestion-icon svg {
            width: 20px;
            height: 20px;
            fill: var(--primary-color);
        }

        .suggestion-content {
            flex: 1;
        }

        .suggestion-title {
            font-weight: 600;
            margin-bottom: 3px;
        }

        .suggestion-meta {
            font-size: 0.85rem;
            color: var(--text-secondary);
        }

        /* Quick Filters */
        .quick-filters {
            display: flex;
            gap: 10px;
            flex-wrap: wrap;
            margin-top: 20px;
        }

        .filter-chip {
            padding: 8px 16px;
            background: rgba(0, 212, 255, 0.1);
            border: 1px solid var(--primary-color);
            border-radius: 20px;
            color: var(--primary-color);
            font-size: 0.9rem;
            cursor: pointer;
            transition: all 0.3s ease;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 8px;
        }

        .filter-chip:hover {
            background: var(--primary-color);
            color: #000;
        }

        .filter-chip.active {
            background: var(--primary-color);
            color: #000;
        }

        /* Search Stats */
        .search-stats {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-bottom: 40px;
        }

        .stat-card {
            background: var(--dark-color);
            border-radius: 12px;
            padding: 25px;
            border: 1px solid var(--border-color);
            text-align: center;
        }

        .stat-value {
            font-size: 2.5rem;
            font-weight: bold;
            color: var(--primary-color);
            margin-bottom: 5px;
        }

        .stat-label {
            color: var(--text-secondary);
            font-size: 0.9rem;
        }

        /* Results Layout */
        .results-layout {
            display: grid;
            grid-template-columns: 280px 1fr;
            gap: 30px;
        }

        /* Filters Sidebar */
        .filters-sidebar {
            background: var(--dark-color);
            border-radius: 15px;
            padding: 25px;
            border: 1px solid var(--border-color);
            height: fit-content;
            position: sticky;
            top: 20px;
        }

        .filters-title {
            font-size: 1.2rem;
            font-weight: bold;
            margin-bottom: 20px;
            padding-bottom: 15px;
            border-bottom: 2px solid var(--border-color);
        }

        .filter-group {
            margin-bottom: 25px;
        }

        .filter-group-title {
            font-weight: 600;
            margin-bottom: 12px;
            color: var(--text-primary);
            font-size: 0.95rem;
        }

        .filter-options {
            display: flex;
            flex-direction: column;
            gap: 10px;
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

        /* Results Section */
        .results-section {
            display: flex;
            flex-direction: column;
        }

        /* Toolbar */
        .results-toolbar {
            background: var(--dark-color);
            border-radius: 12px;
            padding: 20px 25px;
            margin-bottom: 30px;
            border: 1px solid var(--border-color);
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 15px;
        }

        .results-count {
            font-size: 0.95rem;
            color: var(--text-secondary);
        }

        .results-count strong {
            color: var(--primary-color);
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

        /* Products Grid */
        .products-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
            gap: 30px;
            margin-bottom: 40px;
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
        }

        .empty-text {
            color: var(--text-secondary);
            margin-bottom: 25px;
            font-size: 1.1rem;
        }

        .empty-suggestions {
            margin-top: 30px;
        }

        .empty-suggestions-title {
            font-size: 1.2rem;
            margin-bottom: 15px;
            color: var(--text-primary);
        }

        .suggestions-list {
            display: flex;
            gap: 10px;
            justify-content: center;
            flex-wrap: wrap;
        }

        .suggestion-tag {
            padding: 10px 20px;
            background: var(--dark-color);
            border: 1px solid var(--border-color);
            border-radius: 20px;
            color: var(--text-primary);
            text-decoration: none;
            transition: all 0.3s ease;
        }

        .suggestion-tag:hover {
            background: var(--primary-color);
            color: #000;
            border-color: var(--primary-color);
        }

        /* Popular Searches */
        .popular-searches {
            background: var(--dark-color);
            border-radius: 15px;
            padding: 30px;
            margin-bottom: 40px;
            border: 1px solid var(--border-color);
        }

        .popular-title {
            font-size: 1.3rem;
            font-weight: bold;
            margin-bottom: 20px;
        }

        .popular-items {
            display: flex;
            gap: 12px;
            flex-wrap: wrap;
        }

        .popular-item {
            padding: 10px 20px;
            background: rgba(0, 212, 255, 0.1);
            border: 1px solid var(--primary-color);
            border-radius: 20px;
            color: var(--primary-color);
            text-decoration: none;
            transition: all 0.3s ease;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .popular-item:hover {
            background: var(--primary-color);
            color: #000;
            transform: translateY(-2px);
        }

        .popular-item svg {
            width: 16px;
            height: 16px;
            fill: currentColor;
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

        /* Mobile Toggle */
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
        }

        /* Responsive */
        @media (max-width: 1024px) {
            .results-layout {
                grid-template-columns: 1fr;
            }

            .filters-sidebar {
                position: static;
            }

            .mobile-filters-toggle {
                display: block;
            }

            .filters-sidebar {
                display: none;
            }

            .filters-sidebar.mobile-open {
                display: block;
                margin-bottom: 30px;
            }
        }

        @media (max-width: 768px) {
            body {
                padding-right: 0;
            }

            .search-container {
                padding: 20px 15px;
            }

            .search-header {
                padding: 25px 20px;
            }

            .search-title {
                font-size: 1.5rem;
            }

            .search-input-wrapper {
                flex-direction: column;
            }

            .products-grid {
                grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
                gap: 20px;
            }

            .search-stats {
                grid-template-columns: repeat(2, 1fr);
            }
        }

        @media (max-width: 480px) {
            .products-grid {
                grid-template-columns: 1fr;
            }

            .search-stats {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>
<!-- Include Header -->
<%@ include file="/views/components/header.jsp" %>

<div class="search-container">
    <!-- Search Header -->
    <div class="search-header">
        <h1 class="search-title">
            <c:choose>
                <c:when test="${not empty param.q}">
                    Resultados para: <span class="search-query">"${param.q}"</span>
                </c:when>
                <c:otherwise>
                    Búsqueda Avanzada
                </c:otherwise>
            </c:choose>
        </h1>
        
        <c:if test="${not empty productos}">
            <p class="search-results-info">
                Encontramos <strong>${totalProductos}</strong> productos que coinciden con tu búsqueda
            </p>
        </c:if>

        <!-- Advanced Search Box -->
        <form action="${pageContext.request.contextPath}/buscar" method="GET">
            <div class="search-box-advanced">
                <div class="search-input-wrapper">
                    <div style="position: relative; flex: 1;">
                        <input type="text" 
                               name="q" 
                               class="search-input" 
                               placeholder="Buscar productos, marcas, categorías..."
                               value="${param.q}"
                               id="searchInput"
                               autocomplete="off"
                               autofocus>
                        <i class="fas fa-search search-icon"></i>
                        
                        <!-- Autocomplete Suggestions -->
                        <div class="search-suggestions" id="suggestions"></div>
                    </div>
                    <button type="submit" class="btn-search">
                        <i class="fas fa-search"></i> Buscar
                    </button>
                </div>

                <!-- Quick Filters -->
                <div class="quick-filters">
                    <a href="${pageContext.request.contextPath}/buscar?q=${param.q}&categoria=1" 
                       class="filter-chip ${param.categoria == '1' ? 'active' : ''}">
                        <i class="fas fa-laptop"></i> Laptops
                    </a>
                    <a href="${pageContext.request.contextPath}/buscar?q=${param.q}&categoria=2" 
                       class="filter-chip ${param.categoria == '2' ? 'active' : ''}">
                        <i class="fas fa-mobile-alt"></i> Smartphones
                    </a>
                    <a href="${pageContext.request.contextPath}/buscar?q=${param.q}&categoria=3" 
                       class="filter-chip ${param.categoria == '3' ? 'active' : ''}">
                        <i class="fas fa-tablet-alt"></i> Tablets
                    </a>
                    <a href="${pageContext.request.contextPath}/buscar?q=${param.q}&enOferta=true" 
                       class="filter-chip ${param.enOferta == 'true' ? 'active' : ''}">
                        <i class="fas fa-tags"></i> En Oferta
                    </a>
                    <a href="${pageContext.request.contextPath}/buscar?q=${param.q}&envioGratis=true" 
                       class="filter-chip ${param.envioGratis == 'true' ? 'active' : ''}">
                        <i class="fas fa-truck"></i> Envío Gratis
                    </a>
                </div>
            </div>
        </form>
    </div>

    <c:choose>
        <c:when test="${not empty productos}">
            <!-- Search Stats -->
            <div class="search-stats">
                <div class="stat-card">
                    <div class="stat-value">${totalProductos}</div>
                    <div class="stat-label">Productos Encontrados</div>
                </div>
                <div class="stat-card">
                    <div class="stat-value">${categoriasEncontradas}</div>
                    <div class="stat-label">Categorías</div>
                </div>
                <div class="stat-card">
                    <div class="stat-value">${marcasEncontradas}</div>
                    <div class="stat-label">Marcas</div>
                </div>
                <div class="stat-card">
                    <div class="stat-value">${productosEnOferta}</div>
                    <div class="stat-label">En Oferta</div>
                </div>
            </div>

            <!-- Mobile Filters Toggle -->
            <button class="mobile-filters-toggle" onclick="toggleMobileFilters()">
                <i class="fas fa-filter"></i> Filtros
            </button>

            <!-- Results Layout -->
            <div class="results-layout">
                <!-- Filters Sidebar -->
                <aside class="filters-sidebar" id="filtersSidebar">
                    <h3 class="filters-title">Refinar Búsqueda</h3>

                    <form method="GET" action="${pageContext.request.contextPath}/buscar">
                        <input type="hidden" name="q" value="${param.q}">

                        <!-- Price Range -->
                        <div class="filter-group">
                            <div class="filter-group-title">Rango de Precio</div>
                            <div style="display: grid; grid-template-columns: 1fr auto 1fr; gap: 10px; align-items: center;">
                                <input type="number" 
                                       name="precioMin" 
                                       placeholder="Mín"
                                       value="${param.precioMin}"
                                       style="padding: 8px; background: rgba(255,255,255,0.05); border: 1px solid var(--border-color); border-radius: 6px; color: var(--text-primary);">
                                <span>-</span>
                                <input type="number" 
                                       name="precioMax" 
                                       placeholder="Máx"
                                       value="${param.precioMax}"
                                       style="padding: 8px; background: rgba(255,255,255,0.05); border: 1px solid var(--border-color); border-radius: 6px; color: var(--text-primary);">
                            </div>
                        </div>

                        <!-- Categories -->
                        <c:if test="${not empty categorias}">
                            <div class="filter-group">
                                <div class="filter-group-title">Categorías</div>
                                <div class="filter-options">
                                    <c:forEach items="${categorias}" var="categoria">
                                        <label class="filter-option">
                                            <input type="checkbox" 
                                                   name="categorias" 
                                                   value="${categoria.idCategoria}">
                                            <span class="filter-checkbox"></span>
                                            <span class="filter-label">${categoria.nombre}</span>
                                        </label>
                                    </c:forEach>
                                </div>
                            </div>
                        </c:if>

                        <!-- Brands -->
                        <c:if test="${not empty marcas}">
                            <div class="filter-group">
                                <div class="filter-group-title">Marcas</div>
                                <div class="filter-options">
                                    <c:forEach items="${marcas}" var="marca">
                                        <label class="filter-option">
                                            <input type="checkbox" 
                                                   name="marcas" 
                                                   value="${marca}">
                                            <span class="filter-checkbox"></span>
                                            <span class="filter-label">${marca}</span>
                                        </label>
                                    </c:forEach>
                                </div>
                            </div>
                        </c:if>

                        <!-- Availability -->
                        <div class="filter-group">
                            <div class="filter-group-title">Disponibilidad</div>
                            <div class="filter-options">
                                <label class="filter-option">
                                    <input type="checkbox" name="enStock" value="true">
                                    <span class="filter-checkbox"></span>
                                    <span class="filter-label">En stock</span>
                                </label>
                                <label class="filter-option">
                                    <input type="checkbox" name="conDescuento" value="true">
                                    <span class="filter-checkbox"></span>
                                    <span class="filter-label">Con descuento</span>
                                </label>
                            </div>
                        </div>

                        <button type="submit" style="width: 100%; padding: 12px; background: var(--primary-color); color: #000; border: none; border-radius: 8px; font-weight: 600; cursor: pointer; margin-top: 20px;">
                            Aplicar Filtros
                        </button>
                    </form>
                </aside>

                <!-- Results Section -->
                <main class="results-section">
                    <!-- Toolbar -->
                    <div class="results-toolbar">
                        <div class="results-count">
                            Mostrando <strong>${productos.size()}</strong> de <strong>${totalProductos}</strong> resultados
                        </div>

                        <select class="sort-select" onchange="sortResults(this.value)">
                            <option value="">Ordenar por</option>
                            <option value="relevancia" ${param.orden == 'relevancia' ? 'selected' : ''}>
                                Más Relevantes
                            </option>
                            <option value="precio_asc" ${param.orden == 'precio_asc' ? 'selected' : ''}>
                                Precio: Menor a Mayor
                            </option>
                            <option value="precio_desc" ${param.orden == 'precio_desc' ? 'selected' : ''}>
                                Precio: Mayor a Menor
                            </option>
                            <option value="nombre_asc" ${param.orden == 'nombre_asc' ? 'selected' : ''}>
                                Nombre: A-Z
                            </option>
                        </select>
                    </div>

                    <!-- Products Grid -->
                    <div class="products-grid">
                        <c:forEach items="${productos}" var="producto">
                            <c:set var="producto" value="${producto}" scope="request"/>
                            <jsp:include page="/views/components/producto-card.jsp"/>
                        </c:forEach>
                    </div>

                    <!-- Pagination -->
                    <c:if test="${totalPaginas > 1}">
                        <nav class="pagination">
                            <c:if test="${paginaActual > 1}">
                                <a href="?q=${param.q}&pagina=${paginaActual - 1}" class="page-btn">
                                    <i class="fas fa-chevron-left"></i> Anterior
                                </a>
                            </c:if>

                            <c:forEach begin="1" end="${totalPaginas}" var="i">
                                <c:choose>
                                    <c:when test="${i == paginaActual}">
                                        <span class="page-btn active">${i}</span>
                                    </c:when>
                                    <c:otherwise>
                                        <a href="?q=${param.q}&pagina=${i}" class="page-btn">${i}</a>
                                    </c:otherwise>
                                </c:choose>
                            </c:forEach>

                            <c:if test="${paginaActual < totalPaginas}">
                                <a href="?q=${param.q}&pagina=${paginaActual + 1}" class="page-btn">
                                    Siguiente <i class="fas fa-chevron-right"></i>
                                </a>
                            </c:if>
                        </nav>
                    </c:if>
                </main>
            </div>
        </c:when>
        <c:otherwise>
            <!-- Empty State -->
            <div class="empty-state">
                <div class="empty-icon">
                    <i class="fas fa-search"></i>
                </div>
                <h2 class="empty-title">No encontramos resultados</h2>
                <p class="empty-text">
                    <c:choose>
                        <c:when test="${not empty param.q}">
                            No encontramos productos que coincidan con "<strong>${param.q}</strong>"
                        </c:when>
                        <c:otherwise>
                            Realiza una búsqueda para encontrar productos
                        </c:otherwise>
                    </c:choose>
                </p>

                <div class="empty-suggestions">
                    <h3 class="empty-suggestions-title">Intenta buscar:</h3>
                    <div class="suggestions-list">
                        <a href="${pageContext.request.contextPath}/buscar?q=laptop" class="suggestion-tag">Laptops</a>
                        <a href="${pageContext.request.contextPath}/buscar?q=smartphone" class="suggestion-tag">Smartphones</a>
                        <a href="${pageContext.request.contextPath}/buscar?q=tablet" class="suggestion-tag">Tablets</a>
                        <a href="${pageContext.request.contextPath}/buscar?q=auriculares" class="suggestion-tag">Auriculares</a>
                        <a href="${pageContext.request.contextPath}/buscar?q=mouse" class="suggestion-tag">Mouse</a>
                        <a href="${pageContext.request.contextPath}/buscar?q=teclado" class="suggestion-tag">Teclados</a>
                    </div>
                </div>
            </div>

            <!-- Popular Searches -->
            <div class="popular-searches">
                <h3 class="popular-title">
                    <i class="fas fa-fire" style="color: #ff4444; margin-right: 10px;"></i>
                    Búsquedas Populares
                </h3>
                <div class="popular-items">
                    <a href="${pageContext.request.contextPath}/buscar?q=laptop gaming" class="popular-item">
                        <svg viewBox="0 0 24 24">
                            <path d="M15.5 14h-.79l-.28-.27C15.41 12.59 16 11.11 16 9.5 16 5.91 13.09 3 9.5 3S3 5.91 3 9.5 5.91 16 9.5 16c1.61 0 3.09-.59 4.23-1.57l.27.28v.79l5 4.99L20.49 19l-4.99-5zm-6 0C7.01 14 5 11.99 5 9.5S7.01 5 9.5 5 14 7.01 14 9.5 11.99 14 9.5 14z"/>
                        </svg>
                        Laptop Gaming
                    </a>
                    <a href="${pageContext.request.contextPath}/buscar?q=iphone" class="popular-item">
                        <svg viewBox="0 0 24 24">
                            <path d="M15.5 14h-.79l-.28-.27C15.41 12.59 16 11.11 16 9.5 16 5.91 13.09 3 9.5 3S3 5.91 3 9.5 5.91 16 9.5 16c1.61 0 3.09-.59 4.23-1.57l.27.28v.79l5 4.99L20.49 19l-4.99-5zm-6 0C7.01 14 5 11.99 5 9.5S7.01 5 9.5 5 14 7.01 14 9.5 11.99 14 9.5 14z"/>
                        </svg>
                        iPhone
                    </a>
                    <a href="${pageContext.request.contextPath}/buscar?q=macbook" class="popular-item">
                        <svg viewBox="0 0 24 24">
                            <path d="M15.5 14h-.79l-.28-.27C15.41 12.59 16 11.11 16 9.5 16 5.91 13.09 3 9.5 3S3 5.91 3 9.5 5.91 16 9.5 16c1.61 0 3.09-.59 4.23-1.57l.27.28v.79l5 4.99L20.49 19l-4.99-5zm-6 0C7.01 14 5 11.99 5 9.5S7.01 5 9.5 5 14 7.01 14 9.5 11.99 14 9.5 14z"/>
                        </svg>
                        MacBook
                    </a>
                    <a href="${pageContext.request.contextPath}/buscar?q=monitor" class="popular-item">
                        <svg viewBox="0 0 24 24">
                            <path d="M15.5 14h-.79l-.28-.27C15.41 12.59 16 11.11 16 9.5 16 5.91 13.09 3 9.5 3S3 5.91 3 9.5 5.91 16 9.5 16c1.61 0 3.09-.59 4.23-1.57l.27.28v.79l5 4.99L20.49 19l-4.99-5zm-6 0C7.01 14 5 11.99 5 9.5S7.01 5 9.5 5 14 7.01 14 9.5 11.99 14 9.5 14z"/>
                        </svg>
                        Monitor 4K
                    </a>
                    <a href="${pageContext.request.contextPath}/buscar?q=webcam" class="popular-item">
                        <svg viewBox="0 0 24 24">
                            <path d="M15.5 14h-.79l-.28-.27C15.41 12.59 16 11.11 16 9.5 16 5.91 13.09 3 9.5 3S3 5.91 3 9.5 5.91 16 9.5 16c1.61 0 3.09-.59 4.23-1.57l.27.28v.79l5 4.99L20.49 19l-4.99-5zm-6 0C7.01 14 5 11.99 5 9.5S7.01 5 9.5 5 14 7.01 14 9.5 11.99 14 9.5 14z"/>
                        </svg>
                        Webcam HD
                    </a>
                </div>
            </div>
        </c:otherwise>
    </c:choose>
</div>

<!-- Include Footer -->
<%@ include file="/views/components/footer.jsp" %>

<script>
    // Toggle mobile filters
    function toggleMobileFilters() {
        const sidebar = document.getElementById('filtersSidebar');
        sidebar.classList.toggle('mobile-open');
    }

    // Sort results
    function sortResults(orden) {
        const url = new URL(window.location.href);
        if (orden) {
            url.searchParams.set('orden', orden);
        } else {
            url.searchParams.delete('orden');
        }
        window.location.href = url.toString();
    }

    // Simple autocomplete simulation
    const searchInput = document.getElementById('searchInput');
    const suggestions = document.getElementById('suggestions');

    const popularTerms = [
        { title: 'Laptop Gaming', category: 'Laptops', icon: 'laptop' },
        { title: 'iPhone 15 Pro', category: 'Smartphones', icon: 'mobile-alt' },
        { title: 'MacBook Air M2', category: 'Laptops', icon: 'laptop' },
        { title: 'Samsung Galaxy S24', category: 'Smartphones', icon: 'mobile-alt' },
        { title: 'iPad Pro', category: 'Tablets', icon: 'tablet-alt' },
        { title: 'AirPods Pro', category: 'Audio', icon: 'headphones' },
        { title: 'Monitor 4K', category: 'Accesorios', icon: 'desktop' },
        { title: 'Mouse Gaming', category: 'Accesorios', icon: 'mouse' }
    ];

    searchInput.addEventListener('input', function() {
        const query = this.value.toLowerCase();
        
        if (query.length < 2) {
            suggestions.classList.remove('active');
            return;
        }

        const filtered = popularTerms.filter(term => 
            term.title.toLowerCase().includes(query) || 
            term.category.toLowerCase().includes(query)
        );

        if (filtered.length > 0) {
            suggestions.innerHTML = filtered.map(term => `
                <div class="suggestion-item" onclick="selectSuggestion('${term.title}')">
                    <div class="suggestion-icon">
                        <svg viewBox="0 0 24 24">
                            <path d="M15.5 14h-.79l-.28-.27C15.41 12.59 16 11.11 16 9.5 16 5.91 13.09 3 9.5 3S3 5.91 3 9.5 5.91 16 9.5 16c1.61 0 3.09-.59 4.23-1.57l.27.28v.79l5 4.99L20.49 19l-4.99-5zm-6 0C7.01 14 5 11.99 5 9.5S7.01 5 9.5 5 14 7.01 14 9.5 11.99 14 9.5 14z"/>
                        </svg>
                    </div>
                    <div class="suggestion-content">
                        <div class="suggestion-title">${term.title}</div>
                        <div class="suggestion-meta">en ${term.category}</div>
                    </div>
                </div>
            `).join('');
            suggestions.classList.add('active');
        } else {
            suggestions.classList.remove('active');
        }
    });

    function selectSuggestion(term) {
        searchInput.value = term;
        suggestions.classList.remove('active');
        searchInput.form.submit();
    }

    // Close suggestions on click outside
    document.addEventListener('click', function(e) {
        if (!searchInput.contains(e.target) && !suggestions.contains(e.target)) {
            suggestions.classList.remove('active');
        }
    });
</script>
</body>
</html>
