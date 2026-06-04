package controller;

import dao.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.*;

import java.io.IOException;
import java.util.*;

import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.http.Part;

import java.io.File;
import java.nio.file.Paths;

@WebServlet(name = "EvaluateController", value = "/evaluate")
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024 * 2,
        maxFileSize = 1024 * 1024 * 10,
        maxRequestSize = 1024 * 1024 * 50
)
public class EvaluateController extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null) {
            response.sendRedirect("login");
            return;
        }

        String orderIdStr = request.getParameter("orderId");
        if (orderIdStr == null) {
            response.sendRedirect("orders");
            return;
        }

        try {
            int orderId = Integer.parseInt(orderIdStr);
            OrderDAO orderDAO = new OrderDAO();
            Order order = orderDAO.findById(orderId);

            if (order == null || order.getUserId() != user.getId()) {
                response.sendRedirect("orders");
                return;
            }

            String success = request.getParameter("success");
            if (success == null) {
                String referer = request.getHeader("Referer");
                if (referer != null) {
                    session.setAttribute("evalReturnUrl_" + orderId, referer);
                }
            }
            String returnUrl = (String) session.getAttribute("evalReturnUrl_" + orderId);
            if (returnUrl == null) {
                returnUrl = "orders";
            }

            OrderItemDAO orderItemDAO = new OrderItemDAO();
            List<OrderItem> items = orderItemDAO.getByOrderId(orderId);

            ProductDAO productDAO = new ProductDAO();
            Map<String, Product> productMap = new HashMap<>();
            for (OrderItem item : items) {
                Product p = productDAO.getProductById(item.getProductId());
                if (p != null) {
                    productMap.put(item.getProductId(), p);
                }
            }

            Set<String> evaluatedProducts = (Set<String>) session.getAttribute("evalOrder_" + orderId);
            if (evaluatedProducts == null) {
                evaluatedProducts = new HashSet<>();
            }
            
            EvaluateDAO evaluateDAO = new EvaluateDAO();
            List<Evaluates> userEvaluatesList = evaluateDAO.getByUserId(user.getId());
            for (Evaluates e : userEvaluatesList) {
                evaluatedProducts.add(e.getId());
            }

            if (order.isEvaluated()) {
                for (OrderItem item : items) {
                    evaluatedProducts.add(item.getProductId());
                }
            }
            
            boolean allEvaluated = true;
            for (OrderItem item : items) {
                if (!evaluatedProducts.contains(item.getProductId())) {
                    allEvaluated = false;
                    break;
                }
            }
            if (allEvaluated && !order.isEvaluated()) {
                orderDAO.updateEvaluatedStatus(orderId, true);
                order.setEvaluated(true);
            }

            request.setAttribute("order", order);
            request.setAttribute("items", items);
            request.setAttribute("productMap", productMap);
            request.setAttribute("evaluatedProductIds", evaluatedProducts);
            request.setAttribute("returnUrl", returnUrl);
            request.getRequestDispatcher("info_users/evaluate.jsp").forward(request, response);

        } catch (NumberFormatException e) {
            response.sendRedirect("orders");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null) {
            response.sendRedirect("login");
            return;
        }

        String productId = request.getParameter("productId");
        String ratingStr = request.getParameter("rating");
        String content = request.getParameter("content");
        String orderId = request.getParameter("orderId");

        if (productId != null && ratingStr != null) {
            try {
                double star = Double.parseDouble(ratingStr);

                CTEvaluateDAO ctEvaluateDAO = new CTEvaluateDAO();
                CTEvaluates ctEvaluates = new CTEvaluates();
                ctEvaluates.setContent(content);
                ctEvaluates.setStar(star);
                ctEvaluates.setCreateAt(java.time.LocalDateTime.now());
                ctEvaluates.setUpdateAt(java.time.LocalDateTime.now());
                Part filePart = null;
                try {
                    filePart = request.getPart("image");
                } catch (Exception ex) {
                }

                String imagePath = utils.FileUtil.uploadImage(filePart, request, "reviews");
                ctEvaluates.setImagePath(imagePath);

                int evaluateId = ctEvaluateDAO.createAndReturnId(ctEvaluates);

                EvaluateDAO evaluateDAO = new EvaluateDAO();
                Evaluates evaluates = new Evaluates();
                evaluates.setId(productId);
                evaluates.setUserId(user.getId());
                evaluates.setEvaluatesId(evaluateId);

                evaluateDAO.save(evaluates);

            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        if (orderId != null) {
            try {
                int oId = Integer.parseInt(orderId);
                
                Set<String> evaluatedProducts = (Set<String>) session.getAttribute("evalOrder_" + oId);
                if (evaluatedProducts == null) {
                    evaluatedProducts = new HashSet<>();
                }
                if (productId != null) {
                    evaluatedProducts.add(productId);
                }
                session.setAttribute("evalOrder_" + oId, evaluatedProducts);
                
                OrderItemDAO orderItemDAO = new OrderItemDAO();
                List<OrderItem> items = orderItemDAO.getByOrderId(oId);
                
                if (evaluatedProducts.size() >= items.size()) {
                    OrderDAO orderDAO = new OrderDAO();
                    orderDAO.updateEvaluatedStatus(oId, true);
                }
                
                response.sendRedirect("evaluate?orderId=" + orderId + "&success=true");
            } catch (Exception e) {
                e.printStackTrace();
                response.sendRedirect("orders");
            }
        } else {
            response.sendRedirect("orders");
        }
    }
}
