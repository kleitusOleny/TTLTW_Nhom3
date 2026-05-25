package controller.admin;

import dao.ProductReceiptDAO;
import db.JdbiConnector;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.ProductReceipt;
import model.User;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "ProductReceiptController", value = "/product-receipt-manager")
public class ProductReceiptController extends HttpServlet {
    
    // Khởi tạo DAO theo pattern hiện tại của dự án
    private final ProductReceiptDAO receiptDAO = JdbiConnector.get().onDemand(ProductReceiptDAO.class);;
    
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // Lấy danh sách toàn bộ phiếu nhập kho chưa bị xóa mềm
        List<ProductReceipt> receipts = receiptDAO.findAllActive();
        req.setAttribute("receipts", receipts);
        
        // Chuyển hướng đến trang hiển thị giao diện quản lý nhập kho
        req.getRequestDispatcher("admin/manage_receipt.jsp").forward(req, resp);
    }
    
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");
        
        if ("create".equals(action)) {
            try {
                // Lấy thông tin user hiện tại từ session
                User user = (User) req.getSession().getAttribute("user");
                if (user == null) {
                    resp.sendRedirect("login");
                    return;
                }
                
                ProductReceipt receipt = new ProductReceipt();
                receipt.setUserId(user.getId());
                
                String supplierIdStr = req.getParameter("supplierId");
                if (supplierIdStr != null && !supplierIdStr.isEmpty()) {
                    receipt.setSupplierId(Integer.parseInt(supplierIdStr));
                }
                
                receipt.setNote(req.getParameter("note"));
                
                // Thu thập danh sách chi tiết sản phẩm nhập kho từ client gửi lên và gọi xử lý transaction
                // receiptDAO.processReceipt(receipt);
                
                resp.sendRedirect("product-receipt-manager?success");
            } catch (Exception e) {
                e.printStackTrace();
                resp.sendRedirect("product-receipt-manager?error");
            }
        }
    }
}