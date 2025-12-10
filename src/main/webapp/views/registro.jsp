<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Registrarse - TechZone</title>

    <style>
        /* ===================================
           TECHZONE - Register Page Styles
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

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: var(--bg-darker);
            color: var(--text-primary);
            line-height: 1.6;
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

        .register-main {
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 40px 20px;
        }

        .register-container {
            max-width: 900px;
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
           REGISTER CARD
           =================================== */

        .register-card {
            background: rgba(26, 26, 26, 0.7);
            backdrop-filter: blur(20px);
            border: 1px solid rgba(255, 255, 255, 0.1);
            border-radius: 20px;
            padding: 40px;
            box-shadow:
                    0 20px 60px rgba(0, 0, 0, 0.5),
                    0 0 0 1px rgba(255, 255, 255, 0.05),
                    inset 0 1px 0 rgba(255, 255, 255, 0.1);
        }

        /* ===================================
           REGISTER HEADER
           =================================== */

        .register-header {
            text-align: center;
            margin-bottom: 35px;
        }

        .register-logo {
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

        .register-title {
            font-size: 32px;
            font-weight: 700;
            color: var(--text-primary);
            margin-bottom: 8px;
        }

        .register-title span {
            color: var(--primary-color);
        }

        .register-subtitle {
            font-size: 14px;
            color: var(--text-secondary);
        }

        /* ===================================
           ALERTS
           =================================== */

        .alert {
            display: flex;
            align-items: flex-start;
            gap: 12px;
            padding: 15px;
            border-radius: 10px;
            margin-bottom: 20px;
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

        .alert svg {
            width: 22px;
            height: 22px;
            flex-shrink: 0;
            margin-top: 2px;
        }

        .alert-error {
            background: rgba(255, 68, 68, 0.1);
            border: 1px solid rgba(255, 68, 68, 0.3);
            color: #ff6b6b;
        }

        .alert-error svg {
            fill: var(--error-color);
        }

        /* ===================================
           FORM STYLES
           =================================== */

        .register-form {
            display: flex;
            flex-direction: column;
            gap: 20px;
        }

        .form-row {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
        }

        .form-group {
            display: flex;
            flex-direction: column;
            gap: 8px;
        }

        .form-group.full-width {
            grid-column: 1 / -1;
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

        .required {
            color: var(--error-color);
            margin-left: 2px;
        }

        .input-wrapper {
            position: relative;
        }

        .form-input,
        .form-textarea {
            width: 100%;
            padding: 14px 16px;
            background: rgba(255, 255, 255, 0.05);
            border: 1px solid rgba(255, 255, 255, 0.1);
            border-radius: 10px;
            color: var(--text-primary);
            font-size: 15px;
            font-family: inherit;
            transition: all 0.3s ease;
        }

        .form-input:focus,
        .form-textarea:focus {
            outline: none;
            background: rgba(255, 255, 255, 0.08);
            border-color: var(--primary-color);
            box-shadow: 0 0 0 3px rgba(0, 212, 255, 0.1);
        }

        .form-input::placeholder,
        .form-textarea::placeholder {
            color: rgba(255, 255, 255, 0.3);
        }

        .form-textarea {
            min-height: 80px;
            resize: vertical;
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
        .form-input:focus ~ .input-border,
        .form-textarea:focus ~ .input-border {
            width: 100%;
        }

        /* Password Toggle */
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

        /* Password Strength Indicator */
        .password-strength {
            display: flex;
            gap: 5px;
            margin-top: 8px;
        }

        .strength-bar {
            flex: 1;
            height: 4px;
            background: rgba(255, 255, 255, 0.1);
            border-radius: 2px;
            transition: all 0.3s ease;
        }

        .strength-bar.active {
            background: var(--primary-color);
        }

        .strength-bar.weak {
            background: #ff4444;
        }

        .strength-bar.medium {
            background: #ffbb33;
        }

        .strength-bar.strong {
            background: #00C851;
        }

        .strength-text {
            font-size: 12px;
            color: var(--text-secondary);
            margin-top: 5px;
        }

        /* Help Text */
        .form-help {
            font-size: 12px;
            color: var(--text-secondary);
            margin-top: 4px;
        }

        /* ===================================
           TERMS CHECKBOX
           =================================== */

        .terms-group {
            display: flex;
            align-items: flex-start;
            gap: 12px;
            padding: 15px;
            background: rgba(0, 212, 255, 0.05);
            border: 1px solid rgba(0, 212, 255, 0.2);
            border-radius: 10px;
            cursor: pointer;
            user-select: none;
        }

        .checkbox-input {
            display: none;
        }

        .checkbox-custom {
            width: 20px;
            height: 20px;
            border: 2px solid rgba(255, 255, 255, 0.2);
            border-radius: 4px;
            position: relative;
            flex-shrink: 0;
            transition: all 0.3s ease;
            margin-top: 2px;
        }

        .checkbox-input:checked + .checkbox-custom {
            background: var(--primary-color);
            border-color: var(--primary-color);
        }

        .checkbox-input:checked + .checkbox-custom::after {
            content: '';
            position: absolute;
            top: 2px;
            left: 6px;
            width: 5px;
            height: 10px;
            border: solid #000;
            border-width: 0 2px 2px 0;
            transform: rotate(45deg);
        }

        .terms-text {
            font-size: 13px;
            color: var(--text-secondary);
            line-height: 1.5;
        }

        .terms-text a {
            color: var(--primary-color);
            text-decoration: none;
            transition: all 0.3s ease;
        }

        .terms-text a:hover {
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

        .btn-submit:disabled {
            opacity: 0.5;
            cursor: not-allowed;
            transform: none;
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
           LOGIN LINK
           =================================== */

        .login-link {
            text-align: center;
            font-size: 14px;
            color: var(--text-secondary);
            margin-top: 20px;
        }

        .login-link a {
            color: var(--primary-color);
            text-decoration: none;
            font-weight: 600;
            transition: all 0.3s ease;
        }

        .login-link a:hover {
            color: var(--primary-hover);
            text-decoration: underline;
        }

        /* ===================================
           RESPONSIVE DESIGN
           =================================== */

        @media (max-width: 768px) {
            .register-main {
                padding: 20px 15px;
            }

            .register-card {
                padding: 30px 20px;
                border-radius: 15px;
            }

            .register-title {
                font-size: 26px;
            }

            .form-row {
                grid-template-columns: 1fr;
                gap: 20px;
            }
        }

        @media (max-width: 480px) {
            .register-logo {
                width: 50px;
                height: 50px;
            }

            .logo-icon {
                width: 28px;
                height: 28px;
            }

            .register-title {
                font-size: 22px;
            }

            .form-input,
            .form-textarea {
                padding: 12px 14px;
                font-size: 14px;
            }
        }

        /* ===================================
           LOADING STATE
           =================================== */

        .btn-submit.loading {
            pointer-events: none;
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
    </style>
</head>
<body>
<!-- Video Background -->
<div class="video-background">
    <video autoplay muted loop playsinline>
        <source src="${pageContext.request.contextPath}/video/tech-background.mp4" type="video/mp4">
    </video>
    <div class="video-overlay"></div>
</div>

<!-- Sidebar -->
<%@ include file="/views/components/header.jsp" %>

<!-- Register Container -->
<main class="register-main">
    <div class="register-container">
        <div class="register-card">
            <!-- Header -->
            <div class="register-header">
                <div class="register-logo">
                    <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg" class="logo-icon">
                        <path d="M12 12c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm0 2c-2.67 0-8 1.34-8 4v2h16v-2c0-2.66-5.33-4-8-4z"/>
                    </svg>
                </div>
                <h1 class="register-title">Únete a <span>TechZone</span></h1>
                <p class="register-subtitle">Crea tu cuenta y comienza a disfrutar de nuestros beneficios</p>
            </div>

            <!-- Error Message -->
            <c:if test="${not empty error}">
            <div class="alert alert-error">
                <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                    <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm1 15h-2v-2h2v2zm0-4h-2V7h2v6z"/>
                </svg>
                <span>${error}</span>
            </div>
            </c:if>

            <!-- Register Form -->
            <form action="${pageContext.request.contextPath}/registro" method="POST" class="register-form" id="registerForm">
                <!-- Nombre y Apellido -->
                <div class="form-row">
                    <div class="form-group">
                        <label for="nombre" class="form-label">
                            <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                                <path d="M12 12c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4z"/>
                            </svg>
                            <span>Nombre <span class="required">*</span></span>
                        </label>
                        <div class="input-wrapper">
                            <input
                                    type="text"
                                    id="nombre"
                                    name="nombre"
                                    class="form-input"
                                    placeholder="Tu nombre"
                                    value="${nombre}"

                                    autocomplete="given-name"
                                    minlength="2"
                                    maxlength="50"
                            >
                            <div class="input-border"></div>
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="apellido" class="form-label">
                            <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                                <path d="M12 12c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4z"/>
                            </svg>
                            <span>Apellido <span class="required">*</span></span>
                        </label>
                        <div class="input-wrapper">
                            <input
                                    type="text"
                                    id="apellido"
                                    name="apellido"
                                    class="form-input"
                                    placeholder="Tu apellido"
                                    value="${apellido}"

                                    autocomplete="family-name"
                                    minlength="2"
                                    maxlength="50"
                            >
                            <div class="input-border"></div>
                        </div>
                    </div>
                </div>

                <!-- Email -->
                <div class="form-group">
                    <label for="email" class="form-label">
                        <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                            <path d="M20 4H4c-1.1 0-1.99.9-1.99 2L2 18c0 1.1.9 2 2 2h16c1.1 0 2-.9 2-2V6c0-1.1-.9-2-2-2zm0 4l-8 5-8-5V6l8 5 8-5v2z"/>
                        </svg>
                        <span>Correo Electrónico <span class="required">*</span></span>
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

                <!-- Teléfono y Dirección -->
                <div class="form-row">
                    <div class="form-group">
                        <label for="telefono" class="form-label">
                            <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                                <path d="M6.62 10.79c1.44 2.83 3.76 5.14 6.59 6.59l2.2-2.2c.27-.27.67-.36 1.02-.24 1.12.37 2.33.57 3.57.57.55 0 1 .45 1 1V20c0 .55-.45 1-1 1-9.39 0-17-7.61-17-17 0-.55.45-1 1-1h3.5c.55 0 1 .45 1 1 0 1.25.2 2.45.57 3.57.11.35.03.74-.25 1.02l-2.2 2.2z"/>
                            </svg>
                            <span>Teléfono</span>
                        </label>
                        <div class="input-wrapper">
                            <input
                                    type="tel"
                                    id="telefono"
                                    name="telefono"
                                    class="form-input"
                                    placeholder="+593 99 123 4567"
                                    value="${telefono}"
                                    autocomplete="tel"
                                    pattern="[0-9+\s\-()]*"
                            >
                            <div class="input-border"></div>
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="direccion" class="form-label">
                            <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                                <path d="M12 2C8.13 2 5 5.13 5 9c0 5.25 7 13 7 13s7-7.75 7-13c0-3.87-3.13-7-7-7zm0 9.5c-1.38 0-2.5-1.12-2.5-2.5s1.12-2.5 2.5-2.5 2.5 1.12 2.5 2.5-1.12 2.5-2.5 2.5z"/>
                            </svg>
                            <span>Dirección</span>
                        </label>
                        <div class="input-wrapper">
                            <input
                                    type="text"
                                    id="direccion"
                                    name="direccion"
                                    class="form-input"
                                    placeholder="Tu dirección"
                                    value="${direccion}"
                                    autocomplete="street-address"
                            >
                            <div class="input-border"></div>
                        </div>
                    </div>
                </div>

                <!-- Contraseña -->
                <div class="form-group">
                    <label for="password" class="form-label">
                        <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                            <path d="M18 8h-1V6c0-2.76-2.24-5-5-5S7 3.24 7 6v2H6c-1.1 0-2 .9-2 2v10c0 1.1.9 2 2 2h12c1.1 0 2-.9 2-2V10c0-1.1-.9-2-2-2zm-6 9c-1.1 0-2-.9-2-2s.9-2 2-2 2 .9 2 2-.9 2-2 2zm3.1-9H8.9V6c0-1.71 1.39-3.1 3.1-3.1 1.71 0 3.1 1.39 3.1 3.1v2z"/>
                        </svg>
                        <span>Contraseña <span class="required">*</span></span>
                    </label>
                    <div class="input-wrapper">
                        <input
                                type="password"
                                id="password"
                                name="password"
                                class="form-input"
                                placeholder="Mínimo 8 caracteres"

                                autocomplete="new-password"
                                minlength="8"
                                oninput="checkPasswordStrength(this.value)"
                        >
                        <button type="button" class="toggle-password" onclick="togglePassword('password')">
                            <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg" class="eye-icon">
                                <path d="M12 4.5C7 4.5 2.73 7.61 1 12c1.73 4.39 6 7.5 11 7.5s9.27-3.11 11-7.5c-1.73-4.39-6-7.5-11-7.5zM12 17c-2.76 0-5-2.24-5-5s2.24-5 5-5 5 2.24 5 5-2.24 5-5 5zm0-8c-1.66 0-3 1.34-3 3s1.34 3 3 3 3-1.34 3-3-1.34-3-3-3z"/>
                            </svg>
                        </button>
                        <div class="input-border"></div>
                    </div>
                    <div class="password-strength" id="passwordStrength">
                        <div class="strength-bar"></div>
                        <div class="strength-bar"></div>
                        <div class="strength-bar"></div>
                        <div class="strength-bar"></div>
                    </div>
                    <p class="strength-text" id="strengthText"></p>
                </div>

                <!-- Confirmar Contraseña -->
                <div class="form-group">
                    <label for="confirmPassword" class="form-label">
                        <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                            <path d="M18 8h-1V6c0-2.76-2.24-5-5-5S7 3.24 7 6v2H6c-1.1 0-2 .9-2 2v10c0 1.1.9 2 2 2h12c1.1 0 2-.9 2-2V10c0-1.1-.9-2-2-2zm-6 9c-1.1 0-2-.9-2-2s.9-2 2-2 2 .9 2 2-.9 2-2 2zm3.1-9H8.9V6c0-1.71 1.39-3.1 3.1-3.1 1.71 0 3.1 1.39 3.1 3.1v2z"/>
                        </svg>
                        <span>Confirmar Contraseña <span class="required">*</span></span>
                    </label>
                    <div class="input-wrapper">
                        <input
                                type="password"
                                id="confirmPassword"
                                name="confirmPassword"
                                class="form-input"
                                placeholder="Repite tu contraseña"

                                autocomplete="new-password"
                                minlength="8"
                        >
                        <button type="button" class="toggle-password" onclick="togglePassword('confirmPassword')">
                            <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg" class="eye-icon">
                                <path d="M12 4.5C7 4.5 2.73 7.61 1 12c1.73 4.39 6 7.5 11 7.5s9.27-3.11 11-7.5c-1.73-4.39-6-7.5-11-7.5zM12 17c-2.76 0-5-2.24-5-5s2.24-5 5-5 5 2.24 5 5-2.24 5-5 5zm0-8c-1.66 0-3 1.34-3 3s1.34 3 3 3 3-1.34 3-3-1.34-3-3-3z"/>
                            </svg>
                        </button>
                        <div class="input-border"></div>
                    </div>
                </div>

                <!-- Términos y Condiciones -->
                <label class="terms-group">
                    <input type="checkbox" name="terminos" class="checkbox-input" required>
                    <span class="checkbox-custom"></span>
                    <span class="terms-text">
                        Acepto los <a href="${pageContext.request.contextPath}/terminos" target="_blank">Términos y Condiciones</a>

                        <a href="${pageContext.request.contextPath}/privacidad" target="_blank">Política de Privacidad</a>
</span>
                </label>
                <!-- Submit Button -->
                <button type="submit" class="btn-submit" id="submitBtn">
                    <span class="btn-text">Crear Cuenta</span>
                    <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg" class="btn-icon">
                        <path d="M12 4l-1.41 1.41L16.17 11H4v2h12.17l-5.58 5.59L12 20l8-8z"/>
                    </svg>
                </button>

                <!-- Login Link -->
                <div class="login-link">
                    ¿Ya tienes cuenta?
                    <a href="${pageContext.request.contextPath}/login">Inicia sesión aquí</a>
                </div>
            </form>
        </div>
    </div>
</main>
<!-- Footer -->
<%@ include file="/views/components/footer.jsp" %>
<script>
    // Toggle password visibility
    function togglePassword(fieldId) {
        const passwordInput = document.getElementById(fieldId);
        const button = passwordInput.nextElementSibling;
        const eyeIcon = button.querySelector('.eye-icon');

        if (passwordInput.type === 'password') {
            passwordInput.type = 'text';
            eyeIcon.innerHTML = '<path d="M12 7c2.76 0 5 2.24 5 5 0 .65-.13 1.26-.36 1.83l2.92 2.92c1.51-1.26 2.7-2.89 3.43-4.75-1.73-4.39-6-7.5-11-7.5-1.4 0-2.74.25-3.98.7l2.16 2.16C10.74 7.13 11.35 7 12 7zM2 4.27l2.28 2.28.46.46C3.08 8.3 1.78 10.02 1 12c1.73 4.39 6 7.5 11 7.5 1.55 0 3.03-.3 4.38-.84l.42.42L19.73 22 21 20.73 3.27 3 2 4.27zM7.53 9.8l1.55 1.55c-.05.21-.08.43-.08.65 0 1.66 1.34 3 3 3 .22 0 .44-.03.65-.08l1.55 1.55c-.67.33-1.41.53-2.2.53-2.76 0-5-2.24-5-5 0-.79.2-1.53.53-2.2zm4.31-.78l3.15 3.15.02-.16c0-1.66-1.34-3-3-3l-.17.01z"/>';
        } else {
            passwordInput.type = 'password';
            eyeIcon.innerHTML = '<path d="M12 4.5C7 4.5 2.73 7.61 1 12c1.73 4.39 6 7.5 11 7.5s9.27-3.11 11-7.5c-1.73-4.39-6-7.5-11-7.5zM12 17c-2.76 0-5-2.24-5-5s2.24-5 5-5 5 2.24 5 5-2.24 5-5 5zm0-8c-1.66 0-3 1.34-3 3s1.34 3 3 3 3-1.34 3-3-1.34-3-3-3z"/>';
        }
    }

    // Check password strength
    function checkPasswordStrength(password) {
        const strengthBars = document.querySelectorAll('.strength-bar');
        const strengthText = document.getElementById('strengthText');

        // Reset bars
        strengthBars.forEach(bar => {
            bar.classList.remove('active', 'weak', 'medium', 'strong');
        });

        if (password.length === 0) {
            strengthText.textContent = '';
            return;
        }

        let strength = 0;

        // Checks
        if (password.length >= 8) strength++;
        if (password.match(/[a-z]/) && password.match(/[A-Z]/)) strength++;
        if (password.match(/[0-9]/)) strength++;
        if (password.match(/[^a-zA-Z0-9]/)) strength++;

        // Update bars and text
        for (let i = 0; i < strength; i++) {
            strengthBars[i].classList.add('active');
            if (strength === 1) strengthBars[i].classList.add('weak');
            else if (strength === 2 || strength === 3) strengthBars[i].classList.add('medium');
            else if (strength === 4) strengthBars[i].classList.add('strong');
        }

        if (strength === 1) strengthText.textContent = 'Contraseña débil';
        else if (strength === 2) strengthText.textContent = 'Contraseña media';
        else if (strength === 3) strengthText.textContent = 'Contraseña buena';
        else if (strength === 4) strengthText.textContent = 'Contraseña fuerte';
    }

    // Form validation
    document.getElementById('registerForm').addEventListener('submit', function(e) {
        const password = document.getElementById('password').value;
        const confirmPassword = document.getElementById('confirmPassword').value;
        const submitBtn = document.getElementById('submitBtn');

        if (password !== confirmPassword) {
            e.preventDefault();
            alert('Las contraseñas no coinciden');
            return;
        }

        // Add loading state
        submitBtn.classList.add('loading');
        submitBtn.disabled = true;
    });

    // Add animation on input focus
    document.querySelectorAll('.form-input, .form-textarea').forEach(input => {
        input.addEventListener('focus', function() {
            this.closest('.input-wrapper').classList.add('focused');
        });

        input.addEventListener('blur', function() {
            if (this.value === '') {
                this.closest('.input-wrapper').classList.remove('focused');
            }
        });

        // Pre-fill focused state
        if (input.value !== '') {
            input.closest('.input-wrapper').classList.add('focused');
        }
    });
</script>
</body>
</html>
