package controller;

//import dao.FavouriteDAO;
import dao.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Product;
//import model.User;
import services.ProductService;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet(name = "StoreController", value = "/store")
public class StoreController extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        ProductDAO dao = new ProductDAO();
        CategoryDAO categoryDAO = new CategoryDAO();
        ManufacturerDAO manuDAO = new ManufacturerDAO();
        TypeDAO typeDAO = new TypeDAO();
        TagDAO tagDAO = new TagDAO();
        // 1. Cấu hình phân trang
        int pageSize = 16;
        int page = 1;
        
        String pageParam = request.getParameter("page");
        if (pageParam != null && !pageParam.isEmpty()) {
            try {
                page = Integer.parseInt(pageParam);
            } catch (NumberFormatException e) {
                page = 1;
            }
        }
        
        String sort = request.getParameter("sort");
        if (sort == null) {
            sort = "default";
        }
        
        // Tính toán vị trí bắt đầu
        int offset = (page - 1) * pageSize;
        
        String promo = request.getParameter("promo");
        boolean onlyDiscounted = "true".equalsIgnoreCase(promo);

        // 2. Lấy dữ liệu
        List<Product> products;
        int totalProducts;
        if (onlyDiscounted) {
            products = dao.filterProducts(null, null, null, null, null, null, null, null, pageSize, offset, sort, true);
            totalProducts = dao.countFilteredProducts(null, null, null, null, null, null, null, null, true);
            request.setAttribute("curHeader", "promo");
            request.setAttribute("filterParams", "&promo=true");
        } else {
            products = dao.getProducts(pageSize, offset, sort);
            totalProducts = ProductService.countTotalProducts();
            request.setAttribute("curHeader", "store");
        }
        double maxPrice = dao.getMaxPrice();
        request.setAttribute("maxPrice", maxPrice > 0 ? maxPrice : 10000000);
        
        // 3. Tính tổng số trang
        int totalPages = (int) Math.ceil((double) totalProducts / pageSize);

        // 4. Load user's favorite product IDs if logged in
        HttpSession session = request.getSession(false);
        if (session != null) {
            model.User user = (model.User) session.getAttribute("user");
            if (user != null) {
                dao.FavouriteDAO favouriteDAO = new dao.FavouriteDAO();
                List<Map<String, Object>> userFavouritesList = favouriteDAO
                        .getFavouritesWithProductsByUserID(user.getId());
                request.setAttribute("userFavouritesList", userFavouritesList);
            }
        }
        
        
        request.setAttribute("currentSort", sort);
        
        // 5. Gửi dữ liệu sang JSP
        request.setAttribute("products", products);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("currentPage", page);
        request.setAttribute("categories", categoryDAO.getAllCategories());
        request.setAttribute("types", typeDAO.getAllTypes());
        request.setAttribute("manufacturers", manuDAO.getAllManufacturers());
        request.setAttribute("tags", tagDAO.getAllTags());
        request.setAttribute("origins", dao.getAllOrigins());
        request.setAttribute("capacities", dao.getAllCapacities());
        request.setAttribute("selectedTags", new ArrayList<>());
        
        
        request.getRequestDispatcher("store.jsp").forward(request, response);
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) {
    }
}