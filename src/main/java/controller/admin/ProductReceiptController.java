package controller.admin;

import com.google.gson.Gson;
import dao.ManufacturerDAO;
import dao.ProductDAO;
import dao.ProductReceiptDAO;
import db.JdbiConnector;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.ProductReceipt;
import model.ProductReceiptDetail;
import model.User;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

@WebServlet(name = "ProductReceiptController", value = "/product-receipt-manager")
public class ProductReceiptController extends HttpServlet {
    
    private final ProductReceiptDAO receiptDAO = JdbiConnector.get().onDemand(ProductReceiptDAO.class);
    
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");
        if ("get-details".equals(action)) {
            try {
                int id = Integer.parseInt(req.getParameter("id"));
                ProductReceipt receipt = receiptDAO.getReceiptWithDetails(id);
                resp.setContentType("application/json");
                resp.setCharacterEncoding("UTF-8");
                resp.getWriter().write(new Gson().toJson(receipt));
            } catch (Exception e) {
                e.printStackTrace();
                resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid receipt ID");
            }
            return;
        }

        // Lấy danh sách toàn bộ phiếu nhập kho chưa bị xóa mềm
        List<ProductReceipt> receipts = receiptDAO.findAllActive();
        req.setAttribute("receipts", receipts);
        
        // Lấy danh sách nhà sản xuất làm nhà cung cấp
        req.setAttribute("suppliers", new ManufacturerDAO().getAllManufacturers());
        
        // Lấy danh sách sản phẩm để cho phép thêm vào phiếu nhập
        req.setAttribute("products", new ProductDAO().listProduct());
        
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
                
                // Thu thập danh sách chi tiết sản phẩm nhập kho từ client gửi lên
                String[] productIds = req.getParameterValues("productId[]");
                String[] quantities = req.getParameterValues("quantity[]");
                String[] unitPrices = req.getParameterValues("unitPrice[]");
                
                List<ProductReceiptDetail> details = new ArrayList<>();
                BigDecimal totalAmount = BigDecimal.ZERO;
                
                if (productIds != null) {
                    for (int i = 0; i < productIds.length; i++) {
                        String prodId = productIds[i];
                        int qty = Integer.parseInt(quantities[i]);
                        BigDecimal price = new BigDecimal(unitPrices[i]);
                        
                        ProductReceiptDetail detail = new ProductReceiptDetail();
                        detail.setProductId(prodId);
                        detail.setQuantity(qty);
                        detail.setUnitPrice(price);
                        details.add(detail);
                        
                        totalAmount = totalAmount.add(price.multiply(BigDecimal.valueOf(qty)));
                    }
                }
                
                receipt.setDetails(details);
                receipt.setTotalAmount(totalAmount);
                
                // Gọi xử lý transaction lưu phiếu nhập và tăng số lượng kho
                receiptDAO.processReceipt(receipt);
                
                resp.sendRedirect("product-receipt-manager?success");
            } catch (Exception e) {
                e.printStackTrace();
                resp.sendRedirect("product-receipt-manager?error");
            }
        }
    }
}