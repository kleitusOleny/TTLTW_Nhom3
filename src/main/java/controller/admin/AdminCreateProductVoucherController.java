package controller.admin;

import dao.DiscountDAO;
import dao.DiscountProcessDAO;
import model.Discount;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.Collections;
import java.util.Date;

@WebServlet(name = "AdminCreateProductVoucherController", urlPatterns = {"/admin/create-product-voucher"})
public class AdminCreateProductVoucherController extends HttpServlet {
    private DiscountDAO discountDAO;
    private DiscountProcessDAO discountProcessDAO;

    @Override
    public void init() {
        discountDAO = new DiscountDAO();
        discountProcessDAO = new DiscountProcessDAO();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        try {
            String productIdStr = request.getParameter("productId");
            String code = request.getParameter("code");
            String quantityStr = request.getParameter("quantity");
            String type = request.getParameter("type");
            String valueStr = request.getParameter("value");
            String startStr = request.getParameter("start");
            String endStr = request.getParameter("end");

            if (productIdStr == null || code == null || quantityStr == null || type == null || valueStr == null || startStr == null || endStr == null) {
                response.getWriter().write("{\"success\":false,\"message\":\"Thiếu thông tin bắt buộc.\"}");
                return;
            }

            int quantity = Integer.parseInt(quantityStr);
            double value = Double.parseDouble(valueStr);

            Discount discount = new Discount();
            discount.setDiscountCode(code);
            discount.setQuantity(quantity);
            discount.setDiscountType(type);
            discount.setDiscountValue(value);
            discount.setApplyType("order");
            discount.setActive(true);
            discount.setIsDelete(false);

            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
            Date startDate = sdf.parse(startStr);
            Date endDate = sdf.parse(endStr);
            discount.setDiscountFrom(new Timestamp(startDate.getTime()));
            discount.setDiscountTo(new Timestamp(endDate.getTime()));

            Timestamp now = new Timestamp(System.currentTimeMillis());
            discount.setCreateAt(now);
            discount.setUpdateAt(now);

            // Save discount code
            discount = discountDAO.save(discount);

            if (discount == null || discount.getId() == null) {
                response.getWriter().write("{\"success\":false,\"message\":\"Không thể lưu mã giảm giá.\"}");
                return;
            }

            // Apply discount code to product
            discountProcessDAO.applyDiscountToProducts(discount.getId(), Collections.singletonList(productIdStr));

            response.getWriter().write("{\"success\":true,\"message\":\"Tạo và áp dụng voucher cho sản phẩm thành công!\"}");

        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"success\":false,\"message\":\"Dữ liệu số không hợp lệ.\"}");
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"success\":false,\"message\":\"Lỗi hệ thống: " + escapeJson(e.getMessage()) + "\"}");
        }
    }

    private String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r");
    }
}
