package controller.admin;

import com.google.gson.Gson;
import dao.ProductDAO;
import dao.ProductIssueDAO;
import db.JdbiConnector;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.ProductIssue;
import model.ProductIssueDetail;
import model.User;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

@WebServlet(name = "ProductIssueController", urlPatterns = {
        "/product-issue-manager",
        "/product-issue-manager/get-details",
        "/product-issue-manager/create"
})
public class ProductIssueController extends HttpServlet {
    
    private final ProductIssueDAO issueDAO = JdbiConnector.get().onDemand(ProductIssueDAO.class);
    
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");
        if (action == null || action.trim().isEmpty()) {
            String path = req.getServletPath();
            if (path.endsWith("/get-details")) action = "get-details";
            else if (path.endsWith("/create")) action = "create";
        }
        if ("get-details".equals(action)) {
            try {
                int id = Integer.parseInt(req.getParameter("id"));
                ProductIssue issue = issueDAO.getIssueWithDetails(id);
                resp.setContentType("application/json");
                resp.setCharacterEncoding("UTF-8");
                resp.getWriter().write(new Gson().toJson(issue));
            } catch (Exception e) {
                e.printStackTrace();
                resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid issue ID");
            }
            return;
        }

        List<ProductIssue> issues = issueDAO.findAllActive();
        req.setAttribute("issues", issues);
        
        req.setAttribute("products", new ProductDAO().listProduct());
        
        req.getRequestDispatcher("admin/manage_issue.jsp").forward(req, resp);
    }
    
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");
        if (action == null || action.trim().isEmpty()) {
            String path = req.getServletPath();
            if (path.endsWith("/get-details")) action = "get-details";
            else if (path.endsWith("/create")) action = "create";
        }
        
        if ("create".equals(action)) {
            try {
                User user = (User) req.getSession().getAttribute("user");
                if (user == null) {
                    resp.sendRedirect(req.getContextPath() + "/login");
                    return;
                }
                
                ProductIssue issue = new ProductIssue();
                issue.setUserId(user.getId());
                
                String orderIdStr = req.getParameter("orderId");
                if (orderIdStr != null && !orderIdStr.isEmpty()) {
                    issue.setOrderId(Integer.parseInt(orderIdStr));
                }
                
                issue.setReason(req.getParameter("reason"));
                issue.setNote(req.getParameter("note"));
                
                // Thu thập danh sách chi tiết sản phẩm xuất kho từ client gửi lên
                String[] productIds = req.getParameterValues("productId[]");
                String[] quantities = req.getParameterValues("quantity[]");
                
                List<ProductIssueDetail> details = new ArrayList<>();
                if (productIds != null) {
                    for (int i = 0; i < productIds.length; i++) {
                        String prodId = productIds[i];
                        int qty = Integer.parseInt(quantities[i]);
                        
                        ProductIssueDetail detail = new ProductIssueDetail();
                        detail.setProductId(prodId);
                        detail.setQuantity(qty);
                        details.add(detail);
                    }
                }
                issue.setDetails(details);
                
                // Gọi xử lý transaction lưu phiếu xuất và giảm số lượng kho
                issueDAO.processIssue(issue);
                
                resp.sendRedirect(req.getContextPath() + "/product-issue-manager?success");
            } catch (Exception e) {
                e.printStackTrace();
                resp.sendRedirect(req.getContextPath() + "/product-issue-manager?error=" + java.net.URLEncoder.encode(e.getMessage(), "UTF-8"));
            }
        }
    }
}