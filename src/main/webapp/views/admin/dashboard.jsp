<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard Administrativo - TechZone</title>

    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <!-- Chart.js -->
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

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

        .dashboard-container {
            max-width: 1600px;
            margin: 0 auto;
            padding: 40px 20px 60px;
        }

        /* Header */
        .dashboard-header {
            margin-bottom: 40px;
        }

        .header-top {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 15px;
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

        .btn-action {
            padding: 12px 25px;
            border-radius: 10px;
            font-weight: 600;
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

        .date-range {
            display: flex;
            align-items: center;
            gap: 10px;
            color: var(--text-secondary);
            font-size: 0.95rem;
        }

        .date-range svg {
            width: 18px;
            height: 18px;
            fill: var(--primary-color);
        }

        /* Quick Stats */
        .quick-stats {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 25px;
            margin-bottom: 40px;
        }

        .stat-card {
            background: var(--dark-color);
            border: 1px solid var(--border-color);
            border-radius: 15px;
            padding: 25px;
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
            height: 4px;
            background: linear-gradient(90deg, var(--primary-color), var(--secondary-color));
        }

        .stat-card:hover {
            transform: translateY(-5px);
            border-color: var(--primary-color);
            box-shadow: 0 10px 30px rgba(0, 212, 255, 0.2);
        }

        .stat-header {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            margin-bottom: 15px;
        }

        .stat-icon {
            width: 50px;
            height: 50px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.5rem;
        }

        .stat-icon.revenue {
            background: rgba(0, 212, 255, 0.1);
            color: var(--primary-color);
        }

        .stat-icon.orders {
            background: rgba(0, 200, 81, 0.1);
            color: var(--success-color);
        }

        .stat-icon.users {
            background: rgba(138, 43, 226, 0.1);
            color: #b19cd9;
        }

        .stat-icon.products {
            background: rgba(255, 187, 51, 0.1);
            color: var(--warning-color);
        }

        .stat-trend {
            padding: 5px 12px;
            border-radius: 20px;
            font-size: 0.85rem;
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 5px;
        }

        .trend-up {
            background: rgba(0, 200, 81, 0.2);
            color: var(--success-color);
        }

        .trend-down {
            background: rgba(255, 68, 68, 0.2);
            color: var(--danger-color);
        }

        .stat-value {
            font-size: 2.5rem;
            font-weight: bold;
            color: var(--text-primary);
            margin-bottom: 5px;
        }

        .stat-label {
            color: var(--text-secondary);
            font-size: 0.95rem;
        }

        .stat-footer {
            margin-top: 15px;
            padding-top: 15px;
            border-top: 1px solid var(--border-color);
            font-size: 0.85rem;
            color: var(--text-secondary);
        }

        /* Charts Section */
        .charts-section {
            display: grid;
            grid-template-columns: 2fr 1fr;
            gap: 25px;
            margin-bottom: 40px;
        }

        .chart-card {
            background: var(--dark-color);
            border: 1px solid var(--border-color);
            border-radius: 15px;
            padding: 30px;
        }

        .chart-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 25px;
        }

        .chart-title {
            font-size: 1.3rem;
            font-weight: bold;
            color: var(--text-primary);
        }

        .chart-period {
            display: flex;
            gap: 10px;
        }

        .period-btn {
            padding: 6px 15px;
            background: rgba(255, 255, 255, 0.05);
            border: 1px solid var(--border-color);
            border-radius: 6px;
            color: var(--text-secondary);
            font-size: 0.85rem;
            cursor: pointer;
            transition: all 0.3s ease;
        }

        .period-btn:hover,
        .period-btn.active {
            background: var(--primary-color);
            color: #000;
            border-color: var(--primary-color);
        }

        /* Recent Activity */
        .activity-section {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 25px;
            margin-bottom: 40px;
        }

        .activity-card {
            background: var(--dark-color);
            border: 1px solid var(--border-color);
            border-radius: 15px;
            padding: 25px;
        }

        .activity-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
            padding-bottom: 15px;
            border-bottom: 1px solid var(--border-color);
        }

        .activity-title {
            font-size: 1.2rem;
            font-weight: bold;
        }

        .btn-view-all {
            color: var(--primary-color);
            text-decoration: none;
            font-weight: 600;
            font-size: 0.9rem;
            transition: color 0.3s ease;
        }

        .btn-view-all:hover {
            color: var(--primary-hover);
        }

        .activity-list {
            display: flex;
            flex-direction: column;
            gap: 15px;
            max-height: 400px;
            overflow-y: auto;
        }

        .activity-list::-webkit-scrollbar {
            width: 6px;
        }

        .activity-list::-webkit-scrollbar-track {
            background: rgba(255, 255, 255, 0.05);
        }

        .activity-list::-webkit-scrollbar-thumb {
            background: var(--primary-color);
            border-radius: 3px;
        }

        .activity-item {
            display: flex;
            gap: 15px;
            padding: 15px;
            background: rgba(255, 255, 255, 0.02);
            border-radius: 10px;
            transition: all 0.3s ease;
            cursor: pointer;
        }

        .activity-item:hover {
            background: rgba(255, 255, 255, 0.05);
            transform: translateX(5px);
        }

        .activity-icon {
            width: 40px;
            height: 40px;
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            flex-shrink: 0;
        }

        .activity-icon.order {
            background: rgba(0, 212, 255, 0.1);
            color: var(--primary-color);
        }

        .activity-icon.user {
            background: rgba(138, 43, 226, 0.1);
            color: #b19cd9;
        }

        .activity-icon.product {
            background: rgba(255, 187, 51, 0.1);
            color: var(--warning-color);
        }

        .activity-content {
            flex: 1;
        }

        .activity-text {
            color: var(--text-primary);
            margin-bottom: 5px;
            font-size: 0.95rem;
        }

        .activity-time {
            color: var(--text-secondary);
            font-size: 0.85rem;
        }

        .activity-value {
            font-weight: bold;
            color: var(--primary-color);
            white-space: nowrap;
        }

        /* Top Products */
        .top-products {
            background: var(--dark-color);
            border: 1px solid var(--border-color);
            border-radius: 15px;
            padding: 25px;
            margin-bottom: 40px;
        }

        .products-table {
            width: 100%;
            border-collapse: collapse;
        }

        .products-table thead {
            background: rgba(255, 255, 255, 0.02);
        }

        .products-table th {
            padding: 15px;
            text-align: left;
            font-weight: 600;
            color: var(--text-secondary);
            font-size: 0.9rem;
            text-transform: uppercase;
            border-bottom: 2px solid var(--border-color);
        }

        .products-table td {
            padding: 15px;
            border-bottom: 1px solid var(--border-color);
        }

        .products-table tr:hover {
            background: rgba(255, 255, 255, 0.02);
        }

        .product-info {
            display: flex;
            align-items: center;
            gap: 15px;
        }

        .product-image {
            width: 50px;
            height: 50px;
            background: var(--light-color);
            border-radius: 8px;
            overflow: hidden;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .product-image img {
            max-width: 100%;
            max-height: 100%;
            object-fit: contain;
        }

        .product-name {
            font-weight: 600;
            color: var(--text-primary);
        }

        .product-category {
            font-size: 0.85rem;
            color: var(--text-secondary);
        }

        .stock-badge {
            padding: 5px 12px;
            border-radius: 15px;
            font-size: 0.85rem;
            font-weight: 600;
        }

        .stock-high {
            background: rgba(0, 200, 81, 0.2);
            color: var(--success-color);
        }

        .stock-medium {
            background: rgba(255, 187, 51, 0.2);
            color: var(--warning-color);
        }

        .stock-low {
            background: rgba(255, 68, 68, 0.2);
            color: var(--danger-color);
        }

        /* Quick Actions */
        .quick-actions {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
        }

        .action-card {
            background: var(--dark-color);
            border: 1px solid var(--border-color);
            border-radius: 12px;
            padding: 25px;
            text-align: center;
            transition: all 0.3s ease;
            cursor: pointer;
            text-decoration: none;
        }

        .action-card:hover {
            transform: translateY(-5px);
            border-color: var(--primary-color);
            box-shadow: 0 10px 30px rgba(0, 212, 255, 0.2);
        }

        .action-icon {
            width: 60px;
            height: 60px;
            margin: 0 auto 15px;
            border-radius: 12px;
            background: linear-gradient(135deg, var(--primary-color), var(--secondary-color));
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.8rem;
            color: #000;
        }

        .action-title {
            font-weight: 600;
            color: var(--text-primary);
            margin-bottom: 5px;
        }

        .action-desc {
            font-size: 0.85rem;
            color: var(--text-secondary);
        }

        /* Alert */
        .alert {
            padding: 15px 20px;
            border-radius: 10px;
            margin-bottom: 25px;
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .alert-info {
            background: rgba(0, 212, 255, 0.1);
            border: 1px solid var(--info-color);
            color: var(--info-color);
        }

        /* Responsive */
        @media (max-width: 1200px) {
            .charts-section {
                grid-template-columns: 1fr;
            }
        }

        @media (max-width: 768px) {
            body {
                padding-right: 0;
            }

            .dashboard-container {
                padding: 20px 15px;
            }

            .page-title {
                font-size: 2rem;
            }

            .quick-stats {
                grid-template-columns: repeat(2, 1fr);
            }

            .activity-section {
                grid-template-columns: 1fr;
            }

            .header-top {
                flex-direction: column;
                align-items: flex-start;
            }

            .products-table {
                font-size: 0.85rem;
            }
        }

        @media (max-width: 480px) {
            .quick-stats {
                grid-template-columns: 1fr;
            }

            .products-table th,
            .products-table td {
                padding: 10px;
            }
        }
    </style>
</head>
<body>
<!-- Include Header -->
<%@ include file="/views/components/header.jsp" %>

<div class="dashboard-container">
    <!-- Header -->
    <div class="dashboard-header">
        <div class="header-top">
            <div>
                <h1 class="page-title">Dashboard Administrativo</h1>
                <div class="date-range">
                    <svg viewBox="0 0 24 24">
                        <path d="M9 11H7v2h2v-2zm4 0h-2v2h2v-2zm4 0h-2v2h2v-2zm2-7h-1V2h-2v2H8V2H6v2H5c-1.11 0-1.99.9-1.99 2L3 20c0 1.1.89 2 2 2h14c1.1 0 2-.9 2-2V6c0-1.1-.9-2-2-2zm0 16H5V9h14v11z"/>
                    </svg>
                    <span>
                        <fmt:formatDate value="${fechaInicio}" pattern="dd/MM/yyyy"/> - 
                        <fmt:formatDate value="${fechaFin}" pattern="dd/MM/yyyy"/>
                    </span>
                </div>
            </div>

            <div class="header-actions">
                <button class="btn-action btn-secondary" onclick="window.print()">
                    <i class="fas fa-print"></i>
                    Imprimir
                </button>
                <a href="${pageContext.request.contextPath}/admin/estadisticas" class="btn-action btn-primary">
                    <i class="fas fa-chart-line"></i>
                    Reportes
                </a>
            </div>
        </div>

        <c:if test="${not empty alertasStockBajo}">
            <div class="alert alert-info">
                <i class="fas fa-exclamation-triangle"></i>
                <span>
                    Hay <strong>${alertasStockBajo}</strong> productos con stock bajo. 
                    <a href="${pageContext.request.contextPath}/admin/productos?stockBajo=true" 
                       style="color: var(--primary-color); text-decoration: underline;">
                        Ver ahora
                    </a>
                </span>
            </div>
        </c:if>
    </div>

    <!-- Quick Stats -->
    <div class="quick-stats">
        <!-- Revenue -->
        <div class="stat-card">
            <div class="stat-header">
                <div class="stat-icon revenue">
                    <i class="fas fa-dollar-sign"></i>
                </div>
                <div class="stat-trend trend-up">
                    <i class="fas fa-arrow-up"></i>
                    <span>+${crecimientoVentas}%</span>
                </div>
            </div>
            <div class="stat-value">
                $<fmt:formatNumber value="${ventasTotales}" pattern="#,##0.00"/>
            </div>
            <div class="stat-label">Ventas Totales</div>
            <div class="stat-footer">
                vs mes anterior: $<fmt:formatNumber value="${ventasMesAnterior}" pattern="#,##0.00"/>
            </div>
        </div>

        <!-- Orders -->
        <div class="stat-card">
            <div class="stat-header">
                <div class="stat-icon orders">
                    <i class="fas fa-shopping-cart"></i>
                </div>
                <div class="stat-trend trend-up">
                    <i class="fas fa-arrow-up"></i>
                    <span>+${crecimientoPedidos}%</span>
                </div>
            </div>
            <div class="stat-value">${totalPedidos}</div>
            <div class="stat-label">Pedidos</div>
            <div class="stat-footer">
                ${pedidosPendientes} pendientes de procesar
            </div>
        </div>

        <!-- Users -->
        <div class="stat-card">
            <div class="stat-header">
                <div class="stat-icon users">
                    <i class="fas fa-users"></i>
                </div>
                <div class="stat-trend trend-up">
                    <i class="fas fa-arrow-up"></i>
                    <span>+${crecimientoUsuarios}%</span>
                </div>
            </div>
            <div class="stat-value">${totalUsuarios}</div>
            <div class="stat-label">Usuarios Registrados</div>
            <div class="stat-footer">
                ${usuariosNuevos} nuevos este mes
            </div>
        </div>

        <!-- Products -->
        <div class="stat-card">
            <div class="stat-header">
                <div class="stat-icon products">
                    <i class="fas fa-box"></i>
                </div>
                <div class="stat-trend ${productosNuevos > 0 ? 'trend-up' : 'trend-down'}">
                    <i class="fas fa-${productosNuevos > 0 ? 'arrow-up' : 'minus'}"></i>
                    <span>${productosNuevos > 0 ? '+' : ''}${productosNuevos}</span>
                </div>
            </div>
            <div class="stat-value">${totalProductos}</div>
            <div class="stat-label">Productos</div>
            <div class="stat-footer">
                ${productosStockBajo} con stock bajo
            </div>
        </div>
    </div>

    <!-- Charts Section -->
    <div class="charts-section">
        <!-- Sales Chart -->
        <div class="chart-card">
            <div class="chart-header">
                <h3 class="chart-title">Ventas del Mes</h3>
                <div class="chart-period">
                    <button class="period-btn" onclick="changePeriod('week')">7 días</button>
                    <button class="period-btn active" onclick="changePeriod('month')">30 días</button>
                    <button class="period-btn" onclick="changePeriod('year')">1 año</button>
                </div>
            </div>
            <canvas id="salesChart" height="100"></canvas>
        </div>

        <!-- Category Distribution -->
        <div class="chart-card">
            <div class="chart-header">
                <h3 class="chart-title">Ventas por Categoría</h3>
            </div>
            <canvas id="categoryChart" height="250"></canvas>
        </div>
    </div>

    <!-- Recent Activity -->
    <div class="activity-section">
        <!-- Recent Orders -->
        <div class="activity-card">
            <div class="activity-header">
                <h3 class="activity-title">Pedidos Recientes</h3>
                <a href="${pageContext.request.contextPath}/admin/pedidos" class="btn-view-all">
                    Ver todos <i class="fas fa-arrow-right"></i>
                </a>
            </div>
            <div class="activity-list">
                <c:forEach items="${pedidosRecientes}" var="pedido" end="4">
                    <div class="activity-item" onclick="window.location.href='${pageContext.request.contextPath}/pedido/detalle?id=${pedido.idPedido}'">
                        <div class="activity-icon order">
                            <i class="fas fa-shopping-bag"></i>
                        </div>
                        <div class="activity-content">
                            <div class="activity-text">
                                Pedido #${pedido.idPedido} - ${pedido.usuario.nombreCompleto}
                            </div>
                            <div class="activity-time">
                                <fmt:formatDate value="${pedido.fechaPedido}" pattern="dd/MM/yyyy HH:mm"/>
                            </div>
                        </div>
                        <div class="activity-value">
                            $<fmt:formatNumber value="${pedido.total}" pattern="#,##0.00"/>
                        </div>
                    </div>
                </c:forEach>
            </div>
        </div>

        <!-- Recent Users -->
        <div class="activity-card">
            <div class="activity-header">
                <h3 class="activity-title">Usuarios Nuevos</h3>
                <a href="${pageContext.request.contextPath}/admin/usuarios" class="btn-view-all">
                    Ver todos <i class="fas fa-arrow-right"></i>
                </a>
            </div>
            <div class="activity-list">
                <c:forEach items="${usuariosRecientes}" var="usuario" end="4">
                    <div class="activity-item" onclick="window.location.href='${pageContext.request.contextPath}/admin/usuarios?id=${usuario.idUsuario}'">
                        <div class="activity-icon user">
                            <i class="fas fa-user"></i>
                        </div>
                        <div class="activity-content">
                            <div class="activity-text">${usuario.nombreCompleto}</div>
                            <div class="activity-time">
                                <fmt:formatDate value="${usuario.fechaRegistro}" pattern="dd/MM/yyyy HH:mm"/>
                            </div>
                        </div>
                        <div class="activity-value">${usuario.rol}</div>
                    </div>
                </c:forEach>
            </div>
        </div>
    </div>

    <!-- Top Products -->
    <div class="top-products">
        <div class="activity-header">
            <h3 class="activity-title">Productos Más Vendidos</h3>
            <a href="${pageContext.request.contextPath}/admin/productos" class="btn-view-all">
                Ver todos <i class="fas fa-arrow-right"></i>
            </a>
        </div>

        <table class="products-table">
            <thead>
                <tr>
                    <th>Producto</th>
                    <th>Categoría</th>
                    <th>Precio</th>
                    <th>Vendidos</th>
                    <th>Stock</th>
                    <th>Total</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach items="${productosMasVendidos}" var="producto" end="9">
                    <tr>
                        <td>
                            <div class="product-info">
                                <div class="product-image">
                                    <c:choose>
                                        <c:when test="${not empty producto.imagenPrincipal}">
                                            <img src="${pageContext.request.contextPath}/uploads/${producto.imagenPrincipal}" alt="${producto.nombre}">
                                        </c:when>
                                        <c:otherwise>
                                            <i class="fas fa-image" style="color: #666;"></i>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                                <div>
                                    <div class="product-name">${producto.nombre}</div>
                                    <div class="product-category">${producto.categoria.nombre}</div>
                                </div>
                            </div>
                        </td>
                        <td>${producto.categoria.nombre}</td>
                        <td>$<fmt:formatNumber value="${producto.precio}" pattern="#,##0.00"/></td>
                        <td><strong>${producto.cantidadVendida}</strong> unidades</td>
                        <td>
                            <span class="stock-badge ${producto.stock > 10 ? 'stock-high' : (producto.stock > 5 ? 'stock-medium' : 'stock-low')}">
                                ${producto.stock}
                            </span>
                        </td>
                        <td>
                            <strong style="color: var(--primary-color);">
                                $<fmt:formatNumber value="${producto.precio * producto.cantidadVendida}" pattern="#,##0.00"/>
                            </strong>
                        </td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>
    </div>

    <!-- Quick Actions -->
    <div class="quick-actions">
        <a href="${pageContext.request.contextPath}/admin/productos" class="action-card">
            <div class="action-icon">
                <i class="fas fa-box"></i>
            </div>
            <div class="action-title">Gestionar Productos</div>
            <div class="action-desc">Agregar, editar o eliminar productos</div>
        </a>

        <a href="${pageContext.request.contextPath}/admin/pedidos" class="action-card">
            <div class="action-icon">
                <i class="fas fa-shopping-cart"></i>
            </div>
            <div class="action-title">Ver Pedidos</div>
            <div class="action-desc">Gestionar y procesar pedidos</div>
        </a>

        <a href="${pageContext.request.contextPath}/admin/usuarios" class="action-card">
            <div class="action-icon">
                <i class="fas fa-users"></i>
            </div>
            <div class="action-title">Usuarios</div>
            <div class="action-desc">Administrar usuarios del sistema</div>
        </a>

        <a href="${pageContext.request.contextPath}/admin/estadisticas" class="action-card">
            <div class="action-icon">
                <i class="fas fa-chart-bar"></i>
            </div>
            <div class="action-title">Estadísticas</div>
            <div class="action-desc">Ver reportes y análisis</div>
        </a>
    </div>
</div>

<!-- Include Footer -->
<%@ include file="/views/components/footer.jsp" %>

<script>
    // Sales Chart
    const salesCtx = document.getElementById('salesChart').getContext('2d');
    const salesChart = new Chart(salesCtx, {
        type: 'line',
        data: {
            labels: ${ventasLabels},
            datasets: [{
                label: 'Ventas',
                data: ${ventasData},
                borderColor: '#00d4ff',
                backgroundColor: 'rgba(0, 212, 255, 0.1)',
                tension: 0.4,
                fill: true
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: true,
            plugins: {
                legend: {
                    display: false
                }
            },
            scales: {
                y: {
                    beginAtZero: true,
                    ticks: {
                        color: '#b0b0b0',
                        callback: function(value) {
                            return '$' + value.toLocaleString();
                        }
                    },
                    grid: {
                        color: 'rgba(255, 255, 255, 0.1)'
                    }
                },
                x: {
                    ticks: {
                        color: '#b0b0b0'
                    },
                    grid: {
                        color: 'rgba(255, 255, 255, 0.1)'
                    }
                }
            }
        }
    });

    // Category Chart
    const categoryCtx = document.getElementById('categoryChart').getContext('2d');
    const categoryChart = new Chart(categoryCtx, {
        type: 'doughnut',
        data: {
            labels: ${categoriasLabels},
            datasets: [{
                data: ${categoriasData},
                backgroundColor: [
                    '#00d4ff',
                    '#0099cc',
                    '#00C851',
                    '#ffbb33',
                    '#ff4444',
                    '#b19cd9'
                ]
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: true,
            plugins: {
                legend: {
                    position: 'bottom',
                    labels: {
                        color: '#b0b0b0',
                        padding: 15
                    }
                }
            }
        }
    });

    // Change period (simulación)
    function changePeriod(period) {
        document.querySelectorAll('.period-btn').forEach(btn => btn.classList.remove('active'));
        event.target.classList.add('active');
        // Aquí iría la lógica para recargar datos
    }
</script>
</body>
</html>
