<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Estadísticas y Reportes - TechZone</title>

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

        .estadisticas-container {
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

        /* Filters */
        .filters-card {
            background: var(--dark-color);
            border: 1px solid var(--border-color);
            border-radius: 12px;
            padding: 25px;
            margin-bottom: 30px;
        }

        .filters-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }

        .filters-title {
            font-size: 1.2rem;
            font-weight: bold;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .filters-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 15px;
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

        /* Period Selector */
        .period-selector {
            display: flex;
            gap: 10px;
            margin-bottom: 30px;
        }

        .period-btn {
            padding: 12px 25px;
            background: var(--dark-color);
            border: 1px solid var(--border-color);
            border-radius: 10px;
            color: var(--text-secondary);
            cursor: pointer;
            transition: all 0.3s ease;
            font-weight: 600;
        }

        .period-btn:hover,
        .period-btn.active {
            background: var(--primary-color);
            color: #000;
            border-color: var(--primary-color);
        }

        /* Summary Cards */
        .summary-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }

        .summary-card {
            background: var(--dark-color);
            border: 1px solid var(--border-color);
            border-radius: 12px;
            padding: 25px;
            transition: all 0.3s ease;
            position: relative;
            overflow: hidden;
        }

        .summary-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 4px;
            background: linear-gradient(90deg, var(--primary-color), var(--secondary-color));
        }

        .summary-card:hover {
            transform: translateY(-5px);
            border-color: var(--primary-color);
            box-shadow: 0 10px 30px rgba(0, 212, 255, 0.2);
        }

        .summary-header {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            margin-bottom: 15px;
        }

        .summary-icon {
            width: 50px;
            height: 50px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.5rem;
        }

        .summary-icon.revenue {
            background: rgba(0, 212, 255, 0.1);
            color: var(--primary-color);
        }

        .summary-icon.orders {
            background: rgba(0, 200, 81, 0.1);
            color: var(--success-color);
        }

        .summary-icon.products {
            background: rgba(255, 187, 51, 0.1);
            color: var(--warning-color);
        }

        .summary-icon.users {
            background: rgba(177, 156, 217, 0.1);
            color: var(--purple-color);
        }

        .summary-trend {
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

        .summary-value {
            font-size: 2.2rem;
            font-weight: bold;
            color: var(--text-primary);
            margin-bottom: 8px;
        }

        .summary-label {
            color: var(--text-secondary);
            font-size: 0.95rem;
            margin-bottom: 12px;
        }

        .summary-detail {
            display: flex;
            justify-content: space-between;
            padding-top: 12px;
            border-top: 1px solid var(--border-color);
            font-size: 0.85rem;
        }

        .detail-item {
            display: flex;
            flex-direction: column;
            gap: 3px;
        }

        .detail-label {
            color: var(--text-secondary);
        }

        .detail-value {
            font-weight: 600;
            color: var(--text-primary);
        }

        /* Charts Section */
        .charts-section {
            display: grid;
            grid-template-columns: 2fr 1fr;
            gap: 25px;
            margin-bottom: 30px;
        }

        .chart-card {
            background: var(--dark-color);
            border: 1px solid var(--border-color);
            border-radius: 12px;
            padding: 25px;
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
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .chart-actions {
            display: flex;
            gap: 10px;
        }

        .chart-btn {
            padding: 6px 15px;
            background: rgba(255, 255, 255, 0.05);
            border: 1px solid var(--border-color);
            border-radius: 6px;
            color: var(--text-secondary);
            font-size: 0.85rem;
            cursor: pointer;
            transition: all 0.3s ease;
        }

        .chart-btn:hover,
        .chart-btn.active {
            background: var(--primary-color);
            color: #000;
            border-color: var(--primary-color);
        }

        /* Full Width Charts */
        .chart-full {
            grid-column: 1 / -1;
        }

        /* Reports Grid */
        .reports-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 25px;
            margin-bottom: 30px;
        }

        .report-card {
            background: var(--dark-color);
            border: 1px solid var(--border-color);
            border-radius: 12px;
            padding: 25px;
            transition: all 0.3s ease;
        }

        .report-card:hover {
            border-color: var(--primary-color);
            box-shadow: 0 5px 20px rgba(0, 212, 255, 0.1);
        }

        .report-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
            padding-bottom: 15px;
            border-bottom: 1px solid var(--border-color);
        }

        .report-title {
            font-size: 1.1rem;
            font-weight: bold;
        }

        .report-icon {
            width: 40px;
            height: 40px;
            border-radius: 10px;
            background: rgba(0, 212, 255, 0.1);
            color: var(--primary-color);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.2rem;
        }

        .report-list {
            display: flex;
            flex-direction: column;
            gap: 12px;
        }

        .report-item {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 12px;
            background: rgba(255, 255, 255, 0.02);
            border-radius: 8px;
            transition: all 0.3s ease;
        }

        .report-item:hover {
            background: rgba(255, 255, 255, 0.05);
        }

        .item-name {
            color: var(--text-primary);
            font-weight: 500;
        }

        .item-value {
            font-weight: bold;
            color: var(--primary-color);
        }

        .item-bar {
            height: 6px;
            background: rgba(255, 255, 255, 0.1);
            border-radius: 3px;
            margin-top: 8px;
            overflow: hidden;
        }

        .item-bar-fill {
            height: 100%;
            background: linear-gradient(90deg, var(--primary-color), var(--secondary-color));
            border-radius: 3px;
            transition: width 0.3s ease;
        }

        /* Comparison Table */
        .comparison-card {
            background: var(--dark-color);
            border: 1px solid var(--border-color);
            border-radius: 12px;
            padding: 25px;
            margin-bottom: 30px;
        }

        .comparison-table {
            width: 100%;
            border-collapse: collapse;
        }

        .comparison-table thead {
            background: rgba(255, 255, 255, 0.02);
        }

        .comparison-table th {
            padding: 15px;
            text-align: left;
            font-weight: 600;
            color: var(--text-secondary);
            font-size: 0.9rem;
            text-transform: uppercase;
            border-bottom: 2px solid var(--border-color);
        }

        .comparison-table td {
            padding: 15px;
            border-bottom: 1px solid var(--border-color);
        }

        .comparison-table tr:hover {
            background: rgba(255, 255, 255, 0.02);
        }

        .metric-name {
            font-weight: 600;
            color: var(--text-primary);
        }

        .metric-value {
            font-size: 1.1rem;
            font-weight: bold;
        }

        .metric-positive {
            color: var(--success-color);
        }

        .metric-negative {
            color: var(--danger-color);
        }

        .metric-neutral {
            color: var(--info-color);
        }

        /* Export Section */
        .export-section {
            background: var(--dark-color);
            border: 1px solid var(--border-color);
            border-radius: 12px;
            padding: 30px;
            text-align: center;
        }

        .export-title {
            font-size: 1.5rem;
            font-weight: bold;
            margin-bottom: 15px;
        }

        .export-desc {
            color: var(--text-secondary);
            margin-bottom: 25px;
        }

        .export-buttons {
            display: flex;
            justify-content: center;
            gap: 15px;
            flex-wrap: wrap;
        }

        .btn-export {
            padding: 15px 30px;
            border-radius: 10px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            border: 1px solid var(--border-color);
            background: var(--darker-color);
            color: var(--text-primary);
            display: inline-flex;
            align-items: center;
            gap: 10px;
            font-size: 1rem;
        }

        .btn-export:hover {
            transform: translateY(-3px);
            box-shadow: 0 8px 20px rgba(0, 212, 255, 0.2);
        }

        .btn-export.excel:hover {
            background: #107C41;
            border-color: #107C41;
        }

        .btn-export.pdf:hover {
            background: #DC3545;
            border-color: #DC3545;
        }

        .btn-export.csv:hover {
            background: var(--success-color);
            border-color: var(--success-color);
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

            .estadisticas-container {
                padding: 20px 15px;
            }

            .page-title {
                font-size: 2rem;
            }

            .summary-grid {
                grid-template-columns: repeat(2, 1fr);
            }

            .reports-grid {
                grid-template-columns: 1fr;
            }

            .period-selector {
                flex-wrap: wrap;
            }

            .comparison-table {
                font-size: 0.85rem;
            }
        }

        @media (max-width: 480px) {
            .summary-grid {
                grid-template-columns: 1fr;
            }

            .export-buttons {
                flex-direction: column;
            }

            .btn-export {
                width: 100%;
            }
        }
    </style>
