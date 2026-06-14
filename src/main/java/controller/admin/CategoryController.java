package controller.admin;

import dao.CategoryDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Category;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "CategoryController", urlPatterns = {
        "/category-manager",
        "/category-manager/add",
        "/category-manager/edit",
        "/category-manager/delete"
})
public class CategoryController extends HttpServlet {
    
    CategoryDAO categoryDAO = new CategoryDAO();
    
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        // Lấy danh sách danh mục
        List<Category> list = categoryDAO.getAllCategories();
        req.setAttribute("categories", list);
        
        // Chuyển hướng sang trang JSP
        req.getRequestDispatcher("admin/manage_category.jsp").forward(req, resp);
    }
    
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String action = req.getParameter("action");
        if (action == null || action.trim().isEmpty()) {
            String path = req.getServletPath();
            if (path.endsWith("/add")) action = "add";
            else if (path.endsWith("/edit")) action = "edit";
            else if (path.endsWith("/delete")) action = "delete";
        }
        
        try {
            if ("add".equals(action)) {
                String name = req.getParameter("name");
                String slug = req.getParameter("slug");
                
                Category c = new Category();
//            c.setId(UUID.randomUUID().toString().substring(0, 8));
                c.setCategoryName(name);
                c.setSlug(slug);
                
                categoryDAO.insert(c);
            } else if ("delete".equals(action)) {
                String id = req.getParameter("id");
                categoryDAO.delete(id);
            } else if ("edit".equals(action)) { // Xử lý hành động Sửa
                String idStr = req.getParameter("id");
                String name = req.getParameter("name");
                String slug = req.getParameter("slug");
                
                if (idStr != null && !idStr.isEmpty()) {
                    Category c = new Category();
                    c.setId(String.valueOf(Integer.parseInt(idStr))); // Chuyển String sang int
                    c.setCategoryName(name);
                    c.setSlug(slug);
                    
                    categoryDAO.update(c); // Gọi hàm update bên DAO
                }
            }
        }catch (Exception e){
            e.printStackTrace();
        }
        resp.sendRedirect(req.getContextPath() + "/category-manager");
    }
}