package controller;

import dao.ProductDAO;
import dao.ReviewDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Product;
import model.ReviewViewModel;

import java.io.IOException;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@WebServlet(name = "DetailController", value = { "/detail", "/infoUsers/detail" })
public class DetailController extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String id = request.getParameter("id");

        if (id == null || id.isEmpty()) {
            response.sendRedirect("store");
            return;
        }

        ProductDAO dao = new ProductDAO();
        Product product = dao.getProductById(id);

        if (product == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Sản phẩm không tồn tại");
            return;
        }

        List<Product> relatedProducts = dao.getRelatedProducts();

        ReviewDAO reviewDAO = new ReviewDAO();
        List<ReviewViewModel> reviews = reviewDAO.getReviewsByProduct(id);

        long totalReviews = reviews.size();
        long star5 = reviews.stream().filter(r -> r.getStar() >= 5).count();
        long star4 = reviews.stream().filter(r -> r.getStar() >= 4 && r.getStar() < 5).count();
        long star3 = reviews.stream().filter(r -> r.getStar() >= 3 && r.getStar() < 4).count();
        long star2 = reviews.stream().filter(r -> r.getStar() >= 2 && r.getStar() < 3).count();
        long star1 = reviews.stream().filter(r -> r.getStar() >= 1 && r.getStar() < 2).count();

        request.setAttribute("totalReviews", totalReviews);
        request.setAttribute("star5", star5);
        request.setAttribute("star4", star4);
        request.setAttribute("star3", star3);
        request.setAttribute("star2", star2);
        request.setAttribute("star1", star1);

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

        request.setAttribute("product", product);
        request.setAttribute("relatedProducts", relatedProducts);
        request.setAttribute("reviews", reviews);

        request.getRequestDispatcher("detail.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) {
    }
}