</head>
<body>
<!-- Include Header -->
<%@ include file="/views/components/header.jsp" %>

<div class="estadisticas-container">
    <!-- Header -->
    <div class="page-header">
        <h1 class="page-title">Estadísticas y Reportes</h1>
        <div class="header-actions">
            <a href="${pageContext.request.contextPath}/admin/dashboard" class="btn btn-secondary">
                <i class="fas fa-arrow-left"></i>
                Volver al Dashboard
            </a>
        </div>
    </div>

    <!-- Filters -->
    <div class="filters-card">
        <div class="filters-header">
            <div class="filters-title">
                <i class="fas fa-filter"></i>
                Filtros de Período
            </div>
        </div>

        <form method="get" action="${pageContext.request.contextPath}/admin/estadisticas">
            <div class="filters-grid">
                <div class="form-group">
                    <label class="form-label">Fecha Inicio</label>
                    <input type="date" name="fechaInicio" class="form-control" 
                           value="${param.fechaInicio}">
                </div>

                <div class="form-group">
                    <label class="form-label">Fecha Fin</label>
                    <input type="date" name="fechaFin" class="form-control" 
                           value="${param.fechaFin}">
                </div>

                <div class="form-group">
                    <label class="form-label">Comparar con</label>
                    <select name="comparacion" class="form-control">
                        <option value="">Sin comparación</option>
                        <option value="mes_anterior" ${param.comparacion == 'mes_anterior' ? 'selected' : ''}>Mes Anterior</option>
                        <option value="año_anterior" ${param.comparacion == 'año_anterior' ? 'selected' : ''}>Año Anterior</option>
                        <option value="trimestre_anterior" ${param.comparacion == 'trimestre_anterior' ? 'selected' : ''}>Trimestre Anterior</option>
                    </select>
                </div>

                <div class="form-group" style="display: flex; align-items: flex-end;">
                    <button type="submit" class="btn btn-primary" style="width: 100%;">
                        <i class="fas fa-chart-line"></i>
                        Generar Reporte
                    </button>
                </div>
            </div>
        </form>
    </div>

    <!-- Period Selector -->
    <div class="period-selector">
        <button class="period-btn active" onclick="cambiarPeriodo('hoy')">Hoy</button>
        <button class="period-btn" onclick="cambiarPeriodo('semana')">Esta Semana</button>
        <button class="period-btn" onclick="cambiarPeriodo('mes')">Este Mes</button>
        <button class="period-btn" onclick="cambiarPeriodo('trimestre')">Trimestre</button>
        <button class="period-btn" onclick="cambiarPeriodo('año')">Este Año</button>
    </div>

    <!-- Summary Cards -->
    <div class="summary-grid">
        <!-- Revenue -->
        <div class="summary-card">
            <div class="summary-header">
                <div class="summary-icon revenue">
                    <i class="fas fa-dollar-sign"></i>
                </div>
                <div class="summary-trend trend-up">
                    <i class="fas fa-arrow-up"></i>
                    <span>+${crecimientoVentas}%</span>
                </div>
            </div>
            <div class="summary-value">
                $<fmt:formatNumber value="${ventasTotales}" pattern="#,##0.00"/>
            </div>
            <div class="summary-label">Ingresos Totales</div>
            <div class="summary-detail">
                <div class="detail-item">
                    <span class="detail-label">Promedio diario</span>
                    <span class="detail-value">$<fmt:formatNumber value="${promedioDiario}" pattern="#,##0"/></span>
                </div>
                <div class="detail-item">
                    <span class="detail-label">Ticket promedio</span>
                    <span class="detail-value">$<fmt:formatNumber value="${ticketPromedio}" pattern="#,##0"/></span>
                </div>
            </div>
        </div>

        <!-- Orders -->
        <div class="summary-card">
            <div class="summary-header">
                <div class="summary-icon orders">
                    <i class="fas fa-shopping-cart"></i>
                </div>
                <div class="summary-trend trend-up">
                    <i class="fas fa-arrow-up"></i>
                    <span>+${crecimientoPedidos}%</span>
                </div>
            </div>
            <div class="summary-value">${totalPedidos}</div>
            <div class="summary-label">Pedidos Completados</div>
            <div class="summary-detail">
                <div class="detail-item">
                    <span class="detail-label">Tasa conversión</span>
                    <span class="detail-value">${tasaConversion}%</span>
                </div>
                <div class="detail-item">
                    <span class="detail-label">Cancelados</span>
                    <span class="detail-value">${pedidosCancelados}</span>
                </div>
            </div>
        </div>

        <!-- Products -->
        <div class="summary-card">
            <div class="summary-header">
                <div class="summary-icon products">
                    <i class="fas fa-box"></i>
                </div>
                <div class="summary-trend trend-up">
                    <i class="fas fa-arrow-up"></i>
                    <span>+${crecimientoProductos}%</span>
                </div>
            </div>
            <div class="summary-value">${productosVendidos}</div>
            <div class="summary-label">Productos Vendidos</div>
            <div class="summary-detail">
                <div class="detail-item">
                    <span class="detail-label">SKUs activos</span>
                    <span class="detail-value">${skusActivos}</span>
                </div>
                <div class="detail-item">
                    <span class="detail-label">Stock bajo</span>
                    <span class="detail-value">${stockBajo}</span>
                </div>
            </div>
        </div>

        <!-- Users -->
        <div class="summary-card">
            <div class="summary-header">
                <div class="summary-icon users">
                    <i class="fas fa-users"></i>
                </div>
                <div class="summary-trend trend-up">
                    <i class="fas fa-arrow-up"></i>
                    <span>+${crecimientoUsuarios}%</span>
                </div>
            </div>
            <div class="summary-value">${nuevosUsuarios}</div>
            <div class="summary-label">Nuevos Usuarios</div>
            <div class="summary-detail">
                <div class="detail-item">
                    <span class="detail-label">Total usuarios</span>
                    <span class="detail-value">${totalUsuarios}</span>
                </div>
                <div class="detail-item">
                    <span class="detail-label">Activos</span>
                    <span class="detail-value">${usuariosActivos}</span>
                </div>
            </div>
        </div>
    </div>

    <!-- Charts Section -->
    <div class="charts-section">
        <!-- Revenue Chart -->
        <div class="chart-card">
            <div class="chart-header">
                <div class="chart-title">
                    <i class="fas fa-chart-line"></i>
                    Ingresos
                </div>
                <div class="chart-actions">
                    <button class="chart-btn active" onclick="cambiarGrafica('ventas', 'dia')">Día</button>
                    <button class="chart-btn" onclick="cambiarGrafica('ventas', 'semana')">Semana</button>
                    <button class="chart-btn" onclick="cambiarGrafica('ventas', 'mes')">Mes</button>
                </div>
            </div>
            <canvas id="revenueChart" height="100"></canvas>
        </div>

        <!-- Orders Chart -->
        <div class="chart-card">
            <div class="chart-header">
                <div class="chart-title">
                    <i class="fas fa-shopping-cart"></i>
                    Estado de Pedidos
                </div>
            </div>
            <canvas id="ordersChart" height="250"></canvas>
        </div>

        <!-- Products Chart -->
        <div class="chart-card chart-full">
            <div class="chart-header">
                <div class="chart-title">
                    <i class="fas fa-box"></i>
                    Categorías Más Vendidas
                </div>
            </div>
            <canvas id="categoriesChart" height="80"></canvas>
        </div>
    </div>

    <!-- Reports Grid -->
    <div class="reports-grid">
        <!-- Top Products -->
        <div class="report-card">
            <div class="report-header">
                <div class="report-title">Productos Más Vendidos</div>
                <div class="report-icon">
                    <i class="fas fa-trophy"></i>
                </div>
            </div>
            <div class="report-list">
                <c:forEach items="${topProductos}" var="producto" end="4">
                    <div class="report-item">
                        <div style="flex: 1;">
                            <div class="item-name">${producto.nombre}</div>
                            <div class="item-bar">
                                <div class="item-bar-fill" style="width: ${producto.porcentaje}%"></div>
                            </div>
                        </div>
                        <div class="item-value">${producto.cantidad}</div>
                    </div>
                </c:forEach>
            </div>
        </div>

        <!-- Top Categories -->
        <div class="report-card">
            <div class="report-header">
                <div class="report-title">Categorías Principales</div>
                <div class="report-icon">
                    <i class="fas fa-tags"></i>
                </div>
            </div>
            <div class="report-list">
                <c:forEach items="${topCategorias}" var="categoria" end="4">
                    <div class="report-item">
                        <div style="flex: 1;">
                            <div class="item-name">${categoria.nombre}</div>
                            <div class="item-bar">
                                <div class="item-bar-fill" style="width: ${categoria.porcentaje}%"></div>
                            </div>
                        </div>
                        <div class="item-value">$<fmt:formatNumber value="${categoria.ventas}" pattern="#,##0"/></div>
                    </div>
                </c:forEach>
            </div>
        </div>

        <!-- Top Customers -->
        <div class="report-card">
            <div class="report-header">
                <div class="report-title">Mejores Clientes</div>
                <div class="report-icon">
                    <i class="fas fa-star"></i>
                </div>
            </div>
            <div class="report-list">
                <c:forEach items="${topClientes}" var="cliente" end="4">
                    <div class="report-item">
                        <div style="flex: 1;">
                            <div class="item-name">${cliente.nombre}</div>
                            <div class="item-bar">
                                <div class="item-bar-fill" style="width: ${cliente.porcentaje}%"></div>
                            </div>
                        </div>
                        <div class="item-value">$<fmt:formatNumber value="${cliente.total}" pattern="#,##0"/></div>
                    </div>
                </c:forEach>
            </div>
        </div>
    </div>

    <!-- Comparison Table -->
    <div class="comparison-card">
        <div class="chart-header">
            <div class="chart-title">
                <i class="fas fa-chart-bar"></i>
                Comparación de Métricas
            </div>
        </div>

        <table class="comparison-table">
            <thead>
                <tr>
                    <th>Métrica</th>
                    <th>Período Actual</th>
                    <th>Período Anterior</th>
                    <th>Variación</th>
                    <th>% Cambio</th>
                </tr>
            </thead>
            <tbody>
                <tr>
                    <td class="metric-name">Ingresos Totales</td>
                    <td class="metric-value metric-neutral">$<fmt:formatNumber value="${ventasActuales}" pattern="#,##0"/></td>
                    <td>$<fmt:formatNumber value="${ventasAnteriores}" pattern="#,##0"/></td>
                    <td class="metric-value metric-positive">+$<fmt:formatNumber value="${ventasActuales - ventasAnteriores}" pattern="#,##0"/></td>
                    <td class="metric-value metric-positive">+${porcentajeVentas}%</td>
                </tr>
                <tr>
                    <td class="metric-name">Pedidos Completados</td>
                    <td class="metric-value metric-neutral">${pedidosActuales}</td>
                    <td>${pedidosAnteriores}</td>
                    <td class="metric-value metric-positive">+${pedidosActuales - pedidosAnteriores}</td>
                    <td class="metric-value metric-positive">+${porcentajePedidos}%</td>
                </tr>
                <tr>
                    <td class="metric-name">Productos Vendidos</td>
                    <td class="metric-value metric-neutral">${productosActuales}</td>
                    <td>${productosAnteriores}</td>
                    <td class="metric-value metric-positive">+${productosActuales - productosAnteriores}</td>
                    <td class="metric-value metric-positive">+${porcentajeProductos}%</td>
                </tr>
                <tr>
                    <td class="metric-name">Nuevos Usuarios</td>
                    <td class="metric-value metric-neutral">${usuariosActuales}</td>
                    <td>${usuariosAnteriores}</td>
                    <td class="metric-value metric-positive">+${usuariosActuales - usuariosAnteriores}</td>
                    <td class="metric-value metric-positive">+${porcentajeUsuarios}%</td>
                </tr>
                <tr>
                    <td class="metric-name">Ticket Promedio</td>
                    <td class="metric-value metric-neutral">$<fmt:formatNumber value="${ticketActual}" pattern="#,##0"/></td>
                    <td>$<fmt:formatNumber value="${ticketAnterior}" pattern="#,##0"/></td>
                    <td class="metric-value ${ticketActual > ticketAnterior ? 'metric-positive' : 'metric-negative'}">
                        ${ticketActual > ticketAnterior ? '+' : ''}$<fmt:formatNumber value="${ticketActual - ticketAnterior}" pattern="#,##0"/>
                    </td>
                    <td class="metric-value ${ticketActual > ticketAnterior ? 'metric-positive' : 'metric-negative'}">
                        ${ticketActual > ticketAnterior ? '+' : ''}${porcentajeTicket}%
                    </td>
                </tr>
            </tbody>
        </table>
    </div>

    <!-- Export Section -->
    <div class="export-section">
        <div class="export-title">Exportar Reportes</div>
        <div class="export-desc">
            Descarga los reportes completos en el formato que prefieras
        </div>
        <div class="export-buttons">
            <button class="btn-export excel" onclick="exportarReporte('excel')">
                <i class="fas fa-file-excel"></i>
                Exportar a Excel
            </button>
            <button class="btn-export pdf" onclick="exportarReporte('pdf')">
                <i class="fas fa-file-pdf"></i>
                Exportar a PDF
            </button>
            <button class="btn-export csv" onclick="exportarReporte('csv')">
                <i class="fas fa-file-csv"></i>
                Exportar a CSV
            </button>
        </div>
    </div>
