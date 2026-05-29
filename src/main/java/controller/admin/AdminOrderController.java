package controller.admin;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.reflect.TypeToken;
import dao.AddressDAO;
import dao.OrderDAO;
import dao.OrderItemDAO;
import dao.PaymentDAO;
import dao.ProductDAO;
import dao.ShipOrderDAO;
import dao.UserDAO;
import model.Address;
import model.CreateOrderRequest;
import model.Order;
import model.OrderItem;
import model.OrderViewModel;
import model.Payment;
import model.Product;
import model.ShipOrder;
import model.User;
import services.EmailServices;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

@WebServlet({"/admin/manage-orders", "/admin/get-order", "/admin/update-order", "/admin/delete-order", "/admin/add-order", "/admin/create-order", "/admin/submit-order", "/admin/api/orders", "/admin/edit-order", "/admin/verify-user", "/admin/refund-order", "/admin/send-feedback"})
public class AdminOrderController extends HttpServlet {
    private OrderDAO orderDAO;
    private ShipOrderDAO shipOrderDAO;
    private EmailServices emailServices;
    private ProductDAO productDAO;
    private UserDAO userDAO;
    private OrderItemDAO orderItemDAO;
    private AddressDAO addressDAO;
    private PaymentDAO paymentDAO;
    private Gson gson;

