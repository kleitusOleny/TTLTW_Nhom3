package controller.admin;

import dao.DiscountProcessDAO;
import dao.ProductDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

@WebServlet(name = "AdminApplyDiscountController", urlPatterns = {"/admin/apply-discount"})
public class AdminApplyDiscountController extends HttpServlet {
    private ProductDAO productDAO;
    private DiscountProcessDAO discountProcessDAO;

    @Override
    public void init() {
        productDAO = new ProductDAO();
        discountProcessDAO = new DiscountProcessDAO();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        try {
            int discountId = Integer.parseInt(request.getParameter("discountId"));
            String applyType = request.getParameter("applyType");

            List<String> productIds = new ArrayList<>();

            if ("PRODUCT".equals(applyType)) {
                String[] ids = request.getParameterValues("productIds");
                if (ids != null) {
                    productIds.addAll(Arrays.asList(ids));
                }
                productIds = productDAO.filterExistingProductIds(productIds);

            } else if ("CATEGORY".equals(applyType)) {
                String[] categoryIds = request.getParameterValues("categoryIds");
                if (categoryIds != null) {
                    productIds = productDAO.getProductIdsByCategoryIds(Arrays.asList(categoryIds));
                }

            } else if ("MANUFACTURER".equals(applyType)) {
                String[] manufacturerIds = request.getParameterValues("manufacturerIds");
                if (manufacturerIds != null) {
                    productIds = productDAO.getProductIdsByManufacturerIds(Arrays.asList(manufacturerIds));
                }
            }

            if (productIds.isEmpty()) {
                response.getWriter().write("{\"success\":false,\"message\":\"Không tìm thấy sản phẩm nào để áp dụng.\"}");
                return;
            }

            DiscountProcessDAO.ApplyResult result = discountProcessDAO.applyDiscountToProducts(discountId, productIds);

            String message = "Đã áp dụng mã giảm giá cho " + productIds.size() + " sản phẩm"
                    + " (Mới: " + result.getInserted() + ", Kích hoạt lại: " + result.getReactivated() + ")";

            response.getWriter().write("{\"success\":true,\"message\":\"" + escapeJson(message) + "\"}");

        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"success\":false,\"message\":\"Dữ liệu không hợp lệ.\"}");
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"success\":false,\"message\":\"Lỗi server: " + escapeJson(e.getMessage()) + "\"}");
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
