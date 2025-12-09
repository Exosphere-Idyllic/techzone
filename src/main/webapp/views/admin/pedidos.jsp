<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Gestión de Pedidos - TechZone</title>

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
            --purple-color: #b19cd9;
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

        .header-actions {
            display: flex;
            gap: 15px;
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

        .btn-sm {
            padding: 8px 15px;
            font-size: 0.9rem;
        }

        /* Stats */
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }

        .stat-card {
            background: var(--dark-color);
            border: 1px solid var(--border-color);
            border-radius: 12px;
            padding: 20px;
            transition: all 0.3s ease;
            position: relative;
            overflow: hidden;
        }

        .stat-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 3px;
        }

        .stat-card.total::before { background: var(--primary-color); }
        .stat-card.pending::before { background: var(--warning-color); }
        .stat-card.processing::before { background: var(--info-color); }
        .stat-card.shipped::before { background: var(--purple-color); }
        .stat-card.delivered::before { background: var(--success-color); }

        .stat-card:hover {
            transform: translateY(-3px);
            border-color: var(--primary-color);
            box-shadow: 0 8px 20px rgba(0, 212, 255, 0.2);
        }

        .stat-header {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            margin-bottom: 15px;
        }

        .stat-icon {
            width: 45px;
            height: 45px;
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.3rem;
        }

        .stat-icon.total {
            background: rgba(0, 212, 255, 0.1);
            color: var(--primary-color);
        }

        .stat-icon.pending {
            background: rgba(255, 187, 51, 0.1);
            color: var(--warning-color);
        }

        .stat-icon.processing {
            background: rgba(0, 212, 255, 0.1);
            color: var(--info-color);
        }

        .stat-icon.shipped {
            background: rgba(177, 156, 217, 0.1);
            color: var(--purple-color);
        }

        .stat-icon.delivered {
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
        }

        .stat-amount {
            font-size: 0.95rem;
            color: var(--primary-color);
            font-weight: 600;
            margin-top: 8px;
        }

        /* Tabs */
        .tabs-container {
            background: var(--dark-color);
            border: 1px solid var(--border-color);
            border-radius: 12px;
            margin-bottom: 25px;
            overflow: hidden;
        }

        .tabs-header {
            display: flex;
            border-bottom: 1px solid var(--border-color);
            overflow-x: auto;
        }

        .tab-btn {
            padding: 18px 30px;
            background: transparent;
            border: none;
            color: var(--text-secondary);
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            position: relative;
            white-space: nowrap;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .tab-btn:hover {
            color: var(--text-primary);
            background: rgba(255, 255, 255, 0.02);
        }

        .tab-btn.active {
            color: var(--primary-color);
            background: rgba(0, 212, 255, 0.05);
        }

        .tab-btn.active::after {
            content: '';
            position: absolute;
            bottom: 0;
            left: 0;
            width: 100%;
            height: 3px;
            background: var(--primary-color);
        }

        .tab-badge {
            padding: 3px 10px;
            background: rgba(255, 255, 255, 0.1);
            border-radius: 12px;
            font-size: 0.85rem;
        }

        .tab-btn.active .tab-badge {
            background: var(--primary-color);
            color: #000;
        }

        /* Filters */
        .filters-section {
            padding: 25px;
        }

        .filters-grid {
            display: grid;
            grid-template-columns: 2fr repeat(3, 1fr);
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
        }

        .search-box input {
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

        /* Orders List */
        .orders-list {
            display: flex;
            flex-direction: column;
            gap: 20px;
            padding: 25px;
        }

        .order-card {
            background: var(--darker-color);
            border: 1px solid var(--border-color);
            border-radius: 12px;
            padding: 25px;
            transition: all 0.3s ease;
        }

        .order-card:hover {
            border-color: var(--primary-color);
            box-shadow: 0 5px 20px rgba(0, 212, 255, 0.1);
        }

        .order-header {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            margin-bottom: 20px;
            padding-bottom: 15px;
            border-bottom: 1px solid var(--border-color);
            flex-wrap: wrap;
            gap: 15px;
        }

        .order-info {
            flex: 1;
        }

        .order-number {
            font-size: 1.3rem;
            font-weight: bold;
            color: var(--text-primary);
            margin-bottom: 8px;
        }

        .order-meta {
            display: flex;
            gap: 20px;
            flex-wrap: wrap;
            color: var(--text-secondary);
            font-size: 0.9rem;
        }

        .meta-item {
            display: flex;
            align-items: center;
            gap: 6px;
        }

        .order-status {
            display: flex;
            flex-direction: column;
            align-items: flex-end;
            gap: 10px;
        }

        .badge {
            padding: 8px 16px;
            border-radius: 20px;
            font-size: 0.85rem;
            font-weight: 600;
            display: inline-block;
        }

        .badge-pendiente {
            background: rgba(255, 187, 51, 0.2);
            color: var(--warning-color);
        }

        .badge-pagado {
            background: rgba(0, 212, 255, 0.2);
            color: var(--info-color);
        }

        .badge-enviado {
            background: rgba(177, 156, 217, 0.2);
            color: var(--purple-color);
        }

        .badge-entregado {
            background: rgba(0, 200, 81, 0.2);
            color: var(--success-color);
        }

        .badge-cancelado {
            background: rgba(255, 68, 68, 0.2);
            color: var(--danger-color);
        }

        .order-total {
            font-size: 1.5rem;
            font-weight: bold;
            color: var(--primary-color);
        }

        .order-body {
            display: grid;
            grid-template-columns: 2fr 1fr 1fr;
            gap: 25px;
            margin-bottom: 20px;
        }

        .order-customer {
            display: flex;
            flex-direction: column;
            gap: 10px;
        }

        .customer-name {
            font-weight: 600;
            color: var(--text-primary);
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .customer-info {
            color: var(--text-secondary);
            font-size: 0.9rem;
            display: flex;
            flex-direction: column;
            gap: 5px;
        }

        .order-products {
            display: flex;
            flex-direction: column;
            gap: 8px;
        }

        .products-preview {
            display: flex;
            gap: 8px;
            flex-wrap: wrap;
        }

        .product-thumb {
            width: 50px;
            height: 50px;
            background: var(--light-color);
            border-radius: 6px;
            overflow: hidden;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .product-thumb img {
            max-width: 100%;
            max-height: 100%;
            object-fit: contain;
        }

        .products-count {
            font-size: 0.85rem;
            color: var(--text-secondary);
            margin-top: 5px;
        }

        .order-shipping {
            display: flex;
            flex-direction: column;
            gap: 8px;
        }

        .shipping-method {
            font-weight: 600;
            color: var(--text-primary);
        }

        .shipping-address {
            font-size: 0.9rem;
            color: var(--text-secondary);
        }

        .tracking-number {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 6px 12px;
            background: rgba(0, 212, 255, 0.1);
            border-radius: 6px;
            font-size: 0.85rem;
            color: var(--primary-color);
            margin-top: 5px;
        }

        .order-footer {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding-top: 15px;
            border-top: 1px solid var(--border-color);
            flex-wrap: wrap;
            gap: 15px;
        }

        .order-actions {
            display: flex;
            gap: 10px;
        }

        .btn-action {
            padding: 10px 20px;
            border-radius: 8px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            border: 1px solid var(--border-color);
            background: var(--darker-color);
            color: var(--text-primary);
            font-size: 0.9rem;
            display: inline-flex;
            align-items: center;
            gap: 8px;
        }

        .btn-action:hover {
            transform: translateY(-2px);
        }

        .btn-action.view:hover {
            background: var(--primary-color);
            color: #000;
            border-color: var(--primary-color);
        }

        .btn-action.process:hover {
            background: var(--success-color);
            color: #fff;
            border-color: var(--success-color);
        }

        .btn-action.cancel:hover {
            background: var(--danger-color);
            color: #fff;
            border-color: var(--danger-color);
        }

        .status-selector {
            padding: 10px 15px;
            background: var(--darker-color);
            border: 1px solid var(--border-color);
            border-radius: 8px;
            color: var(--text-primary);
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
        }

        .status-selector:hover {
            border-color: var(--primary-color);
        }

        /* Empty State */
        .empty-state {
            text-align: center;
            padding: 80px 20px;
        }

        .empty-icon {
            width: 100px;
            height: 100px;
            margin: 0 auto 20px;
            background: rgba(255, 255, 255, 0.05);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 3rem;
            color: var(--text-secondary);
        }

        .empty-title {
            font-size: 1.5rem;
            font-weight: bold;
            margin-bottom: 10px;
            color: var(--text-primary);
        }

        .empty-text {
            color: var(--text-secondary);
            margin-bottom: 25px;
        }

        /* Pagination */
        .pagination {
            display: flex;
            justify-content: center;
            align-items: center;
            gap: 10px;
            padding: 25px;
            border-top: 1px solid var(--border-color);
        }

        .pagination-btn {
            padding: 10px 15px;
            background: var(--darker-color);
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
                transform: translateY(-20px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
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

        /* Responsive */
        @media (max-width: 1024px) {
            .filters-grid {
                grid-template-columns: repeat(2, 1fr);
            }

            .order-body {
                grid-template-columns: 1fr;
            }
        }

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

            .order-header {
                flex-direction: column;
            }

            .order-status {
                align-items: flex-start;
            }

            .order-footer {
                flex-direction: column;
                align-items: stretch;
            }

            .order-actions {
                flex-wrap: wrap;
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

            .tabs-header {
                flex-wrap: wrap;
            }

            .tab-btn {
                flex: 1;
                min-width: 120px;
            }
        }
    </style>
</head>
<body>
<!-- Include Header -->
<%@ include file="/views/components/header.jsp" %>

<div class="pedidos-container">
    <!-- Header -->
    <div class="page-header">
        <h1 class="page-title">Gestión de Pedidos</h1>
        <div class="header-actions">
            <button class="btn btn-secondary" onclick="exportarPedidos()">
                <i class="fas fa-file-excel"></i>
                Exportar
            </button>
            <button class="btn btn-secondary" onclick="window.print()">
                <i class="fas fa-print"></i>
                Imprimir
            </button>
        </div>
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
        <div class="stat-card total">
            <div class="stat-header">
                <div class="stat-icon total">
                    <i class="fas fa-shopping-cart"></i>
                </div>
            </div>
            <div class="stat-value">${totalPedidos}</div>
            <div class="stat-label">Total Pedidos</div>
            <div class="stat-amount">
                $<fmt:formatNumber value="${totalVentas}" pattern="#,##0.00"/>
            </div>
        </div>

        <div class="stat-card pending">
            <div class="stat-header">
                <div class="stat-icon pending">
                    <i class="fas fa-clock"></i>
                </div>
            </div>
            <div class="stat-value">${pedidosPendientes}</div>
            <div class="stat-label">Pendientes</div>
            <div class="stat-amount">
                $<fmt:formatNumber value="${ventasPendientes}" pattern="#,##0.00"/>
            </div>
        </div>

        <div class="stat-card processing">
            <div class="stat-header">
                <div class="stat-icon processing">
                    <i class="fas fa-sync"></i>
                </div>
            </div>
            <div class="stat-value">${pedidosPagados}</div>
            <div class="stat-label">Pagados</div>
            <div class="stat-amount">
                $<fmt:formatNumber value="${ventasPagadas}" pattern="#,##0.00"/>
            </div>
        </div>

        <div class="stat-card shipped">
            <div class="stat-header">
                <div class="stat-icon shipped">
                    <i class="fas fa-truck"></i>
                </div>
            </div>
            <div class="stat-value">${pedidosEnviados}</div>
            <div class="stat-label">Enviados</div>
            <div class="stat-amount">
                $<fmt:formatNumber value="${ventasEnviadas}" pattern="#,##0.00"/>
            </div>
        </div>

        <div class="stat-card delivered">
            <div class="stat-header">
                <div class="stat-icon delivered">
                    <i class="fas fa-check-circle"></i>
                </div>
            </div>
            <div class="stat-value">${pedidosEntregados}</div>
            <div class="stat-label">Entregados</div>
            <div class="stat-amount">
                $<fmt:formatNumber value="${ventasEntregadas}" pattern="#,##0.00"/>
            </div>
        </div>
    </div>

    <!-- Tabs Container -->
    <div class="tabs-container">
        <!-- Tabs Header -->
        <div class="tabs-header">
            <button class="tab-btn ${empty param.estado or param.estado == 'todos' ? 'active' : ''}" 
                    onclick="filtrarPorEstado('todos')">
                <i class="fas fa-list"></i>
                Todos
                <span class="tab-badge">${totalPedidos}</span>
            </button>
            <button class="tab-btn ${param.estado == 'pendiente' ? 'active' : ''}" 
                    onclick="filtrarPorEstado('pendiente')">
                <i class="fas fa-clock"></i>
                Pendientes
                <span class="tab-badge">${pedidosPendientes}</span>
            </button>
            <button class="tab-btn ${param.estado == 'pagado' ? 'active' : ''}" 
                    onclick="filtrarPorEstado('pagado')">
                <i class="fas fa-credit-card"></i>
                Pagados
                <span class="tab-badge">${pedidosPagados}</span>
            </button>
            <button class="tab-btn ${param.estado == 'enviado' ? 'active' : ''}" 
                    onclick="filtrarPorEstado('enviado')">
                <i class="fas fa-truck"></i>
                Enviados
                <span class="tab-badge">${pedidosEnviados}</span>
            </button>
            <button class="tab-btn ${param.estado == 'entregado' ? 'active' : ''}" 
                    onclick="filtrarPorEstado('entregado')">
                <i class="fas fa-check-circle"></i>
                Entregados
                <span class="tab-badge">${pedidosEntregados}</span>
            </button>
            <button class="tab-btn ${param.estado == 'cancelado' ? 'active' : ''}" 
                    onclick="filtrarPorEstado('cancelado')">
                <i class="fas fa-times-circle"></i>
                Cancelados
                <span class="tab-badge">${pedidosCancelados}</span>
            </button>
        </div>

        <!-- Filters -->
        <div class="filters-section">
            <form method="get" action="${pageContext.request.contextPath}/admin/pedidos">
                <input type="hidden" name="estado" value="${param.estado}">
                
                <div class="filters-grid">
                    <div class="form-group">
                        <label class="form-label">Buscar</label>
                        <div class="search-box">
                            <i class="fas fa-search search-icon"></i>
                            <input type="text" name="busqueda" class="form-control" 
                                   placeholder="Número de pedido, cliente..." 
                                   value="${param.busqueda}">
                        </div>
                    </div>

                    <div class="form-group">
                        <label class="form-label">Fecha Desde</label>
                        <input type="date" name="fechaDesde" class="form-control" 
                               value="${param.fechaDesde}">
                    </div>

                    <div class="form-group">
                        <label class="form-label">Fecha Hasta</label>
                        <input type="date" name="fechaHasta" class="form-control" 
                               value="${param.fechaHasta}">
                    </div>

                    <div class="form-group">
                        <label class="form-label">Método de Pago</label>
                        <select name="metodoPago" class="form-control">
                            <option value="">Todos</option>
                            <option value="efectivo" ${param.metodoPago == 'efectivo' ? 'selected' : ''}>Efectivo</option>
                            <option value="tarjeta" ${param.metodoPago == 'tarjeta' ? 'selected' : ''}>Tarjeta</option>
                            <option value="transferencia" ${param.metodoPago == 'transferencia' ? 'selected' : ''}>Transferencia</option>
                        </select>
                    </div>
                </div>

                <div class="filters-actions">
                    <button type="submit" class="btn btn-primary btn-sm">
                        <i class="fas fa-filter"></i>
                        Aplicar Filtros
                    </button>
                    <a href="${pageContext.request.contextPath}/admin/pedidos" class="btn btn-secondary btn-sm">
                        <i class="fas fa-times"></i>
                        Limpiar
                    </a>
                </div>
            </form>
        </div>

        <!-- Orders List -->
        <div class="orders-list">
            <c:choose>
                <c:when test="${not empty pedidos}">
                    <c:forEach items="${pedidos}" var="pedido">
                        <div class="order-card">
                            <!-- Header -->
                            <div class="order-header">
                                <div class="order-info">
                                    <div class="order-number">Pedido #${pedido.idPedido}</div>
                                    <div class="order-meta">
                                        <div class="meta-item">
                                            <i class="fas fa-calendar"></i>
                                            <fmt:formatDate value="${pedido.fechaPedido}" pattern="dd/MM/yyyy HH:mm"/>
                                        </div>
                                        <div class="meta-item">
                                            <i class="fas fa-user"></i>
                                            ${pedido.usuario.nombreCompleto}
                                        </div>
                                        <div class="meta-item">
                                            <i class="fas fa-credit-card"></i>
                                            ${pedido.metodoPago}
                                        </div>
                                    </div>
                                </div>

                                <div class="order-status">
                                    <span class="badge badge-${pedido.estado}">
                                        ${pedido.estado}
                                    </span>
                                    <div class="order-total">
                                        $<fmt:formatNumber value="${pedido.total}" pattern="#,##0.00"/>
                                    </div>
                                </div>
                            </div>

                            <!-- Body -->
                            <div class="order-body">
                                <!-- Customer Info -->
                                <div class="order-customer">
                                    <div class="customer-name">
                                        <i class="fas fa-user-circle"></i>
                                        ${pedido.usuario.nombreCompleto}
                                    </div>
                                    <div class="customer-info">
                                        <div><i class="fas fa-envelope"></i> ${pedido.usuario.email}</div>
                                        <c:if test="${not empty pedido.usuario.telefono}">
                                            <div><i class="fas fa-phone"></i> ${pedido.usuario.telefono}</div>
                                        </c:if>
                                    </div>
                                </div>

                                <!-- Products Preview -->
                                <div class="order-products">
                                    <div class="products-preview">
                                        <c:forEach items="${pedido.detalles}" var="detalle" end="3">
                                            <div class="product-thumb">
                                                <c:choose>
                                                    <c:when test="${not empty detalle.producto.imagenPrincipal}">
                                                        <img src="${pageContext.request.contextPath}/uploads/${detalle.producto.imagenPrincipal}" 
                                                             alt="${detalle.producto.nombre}">
                                                    </c:when>
                                                    <c:otherwise>
                                                        <i class="fas fa-image" style="color: #666;"></i>
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>
                                        </c:forEach>
                                        <c:if test="${fn:length(pedido.detalles) > 4}">
                                            <div class="product-thumb" style="background: var(--primary-color); color: #000;">
                                                +${fn:length(pedido.detalles) - 4}
                                            </div>
                                        </c:if>
                                    </div>
                                    <div class="products-count">
                                        ${fn:length(pedido.detalles)} producto(s)
                                    </div>
                                </div>

                                <!-- Shipping Info -->
                                <div class="order-shipping">
                                    <div class="shipping-method">
                                        <i class="fas fa-truck"></i>
                                        ${pedido.tipoEnvio}
                                    </div>
                                    <div class="shipping-address">
                                        ${pedido.direccionEnvio}
                                    </div>
                                    <c:if test="${not empty pedido.numeroSeguimiento}">
                                        <div class="tracking-number">
                                            <i class="fas fa-barcode"></i>
                                            ${pedido.numeroSeguimiento}
                                        </div>
                                    </c:if>
                                </div>
                            </div>

                            <!-- Footer -->
                            <div class="order-footer">
                                <div class="order-actions">
                                    <button class="btn-action view" 
                                            onclick="window.location.href='${pageContext.request.contextPath}/pedido/detalle?id=${pedido.idPedido}'">
                                        <i class="fas fa-eye"></i>
                                        Ver Detalle
                                    </button>

                                    <c:if test="${pedido.estado == 'pendiente' or pedido.estado == 'pagado'}">
                                        <button class="btn-action process" 
                                                onclick="procesarPedido(${pedido.idPedido})">
                                            <i class="fas fa-check"></i>
                                            Procesar
                                        </button>
                                    </c:if>

                                    <c:if test="${pedido.estado != 'cancelado' and pedido.estado != 'entregado'}">
                                        <button class="btn-action cancel" 
                                                onclick="cancelarPedido(${pedido.idPedido})">
                                            <i class="fas fa-times"></i>
                                            Cancelar
                                        </button>
                                    </c:if>
                                </div>

                                <select class="status-selector" 
                                        onchange="cambiarEstado(${pedido.idPedido}, this.value)">
                                    <option value="">Cambiar estado...</option>
                                    <option value="pendiente">Pendiente</option>
                                    <option value="pagado">Pagado</option>
                                    <option value="enviado">Enviado</option>
                                    <option value="entregado">Entregado</option>
                                    <option value="cancelado">Cancelado</option>
                                </select>
                            </div>
                        </div>
                    </c:forEach>
                </c:when>
                <c:otherwise>
                    <div class="empty-state">
                        <div class="empty-icon">
                            <i class="fas fa-shopping-cart"></i>
                        </div>
                        <div class="empty-title">No hay pedidos</div>
                        <div class="empty-text">
                            No se encontraron pedidos con los filtros aplicados
                        </div>
                        <a href="${pageContext.request.contextPath}/admin/pedidos" class="btn btn-primary">
                            Ver todos los pedidos
                        </a>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>

        <!-- Pagination -->
        <c:if test="${totalPaginas > 1}">
            <div class="pagination">
                <button class="pagination-btn" 
                        onclick="cambiarPagina(${paginaActual - 1})"
                        ${paginaActual <= 1 ? 'disabled' : ''}>
                    <i class="fas fa-chevron-left"></i>
                </button>

                <c:forEach begin="1" end="${totalPaginas}" var="i">
                    <c:if test="${i <= 5 or (i >= paginaActual - 2 and i <= paginaActual + 2) or i >= totalPaginas - 4}">
                        <button class="pagination-btn ${i == paginaActual ? 'active' : ''}" 
                                onclick="cambiarPagina(${i})">
                            ${i}
                        </button>
                    </c:if>
                </c:forEach>

                <button class="pagination-btn" 
                        onclick="cambiarPagina(${paginaActual + 1})"
                        ${paginaActual >= totalPaginas ? 'disabled' : ''}>
                    <i class="fas fa-chevron-right"></i>
                </button>

                <span class="pagination-info">
                    Página ${paginaActual} de ${totalPaginas}
                </span>
            </div>
        </c:if>
    </div>
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

    // Filter by status
    function filtrarPorEstado(estado) {
        const url = new URL(window.location);
        url.searchParams.set('estado', estado);
        url.searchParams.delete('pagina');
        window.location.href = url.toString();
    }

    // Change page
    function cambiarPagina(pagina) {
        const url = new URL(window.location);
        url.searchParams.set('pagina', pagina);
        window.location.href = url.toString();
    }

    // Change status
    function cambiarEstado(idPedido, nuevoEstado) {
        if (!nuevoEstado) return;
        
        if (confirm('¿Estás seguro de cambiar el estado del pedido?')) {
            window.location.href = `${pageContext.request.contextPath}/admin/pedidos?accion=cambiarEstado&id=${idPedido}&estado=${nuevoEstado}`;
        }
    }

    // Process order
    function procesarPedido(idPedido) {
        if (confirm('¿Confirmar procesamiento del pedido?')) {
            window.location.href = `${pageContext.request.contextPath}/admin/pedidos?accion=procesar&id=${idPedido}`;
        }
    }

    // Cancel order
    function cancelarPedido(idPedido) {
        const motivo = prompt('Ingresa el motivo de cancelación:');
        if (motivo) {
            window.location.href = `${pageContext.request.contextPath}/admin/pedidos?accion=cancelar&id=${idPedido}&motivo=${encodeURIComponent(motivo)}`;
        }
    }

    // Export orders
    function exportarPedidos() {
        const url = new URL(window.location);
        url.searchParams.set('accion', 'exportar');
        window.location.href = url.toString();
    }
</script>
</body>
</html>
