package controller.admin;

import dao.ReportDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;
import java.util.Map;

@WebServlet(name = "AdminPromotionStatsController", value = "/admin/promotion-stats")
public class AdminPromotionStatsController extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String period = request.getParameter("period");
        if (period == null || period.trim().isEmpty()) {
            period = "all";
        }

        ReportDAO reportDAO = new ReportDAO();
        List<Map<String, Object>> promoProductStats = reportDAO.getPromotionalProductStats(period);
        request.setAttribute("promoProductStats", promoProductStats);
        request.setAttribute("period", period);

        String timeFilter = request.getParameter("timeFilter");
        if (timeFilter == null || timeFilter.trim().isEmpty()) {
            timeFilter = "all_active";
        }
        List<Map<String, Object>> activePromoStats = reportDAO.getActivePromotionStats(timeFilter);
        request.setAttribute("activePromoStats", activePromoStats);
        request.setAttribute("timeFilter", timeFilter);

        request.setAttribute("activePage", "promotion-stats");
        request.getRequestDispatcher("/admin/manage_promotion_stats.jsp").forward(request, response);
    }
}
