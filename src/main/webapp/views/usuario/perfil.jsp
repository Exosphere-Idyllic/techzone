<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <title>Mi Perfil - TechZone</title>

    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
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

        body {
            background-color: var(--darker-color);
            color: var(--text-primary);
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            padding-right: 220px;
        }

        .profile-container {
            max-width: 1200px;
            margin: 40px auto;
            padding: 0 20px 60px;
        }

        .profile-header {
            background: var(--dark-color);
            border-radius: 15px;
            padding: 30px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.5);
            margin-bottom: 30px;
            border: 1px solid var(--border-color);
            display: flex;
            align-items: center;
            gap: 30px;
        }

        .profile-avatar {
            width: 120px;
            height: 120px;
            border-radius: 50%;
            background: linear-gradient(135deg, var(--primary-color), var(--secondary-color));
            display: flex;
            align-items: center;
            justify-content: center;
            color: #000;
            font-size: 3rem;
            font-weight: bold;
            flex-shrink: 0;
            box-shadow: 0 10px 30px rgba(0, 212, 255, 0.3);
        }

        .profile-info {
            flex: 1;
        }

        .profile-name {
            font-size: 2rem;
            font-weight: bold;
            color: var(--text-primary);
            margin-bottom: 5px;
        }

        .profile-email {
            color: var(--text-secondary);
            font-size: 1.1rem;
            margin-bottom: 10px;
        }

        .profile-badge {
            display: inline-block;
            padding: 5px 15px;
            border-radius: 20px;
            font-size: 0.85rem;
            font-weight: 600;
            text-transform: uppercase;
        }

        .badge-admin {
            background: linear-gradient(135deg, var(--primary-color), var(--secondary-color));
            color: #000;
        }

        .badge-cliente {
            background: rgba(0, 212, 255, 0.2);
            color: var(--primary-color);
            border: 1px solid var(--primary-color);
        }

        .badge-vendedor {
            background: rgba(255, 187, 51, 0.2);
            color: #ffbb33;
            border: 1px solid #ffbb33;
        }

        .profile-stats {
            display: flex;
            gap: 30px;
            margin-top: 20px;
        }

        .stat-item {
            text-align: center;
        }

        .stat-value {
            font-size: 1.5rem;
            font-weight: bold;
            color: var(--primary-color);
        }

        .stat-label {
            font-size: 0.85rem;
            color: var(--text-secondary);
            text-transform: uppercase;
        }

        .profile-tabs {
            background: var(--dark-color);
            border-radius: 15px;
            padding: 30px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.5);
            border: 1px solid var(--border-color);
        }

        .nav-tabs {
            border-bottom: 2px solid var(--border-color);
            margin-bottom: 30px;
        }

        .nav-tabs .nav-link {
            color: var(--text-secondary);
            border: none;
            padding: 15px 25px;
            font-weight: 600;
            transition: all 0.3s ease;
            border-bottom: 3px solid transparent;
        }

        .nav-tabs .nav-link:hover {
            color: var(--text-primary);
            border-bottom-color: rgba(0, 212, 255, 0.3);
        }

        .nav-tabs .nav-link.active {
            color: var(--primary-color);
            background: transparent;
            border-bottom-color: var(--primary-color);
        }

        .form-group {
            margin-bottom: 20px;
        }

        .form-label {
            display: block;
            margin-bottom: 8px;
            font-weight: 600;
            color: var(--text-primary);
            font-size: 0.95rem;
        }

        .form-control {
            background: rgba(255, 255, 255, 0.05);
            border: 1px solid var(--border-color);
            color: var(--text-primary);
            padding: 12px 15px;
            border-radius: 8px;
            transition: all 0.3s ease;
        }

        .form-control:focus {
            background: rgba(255, 255, 255, 0.08);
            border-color: var(--primary-color);
            box-shadow: 0 0 0 3px rgba(0, 212, 255, 0.1);
            color: var(--text-primary);
        }

        .form-control::placeholder {
            color: rgba(255, 255, 255, 0.3);
        }

        .form-row {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 20px;
        }

        .btn-primary {
            background: linear-gradient(135deg, var(--primary-color), var(--secondary-color));
            border: none;
            padding: 12px 30px;
            border-radius: 8px;
            font-weight: 600;
            color: #000;
            transition: all 0.3s ease;
            box-shadow: 0 5px 15px rgba(0, 212, 255, 0.3);
        }

        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 20px rgba(0, 212, 255, 0.4);
            color: #000;
        }

        .btn-secondary {
            background: transparent;
            border: 2px solid var(--border-color);
            color: var(--text-secondary);
            padding: 12px 30px;
            border-radius: 8px;
            font-weight: 600;
            transition: all 0.3s ease;
        }

        .btn-secondary:hover {
            border-color: var(--text-primary);
            color: var(--text-primary);
            background: rgba(255, 255, 255, 0.05);
        }

        .alert {
            border-radius: 10px;
            padding: 15px 20px;
            margin-bottom: 20px;
            border: 1px solid;
            animation: slideDown 0.3s ease-out;
        }

        @keyframes slideDown {
            from {
                opacity: 0;
                transform: translateY(-10px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
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

        .quick-links {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 15px;
            margin-top: 30px;
        }

        .quick-link-card {
            background: var(--light-color);
            padding: 20px;
            border-radius: 10px;
            text-align: center;
            text-decoration: none;
            transition: all 0.3s ease;
            border: 1px solid var(--border-color);
        }

        .quick-link-card:hover {
            transform: translateY(-5px);
            border-color: var(--primary-color);
            box-shadow: 0 10px 30px rgba(0, 212, 255, 0.2);
        }

        .quick-link-icon {
            font-size: 2.5rem;
            color: var(--primary-color);
            margin-bottom: 10px;
        }

        .quick-link-text {
            color: var(--text-primary);
            font-weight: 600;
            display: block;
        }

        .password-toggle {
            position: absolute;
            right: 15px;
            top: 50%;
            transform: translateY(-50%);
            background: none;
            border: none;
            color: var(--text-secondary);
            cursor: pointer;
            padding: 5px;
        }

        .password-toggle:hover {
            color: var(--primary-color);
        }

        .input-wrapper {
            position: relative;
        }

        .breadcrumb {
            background: transparent;
            padding: 0;
            margin-bottom: 30px;
        }

        .breadcrumb-item {
            color: var(--text-secondary);
        }

        .breadcrumb-item a {
            color: var(--primary-color);
            text-decoration: none;
        }

        .breadcrumb-item.active {
            color: var(--text-primary);
        }

        /* Responsive */
        @media (max-width: 768px) {
            body {
                padding-right: 0;
            }

            .profile-header {
                flex-direction: column;
                text-align: center;
            }

            .profile-stats {
                justify-content: center;
            }

            .form-row {
                grid-template-columns: 1fr;
            }

            .profile-container {
                padding: 20px 15px;
            }
        }
    </style>
</head>
<body>
<!-- Include Header -->
<%@ include file="/views/components/header.jsp" %>

<div class="profile-container">
    <!-- Breadcrumb -->
    <nav aria-label="breadcrumb">
        <ol class="breadcrumb">
            <li class="breadcrumb-item">
                <a href="${pageContext.request.contextPath}/">Inicio</a>
            </li>
            <li class="breadcrumb-item active">Mi Perfil</li>
        </ol>
    </nav>

    <!-- Profile Header -->
    <div class="profile-header">
        <div class="profile-avatar">
            ${sessionScope.usuario.nombre.substring(0,1)}${sessionScope.usuario.apellido.substring(0,1)}
        </div>
        <div class="profile-info">
            <h1 class="profile-name">
                ${sessionScope.usuario.nombre} ${sessionScope.usuario.apellido}
            </h1>
            <p class="profile-email">${sessionScope.usuario.email}</p>
            <span class="profile-badge badge-${sessionScope.usuario.rol.toString().toLowerCase()}">
                ${sessionScope.usuario.rol}
            </span>
            <div class="profile-stats">
                <div class="stat-item">
                    <div class="stat-value">
                        <fmt:formatDate value="${sessionScope.usuario.fechaRegistro}" pattern="dd/MM/yyyy"/>
                    </div>
                    <div class="stat-label">Miembro desde</div>
                </div>
                <div class="stat-item">
                    <div class="stat-value">${sessionScope.usuario.estado}</div>
                    <div class="stat-label">Estado</div>
                </div>
            </div>
        </div>
    </div>

    <!-- Messages -->
    <c:if test="${not empty mensaje}">
        <div class="alert alert-success">
            <i class="fas fa-check-circle me-2"></i>${mensaje}
        </div>
    </c:if>

    <c:if test="${not empty error}">
        <div class="alert alert-danger">
            <i class="fas fa-exclamation-circle me-2"></i>${error}
        </div>
    </c:if>

    <!-- Profile Tabs -->
    <div class="profile-tabs">
        <ul class="nav nav-tabs" role="tablist">
            <li class="nav-item" role="presentation">
                <button class="nav-link ${empty tabActiva or tabActiva == 'info' ? 'active' : ''}"
                        data-bs-toggle="tab"
                        data-bs-target="#info"
                        type="button"
                        role="tab">
                    <i class="fas fa-user me-2"></i>Información Personal
                </button>
            </li>
            <li class="nav-item" role="presentation">
                <button class="nav-link ${tabActiva == 'password' ? 'active' : ''}"
                        data-bs-toggle="tab"
                        data-bs-target="#password"
                        type="button"
                        role="tab">
                    <i class="fas fa-lock me-2"></i>Cambiar Contraseña
                </button>
            </li>
        </ul>

        <div class="tab-content">
            <!-- Personal Info Tab -->
            <div class="tab-pane fade ${empty tabActiva or tabActiva == 'info' ? 'show active' : ''}"
                 id="info"
                 role="tabpanel">
                <form action="${pageContext.request.contextPath}/perfil/actualizar" method="POST">
                    <div class="form-row">
                        <div class="form-group">
                            <label for="nombre" class="form-label">Nombre</label>
                            <input type="text"
                                   class="form-control"
                                   id="nombre"
                                   name="nombre"
                                   value="${sessionScope.usuario.nombre}"
                                   required>
                        </div>

                        <div class="form-group">
                            <label for="apellido" class="form-label">Apellido</label>
                            <input type="text"
                                   class="form-control"
                                   id="apellido"
                                   name="apellido"
                                   value="${sessionScope.usuario.apellido}"
                                   required>
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="email" class="form-label">Email</label>
                        <input type="email"
                               class="form-control"
                               id="email"
                               name="email"
                               value="${sessionScope.usuario.email}"
                               required>
                    </div>

                    <div class="form-group">
                        <label for="telefono" class="form-label">Teléfono</label>
                        <input type="tel"
                               class="form-control"
                               id="telefono"
                               name="telefono"
                               value="${sessionScope.usuario.telefono}"
                               placeholder="+593 99 123 4567">
                    </div>

                    <div class="form-group">
                        <label for="direccion" class="form-label">Dirección</label>
                        <textarea class="form-control"
                                  id="direccion"
                                  name="direccion"
                                  rows="3"
                                  placeholder="Tu dirección completa">${sessionScope.usuario.direccion}</textarea>
                    </div>

                    <div class="d-flex gap-3">
                        <button type="submit" class="btn btn-primary">
                            <i class="fas fa-save me-2"></i>Guardar Cambios
                        </button>
                        <button type="reset" class="btn btn-secondary">
                            <i class="fas fa-undo me-2"></i>Cancelar
                        </button>
                    </div>
                </form>
            </div>

            <!-- Password Tab -->
            <div class="tab-pane fade ${tabActiva == 'password' ? 'show active' : ''}"
                 id="password"
                 role="tabpanel">
                <form action="${pageContext.request.contextPath}/perfil/cambiar-password" method="POST">
                    <div class="form-group">
                        <label for="currentPassword" class="form-label">Contraseña Actual</label>
                        <div class="input-wrapper">
                            <input type="password"
                                   class="form-control"
                                   id="currentPassword"
                                   name="currentPassword"
                                   required>
                            <button type="button" class="password-toggle" onclick="togglePassword('currentPassword')">
                                <i class="fas fa-eye"></i>
                            </button>
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="newPassword" class="form-label">Nueva Contraseña</label>
                        <div class="input-wrapper">
                            <input type="password"
                                   class="form-control"
                                   id="newPassword"
                                   name="newPassword"
                                   required
                                   minlength="8">
                            <button type="button" class="password-toggle" onclick="togglePassword('newPassword')">
                                <i class="fas fa-eye"></i>
                            </button>
                        </div>
                        <small class="text-muted">Mínimo 8 caracteres</small>
                    </div>

                    <div class="form-group">
                        <label for="confirmPassword" class="form-label">Confirmar Nueva Contraseña</label>
                        <div class="input-wrapper">
                            <input type="password"
                                   class="form-control"
                                   id="confirmPassword"
                                   name="confirmPassword"
                                   required
                                   minlength="8">
                            <button type="button" class="password-toggle" onclick="togglePassword('confirmPassword')">
                                <i class="fas fa-eye"></i>
                            </button>
                        </div>
                    </div>

                    <div class="d-flex gap-3">
                        <button type="submit" class="btn btn-primary">
                            <i class="fas fa-key me-2"></i>Cambiar Contraseña
                        </button>
                        <button type="reset" class="btn btn-secondary">
                            <i class="fas fa-undo me-2"></i>Cancelar
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- Quick Links -->
    <div class="quick-links">
        <a href="${pageContext.request.contextPath}/pedidos" class="quick-link-card">
            <i class="fas fa-shopping-bag quick-link-icon"></i>
            <span class="quick-link-text">Mis Pedidos</span>
        </a>
        <a href="${pageContext.request.contextPath}/productos" class="quick-link-card">
            <i class="fas fa-store quick-link-icon"></i>
            <span class="quick-link-text">Explorar Productos</span>
        </a>
    </div>
</div>

<!-- Include Footer -->
<%@ include file="/views/components/footer.jsp" %>

<!-- Bootstrap JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

<script>
    // Toggle password visibility
    function togglePassword(inputId) {
        const input = document.getElementById(inputId);
        const icon = input.nextElementSibling.querySelector('i');

        if (input.type === 'password') {
            input.type = 'text';
            icon.classList.remove('fa-eye');
            icon.classList.add('fa-eye-slash');
        } else {
            input.type = 'password';
            icon.classList.remove('fa-eye-slash');
            icon.classList.add('fa-eye');
        }
    }

    // Password validation
    document.querySelector('#password form')?.addEventListener('submit', function(e) {
        const newPassword = document.getElementById('newPassword').value;
        const confirmPassword = document.getElementById('confirmPassword').value;

        if (newPassword !== confirmPassword) {
            e.preventDefault();
            alert('Las contraseñas no coinciden');
        }
    });

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
