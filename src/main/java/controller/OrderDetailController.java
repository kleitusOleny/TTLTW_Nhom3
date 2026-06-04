package controller;

import dao.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.*;
import services.ProductService;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@WebServlet(name = "OrderDetailController", value = "/order-detail")
public class OrderDetailController extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        if (user == null) {
            response.sendRedirect("login");
            return;
        }

        String orderIdStr = request.getParameter("id");
        if (orderIdStr == null || orderIdStr.isEmpty()) {
            response.sendRedirect("orders");
            return;
        }

        try {
            int orderId = Integer.parseInt(orderIdStr);
            OrderDAO orderDAO = new OrderDAO();
            Order order = orderDAO.findById(orderId);

            if (order == null) {
                response.sendRedirect("orders");
                return;
            }

            if (order.getUserId() != user.getId()) {
                response.sendRedirect("orders");
                return;
            }

            OrderItemDAO orderItemDAO = new OrderItemDAO();
            List<OrderItem> items = orderItemDAO.getByOrderId(orderId);
            order.setItems(items);

            ProductService productService = new ProductService();
            Map<String, Product> productMap = new HashMap<>();
            for (OrderItem item : items) {
                Product product = productService.getProduct(item.getProductId());
                if (product == null) {
                } else {
                    productMap.put(item.getProductId(), product);
                }
            }

            request.setAttribute("order", order);
            request.setAttribute("productMap", productMap);

            AddressDAO addressDAO = new AddressDAO();
            Optional<Address> shippingAddressOpt = addressDAO.findById(order.getShippingAddressId());
            request.setAttribute("shippingAddress", shippingAddressOpt.orElse(null));

            PaymentDAO paymentDAO = new PaymentDAO();
           Payment payment = paymentDAO.findByOrderId(orderId);
            request.setAttribute("payment", payment);

            ShipOrderDAO shipOrderDAO = new ShipOrderDAO();
            ShipOrder shipOrder = shipOrderDAO.getByOrderId(orderId);
            request.setAttribute("shipOrder", shipOrder);

            request.getRequestDispatcher("info_users/detail_order.jsp").forward(request, response);

        } catch (NumberFormatException e) {
            response.sendRedirect("orders");
        } catch (Exception e) {
            e.printStackTrace();
            throw e;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        if ("reorder".equals(action)) {
            HttpSession session = request.getSession();
            User user = (User) session.getAttribute("user");
            if (user == null) {
                response.sendRedirect("login");
                return;
            }
            try {
                int orderId = Integer.parseInt(request.getParameter("orderId"));
                OrderItemDAO orderItemDAO = new OrderItemDAO();
                List<OrderItem> items = orderItemDAO.getByOrderId(orderId);
                ProductService productService = new ProductService();
                Cart buyNowCart = new Cart();
                for (OrderItem item : items) {
                    Product product = productService.getProduct(item.getProductId());
                    if (product != null && product.getQuantity() > 0) {
                        int qty = Math.min(item.getQuantity(), product.getQuantity());
                        buyNowCart.addItem(product, qty);
                    }
                }
                if (!buyNowCart.getItems().isEmpty()) {
                    session.setAttribute("buyNowCart", buyNowCart);
                    response.sendRedirect("checkout?from=buyNow");
                } else {
                    session.setAttribute("errorMessage", "Tất cả sản phẩm trong đơn hàng này đã hết hàng.");
                    response.sendRedirect("order-detail?id=" + orderId);
                }
            } catch (Exception e) {
                e.printStackTrace();
                response.sendRedirect("orders");
            }
        }
    }
}