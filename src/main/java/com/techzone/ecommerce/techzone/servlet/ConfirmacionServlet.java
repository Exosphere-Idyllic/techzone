package com.techzone.ecommerce.techzone.servlet;

import com.techzone.ecommerce.techzone.model.DetallePedido;
import com.techzone.ecommerce.techzone.model.Pedido;
import com.techzone.ecommerce.techzone.model.Usuario;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

/**
 * Servlet para mostrar la confirmación del pedido
 */
@WebServlet(name = "ConfirmacionServlet", urlPatterns = {"/checkout/confirmacion"})
public class ConfirmacionServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        Usuario usuario = (Usuario) session.getAttribute("usuario");

        if (usuario == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // Obtener pedido y detalles de la sesión
        Pedido pedido = (Pedido) session.getAttribute("pedido");
        @SuppressWarnings("unchecked")
        List<DetallePedido> detalles = (List<DetallePedido>) session.getAttribute("detalles");

        if (pedido == null || detalles == null) {
            response.sendRedirect(request.getContextPath() + "/carrito");
            return;
        }

        // Pasar datos a la vista
        request.setAttribute("pedido", pedido);
        request.setAttribute("detalles", detalles);

        // Limpiar datos de sesión (ya se mostraron)
        session.removeAttribute("pedido");
        session.removeAttribute("detalles");

        request.getRequestDispatcher("/views/carrito/confirmacion.jsp").forward(request, response);
    }
}