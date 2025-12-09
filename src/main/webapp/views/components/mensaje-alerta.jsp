<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%--
  Componente reutilizable para mostrar mensajes de alerta
  Tipos: success, error, warning, info

  Uso:
  - Mensajes flash de sesión (se autodestruyen)
  - Mensajes estáticos en request attributes

  Ejemplo en servlet:
  SessionUtil.setFlashMessage(request, "success", "Operación exitosa");
  SessionUtil.setFlashMessage(request, "error", "Error al procesar");

  O directamente en request:
  request.setAttribute("mensaje", "Mensaje de éxito");
  request.setAttribute("error", "Mensaje de error");
--%>

<style>
    /* ===================================
       ALERT COMPONENT STYLES
       =================================== */

    .alert-container {
        position: fixed;
        top: 20px;
        right: 240px; /* Ajustado para el sidebar */
        z-index: 9999;
        display: flex;
        flex-direction: column;
        gap: 12px;
        max-width: 450px;
        width: calc(100% - 260px);
        pointer-events: none;
    }

    .alert {
        display: flex;
        align-items: flex-start;
        gap: 12px;
        padding: 16px 20px;
        border-radius: 12px;
        box-shadow:
                0 10px 30px rgba(0, 0, 0, 0.3),
                0 0 0 1px rgba(255, 255, 255, 0.1);
        backdrop-filter: blur(20px);
        opacity: 0;
        transform: translateX(400px);
        animation: slideIn 0.4s ease-out forwards;
        pointer-events: all;
        position: relative;
        overflow: hidden;
        transition: all 0.3s ease;
    }

    .alert:hover {
        transform: translateX(0) scale(1.02);
        box-shadow:
                0 15px 40px rgba(0, 0, 0, 0.4),
                0 0 0 1px rgba(255, 255, 255, 0.15);
    }

    .alert.removing {
        animation: slideOut 0.3s ease-out forwards;
    }

    @keyframes slideIn {
        from {
            opacity: 0;
            transform: translateX(400px);
        }
        to {
            opacity: 1;
            transform: translateX(0);
        }
    }

    @keyframes slideOut {
        from {
            opacity: 1;
            transform: translateX(0);
        }
        to {
            opacity: 0;
            transform: translateX(400px);
        }
    }

    /* Progress Bar */
    .alert-progress {
        position: absolute;
        bottom: 0;
        left: 0;
        height: 3px;
        width: 100%;
        transform-origin: left;
        animation: progress 5s linear forwards;
    }

    @keyframes progress {
        from {
            transform: scaleX(1);
        }
        to {
            transform: scaleX(0);
        }
    }

    .alert.paused .alert-progress {
        animation-play-state: paused;
    }

    /* Alert Types */
    .alert-success {
        background: rgba(0, 200, 81, 0.15);
        border: 1px solid rgba(0, 200, 81, 0.4);
        color: #51cf66;
    }

    .alert-success .alert-progress {
        background: linear-gradient(90deg, #00C851, #51cf66);
    }

    .alert-error {
        background: rgba(255, 68, 68, 0.15);
        border: 1px solid rgba(255, 68, 68, 0.4);
        color: #ff6b6b;
    }

    .alert-error .alert-progress {
        background: linear-gradient(90deg, #ff4444, #ff6b6b);
    }

    .alert-warning {
        background: rgba(255, 187, 51, 0.15);
        border: 1px solid rgba(255, 187, 51, 0.4);
        color: #ffc107;
    }

    .alert-warning .alert-progress {
        background: linear-gradient(90deg, #ffbb33, #ffc107);
    }

    .alert-info {
        background: rgba(0, 212, 255, 0.15);
        border: 1px solid rgba(0, 212, 255, 0.4);
        color: #00d4ff;
    }

    .alert-info .alert-progress {
        background: linear-gradient(90deg, #00d4ff, #0099cc);
    }

    /* Alert Icon */
    .alert-icon {
        width: 24px;
        height: 24px;
        flex-shrink: 0;
        margin-top: 2px;
    }

    .alert-success .alert-icon {
        fill: #00C851;
    }

    .alert-error .alert-icon {
        fill: #ff4444;
    }

    .alert-warning .alert-icon {
        fill: #ffbb33;
    }

    .alert-info .alert-icon {
        fill: #00d4ff;
    }

    /* Alert Content */
    .alert-content {
        flex: 1;
        min-width: 0;
    }

    .alert-title {
        font-size: 15px;
        font-weight: 600;
        margin-bottom: 4px;
        line-height: 1.4;
    }

    .alert-message {
        font-size: 14px;
        line-height: 1.5;
        opacity: 0.9;
        word-wrap: break-word;
    }

    /* Close Button */
    .alert-close {
        background: none;
        border: none;
        cursor: pointer;
        padding: 4px;
        display: flex;
        align-items: center;
        justify-content: center;
        border-radius: 6px;
        transition: all 0.3s ease;
        opacity: 0.6;
        flex-shrink: 0;
    }

    .alert-close:hover {
        opacity: 1;
        background: rgba(255, 255, 255, 0.1);
        transform: scale(1.1);
    }

    .alert-close svg {
        width: 20px;
        height: 20px;
        fill: currentColor;
    }

    /* Responsive */
    @media (max-width: 768px) {
        .alert-container {
            right: 20px;
            left: 20px;
            width: auto;
            top: 70px; /* Debajo del toggle del sidebar */
        }

        .alert {
            padding: 14px 16px;
        }

        .alert-icon {
            width: 22px;
            height: 22px;
        }

        .alert-title {
            font-size: 14px;
        }

        .alert-message {
            font-size: 13px;
        }
    }

    @media (max-width: 480px) {
        .alert-container {
            top: 60px;
        }

        .alert {
            padding: 12px 14px;
        }

        .alert-content {
            font-size: 13px;
        }
    }

    /* Static Alerts (para usar en páginas específicas) */
    .alert-static {
        position: relative;
        width: 100%;
        max-width: 100%;
        margin-bottom: 20px;
        opacity: 1;
        transform: translateX(0);
        animation: fadeIn 0.4s ease-out;
    }

    @keyframes fadeIn {
        from {
            opacity: 0;
            transform: translateY(-10px);
        }
        to {
            opacity: 1;
            transform: translateY(0);
        }
    }

    .alert-static .alert-progress {
        display: none;
    }
</style>

<!-- Alert Container (para mensajes flotantes) -->
<div class="alert-container" id="alertContainer"></div>

<script>
    /**
     * Sistema de alertas para TechZone
     * Maneja tanto mensajes flash de sesión como alertas dinámicas
     */

    let AlertSystem = {
        container: null,
        alerts: [],
        autoRemoveDelay: 5000, // 5 segundos

        init() {
            this.container = document.getElementById('alertContainer');
            this.checkFlashMessages();
        },

        /**
         * Verifica y muestra mensajes flash de la sesión
         */
        checkFlashMessages() {
            // Mensajes de éxito
            <c:if test="${not empty sessionScope.flashSuccess}">
            this.show('success', '${sessionScope.flashSuccess}');
            <c:remove var="flashSuccess" scope="session" />
            </c:if>

            // Mensajes de error
            <c:if test="${not empty sessionScope.flashError}">
            this.show('error', '${sessionScope.flashError}');
            <c:remove var="flashError" scope="session" />
            </c:if>

            // Mensajes de advertencia
            <c:if test="${not empty sessionScope.flashWarning}">
            this.show('warning', '${sessionScope.flashWarning}');
            <c:remove var="flashWarning" scope="session" />
            </c:if>

            // Mensajes informativos
            <c:if test="${not empty sessionScope.flashInfo}">
            this.show('info', '${sessionScope.flashInfo}');
            <c:remove var="flashInfo" scope="session" />
            </c:if>

            // También verificar en request attributes (para alertas estáticas)
            <c:if test="${not empty requestScope.mensaje}">
            this.show('success', '${requestScope.mensaje}');
            </c:if>

            <c:if test="${not empty requestScope.error}">
            this.show('error', '${requestScope.error}');
            </c:if>

            <c:if test="${not empty requestScope.warning}">
            this.show('warning', '${requestScope.warning}');
            </c:if>

            <c:if test="${not empty requestScope.info}">
            this.show('info', '${requestScope.info}');
            </c:if>
        },

        /**
         * Muestra una alerta
         * @param {string} type - success, error, warning, info
         * @param {string} message - Mensaje a mostrar
         * @param {string} title - Título opcional
         * @param {number} duration - Duración en ms (opcional)
         */
        show(type, message, title = null, duration = null) {
            const alertId = 'alert-' + Date.now();
            const alertElement = this.createAlertElement(alertId, type, message, title);

            this.container.appendChild(alertElement);
            this.alerts.push({ id: alertId, element: alertElement });

            // Auto-remove después del delay
            const removeDelay = duration || this.autoRemoveDelay;
            const timeoutId = setTimeout(() => {
                this.remove(alertId);
            }, removeDelay);

            // Pausar/reanudar el timer en hover
            alertElement.addEventListener('mouseenter', () => {
                clearTimeout(timeoutId);
                alertElement.classList.add('paused');
            });

            alertElement.addEventListener('mouseleave', () => {
                alertElement.classList.remove('paused');
                setTimeout(() => {
                    this.remove(alertId);
                }, 2000);
            });
        },

        /**
         * Crea el elemento HTML de la alerta
         */
        createAlertElement(id, type, message, title) {
            const alert = document.createElement('div');
            alert.id = id;
            alert.className = `alert alert-${type}`;

            const icons = {
                success: '<path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-2 15l-5-5 1.41-1.41L10 14.17l7.59-7.59L19 8l-9 9z"/>',
                error: '<path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm1 15h-2v-2h2v2zm0-4h-2V7h2v6z"/>',
                warning: '<path d="M1 21h22L12 2 1 21zm12-3h-2v-2h2v2zm0-4h-2v-4h2v4z"/>',
                info: '<path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm1 15h-2v-6h2v6zm0-8h-2V7h2v2z"/>'
            };

            const titles = {
                success: title || '¡Éxito!',
                error: title || 'Error',
                warning: title || 'Advertencia',
                info: title || 'Información'
            };

            alert.innerHTML = `
                <svg class="alert-icon" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                    ${icons[type]}
                </svg>
                <div class="alert-content">
                    <div class="alert-title">${titles[type]}</div>
                    <div class="alert-message">${this.escapeHtml(message)}</div>
                </div>
                <button class="alert-close" onclick="AlertSystem.remove('${id}')" aria-label="Cerrar">
                    <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                        <path d="M19 6.41L17.59 5 12 10.59 6.41 5 5 6.41 10.59 12 5 17.59 6.41 19 12 13.41 17.59 19 19 17.59 13.41 12z"/>
                    </svg>
                </button>
                <div class="alert-progress"></div>
            `;

            return alert;
        },

        /**
         * Elimina una alerta
         */
        remove(alertId) {
            const alertIndex = this.alerts.findIndex(a => a.id === alertId);
            if (alertIndex === -1) return;

            const alert = this.alerts[alertIndex];
            alert.element.classList.add('removing');

            setTimeout(() => {
                if (alert.element.parentNode) {
                    alert.element.parentNode.removeChild(alert.element);
                }
                this.alerts.splice(alertIndex, 1);
            }, 300);
        },

        /**
         * Elimina todas las alertas
         */
        removeAll() {
            this.alerts.forEach(alert => {
                this.remove(alert.id);
            });
        },

        /**
         * Escapa HTML para prevenir XSS
         */
        escapeHtml(text) {
            const div = document.createElement('div');
            div.textContent = text;
            return div.innerHTML;
        }
    };

    // Inicializar al cargar el DOM
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', () => AlertSystem.init());
    } else {
        AlertSystem.init();
    }

    // Exponer globalmente para uso en otras páginas
    window.AlertSystem = AlertSystem;
</script>

<%--
  MÉTODOS DE USO:

  1. Desde Servlet (con SessionUtil):
  ========================================
  // Éxito
  SessionUtil.setFlashMessage(request, "success", "Producto agregado al carrito");

  // Error
  SessionUtil.setFlashMessage(request, "error", "No se pudo procesar el pedido");

  // Advertencia
  SessionUtil.setFlashMessage(request, "warning", "Stock limitado");

  // Info
  SessionUtil.setFlashMessage(request, "info", "Envío gratis en compras mayores a $50");

  2. Desde JavaScript:
  ========================================
  // Alerta simple
  AlertSystem.show('success', 'Operación completada');

  // Con título personalizado
  AlertSystem.show('error', 'No se pudo conectar', 'Error de Conexión');

  // Con duración personalizada (en ms)
  AlertSystem.show('info', 'Guardando cambios...', null, 3000);

  3. Request Attributes (para páginas específicas):
  ========================================
  request.setAttribute("mensaje", "Usuario actualizado");
  request.setAttribute("error", "Email ya registrado");
  request.setAttribute("warning", "Revisa los datos ingresados");
  request.setAttribute("info", "Completa tu perfil");

  4. Alertas estáticas en JSP:
  ========================================
  <div class="alert alert-success alert-static">
      <svg class="alert-icon" viewBox="0 0 24 24">
          <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-2 15l-5-5 1.41-1.41L10 14.17l7.59-7.59L19 8l-9 9z"/>
      </svg>
      <div class="alert-content">
          <div class="alert-title">¡Éxito!</div>
          <div class="alert-message">Tu mensaje aquí</div>
      </div>
  </div>
--%>