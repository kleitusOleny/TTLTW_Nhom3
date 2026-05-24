package controller.admin;

import dao.ProductIssueDAO;
import db.JdbiConnector;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.ProductIssue;
import model.User;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "ProductIssueController", value = "/product-issue-manager")
public class ProductIssueController extends HttpServlet {
    
    private final ProductIssueDAO issueDAO = JdbiConnector.get().onDemand(ProductIssueDAO.class);
    
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        List<ProductIssue> issues = issueDAO.findAllActive();
        req.setAttribute("issues", issues);
        
        req.getRequestDispatcher("admin/manage_issue.jsp").forward(req, resp);
    }
    
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");
        
        if ("create".equals(action)) {
            try {
                User user = (User) req.getSession().getAttribute("user");
                if (user == null) {
                    resp.sendRedirect("login");
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
                
                resp.sendRedirect("product-issue-manager?success");
            } catch (Exception e) {
                e.printStackTrace();
                resp.sendRedirect("product-issue-manager?error");
            }
        }
    }
}