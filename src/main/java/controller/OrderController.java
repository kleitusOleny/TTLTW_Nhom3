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
        Map<Integer, List<Map<String, Object>>> orderItemsMap = new HashMap<>();

        for (Order order : orders) {
            ShipOrder shipOrder = shipOrderDAO.getByOrderId(order.getId());
            if (shipOrder != null) {
                shipOrderMap.put(order.getId(), shipOrder);
            }

            Payment payment = paymentDAO.findByOrderId(order.getId());
            if (payment != null) {
                paymentMap.put(order.getId(), payment);
            }
            
            orderItemsMap.put(order.getId(), orderDAO.getOrderItems(order.getId()));
        }

        request.setAttribute("orders", orders);
        request.setAttribute("shipOrderMap", shipOrderMap);
        request.setAttribute("paymentMap", paymentMap);
        request.setAttribute("orderItemsMap", orderItemsMap);
        request.getRequestDispatcher("info_users/my_orders.jsp").forward(request, response);
    }
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String action = request.getParameter("action");
        if ("requestRefund".equals(action)) {
            try {
                int orderId = Integer.parseInt(request.getParameter("orderId"));
                ShipOrderDAO shipOrderDAO = new ShipOrderDAO();
                ShipOrder shipOrder = shipOrderDAO.getByOrderId(orderId);
                
                if (shipOrder != null && "Giao hàng thành công".equals(shipOrder.getStatus())) {
                    String reason = request.getParameter("reason");
                    
                    OrderDAO orderDAO = new OrderDAO();
                    Order order = orderDAO.findById(orderId);
                    if (order != null) {
                        String refundReason = reason != null && !reason.trim().isEmpty() ? reason.trim() : "Không có lý do";
                        order.setMessage(refundReason);
                        order.setUpdateAt(new java.sql.Timestamp(System.currentTimeMillis()));
                        orderDAO.save(order);
                    }
                    
                    shipOrderDAO.updateStatus(orderId, "Yêu cầu hoàn trả");
                    session.setAttribute("successMessage", "Yêu cầu hoàn trả / hoàn tiền đã được gửi. Chúng tôi sẽ xử lý sớm nhất.");
                } else {
                    session.setAttribute("errorMessage", "Không thể yêu cầu hoàn trả cho đơn hàng này.");
                }
            } catch (Exception e) {
                session.setAttribute("errorMessage", "Đã có lỗi xảy ra khi gửi yêu cầu.");
            }
            String referer = request.getHeader("Referer");
            response.sendRedirect(referer != null ? referer : request.getContextPath() + "/orders");
        }
    }
}
