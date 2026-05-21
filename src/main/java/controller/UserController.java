package controller;

import dao.CTEvaluateDAO;
import dao.EvaluateDAO;
import dao.FavouriteDAO;
import dao.ProductDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.CTEvaluates;
import model.Evaluates;
import model.Product;
import model.User;
import services.EvaluateService;
import services.UserService;

import java.io.IOException;
import java.text.ParseException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@WebServlet(name = "UserController", value = "/user")
public class UserController extends HttpServlet {
    private UserService userService;
    private EvaluateService evaluateService;
    private FavouriteDAO favouriteDAO;

    @Override
    public void init() {
        userService = new UserService();
        evaluateService = new EvaluateService();
        favouriteDAO = new FavouriteDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        String page = request.getParameter("page");
        if (page == null) {
            page = "info";
        }
        request.setAttribute("user", user);
        
        if (user != null) {
            int favCount = favouriteDAO.countFavouritesByUserID(user.getId());
            request.setAttribute("favCount", favCount);
        }
        String requestedWith = request.getHeader("X-Requested-With");
        if (!"XMLHttpRequest".equals(requestedWith)) {
            request.setAttribute("initialPage", userService.getFullUrl(request, page));
            request.getRequestDispatcher("/info_users/user_sidebar.jsp").forward(request, response);
            return;
        } else {
            try {
                userService.dispatchSubPage(page, user, request, response, evaluateService);
            } catch (Exception e) {
                log("Error in UserController", e);
                response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            }
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        if ("updateProfile".equals(action)) {
            try {
                userService.updateProfile(request, response);
            } catch (ParseException e) {
                throw new RuntimeException(e);
            }
        } else {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Action không hợp lệ");
        }
    }
}
