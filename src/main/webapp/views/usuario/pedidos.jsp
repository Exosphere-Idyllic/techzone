<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Mis Pedidos - TechZone</title>

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
            --info-color: #00d4ff;
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

        .pedidos-container {
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
        }

        .breadcrumb a {
            color: var(--primary-color);
            text-decoration: none;
        }

        .breadcrumb a:hover {
            color: var(--primary-hover);
        }

        /* Header */
        .pedidos-header {
            margin-bottom: 40px;
        }

        .page-title {
            font-size: 2.5rem;
            font-weight: bold;
            margin-bottom: 10px;
            background: linear-gradient(135deg, var(--primary-color), var(--secondary-color));
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }

        .page-subtitle {
            font-size: 1.1rem;
            color: var(--text-secondary);
        }

        /* Stats Cards */
        .stats-grid {
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
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.5rem;
        }

        .stat-icon.total {
            background: rgba(0, 212, 255, 0.1);
            color: var(--primary-color);
        }

        .stat-icon.pendiente {
            background: rgba(255, 187, 51, 0.1);
            color: var(--warning-color);
        }

        .stat-icon.enviado {
            background: rgba(0, 212, 255, 0.1);
            color: var(--info-color);
        }

        .stat-icon.entregado {
            background: rgba(0, 200, 81, 0.1);
            color: var(--success-color);
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
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        /* Filters Bar */
        .filters-bar {
            background: var(--dark-color);
            border-radius: 12px;
            padding: 25px;
            margin-bottom: 30px;
            border: 1px solid var(--border-color);
        }

        .filters-grid {
            display: grid;
            grid-template-columns: 1fr auto auto;
            gap: 20px;
            align-items: center;
        }

        .search-box {
            position: relative;
        }

        .search-input {
            width: 100%;
            padding: 12px 45px 12px 15px;
            background: rgba(255, 255, 255, 0.05);
            border: 1px solid var(--border-color);
            border-radius: 8px;
            color: var(--text-primary);
            font-size: 0.95rem;
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

        .search-icon {
            position: absolute;
            right: 15px;
            top: 50%;
            transform: translateY(-50%);
            color: var(--text-secondary);
            pointer-events: none;
        }

        .filter-select {
            padding: 12px 40px 12px 15px;
            background: rgba(255, 255, 255, 0.05);
            border: 1px solid var(--border-color);
            border-radius: 8px;
            color: var(--text-primary);
            font-size: 0.95rem;
            cursor: pointer;
            appearance: none;
            background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='%2300d4ff'%3E%3Cpath d='M7 10l5 5 5-5z'/%3E%3C/svg%3E");
            background-repeat: no-repeat;
            background-position: right 10px center;
            background-size: 20px;
            min-width: 180px;
        }

        .filter-select:focus {
            outline: none;
            border-color: var(--primary-color);
            box-shadow: 0 0 0 3px rgba(0, 212, 255, 0.1);
        }

        .btn-clear-filters {
            padding: 12px 20px;
            background: transparent;
            border: 1px solid var(--border-color);
            border-radius: 8px;
            color: var(--text-secondary);
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .btn-clear-filters:hover {
            background: rgba(255, 255, 255, 0.05);
            border-color: var(--primary-color);
            color: var(--text-primary);
        }

        /* Status Tabs */
        .status-tabs {
            display: flex;
            gap: 10px;
            margin-bottom: 30px;
            overflow-x: auto;
            padding-bottom: 5px;
        }

        .status-tabs::-webkit-scrollbar {
            height: 6px;
        }

        .status-tabs::-webkit-scrollbar-track {
            background: var(--darker-color);
        }

        .status-tabs::-webkit-scrollbar-thumb {
            background: var(--primary-color);
            border-radius: 3px;
        }

        .status-tab {
            padding: 12px 25px;
            background: var(--dark-color);
            border: 1px solid var(--border-color);
            border-radius: 25px;
            color: var(--text-secondary);
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            white-space: nowrap;
            text-decoration: none;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .status-tab:hover {
            background: var(--light-color);
            color: var(--text-primary);
        }

        .status-tab.active {
            background: linear-gradient(135deg, var(--primary-color), var(--secondary-color));
            color: #000;
            border-color: transparent;
        }

        .status-badge {
            background: rgba(0, 0, 0, 0.3);
            padding: 2px 8px;
            border-radius: 10px;
            font-size: 0.8rem;
        }

        .status-tab.active .status-badge {
            background: rgba(0, 0, 0, 0.2);
        }

        /* Pedidos List */
        .pedidos-list {
            display: flex;
            flex-direction: column;
            gap: 20px;
        }

        .pedido-card {
            background: var(--dark-color);
            border: 1px solid var(--border-color);
            border-radius: 15px;
            padding: 25px;
            transition: all 0.3s ease;
            cursor: pointer;
        }

        .pedido-card:hover {
            transform: translateY(-3px);
            border-color: var(--primary-color);
            box-shadow: 0 10px 30px rgba(0, 212, 255, 0.2);
        }

        .pedido-header {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            margin-bottom: 20px;
            padding-bottom: 20px;
            border-bottom: 1px solid var(--border-color);
            flex-wrap: wrap;
            gap: 15px;
        }

        .pedido-info {
            flex: 1;
        }

        .pedido-number {
            font-size: 1.3rem;
            font-weight: bold;
            color: var(--primary-color);
            margin-bottom: 8px;
        }

        .pedido-date {
            color: var(--text-secondary);
            font-size: 0.9rem;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .pedido-date svg {
            width: 16px;
            height: 16px;
            fill: currentColor;
        }

        .pedido-status {
            padding: 8px 20px;
            border-radius: 20px;
            font-weight: 600;
            font-size: 0.9rem;
            text-transform: uppercase;
            display: inline-flex;
            align-items: center;
            gap: 8px;
        }

        .status-pendiente {
            background: rgba(255, 187, 51, 0.2);
            color: var(--warning-color);
            border: 1px solid var(--warning-color);
        }

        .status-pagado {
            background: rgba(0, 212, 255, 0.2);
            color: var(--info-color);
            border: 1px solid var(--info-color);
        }

        .status-enviado {
            background: rgba(138, 43, 226, 0.2);
            color: #b19cd9;
            border: 1px solid #b19cd9;
        }

        .status-entregado {
            background: rgba(0, 200, 81, 0.2);
            color: var(--success-color);
            border: 1px solid var(--success-color);
        }

        .status-cancelado {
            background: rgba(255, 68, 68, 0.2);
            color: var(--danger-color);
            border: 1px solid var(--danger-color);
        }

        /* Pedido Body */
        .pedido-body {
            margin-bottom: 20px;
        }

        .pedido-products {
            display: flex;
            gap: 15px;
            margin-bottom: 20px;
            overflow-x: auto;
            padding-bottom: 10px;
        }

        .pedido-products::-webkit-scrollbar {
            height: 6px;
        }

        .pedido-products::-webkit-scrollbar-track {
            background: rgba(255, 255, 255, 0.05);
        }

        .pedido-products::-webkit-scrollbar-thumb {
            background: var(--primary-color);
            border-radius: 3px;
        }

        .product-mini {
            flex-shrink: 0;
            width: 80px;
            height: 80px;
            background: var(--light-color);
            border-radius: 8px;
            overflow: hidden;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .product-mini img {
            max-width: 100%;
            max-height: 100%;
            object-fit: contain;
        }

        .product-mini svg {
            width: 40px;
            height: 40px;
            fill: #666;
        }

        .pedido-meta {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
            gap: 15px;
        }

        .meta-item {
            display: flex;
            flex-direction: column;
            gap: 5px;
        }

        .meta-label {
            font-size: 0.85rem;
            color: var(--text-secondary);
            text-transform: uppercase;
        }

        .meta-value {
            font-weight: 600;
            color: var(--text-primary);
        }

        .meta-value.total {
            font-size: 1.5rem;
            color: var(--primary-color);
        }

        /* Pedido Footer */
        .pedido-footer {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding-top: 20px;
            border-top: 1px solid var(--border-color);
            gap: 15px;
            flex-wrap: wrap;
        }

        .pedido-actions {
            display: flex;
            gap: 10px;
        }

        .btn-action {
            padding: 10px 20px;
            border-radius: 8px;
            font-weight: 600;
            font-size: 0.9rem;
            cursor: pointer;
            transition: all 0.3s ease;
            border: none;
            display: flex;
            align-items: center;
            gap: 8px;
            text-decoration: none;
        }

        .btn-primary {
            background: linear-gradient(135deg, var(--primary-color), var(--secondary-color));
            color: #000;
        }

        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(0, 212, 255, 0.4);
        }

        .btn-secondary {
            background: transparent;
            border: 1px solid var(--border-color);
            color: var(--text-primary);
        }

        .btn-secondary:hover {
            background: rgba(255, 255, 255, 0.05);
            border-color: var(--primary-color);
        }

        .btn-danger {
            background: transparent;
            border: 1px solid var(--danger-color);
            color: var(--danger-color);
        }

        .btn-danger:hover {
            background: var(--danger-color);
            color: #fff;
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

        .btn-explore {
            padding: 15px 40px;
            background: linear-gradient(135deg, var(--primary-color), var(--secondary-color));
            color: #000;
            border: none;
            border-radius: 10px;
            font-weight: 700;
            font-size: 1rem;
            cursor: pointer;
            transition: all 0.3s ease;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 10px;
            box-shadow: 0 5px 20px rgba(0, 212, 255, 0.3);
        }

        .btn-explore:hover {
            transform: translateY(-3px);
            box-shadow: 0 10px 30px rgba(0, 212, 255, 0.5);
        }

        /* Pagination */
        .pagination {
            display: flex;
            justify-content: center;
            gap: 10px;
            margin-top: 40px;
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

        @keyframes slideDown {
            from {
                opacity: 0;
                transform: translateY(-10px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
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
        @media (max-width: 768px) {
            body {
                padding-right: 0;
            }

            .pedidos-container {
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

            .pedido-header {
                flex-direction: column;
            }

            .pedido-meta {
                grid-template-columns: 1fr;
            }

            .pedido-footer {
                flex-direction: column;
            }

            .pedido-actions {
                width: 100%;
            }

            .btn-action {
                flex: 1;
                justify-content: center;
            }
        }

        @media (max-width: 480px) {
            .stats-grid {
                grid-template-columns: 1fr;
            }

            .status-tabs {
                flex-direction: column;
            }

            .status-tab {
                justify-content: center;
            }
        }
    </style>
</head>
<body>
<!-- Include Header -->
<%@ include file="/views/components/header.jsp" %>

<div class="pedidos-container">
    <!-- Breadcrumb -->
    <nav class="breadcrumb">
        <a href="${pageContext.request.contextPath}/">Inicio</a>
        <span>/</span>
        <span>Mis Pedidos</span>
    </nav>

    <!-- Header -->
    <div class="pedidos-header">
        <h1 class="page-title">Mis Pedidos</h1>
        <p class="page-subtitle">Gestiona y realiza seguimiento de tus pedidos</p>
    </div>

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

    <!-- Stats Cards -->
    <div class="stats-grid">
        <div class="stat-card">
            <div class="stat-icon total">
                <i class="fas fa-shopping-bag"></i>
            </div>
            <div class="stat-value">${totalPedidos}</div>
            <div class="stat-label">Total Pedidos</div>
        </div>

        <div class="stat-card">
            <div class="stat-icon pendiente">
                <i class="fas fa-clock"></i>
            </div>
            <div class="stat-value">${pedidosPendientes}</div>
            <div class="stat-label">Pendientes</div>
        </div>

        <div class="stat-card">
            <div class="stat-icon enviado">
                <i class="fas fa-shipping-fast"></i>
            </div>
            <div class="stat-value">${pedidosEnviados}</div>
            <div class="stat-label">Enviados</div>
        </div>

        <div class="stat-card">
            <div class="stat-icon entregado">
                <i class="fas fa-check-circle"></i>
            </div>
            <div class="stat-value">${pedidosEntregados}</div>
            <div class="stat-label">Entregados</div>
        </div>
    </div>

    <!-- Filters Bar -->
    <div class="filters-bar">
        <form method="GET" action="${pageContext.request.contextPath}/pedidos">
            <div class="filters-grid">
                <div class="search-box">
                    <input type="text" 
                           name="buscar" 
                           class="search-input" 
                           placeholder="Buscar por número de pedido..."
                           value="${param.buscar}">
                    <i class="fas fa-search search-icon"></i>
                </div>

                <select name="estado" class="filter-select" onchange="this.form.submit()">
                    <option value="">Todos los estados</option>
                    <option value="PENDIENTE" ${param.estado == 'PENDIENTE' ? 'selected' : ''}>Pendiente</option>
                    <option value="PAGADO" ${param.estado == 'PAGADO' ? 'selected' : ''}>Pagado</option>
                    <option value="ENVIADO" ${param.estado == 'ENVIADO' ? 'selected' : ''}>Enviado</option>
                    <option value="ENTREGADO" ${param.estado == 'ENTREGADO' ? 'selected' : ''}>Entregado</option>
                    <option value="CANCELADO" ${param.estado == 'CANCELADO' ? 'selected' : ''}>Cancelado</option>
                </select>

                <button type="button" class="btn-clear-filters" onclick="window.location.href='${pageContext.request.contextPath}/pedidos'">
                    <i class="fas fa-times"></i>
                    Limpiar
                </button>
            </div>
        </form>
    </div>

    <!-- Status Tabs -->
    <div class="status-tabs">
        <a href="${pageContext.request.contextPath}/pedidos" 
           class="status-tab ${empty param.estado ? 'active' : ''}">
            <i class="fas fa-list"></i>
            <span>Todos</span>
            <span class="status-badge">${totalPedidos}</span>
        </a>
        <a href="${pageContext.request.contextPath}/pedidos?estado=PENDIENTE" 
           class="status-tab ${param.estado == 'PENDIENTE' ? 'active' : ''}">
            <i class="fas fa-clock"></i>
            <span>Pendiente</span>
            <span class="status-badge">${pedidosPendientes}</span>
        </a>
        <a href="${pageContext.request.contextPath}/pedidos?estado=ENVIADO" 
           class="status-tab ${param.estado == 'ENVIADO' ? 'active' : ''}">
            <i class="fas fa-shipping-fast"></i>
            <span>Enviado</span>
            <span class="status-badge">${pedidosEnviados}</span>
        </a>
        <a href="${pageContext.request.contextPath}/pedidos?estado=ENTREGADO" 
           class="status-tab ${param.estado == 'ENTREGADO' ? 'active' : ''}">
            <i class="fas fa-check-circle"></i>
            <span>Entregado</span>
            <span class="status-badge">${pedidosEntregados}</span>
        </a>
        <a href="${pageContext.request.contextPath}/pedidos?estado=CANCELADO" 
           class="status-tab ${param.estado == 'CANCELADO' ? 'active' : ''}">
            <i class="fas fa-times-circle"></i>
            <span>Cancelado</span>
            <span class="status-badge">${pedidosCancelados}</span>
        </a>
    </div>

    <!-- Pedidos List -->
    <c:choose>
        <c:when test="${not empty pedidos}">
            <div class="pedidos-list">
                <c:forEach items="${pedidos}" var="pedido">
                    <div class="pedido-card" onclick="window.location.href='${pageContext.request.contextPath}/pedido/detalle?id=${pedido.idPedido}'">
                        <!-- Header -->
                        <div class="pedido-header">
                            <div class="pedido-info">
                                <div class="pedido-number">
                                    <i class="fas fa-hashtag"></i> Pedido ${pedido.idPedido}
                                </div>
                                <div class="pedido-date">
                                    <svg viewBox="0 0 24 24">
                                        <path d="M9 11H7v2h2v-2zm4 0h-2v2h2v-2zm4 0h-2v2h2v-2zm2-7h-1V2h-2v2H8V2H6v2H5c-1.11 0-1.99.9-1.99 2L3 20c0 1.1.89 2 2 2h14c1.1 0 2-.9 2-2V6c0-1.1-.9-2-2-2zm0 16H5V9h14v11z"/>
                                    </svg>
                                    <fmt:formatDate value="${pedido.fechaPedido}" pattern="dd 'de' MMMM 'de' yyyy, HH:mm"/>
                                </div>
                            </div>

                            <span class="pedido-status status-${pedido.estado.toString().toLowerCase()}">
                                <c:choose>
                                    <c:when test="${pedido.estado == 'PENDIENTE'}">
                                        <i class="fas fa-clock"></i>
                                    </c:when>
                                    <c:when test="${pedido.estado == 'PAGADO'}">
                                        <i class="fas fa-credit-card"></i>
                                    </c:when>
                                    <c:when test="${pedido.estado == 'ENVIADO'}">
                                        <i class="fas fa-shipping-fast"></i>
                                    </c:when>
                                    <c:when test="${pedido.estado == 'ENTREGADO'}">
                                        <i class="fas fa-check-circle"></i>
                                    </c:when>
                                    <c:when test="${pedido.estado == 'CANCELADO'}">
                                        <i class="fas fa-times-circle"></i>
                                    </c:when>
                                </c:choose>
                                ${pedido.estado}
                            </span>
                        </div>

                        <!-- Body -->
                        <div class="pedido-body">
                            <!-- Products Preview -->
                            <c:if test="${not empty pedido.detalles}">
                                <div class="pedido-products">
                                    <c:forEach items="${pedido.detalles}" var="detalle" end="4">
                                        <div class="product-mini">
                                            <c:choose>
                                                <c:when test="${not empty detalle.producto.imagenPrincipal}">
                                                    <img src="${pageContext.request.contextPath}/uploads/${detalle.producto.imagenPrincipal}" 
                                                         alt="${detalle.producto.nombre}">
                                                </c:when>
                                                <c:otherwise>
                                                    <svg viewBox="0 0 24 24">
                                                        <path d="M21 19V5c0-1.1-.9-2-2-2H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2zM8.5 13.5l2.5 3.01L14.5 12l4.5 6H5l3.5-4.5z"/>
                                                    </svg>
                                                </c:otherwise>
                                            </c:choose>
                                        </div>
                                    </c:forEach>
                                    <c:if test="${pedido.detalles.size() > 5}">
                                        <div class="product-mini" style="background: rgba(0, 212, 255, 0.1); color: var(--primary-color); display: flex; align-items: center; justify-content: center; font-weight: bold;">
                                            +${pedido.detalles.size() - 5}
                                        </div>
                                    </c:if>
                                </div>
                            </c:if>

                            <!-- Meta Info -->
                            <div class="pedido-meta">
                                <div class="meta-item">
                                    <span class="meta-label">Productos</span>
                                    <span class="meta-value">${pedido.cantidadItems} items</span>
                                </div>
                                <div class="meta-item">
                                    <span class="meta-label">Método de Pago</span>
                                    <span class="meta-value">${pedido.metodoPago}</span>
                                </div>
                                <div class="meta-item">
                                    <span class="meta-label">Envío</span>
                                    <span class="meta-value">Gratis</span>
                                </div>
                                <div class="meta-item">
                                    <span class="meta-label">Total</span>
                                    <span class="meta-value total">
                                        $<fmt:formatNumber value="${pedido.total}" pattern="#,##0.00"/>
                                    </span>
                                </div>
                            </div>
                        </div>

                        <!-- Footer -->
                        <div class="pedido-footer" onclick="event.stopPropagation()">
                            <div class="pedido-actions">
                                <a href="${pageContext.request.contextPath}/pedido/detalle?id=${pedido.idPedido}" 
                                   class="btn-action btn-primary">
                                    <i class="fas fa-eye"></i>
                                    Ver Detalle
                                </a>

                                <c:if test="${pedido.estado == 'ENTREGADO'}">
                                    <a href="${pageContext.request.contextPath}/pedido/recomprar?id=${pedido.idPedido}" 
                                       class="btn-action btn-secondary">
                                        <i class="fas fa-redo"></i>
                                        Volver a Comprar
                                    </a>
                                </c:if>

                                <c:if test="${pedido.estado == 'PENDIENTE'}">
                                    <button type="button" 
                                            class="btn-action btn-danger" 
                                            onclick="confirmarCancelacion(${pedido.idPedido})">
                                        <i class="fas fa-times"></i>
                                        Cancelar
                                    </button>
                                </c:if>
                            </div>

                            <c:if test="${pedido.estado == 'ENVIADO' && not empty pedido.numeroSeguimiento}">
                                <div style="color: var(--text-secondary); font-size: 0.9rem;">
                                    <i class="fas fa-truck"></i>
                                    Tracking: <strong style="color: var(--primary-color);">${pedido.numeroSeguimiento}</strong>
                                </div>
                            </c:if>
                        </div>
                    </div>
                </c:forEach>
            </div>

            <!-- Pagination -->
            <c:if test="${totalPaginas > 1}">
                <nav class="pagination">
                    <c:if test="${paginaActual > 1}">
                        <a href="?pagina=${paginaActual - 1}${not empty param.estado ? '&estado='.concat(param.estado) : ''}" 
                           class="page-btn">
                            <i class="fas fa-chevron-left"></i> Anterior
                        </a>
                    </c:if>

                    <c:forEach begin="1" end="${totalPaginas}" var="i">
                        <c:choose>
                            <c:when test="${i == paginaActual}">
                                <span class="page-btn active">${i}</span>
                            </c:when>
                            <c:otherwise>
                                <a href="?pagina=${i}${not empty param.estado ? '&estado='.concat(param.estado) : ''}" 
                                   class="page-btn">${i}</a>
                            </c:otherwise>
                        </c:choose>
                    </c:forEach>

                    <c:if test="${paginaActual < totalPaginas}">
                        <a href="?pagina=${paginaActual + 1}${not empty param.estado ? '&estado='.concat(param.estado) : ''}" 
                           class="page-btn">
                            Siguiente <i class="fas fa-chevron-right"></i>
                        </a>
                    </c:if>
                </nav>
            </c:if>
        </c:when>
        <c:otherwise>
            <!-- Empty State -->
            <div class="empty-state">
                <div class="empty-icon">
                    <i class="fas fa-shopping-bag"></i>
                </div>
                <h2 class="empty-title">No tienes pedidos aún</h2>
                <p class="empty-text">
                    Explora nuestro catálogo y realiza tu primera compra
                </p>
                <a href="${pageContext.request.contextPath}/productos" class="btn-explore">
                    <i class="fas fa-store"></i>
                    Explorar Productos
                </a>
            </div>
        </c:otherwise>
    </c:choose>
</div>

<!-- Include Footer -->
<%@ include file="/views/components/footer.jsp" %>

<script>
    // Confirmar cancelación de pedido
    function confirmarCancelacion(idPedido) {
        if (confirm('¿Estás seguro de que deseas cancelar este pedido?')) {
            const motivo = prompt('Por favor, indica el motivo de la cancelación (opcional):');
            
            const form = document.createElement('form');
            form.method = 'POST';
            form.action = '${pageContext.request.contextPath}/pedido/cancelar';
            
            const inputId = document.createElement('input');
            inputId.type = 'hidden';
            inputId.name = 'idPedido';
            inputId.value = idPedido;
            form.appendChild(inputId);
            
            if (motivo) {
                const inputMotivo = document.createElement('input');
                inputMotivo.type = 'hidden';
                inputMotivo.name = 'motivo';
                inputMotivo.value = motivo;
                form.appendChild(inputMotivo);
            }
            
            document.body.appendChild(form);
            form.submit();
        }
    }

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
