package controller.admin;

import dao.CategoryDAO;
import dao.DiscountDAO;
import dao.ManufacturerDAO;
import dao.ProductDAO;
import model.Category;
import model.Discount;
import model.Manufacturer;
import model.Product;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;
import java.util.Optional;

@WebServlet(name = "AdminDiscountController", urlPatterns = {
        "/admin/manage-promotions",
        "/admin/get-promotion",
        "/admin/delete-promotion",
        "/admin/update-promotion",
        "/admin/add-promotion"
})
public class AdminDiscountController extends HttpServlet {
    private DiscountDAO discountDAO;
    private ProductDAO productDAO;
    private ManufacturerDAO manufacturerDAO;
    private CategoryDAO categoryDAO;

    @Override
    public void init() {
        discountDAO = new DiscountDAO();
        productDAO = new ProductDAO();
        manufacturerDAO = new ManufacturerDAO();
        categoryDAO = new CategoryDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();
        if ("/admin/get-promotion".equals(path)) {
            handleGetPromotion(request, response);
        } else {
            handleList(request, response);
        }
    }

    private void handleList(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            List<Discount> discounts = discountDAO.findAll();
            request.setAttribute("discounts", discounts);

            List<Category> categories = categoryDAO.getAllCategories();
            List<Product> products = productDAO.listProduct();
            List<Manufacturer> manufacturers = manufacturerDAO.getAllManufacturers();

            request.setAttribute("categories", categories);
            request.setAttribute("products", products);
            request.setAttribute("manufacturers", manufacturers);

            String errorMessage = (String) request.getSession().getAttribute("errorMessage");
            if (errorMessage != null) {
                request.setAttribute("errorMessage", errorMessage);
                request.getSession().removeAttribute("errorMessage");
            }

            request.getRequestDispatcher("/admin/manage_promotions.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Unable to load promotions");
        }
    }

    private void handleGetPromotion(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            int id = Integer.parseInt(request.getParameter("id"));
            Optional<Discount> optDiscount = discountDAO.findByIdAdmin(id);
            if (optDiscount.isPresent()) {
                Discount discount = optDiscount.get();
                request.setAttribute("discountEdit", discount);
                request.setAttribute("discounts", discountDAO.findAll());
                request.getRequestDispatcher("/admin/manage_promotions.jsp").forward(request, response);
            } else {
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();
        if ("/admin/delete-promotion".equals(path)) {
            handleDelete(request, response);
        } else if ("/admin/update-promotion".equals(path)) {
            handleUpdate(request, response);
        } else if ("/admin/add-promotion".equals(path)) {
            handleAdd(request, response);
        } else {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    private void handleAdd(HttpServletRequest request, HttpServletResponse response) throws IOException {
        try {
            Discount discount = new Discount();
            discount.setDiscountCode(request.getParameter("code_add"));
            discount.setQuantity(Integer.parseInt(request.getParameter("quantity_add")));
            discount.setDiscountType(request.getParameter("type_add"));
            discount.setDiscountValue(Double.parseDouble(request.getParameter("value_add")));
            discount.setApplyType(request.getParameter("apply_type_add"));

            String status = request.getParameter("status_add");
            discount.setActive("Hoạt động".equals(status));
            discount.setIsDelete(false);

            java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("yyyy-MM-dd");
            java.util.Date startDate = sdf.parse(request.getParameter("start_add"));
            java.util.Date endDate = sdf.parse(request.getParameter("end_add"));
            discount.setDiscountFrom(new java.sql.Timestamp(startDate.getTime()));
            discount.setDiscountTo(new java.sql.Timestamp(endDate.getTime()));

            java.sql.Timestamp now = new java.sql.Timestamp(System.currentTimeMillis());
            discount.setCreateAt(now);
            discount.setUpdateAt(now);

            discountDAO.save(discount);
            response.sendRedirect(request.getContextPath() + "/admin/manage-promotions?success=AddSuccess");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/admin/manage-promotions?error=AddFailed");
        }
    }

    private void handleUpdate(HttpServletRequest request, HttpServletResponse response) throws IOException {
        try {
            int id = Integer.parseInt(request.getParameter("id"));
            Optional<Discount> optDiscount = discountDAO.findByIdAdmin(id);
            if (!optDiscount.isPresent()) {
                response.sendRedirect(request.getContextPath() + "/admin/manage-promotions?error=NotFound");
                return;
            }
            Discount discount = optDiscount.get();
            discount.setDiscountCode(request.getParameter("code_edit"));
            discount.setQuantity(Integer.parseInt(request.getParameter("quantity_edit")));
            discount.setDiscountType(request.getParameter("type_edit"));
            discount.setDiscountValue(Double.parseDouble(request.getParameter("value_edit")));
            discount.setApplyType(request.getParameter("apply_type_edit"));

            String status = request.getParameter("status_edit");
            if ("Đã ẩn".equals(status)) {
                discount.setActive(false);
                discount.setIsDelete(true);
            } else if ("Đã khóa".equals(status)) {
                discount.setActive(false);
                discount.setIsDelete(false);
            } else {
                discount.setActive(true);
                discount.setIsDelete(false);
            }

            java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("yyyy-MM-dd");
            java.util.Date startDate = sdf.parse(request.getParameter("start_edit"));
            java.util.Date endDate = sdf.parse(request.getParameter("end_edit"));
            discount.setDiscountFrom(new java.sql.Timestamp(startDate.getTime()));
            discount.setDiscountTo(new java.sql.Timestamp(endDate.getTime()));
            discount.setUpdateAt(new java.sql.Timestamp(System.currentTimeMillis()));

            discountDAO.save(discount);
            response.sendRedirect(request.getContextPath() + "/admin/manage-promotions?success=UpdateSuccess");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/admin/manage-promotions?error=UpdateFailed");
        }
    }

    private void handleDelete(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        try {
            String idParam = request.getParameter("id");
            int id = Integer.parseInt(idParam);
            boolean success = discountDAO.deleteById(id); // soft‑delete
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            response.getWriter().write("{\"success\":" + success + "}");
            response.getWriter().flush();
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.setContentType("application/json");
            response.getWriter().write("{\"success\":false, \"error\":\"" + e.getMessage() + "\"}");
            response.getWriter().flush();
        }
    }
}
