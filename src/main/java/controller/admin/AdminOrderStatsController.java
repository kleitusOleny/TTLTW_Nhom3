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

        List<Map<String, Object>> customerStats = reportDAO.getCustomerOrderStats(period);
        request.setAttribute("customerStats", customerStats);
        request.setAttribute("period", period);

        Map<String, Object> summary = reportDAO.getCustomerStatsSummary();
        request.setAttribute("summary", summary);

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

        List<Map<String, Object>> orderStatusStats = reportDAO.getOrderStatusStats(period);
        request.setAttribute("orderStatusStats", orderStatusStats);
        
        long totalOrdersStatus = 0;
        for (Map<String, Object> stat : orderStatusStats) {
            totalOrdersStatus += ((Number) stat.get("order_count")).longValue();
        }
        request.setAttribute("totalOrdersStatus", totalOrdersStatus);

        StringBuilder statusLabelsJson = new StringBuilder("[");
        StringBuilder statusCountsJson = new StringBuilder("[");
        for (int i = 0; i < orderStatusStats.size(); i++) {
            Map<String, Object> row = orderStatusStats.get(i);
            String status = row.get("status") != null ? row.get("status").toString().replace("\"", "\\\"") : "Không rõ";
            long count = ((Number) row.get("order_count")).longValue();
            
            statusLabelsJson.append("\"").append(status).append("\"");
            statusCountsJson.append(count);
            if (i < orderStatusStats.size() - 1) {
                statusLabelsJson.append(",");
                statusCountsJson.append(",");
            }
        }
        statusLabelsJson.append("]");
        statusCountsJson.append("]");
        
        request.setAttribute("statusLabelsJson", statusLabelsJson.toString());
        request.setAttribute("statusCountsJson", statusCountsJson.toString());
        Map<String, Object> paymentSummary = reportDAO.getPaymentStatusSummary(period);
        request.setAttribute("paymentSummary", paymentSummary);

        List<Map<String, Object>> paymentMethodStats = reportDAO.getPaymentMethodStats(period);
        request.setAttribute("paymentMethodStats", paymentMethodStats);
        
        StringBuilder methodLabelsJson = new StringBuilder("[");
        StringBuilder methodAmountsJson = new StringBuilder("[");
        for (int i = 0; i < paymentMethodStats.size(); i++) {
            Map<String, Object> row = paymentMethodStats.get(i);
            String method = row.get("method") != null ? row.get("method").toString().replace("\"", "\\\"") : "Khác";
            double amount = row.get("total_amount") != null ? ((Number) row.get("total_amount")).doubleValue() : 0;
            
            methodLabelsJson.append("\"").append(method).append("\"");
            methodAmountsJson.append(amount);
            if (i < paymentMethodStats.size() - 1) {
                methodLabelsJson.append(",");
                methodAmountsJson.append(",");
            }
        }
        methodLabelsJson.append("]");
        methodAmountsJson.append("]");
        request.setAttribute("methodLabelsJson", methodLabelsJson.toString());
        request.setAttribute("methodAmountsJson", methodAmountsJson.toString());

        List<Map<String, Object>> unpaidDeliveredOrders = reportDAO.getDeliveredButUnpaidOrders(period);
        request.setAttribute("unpaidDeliveredOrders", unpaidDeliveredOrders);

        request.setAttribute("activePage", "order-stats");
        request.getRequestDispatcher("/admin/manage_order_stats.jsp").forward(request, response);
    }
}
