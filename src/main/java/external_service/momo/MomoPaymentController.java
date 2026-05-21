package external_service.momo;

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

@WebServlet(name = "MomoPaymentController", value = "/momoPayment")
public class MomoPaymentController extends HttpServlet {

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
            
            System.out.println("MomoPaymentController: Creating payment for orderId=" + orderId + ", amount=" + amount);
            String payUrl = external_service.momo.Payment.createPaymentUrl(String.valueOf(orderId), amount, orderInfo);
            
            if (payUrl != null && !payUrl.isEmpty()) {
                System.out.println("MomoPaymentController: Redirecting to MoMo payUrl=" + payUrl);
                resp.sendRedirect(payUrl);
            } else {
                System.err.println("MomoPaymentController Error: Generated payUrl is null or empty");
                resp.sendError(500, "Không thể tạo liên kết thanh toán MoMo. Vui lòng thử lại sau.");
            }
        } catch (Exception e) {
            System.err.println("MomoPaymentController Exception: " + e.getMessage());
            e.printStackTrace();
            resp.sendError(500, "Lỗi hệ thống khi tạo thanh toán MoMo.");
        }
    }
}
