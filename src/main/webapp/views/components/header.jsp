<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<style>
    /* Estilos del sidebar inline para asegurar que se carguen */
    :root {
        --sidebar-width: 220px;
        --sidebar-bg: #1a1a1a;
        --sidebar-hover: #2a2a2a;
        --sidebar-active: #333333;
        --text-primary: #ffffff;
        --text-secondary: #b0b0b0;
        --accent-color: #00d4ff;
        --border-color: #333333;
    }

    body {
        margin: 0;
        padding: 0;
        padding-right: var(--sidebar-width);
    }

    .sidebar {
        position: fixed;
        right: 0;
        top: 0;
        width: var(--sidebar-width);
        height: 100vh;
        background-color: var(--sidebar-bg);
        border-left: 1px solid var(--border-color);
        display: flex;
        flex-direction: column;
        z-index: 1000;
        overflow-y: auto;
    }

    .sidebar::-webkit-scrollbar {
        width: 6px;
    }

    .sidebar::-webkit-scrollbar-track {
        background: var(--sidebar-bg);
    }

    .sidebar::-webkit-scrollbar-thumb {
        background: var(--sidebar-hover);
        border-radius: 3px;
    }

    .sidebar-header {
        padding: 20px 15px;
        border-bottom: 1px solid var(--border-color);
        text-align: center;
    }

    .sidebar-logo {
        font-size: 24px;
        font-weight: 700;
        color: var(--text-primary);
        text-transform: uppercase;
        letter-spacing: 2px;
    }

    .sidebar-logo span {
        color: var(--accent-color);
    }

    .sidebar-nav {
        flex: 1;
        padding: 10px 0;
    }

    .nav-section {
        margin-bottom: 20px;
    }

    .nav-item {
        display: flex;
        align-items: center;
        padding: 12px 20px;
        color: var(--text-secondary);
        text-decoration: none;
        transition: all 0.3s ease;
        cursor: pointer;
        border-left: 3px solid transparent;
        position: relative;
    }

    .nav-item:hover {
        background-color: var(--sidebar-hover);
        color: var(--text-primary);
        border-left-color: var(--accent-color);
    }

    .nav-item.active {
        background-color: var(--sidebar-active);
        color: var(--text-primary);
        border-left-color: var(--accent-color);
    }

    .nav-item svg {
        width: 24px;
        height: 24px;
        margin-right: 12px;
        fill: currentColor;
        flex-shrink: 0;
    }

    .nav-item-text {
        font-size: 14px;
        font-weight: 500;
    }

    .cart-badge {
        position: absolute;
        right: 20px;
        background-color: var(--accent-color);
        color: #000;
        font-size: 11px;
        font-weight: 700;
        padding: 2px 6px;
        border-radius: 10px;
        min-width: 18px;
        text-align: center;
    }

    .sidebar-footer {
        padding: 15px;
        border-top: 1px solid var(--border-color);
    }

    .user-info {
        display: flex;
        align-items: center;
        padding: 10px;
        background-color: var(--sidebar-hover);
        border-radius: 8px;
        margin-bottom: 10px;
    }

    .user-avatar {
        width: 36px;
        height: 36px;
        border-radius: 50%;
        background: linear-gradient(135deg, var(--accent-color), #0099cc);
        display: flex;
        align-items: center;
        justify-content: center;
        font-weight: 700;
        font-size: 14px;
        color: #000;
        margin-right: 10px;
        flex-shrink: 0;
    }

    .user-details {
        flex: 1;
        min-width: 0;
    }

    .user-name {
        font-size: 13px;
        font-weight: 600;
        color: var(--text-primary);
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
    }

    .user-role {
        font-size: 11px;
        color: var(--text-secondary);
        text-transform: uppercase;
    }

    .btn-action {
        width: 100%;
        padding: 10px;
        background-color: var(--accent-color);
        color: #000;
        border: none;
        border-radius: 6px;
        font-size: 13px;
        font-weight: 600;
        cursor: pointer;
        text-transform: uppercase;
        letter-spacing: 0.5px;
        transition: all 0.3s ease;
        text-align: center;
        text-decoration: none;
        display: block;
    }

    .btn-action:hover {
        background-color: #00b8e6;
        transform: translateY(-1px);
    }

    .btn-secondary {
        background-color: transparent;
        color: var(--text-secondary);
        border: 1px solid var(--border-color);
        margin-top: 8px;
    }

    .btn-secondary:hover {
        background-color: var(--sidebar-hover);
        color: var(--text-primary);
        border-color: var(--text-secondary);
    }

    .mobile-toggle {
        position: fixed;
        top: 20px;
        right: 20px;
        z-index: 1001;
        background-color: var(--sidebar-bg);
        border: 1px solid var(--border-color);
        border-radius: 8px;
        padding: 10px;
        cursor: pointer;
        display: none;
    }

    .mobile-toggle svg {
        width: 24px;
        height: 24px;
        fill: var(--text-primary);
    }

    @media (max-width: 768px) {
        body {
            padding-right: 0;
        }

        .sidebar {
            transform: translateX(100%);
            transition: transform 0.3s ease;
        }

        .sidebar.mobile-open {
            transform: translateX(0);
        }

        .mobile-toggle {
            display: block;
        }

        .sidebar.mobile-open::before {
            content: '';
            position: fixed;
            top: 0;
            left: 0;
            right: var(--sidebar-width);
            bottom: 0;
            background-color: rgba(0, 0, 0, 0.5);
            z-index: -1;
        }
    }
</style>

<!-- Mobile Toggle Button -->
<button class="mobile-toggle" onclick="toggleSidebar()">
    <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
        <path d="M3 18h18v-2H3v2zm0-5h18v-2H3v2zm0-7v2h18V6H3z"/>
    </svg>
</button>

<!-- Sidebar -->
<nav class="sidebar" id="sidebar">
    <!-- Header -->
    <div class="sidebar-header">
        <div class="sidebar-logo">
            TECH<span>ZONE</span>
        </div>
    </div>

    <!-- Navigation -->
    <div class="sidebar-nav">
        <div class="nav-section">
            <a href="${pageContext.request.contextPath}/" class="nav-item">
                <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                    <path d="M10 20v-6h4v6h5v-8h3L12 3 2 12h3v8z"/>
                </svg>
                <span class="nav-item-text">Home</span>
            </a>

            <a href="${pageContext.request.contextPath}/productos" class="nav-item">
                <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                    <path d="M4 6h16v2H4zm0 5h16v2H4zm0 5h16v2H4z"/>
                </svg>
                <span class="nav-item-text">Productos</span>
            </a>

            <a href="${pageContext.request.contextPath}/categorias" class="nav-item">
                <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                    <path d="M12 2l-5.5 9h11L12 2zm0 3.84L13.93 9h-3.87L12 5.84zM17.5 13c-2.49 0-4.5 2.01-4.5 4.5s2.01 4.5 4.5 4.5 4.5-2.01 4.5-4.5-2.01-4.5-4.5-4.5zm0 7c-1.38 0-2.5-1.12-2.5-2.5s1.12-2.5 2.5-2.5 2.5 1.12 2.5 2.5-1.12 2.5-2.5 2.5zM3 21.5h8v-8H3v8zm2-6h4v4H5v-4z"/>
                </svg>
                <span class="nav-item-text">Categorías</span>
            </a>

            <a href="${pageContext.request.contextPath}/productos/ofertas" class="nav-item">
                <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                    <path d="M21.41 11.58l-9-9C12.05 2.22 11.55 2 11 2H4c-1.1 0-2 .9-2 2v7c0 .55.22 1.05.59 1.42l9 9c.36.36.86.58 1.41.58.55 0 1.05-.22 1.41-.59l7-7c.37-.36.59-.86.59-1.41 0-.55-.23-1.06-.59-1.42zM5.5 7C4.67 7 4 6.33 4 5.5S4.67 4 5.5 4 7 4.67 7 5.5 6.33 7 5.5 7z"/>
                </svg>
                <span class="nav-item-text">Ofertas</span>
            </a>

            <a href="${pageContext.request.contextPath}/carrito" class="nav-item">
                <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                    <path d="M7 18c-1.1 0-1.99.9-1.99 2S5.9 22 7 22s2-.9 2-2-.9-2-2-2zM1 2v2h2l3.6 7.59-1.35 2.45c-.16.28-.25.61-.25.96 0 1.1.9 2 2 2h12v-2H7.42c-.14 0-.25-.11-.25-.25l.03-.12.9-1.63h7.45c.75 0 1.41-.41 1.75-1.03l3.58-6.49c.08-.14.12-.31.12-.48 0-.55-.45-1-1-1H5.21l-.94-2H1zm16 16c-1.1 0-1.99.9-1.99 2s.89 2 1.99 2 2-.9 2-2-.9-2-2-2z"/>
                </svg>
                <span class="nav-item-text">Carrito</span>
                <c:if test="${not empty sessionScope.itemsCarrito && sessionScope.itemsCarrito > 0}">
                    <span class="cart-badge">${sessionScope.itemsCarrito}</span>
                </c:if>
            </a>
        </div>

        <c:if test="${not empty sessionScope.usuario}">
            <div class="nav-section">
                <a href="${pageContext.request.contextPath}/pedidos" class="nav-item">
                    <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                        <path d="M19 3H5c-1.11 0-2 .9-2 2v14c0 1.1.89 2 2 2h14c1.11 0 2-.9 2-2V5c0-1.1-.89-2-2-2zm-2 10h-4v4h-2v-4H7v-2h4V7h2v4h4v2z"/>
                    </svg>
                    <span class="nav-item-text">Mis Pedidos</span>
                </a>

                <a href="${pageContext.request.contextPath}/perfil" class="nav-item">
                    <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                        <path d="M12 12c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm0 2c-2.67 0-8 1.34-8 4v2h16v-2c0-2.66-5.33-4-8-4z"/>
                    </svg>
                    <span class="nav-item-text">Perfil</span>
                </a>

                <c:if test="${sessionScope.usuario.rol == 'ADMIN'}">
                    <a href="${pageContext.request.contextPath}/admin/dashboard" class="nav-item">
                        <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                            <path d="M3 13h8V3H3v10zm0 8h8v-6H3v6zm10 0h8V11h-8v10zm0-18v6h8V3h-8z"/>
                        </svg>
                        <span class="nav-item-text">Admin</span>
                    </a>
                </c:if>
            </div>
        </c:if>
    </div>

    <!-- Footer -->
    <div class="sidebar-footer">
        <c:choose>
            <c:when test="${not empty sessionScope.usuario}">
                <div class="user-info">
                    <div class="user-avatar">
                            ${sessionScope.usuario.nombre.substring(0,1).toUpperCase()}${sessionScope.usuario.apellido.substring(0,1).toUpperCase()}
                    </div>
                    <div class="user-details">
                        <div class="user-name">${sessionScope.usuario.nombreCompleto}</div>
                        <div class="user-role">${sessionScope.usuario.rol}</div>
                    </div>
                </div>
                <a href="${pageContext.request.contextPath}/logout" class="btn-action btn-secondary">
                    Cerrar Sesión
                </a>
            </c:when>
            <c:otherwise>
                <a href="${pageContext.request.contextPath}/login" class="btn-action">
                    Iniciar Sesión
                </a>
                <a href="${pageContext.request.contextPath}/registro" class="btn-action btn-secondary">
                    Registrarse
                </a>
            </c:otherwise>
        </c:choose>
    </div>
</nav>

<script>
    function toggleSidebar() {
        const sidebar = document.getElementById('sidebar');
        sidebar.classList.toggle('mobile-open');
    }

    // Cerrar sidebar al hacer click fuera en mobile
    document.addEventListener('click', function(event) {
        if (window.innerWidth <= 768) {
            const sidebar = document.getElementById('sidebar');
            const toggle = document.querySelector('.mobile-toggle');

            if (sidebar && toggle && !sidebar.contains(event.target) && !toggle.contains(event.target)) {
                sidebar.classList.remove('mobile-open');
            }
        }
    });

    // Marcar elemento activo
    document.addEventListener('DOMContentLoaded', function() {
        const currentPath = window.location.pathname;
        const navItems = document.querySelectorAll('.nav-item');

        navItems.forEach(item => {
            const href = item.getAttribute('href');
            if (href && currentPath.includes(href.split('?')[0])) {
                item.classList.add('active');
            }
        });
    });
</script>