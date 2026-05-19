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
    private OrderDAO orderDAO;
    private OrderItemDAO orderItemDAO;
    private ProductDAO productDAO;
    private static final int LEGAL_AGE = 18;
    @Override
    public void init() {
        orderDAO = new OrderDAO();
        orderItemDAO = new OrderItemDAO();
        productDAO = new ProductDAO();
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

        DiscountService discountService = new DiscountService();
        List<Discount> allUserVouchers = discountService.getUserVouchers(user.getId());

        List<Discount> shippingDiscounts = new ArrayList<>();
        List<Discount> otherVouchers = new ArrayList<>();

        for (Discount d : allUserVouchers) {
            if (d.getApplyType() != null && d.getApplyType().toUpperCase().contains("SHIP")) {
                shippingDiscounts.add(d);
            } else {
                otherVouchers.add(d);
            }
        }

        if (cart.getShippingDiscount() != null) {
            boolean exists = false;
            for (Discount d : shippingDiscounts) {
                if (d.getDiscountCode().equals(cart.getShippingDiscount().getDiscountCode())) {
                    exists = true;
                    break;
                }
            }
            if (!exists) {
                shippingDiscounts.add(cart.getShippingDiscount());
            }
        }

        if (cart.getVoucherDiscount() != null) {
            boolean exists = false;
            for (Discount d : otherVouchers) {
                if (d.getDiscountCode().equals(cart.getVoucherDiscount().getDiscountCode())) {
                    exists = true;
                    break;
                }
            }
            if (!exists) {
                otherVouchers.add(cart.getVoucherDiscount());
            }
        }

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
        // Chọn phí ship mặc định
        shippingFee = ghnFee > 0 ? ghnFee : ghtkFee;

        request.setAttribute("ghnFee", ghnFee);
        request.setAttribute("ghtkFee", ghtkFee);
        request.setAttribute("shippingFee", shippingFee);
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

        if (user == null || order == null) {
            response.sendRedirect("store");
            return;
        }

        if (order.getShippingAddressId() == 0) {
            session.setAttribute("errorMessage", "Vui lòng thêm địa chỉ giao hàng trước khi đặt hàng.");
            response.sendRedirect("address?redirect=checkout");
            return;
        }
        // Kiểm tra tuổi phía server
        if (!checkLegalAge(user)) {
            session.setAttribute("errorMessage", "Bạn chưa đủ tuổi hợp pháp để mua sản phẩm này.");
            String checkoutType = (String) session.getAttribute("checkoutType");
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
                int currentStock = productDAO.getQuantity(item.getProductId());
                if (currentStock < item.getQuantity()) {
                    String productName = productDAO.getProductById(item.getProductId()).getProductName();
                    session.setAttribute("errorMessage", "Sản phẩm '" + productName
                            + "' không đủ số lượng trong kho (Còn lại: " + currentStock + ")");
                    String checkoutType = (String) session.getAttribute("checkoutType");
                    if ("buyNow".equals(checkoutType)) {
                        response.sendRedirect("checkout?from=buyNow");
                    } else {
                        response.sendRedirect("checkout");
                    }
                    return;
                }
            }

            int orderId = orderDAO.createAndReturnId(order);
            order.setId(orderId);

            // Trừ tồn kho
            for (OrderItem item : order.getItems()) {
                item.setOrderId(orderId);
                orderItemDAO.save(item);

                int currentStock = productDAO.getQuantity(item.getProductId());
                productDAO.updateQuantity(item.getProductId(), currentStock - item.getQuantity());
            }

            String paymentMethod = request.getParameter("payment_method");
            String selectedCarrier = request.getParameter("shipping_carrier");

            String carrierName = "Giao Hàng Nhanh (GHN)";
            double shippingFee = 0.0;
            int estimatedDays = 3;

            // Đọc phí ship từ form (đã tính qua GHN API ở frontend)
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

            PaymentDAO paymentDAO = new PaymentDAO();
            Payment payment = new Payment();
            payment.setOrderId(orderId);
            payment.setAmount(order.getTotalPrice() + shippingFee);
            payment.setPaidAt(new Timestamp(System.currentTimeMillis()));

            String checkoutType = (String) session.getAttribute("checkoutType");

            if ("ewallet".equals(paymentMethod)) {
                payment.setPayStrategy("VNPay");
                payment.setStatus("Pending");
                paymentDAO.save(payment);

                // Tạo ship order cho VNPay (đã trừ tồn kho)
                ShipOrderDAO shipOrderDAO = new ShipOrderDAO();
                ShipOrder shipOrder = new ShipOrder();
                shipOrder.setOrderId(orderId);
                shipOrder.setCarrierName(carrierName);
                shipOrder.setTrackingNumber("VNPAY" + System.currentTimeMillis());
                shipOrder.setShippingFee(shippingFee);
                shipOrder.setStatus("Chờ thanh toán");
                shipOrder.setEstimatedDeliveryDate(
                        new Timestamp(System.currentTimeMillis() + (long) estimatedDays * 24 * 60 * 60 * 1000));
                shipOrderDAO.save(shipOrder);

                if ("buyNow".equals(checkoutType)) {
                    session.removeAttribute("buyNowCart");
                } else {
                    session.removeAttribute("cart");
                }
                session.removeAttribute("pendingOrder");
                session.removeAttribute("checkoutType");

                // Xử lý voucher/discount
                handleDiscountsAfterOrder(order, user);

                response.sendRedirect("payment?orderId=" + orderId);
            } else {
                payment.setPayStrategy("COD");
                payment.setStatus("Pending");
                paymentDAO.save(payment);

                ShipOrderDAO shipOrderDAO = new ShipOrderDAO();
                ShipOrder shipOrder = new ShipOrder();
                shipOrder.setOrderId(orderId);
                shipOrder.setCarrierName(carrierName);
                shipOrder.setTrackingNumber("COD" + System.currentTimeMillis());
                shipOrder.setShippingFee(shippingFee);
                shipOrder.setStatus("Chuẩn bị đơn hàng");
                shipOrder.setEstimatedDeliveryDate(
                        new Timestamp(System.currentTimeMillis() + (long) estimatedDays * 24 * 60 * 60 * 1000));
                shipOrderDAO.save(shipOrder);

                if ("buyNow".equals(checkoutType)) {
                    session.removeAttribute("buyNowCart");
                } else {
                    session.removeAttribute("cart");
                }
                session.removeAttribute("pendingOrder");
                session.removeAttribute("checkoutType");

                // Xử lý voucher/discount
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
