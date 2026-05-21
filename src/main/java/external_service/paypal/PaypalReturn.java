package external_service.paypal;

import dao.OrderDAO;
import dao.PaymentDAO;
import dao.ShipOrderDAO;
import model.Order;
import model.Payment;
import model.ShipOrder;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.Timestamp;

@WebServlet(name = "PaypalReturn", value = "/paypalReturn")
public class PaypalReturn extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            String orderIdStr = request.getParameter("orderId");
            String token = request.getParameter("token"); // PayPal Order ID
            String payerId = request.getParameter("PayerID");

            System.out.println("PaypalReturn parameters: orderId=" + orderIdStr + ", token=" + token + ", payerId=" + payerId);

            if (orderIdStr == null || orderIdStr.trim().isEmpty() || token == null || token.trim().isEmpty()) {
                response.sendRedirect("store");
                return;
            }

            int orderId = Integer.parseInt(orderIdStr);
            OrderDAO orderDAO = new OrderDAO();
            Order order = orderDAO.findById(orderId);
            if (order == null) {
                System.out.println("PaypalReturn: Order not found for id=" + orderId);
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Order not found");
                return;
            }

            // Capture the payment using the PayPal API helper
            boolean captureSuccess = external_service.paypal.Payment.capturePayment(token);
            System.out.println("PaypalReturn: Capture success=" + captureSuccess);

            PaymentDAO paymentDAO = new PaymentDAO();
            Payment payment = paymentDAO.findByOrderId(orderId);
            double amount = (payment != null) ? payment.getAmount() : order.getTotalPrice();

            if (payment == null) {
                payment = new Payment();
                payment.setOrderId(orderId);
                payment.setPayStrategy("PayPal");
                payment.setAmount(amount);
                payment.setPaidAt(new Timestamp(System.currentTimeMillis()));
                payment.setStatus(captureSuccess ? "Completed" : "Failed");
                paymentDAO.save(payment);
            } else {
                payment.setPayStrategy("PayPal");
                payment.setStatus(captureSuccess ? "Completed" : "Failed");
                payment.setPaidAt(new Timestamp(System.currentTimeMillis()));
                paymentDAO.save(payment);
            }

            if (captureSuccess) {
                // Update Ship Order tracking information
                ShipOrderDAO shipOrderDAO = new ShipOrderDAO();
                ShipOrder shipOrder = shipOrderDAO.getByOrderId(orderId);
                if (shipOrder != null) {
                    shipOrder.setStatus("Chuẩn bị đơn hàng");
                    shipOrder.setTrackingNumber("PAYPAL" + token);
                    shipOrderDAO.save(shipOrder);
                } else {
                    shipOrder = new ShipOrder();
                    shipOrder.setOrderId(orderId);
                    shipOrder.setCarrierName("Giao hàng tiêu chuẩn");
                    shipOrder.setTrackingNumber("PAYPAL" + token);
                    shipOrder.setShippingFee(0.0);
                    shipOrder.setStatus("Chuẩn bị đơn hàng");
                    shipOrder.setEstimatedDeliveryDate(
                            new Timestamp(System.currentTimeMillis() + 3 * 24 * 60 * 60 * 1000));
                    shipOrderDAO.save(shipOrder);
                }
            }

            request.setAttribute("transResult", captureSuccess);
            request.setAttribute("orderId", orderId);
            request.setAttribute("paymentCode", token);
            request.setAttribute("amount", amount);
            request.setAttribute("orderInfo", "Thanh toán đơn hàng:" + orderId);
            request.setAttribute("payDate", new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new java.util.Date()));

            System.out.println("PaypalReturn: Forwarding request to paypal/paypal_return.jsp");
            request.getRequestDispatcher("paypal/paypal_return.jsp").forward(request, response);

        } catch (Exception e) {
            System.err.println("PaypalReturn Error: " + e.getMessage());
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Internal Server Error: " + e.getMessage());
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