    @Override
    public void init() {
        orderDAO = new OrderDAO();
        shipOrderDAO = new ShipOrderDAO();
        emailServices = new EmailServices();
        productDAO = new ProductDAO();
        userDAO = new UserDAO();
        orderItemDAO = new OrderItemDAO();
        addressDAO = new AddressDAO();
        paymentDAO = new PaymentDAO();
        gson = new GsonBuilder().serializeNulls().create();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String path = request.getServletPath();

        try {
            if ("/admin/manage-orders".equals(path)) {
                List<OrderViewModel> orders = orderDAO.getAllOrdersWithStatus();
                request.setAttribute("orders", orders);
                request.getRequestDispatcher("/admin/manage_orders.jsp").forward(request, response);
                
            } else if ("/admin/get-order".equals(path)) {
                int id = Integer.parseInt(request.getParameter("id"));
                Map<String, Object> orderInfo = orderDAO.getOrderInfo(id);
                List<Map<String, Object>> orderItems = orderDAO.getOrderItems(id);
                List<OrderViewModel> orders = orderDAO.getAllOrdersWithStatus();
                
                if (orderInfo != null) {
                    request.setAttribute("orders", orders);
                    request.setAttribute("orderInfo", orderInfo);
                    request.setAttribute("orderItems", orderItems);
                    request.getRequestDispatcher("/admin/manage_orders.jsp").forward(request, response);
                } else {
                    response.sendError(HttpServletResponse.SC_NOT_FOUND);
                }
                
            } else if ("/admin/create-order".equals(path)) {
                String keyword = request.getParameter("keyword");
                String filterType = request.getParameter("filterType");

                List<Product> products = productDAO.getProducts(50, 0, "price-asc");

                if (keyword != null && !keyword.trim().isEmpty()) {
                    String kw = keyword.toLowerCase().trim();
                    products = products.stream()
                            .filter(p -> p.getProductName().toLowerCase().contains(kw)
                                    || p.getId().toLowerCase().contains(kw)
                                    || (p.getOrigin() != null && p.getOrigin().toLowerCase().contains(kw)))
                            .toList();
                }

                if (filterType != null && !filterType.isEmpty() && !"all".equals(filterType)) {
                    products = products.stream()
                            .filter(p -> p.getTypeId() != null
                                    && p.getTypeId().toLowerCase().contains(filterType.toLowerCase()))
                            .toList();
                }

                request.setAttribute("products", products);
                request.setAttribute("keyword", keyword);
                request.setAttribute("filterType", filterType != null ? filterType : "all");

                List<User> recentCustomers = userDAO.findAll().stream().limit(10).toList();
                request.setAttribute("recentCustomers", recentCustomers);

                request.getRequestDispatcher("/admin/create_order.jsp").forward(request, response);

            } else if ("/admin/verify-user".equals(path)) {
                String email = request.getParameter("email");
                String phone = request.getParameter("phone");

                User foundUser = null;
                if (email != null && !email.trim().isEmpty()) {
                    foundUser = userDAO.findByEmail(email.trim());
                }
                if (foundUser == null && phone != null && !phone.trim().isEmpty()) {
                    foundUser = userDAO.findByPhoneNumber(phone.trim());
                }

                if (foundUser != null) {
                    request.setAttribute("found", true);
                    request.setAttribute("userId", foundUser.getId());
                    request.setAttribute("fullName", foundUser.getFullName() != null ? foundUser.getFullName() : "");
                    request.setAttribute("email", foundUser.getEmail() != null ? foundUser.getEmail() : "");
                    request.setAttribute("phone", foundUser.getPhoneNumber() != null ? foundUser.getPhoneNumber() : "");
                } else {
                    request.setAttribute("found", false);
                    request.setAttribute("message", "Không tìm thấy người dùng. Đơn hàng sẽ được tạo cho khách vãng lai.");
                }
                
                List<Product> products = productDAO.listProduct();
                request.setAttribute("products", products);
                
                List<User> recentCustomers = userDAO.findAll().stream().limit(10).toList();
                request.setAttribute("recentCustomers", recentCustomers);

                request.getRequestDispatcher("/admin/create_order.jsp").forward(request, response);
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String path = request.getServletPath();
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        try {
            if ("/admin/update-order".equals(path)) {
                int id = Integer.parseInt(request.getParameter("id"));
                String status = request.getParameter("statusSelect");
                
                if (status == null) {
                    status = request.getParameter("status");
                }

                User currentUser = (User) request.getSession().getAttribute("user");
                boolean isAdmin = currentUser != null && currentUser.getAdministrator() == 1;
                Map<String, Object> orderInfo = orderDAO.getOrderInfo(id);

                if (orderInfo != null && !isAdmin) {
                    String currentStatus = (String) orderInfo.get("ship_status");
                    if (currentStatus != null && (currentStatus.equalsIgnoreCase("Giao hàng thành công") || currentStatus.equalsIgnoreCase("Đã giao") || currentStatus.equalsIgnoreCase("Đã hủy"))) {
                        request.getSession().setAttribute("errorMessage", "Không thể cập nhật trạng thái đơn hàng đã giao hoặc đã hủy (Cần quyền Admin)!");
                        response.sendRedirect(request.getContextPath() + "/admin/manage-orders");
                        return;
                    }
                }
                
                boolean isUpdated = false;
                if (status != null) {
                    isUpdated = shipOrderDAO.updateStatus(id, status);
                    if (!isUpdated) {
                        ShipOrder shipOrder = new ShipOrder();
                        shipOrder.setOrderId(id);
                        shipOrder.setStatus(status);
                        shipOrder.setShippingFee(0.0);
                        isUpdated = shipOrderDAO.save(shipOrder) != null;
                    }
                }
                
                if (isUpdated) {
                    String message = "Cập nhật trạng thái đơn hàng thành công! Hệ thống đang tiến hành gửi email thông báo ẩn.";
                    if (orderInfo != null && orderInfo.get("email") != null) {
                        final String userEmail = orderInfo.get("email").toString();
                        final String finalStatus = status;
                        final int finalId = id;
                        java.util.concurrent.CompletableFuture.runAsync(() -> {
                            emailServices.sendOrderProblemEmail(userEmail, finalId, finalStatus);
                        });
                    }
                    request.getSession().setAttribute("successMessage", message);
                } else {
                    request.getSession().setAttribute("errorMessage", "Cập nhật thất bại!");
                }
                response.sendRedirect(request.getContextPath() + "/admin/manage-orders");
                
            } else if ("/admin/delete-order".equals(path)) {
                response.setContentType("application/json");
                PrintWriter out = response.getWriter();
                String idsParam = request.getParameter("ids");
                
                if (idsParam != null && !idsParam.trim().isEmpty()) {
                    String[] ids = idsParam.split(",");
                    boolean allSuccess = true;
                    boolean somePrevented = false;
                    for (String idStr : ids) {
                        try {
                            int orderId = Integer.parseInt(idStr.trim());
                            Map<String, Object> orderInfo = orderDAO.getOrderInfo(orderId);
                            if (orderInfo != null) {
                                String status = (String) orderInfo.get("ship_status");
                                if (status != null && (status.equalsIgnoreCase("Giao hàng thành công") || status.equalsIgnoreCase("Đã giao") || status.equalsIgnoreCase("Đã hủy"))) {
                                    somePrevented = true;
                                    allSuccess = false;
                                    continue;
                                }
                            }
                            boolean deleted = orderDAO.deleteById(orderId);
                            if (!deleted) allSuccess = false;
                        } catch (NumberFormatException e) {
                            allSuccess = false;
                        }
                    }
                    if (allSuccess) {
                        out.print("{\"success\": true, \"message\": \"Đã xóa đơn hàng thành công!\"}");
                    } else if (somePrevented) {
                        out.print("{\"success\": false, \"message\": \"Không thể xóa đơn hàng đã giao hoặc đã hủy!\"}");
                    } else {
                        out.print("{\"success\": false, \"message\": \"Có lỗi xảy ra khi xóa một số đơn hàng!\"}");
                    }
                } else {
                    out.print("{\"success\": false, \"message\": \"Không có đơn hàng nào được chọn!\"}");
                }
                out.flush();
                
            } else if ("/admin/add-order".equals(path)) {
                String customerEmail = request.getParameter("customerEmail");
                int userId = 1; 

                model.User user = userDAO.findByEmail(customerEmail);
                if (user != null) {
                    userId = user.getId();
                }

                String dateStr = request.getParameter("date");
                String totalStr = request.getParameter("total");
                String status = request.getParameter("status");

                double total = 0;
                try {
                    total = Double.parseDouble(totalStr.replaceAll("[^0-9.]", ""));
                } catch (NumberFormatException e) {
                    total = 0;
                }

                Order order = new Order();
                order.setUserId(userId);
                order.setTotalPrice(total);
                order.setCreateAt(Timestamp.valueOf(dateStr + " 00:00:00"));
                order.setUpdateAt(Timestamp.valueOf(LocalDateTime.now()));
                order.setDelete(false);
                order.setShippingAddressId(1);

                int orderId = orderDAO.createAndReturnId(order);

                if (orderId > 0) {
                    ShipOrder shipOrder = new ShipOrder();
                    shipOrder.setOrderId(orderId);
                    shipOrder.setStatus(status);
                    shipOrder.setCarrierName("Giao hàng nhanh");
                    shipOrder.setShippingFee(0);
                    shipOrder.setEstimatedDeliveryDate(Timestamp.valueOf(LocalDateTime.now().plusDays(3)));

                    shipOrderDAO.save(shipOrder);
                }

                response.setContentType("application/json");
                response.getWriter().write("{\"success\": true, \"message\": \"Thêm đơn hàng thành công!\"}");
                
            } else if ("/admin/api/orders".equals(path)) {
                response.setContentType("application/json");

                try (BufferedReader reader = request.getReader()) {
                    CreateOrderRequest payload = gson.fromJson(reader, CreateOrderRequest.class);
                    if (payload == null || payload.getItems() == null || payload.getItems().isEmpty()) {
                        writeJson(response, HttpServletResponse.SC_BAD_REQUEST,
                                Map.of("success", false, "message", "Danh sách sản phẩm không hợp lệ."));
                        return;
                    }

                    double total = payload.getItems().stream()
                            .mapToDouble(item -> item.getUnitPrice() * item.getQuantity())
                            .sum();

                    int userId = resolveUserId(payload);
                    int shippingAddressId = payload.getAddressId() != null ? payload.getAddressId() : 1;

                    Order order = new Order();
                    order.setUserId(userId);
                    order.setShippingAddressId(shippingAddressId);
                    order.setTotalPrice(total);
                    order.setCreateAt(Timestamp.valueOf(LocalDateTime.now()));
                    order.setUpdateAt(Timestamp.valueOf(LocalDateTime.now()));
                    order.setDelete(false);
                    order.setNote(payload.getNote());

                    int orderId = orderDAO.createAndReturnId(order);

                    for (CreateOrderRequest.Item item : payload.getItems()) {
                        OrderItem orderItem = new OrderItem();
                        orderItem.setOrderId(orderId);
                        orderItem.setProductId(item.getProductId());
                        orderItem.setQuantity(item.getQuantity());
                        orderItem.setUnitPrice(item.getUnitPrice());
                        orderItemDAO.save(orderItem);
                    }

                    ShipOrder shipOrder = new ShipOrder();
                    shipOrder.setOrderId(orderId);
                    shipOrder.setCarrierName("Giao hàng nhanh");
                    shipOrder.setShippingFee(payload.getShippingFee() != null ? payload.getShippingFee() : 0);
                    shipOrder.setStatus(payload.getShippingStatus() != null ? payload.getShippingStatus() : "Chuẩn bị đơn hàng");
                    shipOrder.setEstimatedDeliveryDate(Timestamp.valueOf(LocalDateTime.now().plusDays(3)));
                    shipOrderDAO.save(shipOrder);

                    Payment payment = new Payment();
                    payment.setOrderId(orderId);
                    payment.setPayStrategy(payload.getPaymentMethod() != null ? payload.getPaymentMethod() : "COD");
                    payment.setStatus("Chưa thanh toán");
                    payment.setAmount(total);
                    paymentDAO.save(payment);

                    writeJson(response, HttpServletResponse.SC_OK, Map.of(
                            "success", true,
                            "message", "Đã tạo đơn hàng thành công",
                            "orderId", orderId));
                }
            } else if ("/admin/submit-order".equals(path)) {
                String customerName = request.getParameter("customerName");
                String customerPhone = request.getParameter("customerPhone");
                String customerEmail = request.getParameter("customerEmail");
                String customerAddress = request.getParameter("customerAddress");
                String orderNote = request.getParameter("orderNote");
                String paymentMethod = request.getParameter("paymentMethod");
                String cartDataJson = request.getParameter("cartData");

                if (customerName == null || customerName.trim().isEmpty() ||
                        customerPhone == null || customerPhone.trim().isEmpty() ||
                        customerAddress == null || customerAddress.trim().isEmpty()) {
                    request.getSession().setAttribute("errorMessage", "Vui lòng điền đầy đủ thông tin khách hàng!");
                    response.sendRedirect(request.getContextPath() + "/admin/create-order");
                    return;
                }

                if (cartDataJson == null || cartDataJson.trim().isEmpty() || "[]".equals(cartDataJson.trim())) {
                    request.getSession().setAttribute("errorMessage", "Vui lòng chọn ít nhất một sản phẩm!");
                    response.sendRedirect(request.getContextPath() + "/admin/create-order");
                    return;
                }

                List<Map<String, Object>> cartItems = gson.fromJson(cartDataJson,
                        new TypeToken<List<Map<String, Object>>>() {
                        }.getType());

                if (cartItems == null || cartItems.isEmpty()) {
                    request.getSession().setAttribute("errorMessage", "Giỏ hàng trống!");
                    response.sendRedirect(request.getContextPath() + "/admin/create-order");
                    return;
                }

                int userId = 1;
                String verifiedUserIdStr = request.getParameter("verifiedUserId");
                if (verifiedUserIdStr != null && !verifiedUserIdStr.trim().isEmpty()) {
                    try {
                        userId = Integer.parseInt(verifiedUserIdStr.trim());
                    } catch (NumberFormatException e) {
                        // Ignore invalid IDs
                    }
                } else if (customerEmail != null && !customerEmail.trim().isEmpty()) {
                    User existingUser = userDAO.findByEmail(customerEmail.trim());
                    if (existingUser != null) {
                        userId = existingUser.getId();
                    }
                } else if (customerPhone != null && !customerPhone.trim().isEmpty()) {
                    User existingUser = userDAO.findByPhoneNumber(customerPhone.trim());
                    if (existingUser != null) {
                        userId = existingUser.getId();
                    }
                }

                Address address = new Address();
                address.setUserId(userId);
                address.setFullName(customerName.trim());
                address.setPhoneNumber(customerPhone.trim());
                address.setAddressLine(customerAddress.trim());
                address.setCity(""); 
                address.setWard("");
                address.setDefault(false);

                addressDAO.save(address);
                List<Address> userAddresses = addressDAO.getByUserID(userId);
                int addressId = userAddresses.isEmpty() ? 1 : userAddresses.get(userAddresses.size() - 1).getId();

                double totalPrice = 0;
                for (Map<String, Object> item : cartItems) {
                    double unitPrice = ((Number) item.get("unitPrice")).doubleValue();
                    int quantity = ((Number) item.get("quantity")).intValue();
                    totalPrice += unitPrice * quantity;
                }

                Order order = new Order();
                order.setUserId(userId);
                order.setShippingAddressId(addressId);
                order.setTotalPrice(totalPrice);
                order.setCreateAt(Timestamp.valueOf(LocalDateTime.now()));
                order.setUpdateAt(Timestamp.valueOf(LocalDateTime.now()));
                order.setDelete(false);

                String noteContent = "";
                if (customerEmail != null && !customerEmail.trim().isEmpty()) {
                    noteContent = "EMAIL:" + customerEmail.trim();
                }
                if (orderNote != null && !orderNote.trim().isEmpty()) {
                    if (!noteContent.isEmpty()) {
                        noteContent += " | Ghi chú: " + orderNote.trim();
                    } else {
                        noteContent = orderNote.trim();
                    }
                }
                order.setNote(noteContent);

                int orderId = orderDAO.createAndReturnId(order);

                if (orderId > 0) {
                    for (Map<String, Object> item : cartItems) {
                        String productId = (String) item.get("productId");
                        double unitPrice = ((Number) item.get("unitPrice")).doubleValue();
                        int quantity = ((Number) item.get("quantity")).intValue();

                        OrderItem orderItem = new OrderItem();
                        orderItem.setOrderId(orderId);
                        orderItem.setProductId(productId);
                        orderItem.setQuantity(quantity);
                        orderItem.setUnitPrice(unitPrice);

                        orderItemDAO.save(orderItem);
                    }

                    ShipOrder shipOrder = new ShipOrder();
                    shipOrder.setOrderId(orderId);
                    shipOrder.setStatus("Chờ xác nhận");
                    shipOrder.setCarrierName("Giao hàng nhanh");
                    shipOrder.setShippingFee(0);
                    shipOrder.setEstimatedDeliveryDate(Timestamp.valueOf(LocalDateTime.now().plusDays(3)));

                    shipOrderDAO.save(shipOrder);

                    request.getSession().setAttribute("successMessage",
                            "Tạo đơn hàng #" + orderId + " thành công!");
                    response.sendRedirect(request.getContextPath() + "/admin/manage-orders");
                } else {
                    throw new Exception("Không thể tạo đơn hàng");
                }
            }
            else if ("/admin/edit-order".equals(path)) {

                int orderId = Integer.parseInt(request.getParameter("orderId"));
                String note = request.getParameter("note");
                String carrierName = request.getParameter("carrierName");
                String shippingFeeStr = request.getParameter("shippingFee");
                String itemsJson = request.getParameter("items");

                Order order = orderDAO.findById(orderId);
                if (order == null) {
                    request.setAttribute("errorMessage", "Không tìm thấy đơn hàng #" + orderId);
                    List<OrderViewModel> orders = orderDAO.getAllOrdersWithStatus();
                    request.setAttribute("orders", orders);
                    request.getRequestDispatcher("/admin/manage_orders.jsp").forward(request, response);
                    return;
                }

                if (note != null) {
                    order.setNote(note);
                }
                order.setUpdateAt(Timestamp.valueOf(LocalDateTime.now()));

                if (itemsJson != null && !itemsJson.trim().isEmpty()) {
                    List<Map<String, Object>> items = gson.fromJson(itemsJson,
                            new TypeToken<List<Map<String, Object>>>() {}.getType());

                    if (items != null && !items.isEmpty()) {
                        orderItemDAO.deleteByOrderId(orderId);
                        double newTotal = 0;

                        for (Map<String, Object> item : items) {
                            String productId = (String) item.get("productId");
                            int quantity = ((Number) item.get("quantity")).intValue();
                            double unitPrice = ((Number) item.get("unitPrice")).doubleValue();

                            OrderItem orderItem = new OrderItem();
                            orderItem.setOrderId(orderId);
                            orderItem.setProductId(productId);
                            orderItem.setQuantity(quantity);
                            orderItem.setUnitPrice(unitPrice);
                            orderItemDAO.save(orderItem);

                            newTotal += unitPrice * quantity;
                        }
                        order.setTotalPrice(newTotal);
                    }
                }

                orderDAO.save(order);

                if (carrierName != null || shippingFeeStr != null) {
                    ShipOrder shipOrder = shipOrderDAO.getByOrderId(orderId);
                    if (shipOrder != null) {
                        if (carrierName != null) shipOrder.setCarrierName(carrierName);
                        if (shippingFeeStr != null) {
                            try { shipOrder.setShippingFee(Double.parseDouble(shippingFeeStr)); }
                            catch (NumberFormatException ignored) {}
                        }
                        shipOrderDAO.save(shipOrder);
                    }
                }

                request.setAttribute("successMessage", "Cập nhật đơn hàng #" + orderId + " thành công!");
                List<OrderViewModel> orders = orderDAO.getAllOrdersWithStatus();
                request.setAttribute("orders", orders);
                request.getRequestDispatcher("/admin/manage_orders.jsp").forward(request, response);
            }
            else if ("/admin/refund-order".equals(path)) {

                int orderId = Integer.parseInt(request.getParameter("orderId"));
                String refundReason = request.getParameter("reason");

                Map<String, Object> orderInfo = orderDAO.getOrderInfo(orderId);
                if (orderInfo == null) {
                    request.setAttribute("errorMessage", "Không tìm thấy đơn hàng!");
                    List<OrderViewModel> orders = orderDAO.getAllOrdersWithStatus();
                    request.setAttribute("orders", orders);
                    request.getRequestDispatcher("/admin/manage_orders.jsp").forward(request, response);
                    return;
                }

                Payment payment = paymentDAO.findByOrderId(orderId);
                if (payment == null) {
                    request.setAttribute("errorMessage", "Đơn hàng chưa có thông tin thanh toán!");
                    List<OrderViewModel> orders = orderDAO.getAllOrdersWithStatus();
                    request.setAttribute("orders", orders);
                    request.getRequestDispatcher("/admin/manage_orders.jsp").forward(request, response);
                    return;
                }

                String payMethod = payment.getPayStrategy();
                String currentPayStatus = payment.getStatus();

                if (!"Đã thanh toán".equalsIgnoreCase(currentPayStatus)
                        && !"Success".equalsIgnoreCase(currentPayStatus)
                        && !"Completed".equalsIgnoreCase(currentPayStatus)) {
                    request.setAttribute("errorMessage", "Đơn hàng chưa được thanh toán hoặc đã hoàn tiền. Trạng thái hiện tại: " + currentPayStatus);
                    List<OrderViewModel> orders = orderDAO.getAllOrdersWithStatus();
                    request.setAttribute("orders", orders);
                    request.getRequestDispatcher("/admin/manage_orders.jsp").forward(request, response);
                    return;
                }

                paymentDAO.updateStatusByOrderId(orderId, "Đã hoàn tiền");

                shipOrderDAO.updateStatus(orderId, "Đã hủy");
                String userEmail = orderInfo.get("email") != null ? orderInfo.get("email").toString() : null;
                if (userEmail != null && !userEmail.isEmpty()) {
                    final String email = userEmail;
                    final int fOrderId = orderId;
                    final double amount = payment.getAmount();
                    final String reason = refundReason != null ? refundReason : "Không có lý do cụ thể";
                    final String method = payMethod;

                    java.util.concurrent.CompletableFuture.runAsync(() -> {
                        emailServices.sendRefundEmail(email, fOrderId, amount, reason, method);
                    });
                }

                request.setAttribute("successMessage", "Hoàn tiền đơn hàng #" + orderId + " thành công! Email thông báo đã được gửi.");
                List<OrderViewModel> orders = orderDAO.getAllOrdersWithStatus();
                request.setAttribute("orders", orders);
                request.getRequestDispatcher("/admin/manage_orders.jsp").forward(request, response);
            }

            else if ("/admin/send-feedback".equals(path)) {

                int orderId = Integer.parseInt(request.getParameter("orderId"));
                String feedbackContent = request.getParameter("content");
                String feedbackSubject = request.getParameter("subject");

                if (feedbackContent == null || feedbackContent.trim().isEmpty()) {
                    request.setAttribute("errorMessage", "Nội dung phản hồi không được để trống!");
                    List<OrderViewModel> orders = orderDAO.getAllOrdersWithStatus();
                    request.setAttribute("orders", orders);
                    request.getRequestDispatcher("/admin/manage_orders.jsp").forward(request, response);
                    return;
                }

                Map<String, Object> orderInfo = orderDAO.getOrderInfo(orderId);
                if (orderInfo == null) {
                    request.setAttribute("errorMessage", "Không tìm thấy đơn hàng!");
                    List<OrderViewModel> orders = orderDAO.getAllOrdersWithStatus();
                    request.setAttribute("orders", orders);
                    request.getRequestDispatcher("/admin/manage_orders.jsp").forward(request, response);
                    return;
                }

                String userEmail = orderInfo.get("email") != null ? orderInfo.get("email").toString() : null;
                if (userEmail == null || userEmail.isEmpty()) {
                    request.setAttribute("errorMessage", "Không tìm thấy email người dùng!");
                    List<OrderViewModel> orders = orderDAO.getAllOrdersWithStatus();
                    request.setAttribute("orders", orders);
                    request.getRequestDispatcher("/admin/manage_orders.jsp").forward(request, response);
                    return;
                }

                User adminUser = (User) request.getSession().getAttribute("user");
                String adminName = adminUser != null && adminUser.getFullName() != null
                        ? adminUser.getFullName() : "Admin";

                final String email = userEmail;
                final int fOrderId = orderId;
                final String content = feedbackContent.trim();
                final String subject = feedbackSubject != null ? feedbackSubject.trim() : "Phản hồi về đơn hàng";
                final String fAdminName = adminName;

                java.util.concurrent.CompletableFuture.runAsync(() -> {
                    emailServices.sendAdminFeedbackEmail(email, fOrderId, subject, content, fAdminName);
                });

                request.setAttribute("successMessage", "Đã gửi phản hồi tới " + userEmail + " thành công!");
                List<OrderViewModel> orders = orderDAO.getAllOrdersWithStatus();
                request.setAttribute("orders", orders);
                request.getRequestDispatcher("/admin/manage_orders.jsp").forward(request, response);
            }

        } catch (Exception e) {
            e.printStackTrace();
            if ("/admin/delete-order".equals(path) || "/admin/api/orders".equals(path)
                    || "/admin/add-order".equals(path) || "/admin/edit-order".equals(path)
                    || "/admin/refund-order".equals(path) || "/admin/send-feedback".equals(path)) {
                response.setContentType("application/json");
                response.getWriter().print("{\"success\": false, \"message\": \"Lỗi server: " + e.getMessage() + "\"}");
            } else if ("/admin/submit-order".equals(path)) {
                request.getSession().setAttribute("errorMessage", "Có lỗi xảy ra khi tạo đơn hàng: " + e.getMessage());
                response.sendRedirect(request.getContextPath() + "/admin/create-order");
            } else {
                request.getSession().setAttribute("errorMessage", "Lỗi server!");
                response.sendRedirect(request.getContextPath() + "/admin/manage-orders");
            }
        }
    }

    private int resolveUserId(CreateOrderRequest payload) {
        if (payload.getUserId() != null) {
            return payload.getUserId();
        }
        User found = null;
        if (payload.getCustomerEmail() != null && !payload.getCustomerEmail().isBlank()) {
            found = userDAO.findByEmail(payload.getCustomerEmail().trim());
        }
        if (found == null && payload.getCustomerPhone() != null && !payload.getCustomerPhone().isBlank()) {
            found = userDAO.findByPhoneNumber(payload.getCustomerPhone().trim());
        }
        return found != null ? found.getId() : 1;
    }

    private void writeJson(HttpServletResponse response, int status, Map<String, ?> payload) throws IOException {
        response.setStatus(status);
        gson.toJson(payload, response.getWriter());
    }
}
