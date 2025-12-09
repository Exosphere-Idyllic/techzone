<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Pedido Confirmado - TechZone</title>

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

        .confirmation-container {
            max-width: 1000px;
            margin: 40px auto;
            padding: 0 20px 60px;
        }

        /* Success Animation */
        .success-animation {
            text-align: center;
            padding: 60px 20px;
            background: var(--dark-color);
            border-radius: 15px;
            border: 1px solid var(--border-color);
            margin-bottom: 30px;
            animation: slideDown 0.6s ease-out;
        }

        @keyframes slideDown {
            from {
                opacity: 0;
                transform: translateY(-30px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        .success-icon {
            width: 100px;
            height: 100px;
            border-radius: 50%;
            background: linear-gradient(135deg, var(--success-color), #00a844);
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 25px;
            animation: scaleUp 0.6s ease-out 0.3s both;
            box-shadow: 0 10px 40px rgba(0, 200, 81, 0.3);
        }

        @keyframes scaleUp {
            from {
                transform: scale(0);
            }
            to {
                transform: scale(1);
            }
        }

        .success-icon i {
            font-size: 3.5rem;
            color: #000;
        }

        .success-title {
            font-size: 2.5rem;
            font-weight: bold;
            color: var(--text-primary);
            margin-bottom: 15px;
            animation: fadeIn 0.6s ease-out 0.6s both;
        }

        .success-subtitle {
            font-size: 1.2rem;
            color: var(--text-secondary);
            margin-bottom: 25px;
            animation: fadeIn 0.6s ease-out 0.8s both;
        }

        @keyframes fadeIn {
            from {
                opacity: 0;
            }
            to {
                opacity: 1;
            }
        }

        .order-number {
            display: inline-block;
            padding: 15px 30px;
            background: rgba(0, 212, 255, 0.1);
            border: 2px solid var(--primary-color);
            border-radius: 10px;
            font-size: 1.5rem;
            font-weight: bold;
            color: var(--primary-color);
            animation: fadeIn 0.6s ease-out 1s both;
        }

        /* Order Details */
        .order-details {
            background: var(--dark-color);
            border-radius: 15px;
            padding: 30px;
            border: 1px solid var(--border-color);
            margin-bottom: 30px;
        }

        .detail-section {
            margin-bottom: 30px;
            padding-bottom: 30px;
            border-bottom: 1px solid var(--border-color);
        }

        .detail-section:last-child {
            margin-bottom: 0;
            padding-bottom: 0;
            border-bottom: none;
        }

        .detail-title {
            font-size: 1.3rem;
            font-weight: bold;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .detail-icon {
            width: 35px;
            height: 35px;
            border-radius: 8px;
            background: rgba(0, 212, 255, 0.1);
            display: flex;
            align-items: center;
            justify-content: center;
            color: var(--primary-color);
        }

        .info-grid {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 20px;
        }

        .info-item {
            display: flex;
            flex-direction: column;
        }

        .info-label {
            font-size: 0.85rem;
            color: var(--text-secondary);
            margin-bottom: 5px;
            text-transform: uppercase;
        }

        .info-value {
            font-size: 1rem;
            color: var(--text-primary);
            font-weight: 600;
        }

        /* Order Items */
        .order-items {
            display: flex;
            flex-direction: column;
            gap: 15px;
        }

        .order-item {
            display: flex;
            gap: 15px;
            padding: 15px;
            background: var(--light-color);
            border-radius: 10px;
            border: 1px solid var(--border-color);
        }

        .item-image {
            width: 80px;
            height: 80px;
            background: var(--darker-color);
            border-radius: 8px;
            overflow: hidden;
            display: flex;
            align-items: center;
            justify-content: center;
            flex-shrink: 0;
        }

        .item-image img {
            max-width: 100%;
            max-height: 100%;
            object-fit: contain;
        }

        .item-info {
            flex: 1;
        }

        .item-name {
            font-weight: 600;
            margin-bottom: 5px;
        }

        .item-qty {
            font-size: 0.9rem;
            color: var(--text-secondary);
        }

        .item-price {
            font-weight: bold;
            color: var(--primary-color);
            font-size: 1.2rem;
        }

        /* Order Summary */
        .order-summary {
            background: var(--light-color);
            padding: 20px;
            border-radius: 10px;
            margin-top: 20px;
        }

        .summary-row {
            display: flex;
            justify-content: space-between;
            padding: 10px 0;
        }

        .summary-total {
            margin-top: 15px;
            padding-top: 15px;
            border-top: 2px solid var(--border-color);
        }

        .summary-total .summary-label {
            font-size: 1.2rem;
            font-weight: 600;
        }

        .summary-total .summary-value {
            font-size: 1.8rem;
            color: var(--primary-color);
        }

        /* Action Buttons */
        .action-buttons {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 15px;
            margin-top: 30px;
        }

        .btn-action {
            padding: 15px 20px;
            border-radius: 10px;
            font-weight: 600;
            text-align: center;
            text-decoration: none;
            transition: all 0.3s ease;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
        }

        .btn-primary {
            background: linear-gradient(135deg, var(--primary-color), var(--secondary-color));
            color: #000;
            border: none;
            box-shadow: 0 5px 15px rgba(0, 212, 255, 0.3);
        }

        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 20px rgba(0, 212, 255, 0.4);
        }

        .btn-secondary {
            background: transparent;
            color: var(--text-primary);
            border: 2px solid var(--border-color);
        }

        .btn-secondary:hover {
            border-color: var(--text-primary);
            background: rgba(255, 255, 255, 0.05);
        }

        /* Next Steps */
        .next-steps {
            background: var(--dark-color);
            border-radius: 15px;
            padding: 30px;
            border: 1px solid var(--border-color);
            margin-bottom: 30px;
        }

        .steps-title {
            font-size: 1.5rem;
            font-weight: bold;
            margin-bottom: 25px;
        }

        .step {
            display: flex;
            gap: 20px;
            margin-bottom: 20px;
        }

        .step:last-child {
            margin-bottom: 0;
        }

        .step-number {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            background: linear-gradient(135deg, var(--primary-color), var(--secondary-color));
            color: #000;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: bold;
            flex-shrink: 0;
        }

        .step-content {
            flex: 1;
        }

        .step-title {
            font-weight: 600;
            margin-bottom: 5px;
        }

        .step-desc {
            font-size: 0.9rem;
            color: var(--text-secondary);
        }

        /* Responsive */
        @media (max-width: 768px) {
            body {
                padding-right: 0;
            }

            .confirmation-container {
                padding: 20px 15px;
            }

            .info-grid {
                grid-template-columns: 1fr;
            }

            .action-buttons {
                grid-template-columns: 1fr;
            }

            .order-item {
                flex-direction: column;
                text-align: center;
            }

            .item-image {
                margin: 0 auto;
            }
        }
    </style>
</head>
<body>
<!-- Include Header -->
<%@ include file="/views/components/header.jsp" %>

<div class="confirmation-container">
    <!-- Success Animation -->
    <div class="success-animation">
        <div class="success-icon">
            <i class="fas fa-check"></i>
        </div>
        <h1 class="success-title">¡Pedido Realizado con Éxito!</h1>
        <p class="success-subtitle">
            Hemos recibido tu pedido y lo estamos procesando
        </p>
        <div class="order-number">
            Pedido #${pedido.idPedido}
        </div>
    </div>

    <!-- Order Details -->
    <div class="order-details">
        <!-- Customer Info -->
        <div class="detail-section">
            <h2 class="detail-title">
                <div class="detail-icon">
                    <i class="fas fa-user"></i>
                </div>
                Información del Cliente
            </h2>
            <div class="info-grid">
                <div class="info-item">
                    <span class="info-label">Nombre</span>
                    <span class="info-value">${sessionScope.usuario.nombre} ${sessionScope.usuario.apellido}</span>
                </div>
                <div class="info-item">
                    <span class="info-label">Email</span>
                    <span class="info-value">${sessionScope.usuario.email}</span>
                </div>
                <div class="info-item">
                    <span class="info-label">Teléfono</span>
                    <span class="info-value">${sessionScope.usuario.telefono}</span>
                </div>
                <div class="info-item">
                    <span class="info-label">Fecha del Pedido</span>
                    <span class="info-value">
                            <fmt:formatDate value="${pedido.fechaPedido}" pattern="dd/MM/yyyy HH:mm"/>
                        </span>
                </div>
            </div>
        </div>

        <!-- Shipping Info -->
        <div class="detail-section">
            <h2 class="detail-title">
                <div class="detail-icon">
                    <i class="fas fa-truck"></i>
                </div>
                Información de Envío
            </h2>
            <div class="info-grid">
                <div class="info-item" style="grid-column: 1 / -1;">
                    <span class="info-label">Dirección de Entrega</span>
                    <span class="info-value">${pedido.direccionEnvio}</span>
                </div>
                <div class="info-item">
                    <span class="info-label">Método de Pago</span>
                    <span class="info-value">${pedido.metodoPago}</span>
                </div>
                <div class="info-item">
                    <span class="info-label">Estado del Pedido</span>
                    <span class="info-value" style="color: var(--success-color);">
                        ${pedido.estado}
                    </span>
                </div>
            </div>
        </div>

        <!-- Order Items -->
        <div class="detail-section">
            <h2 class="detail-title">
                <div class="detail-icon">
                    <i class="fas fa-box"></i>
                </div>
                Productos del Pedido
            </h2>
            <div class="order-items">
                <c:forEach var="detalle" items="${detalles}">
                    <div class="order-item">
                        <div class="item-image">
                            <c:choose>
                                <c:when test="${not empty detalle.producto.imagenPrincipal}">
                                    <img src="${pageContext.request.contextPath}/uploads/${detalle.producto.imagenPrincipal}"
                                         alt="${detalle.producto.nombre}">
                                </c:when>
                                <c:otherwise>
                                    <i class="fas fa-image" style="font-size: 2rem; color: #666;"></i>
                                </c:otherwise>
                            </c:choose>
                        </div>
                        <div class="item-info">
                            <div class="item-name">${detalle.producto.nombre}</div>
                            <div class="item-qty">Cantidad: ${detalle.cantidad}</div>
                        </div>
                        <div class="item-price">
                            $<fmt:formatNumber value="${detalle.subtotal}" pattern="#,##0.00"/>
                        </div>
                    </div>
                </c:forEach>
            </div>

            <!-- Order Summary -->
            <div class="order-summary">
                <div class="summary-row">
                    <span class="summary-label">Subtotal</span>
                    <span class="summary-value">
                            $<fmt:formatNumber value="${pedido.total}" pattern="#,##0.00"/>
                        </span>
                </div>
                <div class="summary-row">
                    <span class="summary-label">Envío</span>
                    <span class="summary-value">Gratis</span>
                </div>
                <div class="summary-row summary-total">
                    <span class="summary-label">Total</span>
                    <span class="summary-value">
                            $<fmt:formatNumber value="${pedido.total}" pattern="#,##0.00"/>
                        </span>
                </div>
            </div>
        </div>
    </div>

    <!-- Next Steps -->
    <div class="next-steps">
        <h2 class="steps-title">¿Qué sigue?</h2>

        <div class="step">
            <div class="step-number">1</div>
            <div class="step-content">
                <div class="step-title">Confirmación por Email</div>
                <div class="step-desc">
                    Recibirás un email de confirmación con los detalles de tu pedido
                </div>
            </div>
        </div>

        <div class="step">
            <div class="step-number">2</div>
            <div class="step-content">
                <div class="step-title">Procesamiento</div>
                <div class="step-desc">
                    Prepararemos tu pedido y lo enviaremos en 24-48 horas
                </div>
            </div>
        </div>

        <div class="step">
            <div class="step-number">3</div>
            <div class="step-content">
                <div class="step-title">Seguimiento</div>
                <div class="step-desc">
                    Podrás hacer seguimiento de tu pedido desde "Mis Pedidos"
                </div>
            </div>
        </div>
    </div>

    <!-- Action Buttons -->
    <div class="action-buttons">
        <a href="${pageContext.request.contextPath}/pedido/detalle?id=${pedido.idPedido}" class="btn-action btn-primary">
            <i class="fas fa-receipt"></i>
            Ver Detalle
        </a>
        <a href="${pageContext.request.contextPath}/pedidos" class="btn-action btn-secondary">
            <i class="fas fa-list"></i>
            Mis Pedidos
        </a>
        <a href="${pageContext.request.contextPath}/productos" class="btn-action btn-secondary">
            <i class="fas fa-shopping-bag"></i>
            Seguir Comprando
        </a>
    </div>
</div>

<!-- Include Footer -->
<%@ include file="/views/components/footer.jsp" %>
</body>
</html>
