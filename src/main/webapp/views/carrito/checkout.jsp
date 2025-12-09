<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Checkout - TechZone</title>

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

        .checkout-container {
            max-width: 1400px;
            margin: 40px auto;
            padding: 0 20px 60px;
        }

        .page-title {
            font-size: 2.5rem;
            font-weight: bold;
            margin-bottom: 10px;
        }

        .progress-steps {
            display: flex;
            justify-content: space-between;
            margin: 30px 0 40px;
            position: relative;
        }

        .progress-line {
            position: absolute;
            top: 20px;
            left: 0;
            right: 0;
            height: 3px;
            background: var(--border-color);
            z-index: 1;
        }

        .progress-line-fill {
            height: 100%;
            background: var(--primary-color);
            width: 50%;
            transition: width 0.5s ease;
        }

        .step {
            flex: 1;
            text-align: center;
            position: relative;
            z-index: 2;
        }

        .step-circle {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            background: var(--border-color);
            color: var(--text-secondary);
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 10px;
            font-weight: bold;
            transition: all 0.3s ease;
        }

        .step.active .step-circle {
            background: var(--primary-color);
            color: #000;
            box-shadow: 0 0 0 4px rgba(0, 212, 255, 0.2);
        }

        .step.completed .step-circle {
            background: var(--success-color);
            color: #000;
        }

        .step-label {
            font-size: 0.9rem;
            color: var(--text-secondary);
        }

        .step.active .step-label,
        .step.completed .step-label {
            color: var(--text-primary);
            font-weight: 600;
        }

        .checkout-layout {
            display: grid;
            grid-template-columns: 1fr 400px;
            gap: 30px;
        }

        /* Forms Section */
        .checkout-forms {
            display: flex;
            flex-direction: column;
            gap: 25px;
        }

        .form-section {
            background: var(--dark-color);
            border-radius: 15px;
            padding: 30px;
            border: 1px solid var(--border-color);
        }

        .section-title {
            font-size: 1.5rem;
            font-weight: bold;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .section-icon {
            width: 40px;
            height: 40px;
            border-radius: 10px;
            background: linear-gradient(135deg, var(--primary-color), var(--secondary-color));
            display: flex;
            align-items: center;
            justify-content: center;
            color: #000;
        }

        .form-row {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 20px;
            margin-bottom: 20px;
        }

        .form-group {
            margin-bottom: 20px;
        }

        .form-group.full-width {
            grid-column: 1 / -1;
        }

        .form-label {
            display: block;
            margin-bottom: 8px;
            font-weight: 600;
            color: var(--text-primary);
            font-size: 0.95rem;
        }

        .required {
            color: var(--danger-color);
        }

        .form-control {
            width: 100%;
            padding: 12px 15px;
            background: rgba(255, 255, 255, 0.05);
            border: 1px solid var(--border-color);
            border-radius: 8px;
            color: var(--text-primary);
            font-size: 0.95rem;
            transition: all 0.3s ease;
        }

        .form-control:focus {
            outline: none;
            background: rgba(255, 255, 255, 0.08);
            border-color: var(--primary-color);
            box-shadow: 0 0 0 3px rgba(0, 212, 255, 0.1);
        }

        .form-control::placeholder {
            color: rgba(255, 255, 255, 0.3);
        }

        select.form-control {
            cursor: pointer;
        }

        /* Payment Methods */
        .payment-methods {
            display: grid;
            gap: 15px;
        }

        .payment-option {
            display: flex;
            align-items: center;
            gap: 15px;
            padding: 20px;
            background: var(--light-color);
            border: 2px solid var(--border-color);
            border-radius: 10px;
            cursor: pointer;
            transition: all 0.3s ease;
        }

        .payment-option:hover {
            border-color: var(--primary-color);
        }

        .payment-option input[type="radio"] {
            width: 20px;
            height: 20px;
            accent-color: var(--primary-color);
            cursor: pointer;
        }

        .payment-icon {
            font-size: 2rem;
            color: var(--primary-color);
        }

        .payment-info {
            flex: 1;
        }

        .payment-name {
            font-weight: 600;
            color: var(--text-primary);
            margin-bottom: 5px;
        }

        .payment-desc {
            font-size: 0.85rem;
            color: var(--text-secondary);
        }

        /* Order Summary */
        .order-summary {
            background: var(--dark-color);
            border-radius: 15px;
            padding: 30px;
            border: 1px solid var(--border-color);
            position: sticky;
            top: 20px;
            height: fit-content;
        }

        .summary-title {
            font-size: 1.5rem;
            font-weight: bold;
            margin-bottom: 25px;
        }

        .summary-items {
            max-height: 300px;
            overflow-y: auto;
            margin-bottom: 20px;
            padding-right: 10px;
        }

        .summary-items::-webkit-scrollbar {
            width: 6px;
        }

        .summary-items::-webkit-scrollbar-track {
            background: var(--light-color);
            border-radius: 3px;
        }

        .summary-items::-webkit-scrollbar-thumb {
            background: var(--primary-color);
            border-radius: 3px;
        }

        .summary-item {
            display: flex;
            gap: 15px;
            margin-bottom: 15px;
            padding-bottom: 15px;
            border-bottom: 1px solid var(--border-color);
        }

        .summary-item:last-child {
            border-bottom: none;
        }

        .summary-item-image {
            width: 60px;
            height: 60px;
            background: var(--light-color);
            border-radius: 8px;
            overflow: hidden;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .summary-item-image img {
            max-width: 100%;
            max-height: 100%;
            object-fit: contain;
        }

        .summary-item-details {
            flex: 1;
        }

        .summary-item-name {
            font-weight: 600;
            font-size: 0.9rem;
            margin-bottom: 5px;
        }

        .summary-item-qty {
            font-size: 0.85rem;
            color: var(--text-secondary);
        }

        .summary-item-price {
            font-weight: 600;
            color: var(--primary-color);
        }

        .summary-totals {
            padding-top: 20px;
            border-top: 2px solid var(--border-color);
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
            font-size: 2rem;
            color: var(--primary-color);
        }

        .btn-place-order {
            width: 100%;
            padding: 16px;
            background: linear-gradient(135deg, var(--primary-color), var(--secondary-color));
            border: none;
            border-radius: 10px;
            color: #000;
            font-size: 1.1rem;
            font-weight: 700;
            cursor: pointer;
            margin-top: 20px;
            transition: all 0.3s ease;
            box-shadow: 0 10px 30px rgba(0, 212, 255, 0.3);
        }

        .btn-place-order:hover {
            transform: translateY(-3px);
            box-shadow: 0 15px 40px rgba(0, 212, 255, 0.5);
        }

        .btn-back {
            width: 100%;
            padding: 12px;
            background: transparent;
            border: 2px solid var(--border-color);
            border-radius: 10px;
            color: var(--text-secondary);
            font-weight: 600;
            cursor: pointer;
            margin-top: 10px;
            transition: all 0.3s ease;
        }

        .btn-back:hover {
            border-color: var(--text-primary);
            color: var(--text-primary);
            background: rgba(255, 255, 255, 0.05);
        }

        .alert {
            padding: 15px 20px;
            border-radius: 10px;
            margin-bottom: 20px;
            border: 1px solid;
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .alert-danger {
            background: rgba(255, 68, 68, 0.1);
            border-color: var(--danger-color);
            color: #ff6b6b;
        }

        /* Responsive */
        @media (max-width: 1024px) {
            .checkout-layout {
                grid-template-columns: 1fr;
            }

            .order-summary {
                position: static;
            }
        }

        @media (max-width: 768px) {
            body {
                padding-right: 0;
            }

            .checkout-container {
                padding: 20px 15px;
            }

            .form-row {
                grid-template-columns: 1fr;
            }

            .progress-steps {
                flex-direction: column;
                gap: 20px;
            }

            .progress-line {
                display: none;
            }
        }
    </style>
</head>
<body>
<!-- Include Header -->
<%@ include file="/views/components/header.jsp" %>

<div class="checkout-container">
    <!-- Page Title -->
    <h1 class="page-title">
        <i class="fas fa-credit-card"></i> Checkout
    </h1>

    <!-- Progress Steps -->
    <div class="progress-steps">
        <div class="progress-line">
            <div class="progress-line-fill"></div>
        </div>
        <div class="step completed">
            <div class="step-circle">
                <i class="fas fa-check"></i>
            </div>
            <div class="step-label">Carrito</div>
        </div>
        <div class="step active">
            <div class="step-circle">2</div>
            <div class="step-label">Información</div>
        </div>
        <div class="step">
            <div class="step-circle">3</div>
            <div class="step-label">Confirmación</div>
        </div>
    </div>

    <!-- Error Message -->
    <c:if test="${not empty error}">
        <div class="alert alert-danger">
            <i class="fas fa-exclamation-circle"></i>
            <span>${error}</span>
        </div>
    </c:if>

    <!-- Checkout Layout -->
    <form action="${pageContext.request.contextPath}/checkout/procesar" method="POST">
        <div class="checkout-layout">
            <!-- Forms Section -->
            <div class="checkout-forms">
                <!-- Shipping Information -->
                <div class="form-section">
                    <h2 class="section-title">
                        <div class="section-icon">
                            <i class="fas fa-truck"></i>
                        </div>
                        Información de Envío
                    </h2>

                    <div class="form-row">
                        <div class="form-group">
                            <label for="nombre" class="form-label">
                                Nombre <span class="required">*</span>
                            </label>
                            <input type="text"
                                   id="nombre"
                                   name="nombre"
                                   class="form-control"
                                   value="${sessionScope.usuario.nombre}"
                                   required>
                        </div>

                        <div class="form-group">
                            <label for="apellido" class="form-label">
                                Apellido <span class="required">*</span>
                            </label>
                            <input type="text"
                                   id="apellido"
                                   name="apellido"
                                   class="form-control"
                                   value="${sessionScope.usuario.apellido}"
                                   required>
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="direccion" class="form-label">
                            Dirección Completa <span class="required">*</span>
                        </label>
                        <textarea id="direccion"
                                  name="direccion"
                                  class="form-control"
                                  rows="3"
                                  placeholder="Calle, número, piso, departamento..."
                                  required>${sessionScope.usuario.direccion}</textarea>
                    </div>

                    <div class="form-row">
                        <div class="form-group">
                            <label for="ciudad" class="form-label">
                                Ciudad <span class="required">*</span>
                            </label>
                            <input type="text"
                                   id="ciudad"
                                   name="ciudad"
                                   class="form-control"
                                   placeholder="Ej: Quito"
                                   required>
                        </div>

                        <div class="form-group">
                            <label for="codigoPostal" class="form-label">
                                Código Postal
                            </label>
                            <input type="text"
                                   id="codigoPostal"
                                   name="codigoPostal"
                                   class="form-control"
                                   placeholder="170150">
                        </div>
                    </div>

                    <div class="form-row">
                        <div class="form-group">
                            <label for="telefono" class="form-label">
                                Teléfono <span class="required">*</span>
                            </label>
                            <input type="tel"
                                   id="telefono"
                                   name="telefono"
                                   class="form-control"
                                   value="${sessionScope.usuario.telefono}"
                                   placeholder="+593 99 123 4567"
                                   required>
                        </div>

                        <div class="form-group">
                            <label for="email" class="form-label">
                                Email <span class="required">*</span>
                            </label>
                            <input type="email"
                                   id="email"
                                   name="email"
                                   class="form-control"
                                   value="${sessionScope.usuario.email}"
                                   required>
                        </div>
                    </div>
                </div>

                <!-- Payment Method -->
                <div class="form-section">
                    <h2 class="section-title">
                        <div class="section-icon">
                            <i class="fas fa-credit-card"></i>
                        </div>
                        Método de Pago
                    </h2>

                    <div class="payment-methods">
                        <label class="payment-option">
                            <input type="radio" name="metodoPago" value="TARJETA" checked>
                            <i class="fas fa-credit-card payment-icon"></i>
                            <div class="payment-info">
                                <div class="payment-name">Tarjeta de Crédito/Débito</div>
                                <div class="payment-desc">Visa, Mastercard, American Express</div>
                            </div>
                        </label>

                        <label class="payment-option">
                            <input type="radio" name="metodoPago" value="TRANSFERENCIA">
                            <i class="fas fa-university payment-icon"></i>
                            <div class="payment-info">
                                <div class="payment-name">Transferencia Bancaria</div>
                                <div class="payment-desc">Recibe instrucciones por email</div>
                            </div>
                        </label>

                        <label class="payment-option">
                            <input type="radio" name="metodoPago" value="EFECTIVO">
                            <i class="fas fa-money-bill-wave payment-icon"></i>
                            <div class="payment-info">
                                <div class="payment-name">Efectivo contra entrega</div>
                                <div class="payment-desc">Paga al recibir tu pedido</div>
                            </div>
                        </label>
                    </div>
                </div>

                <!-- Additional Notes -->
                <div class="form-section">
                    <h2 class="section-title">
                        <div class="section-icon">
                            <i class="fas fa-comment"></i>
                        </div>
                        Notas Adicionales (Opcional)
                    </h2>

                    <div class="form-group">
                            <textarea name="notas"
                                      class="form-control"
                                      rows="4"
                                      placeholder="Instrucciones especiales para la entrega, referencias del domicilio, etc."></textarea>
                    </div>
                </div>
            </div>

            <!-- Order Summary -->
            <div class="order-summary">
                <h2 class="summary-title">Resumen del Pedido</h2>

                <div class="summary-items">
                    <c:forEach var="item" items="${carrito}">
                        <div class="summary-item">
                            <div class="summary-item-image">
                                <c:choose>
                                    <c:when test="${not empty item.producto.imagenPrincipal}">
                                        <img src="${pageContext.request.contextPath}/uploads/${item.producto.imagenPrincipal}"
                                             alt="${item.producto.nombre}">
                                    </c:when>
                                    <c:otherwise>
                                        <i class="fas fa-image"></i>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                            <div class="summary-item-details">
                                <div class="summary-item-name">${item.producto.nombre}</div>
                                <div class="summary-item-qty">Cantidad: ${item.cantidad}</div>
                            </div>
                            <div class="summary-item-price">
                                $<fmt:formatNumber value="${item.producto.precio * item.cantidad}" pattern="#,##0.00"/>
                            </div>
                        </div>
                    </c:forEach>
                </div>

                <div class="summary-totals">
                    <div class="summary-row">
                        <span class="summary-label">Subtotal</span>
                        <span class="summary-value">
                                $<fmt:formatNumber value="${subtotal}" pattern="#,##0.00"/>
                            </span>
                    </div>

                    <div class="summary-row">
                        <span class="summary-label">Envío</span>
                        <span class="summary-value">Gratis</span>
                    </div>

                    <div class="summary-row summary-total">
                        <span class="summary-label">Total</span>
                        <span class="summary-value">
                                $<fmt:formatNumber value="${total}" pattern="#,##0.00"/>
                            </span>
                    </div>
                </div>

                <button type="submit" class="btn-place-order">
                    <i class="fas fa-check"></i> Confirmar Pedido
                </button>

                <a href="${pageContext.request.contextPath}/carrito">
                    <button type="button" class="btn-back">
                        <i class="fas fa-arrow-left"></i> Volver al Carrito
                    </button>
                </a>
            </div>
        </div>
    </form>
</div>

<!-- Include Footer -->
<%@ include file="/views/components/footer.jsp" %>

<script>
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
