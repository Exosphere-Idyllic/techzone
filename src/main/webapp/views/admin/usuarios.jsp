<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Gestión de Usuarios - TechZone</title>

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

        .usuarios-container {
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
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }

        .stat-card {
            background: var(--dark-color);
            border: 1px solid var(--border-color);
            border-radius: 12px;
            padding: 20px;
            transition: all 0.3s ease;
        }

        .stat-card:hover {
            transform: translateY(-3px);
            border-color: var(--primary-color);
            box-shadow: 0 8px 20px rgba(0, 212, 255, 0.2);
        }

        .stat-icon {
            width: 45px;
            height: 45px;
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.3rem;
            margin-bottom: 12px;
        }

        .stat-icon.total {
            background: rgba(0, 212, 255, 0.1);
            color: var(--primary-color);
        }

        .stat-icon.admins {
            background: rgba(177, 156, 217, 0.1);
            color: var(--purple-color);
        }

        .stat-icon.clients {
            background: rgba(0, 200, 81, 0.1);
            color: var(--success-color);
        }

        .stat-icon.active {
            background: rgba(0, 200, 81, 0.1);
            color: var(--success-color);
        }

        .stat-icon.inactive {
            background: rgba(255, 68, 68, 0.1);
            color: var(--danger-color);
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

        /* Filters */
        .filters-section {
            background: var(--dark-color);
            border: 1px solid var(--border-color);
            border-radius: 12px;
            padding: 20px;
            margin-bottom: 25px;
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

        /* Table */
        .table-container {
            background: var(--dark-color);
            border: 1px solid var(--border-color);
            border-radius: 12px;
            overflow: hidden;
            margin-bottom: 25px;
        }

        .table-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 20px 25px;
            border-bottom: 1px solid var(--border-color);
        }

        .table-title {
            font-size: 1.2rem;
            font-weight: bold;
        }

        .table-actions {
            display: flex;
            gap: 10px;
        }

        .users-table {
            width: 100%;
            border-collapse: collapse;
        }

        .users-table thead {
            background: rgba(255, 255, 255, 0.02);
        }

        .users-table th {
            padding: 15px 20px;
            text-align: left;
            font-weight: 600;
            color: var(--text-secondary);
            font-size: 0.9rem;
            text-transform: uppercase;
            border-bottom: 2px solid var(--border-color);
        }

        .users-table th.sortable {
            cursor: pointer;
            user-select: none;
        }

        .users-table th.sortable:hover {
            color: var(--primary-color);
        }

        .users-table td {
            padding: 15px 20px;
            border-bottom: 1px solid var(--border-color);
        }

        .users-table tr:hover {
            background: rgba(255, 255, 255, 0.02);
        }

        .user-cell {
            display: flex;
            align-items: center;
            gap: 15px;
        }

        .user-avatar {
            width: 50px;
            height: 50px;
            background: linear-gradient(135deg, var(--primary-color), var(--secondary-color));
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.3rem;
            font-weight: bold;
            color: #000;
            flex-shrink: 0;
        }

        .user-info {
            flex: 1;
        }

        .user-name {
            font-weight: 600;
            color: var(--text-primary);
            margin-bottom: 4px;
        }

        .user-email {
            font-size: 0.85rem;
            color: var(--text-secondary);
        }

        .badge {
            padding: 5px 12px;
            border-radius: 15px;
            font-size: 0.85rem;
            font-weight: 600;
            display: inline-block;
        }

        .badge-admin {
            background: rgba(177, 156, 217, 0.2);
            color: var(--purple-color);
        }

        .badge-cliente {
            background: rgba(0, 212, 255, 0.2);
            color: var(--info-color);
        }

        .badge-activo {
            background: rgba(0, 200, 81, 0.2);
            color: var(--success-color);
        }

        .badge-inactivo {
            background: rgba(255, 68, 68, 0.2);
            color: var(--danger-color);
        }

        .user-stats {
            display: flex;
            flex-direction: column;
            gap: 5px;
        }

        .stat-item {
            display: flex;
            align-items: center;
            gap: 8px;
            font-size: 0.85rem;
            color: var(--text-secondary);
        }

        .stat-value {
            font-weight: 600;
            color: var(--primary-color);
        }

        .action-buttons {
            display: flex;
            gap: 8px;
        }

        .btn-icon {
            width: 35px;
            height: 35px;
            padding: 0;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            border-radius: 8px;
            cursor: pointer;
            transition: all 0.3s ease;
            border: 1px solid var(--border-color);
            background: var(--darker-color);
            color: var(--text-primary);
        }

        .btn-icon:hover {
            transform: translateY(-2px);
        }

        .btn-icon.view:hover {
            background: var(--primary-color);
            color: #000;
            border-color: var(--primary-color);
        }

        .btn-icon.edit:hover {
            background: var(--info-color);
            color: #000;
            border-color: var(--info-color);
        }

        .btn-icon.delete:hover {
            background: var(--danger-color);
            color: #fff;
            border-color: var(--danger-color);
        }

        .btn-icon.toggle:hover {
            background: var(--warning-color);
            color: #000;
            border-color: var(--warning-color);
        }

        /* Pagination */
        .pagination {
            display: flex;
            justify-content: center;
            align-items: center;
            gap: 10px;
            padding: 20px;
        }

        .pagination-btn {
            padding: 10px 15px;
            background: var(--dark-color);
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

        /* Modal */
        .modal {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0, 0, 0, 0.8);
            z-index: 9999;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }

        .modal.active {
            display: flex;
        }

        .modal-content {
            background: var(--dark-color);
            border: 1px solid var(--border-color);
            border-radius: 15px;
            max-width: 600px;
            width: 100%;
            max-height: 90vh;
            overflow-y: auto;
            animation: slideDown 0.3s ease;
        }

        @keyframes slideDown {
            from {
                opacity: 0;
                transform: translateY(-50px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        .modal-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 25px 30px;
            border-bottom: 1px solid var(--border-color);
        }

        .modal-title {
            font-size: 1.5rem;
            font-weight: bold;
        }

        .close-modal {
            width: 35px;
            height: 35px;
            border-radius: 8px;
            background: transparent;
            border: 1px solid var(--border-color);
            color: var(--text-primary);
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: all 0.3s ease;
        }

        .close-modal:hover {
            background: var(--danger-color);
            border-color: var(--danger-color);
        }

        .modal-body {
            padding: 30px;
        }

        .form-row {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-bottom: 20px;
        }

        .form-group.full-width {
            grid-column: 1 / -1;
        }

        textarea.form-control {
            min-height: 100px;
            resize: vertical;
        }

        .modal-footer {
            display: flex;
            justify-content: flex-end;
            gap: 15px;
            padding: 20px 30px;
            border-top: 1px solid var(--border-color);
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

        /* Responsive */
        @media (max-width: 1024px) {
            .filters-grid {
                grid-template-columns: repeat(2, 1fr);
            }
        }

        @media (max-width: 768px) {
            body {
                padding-right: 0;
            }

            .usuarios-container {
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

            .table-container {
                overflow-x: auto;
            }

            .users-table {
                min-width: 900px;
            }
        }

        @media (max-width: 480px) {
            .stats-grid {
                grid-template-columns: 1fr;
            }

            .page-header {
                flex-direction: column;
                align-items: flex-start;
            }
        }
    </style>
</head>
<body>
<!-- Include Header -->
<%@ include file="/views/components/header.jsp" %>

<div class="usuarios-container">
    <!-- Header -->
    <div class="page-header">
        <h1 class="page-title">Gestión de Usuarios</h1>
        <button class="btn btn-primary" onclick="abrirModalNuevo()">
            <i class="fas fa-user-plus"></i>
            Nuevo Usuario
        </button>
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
        <div class="stat-card">
            <div class="stat-icon total">
                <i class="fas fa-users"></i>
            </div>
            <div class="stat-value">${totalUsuarios}</div>
            <div class="stat-label">Total Usuarios</div>
        </div>

        <div class="stat-card">
            <div class="stat-icon admins">
                <i class="fas fa-user-shield"></i>
            </div>
            <div class="stat-value">${totalAdmins}</div>
            <div class="stat-label">Administradores</div>
        </div>

        <div class="stat-card">
            <div class="stat-icon clients">
                <i class="fas fa-user"></i>
            </div>
            <div class="stat-value">${totalClientes}</div>
            <div class="stat-label">Clientes</div>
        </div>

        <div class="stat-card">
            <div class="stat-icon active">
                <i class="fas fa-user-check"></i>
            </div>
            <div class="stat-value">${usuariosActivos}</div>
            <div class="stat-label">Activos</div>
        </div>

        <div class="stat-card">
            <div class="stat-icon inactive">
                <i class="fas fa-user-times"></i>
            </div>
            <div class="stat-value">${usuariosInactivos}</div>
            <div class="stat-label">Inactivos</div>
        </div>
    </div>

    <!-- Filters -->
    <div class="filters-section">
        <form method="get" action="${pageContext.request.contextPath}/admin/usuarios">
            <div class="filters-grid">
                <div class="form-group">
                    <label class="form-label">Buscar</label>
                    <div class="search-box">
                        <i class="fas fa-search search-icon"></i>
                        <input type="text" name="busqueda" class="form-control" 
                               placeholder="Nombre, email o teléfono..." 
                               value="${param.busqueda}">
                    </div>
                </div>

                <div class="form-group">
                    <label class="form-label">Rol</label>
                    <select name="rol" class="form-control">
                        <option value="">Todos</option>
                        <option value="admin" ${param.rol == 'admin' ? 'selected' : ''}>Administrador</option>
                        <option value="cliente" ${param.rol == 'cliente' ? 'selected' : ''}>Cliente</option>
                    </select>
                </div>

                <div class="form-group">
                    <label class="form-label">Estado</label>
                    <select name="estado" class="form-control">
                        <option value="">Todos</option>
                        <option value="activo" ${param.estado == 'activo' ? 'selected' : ''}>Activos</option>
                        <option value="inactivo" ${param.estado == 'inactivo' ? 'selected' : ''}>Inactivos</option>
                    </select>
                </div>

                <div class="form-group">
                    <label class="form-label">Fecha Registro</label>
                    <select name="fechaRegistro" class="form-control">
                        <option value="">Todas</option>
                        <option value="hoy" ${param.fechaRegistro == 'hoy' ? 'selected' : ''}>Hoy</option>
                        <option value="semana" ${param.fechaRegistro == 'semana' ? 'selected' : ''}>Esta semana</option>
                        <option value="mes" ${param.fechaRegistro == 'mes' ? 'selected' : ''}>Este mes</option>
                        <option value="año" ${param.fechaRegistro == 'año' ? 'selected' : ''}>Este año</option>
                    </select>
                </div>
            </div>

            <div class="filters-actions">
                <button type="submit" class="btn btn-primary btn-sm">
                    <i class="fas fa-filter"></i>
                    Aplicar Filtros
                </button>
                <a href="${pageContext.request.contextPath}/admin/usuarios" class="btn btn-secondary btn-sm">
                    <i class="fas fa-times"></i>
                    Limpiar
                </a>
            </div>
        </form>
    </div>

    <!-- Table -->
    <div class="table-container">
        <div class="table-header">
            <div class="table-title">
                Usuarios (${fn:length(usuarios)})
            </div>
            <div class="table-actions">
                <button class="btn btn-secondary btn-sm" onclick="exportarUsuarios()">
                    <i class="fas fa-file-excel"></i>
                    Exportar
                </button>
                <button class="btn btn-secondary btn-sm" onclick="window.print()">
                    <i class="fas fa-print"></i>
                    Imprimir
                </button>
            </div>
        </div>

        <c:choose>
            <c:when test="${not empty usuarios}">
                <table class="users-table">
                    <thead>
                        <tr>
                            <th class="sortable" onclick="ordenar('nombre')">Usuario</th>
                            <th class="sortable" onclick="ordenar('rol')">Rol</th>
                            <th>Teléfono</th>
                            <th>Estadísticas</th>
                            <th class="sortable" onclick="ordenar('fecha')">Fecha Registro</th>
                            <th>Estado</th>
                            <th>Acciones</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach items="${usuarios}" var="usuario">
                            <tr>
                                <td>
                                    <div class="user-cell">
                                        <div class="user-avatar">
                                            ${fn:substring(usuario.nombre, 0, 1)}${fn:substring(usuario.apellido, 0, 1)}
                                        </div>
                                        <div class="user-info">
                                            <div class="user-name">${usuario.nombreCompleto}</div>
                                            <div class="user-email">${usuario.email}</div>
                                        </div>
                                    </div>
                                </td>
                                <td>
                                    <span class="badge badge-${usuario.rol}">
                                        <i class="fas fa-${usuario.rol == 'admin' ? 'user-shield' : 'user'}"></i>
                                        ${usuario.rol}
                                    </span>
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${not empty usuario.telefono}">
                                            ${usuario.telefono}
                                        </c:when>
                                        <c:otherwise>
                                            <span style="color: var(--text-secondary);">No registrado</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <div class="user-stats">
                                        <div class="stat-item">
                                            <i class="fas fa-shopping-cart"></i>
                                            <span class="stat-value">${usuario.totalPedidos}</span> pedidos
                                        </div>
                                        <div class="stat-item">
                                            <i class="fas fa-dollar-sign"></i>
                                            <span class="stat-value">$<fmt:formatNumber value="${usuario.totalGastado}" pattern="#,##0"/></span> gastado
                                        </div>
                                    </div>
                                </td>
                                <td>
                                    <fmt:formatDate value="${usuario.fechaRegistro}" pattern="dd/MM/yyyy"/>
                                </td>
                                <td>
                                    <span class="badge badge-${usuario.activo ? 'activo' : 'inactivo'}">
                                        ${usuario.activo ? 'Activo' : 'Inactivo'}
                                    </span>
                                </td>
                                <td>
                                    <div class="action-buttons">
                                        <button class="btn-icon view" 
                                                onclick="verDetalleUsuario(${usuario.idUsuario})"
                                                title="Ver detalle">
                                            <i class="fas fa-eye"></i>
                                        </button>
                                        <button class="btn-icon edit" 
                                                onclick="abrirModalEditar(${usuario.idUsuario})"
                                                title="Editar">
                                            <i class="fas fa-edit"></i>
                                        </button>
                                        <button class="btn-icon toggle" 
                                                onclick="toggleEstado(${usuario.idUsuario}, ${usuario.activo})"
                                                title="${usuario.activo ? 'Desactivar' : 'Activar'}">
                                            <i class="fas fa-${usuario.activo ? 'ban' : 'check'}"></i>
                                        </button>
                                        <button class="btn-icon delete" 
                                                onclick="confirmarEliminar(${usuario.idUsuario}, '${usuario.nombreCompleto}')"
                                                title="Eliminar">
                                            <i class="fas fa-trash"></i>
                                        </button>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>

                <!-- Pagination -->
                <c:if test="${totalPaginas > 1}">
                    <div class="pagination">
                        <button class="pagination-btn" 
                                onclick="cambiarPagina(${paginaActual - 1})"
                                ${paginaActual <= 1 ? 'disabled' : ''}>
                            <i class="fas fa-chevron-left"></i>
                        </button>

                        <c:forEach begin="1" end="${totalPaginas}" var="i">
                            <button class="pagination-btn ${i == paginaActual ? 'active' : ''}" 
                                    onclick="cambiarPagina(${i})">
                                ${i}
                            </button>
                        </c:forEach>

                        <button class="pagination-btn" 
                                onclick="cambiarPagina(${paginaActual + 1})"
                                ${paginaActual >= totalPaginas ? 'disabled' : ''}>
                            <i class="fas fa-chevron-right"></i>
                        </button>

                        <span class="pagination-info">
                            Mostrando ${(paginaActual - 1) * usuariosPorPagina + 1} - 
                            ${paginaActual * usuariosPorPagina > totalUsuarios ? totalUsuarios : paginaActual * usuariosPorPagina} 
                            de ${totalUsuarios}
                        </span>
                    </div>
                </c:if>
            </c:when>
            <c:otherwise>
                <div class="empty-state">
                    <div class="empty-icon">
                        <i class="fas fa-users"></i>
                    </div>
                    <div class="empty-title">No hay usuarios</div>
                    <div class="empty-text">
                        No se encontraron usuarios con los filtros aplicados
                    </div>
                    <a href="${pageContext.request.contextPath}/admin/usuarios" class="btn btn-primary">
                        Ver todos los usuarios
                    </a>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</div>

<!-- Modal Nuevo/Editar Usuario -->
<div id="modalUsuario" class="modal">
    <div class="modal-content">
        <div class="modal-header">
            <h2 class="modal-title" id="modalTitle">Nuevo Usuario</h2>
            <button class="close-modal" onclick="cerrarModal()">
                <i class="fas fa-times"></i>
            </button>
        </div>

        <form id="formUsuario" method="post" 
              action="${pageContext.request.contextPath}/admin/usuarios">
            <div class="modal-body">
                <input type="hidden" name="accion" id="accion" value="crear">
                <input type="hidden" name="idUsuario" id="idUsuario">

                <div class="form-row">
                    <div class="form-group">
                        <label class="form-label">Nombre *</label>
                        <input type="text" name="nombre" id="nombre" class="form-control">
                    </div>

                    <div class="form-group">
                        <label class="form-label">Apellido *</label>
                        <input type="text" name="apellido" id="apellido" class="form-control">
                    </div>
                </div>

                <div class="form-row">
                    <div class="form-group full-width">
                        <label class="form-label">Email *</label>
                        <input type="email" name="email" id="email" class="form-control">
                    </div>
                </div>

                <div class="form-row">
                    <div class="form-group">
                        <label class="form-label">Teléfono</label>
                        <input type="tel" name="telefono" id="telefono" class="form-control">
                    </div>

                    <div class="form-group">
                        <label class="form-label">Rol *</label>
                        <select name="rol" id="rol" class="form-control">
                            <option value="cliente">Cliente</option>
                            <option value="admin">Administrador</option>
                        </select>
                    </div>
                </div>

                <div class="form-row">
                    <div class="form-group">
                        <label class="form-label">Contraseña *</label>
                        <input type="password" name="password" id="password" class="form-control">
                    </div>

                    <div class="form-group">
                        <label class="form-label">Confirmar Contraseña *</label>
                        <input type="password" name="confirmarPassword" id="confirmarPassword" class="form-control">
                    </div>
                </div>

                <div class="form-row">
                    <div class="form-group full-width">
                        <label class="form-label">Dirección</label>
                        <textarea name="direccion" id="direccion" class="form-control"></textarea>
                    </div>
                </div>

                <div class="form-row">
                    <div class="form-group">
                        <label class="form-label">Estado</label>
                        <select name="activo" id="activo" class="form-control">
                            <option value="true">Activo</option>
                            <option value="false">Inactivo</option>
                        </select>
                    </div>
                </div>
            </div>

            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" onclick="cerrarModal()">
                    Cancelar
                </button>
                <button type="submit" class="btn btn-primary">
                    <i class="fas fa-save"></i>
                    Guardar Usuario
                </button>
            </div>
        </form>
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

    // Modal functions
    function abrirModalNuevo() {
        document.getElementById('modalTitle').textContent = 'Nuevo Usuario';
        document.getElementById('accion').value = 'crear';
        document.getElementById('formUsuario').reset();
        document.getElementById('password').required = true;
        document.getElementById('confirmarPassword').required = true;
        document.getElementById('modalUsuario').classList.add('active');
    }

    function abrirModalEditar(id) {
        // Aquí se cargarían los datos del usuario via AJAX
        document.getElementById('modalTitle').textContent = 'Editar Usuario';
        document.getElementById('accion').value = 'editar';
        document.getElementById('idUsuario').value = id;
        document.getElementById('password').required = false;
        document.getElementById('confirmarPassword').required = false;
        document.getElementById('modalUsuario').classList.add('active');
        // Cargar datos del usuario...
    }

    function cerrarModal() {
        document.getElementById('modalUsuario').classList.remove('active');
    }

    // View user detail
    function verDetalleUsuario(id) {
        window.location.href = '${pageContext.request.contextPath}/admin/usuarios?accion=detalle&id=' + id;
    }

    // Toggle user status
    function toggleEstado(id, activo) {
        const accion = activo ? 'desactivar' : 'activar';
        const mensaje = activo ? 
            '¿Estás seguro de desactivar este usuario?' : 
            '¿Estás seguro de activar este usuario?';
        
        if (confirm(mensaje)) {
            window.location.href = `${pageContext.request.contextPath}/admin/usuarios?accion=${accion}&id=${id}`;
        }
    }

    // Delete confirmation
    function confirmarEliminar(id, nombre) {
        if (confirm(`¿Estás seguro de eliminar al usuario "${nombre}"?\n\nEsta acción no se puede deshacer.`)) {
            window.location.href = `${pageContext.request.contextPath}/admin/usuarios?accion=eliminar&id=${id}`;
        }
    }

    // Pagination
    function cambiarPagina(pagina) {
        const url = new URL(window.location);
        url.searchParams.set('pagina', pagina);
        window.location.href = url.toString();
    }

    // Sort
    function ordenar(campo) {
        const url = new URL(window.location);
        url.searchParams.set('orden', campo);
        window.location.href = url.toString();
    }

    // Export
    function exportarUsuarios() {
        window.location.href = '${pageContext.request.contextPath}/admin/usuarios?accion=exportar&formato=excel';
    }

    // Close modal on outside click
    document.getElementById('modalUsuario').addEventListener('click', function(e) {
        if (e.target === this) {
            cerrarModal();
        }
    });

    // Validate passwords match
    document.getElementById('formUsuario').addEventListener('submit', function(e) {
        const password = document.getElementById('password').value;
        const confirmar = document.getElementById('confirmarPassword').value;
        
        if (password && confirmar && password !== confirmar) {
            e.preventDefault();
            alert('Las contraseñas no coinciden');
        }
    });
</script>
</body>
</html>
