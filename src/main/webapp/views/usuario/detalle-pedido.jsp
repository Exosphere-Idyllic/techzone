<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <title>Detalle del Pedido #${pedido.idPedido} - TechZone</title>

    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

    <style>
        :root {
            --primary-color: #2563eb;
            --secondary-color: #1e40af;
            --dark-color: #1f2937;
            --light-color: #f3f4f6;
            --success-color: #10b981;
            --warning-color: #f59e0b;
            --danger-color: #ef4444;
        }

        body {
            background-color: var(--light-color);
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }

        .page-header {
            background: white;
            padding: 30px 0;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
            margin-bottom: 30px;
        }

        .page-title {
            font-size: 2rem;
            font-weight: bold;
            color: var(--dark-color);
            margin: 0;
        }

        .breadcrumb {
            background: none;
            margin: 0;
            padding: 0;
        }

        .content-container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 0 20px 60px;
        }

        .order-header-card {
            background: white;
            border-radius: 15px;
            padding: 30px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
            margin-bottom: 30px;
        }

        .order-number {
            font-size: 2rem;
            font-weight: bold;
            color: var(--primary-color);
            margin-bottom: 10px;
        }

        .order-meta {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-top: 20px;
        }

        .meta-item {
            display: flex;
            flex-direction: column;
        }

        .meta-label {
            font-size: 0.85rem;
            color: #6b7280;
            margin-bottom: 5px;
        }

        .meta-value {
            font-weight: 600;
            color: var(--dark-color);
            font-size: 1.1rem;
        }

        .order-status {
            display: inline-block;
            padding: 10px 20px;
            border-radius: 25px;
            font-weight: 600;
            font-size: 1rem;
            text-transform: uppercase;
        }

        .status-pendiente {
            background: #fef3c7;
            color: #92400e;
        }

        .status-pagado {
            background: #dbeafe;
            color: #1e40af;
        }

        .status-enviado {
            background: #e0e7ff;
            color: #4338ca;
        }

        .status-entregado {
            background: #d1fae5;
            color: #065f46;
        }

        .status-cancelado {
            background: #fee2e2;
            color: #991b1b;
        }

        .progress-tracker {
            background: white;
            border-radius: 15px;
            padding: 30px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
            margin-bottom: 30px;
        }

        .tracker-title {
            font-size: 1.2rem;
            font-weight: bold;
            color: var(--dark-color);
            margin-bottom: 30px;
        }

        .tracker-steps {
            display: flex;
            justify-content: space-between;
            position: relative;
            padding: 0 20px;
        }

        .tracker-line {
            position: absolute;
            top: 20px;
            left: 20px;
            right: 20px;
            height: 4px;
            background: #e5e7eb;
            z-index: 1;
        }

        .tracker-line-progress {
            height: 100%;
            background: var(--success-color);
            transition: width 0.5s ease;
        }

        .tracker-step {
            display: flex;
            flex-direction: column;
            align-items: center;
            position: relative;
            z-index: 2;
            flex: 1;
        }

        .step-icon {
            width: 50px;
            height: 50px;
            border-radius: 50%;
            background: #e5e7eb;
            display: flex;
            align-items: center;
            justify-content: center;
            color: #9ca3af;
            font-size: 1.3rem;
            margin-bottom: 10px;
            transition: all 0.3s ease;
        }

        .tracker-step.completed .step-icon {
            background: var(--success-color);
            color: white;
        }

        .tracker-step.active .step-icon {
            background: var(--primary-color);
            color: white;
            box-shadow: 0 0 0 4px rgba(37, 99, 235, 0.2);
        }

        .step-label {
            font-size: 0.85rem;
            color: #6b7280;
            text-align: center;
            font-weight: 500;
        }

        .tracker-step.completed .step-label,
        .tracker-step.active .step-label {
            color: var(--dark-color);
            font-weight: 600;
        }

        .info-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }

        .info-card {
            background: white;
            border-radius: 15px;
            padding: 25px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
        }

        .info-card-title {
            font-size: 1.1rem;
            font-weight: bold;
            color: var(--dark-color);
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .info-card-icon {
            width: 40px;
            height: 40px;
            border-radius: 10px;
            background: var(--light-color);
            display: flex;
            align-items: center;
            justify-content: center;
            color: var(--primary-color);
        }

        .info-item {
            margin-bottom: 12px;
            display: flex;
            justify-content: space-between;
        }

        .info-label {
            color: #6b7280;
        }

        .info-value {
            font-weight: 600;
            color: var(--dark-color);
            text-align: right;
        }

        .products-card {
            background: white;
            border-radius: 15px;
            padding: 25px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
            margin-bottom: 30px;
        }

        .products-title {
            font-size: 1.2rem;
            font-weight: bold;
            color: var(--dark-color);
            margin-bottom: 20px;
        }

        .product-item {
            display: flex;
            gap: 20px;
            padding: 20px;
            border: 2px solid var(--light-color);
            border-radius: 10px;
            margin-bottom: 15px;
            transition: all 0.3s ease;
        }

        .product-item:hover {
            border-color: var(--primary-color);
            box-shadow: 0 2px 10px rgba(37, 99, 235, 0.1);
        }

        .product-image {
            width: 100px;
            height: 100px;
            object-fit: cover;
            border-radius: 8px;
            background: var(--light-color);
        }

        .product-info {
            flex: 1;
        }

        .product-name {
            font-weight: 600;
            color: var(--dark-color);
            margin-bottom: 8px;
            font-size: 1.1rem;
        }

        .product-meta {
            color: #6b7280;
            font-size: 0.9rem;
            margin-bottom: 5px;
        }

        .product-pricing {
            text-align: right;
            display: flex;
            flex-direction: column;
            justify-content: center;
        }

        .product-quantity {
            color: #6b7280;
            font-size: 0.9rem;
            margin-bottom: 5px;
        }

        .product-price {
            font-weight: 600;
            color: var(--dark-color);
            font-size: 0.95rem;
        }

        .product-subtotal {
            font-weight: bold;
            color: var(--dark-color);
            font-size: 1.2rem;
        }

        .summary-card {
            background: white;
            border-radius: 15px;
            padding: 25px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
        }

        .summary-item {
            display: flex;
            justify-content: space-between;
            padding: 12px 0;
            border-bottom: 1px solid var(--light-color);
        }

        .summary-item:last-child {
            border-bottom: none;
        }

        .summary-label {
            color: #6b7280;
        }

        .summary-value {
            font-weight: 600;
            color: var(--dark-color);
        }

        .summary-total {
            margin-top: 15px;
            padding-top: 15px;
            border-top: 2px solid var(--light-color);
        }

        .summary-total .summary-label {
            font-size: 1.1rem;
            font-weight: 600;
            color: var(--dark-color);
        }

        .summary-total .summary-value {
            font-size: 1.8rem;
            font-weight: bold;
            color: var(--primary-color);
        }

        .action-buttons {
            display: flex;
            gap: 15px;
            margin-top: 30px;
            flex-wrap: wrap;
        }

        .btn-action {
            flex: 1;
            min-width: 200px;
            padding: 15px 30px;
            border-radius: 10px;
            font-weight: 600;
            border: none;
            transition: all 0.3s ease;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
        }

        .btn-primary-action {
            background: var(--primary-color);
            color: white;
        }

        .btn-primary-action:hover {
            background: var(--secondary-color);
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(37, 99, 235, 0.3);
        }

        .btn-danger-action {
            background: var(--danger-color);
            color: white;
        }

        .btn-danger-action:hover {
            background: #dc2626;
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(239, 68, 68, 0.3);
        }

        .btn-secondary-action {
            background: #6b7280;
            color: white;
        }

        .btn-secondary-action:hover {
            background: #4b5563;
        }

        /* Responsive */
        @media (max-width: 768px) {
            .order-meta {
                grid-template-columns: 1fr;
            }

            .tracker-steps {
                flex-direction: column;
                padding: 0;
            }

            .tracker-line {
                width: 4px;
                height: auto;
                left: 24px;
                top: 20px;
                bottom: 20px;
            }

            .tracker-step {
                flex-direction: row;
                align-items: flex-start;
                gap: 15px;
                margin-bottom: 20px;
            }

            .step-label {
                text-align: left;
            }

            .info-grid {
                grid-template-columns: 1fr;
            }

            .product-item {
                flex-direction: column;
            }

            .product-image {
                width: 100%;
                height: 200px;
            }

            .product-pricing {
                text-align: left;
            }

            .action-buttons {
                flex-direction: column;
            }

            .btn-action {
                width: 100%;
            }
        }
    </style>
</head>
<body>
<!-- Include Header -->
<%@ include file="/views/components/header.jsp" %>

<!-- Page Header -->
<div class="page-header">
    <div class="container">
        <h1 class="page-title">
            <i class="fas fa-file-invoice me-2"></i>Detalle del Pedido
        </h1>
        <nav aria-label="breadcrumb">
            <ol class="breadcrumb">
                <li class="breadcrumb-item">
                    <a href="${pageContext.request.contextPath}/">Inicio</a>
                </li>
                <li class="breadcrumb-item">
                    <a href="${pageContext.request.contextPath}/pedidos">Mis Pedidos</a>
                </li>
                <li class="breadcrumb-item active">Pedido #${pedido.idPedido}</li>
            </ol>
        </nav>
    </div>
</div>

<div class="content-container">
    <!-- Order Header Card -->
    <div class="order-header-card">
        <div class="d-flex justify-content-between align-items-start flex-wrap gap-3">
            <div>
                <div class="order-number">Pedido #${pedido.idPedido}</div>
                <p class="text-muted mb-0">
                    Realizado el <fmt:formatDate value="${pedido.fechaPedido}" pattern="dd 'de' MMMM 'de' yyyy 'a las' HH:mm"/>
                </p>
            </div>
            <div>
                    <span class="order-status status-${pedido.estado.toString().toLowerCase()}">
                        ${pedido.estado}
                    </span>
            </div>
        </div>

        <div class="order-meta">
            <div class="meta-item">
                <span class="meta-label">Fecha de Pedido</span>
                <span class="meta-value">
                        <fmt:formatDate value="${pedido.fechaPedido}" pattern="dd/MM/yyyy"/>
                    </span>
            </div>
            <div class="meta-item">
                <span class="meta-label">Método de Pago</span>
                <span class="meta-value">${pedido.metodoPago}</span>
            </div>
            <div class="meta-item">
                <span class="meta-label">Total de Productos</span>
                <span class="meta-value">${cantidadItems} items</span>
            </div>
            <div class="meta-item">
                <span class="meta-label">Total del Pedido</span>
                <span class="meta-value" style="color: var(--primary-color);">
                        $<fmt:formatNumber value="${pedido.total}" pattern="#,##0.00"/>
                    </span>
            </div>
        </div>
    </div>

    <!-- Progress Tracker -->
    <c:if test="${pedido.estado != 'CANCELADO'}">
        <div class="progress-tracker">
            <h3 class="tracker-title">
                <i class="fas fa-route me-2"></i>Seguimiento del Pedido
            </h3>

            <div class="tracker-steps">
                <div class="tracker-line">
                    <div class="tracker-line-progress" style="width:
                    <c:choose>
                    <c:when test='${pedido.estado == "PENDIENTE"}'>0%</c:when>
                    <c:when test='${pedido.estado == "PAGADO"}'>33%</c:when>
                    <c:when test='${pedido.estado == "ENVIADO"}'>66%</c:when>
                    <c:when test='${pedido.estado == "ENTREGADO"}'>100%</c:when>
                    <c:otherwise>0%</c:otherwise>
                    </c:choose>
                            "></div>
                </div>

                <div class="tracker-step ${pedido.estado == 'PENDIENTE' ? 'active' : ''}
                                             ${pedido.estado == 'PAGADO' or pedido.estado == 'ENVIADO' or pedido.estado == 'ENTREGADO' ? 'completed' : ''}">
                    <div class="step-icon">
                        <i class="fas fa-clock"></i>
                    </div>
                    <span class="step-label">Pendiente</span>
                </div>

                <div class="tracker-step ${pedido.estado == 'PAGADO' ? 'active' : ''}
                                             ${pedido.estado == 'ENVIADO' or pedido.estado == 'ENTREGADO' ? 'completed' : ''}">
                    <div class="step-icon">
                        <i class="fas fa-credit-card"></i>
                    </div>
                    <span class="step-label">Pagado</span>
                </div>

                <div class="tracker-step ${pedido.estado == 'ENVIADO' ? 'active' : ''}
                                             ${pedido.estado == 'ENTREGADO' ? 'completed' : ''}">
                    <div class="step-icon">
                        <i class="fas fa-shipping-fast"></i>
                    </div>
                    <span class="step-label">Enviado</span>
                </div>

                <div class="tracker-step ${pedido.estado == 'ENTREGADO' ? 'active completed' : ''}">
                    <div class="step-icon">
                        <i class="fas fa-check-circle"></i>
                    </div>
                    <span class="step-label">Entregado</span>
                </div>
            </div>
        </div>
    </c:if>

    <!-- Info Grid -->
    <div class="info-grid">
        <!-- Shipping Info -->
        <div class="info-card">
            <h3 class="info-card-title">
                <div class="info-card-icon">
                    <i class="fas fa-truck"></i>
                </div>
                Información de Envío
            </h3>
            <div class="info-item">
                <span class="info-label">Dirección:</span>
            </div>
            <p class="info-value">${pedido.direccionEnvio}</p>
        </div>

        <!-- Payment Info -->
        <div class="info-card">
            <h3 class="info-card-title">
                <div class="info-card-icon">
                    <i class="fas fa-credit-card"></i>
                </div>
                Información de Pago
            </h3>
            <div class="info-item">
                <span class="info-label">Método:</span>
                <span class="info-value">${pedido.metodoPago}</span>
            </div>
            <div class="info-item">
                <span class="info-label">Estado:</span>
                <span class="info-value">${pedido.estado}</span>
            </div>
        </div>
    </div>

    <!-- Products List -->
    <div class="products-card">
        <h3 class="products-title">
            <i class="fas fa-box me-2"></i>Productos (${cantidadItems})
        </h3>

        <c:forEach var="detalle" items="${detalles}">
            <div class="product-item">
                <img src="${pageContext.request.contextPath}/uploads/productos/${detalle.producto.imagenPrincipal}"
                     alt="${detalle.producto.nombre}"
                     class="product-image"
                     onerror="this.src='${pageContext.request.contextPath}/images/placeholder.png'">

                <div class="product-info">
                    <div class="product-name">${detalle.producto.nombre}</div>
                    <div class="product-meta">
                        <c:if test="${not empty detalle.producto.marca}">
                            Marca: ${detalle.producto.marca}
                        </c:if>
                    </div>
                    <div class="product-meta">
                        Precio unitario: $<fmt:formatNumber value="${detalle.precioUnitario}" pattern="#,##0.00"/>
                    </div>
                </div>

                <div class="product-pricing">
                    <div class="product-quantity">Cantidad: ${detalle.cantidad}</div>
                    <div class="product-subtotal">
                        $<fmt:formatNumber value="${detalle.subtotal}" pattern="#,##0.00"/>
                    </div>
                </div>
            </div>
        </c:forEach>
    </div>

    <!-- Summary -->
    <div class="row">
        <div class="col-md-6 offset-md-6">
            <div class="summary-card">
                <div class="summary-item">
                    <span class="summary-label">Subtotal (${cantidadItems} items):</span>
                    <span class="summary-value">
                            $<fmt:formatNumber value="${pedido.total}" pattern="#,##0.00"/>
                        </span>
                </div>

                <div class="summary-item">
                    <span class="summary-label">Envío:</span>
                    <span class="summary-value">Gratis</span>
                </div>

                <div class="summary-item summary-total">
                    <span class="summary-label">Total:</span>
                    <span class="summary-value">
                            $<fmt:formatNumber value="${pedido.total}" pattern="#,##0.00"/>
                        </span>
                </div>
            </div>
        </div>
    </div>

    <!-- Action Buttons -->
    <div class="action-buttons">
        <a href="${pageContext.request.contextPath}/pedidos" class="btn-action btn-secondary-action">
            <i class="fas fa-arrow-left"></i>
            Volver a Mis Pedidos
        </a>

        <c:if test="${pedido.estado == 'PENDIENTE'}">
            <button type="button" class="btn-action btn-danger-action" onclick="confirmarCancelacion()">
                <i class="fas fa-times-circle"></i>
                Cancelar Pedido
            </button>
        </c:if>

        <c:if test="${not esConfirmacion}">
            <button type="button" class="btn-action btn-primary-action" onclick="window.print()">
                <i class="fas fa-print"></i>
                Imprimir Pedido
            </button>
        </c:if>
    </div>
</div>

<!-- Include Footer -->
<%@ include file="/views/components/footer.jsp" %>

<!-- Bootstrap JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

<script>
    // Confirmar cancelación
    function confirmarCancelacion() {
        if (confirm('¿Estás seguro de que deseas cancelar este pedido?')) {
            const motivo = prompt('Por favor, indica el motivo de la cancelación (opcional):');

            const form = document.createElement('form');
            form.method = 'POST';
            form.action = '${pageContext.request.contextPath}/pedido/cancelar';

            const inputId = document.createElement('input');
            inputId.type = 'hidden';
            inputId.name = 'idPedido';
            inputId.value = '${pedido.idPedido}';
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

    // Animación del progress tracker
    document.addEventListener('DOMContentLoaded', function() {
        const progressBar = document.querySelector('.tracker-line-progress');
        if (progressBar) {
            progressBar.style.width = '0%';
            setTimeout(function() {
                progressBar.style.width = progressBar.getAttribute('style').match(/width:\s*([^;]+)/)[1];
            }, 100);
        }
    });
</script>
</body>
</html>
