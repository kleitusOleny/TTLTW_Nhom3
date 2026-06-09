package controller.admin;

import dao.ReviewDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.ReviewViewModel;
import model.User;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "AdminManageReviewController", urlPatterns = {
    "/admin/manage-reviews",
    "/admin/delete-review",
    "/admin/restore-review",
    "/admin/get-review",
    "/admin/update-review"
})
public class AdminManageReviewController extends HttpServlet {

    private final ReviewDAO reviewDAO = new ReviewDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        User user = (User) request.getSession().getAttribute("user");

        String uri = request.getRequestURI();

        if (uri.endsWith("/admin/get-review")) {
            String idStr = request.getParameter("id");
            if (idStr != null) {
                try {
                    int id = Integer.parseInt(idStr);
                    ReviewViewModel reviewEdit = reviewDAO.getReviewById(id);
                    request.setAttribute("reviewEdit", reviewEdit);
                } catch (NumberFormatException e) {
                    e.printStackTrace();
                }
            }
        }

        List<ReviewViewModel> reviews = reviewDAO.getAllReviews();
        
        request.setAttribute("activePage", "review");
        request.setAttribute("reviews", reviews);
        
        request.getRequestDispatcher("/admin/manage_reviews.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        User user = (User) request.getSession().getAttribute("user");

        String uri = request.getRequestURI();
        String idStr = request.getParameter("id");

        if (idStr != null) {
            try {
                int id = Integer.parseInt(idStr);
                boolean success = false;
                
                if (uri.endsWith("/admin/delete-review")) {
                    success = reviewDAO.deleteReview(id);
                } else if (uri.endsWith("/admin/restore-review")) {
                    success = reviewDAO.restoreReview(id);
                }
                
                if (success) {
                    response.setStatus(HttpServletResponse.SC_OK);
                } else {
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                }
            } catch (NumberFormatException e) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            }
        } else {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
        }
    }
}
