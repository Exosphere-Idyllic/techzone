<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Gestión de Productos - TechZone</title>

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

        .productos-container {
            max-width: 1600px;
            margin: 0 auto;
            padding: 40px 20px 60px;
        }

        /* Header */
        .page-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 30px;
            flex-wrap: wrap;
            gap: 20px;
        }

        .page-title {
            font-size: 2.5rem;
            font-weight: bold;
            background: linear-gradient(135deg, var(--primary-color), var(--secondary-color));
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }

        .btn {
            padding: 12px 25px;
            border-radius: 10px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            border: none;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            text-decoration: none;
        }

        .btn-primary {
            background: linear-gradient(135deg, var(--primary-color), var(--secondary-color));
            color: #000;
            box-shadow: 0 5px 15px rgba(0, 212, 255, 0.3);
        }

        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 20px rgba(0, 212, 255, 0.4);
        }

        .btn-secondary {
            background: var(--dark-color);
            border: 1px solid var(--border-color);
            color: var(--text-primary);
        }

        .btn-secondary:hover {
            background: var(--light-color);
            border-color: var(--primary-color);
        }

        .btn-danger {
            background: var(--danger-color);
            color: #fff;
        }

        .btn-danger:hover {
            background: #cc0000;
        }

        .btn-sm {
            padding: 8px 15px;
            font-size: 0.9rem;
        }

        /* Stats Cards */
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }

        .stat-card {
            background: var(--dark-color);
            border: 1px solid var(--border-color);
            border-radius: 12px;
            padding: 20px;
            transition: all 0.3s ease;
        }

        .stat-card:hover {
            transform: translateY(-3px);
            border-color: var(--primary-color);
            box-shadow: 0 8px 20px rgba(0, 212, 255, 0.2);
        }

        .stat-icon {
            width: 45px;
            height: 45px;
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.3rem;
            margin-bottom: 12px;
        }

        .stat-icon.total {
            background: rgba(0, 212, 255, 0.1);
            color: var(--primary-color);
        }

        .stat-icon.active {
            background: rgba(0, 200, 81, 0.1);
            color: var(--success-color);
        }

        .stat-icon.low {
            background: rgba(255, 187, 51, 0.1);
            color: var(--warning-color);
        }

        .stat-icon.out {
            background: rgba(255, 68, 68, 0.1);
            color: var(--danger-color);
        }

        .stat-value {
            font-size: 2rem;
            font-weight: bold;
            color: var(--text-primary);
            margin-bottom: 5px;
        }

        .stat-label {
            color: var(--text-secondary);
            font-size: 0.9rem;
        }

        /* Filters */
        .filters-section {
            background: var(--dark-color);
            border: 1px solid var(--border-color);
            border-radius: 12px;
            padding: 20px;
            margin-bottom: 25px;
        }

        .filters-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 15px;
            margin-bottom: 15px;
        }

        .form-group {
            display: flex;
            flex-direction: column;
            gap: 8px;
        }

        .form-label {
            font-weight: 600;
            color: var(--text-secondary);
            font-size: 0.9rem;
        }

        .form-control {
            padding: 12px 15px;
            background: var(--darker-color);
            border: 1px solid var(--border-color);
            border-radius: 8px;
            color: var(--text-primary);
            font-size: 0.95rem;
            transition: all 0.3s ease;
        }

        .form-control:focus {
            outline: none;
            border-color: var(--primary-color);
            box-shadow: 0 0 0 3px rgba(0, 212, 255, 0.1);
        }

        .search-box {
            position: relative;
            flex: 1;
        }

        .search-box input {
            width: 100%;
            padding-left: 45px;
        }

        .search-icon {
            position: absolute;
            left: 15px;
            top: 50%;
            transform: translateY(-50%);
            color: var(--text-secondary);
        }

        .filters-actions {
            display: flex;
            gap: 10px;
            justify-content: flex-end;
        }

        /* Table */
        .table-container {
            background: var(--dark-color);
            border: 1px solid var(--border-color);
            border-radius: 12px;
            overflow: hidden;
            margin-bottom: 25px;
        }

        .table-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 20px 25px;
            border-bottom: 1px solid var(--border-color);
        }

        .table-title {
            font-size: 1.2rem;
            font-weight: bold;
        }

        .table-actions {
            display: flex;
            gap: 10px;
        }

        .products-table {
            width: 100%;
            border-collapse: collapse;
        }

        .products-table thead {
            background: rgba(255, 255, 255, 0.02);
        }

        .products-table th {
            padding: 15px 20px;
            text-align: left;
            font-weight: 600;
            color: var(--text-secondary);
            font-size: 0.9rem;
            text-transform: uppercase;
            border-bottom: 2px solid var(--border-color);
        }

        .products-table th.sortable {
            cursor: pointer;
            user-select: none;
        }

        .products-table th.sortable:hover {
            color: var(--primary-color);
        }

        .products-table td {
            padding: 15px 20px;
            border-bottom: 1px solid var(--border-color);
        }

        .products-table tr:hover {
            background: rgba(255, 255, 255, 0.02);
        }

        .product-cell {
            display: flex;
            align-items: center;
            gap: 15px;
        }

        .product-image {
            width: 60px;
            height: 60px;
            background: var(--light-color);
            border-radius: 8px;
            overflow: hidden;
            display: flex;
            align-items: center;
            justify-content: center;
            flex-shrink: 0;
        }

        .product-image img {
            max-width: 100%;
            max-height: 100%;
            object-fit: contain;
        }

        .product-info {
            flex: 1;
        }

        .product-name {
            font-weight: 600;
            color: var(--text-primary);
            margin-bottom: 4px;
        }

        .product-sku {
            font-size: 0.85rem;
            color: var(--text-secondary);
        }

        .badge {
            padding: 5px 12px;
            border-radius: 15px;
            font-size: 0.85rem;
            font-weight: 600;
            display: inline-block;
        }

        .badge-success {
            background: rgba(0, 200, 81, 0.2);
            color: var(--success-color);
        }

        .badge-warning {
            background: rgba(255, 187, 51, 0.2);
            color: var(--warning-color);
        }

        .badge-danger {
            background: rgba(255, 68, 68, 0.2);
            color: var(--danger-color);
        }

        .badge-info {
            background: rgba(0, 212, 255, 0.2);
            color: var(--primary-color);
        }

        .price {
            font-weight: bold;
            font-size: 1.1rem;
            color: var(--primary-color);
        }

        .action-buttons {
            display: flex;
            gap: 8px;
        }

        .btn-icon {
            width: 35px;
            height: 35px;
            padding: 0;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            border-radius: 8px;
            cursor: pointer;
            transition: all 0.3s ease;
            border: 1px solid var(--border-color);
            background: var(--darker-color);
            color: var(--text-primary);
        }

        .btn-icon:hover {
            transform: translateY(-2px);
        }

        .btn-icon.edit:hover {
            background: var(--primary-color);
            color: #000;
            border-color: var(--primary-color);
        }

        .btn-icon.delete:hover {
            background: var(--danger-color);
            color: #fff;
            border-color: var(--danger-color);
        }

        /* Pagination */
        .pagination {
            display: flex;
            justify-content: center;
            align-items: center;
            gap: 10px;
            padding: 20px;
        }

        .pagination-btn {
            padding: 10px 15px;
            background: var(--dark-color);
            border: 1px solid var(--border-color);
            border-radius: 8px;
            color: var(--text-primary);
            cursor: pointer;
            transition: all 0.3s ease;
        }

        .pagination-btn:hover:not(:disabled) {
            background: var(--primary-color);
            color: #000;
            border-color: var(--primary-color);
        }

        .pagination-btn:disabled {
            opacity: 0.5;
            cursor: not-allowed;
        }

        .pagination-btn.active {
            background: var(--primary-color);
            color: #000;
            border-color: var(--primary-color);
        }

        .pagination-info {
            color: var(--text-secondary);
            font-size: 0.9rem;
        }

        /* Modal */
        .modal {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0, 0, 0, 0.8);
            z-index: 9999;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }

        .modal.active {
            display: flex;
        }

        .modal-content {
            background: var(--dark-color);
            border: 1px solid var(--border-color);
            border-radius: 15px;
            max-width: 800px;
            width: 100%;
            max-height: 90vh;
            overflow-y: auto;
            animation: slideDown 0.3s ease;
        }

        @keyframes slideDown {
            from {
                opacity: 0;
                transform: translateY(-50px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        .modal-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 25px 30px;
            border-bottom: 1px solid var(--border-color);
        }

        .modal-title {
            font-size: 1.5rem;
            font-weight: bold;
        }

        .close-modal {
            width: 35px;
            height: 35px;
            border-radius: 8px;
            background: transparent;
            border: 1px solid var(--border-color);
            color: var(--text-primary);
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: all 0.3s ease;
        }

        .close-modal:hover {
            background: var(--danger-color);
            border-color: var(--danger-color);
        }

        .modal-body {
            padding: 30px;
        }

        .form-row {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-bottom: 20px;
        }

        .form-group.full-width {
            grid-column: 1 / -1;
        }

        textarea.form-control {
            min-height: 100px;
            resize: vertical;
        }

        .file-upload {
            position: relative;
            overflow: hidden;
        }

        .file-upload input[type="file"] {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            opacity: 0;
            cursor: pointer;
        }

        .file-upload-btn {
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
            padding: 40px 20px;
            background: var(--darker-color);
            border: 2px dashed var(--border-color);
            border-radius: 10px;
            color: var(--text-secondary);
            cursor: pointer;
            transition: all 0.3s ease;
        }

        .file-upload:hover .file-upload-btn {
            border-color: var(--primary-color);
            color: var(--primary-color);
        }

        .image-preview {
            display: flex;
            gap: 15px;
            flex-wrap: wrap;
            margin-top: 15px;
        }

        .preview-item {
            position: relative;
            width: 100px;
            height: 100px;
            border-radius: 8px;
            overflow: hidden;
            border: 1px solid var(--border-color);
        }

        .preview-item img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }

        .remove-preview {
            position: absolute;
            top: 5px;
            right: 5px;
            width: 25px;
            height: 25px;
            background: var(--danger-color);
            color: #fff;
            border: none;
            border-radius: 50%;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 0.8rem;
        }

        .modal-footer {
            display: flex;
            justify-content: flex-end;
            gap: 15px;
            padding: 20px 30px;
            border-top: 1px solid var(--border-color);
        }

        /* Alert */
        .alert {
            padding: 15px 20px;
            border-radius: 10px;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 12px;
            animation: slideDown 0.3s ease;
        }

        .alert-success {
            background: rgba(0, 200, 81, 0.1);
            border: 1px solid var(--success-color);
            color: var(--success-color);
        }

        .alert-error {
            background: rgba(255, 68, 68, 0.1);
            border: 1px solid var(--danger-color);
            color: var(--danger-color);
        }

        /* Loading */
        .loading-overlay {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0, 0, 0, 0.7);
            z-index: 10000;
            align-items: center;
            justify-content: center;
        }

        .loading-overlay.active {
            display: flex;
        }

        .spinner {
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

        /* Responsive */
        @media (max-width: 1024px) {
            .filters-grid {
                grid-template-columns: repeat(2, 1fr);
            }
        }

        @media (max-width: 768px) {
            body {
                padding-right: 0;
            }

            .productos-container {
                padding: 20px 15px;
            }

            .page-title {
                font-size: 2rem;
            }

            .stats-grid {
                grid-template-columns: repeat(2, 1fr);
            }

            .filters-grid {
                grid-template-columns: 1fr;
            }

            .table-container {
                overflow-x: auto;
            }

            .products-table {
                min-width: 800px;
            }

            .modal-content {
                margin: 0;
            }
        }

        @media (max-width: 480px) {
            .stats-grid {
                grid-template-columns: 1fr;
            }

            .page-header {
                flex-direction: column;
                align-items: flex-start;
            }
        }
    </style>
</head>
<body>
<!-- Include Header -->
<%@ include file="/views/components/header.jsp" %>

<div class="productos-container">
    <!-- Header -->
    <div class="page-header">
        <h1 class="page-title">Gestión de Productos</h1>
        <button class="btn btn-primary" onclick="abrirModalNuevo()">
            <i class="fas fa-plus"></i>
            Nuevo Producto
        </button>
    </div>

    <!-- Alerts -->
    <c:if test="${not empty mensaje}">
        <div class="alert alert-success">
            <i class="fas fa-check-circle"></i>
            <span>${mensaje}</span>
        </div>
    </c:if>

    <c:if test="${not empty error}">
        <div class="alert alert-error">
            <i class="fas fa-exclamation-circle"></i>
            <span>${error}</span>
        </div>
    </c:if>

    <!-- Stats -->
    <div class="stats-grid">
        <div class="stat-card">
            <div class="stat-icon total">
                <i class="fas fa-box"></i>
            </div>
            <div class="stat-value">${totalProductos}</div>
            <div class="stat-label">Total Productos</div>
        </div>

        <div class="stat-card">
            <div class="stat-icon active">
                <i class="fas fa-check-circle"></i>
            </div>
            <div class="stat-value">${productosActivos}</div>
            <div class="stat-label">Activos</div>
        </div>

        <div class="stat-card">
            <div class="stat-icon low">
                <i class="fas fa-exclamation-triangle"></i>
            </div>
            <div class="stat-value">${productosStockBajo}</div>
            <div class="stat-label">Stock Bajo</div>
        </div>

        <div class="stat-card">
            <div class="stat-icon out">
                <i class="fas fa-times-circle"></i>
            </div>
            <div class="stat-value">${productosSinStock}</div>
            <div class="stat-label">Sin Stock</div>
        </div>
    </div>

    <!-- Filters -->
    <div class="filters-section">
        <form method="get" action="${pageContext.request.contextPath}/admin/productos">
            <div class="filters-grid">
                <div class="form-group">
                    <label class="form-label">Buscar</label>
                    <div class="search-box">
                        <i class="fas fa-search search-icon"></i>
                        <input type="text" name="busqueda" class="form-control" 
                               placeholder="Nombre, SKU o descripción..." 
                               value="${param.busqueda}">
                    </div>
                </div>

                <div class="form-group">
                    <label class="form-label">Categoría</label>
                    <select name="categoria" class="form-control">
                        <option value="">Todas las categorías</option>
                        <c:forEach items="${categorias}" var="cat">
                            <option value="${cat.idCategoria}" ${param.categoria == cat.idCategoria ? 'selected' : ''}>
                                ${cat.nombre}
                            </option>
                        </c:forEach>
                    </select>
                </div>

                <div class="form-group">
                    <label class="form-label">Estado</label>
                    <select name="estado" class="form-control">
                        <option value="">Todos</option>
                        <option value="activo" ${param.estado == 'activo' ? 'selected' : ''}>Activos</option>
                        <option value="inactivo" ${param.estado == 'inactivo' ? 'selected' : ''}>Inactivos</option>
                    </select>
                </div>

                <div class="form-group">
                    <label class="form-label">Stock</label>
                    <select name="stock" class="form-control">
                        <option value="">Todos</option>
                        <option value="disponible" ${param.stock == 'disponible' ? 'selected' : ''}>Disponible</option>
                        <option value="bajo" ${param.stock == 'bajo' ? 'selected' : ''}>Stock Bajo</option>
                        <option value="agotado" ${param.stock == 'agotado' ? 'selected' : ''}>Agotado</option>
                    </select>
                </div>
            </div>

            <div class="filters-actions">
                <button type="submit" class="btn btn-primary btn-sm">
                    <i class="fas fa-filter"></i>
                    Aplicar Filtros
                </button>
                <a href="${pageContext.request.contextPath}/admin/productos" class="btn btn-secondary btn-sm">
                    <i class="fas fa-times"></i>
                    Limpiar
                </a>
            </div>
        </form>
    </div>

    <!-- Table -->
    <div class="table-container">
        <div class="table-header">
            <div class="table-title">
                Productos (${fn:length(productos)})
            </div>
            <div class="table-actions">
                <button class="btn btn-secondary btn-sm" onclick="exportarExcel()">
                    <i class="fas fa-file-excel"></i>
                    Exportar
                </button>
                <button class="btn btn-secondary btn-sm" onclick="window.print()">
                    <i class="fas fa-print"></i>
                    Imprimir
                </button>
            </div>
        </div>

        <table class="products-table">
            <thead>
                <tr>
                    <th class="sortable" onclick="ordenar('nombre')">Producto</th>
                    <th class="sortable" onclick="ordenar('categoria')">Categoría</th>
                    <th class="sortable" onclick="ordenar('precio')">Precio</th>
                    <th class="sortable" onclick="ordenar('stock')">Stock</th>
                    <th>Estado</th>
                    <th>Acciones</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach items="${productos}" var="producto">
                    <tr>
                        <td>
                            <div class="product-cell">
                                <div class="product-image">
                                    <c:choose>
                                        <c:when test="${not empty producto.imagenPrincipal}">
                                            <img src="${pageContext.request.contextPath}/uploads/${producto.imagenPrincipal}" 
                                                 alt="${producto.nombre}">
                                        </c:when>
                                        <c:otherwise>
                                            <i class="fas fa-image" style="color: #666;"></i>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                                <div class="product-info">
                                    <div class="product-name">${producto.nombre}</div>
                                    <div class="product-sku">SKU: ${producto.sku}</div>
                                </div>
                            </div>
                        </td>
                        <td>${producto.categoria.nombre}</td>
                        <td>
                            <span class="price">$<fmt:formatNumber value="${producto.precio}" pattern="#,##0.00"/></span>
                        </td>
                        <td>
                            <span class="badge ${producto.stock > 10 ? 'badge-success' : (producto.stock > 0 ? 'badge-warning' : 'badge-danger')}">
                                ${producto.stock} unidades
                            </span>
                        </td>
                        <td>
                            <span class="badge ${producto.activo ? 'badge-success' : 'badge-danger'}">
                                ${producto.activo ? 'Activo' : 'Inactivo'}
                            </span>
                        </td>
                        <td>
                            <div class="action-buttons">
                                <button class="btn-icon edit" 
                                        onclick="abrirModalEditar(${producto.idProducto})"
                                        title="Editar">
                                    <i class="fas fa-edit"></i>
                                </button>
                                <button class="btn-icon delete" 
                                        onclick="confirmarEliminar(${producto.idProducto}, '${producto.nombre}')"
                                        title="Eliminar">
                                    <i class="fas fa-trash"></i>
                                </button>
                            </div>
                        </td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>

        <!-- Pagination -->
        <div class="pagination">
            <button class="pagination-btn" 
                    onclick="cambiarPagina(${paginaActual - 1})"
                    ${paginaActual <= 1 ? 'disabled' : ''}>
                <i class="fas fa-chevron-left"></i>
            </button>

            <c:forEach begin="1" end="${totalPaginas}" var="i">
                <button class="pagination-btn ${i == paginaActual ? 'active' : ''}" 
                        onclick="cambiarPagina(${i})">
                    ${i}
                </button>
            </c:forEach>

            <button class="pagination-btn" 
                    onclick="cambiarPagina(${paginaActual + 1})"
                    ${paginaActual >= totalPaginas ? 'disabled' : ''}>
                <i class="fas fa-chevron-right"></i>
            </button>

            <span class="pagination-info">
                Mostrando ${(paginaActual - 1) * productosPorPagina + 1} - 
                ${paginaActual * productosPorPagina > totalProductos ? totalProductos : paginaActual * productosPorPagina} 
                de ${totalProductos}
            </span>
        </div>
    </div>
</div>

<!-- Modal Nuevo/Editar Producto -->
<div id="modalProducto" class="modal">
    <div class="modal-content">
        <div class="modal-header">
            <h2 class="modal-title" id="modalTitle">Nuevo Producto</h2>
            <button class="close-modal" onclick="cerrarModal()">
                <i class="fas fa-times"></i>
            </button>
        </div>

        <form id="formProducto" method="post" enctype="multipart/form-data" 
              action="${pageContext.request.contextPath}/admin/productos">
            <div class="modal-body">
                <input type="hidden" name="accion" id="accion" value="crear">
                <input type="hidden" name="idProducto" id="idProducto">

                <div class="form-row">
                    <div class="form-group">
                        <label class="form-label">Nombre *</label>
                        <input type="text" name="nombre" id="nombre" class="form-control" required>
                    </div>

                    <div class="form-group">
                        <label class="form-label">SKU *</label>
                        <input type="text" name="sku" id="sku" class="form-control" required>
                    </div>
                </div>

                <div class="form-row">
                    <div class="form-group">
                        <label class="form-label">Categoría *</label>
                        <select name="idCategoria" id="idCategoria" class="form-control" required>
                            <option value="">Seleccionar...</option>
                            <c:forEach items="${categorias}" var="cat">
                                <option value="${cat.idCategoria}">${cat.nombre}</option>
                            </c:forEach>
                        </select>
                    </div>

                    <div class="form-group">
                        <label class="form-label">Marca</label>
                        <input type="text" name="marca" id="marca" class="form-control">
                    </div>
                </div>

                <div class="form-row">
                    <div class="form-group">
                        <label class="form-label">Precio *</label>
                        <input type="number" name="precio" id="precio" class="form-control" 
                               step="0.01" min="0" required>
                    </div>

                    <div class="form-group">
                        <label class="form-label">Stock *</label>
                        <input type="number" name="stock" id="stock" class="form-control" 
                               min="0" required>
                    </div>

                    <div class="form-group">
                        <label class="form-label">Estado</label>
                        <select name="activo" id="activo" class="form-control">
                            <option value="true">Activo</option>
                            <option value="false">Inactivo</option>
                        </select>
                    </div>
                </div>

                <div class="form-row">
                    <div class="form-group full-width">
                        <label class="form-label">Descripción</label>
                        <textarea name="descripcion" id="descripcion" class="form-control"></textarea>
                    </div>
                </div>

                <div class="form-row">
                    <div class="form-group full-width">
                        <label class="form-label">Imágenes</label>
                        <div class="file-upload">
                            <input type="file" name="imagenes" id="imagenes" 
                                   accept="image/*" multiple onchange="previewImages(this)">
                            <div class="file-upload-btn">
                                <i class="fas fa-cloud-upload-alt" style="font-size: 2rem;"></i>
                                <div>
                                    <div style="font-weight: 600; margin-bottom: 5px;">
                                        Arrastra imágenes o haz clic para seleccionar
                                    </div>
                                    <div style="font-size: 0.85rem;">
                                        Formatos: JPG, PNG, WEBP (Máx. 5MB cada una)
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div id="imagePreview" class="image-preview"></div>
                    </div>
                </div>
            </div>

            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" onclick="cerrarModal()">
                    Cancelar
                </button>
                <button type="submit" class="btn btn-primary">
                    <i class="fas fa-save"></i>
                    Guardar Producto
                </button>
            </div>
        </form>
    </div>
</div>

<!-- Loading Overlay -->
<div id="loadingOverlay" class="loading-overlay">
    <div class="spinner"></div>
</div>

<!-- Include Footer -->
<%@ include file="/views/components/footer.jsp" %>

<script>
    // Auto-hide alerts
    setTimeout(() => {
        document.querySelectorAll('.alert').forEach(alert => {
            alert.style.display = 'none';
        });
    }, 5000);

    // Modal functions
    function abrirModalNuevo() {
        document.getElementById('modalTitle').textContent = 'Nuevo Producto';
        document.getElementById('accion').value = 'crear';
        document.getElementById('formProducto').reset();
        document.getElementById('imagePreview').innerHTML = '';
        document.getElementById('modalProducto').classList.add('active');
    }

    function abrirModalEditar(id) {
        // Aquí se cargarían los datos del producto via AJAX
        document.getElementById('modalTitle').textContent = 'Editar Producto';
        document.getElementById('accion').value = 'editar';
        document.getElementById('idProducto').value = id;
        document.getElementById('modalProducto').classList.add('active');
        // Cargar datos del producto...
    }

    function cerrarModal() {
        document.getElementById('modalProducto').classList.remove('active');
    }

    // Image preview
    function previewImages(input) {
        const preview = document.getElementById('imagePreview');
        preview.innerHTML = '';

        if (input.files) {
            Array.from(input.files).forEach((file, index) => {
                const reader = new FileReader();
                reader.onload = function(e) {
                    const div = document.createElement('div');
                    div.className = 'preview-item';
                    div.innerHTML = `
                        <img src="${e.target.result}" alt="Preview">
                        <button type="button" class="remove-preview" onclick="removePreview(${index})">
                            <i class="fas fa-times"></i>
                        </button>
                    `;
                    preview.appendChild(div);
                };
                reader.readAsDataURL(file);
            });
        }
    }

    function removePreview(index) {
        // Remover preview específico
        const preview = document.getElementById('imagePreview');
        preview.children[index].remove();
    }

    // Delete confirmation
    function confirmarEliminar(id, nombre) {
        if (confirm(`¿Estás seguro de eliminar el producto "${nombre}"?\n\nEsta acción no se puede deshacer.`)) {
            document.getElementById('loadingOverlay').classList.add('active');
            window.location.href = `${pageContext.request.contextPath}/admin/productos?accion=eliminar&id=${id}`;
        }
    }

    // Pagination
    function cambiarPagina(pagina) {
        const url = new URL(window.location);
        url.searchParams.set('pagina', pagina);
        window.location.href = url.toString();
    }

    // Sort
    function ordenar(campo) {
        const url = new URL(window.location);
        url.searchParams.set('orden', campo);
        window.location.href = url.toString();
    }

    // Export
    function exportarExcel() {
        window.location.href = '${pageContext.request.contextPath}/admin/productos?accion=exportar&formato=excel';
    }

    // Close modal on outside click
    document.getElementById('modalProducto').addEventListener('click', function(e) {
        if (e.target === this) {
            cerrarModal();
        }
    });
</script>
</body>
</html>
