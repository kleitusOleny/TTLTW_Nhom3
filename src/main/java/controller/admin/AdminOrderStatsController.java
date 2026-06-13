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

@WebServlet(name = "AdminOrderStatsController", value = "/admin/order-stats")
public class AdminOrderStatsController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String period = request.getParameter("period");
        if (period == null || period.trim().isEmpty()) {
            period = "all";
        }

        ReportDAO reportDAO = new ReportDAO();

        // 1. Get detailed customer order stats list based on period
        List<Map<String, Object>> customerStats = reportDAO.getCustomerOrderStats(period);
        request.setAttribute("customerStats", customerStats);
        request.setAttribute("period", period);

        // 2. Get customer stats summary for Donut Chart (loyal, new, potential count)
        Map<String, Object> summary = reportDAO.getCustomerStatsSummary();
        request.setAttribute("summary", summary);

        // 3. Format data for Top Spend customers Bar Chart (Top 5)
        StringBuilder topNamesJson = new StringBuilder("[");
        StringBuilder topSpendJson = new StringBuilder("[");
        int limit = Math.min(5, customerStats.size());
        for (int i = 0; i < limit; i++) {
            Map<String, Object> row = customerStats.get(i);
            String name = row.get("full_name") != null ? row.get("full_name").toString().replace("\"", "\\\"") : "";
            if (name.isEmpty() && row.get("username") != null) {
                name = row.get("username").toString().replace("\"", "\\\"");
            }
            if (name.isEmpty() && row.get("email") != null) {
                name = row.get("email").toString().split("@")[0];
            }
            String spend = row.get("total_spend") != null ? row.get("total_spend").toString() : "0";

            topNamesJson.append("\"").append(name).append("\"");
            topSpendJson.append(spend);
            if (i < limit - 1) {
                topNamesJson.append(",");
                topSpendJson.append(",");
            }
        }
        topNamesJson.append("]");
        topSpendJson.append("]");

        request.setAttribute("topNamesJson", topNamesJson.toString());
        request.setAttribute("topSpendJson", topSpendJson.toString());

        request.setAttribute("activePage", "order-stats");
        request.getRequestDispatcher("/admin/manage_order_stats.jsp").forward(request, response);
    }
}
