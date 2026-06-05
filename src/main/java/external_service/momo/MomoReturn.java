package external_service.momo;

import dao.OrderDAO;
import dao.PaymentDAO;
import dao.ShipOrderDAO;
import jakarta.servlet.http.HttpSession;
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

@WebServlet(name = "MomoReturn", value = "/momoReturn")
public class MomoReturn extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            String partnerCode = request.getParameter("partnerCode");
            String orderId = request.getParameter("orderId");
            String requestId = request.getParameter("requestId");
            String amount = request.getParameter("amount");
            String orderInfo = request.getParameter("orderInfo");
            String orderType = request.getParameter("orderType");
            String transId = request.getParameter("transId");
            String resultCode = request.getParameter("resultCode");
            String message = request.getParameter("message");
            String payType = request.getParameter("payType");
            String responseTime = request.getParameter("responseTime");
            String extraData = request.getParameter("extraData");
            String signature = request.getParameter("signature");

            if (extraData == null) extraData = "";
            if (payType == null) payType = "";

            System.out.println("MomoReturn parameters:");
            System.out.println("orderId: " + orderId);
            System.out.println("amount: " + amount);
            System.out.println("resultCode: " + resultCode);
            System.out.println("transId: " + transId);
            System.out.println("signature: " + signature);

            String rawHash = "accessKey=" + Config.ACCESS_KEY +
                    "&amount=" + amount +
                    "&extraData=" + extraData +
                    "&message=" + message +
                    "&orderId=" + orderId +
                    "&orderInfo=" + orderInfo +
                    "&partnerCode=" + partnerCode +
                    "&requestId=" + requestId +
                    "&responseTime=" + responseTime +
                    "&resultCode=" + resultCode +
                    "&transId=" + transId;

            String signValue = SignUtils.hmacSHA256(rawHash, Config.SECRET_KEY);
            System.out.println("Calculated signature: " + signValue);

            boolean signatureValid = signValue != null && signValue.equalsIgnoreCase(signature);

            if (signatureValid) {
                String originalOrderIdStr = orderId;
                if (orderId != null && orderId.contains("_")) {
                    originalOrderIdStr = orderId.split("_")[0];
                }
                int parsedOrderId = Integer.parseInt(originalOrderIdStr);

                OrderDAO orderDao = new OrderDAO();
                Order order = orderDao.findById(parsedOrderId);
                if (order == null) {
                    System.out.println("MomoReturn: Order not found for id=" + parsedOrderId);
                    response.sendError(HttpServletResponse.SC_NOT_FOUND, "Order not found");
                    return;
                }

                boolean transSuccess = "0".equals(resultCode);
                System.out.println("MomoReturn: transSuccess=" + transSuccess);

                orderDao.save(order);

                PaymentDAO paymentDAO = new PaymentDAO();
                Payment payment = paymentDAO.findByOrderId(parsedOrderId);

                if (payment == null) {
                    System.out.println("MomoReturn: Payment record not found, creating new one");
                    payment = new Payment();
                    payment.setOrderId(parsedOrderId);
                    payment.setPayStrategy("MoMo");
                    payment.setAmount(Double.parseDouble(amount));
                    payment.setPaidAt(new Timestamp(System.currentTimeMillis()));
                    payment.setStatus(transSuccess ? "Completed" : "Failed");
                    paymentDAO.save(payment);
                } else {
                    payment.setStatus(transSuccess ? "Completed" : "Failed");
                    payment.setPaidAt(new Timestamp(System.currentTimeMillis()));
                    paymentDAO.save(payment);
                }

                if (transSuccess) {
                    ShipOrderDAO shipOrderDAO = new ShipOrderDAO();
                    ShipOrder shipOrder = shipOrderDAO.getByOrderId(parsedOrderId);
                    if (shipOrder != null) {
                        shipOrder.setStatus("Chuẩn bị đơn hàng");
                        shipOrder.setTrackingNumber("MOMO" + transId);
                        shipOrderDAO.save(shipOrder);
                    } else {
                        shipOrder = new ShipOrder();
                        shipOrder.setOrderId(parsedOrderId);
                        shipOrder.setCarrierName("Giao hàng tiêu chuẩn");
                        shipOrder.setTrackingNumber("MOMO" + transId);
                        shipOrder.setShippingFee(0.0);
                        shipOrder.setStatus("Chuẩn bị đơn hàng");
                        shipOrder.setEstimatedDeliveryDate(
                                new Timestamp(System.currentTimeMillis() + 3 * 24 * 60 * 60 * 1000));
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
                }else{
                    dao.OrderItemDAO orderItemDAO = new dao.OrderItemDAO();
                    services.ProductService productService = new services.ProductService();
                    java.util.List<model.OrderItem> items = orderItemDAO.getByOrderId(parsedOrderId);
                    if (items != null) {
                        for (model.OrderItem item : items) {
                            int currentStock = productService.getQuantity(item.getProductId());
                            productService.updateQuantity(item.getProductId(), currentStock + item.getQuantity());
                        }
                    }
                    db.JdbiConnector.get().onDemand(dao.ProductIssueDAO.class).deleteByOrderId(parsedOrderId);
                }

                request.setAttribute("transResult", transSuccess);
                request.setAttribute("orderId", orderId);
                request.setAttribute("paymentCode", transId != null ? transId : "MOMO_PENDING");
                request.setAttribute("amount", Double.parseDouble(amount));
                request.setAttribute("orderInfo", orderInfo);
                request.setAttribute("payDate", new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new java.util.Date()));

                System.out.println("MomoReturn: Forwarding to momo_return.jsp");
                request.getRequestDispatcher("momo/momo_return.jsp").forward(request, response);
            } else {
                System.out.println("MomoReturn: Invalid signature verification!");
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid signature");
            }
        } catch (Exception e) {
            System.err.println("MomoReturn Error: " + e.getMessage());
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    "Internal Server Error: " + e.getMessage());
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
