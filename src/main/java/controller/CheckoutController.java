package controller;

import dao.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.*;
import services.DiscountService;
import services.OrderService;
import services.OrderItemService;
import services.ProductService;

import java.io.IOException;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.time.Period;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet(name = "CheckoutController", value = "/checkout")
public class CheckoutController extends HttpServlet {
    private OrderService orderService;
    private OrderItemService orderItemService;
    private ProductService productService;
    private static final int LEGAL_AGE = 18;
    @Override
    public void init() {
        orderService = new OrderService();
        orderItemService = new OrderItemService();
        productService = new ProductService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        User user = (User) session.getAttribute("user");
        Cart cart;
        String from = request.getParameter("from");
        if ("buyNow".equals(from)) {
            cart = (Cart) session.getAttribute("buyNowCart");
            session.setAttribute("checkoutType", "buyNow");
        } else {
            cart = (Cart) session.getAttribute("cart");
            session.setAttribute("checkoutType", "cart");
        }

        if (user == null) {
            response.sendRedirect("login?redirect=checkout");
            return;
        }

        if (cart == null || cart.getItems().isEmpty()) {
            response.sendRedirect("store");
            return;
        }

        boolean isLegalAge = checkLegalAge(user);
        request.setAttribute("isLegalAge", isLegalAge);
        AddressDAO addressDAO = new AddressDAO();
        List<Address> addresses = addressDAO.getByUserID(user.getId());

        Address shippingAddress = null;
        if (!addresses.isEmpty()) {
            shippingAddress = addresses.stream()
                    .filter(Address::isDefault)
                    .findFirst()
                    .orElse(addresses.get(0));
        }

        DiscountService discountService = new DiscountService();
        double loyaltyAmount = discountService.calculateLoyaltyDiscount(user.getId(), cart.getSubtotal());
        cart.setLoyaltyDiscountAmount(loyaltyAmount);

        Order order = new Order();
        order.setUserId(user.getId());
        order.setTotalPrice(cart.getTotal());
        order.setCreateAt(new Timestamp(System.currentTimeMillis()));
        order.setUpdateAt(new Timestamp(System.currentTimeMillis()));
        order.setDelete(false);
        if (shippingAddress != null) {
            order.setShippingAddressId(shippingAddress.getId());
        }

        if (cart.getShippingDiscount() != null) {
            order.setShippingDiscountId(cart.getShippingDiscount().getId());
        }
        if (cart.getVoucherDiscount() != null) {
            order.setVoucherDiscountId(cart.getVoucherDiscount().getId());
        }
        if (loyaltyAmount > 0) {
            Discount loyaltyDiscount = discountService.getOrCreateLoyaltyDiscount();
            order.setLoyaltyDiscountId(loyaltyDiscount.getId());
        }

        List<OrderItem> items = new ArrayList<>();
        Map<String, Product> productMap = new HashMap<>();

        for (CartItem ci : cart.getItems()) {
            OrderItem oi = new OrderItem();
            oi.setProductId(ci.getProduct().getId());
            oi.setQuantity(ci.getQuantity());
            oi.setUnitPrice(ci.getPrice());

            items.add(oi);
            productMap.put(ci.getProduct().getId(), ci.getProduct());
        }

        order.setItems(items);

        session.setAttribute("pendingOrder", order);

        List<Discount> availableShipping = discountService.getAvailableShippingDiscounts();
        List<Discount> allUserVouchers = discountService.getUserVouchers(user.getId());

        List<Discount> shippingDiscounts = new ArrayList<>(availableShipping);
        List<Discount> otherVouchers = new ArrayList<>();

        for (Discount d : allUserVouchers) {
            if (d.getApplyType() != null && d.getApplyType().toUpperCase().contains("SHIP")) {
                boolean exists = false;
                for (Discount s : shippingDiscounts) {
                    if (s.getId().equals(d.getId())) {
                        exists = true;
                        break;
                    }
                }
                if (!exists) {
                    shippingDiscounts.add(d);
                }
            } else {
                otherVouchers.add(d);
            }
        }
        System.out.println("SHIPPING DISCOUNTS: " + shippingDiscounts);
        System.out.println("OTHER VOUCHERS: " + otherVouchers);

        request.setAttribute("shippingDiscounts", shippingDiscounts);
        request.setAttribute("userVouchers", otherVouchers);

        double subtotal = 0;
        for (CartItem ci : cart.getItems()) {
            subtotal += ci.getTotalPrice();
        }
        double discountAmount = subtotal - order.getTotalPrice();
        if (discountAmount < 0)
            discountAmount = 0;
        request.setAttribute("discountAmount", discountAmount);

        double ghnFee = 0;
        double ghtkFee = 0;
        double shippingFee = 0;
        String shippingError = null;
        if (shippingAddress != null) {
            String province = shippingAddress.getCity();
            String district = shippingAddress.getDistrict();
            String ward = shippingAddress.getWard();

            System.out.println("[SHIP DEBUG] province=" + province + ", district=" + district + ", ward=" + ward);

            if (province != null && !province.trim().isEmpty()
                    && district != null && !district.trim().isEmpty()
                    && ward != null && !ward.trim().isEmpty()) {
                // GHN
                try {
                    Map<String, Object> feeResult = external_service.ghn.Service.calculateFeeByAddress(
                            province, district, ward, 500);
                    System.out.println("[GHN DEBUG] result=" + feeResult);
                    if ("success".equals(feeResult.get("status"))) {
                        ghnFee = ((Number) feeResult.get("fee")).doubleValue();
                    } else {
                        shippingError = (String) feeResult.get("message");
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                    shippingError = "Không thể kết nối dịch vụ GHN";
                }

                // GHTK
                try {
                    Map<String, Object> feeResult = external_service.ghtk.Service.calculateFeeByAddress(
                            province, district, 500);
                    System.out.println("[GHTK DEBUG] result=" + feeResult);
                    if ("success".equals(feeResult.get("status"))) {
                        ghtkFee = ((Number) feeResult.get("fee")).doubleValue();
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                }
            } else {
                if (district == null || district.trim().isEmpty()) {
                    shippingError = "Địa chỉ thiếu thông tin Quận/Huyện. Vui lòng cập nhật địa chỉ.";
                } else {
                    shippingError = "Địa chỉ thiếu thông tin. Vui lòng cập nhật đầy đủ Tỉnh/Quận/Phường.";
                }
            }
        }
        shippingFee = ghnFee > 0 ? ghnFee : ghtkFee;

        double excessDiscount = 0.0;
        if (cart.getShippingDiscount() != null && shippingFee > 0) {
            double sdVal = cart.getShippingDiscount().getDiscountValue();
            if (sdVal > shippingFee) {
                excessDiscount = sdVal - shippingFee;
            }
        }

        request.setAttribute("ghnFee", ghnFee);
        request.setAttribute("ghtkFee", ghtkFee);
        request.setAttribute("shippingFee", shippingFee);
        request.setAttribute("excessDiscount", excessDiscount);
        request.setAttribute("shippingError", shippingError);
        request.setAttribute("currentCart", cart);
        request.setAttribute("order", order);
        request.setAttribute("shippingAddress", shippingAddress);
        request.setAttribute("productMap", productMap);
        request.getRequestDispatcher("payment.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        Order order = (Order) session.getAttribute("pendingOrder");
        Cart cart;
        String checkoutType = (String) session.getAttribute("checkoutType");
        if ("buyNow".equals(checkoutType)) {
            cart = (Cart) session.getAttribute("buyNowCart");
        } else {
            cart = (Cart) session.getAttribute("cart");
        }

        if (user == null || order == null) {
            response.sendRedirect("store");
            return;
        }

        if (order.getShippingAddressId() == 0) {
            session.setAttribute("errorMessage", "Vui lòng thêm địa chỉ giao hàng trước khi đặt hàng.");
            response.sendRedirect("address?redirect=checkout");
            return;
        }
        if (!checkLegalAge(user)) {
            session.setAttribute("errorMessage", "Bạn chưa đủ tuổi hợp pháp để mua sản phẩm này.");
            if ("buyNow".equals(checkoutType)) {
                response.sendRedirect("checkout?from=buyNow");
            } else {
                response.sendRedirect("checkout");
            }
            return;
        }

        try {
            order.setNote(request.getParameter("notes"));
            order.setUpdateAt(new Timestamp(System.currentTimeMillis()));

            // Kiểm tra tồn kho
            for (OrderItem item : order.getItems()) {
                int currentStock = productService.getQuantity(item.getProductId());
                if (currentStock < item.getQuantity()) {
                    String productName = productService.getProductById(item.getProductId()).getProductName();
                    session.setAttribute("errorMessage", "Sản phẩm '" + productName
                            + "' không đủ số lượng trong kho (Còn lại: " + currentStock + ")");
                    if ("buyNow".equals(checkoutType)) {
                        response.sendRedirect("checkout?from=buyNow");
                    } else {
                        response.sendRedirect("checkout");
                    }
                    return;
                }
            }

            int orderId = orderService.createAndReturnId(order);
            order.setId(orderId);

            // Trừ tồn kho và tự động tạo phiếu xuất kho
            ProductIssue issue = new ProductIssue();
            issue.setUserId(user.getId());
            issue.setOrderId(orderId);
            issue.setReason("Xuất kho bán hàng (Đơn hàng #" + orderId + ")");
            issue.setNote("Tự động tạo khi đơn hàng #" + orderId + " đặt thành công.");
            
            List<ProductIssueDetail> issueDetails = new ArrayList<>();
            for (OrderItem item : order.getItems()) {
                item.setOrderId(orderId);
                orderItemService.save(item);

                ProductIssueDetail detail = new ProductIssueDetail();
                detail.setProductId(item.getProductId());
                detail.setQuantity(item.getQuantity());
                issueDetails.add(detail);
            }
            issue.setDetails(issueDetails);
            
            ProductIssueDAO issueDAO = db.JdbiConnector.get().onDemand(ProductIssueDAO.class);
            issueDAO.processIssue(issue);

            String paymentMethod = request.getParameter("payment_method");
            String selectedCarrier = request.getParameter("shipping_carrier");

            String carrierName = "Giao Hàng Nhanh (GHN)";
            double shippingFee = 0.0;
            int estimatedDays = 3;

            String shippingFeeParam = request.getParameter("shipping_fee");
            if (shippingFeeParam != null && !shippingFeeParam.isEmpty()) {
                try {
                    shippingFee = Double.parseDouble(shippingFeeParam);
                } catch (NumberFormatException ignored) {}
            }
            if (selectedCarrier != null && !selectedCarrier.isEmpty()) {
                if ("ghtk".equalsIgnoreCase(selectedCarrier)) {
                    carrierName = "Giao Hàng Tiết Kiệm (GHTK)";
                } else {
                    carrierName = "Giao Hàng Nhanh (GHN)";
                }
            }
            double shippingDiscountVal = 0.0;
            if (cart != null && cart.getShippingDiscount() != null) {
                shippingDiscountVal = cart.getShippingDiscount().getDiscountValue();
            }
            double excessDiscount = 0.0;
            if (shippingDiscountVal > shippingFee) {
                excessDiscount = shippingDiscountVal - shippingFee;
            }
            double actualShippingFee = Math.max(0.0, shippingFee - shippingDiscountVal);
            PaymentDAO paymentDAO = new PaymentDAO();
            Payment payment = new Payment();
            payment.setOrderId(orderId);
            payment.setAmount(order.getTotalPrice() + actualShippingFee);
            payment.setPaidAt(new Timestamp(System.currentTimeMillis()));

            if ("ewallet".equals(paymentMethod) || "momo".equals(paymentMethod) || "paypal".equals(paymentMethod)) {
                String strategy = "VNPay";
                String trackingPrefix = "VNPAY";
                if ("momo".equals(paymentMethod)) {
                    strategy = "MoMo";
                    trackingPrefix = "MOMO";
                } else if ("paypal".equals(paymentMethod)) {
                    strategy = "PayPal";
                    trackingPrefix = "PAYPAL";
                }

                payment.setPayStrategy(strategy);
                payment.setStatus("Pending");
                paymentDAO.save(payment);

                // Tạo ship order cho VNPay/MoMo/PayPal (đã trừ tồn kho)
                ShipOrderDAO shipOrderDAO = new ShipOrderDAO();
                ShipOrder shipOrder = new ShipOrder();
                shipOrder.setOrderId(orderId);
                shipOrder.setCarrierName(carrierName);
                shipOrder.setTrackingNumber(trackingPrefix + System.currentTimeMillis());
                shipOrder.setShippingFee(actualShippingFee);
                shipOrder.setStatus("Chờ thanh toán");
                shipOrder.setEstimatedDeliveryDate(
                        new Timestamp(System.currentTimeMillis() + (long) estimatedDays * 24 * 60 * 60 * 1000));
                shipOrderDAO.save(shipOrder);

//                if ("buyNow".equals(checkoutType)) {
//                    session.removeAttribute("buyNowCart");
//                } else {
//                    session.removeAttribute("cart");
//                    CartDAO cartDAO = new CartDAO();
//                    cartDAO.clearCart(user.getId());
//                }
//                session.removeAttribute("pendingOrder");
//                session.removeAttribute("checkoutType");
//
//                handleDiscountsAfterOrder(order, user);

                if ("ewallet".equals(paymentMethod)) {
                    response.sendRedirect("payment?orderId=" + orderId);
                } else if ("momo".equals(paymentMethod)) {
                    response.sendRedirect("momoPayment?orderId=" + orderId);
                } else {
                    response.sendRedirect("paypalPayment?orderId=" + orderId);
                }
            } else {
                payment.setPayStrategy("COD");
                payment.setStatus("Pending");
                paymentDAO.save(payment);

                ShipOrderDAO shipOrderDAO = new ShipOrderDAO();
                ShipOrder shipOrder = new ShipOrder();
                shipOrder.setOrderId(orderId);
                shipOrder.setCarrierName(carrierName);
                shipOrder.setTrackingNumber("COD" + System.currentTimeMillis());
                shipOrder.setShippingFee(actualShippingFee);
                shipOrder.setStatus("Chuẩn bị đơn hàng");
                shipOrder.setEstimatedDeliveryDate(
                        new Timestamp(System.currentTimeMillis() + (long) estimatedDays * 24 * 60 * 60 * 1000));
                shipOrderDAO.save(shipOrder);

                if ("buyNow".equals(checkoutType)) {
                    session.removeAttribute("buyNowCart");
                } else {
                    session.removeAttribute("cart");
                    CartDAO cartDAO = new CartDAO();
                    cartDAO.clearCart(user.getId());
                }
                session.removeAttribute("pendingOrder");
                session.removeAttribute("checkoutType");

                handleDiscountsAfterOrder(order, user);

                response.sendRedirect("order-success?orderId=" + orderId);
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(500, "Không thể đặt hàng");
        }
    }

    private boolean checkLegalAge(User user) {
        if (user.getBirthDay() == null) {
            return false;
        }
        LocalDate birthDate = user.getBirthDay().toLocalDateTime().toLocalDate();
        LocalDate today = LocalDate.now();
        int age = Period.between(birthDate, today).getYears();
        return age >= LEGAL_AGE;
    }

    private void handleDiscountsAfterOrder(Order order, User user) {
        DiscountService discountService = new DiscountService();

        if (order.getShippingDiscountId() != 0) {
            discountService.decrementQuantity(order.getShippingDiscountId());
        }

        if (order.getVoucherDiscountId() != 0) {
            UserVoucherDAO userVoucherDAO = new UserVoucherDAO();
            List<UserVoucher> userVouchers = userVoucherDAO.findByUserId(user.getId());
            for (UserVoucher uv : userVouchers) {
                if (uv.getDiscountId() == order.getVoucherDiscountId()) {
                    userVoucherDAO.markAsUsed(uv.getId());
                    break;
                }
            }
        }
    }
}
