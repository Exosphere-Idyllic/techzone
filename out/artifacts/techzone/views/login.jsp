<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Iniciar Sesión - TechZone</title>

    <!-- CSS -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/sidebar.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/footer.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/login.css">

    <style>
        /* ===================================
   TECHZONE - Login Page Styles
   =================================== */

        :root {
            --primary-color: #00d4ff;
            --primary-hover: #00b8e6;
            --error-color: #ff4444;
            --success-color: #00C851;
            --text-primary: #ffffff;
            --text-secondary: #b0b0b0;
            --bg-dark: #1a1a1a;
            --bg-darker: #0a0a0a;
            --border-color: #333333;
        }

        /* ===================================
           VIDEO BACKGROUND
           =================================== */

        .video-background {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            overflow: hidden;
            z-index: -1;
        }

        .video-background video {
            position: absolute;
            top: 50%;
            left: 50%;
            min-width: 100%;
            min-height: 100%;
            width: auto;
            height: auto;
            transform: translate(-50%, -50%);
            object-fit: cover;
        }

        .video-overlay {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: linear-gradient(
                    135deg,
                    rgba(0, 10, 20, 0.85) 0%,
                    rgba(10, 10, 10, 0.75) 50%,
                    rgba(20, 20, 30, 0.85) 100%
            );
            backdrop-filter: blur(3px);
        }

        /* ===================================
           MAIN CONTAINER
           =================================== */

        .login-main {
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 40px 20px;
        }

        .login-container {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 40px;
            max-width: 1100px;
            width: 100%;
            animation: slideUp 0.6s ease-out;
        }

        @keyframes slideUp {
            from {
                opacity: 0;
                transform: translateY(30px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        /* ===================================
           LOGIN CARD
           =================================== */

        .login-card {
            background: rgba(26, 26, 26, 0.7);
            backdrop-filter: blur(20px);
            border: 1px solid rgba(255, 255, 255, 0.1);
            border-radius: 20px;
            padding: 40px;
            box-shadow:
                    0 20px 60px rgba(0, 0, 0, 0.5),
                    0 0 0 1px rgba(255, 255, 255, 0.05),
                    inset 0 1px 0 rgba(255, 255, 255, 0.1);
            animation: fadeIn 0.8s ease-out;
        }

        @keyframes fadeIn {
            from {
                opacity: 0;
            }
            to {
                opacity: 1;
            }
        }

        /* ===================================
           LOGIN HEADER
           =================================== */

        .login-header {
            text-align: center;
            margin-bottom: 30px;
        }

        .login-logo {
            width: 60px;
            height: 60px;
            margin: 0 auto 20px;
            background: linear-gradient(135deg, var(--primary-color), #0099cc);
            border-radius: 15px;
            display: flex;
            align-items: center;
            justify-content: center;
            box-shadow: 0 10px 30px rgba(0, 212, 255, 0.3);
            animation: pulse 2s infinite;
        }

        @keyframes pulse {
            0%, 100% {
                transform: scale(1);
                box-shadow: 0 10px 30px rgba(0, 212, 255, 0.3);
            }
            50% {
                transform: scale(1.05);
                box-shadow: 0 15px 40px rgba(0, 212, 255, 0.5);
            }
        }

        .logo-icon {
            width: 32px;
            height: 32px;
            fill: #000;
        }

        .login-title {
            font-size: 28px;
            font-weight: 700;
            color: var(--text-primary);
            margin-bottom: 8px;
        }

        .login-title span {
            color: var(--primary-color);
        }

        .login-subtitle {
            font-size: 14px;
            color: var(--text-secondary);
        }

        /* ===================================
           ALERTS
           =================================== */

        .alert {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 15px;
            border-radius: 10px;
            margin-bottom: 20px;
            opacity: 0;
            transform: translateY(-10px);
            transition: all 0.3s ease;
        }

        .alert.show {
            opacity: 1;
            transform: translateY(0);
        }

        .alert svg {
            width: 22px;
            height: 22px;
            flex-shrink: 0;
        }

        .alert-error {
            background: rgba(255, 68, 68, 0.1);
            border: 1px solid rgba(255, 68, 68, 0.3);
            color: #ff6b6b;
        }

        .alert-error svg {
            fill: var(--error-color);
        }

        .alert-success {
            background: rgba(0, 200, 81, 0.1);
            border: 1px solid rgba(0, 200, 81, 0.3);
            color: #51cf66;
        }

        .alert-success svg {
            fill: var(--success-color);
        }

        /* ===================================
           FORM STYLES
           =================================== */

        .login-form {
            display: flex;
            flex-direction: column;
            gap: 20px;
        }

        .form-group {
            display: flex;
            flex-direction: column;
            gap: 8px;
        }

        .form-label {
            display: flex;
            align-items: center;
            gap: 8px;
            font-size: 14px;
            font-weight: 500;
            color: var(--text-primary);
        }

        .form-label svg {
            width: 18px;
            height: 18px;
            fill: var(--primary-color);
        }

        .input-wrapper {
            position: relative;
        }

        .form-input {
            width: 100%;
            padding: 14px 16px;
            background: rgba(255, 255, 255, 0.05);
            border: 1px solid rgba(255, 255, 255, 0.1);
            border-radius: 10px;
            color: var(--text-primary);
            font-size: 15px;
            transition: all 0.3s ease;
        }

        .form-input:focus {
            outline: none;
            background: rgba(255, 255, 255, 0.08);
            border-color: var(--primary-color);
            box-shadow: 0 0 0 3px rgba(0, 212, 255, 0.1);
        }

        .form-input::placeholder {
            color: rgba(255, 255, 255, 0.3);
        }

        .input-border {
            position: absolute;
            bottom: 0;
            left: 0;
            width: 0;
            height: 2px;
            background: linear-gradient(90deg, var(--primary-color), #0099cc);
            transition: width 0.4s ease;
        }

        .input-wrapper.focused .input-border,
        .form-input:focus ~ .input-border {
            width: 100%;
        }

        /* Toggle Password Button */
        .toggle-password {
            position: absolute;
            right: 12px;
            top: 50%;
            transform: translateY(-50%);
            background: none;
            border: none;
            cursor: pointer;
            padding: 5px;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: all 0.3s ease;
        }

        .toggle-password:hover {
            transform: translateY(-50%) scale(1.1);
        }

        .toggle-password svg {
            width: 22px;
            height: 22px;
            fill: var(--text-secondary);
        }

        /* ===================================
           FORM OPTIONS
           =================================== */

        .form-options {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 10px;
        }

        .checkbox-label {
            display: flex;
            align-items: center;
            gap: 8px;
            cursor: pointer;
            user-select: none;
        }

        .checkbox-input {
            display: none;
        }

        .checkbox-custom {
            width: 18px;
            height: 18px;
            border: 2px solid rgba(255, 255, 255, 0.2);
            border-radius: 4px;
            position: relative;
            transition: all 0.3s ease;
        }

        .checkbox-input:checked + .checkbox-custom {
            background: var(--primary-color);
            border-color: var(--primary-color);
        }

        .checkbox-input:checked + .checkbox-custom::after {
            content: '';
            position: absolute;
            top: 2px;
            left: 5px;
            width: 5px;
            height: 10px;
            border: solid #000;
            border-width: 0 2px 2px 0;
            transform: rotate(45deg);
        }

        .checkbox-text {
            font-size: 14px;
            color: var(--text-secondary);
        }

        .forgot-link {
            font-size: 14px;
            color: var(--primary-color);
            text-decoration: none;
            transition: all 0.3s ease;
        }

        .forgot-link:hover {
            color: var(--primary-hover);
            text-decoration: underline;
        }

        /* ===================================
           SUBMIT BUTTON
           =================================== */

        .btn-submit {
            width: 100%;
            padding: 15px;
            background: linear-gradient(135deg, var(--primary-color), #0099cc);
            border: none;
            border-radius: 10px;
            color: #000;
            font-size: 16px;
            font-weight: 700;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
            transition: all 0.3s ease;
            box-shadow: 0 10px 30px rgba(0, 212, 255, 0.3);
            margin-top: 10px;
        }

        .btn-submit:hover {
            transform: translateY(-2px);
            box-shadow: 0 15px 40px rgba(0, 212, 255, 0.5);
        }

        .btn-submit:active {
            transform: translateY(0);
        }

        .btn-icon {
            width: 20px;
            height: 20px;
            fill: currentColor;
            transition: transform 0.3s ease;
        }

        .btn-submit:hover .btn-icon {
            transform: translateX(5px);
        }

        /* ===================================
           DIVIDER
           =================================== */

        .divider {
            display: flex;
            align-items: center;
            gap: 15px;
            margin: 25px 0;
            color: var(--text-secondary);
            font-size: 13px;
        }

        .divider::before,
        .divider::after {
            content: '';
            flex: 1;
            height: 1px;
            background: rgba(255, 255, 255, 0.1);
        }

        /* ===================================
           SOCIAL LOGIN
           =================================== */

        .social-login {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 12px;
        }

        .btn-social {
            padding: 12px;
            border: 1px solid rgba(255, 255, 255, 0.1);
            border-radius: 10px;
            background: rgba(255, 255, 255, 0.05);
            color: var(--text-primary);
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            transition: all 0.3s ease;
        }

        .btn-social:hover {
            background: rgba(255, 255, 255, 0.1);
            transform: translateY(-2px);
            box-shadow: 0 5px 20px rgba(0, 0, 0, 0.3);
        }

        .btn-social svg {
            width: 20px;
            height: 20px;
        }

        /* ===================================
           REGISTER LINK
           =================================== */

        .register-link {
            text-align: center;
            font-size: 14px;
            color: var(--text-secondary);
            margin-top: 20px;
        }

        .register-link a {
            color: var(--primary-color);
            text-decoration: none;
            font-weight: 600;
            transition: all 0.3s ease;
        }

        .register-link a:hover {
            color: var(--primary-hover);
            text-decoration: underline;
        }

        /* ===================================
           LOGIN INFO (SIDEBAR)
           =================================== */

        .login-info {
            background: rgba(0, 212, 255, 0.05);
            backdrop-filter: blur(20px);
            border: 1px solid rgba(0, 212, 255, 0.2);
            border-radius: 20px;
            padding: 40px;
            display: flex;
            align-items: center;
            justify-content: center;
            animation: fadeInRight 0.8s ease-out;
        }

        @keyframes fadeInRight {
            from {
                opacity: 0;
                transform: translateX(30px);
            }
            to {
                opacity: 1;
                transform: translateX(0);
            }
        }

        .info-content {
            text-align: center;
        }

        .info-icon {
            width: 80px;
            height: 80px;
            fill: var(--primary-color);
            margin-bottom: 25px;
            animation: float 3s ease-in-out infinite;
        }

        @keyframes float {
            0%, 100% {
                transform: translateY(0);
            }
            50% {
                transform: translateY(-10px);
            }
        }

        .info-content h2 {
            font-size: 32px;
            font-weight: 700;
            color: var(--text-primary);
            margin-bottom: 15px;
        }

        .info-content p {
            font-size: 16px;
            color: var(--text-secondary);
            margin-bottom: 25px;
        }

        .features-list {
            list-style: none;
            padding: 0;
            margin: 0;
            text-align: left;
        }

        .features-list li {
            display: flex;
            align-items: center;
            gap: 12px;
            margin-bottom: 15px;
            font-size: 15px;
            color: var(--text-primary);
        }

        .features-list svg {
            width: 20px;
            height: 20px;
            fill: var(--primary-color);
            flex-shrink: 0;
        }

        /* ===================================
           RESPONSIVE DESIGN
           =================================== */

        @media (max-width: 992px) {
            .login-container {
                grid-template-columns: 1fr;
                max-width: 500px;
            }

            .login-info {
                display: none;
            }
        }

        @media (max-width: 576px) {
            .login-main {
                padding: 20px 15px;
            }

            .login-card {
                padding: 30px 20px;
                border-radius: 15px;
            }

            .login-title {
                font-size: 24px;
            }

            .social-login {
                grid-template-columns: 1fr;
            }

            .form-options {
                flex-direction: column;
                align-items: flex-start;
                gap: 15px;
            }
        }

        /* ===================================
           LOADING STATE
           =================================== */

        .btn-submit.loading {
            pointer-events: none;
            opacity: 0.7;
        }

        .btn-submit.loading .btn-text::after {
            content: '...';
            animation: dots 1.5s infinite;
        }

        @keyframes dots {
            0%, 20% {
                content: '.';
            }
            40% {
                content: '..';
            }
            60%, 100% {
                content: '...';
            }
        }

        /* ===================================
           ACCESSIBILITY
           =================================== */

        .form-input:focus-visible,
        .btn-submit:focus-visible,
        .btn-social:focus-visible {
            outline: 2px solid var(--primary-color);
            outline-offset: 2px;
        }

        /* ===================================
           PRINT STYLES
           =================================== */

        @media print {
            .video-background,
            .login-info {
                display: none;
            }
        }
    </style>
</head>
<body>
<!-- Video Background -->
<div class="video-background">
    <video autoplay muted loop playsinline id="bg-video">
        <source src="${pageContext.request.contextPath}/video/tech-background.mp4" type="video/mp4">
    </video>
    <div class="video-overlay"></div>
</div>

<!-- Sidebar -->
<%@ include file="/views/components/header.jsp" %>

<!-- Login Container -->
<main class="login-main">
    <div class="login-container">
        <!-- Login Card -->
        <div class="login-card">
            <!-- Header -->
            <div class="login-header">
                <div class="login-logo">
                    <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg" class="logo-icon">
                        <path d="M20 4H4c-1.11 0-1.99.89-1.99 2L2 18c0 1.11.89 2 2 2h16c1.11 0 2-.89 2-2V6c0-1.11-.89-2-2-2zm0 14H4v-6h16v6zm0-10H4V6h16v2z"/>
                    </svg>
                </div>
                <h1 class="login-title">Bienvenido a <span>TechZone</span></h1>
                <p class="login-subtitle">Inicia sesión para continuar</p>
            </div>

            <!-- Mensajes de Error/Éxito -->
            <c:if test="${not empty error}">
                <div class="alert alert-error">
                    <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                        <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm1 15h-2v-2h2v2zm0-4h-2V7h2v6z"/>
                    </svg>
                    <span>${error}</span>
                </div>
            </c:if>

            <c:if test="${not empty mensaje}">
                <div class="alert alert-success">
                    <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                        <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-2 15l-5-5 1.41-1.41L10 14.17l7.59-7.59L19 8l-9 9z"/>
                    </svg>
                    <span>${mensaje}</span>
                </div>
            </c:if>

            <!-- Login Form -->
            <form action="${pageContext.request.contextPath}/login" method="POST" class="login-form">
                <!-- Email Field -->
                <div class="form-group">
                    <label for="email" class="form-label">
                        <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                            <path d="M20 4H4c-1.1 0-1.99.9-1.99 2L2 18c0 1.1.9 2 2 2h16c1.1 0 2-.9 2-2V6c0-1.1-.9-2-2-2zm0 4l-8 5-8-5V6l8 5 8-5v2z"/>
                        </svg>
                        <span>Correo Electrónico</span>
                    </label>
                    <div class="input-wrapper">
                        <input
                                type="email"
                                id="email"
                                name="email"
                                class="form-input"
                                placeholder="tu@email.com"
                                value="${email}"

                                autocomplete="email"
                        >
                        <div class="input-border"></div>
                    </div>
                </div>

                <!-- Password Field -->
                <div class="form-group">
                    <label for="password" class="form-label">
                        <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                            <path d="M18 8h-1V6c0-2.76-2.24-5-5-5S7 3.24 7 6v2H6c-1.1 0-2 .9-2 2v10c0 1.1.9 2 2 2h12c1.1 0 2-.9 2-2V10c0-1.1-.9-2-2-2zm-6 9c-1.1 0-2-.9-2-2s.9-2 2-2 2 .9 2 2-.9 2-2 2zm3.1-9H8.9V6c0-1.71 1.39-3.1 3.1-3.1 1.71 0 3.1 1.39 3.1 3.1v2z"/>
                        </svg>
                        <span>Contraseña</span>
                    </label>
                    <div class="input-wrapper">
                        <input
                                type="password"
                                id="password"
                                name="password"
                                class="form-input"
                                placeholder="••••••••"

                                autocomplete="current-password"
                        >
                        <button type="button" class="toggle-password" onclick="togglePassword()">
                            <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg" class="eye-icon">
                                <path d="M12 4.5C7 4.5 2.73 7.61 1 12c1.73 4.39 6 7.5 11 7.5s9.27-3.11 11-7.5c-1.73-4.39-6-7.5-11-7.5zM12 17c-2.76 0-5-2.24-5-5s2.24-5 5-5 5 2.24 5 5-2.24 5-5 5zm0-8c-1.66 0-3 1.34-3 3s1.34 3 3 3 3-1.34 3-3-1.34-3-3-3z"/>
                            </svg>
                        </button>
                        <div class="input-border"></div>
                    </div>
                </div>

                <!-- Remember & Forgot Password -->
                <div class="form-options">
                    <label class="checkbox-label">
                        <input type="checkbox" name="recordar" class="checkbox-input">
                        <span class="checkbox-custom"></span>
                        <span class="checkbox-text">Recordarme</span>
                    </label>
                    <a href="${pageContext.request.contextPath}/recuperar-password" class="forgot-link">
                        ¿Olvidaste tu contraseña?
                    </a>
                </div>

                <!-- Submit Button -->
                <button type="submit" class="btn-submit">
                    <span class="btn-text">Iniciar Sesión</span>
                    <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg" class="btn-icon">
                        <path d="M12 4l-1.41 1.41L16.17 11H4v2h12.17l-5.58 5.59L12 20l8-8z"/>
                    </svg>
                </button>

                <!-- Divider -->
                <div class="divider">
                    <span>o continúa con</span>
                </div>

                <!-- Social Login -->
                <div class="social-login">
                    <button type="button" class="btn-social btn-google">
                        <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                            <path d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z" fill="#4285F4"/>
                            <path d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z" fill="#34A853"/>
                            <path d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z" fill="#FBBC05"/>
                            <path d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z" fill="#EA4335"/>
                        </svg>
                        <span>Google</span>
                    </button>
                    <button type="button" class="btn-social btn-facebook">
                        <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                            <path d="M24 12.073c0-6.627-5.373-12-12-12s-12 5.373-12 12c0 5.99 4.388 10.954 10.125 11.854v-8.385H7.078v-3.47h3.047V9.43c0-3.007 1.792-4.669 4.533-4.669 1.312 0 2.686.235 2.686.235v2.953H15.83c-1.491 0-1.956.925-1.956 1.874v2.25h3.328l-.532 3.47h-2.796v8.385C19.612 23.027 24 18.062 24 12.073z" fill="#1877F2"/>
                        </svg>
                        <span>Facebook</span>
                    </button>
                </div>

                <!-- Register Link -->
                <div class="register-link">
                    ¿No tienes cuenta?
                    <a href="${pageContext.request.contextPath}/registro">Regístrate aquí</a>
                </div>
            </form>
        </div>

        <!-- Side Info (visible en desktop) -->
        <div class="login-info">
            <div class="info-content">
                <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg" class="info-icon">
                    <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-2 15l-5-5 1.41-1.41L10 14.17l7.59-7.59L19 8l-9 9z"/>
                </svg>
                <h2>Bienvenido de vuelta</h2>
                <p>Accede a tu cuenta para disfrutar de:</p>
                <ul class="features-list">
                    <li>
                        <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                            <path d="M9 16.17L4.83 12l-1.42 1.41L9 19 21 7l-1.41-1.41z"/>
                        </svg>
                        <span>Ofertas exclusivas</span>
                    </li>
                    <li>
                        <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                            <path d="M9 16.17L4.83 12l-1.42 1.41L9 19 21 7l-1.41-1.41z"/>
                        </svg>
                        <span>Seguimiento de pedidos</span>
                    </li>
                    <li>
                        <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                            <path d="M9 16.17L4.83 12l-1.42 1.41L9 19 21 7l-1.41-1.41z"/>
                        </svg>
                        <span>Historial de compras</span>
                    </li>
                    <li>
                        <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                            <path d="M9 16.17L4.83 12l-1.42 1.41L9 19 21 7l-1.41-1.41z"/>
                        </svg>
                        <span>Lista de deseos</span>
                    </li>
                </ul>
            </div>
        </div>
    </div>
</main>

<!-- Footer -->
<%@ include file="/views/components/footer.jsp" %>

<script>
    // Toggle password visibility
    function togglePassword() {
        const passwordInput = document.getElementById('password');
        const eyeIcon = document.querySelector('.eye-icon');

        if (passwordInput.type === 'password') {
            passwordInput.type = 'text';
            eyeIcon.innerHTML = '<path d="M12 7c2.76 0 5 2.24 5 5 0 .65-.13 1.26-.36 1.83l2.92 2.92c1.51-1.26 2.7-2.89 3.43-4.75-1.73-4.39-6-7.5-11-7.5-1.4 0-2.74.25-3.98.7l2.16 2.16C10.74 7.13 11.35 7 12 7zM2 4.27l2.28 2.28.46.46C3.08 8.3 1.78 10.02 1 12c1.73 4.39 6 7.5 11 7.5 1.55 0 3.03-.3 4.38-.84l.42.42L19.73 22 21 20.73 3.27 3 2 4.27zM7.53 9.8l1.55 1.55c-.05.21-.08.43-.08.65 0 1.66 1.34 3 3 3 .22 0 .44-.03.65-.08l1.55 1.55c-.67.33-1.41.53-2.2.53-2.76 0-5-2.24-5-5 0-.79.2-1.53.53-2.2zm4.31-.78l3.15 3.15.02-.16c0-1.66-1.34-3-3-3l-.17.01z"/>';
        } else {
            passwordInput.type = 'password';
            eyeIcon.innerHTML = '<path d="M12 4.5C7 4.5 2.73 7.61 1 12c1.73 4.39 6 7.5 11 7.5s9.27-3.11 11-7.5c-1.73-4.39-6-7.5-11-7.5zM12 17c-2.76 0-5-2.24-5-5s2.24-5 5-5 5 2.24 5 5-2.24 5-5 5zm0-8c-1.66 0-3 1.34-3 3s1.34 3 3 3 3-1.34 3-3-1.34-3-3-3z"/>';
        }
    }

    // Add animation on input focus
    document.querySelectorAll('.form-input').forEach(input => {
        input.addEventListener('focus', function() {
            this.parentElement.classList.add('focused');
        });

        input.addEventListener('blur', function() {
            if (this.value === '') {
                this.parentElement.classList.remove('focused');
            }
        });
    });

    // Animate alerts
    document.addEventListener('DOMContentLoaded', function() {
        const alerts = document.querySelectorAll('.alert');
        alerts.forEach(alert => {
            setTimeout(() => {
                alert.classList.add('show');
            }, 100);
        });
    });
</script>
</body>
</html>