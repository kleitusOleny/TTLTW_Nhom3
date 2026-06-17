package external_service.paypal;

import dao.OrderDAO;
import dao.PaymentDAO;
import model.Order;
import model.Payment;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet(name = "PaypalPaymentController", value = "/paypalPayment")
public class PaypalPaymentController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        doPost(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        try {
            String orderIdStr = req.getParameter("orderId");

            if (orderIdStr == null || orderIdStr.trim().isEmpty()) {
                resp.sendRedirect("store");
                return;
            }

            int orderId = Integer.parseInt(orderIdStr);
            OrderDAO orderDAO = new OrderDAO();
            Order order = orderDAO.findById(orderId);
            if (order == null) {
                resp.sendRedirect("store");
                return;
            }

            PaymentDAO paymentDAO = new PaymentDAO();
            Payment payment = paymentDAO.findByOrderId(orderId);
            double amount = (payment != null) ? payment.getAmount() : order.getTotalPrice();

            String orderInfo = "Thanh toan don hang:" + orderId;
            
            String scheme = req.getScheme();
            String serverName = req.getServerName();
            int serverPort = req.getServerPort();
            String contextPath = req.getContextPath();
            String baseUrl = scheme + "://" + serverName;
            if (("http".equals(scheme) && serverPort != 80) || ("https".equals(scheme) && serverPort != 443)) {
                baseUrl += ":" + serverPort;
            }
            baseUrl += contextPath;
            String redirectUrl = baseUrl + "/paypalReturn";
            String cancelUrl = baseUrl + "/checkout";
            
            System.out.println("PaypalPaymentController: Creating payment for orderId=" + orderId + ", amount=" + amount);
            String payUrl = external_service.paypal.Payment.createPaymentUrl(String.valueOf(orderId), amount, orderInfo, redirectUrl, cancelUrl);
            
            if (payUrl != null && !payUrl.isEmpty()) {
                System.out.println("PaypalPaymentController: Redirecting to PayPal payUrl=" + payUrl);
                resp.sendRedirect(payUrl);
            } else {
                System.err.println("PaypalPaymentController Error: Generated payUrl is null or empty");
                resp.sendError(500, "Không thể tạo liên kết thanh toán PayPal. Vui lòng thử lại sau.");
            }
        } catch (Exception e) {
            System.err.println("PaypalPaymentController Exception: " + e.getMessage());
            e.printStackTrace();
            resp.sendError(500, "Lỗi hệ thống khi tạo thanh toán PayPal.");
        }
    }
}
