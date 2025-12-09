<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<%--
  Componente reutilizable: Tarjeta de Producto
  
  Parámetros requeridos:
  - producto: Objeto Producto con todas sus propiedades
  
  Uso:
  <jsp:include page="/views/components/producto-card.jsp">
      <jsp:param name="producto" value="${producto}" />
  </jsp:include>
--%>

<style>
    .product-card {
        background: #1a1a1a;
        border: 1px solid #333;
        border-radius: 15px;
        padding: 20px;
        transition: all 0.3s ease;
        cursor: pointer;
        height: 100%;
        display: flex;
        flex-direction: column;
        position: relative;
        overflow: hidden;
    }

    .product-card::before {
        content: '';
        position: absolute;
        top: 0;
        left: 0;
        right: 0;
        bottom: 0;
        background: linear-gradient(135deg, rgba(0, 212, 255, 0.1) 0%, transparent 100%);
        opacity: 0;
        transition: opacity 0.3s ease;
        pointer-events: none;
    }

    .product-card:hover {
        transform: translateY(-8px);
        border-color: #00d4ff;
        box-shadow: 0 15px 40px rgba(0, 212, 255, 0.3);
    }

    .product-card:hover::before {
        opacity: 1;
    }

    .product-badge {
        position: absolute;
        top: 15px;
        right: 15px;
        background: linear-gradient(135deg, #00d4ff, #0099cc);
        color: #000;
        padding: 5px 12px;
        border-radius: 20px;
        font-size: 0.75rem;
        font-weight: 700;
        text-transform: uppercase;
        z-index: 2;
        box-shadow: 0 4px 10px rgba(0, 212, 255, 0.4);
    }

    .product-badge.out-of-stock {
        background: linear-gradient(135deg, #ff4444, #cc0000);
        color: #fff;
    }

    .product-badge.low-stock {
        background: linear-gradient(135deg, #ffbb33, #ff8800);
        color: #000;
    }

    .product-image-wrapper {
        width: 100%;
        height: 220px;
        background: #2a2a2a;
        border-radius: 12px;
        margin-bottom: 15px;
        display: flex;
        align-items: center;
        justify-content: center;
        overflow: hidden;
        position: relative;
    }

    .product-image {
        max-width: 100%;
        max-height: 100%;
        object-fit: contain;
        transition: transform 0.4s ease;
    }

    .product-card:hover .product-image {
        transform: scale(1.1);
    }

    .product-placeholder {
        font-size: 4rem;
        color: #444;
    }

    .product-info {
        flex: 1;
        display: flex;
        flex-direction: column;
    }

    .product-category {
        font-size: 0.8rem;
        color: #00d4ff;
        text-transform: uppercase;
        font-weight: 600;
        margin-bottom: 8px;
        letter-spacing: 0.5px;
    }

    .product-name {
        font-size: 1.1rem;
        font-weight: 600;
        margin-bottom: 10px;
        color: #fff;
        line-height: 1.4;
        min-height: 2.8em;
        display: -webkit-box;
        -webkit-line-clamp: 2;
        -webkit-box-orient: vertical;
        overflow: hidden;
    }

    .product-description {
        font-size: 0.85rem;
        color: #b0b0b0;
        margin-bottom: 15px;
        line-height: 1.5;
        display: -webkit-box;
        -webkit-line-clamp: 2;
        -webkit-box-orient: vertical;
        overflow: hidden;
        flex: 1;
    }

    .product-meta {
        display: flex;
        gap: 15px;
        margin-bottom: 15px;
        font-size: 0.85rem;
        color: #b0b0b0;
    }

    .meta-item {
        display: flex;
        align-items: center;
        gap: 5px;
    }

    .meta-item svg {
        width: 16px;
        height: 16px;
        fill: #00d4ff;
    }

    .product-rating {
        display: flex;
        align-items: center;
        gap: 8px;
        margin-bottom: 15px;
    }

    .stars {
        display: flex;
        gap: 2px;
    }

    .star {
        color: #ffc107;
        font-size: 0.9rem;
    }

    .star.empty {
        color: #444;
    }

    .rating-count {
        font-size: 0.85rem;
        color: #b0b0b0;
    }

    .product-footer {
        margin-top: auto;
        padding-top: 15px;
        border-top: 1px solid #333;
    }

    .product-price-row {
        display: flex;
        align-items: center;
        justify-content: space-between;
        margin-bottom: 15px;
    }

    .product-price {
        font-size: 1.8rem;
        font-weight: 700;
        color: #00d4ff;
    }

    .product-old-price {
        font-size: 1rem;
        color: #666;
        text-decoration: line-through;
        margin-left: 10px;
    }

    .product-discount {
        background: #ff4444;
        color: #fff;
        padding: 4px 8px;
        border-radius: 6px;
        font-size: 0.75rem;
        font-weight: 700;
    }

    .product-stock {
        font-size: 0.85rem;
        margin-bottom: 12px;
    }

    .stock-available {
        color: #00C851;
    }

    .stock-low {
        color: #ffbb33;
    }

    .stock-out {
        color: #ff4444;
    }

    .product-actions {
        display: grid;
        grid-template-columns: 1fr auto;
        gap: 10px;
    }

    .btn-add-cart {
        background: linear-gradient(135deg, #00d4ff, #0099cc);
        color: #000;
        border: none;
        padding: 12px 20px;
        border-radius: 8px;
        font-weight: 700;
        font-size: 0.9rem;
        cursor: pointer;
        transition: all 0.3s ease;
        display: flex;
        align-items: center;
        justify-content: center;
        gap: 8px;
        text-transform: uppercase;
        letter-spacing: 0.5px;
    }

    .btn-add-cart:hover {
        transform: translateY(-2px);
        box-shadow: 0 8px 20px rgba(0, 212, 255, 0.5);
    }

    .btn-add-cart:disabled {
        opacity: 0.5;
        cursor: not-allowed;
        transform: none;
    }

    .btn-add-cart svg {
        width: 18px;
        height: 18px;
        fill: currentColor;
    }

    .btn-quick-view {
        background: rgba(255, 255, 255, 0.05);
        border: 1px solid #333;
        color: #fff;
        padding: 12px;
        border-radius: 8px;
        cursor: pointer;
        transition: all 0.3s ease;
        display: flex;
        align-items: center;
        justify-content: center;
    }

    .btn-quick-view:hover {
        background: rgba(255, 255, 255, 0.1);
        border-color: #00d4ff;
        transform: scale(1.1);
    }

    .btn-quick-view svg {
        width: 20px;
        height: 20px;
        fill: #00d4ff;
    }

    /* Responsive */
    @media (max-width: 768px) {
        .product-image-wrapper {
            height: 180px;
        }

        .product-name {
            font-size: 1rem;
        }

        .product-price {
            font-size: 1.5rem;
        }
    }
</style>

<div class="product-card" onclick="window.location.href='${pageContext.request.contextPath}/producto/detalle?id=${producto.idProducto}'">
    <!-- Badge -->
    <c:choose>
        <c:when test="${producto.stock == 0}">
            <span class="product-badge out-of-stock">Agotado</span>
        </c:when>
        <c:when test="${producto.stock <= 5}">
            <span class="product-badge low-stock">¡Últimas ${producto.stock}!</span>
        </c:when>
        <c:when test="${not empty producto.descuento && producto.descuento > 0}">
            <span class="product-badge">-${producto.descuento}%</span>
        </c:when>
    </c:choose>

    <!-- Image -->
    <div class="product-image-wrapper">
        <c:choose>
            <c:when test="${not empty producto.imagenPrincipal}">
                <img src="${pageContext.request.contextPath}/uploads/${producto.imagenPrincipal}"
                     alt="${producto.nombre}"
                     class="product-image"
                     onerror="this.style.display='none'; this.nextElementSibling.style.display='block';">
                <svg class="product-placeholder" style="display: none;" viewBox="0 0 24 24">
                    <path fill="#444" d="M21 19V5c0-1.1-.9-2-2-2H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2zM8.5 13.5l2.5 3.01L14.5 12l4.5 6H5l3.5-4.5z"/>
                </svg>
            </c:when>
            <c:otherwise>
                <svg class="product-placeholder" viewBox="0 0 24 24">
                    <path fill="#444" d="M21 19V5c0-1.1-.9-2-2-2H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2zM8.5 13.5l2.5 3.01L14.5 12l4.5 6H5l3.5-4.5z"/>
                </svg>
            </c:otherwise>
        </c:choose>
    </div>

    <!-- Info -->
    <div class="product-info">
        <c:if test="${not empty producto.categoria}">
            <div class="product-category">${producto.categoria.nombre}</div>
        </c:if>

        <h3 class="product-name">${producto.nombre}</h3>

        <c:if test="${not empty producto.descripcion}">
            <p class="product-description">${producto.descripcion}</p>
        </c:if>

        <!-- Meta Info -->
        <div class="product-meta">
            <c:if test="${not empty producto.marca}">
                <div class="meta-item">
                    <svg viewBox="0 0 24 24">
                        <path d="M12 2L2 7l10 5 10-5-10-5zM2 17l10 5 10-5M2 12l10 5 10-5"/>
                    </svg>
                    <span>${producto.marca}</span>
                </div>
            </c:if>
        </div>

        <!-- Rating (si existe) -->
        <c:if test="${not empty producto.promedioCalificacion && producto.promedioCalificacion > 0}">
            <div class="product-rating">
                <div class="stars">
                    <c:forEach begin="1" end="5" var="i">
                        <span class="star ${i <= producto.promedioCalificacion ? '' : 'empty'}">★</span>
                    </c:forEach>
                </div>
                <span class="rating-count">(${producto.totalCalificaciones})</span>
            </div>
        </c:if>
    </div>

    <!-- Footer -->
    <div class="product-footer">
        <div class="product-price-row">
            <div>
                <span class="product-price">
                    $<fmt:formatNumber value="${producto.precio}" pattern="#,##0.00"/>
                </span>
                <c:if test="${not empty producto.precioOriginal && producto.precioOriginal > producto.precio}">
                    <span class="product-old-price">
                        $<fmt:formatNumber value="${producto.precioOriginal}" pattern="#,##0.00"/>
                    </span>
                </c:if>
            </div>
            <c:if test="${not empty producto.descuento && producto.descuento > 0}">
                <span class="product-discount">-${producto.descuento}%</span>
            </c:if>
        </div>

        <!-- Stock Info -->
        <div class="product-stock">
            <c:choose>
                <c:when test="${producto.stock == 0}">
                    <span class="stock-out">
                        <svg style="width: 14px; height: 14px; fill: currentColor; vertical-align: middle;" viewBox="0 0 24 24">
                            <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm1 15h-2v-2h2v2zm0-4h-2V7h2v6z"/>
                        </svg>
                        Sin stock
                    </span>
                </c:when>
                <c:when test="${producto.stock <= 5}">
                    <span class="stock-low">
                        <svg style="width: 14px; height: 14px; fill: currentColor; vertical-align: middle;" viewBox="0 0 24 24">
                            <path d="M1 21h22L12 2 1 21zm12-3h-2v-2h2v2zm0-4h-2v-4h2v4z"/>
                        </svg>
                        Solo quedan ${producto.stock}
                    </span>
                </c:when>
                <c:otherwise>
                    <span class="stock-available">
                        <svg style="width: 14px; height: 14px; fill: currentColor; vertical-align: middle;" viewBox="0 0 24 24">
                            <path d="M9 16.17L4.83 12l-1.42 1.41L9 19 21 7l-1.41-1.41z"/>
                        </svg>
                        En stock
                    </span>
                </c:otherwise>
            </c:choose>
        </div>

        <!-- Actions -->
        <div class="product-actions" onclick="event.stopPropagation()">
            <form action="${pageContext.request.contextPath}/carrito/agregar" method="POST" style="display: contents;">
                <input type="hidden" name="idProducto" value="${producto.idProducto}">
                <input type="hidden" name="cantidad" value="1">
                <button type="submit" 
                        class="btn-add-cart" 
                        ${producto.stock == 0 ? 'disabled' : ''}>
                    <svg viewBox="0 0 24 24">
                        <path d="M11 9h2V6h3V4h-3V1h-2v3H8v2h3v3zm-4 9c-1.1 0-1.99.9-1.99 2S5.9 22 7 22s2-.9 2-2-.9-2-2-2zm10 0c-1.1 0-1.99.9-1.99 2s.89 2 1.99 2 2-.9 2-2-.9-2-2-2zm-9.83-3.25l.03-.12.9-1.63h7.45c.75 0 1.41-.41 1.75-1.03l3.86-7.01L19.42 4h-.01l-1.1 2-2.76 5H8.53l-.13-.27L6.16 6l-.95-2-.94-2H1v2h2l3.6 7.59-1.35 2.45c-.16.28-.25.61-.25.96 0 1.1.9 2 2 2h12v-2H7.42c-.13 0-.25-.11-.25-.25z"/>
                    </svg>
                    <span>${producto.stock == 0 ? 'Agotado' : 'Agregar'}</span>
                </button>
            </form>

            <button type="button" 
                    class="btn-quick-view" 
                    onclick="window.location.href='${pageContext.request.contextPath}/producto/detalle?id=${producto.idProducto}'"
                    title="Ver detalles">
                <svg viewBox="0 0 24 24">
                    <path d="M12 4.5C7 4.5 2.73 7.61 1 12c1.73 4.39 6 7.5 11 7.5s9.27-3.11 11-7.5c-1.73-4.39-6-7.5-11-7.5zM12 17c-2.76 0-5-2.24-5-5s2.24-5 5-5 5 2.24 5 5-2.24 5-5 5zm0-8c-1.66 0-3 1.34-3 3s1.34 3 3 3 3-1.34 3-3-1.34-3-3-3z"/>
                </svg>
            </button>
        </div>
    </div>
</div>
