<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Carrito de Compras - TechZone</title>

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

        .cart-container {
            max-width: 1400px;
            margin: 40px auto;
            padding: 0 20px 60px;
        }

        .page-title {
            font-size: 2.5rem;
            font-weight: bold;
            color: var(--text-primary);
            margin-bottom: 10px;
        }

        .page-subtitle {
            color: var(--text-secondary);
            margin-bottom: 30px;
        }

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

        .cart-layout {
            display: grid;
            grid-template-columns: 1fr 400px;
            gap: 30px;
        }

        /* Cart Items Section */
        .cart-items {
            background: var(--dark-color);
            border-radius: 15px;
            padding: 30px;
            border: 1px solid var(--border-color);
        }

        .cart-item {
            display: grid;
            grid-template-columns: 120px 1fr auto;
            gap: 20px;
            padding: 20px;
            background: var(--light-color);
            border-radius: 10px;
            margin-bottom: 15px;
            transition: all 0.3s ease;
            border: 1px solid var(--border-color);
        }

        .cart-item:hover {
            border-color: var(--primary-color);
            box-shadow: 0 5px 20px rgba(0, 212, 255, 0.1);
        }

        .item-image {
            width: 120px;
            height: 120px;
            background: var(--darker-color);
            border-radius: 10px;
            overflow: hidden;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .item-image img {
            max-width: 100%;
            max-height: 100%;
            object-fit: contain;
        }

        .item-details {
            display: flex;
            flex-direction: column;
            justify-content: space-between;
        }

        .item-name {
            font-size: 1.2rem;
            font-weight: 600;
            color: var(--text-primary);
            margin-bottom: 8px;
        }

        .item-meta {
            color: var(--text-secondary);
            font-size: 0.9rem;
            margin-bottom: 5px;
        }

        .item-stock {
            color: var(--success-color);
            font-size: 0.85rem;
        }

        .item-stock.low {
            color: #ffbb33;
        }

        .item-actions {
            display: flex;
            flex-direction: column;
            align-items: flex-end;
            justify-content: space-between;
        }

        .item-price {
            font-size: 1.8rem;
            font-weight: bold;
            color: var(--primary-color);
            margin-bottom: 10px;
        }

        .quantity-control {
            display: flex;
            align-items: center;
            gap: 10px;
            background: var(--darker-color);
            padding: 8px;
            border-radius: 8px;
            margin-bottom: 10px;
        }

        .qty-btn {
            width: 32px;
            height: 32px;
            border: none;
            background: var(--light-color);
            color: var(--text-primary);
            border-radius: 6px;
            cursor: pointer;
            font-size: 1.2rem;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: all 0.3s ease;
        }

        .qty-btn:hover {
            background: var(--primary-color);
            color: #000;
        }

        .qty-input {
            width: 60px;
            text-align: center;
            background: transparent;
            border: none;
            color: var(--text-primary);
            font-size: 1.1rem;
            font-weight: 600;
        }

        .btn-remove {
            background: transparent;
            border: 2px solid var(--danger-color);
            color: var(--danger-color);
            padding: 8px 16px;
            border-radius: 6px;
            cursor: pointer;
            font-weight: 600;
            transition: all 0.3s ease;
        }

        .btn-remove:hover {
            background: var(--danger-color);
            color: #fff;
        }

        /* Summary Section */
        .cart-summary {
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
            color: var(--text-primary);
        }

        .summary-row {
            display: flex;
            justify-content: space-between;
            padding: 12px 0;
            border-bottom: 1px solid var(--border-color);
        }

        .summary-row:last-child {
            border-bottom: none;
        }

        .summary-label {
            color: var(--text-secondary);
        }

        .summary-value {
            font-weight: 600;
            color: var(--text-primary);
        }

        .summary-total {
            margin-top: 20px;
            padding-top: 20px;
            border-top: 2px solid var(--border-color);
        }

        .summary-total .summary-label {
            font-size: 1.2rem;
            font-weight: 600;
            color: var(--text-primary);
        }

        .summary-total .summary-value {
            font-size: 2rem;
            color: var(--primary-color);
        }

        .btn-checkout {
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

        .btn-checkout:hover {
            transform: translateY(-3px);
            box-shadow: 0 15px 40px rgba(0, 212, 255, 0.5);
        }

        .btn-continue {
            width: 100%;
            padding: 14px;
            background: transparent;
            border: 2px solid var(--border-color);
            border-radius: 10px;
            color: var(--text-secondary);
            font-size: 1rem;
            font-weight: 600;
            cursor: pointer;
            margin-top: 10px;
            transition: all 0.3s ease;
        }

        .btn-continue:hover {
            border-color: var(--text-primary);
            color: var(--text-primary);
            background: rgba(255, 255, 255, 0.05);
        }

        /* Empty Cart */
        .empty-cart {
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
            font-size: 2rem;
            font-weight: bold;
            color: var(--text-primary);
            margin-bottom: 10px;
        }

        .empty-text {
            color: var(--text-secondary);
            margin-bottom: 30px;
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

        .alert-success {
            background: rgba(0, 200, 81, 0.1);
            border-color: var(--success-color);
            color: #51cf66;
        }

        .alert-danger {
            background: rgba(255, 68, 68, 0.1);
            border-color: var(--danger-color);
            color: #ff6b6b;
        }

        /* Responsive */
        @media (max-width: 1024px) {
            .cart-layout {
                grid-template-columns: 1fr;
            }

            .cart-summary {
                position: static;
            }
        }

        @media (max-width: 768px) {
            body {
                padding-right: 0;
            }

            .cart-container {
                padding: 20px 15px;
            }

            .cart-item {
                grid-template-columns: 1fr;
                text-align: center;
            }

            .item-image {
                margin: 0 auto;
            }

            .item-actions {
                align-items: center;
            }
        }
    </style>
</head>
<body>
<!-- Include Header -->
<%@ include file="/views/components/header.jsp" %>

<div class="cart-container">
    <!-- Breadcrumb -->
    <div class="breadcrumb">
        <a href="${pageContext.request.contextPath}/">Inicio</a>
        <span>/</span>
        <span>Carrito</span>
    </div>

    <!-- Page Title -->
    <h1 class="page-title">
        <i class="fas fa-shopping-cart"></i> Carrito de Compras
    </h1>
    <p class="page-subtitle">
        <c:choose>
            <c:when test="${not empty carrito and carrito.items.size() > 0}">
                ${carrito.cantidadTotal} item(s) en tu carrito
            </c:when>
            <c:otherwise>
                Tu carrito está vacío
            </c:otherwise>
        </c:choose>
    </p>

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

    <c:choose>
        <c:when test="${not empty carrito and carrito.items.size() > 0}">
            <!-- Cart Layout -->
            <div class="cart-layout">
                <!-- Cart Items -->
                <div class="cart-items">
                    <c:forEach var="item" items="${carrito.items}">
                        <div class="cart-item">
                            <div class="item-image">
                                <c:choose>
                                    <c:when test="${not empty item.producto.imagenPrincipal}">
                                        <img src="${pageContext.request.contextPath}/uploads/${item.producto.imagenPrincipal}"
                                             alt="${item.producto.nombre}">
                                    </c:when>
                                    <c:otherwise>
                                        <i class="fas fa-image" style="font-size: 3rem; color: #666;"></i>
                                    </c:otherwise>
                                </c:choose>
                            </div>

                            <div class="item-details">
                                <div>
                                    <h3 class="item-name">${item.producto.nombre}</h3>
                                    <c:if test="${not empty item.producto.marca}">
                                        <p class="item-meta">
                                            <i class="fas fa-tag"></i> ${item.producto.marca}
                                        </p>
                                    </c:if>
                                    <p class="item-stock ${item.producto.stock < 5 ? 'low' : ''}">
                                        <i class="fas fa-box"></i>
                                        <c:choose>
                                            <c:when test="${item.producto.stock > 10}">
                                                En stock (${item.producto.stock} disponibles)
                                            </c:when>
                                            <c:when test="${item.producto.stock > 0}">
                                                ¡Últimas ${item.producto.stock} unidades!
                                            </c:when>
                                            <c:otherwise>
                                                Sin stock
                                            </c:otherwise>
                                        </c:choose>
                                    </p>
                                </div>
                            </div>

                            <div class="item-actions">
                                <div class="item-price">
                                    $<fmt:formatNumber value="${item.subtotal}" pattern="#,##0.00"/>
                                </div>

                                <form action="${pageContext.request.contextPath}/carrito/actualizar"
                                      method="POST"
                                      class="quantity-control">
                                    <input type="hidden" name="idProducto" value="${item.producto.idProducto}">
                                    <button type="submit" name="accion" value="decrementar" class="qty-btn">
                                        <i class="fas fa-minus"></i>
                                    </button>
                                    <input type="number"
                                           name="cantidad"
                                           value="${item.cantidad}"
                                           min="1"
                                           max="${item.producto.stock}"
                                           class="qty-input"
                                           readonly>
                                    <button type="submit" name="accion" value="incrementar" class="qty-btn"
                                        ${item.cantidad >= item.producto.stock ? 'disabled' : ''}>
                                        <i class="fas fa-plus"></i>
                                    </button>
                                </form>

                                <form action="${pageContext.request.contextPath}/carrito/eliminar"
                                      method="POST"
                                      onsubmit="return confirm('¿Eliminar este producto del carrito?')">
                                    <input type="hidden" name="idProducto" value="${item.producto.idProducto}">
                                    <button type="submit" class="btn-remove">
                                        <i class="fas fa-trash"></i> Eliminar
                                    </button>
                                </form>
                            </div>
                        </div>
                    </c:forEach>
                </div>

                <!-- Cart Summary -->
                <div class="cart-summary">
                    <h2 class="summary-title">Resumen del Pedido</h2>

                    <div class="summary-row">
                        <span class="summary-label">Subtotal</span>
                        <span class="summary-value">
                                $<fmt:formatNumber value="${carrito.subtotal}" pattern="#,##0.00"/>
                            </span>
                    </div>

                    <div class="summary-row">
                        <span class="summary-label">Descuento</span>
                        <span class="summary-value">
                                -$<fmt:formatNumber value="${carrito.totalDescuentos}" pattern="#,##0.00"/>
                            </span>
                    </div>

                    <c:set var="subtotalConDescuento" value="${carrito.subtotal - carrito.totalDescuentos}" />
                    <c:set var="iva" value="${subtotalConDescuento * 0.15}" />
                    <c:set var="totalConIva" value="${subtotalConDescuento + iva}" />

                    <div class="summary-row">
                        <span class="summary-label">IVA (15%)</span>
                        <span class="summary-value">
                                $<fmt:formatNumber value="${iva}" pattern="#,##0.00"/>
                            </span>
                    </div>

                    <div class="summary-row">
                        <span class="summary-label">Envío</span>
                        <span class="summary-value">Gratis</span>
                    </div>

                    <div class="summary-row summary-total">
                        <span class="summary-label">Total</span>
                        <span class="summary-value">
                                $<fmt:formatNumber value="${totalConIva}" pattern="#,##0.00"/>
                            </span>
                    </div>

                    <form action="${pageContext.request.contextPath}/checkout" method="GET">
                        <button type="submit" class="btn-checkout">
                            <i class="fas fa-credit-card"></i> Proceder al Pago
                        </button>
                    </form>

                    <a href="${pageContext.request.contextPath}/productos">
                        <button class="btn-continue">
                            <i class="fas fa-arrow-left"></i> Seguir Comprando
                        </button>
                    </a>
                </div>
            </div>
        </c:when>
        <c:otherwise>
            <!-- Empty Cart -->
            <div class="empty-cart">
                <div class="empty-icon">
                    <i class="fas fa-shopping-cart"></i>
                </div>
                <h2 class="empty-title">Tu carrito está vacío</h2>
                <p class="empty-text">Comienza a agregar productos para verlos aquí</p>
                <a href="${pageContext.request.contextPath}/productos">
                    <button class="btn-checkout">
                        <i class="fas fa-store"></i> Explorar Productos
                    </button>
                </a>
            </div>
        </c:otherwise>
    </c:choose>
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