</div>

<!-- Include Footer -->
<%@ include file="/views/components/footer.jsp" %>

<script>
    // Revenue Chart
    const revenueCtx = document.getElementById('revenueChart').getContext('2d');
    const revenueChart = new Chart(revenueCtx, {
        type: 'line',
        data: {
            labels: ${ventasLabels},
            datasets: [{
                label: 'Ingresos',
                data: ${ventasData},
                borderColor: '#00d4ff',
                backgroundColor: 'rgba(0, 212, 255, 0.1)',
                tension: 0.4,
                fill: true,
                pointRadius: 4,
                pointHoverRadius: 6
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

    // Orders Chart
    const ordersCtx = document.getElementById('ordersChart').getContext('2d');
    const ordersChart = new Chart(ordersCtx, {
        type: 'doughnut',
        data: {
            labels: ['Entregados', 'Enviados', 'Pagados', 'Pendientes', 'Cancelados'],
            datasets: [{
                data: ${pedidosData},
                backgroundColor: [
                    '#00C851',
                    '#b19cd9',
                    '#00d4ff',
                    '#ffbb33',
                    '#ff4444'
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

    // Categories Chart
    const categoriesCtx = document.getElementById('categoriesChart').getContext('2d');
    const categoriesChart = new Chart(categoriesCtx, {
        type: 'bar',
        data: {
            labels: ${categoriasLabels},
            datasets: [{
                label: 'Ventas',
                data: ${categoriasData},
                backgroundColor: 'rgba(0, 212, 255, 0.7)',
                borderColor: '#00d4ff',
                borderWidth: 1
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

    // Functions
    function cambiarPeriodo(periodo) {
        document.querySelectorAll('.period-btn').forEach(btn => btn.classList.remove('active'));
        event.target.classList.add('active');
        
        const url = new URL(window.location);
        url.searchParams.set('periodo', periodo);
        window.location.href = url.toString();
    }

    function cambiarGrafica(tipo, periodo) {
        const buttons = event.target.parentElement.querySelectorAll('.chart-btn');
        buttons.forEach(btn => btn.classList.remove('active'));
        event.target.classList.add('active');
        
        // Aquí iría la lógica para actualizar la gráfica
    }

    function exportarReporte(formato) {
        const url = new URL(window.location);
        url.searchParams.set('accion', 'exportar');
        url.searchParams.set('formato', formato);
        window.location.href = url.toString();
    }
</script>
</body>
</html>
