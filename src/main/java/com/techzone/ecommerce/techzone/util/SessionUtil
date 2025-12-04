package com.techzone.ecommerce.techzone.util;

import com.techzone.ecommerce.techzone.model.Usuario;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;

import java.util.Optional;

/**
 * Utilidad para manejo de sesiones de usuario
 * Centraliza las operaciones comunes de sesión
 * 
 * @author TechZone Team
 */
public class SessionUtil {

    // Constantes para atributos de sesión
    public static final String ATTR_USUARIO = "usuario";
    public static final String ATTR_ID_USUARIO = "idUsuario";
    public static final String ATTR_NOMBRE_USUARIO = "nombreUsuario";
    public static final String ATTR_ROL_USUARIO = "rolUsuario";
    public static final String ATTR_ITEMS_CARRITO = "itemsCarrito";

    // Tiempo de sesión en segundos
    public static final int SESSION_TIMEOUT_DEFAULT = 30 * 60;        // 30 minutos
    public static final int SESSION_TIMEOUT_RECORDAR = 7 * 24 * 60 * 60; // 7 días

    /**
     * Verifica si hay un usuario autenticado en la sesión
     * @param request HttpServletRequest
     * @return true si hay usuario autenticado
     */
    public static boolean isAuthenticated(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        return session != null && session.getAttribute(ATTR_USUARIO) != null;
    }

    /**
     * Obtiene el usuario de la sesión actual
     * @param request HttpServletRequest
     * @return Optional con el usuario o vacío si no hay sesión
     */
    public static Optional<Usuario> getUsuario(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session != null) {
            Usuario usuario = (Usuario) session.getAttribute(ATTR_USUARIO);
            return Optional.ofNullable(usuario);
        }
        return Optional.empty();
    }

    /**
     * Obtiene el ID del usuario de la sesión
     * @param request HttpServletRequest
     * @return ID del usuario o null si no hay sesión
     */
    public static Integer getIdUsuario(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session != null) {
            return (Integer) session.getAttribute(ATTR_ID_USUARIO);
        }
        return null;
    }

    /**
     * Obtiene el rol del usuario de la sesión
     * @param request HttpServletRequest
     * @return Rol del usuario o null si no hay sesión
     */
    public static String getRolUsuario(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session != null) {
            return (String) session.getAttribute(ATTR_ROL_USUARIO);
        }
        return null;
    }

    /**
     * Verifica si el usuario actual es administrador
     * @param request HttpServletRequest
     * @return true si es admin
     */
    public static boolean isAdmin(HttpServletRequest request) {
        String rol = getRolUsuario(request);
        return Usuario.RolUsuario.ADMIN.name().equals(rol);
    }

    /**
     * Verifica si el usuario actual es cliente
     * @param request HttpServletRequest
     * @return true si es cliente
     */
    public static boolean isCliente(HttpServletRequest request) {
        String rol = getRolUsuario(request);
        return Usuario.RolUsuario.CLIENTE.name().equals(rol);
    }

    /**
     * Crea una sesión para el usuario autenticado
     * @param request HttpServletRequest
     * @param usuario Usuario autenticado
     * @param recordar Si debe mantener sesión por más tiempo
     */
    public static void createSession(HttpServletRequest request, Usuario usuario, boolean recordar) {
        // Invalidar sesión anterior si existe
        HttpSession oldSession = request.getSession(false);
        if (oldSession != null) {
            oldSession.invalidate();
        }

        // Crear nueva sesión
        HttpSession session = request.getSession(true);
        
        // Guardar atributos de usuario
        session.setAttribute(ATTR_USUARIO, usuario);
        session.setAttribute(ATTR_ID_USUARIO, usuario.getIdUsuario());
        session.setAttribute(ATTR_NOMBRE_USUARIO, usuario.getNombreCompleto());
        session.setAttribute(ATTR_ROL_USUARIO, usuario.getRol().name());

        // Configurar tiempo de expiración
        if (recordar) {
            session.setMaxInactiveInterval(SESSION_TIMEOUT_RECORDAR);
        } else {
            session.setMaxInactiveInterval(SESSION_TIMEOUT_DEFAULT);
        }
    }

    /**
     * Actualiza los datos del usuario en la sesión
     * @param request HttpServletRequest
     * @param usuario Usuario actualizado
     */
    public static void updateSession(HttpServletRequest request, Usuario usuario) {
        HttpSession session = request.getSession(false);
        if (session != null) {
            session.setAttribute(ATTR_USUARIO, usuario);
            session.setAttribute(ATTR_NOMBRE_USUARIO, usuario.getNombreCompleto());
            session.setAttribute(ATTR_ROL_USUARIO, usuario.getRol().name());
        }
    }

    /**
     * Destruye la sesión actual (logout)
     * @param request HttpServletRequest
     */
    public static void destroySession(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session != null) {
            session.invalidate();
        }
    }

    /**
     * Guarda el conteo de items del carrito en sesión
     * @param request HttpServletRequest
     * @param cantidad Cantidad de items
     */
    public static void setItemsCarrito(HttpServletRequest request, int cantidad) {
        HttpSession session = request.getSession(false);
        if (session != null) {
            session.setAttribute(ATTR_ITEMS_CARRITO, cantidad);
        }
    }

    /**
     * Obtiene el conteo de items del carrito de la sesión
     * @param request HttpServletRequest
     * @return Cantidad de items o 0
     */
    public static int getItemsCarrito(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session != null) {
            Integer items = (Integer) session.getAttribute(ATTR_ITEMS_CARRITO);
            return items != null ? items : 0;
        }
        return 0;
    }

    /**
     * Guarda un mensaje flash en la sesión (se muestra una vez)
     * @param request HttpServletRequest
     * @param tipo Tipo de mensaje (success, error, warning, info)
     * @param mensaje Contenido del mensaje
     */
    public static void setFlashMessage(HttpServletRequest request, String tipo, String mensaje) {
        HttpSession session = request.getSession(true);
        session.setAttribute("flashTipo", tipo);
        session.setAttribute("flashMensaje", mensaje);
    }

    /**
     * Obtiene y elimina el mensaje flash de la sesión
     * @param request HttpServletRequest
     * @return Array con [tipo, mensaje] o null si no hay mensaje
     */
    public static String[] getFlashMessage(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session != null) {
            String tipo = (String) session.getAttribute("flashTipo");
            String mensaje = (String) session.getAttribute("flashMensaje");
            
            if (tipo != null && mensaje != null) {
                // Eliminar después de leer
                session.removeAttribute("flashTipo");
                session.removeAttribute("flashMensaje");
                return new String[]{tipo, mensaje};
            }
        }
        return null;
    }

    /**
     * Guarda la URL a la que redirigir después del login
     * @param request HttpServletRequest
     * @param url URL de retorno
     */
    public static void setReturnUrl(HttpServletRequest request, String url) {
        HttpSession session = request.getSession(true);
        session.setAttribute("returnUrl", url);
    }

    /**
     * Obtiene y elimina la URL de retorno
     * @param request HttpServletRequest
     * @return URL de retorno o null
     */
    public static String getReturnUrl(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session != null) {
            String url = (String) session.getAttribute("returnUrl");
            if (url != null) {
                session.removeAttribute("returnUrl");
            }
            return url;
        }
        return null;
    }

    /**
     * Constructor privado - clase de utilidad
     */
    private SessionUtil() {
        throw new UnsupportedOperationException("Clase de utilidad, no instanciar");
    }
}
