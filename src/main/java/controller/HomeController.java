package controller;

import dao.BannerDAO;
import dao.BlogDAO;
import dao.FavouriteDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Banner;
import model.Blogs;
import model.Discount;
import model.User;

import java.io.IOException;
import java.util.List;
import java.util.Map;

@WebServlet(name = "HomeController", value = "/home")
public class HomeController extends HttpServlet {
    private FavouriteDAO favouriteDAO;
    private services.DiscountService discountService;
    private BlogDAO blogDAO;
    private dao.ProductDAO productDAO;
    private BannerDAO bannerDAO;

    @Override
    public void init() {
        favouriteDAO = new FavouriteDAO();
        discountService = new services.DiscountService();
        blogDAO = new BlogDAO();
        productDAO = new dao.ProductDAO();
        bannerDAO = new BannerDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setAttribute("curHeader", "home");

        List<Map<String, Object>> topFavouritesList = favouriteDAO.getTopFavouritedProducts(4);
        request.setAttribute("topFavouritesList", topFavouritesList);

        HttpSession session = request.getSession(false);
        int userId = 0;
        if (session != null) {
            User user = (User) session.getAttribute("user");
            if (user != null) {
                userId = user.getId();
                List<Map<String, Object>> userFavouritesList = favouriteDAO
                        .getFavouritesWithProductsByUserID(user.getId());
                request.setAttribute("userFavouritesList", userFavouritesList);
            }
        }

        List<Discount> publicVouchers = discountService.getPublicDiscounts();
        request.setAttribute("publicVouchers", publicVouchers);

        java.util.Set<Integer> collectedVoucherIds = new java.util.HashSet<>();
        if (userId > 0) {
            List<Discount> userVouchers = discountService.getUserVouchers(userId);
            for (Discount d : userVouchers) {
                collectedVoucherIds.add(d.getId());
            }
        }
        request.setAttribute("collectedVoucherIds", collectedVoucherIds);

        List<Blogs> latestBlogs = blogDAO.getLatestBlogs(3);
        request.setAttribute("latestBlogs", latestBlogs);

        List<model.Product> featuredProducts = productDAO.getProducts();
        if (featuredProducts != null && featuredProducts.size() > 4) {
            featuredProducts = featuredProducts.subList(0, 4);
        }
        request.setAttribute("featuredProducts", featuredProducts);

        List<model.Product> bestSellingProducts = productDAO.getBestSellingProducts(4);
        request.setAttribute("bestSellingProducts", bestSellingProducts);

        List<Banner> activeBanners = bannerDAO.getActiveBanners();
        request.setAttribute("activeBanners", activeBanners);

        request.getRequestDispatcher("index.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
    }
}