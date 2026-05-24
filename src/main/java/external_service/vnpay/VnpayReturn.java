package external_service.vnpay;

import dao.OrderDAO;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import dao.PaymentDAO;
import model.Payment;
import model.Order;
import model.ShipOrder;

import java.sql.Timestamp;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.Map;

@WebServlet(name = "VnpayReturn", value = { "/VnpayReturn", "/order-success" })
public class VnpayReturn extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            String orderIdParam = request.getParameter("orderId");
            if (orderIdParam != null && !orderIdParam.isEmpty() && request.getRequestURI().contains("order-success")) {
                int orderId = Integer.parseInt(orderIdParam);
                OrderDAO orderDao = new OrderDAO();
                Order order = orderDao.findById(orderId);
                if (order == null) {
                    response.sendError(HttpServletResponse.SC_NOT_FOUND, "Order not found");
                    return;
                }
                request.setAttribute("transResult", true);
                request.setAttribute("orderId", orderId);
                request.setAttribute("paymentCode", "COD");
                request.setAttribute("amount", order.getTotalPrice());
                request.setAttribute("orderInfo", "Thanh toan don hang bang COD");
                request.setAttribute("payDate",
                        new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new java.util.Date()));
                request.getRequestDispatcher("vnpay/vnpay_return.jsp").forward(request, response);
                return;
            }

            Map<String, String> fields = new HashMap<>();
            for (Enumeration params = request.getParameterNames(); params.hasMoreElements();) {
                String fieldName = URLEncoder.encode((String) params.nextElement(),
                        StandardCharsets.US_ASCII.toString());
                String fieldValue = URLEncoder.encode(request.getParameter(fieldName),
                        StandardCharsets.US_ASCII.toString());
                if ((fieldValue != null) && (fieldValue.length() > 0)) {
                    fields.put(fieldName, fieldValue);
                }
            }

            String vnpSecureHash = fields.get("vnp_SecureHash");
            fields.remove("vnp_SecureHash");
            fields.remove("vnp_SecureHashType");

            String signValue = Config.hashAllFields(fields);

            if (signValue.equals(vnpSecureHash)) {

                String paymentCode = request.getParameter("vnp_TransactionNo");
                String orderId = request.getParameter("vnp_TxnRef");
                System.out.println("VnpayReturn: Received orderId=" + orderId + ", paymentCode=" + paymentCode);

                OrderDAO orderDao = new OrderDAO();
                Order order = orderDao.findById(Integer.parseInt(orderId));
                if (order == null) {
                    System.out.println("VnpayReturn: Order not found for id=" + orderId);
                    response.sendError(HttpServletResponse.SC_NOT_FOUND, "Order not found");
                    return;
                } else {
                    System.out.println("VnpayReturn: Order found");
                }

                boolean transSuccess = false;

                if ("00".equals(request.getParameter("vnp_TransactionStatus"))) {
                    transSuccess = true;
                }
                System.out.println("VnpayReturn: transSuccess=" + transSuccess);

                orderDao.save(order);

                // Update Payment status
                PaymentDAO paymentDAO = new PaymentDAO();
                Payment payment = paymentDAO.findByOrderId(Integer.parseInt(orderId));

                if (payment == null) {
                    System.out.println("VnpayReturn: Payment record not found, creating new one");
                    // Should exist if created in CheckoutController, but create if missing
                    payment = new Payment();
                    payment.setOrderId(Integer.parseInt(orderId));
                    payment.setPayStrategy("VNPay");
                    payment.setAmount(order.getTotalPrice());
                    payment.setPaidAt(new Timestamp(System.currentTimeMillis()));
                    payment.setStatus(transSuccess ? "Completed" : "Failed");
                    paymentDAO.save(payment);
                } else {
                    payment.setStatus(transSuccess ? "Completed" : "Failed");
                    payment.setPaidAt(new Timestamp(System.currentTimeMillis()));
                    paymentDAO.save(payment);
                }

                if (transSuccess) {
                    dao.ShipOrderDAO shipOrderDAO = new dao.ShipOrderDAO();
                    if (shipOrderDAO.getByOrderId(Integer.parseInt(orderId)) == null) {
                        ShipOrder shipOrder = new ShipOrder();
                        shipOrder.setOrderId(Integer.parseInt(orderId));
                        shipOrder.setCarrierName("Giao hàng tiêu chuẩn");
                        shipOrder.setTrackingNumber("VNP" + paymentCode);
                        shipOrder.setShippingFee(0.0);
                        shipOrder.setStatus("Chuẩn bị đơn hàng");
                        shipOrder.setEstimatedDeliveryDate(
                                new Timestamp(System.currentTimeMillis() + 3 * 24 * 60 * 60 * 1000)); // +3 days
                        shipOrderDAO.save(shipOrder);
                    }
                    
                    HttpSession session = request.getSession(false);
                    if (session != null) {
                        String checkoutType = (String) session.getAttribute("checkoutType");
                        if ("buyNow".equals(checkoutType)) {
                            session.removeAttribute("buyNowCart");
                        } else {
                            session.removeAttribute("cart");
                            dao.CartDAO cartDAO = new dao.CartDAO();
                            cartDAO.clearCart(order.getUserId());
                        }
                        session.removeAttribute("pendingOrder");
                        session.removeAttribute("checkoutType");
                    }
                }else {
                    dao.OrderItemDAO orderItemDAO = new dao.OrderItemDAO();
                    services.ProductService productService = new services.ProductService();
                    java.util.List<model.OrderItem> items = orderItemDAO.getByOrderId(Integer.parseInt(orderId));
                    if (items != null) {
                        for (model.OrderItem item : items) {
                            int currentStock = productService.getQuantity(item.getProductId());
                            productService.updateQuantity(item.getProductId(), currentStock + item.getQuantity());
                        }
                    }
                }

                request.setAttribute("transResult", transSuccess);
                request.setAttribute("orderId", orderId);
                request.setAttribute("paymentCode", paymentCode);

                System.out.println("VnpayReturn: Forwarding to JSP");
                request.getRequestDispatcher("vnpay/vnpay_return.jsp")
                        .forward(request, response);

            } else {
                System.out.println("VnpayReturn: Invalid signature");
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid signature");
            }
        } catch (Exception e) {
            System.err.println("VnpayReturn Error: " + e.getMessage());
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    "Internal Server Error: " + e.getMessage());
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

    }
}
