package controller;

import dao.OrderDAO;
import dao.PaymentDAO;
import dao.ShipOrderDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Order;
import model.Payment;
import model.ShipOrder;
import model.User;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet(name = "OrderController", value = "/orders")
public class OrderController extends HttpServlet {
    private OrderDAO orderDAO;

    @Override
    public void init() {
        orderDAO = new OrderDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(true);
        User user = (User) session.getAttribute("user");
        if (user == null) {
            String requestedWith = request.getHeader("X-Requested-With");
            if ("XMLHttpRequest".equals(requestedWith)) {
                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                response.getWriter().write("{\"error\":\"not_authenticated\"}");
                return;
            }
            response.sendRedirect(request.getContextPath() + "login");
            return;
        }

        List<Order> orders = orderDAO.getByUserId(user.getId());

        ShipOrderDAO shipOrderDAO = new ShipOrderDAO();
        PaymentDAO paymentDAO = new PaymentDAO();
        Map<Integer, ShipOrder> shipOrderMap = new HashMap<>();
        Map<Integer, Payment> paymentMap = new HashMap<>();

        for (Order order : orders) {
            ShipOrder shipOrder = shipOrderDAO.getByOrderId(order.getId());
            if (shipOrder != null) {
                shipOrderMap.put(order.getId(), shipOrder);
            }

            Payment payment = paymentDAO.findByOrderId(order.getId());
            if (payment != null) {
                paymentMap.put(order.getId(), payment);
            }
        }

        request.setAttribute("orders", orders);
        request.setAttribute("shipOrderMap", shipOrderMap);
        request.setAttribute("paymentMap", paymentMap);
        request.getRequestDispatcher("info_users/my_orders.jsp").forward(request, response);
    }
}
