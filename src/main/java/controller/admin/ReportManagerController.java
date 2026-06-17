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

@WebServlet(name = "ReportManagerController", value = "/report-manager")
public class ReportManagerController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String tab = request.getParameter("tab");
        if (tab == null || tab.isEmpty()) {
            tab = "revenue";
        }

        ReportDAO reportDAO = new ReportDAO();

        if ("revenue".equals(tab)) {
            String period = request.getParameter("period");
            if (period == null || period.isEmpty()) {
                period = "day";
            }
            List<Map<String, Object>> revenueData;
            switch (period) {
                case "month":
                    revenueData = reportDAO.getRevenueByMonth();
                    break;
                case "quarter":
                    revenueData = reportDAO.getRevenueByQuarter();
                    break;
                case "year":
                    revenueData = reportDAO.getRevenueByYear();
                    break;
                case "day":
                default:
                    revenueData = reportDAO.getRevenueByDay();
                    break;
            }
            request.setAttribute("revenueData", revenueData);
            request.setAttribute("period", period);
            
            // Build JS arrays for ApexCharts
            StringBuilder labelsJson = new StringBuilder("[");
            StringBuilder valuesJson = new StringBuilder("[");
            for (int i = 0; i < revenueData.size(); i++) {
                Map<String, Object> row = revenueData.get(i);
                String label = row.get("time_label") != null ? row.get("time_label").toString() : "";
                String rev = row.get("revenue") != null ? row.get("revenue").toString() : "0";
                
                labelsJson.append("\"").append(label).append("\"");
                valuesJson.append(rev);
                if (i < revenueData.size() - 1) {
                    labelsJson.append(",");
                    valuesJson.append(",");
                }
            }
            labelsJson.append("]");
            valuesJson.append("]");
            
            request.setAttribute("labelsJson", labelsJson.toString());
            request.setAttribute("valuesJson", valuesJson.toString());

        } else if ("bestsellers".equals(tab)) {
            String period = request.getParameter("period");
            if (period == null || period.isEmpty()) {
                period = "all";
            }
            
            String startDate = request.getParameter("startDate");
            String endDate = request.getParameter("endDate");
            
            if (startDate == null || startDate.isEmpty() || endDate == null || endDate.isEmpty()) {
                java.time.LocalDate today = java.time.LocalDate.now();
                switch (period) {
                    case "today":
                        startDate = today.toString();
                        endDate = today.toString();
                        break;
                    case "yesterday":
                        startDate = today.minusDays(1).toString();
                        endDate = today.minusDays(1).toString();
                        break;
                    case "7days":
                        startDate = today.minusDays(7).toString();
                        endDate = today.toString();
                        break;
                    case "30days":
                        startDate = today.minusDays(30).toString();
                        endDate = today.toString();
                        break;
                    case "month":
                        startDate = today.withDayOfMonth(1).toString();
                        endDate = today.toString();
                        break;
                    case "all":
                    default:
                        startDate = "";
                        endDate = "";
                        break;
                }
            } else {
                period = "custom";
            }
            
            List<Map<String, Object>> bestSellers = reportDAO.getBestSellingProducts(10, startDate, endDate);
            request.setAttribute("bestSellers", bestSellers);
            request.setAttribute("startDate", startDate);
            request.setAttribute("endDate", endDate);
            request.setAttribute("period", period);
            
            // Build JS arrays for ApexCharts
            StringBuilder labelsJson = new StringBuilder("[");
            StringBuilder valuesJson = new StringBuilder("[");
            for (int i = 0; i < bestSellers.size(); i++) {
                Map<String, Object> row = bestSellers.get(i);
                String name = row.get("product_name") != null ? row.get("product_name").toString().replace("\"", "\\\"") : "";
                String sold = row.get("total_sold") != null ? row.get("total_sold").toString() : "0";
                
                labelsJson.append("\"").append(name).append("\"");
                valuesJson.append(sold);
                if (i < bestSellers.size() - 1) {
                    labelsJson.append(",");
                    valuesJson.append(",");
                }
            }
            labelsJson.append("]");
            valuesJson.append("]");
            
            request.setAttribute("labelsJson", labelsJson.toString());
            request.setAttribute("valuesJson", valuesJson.toString());

        } else if ("unsold".equals(tab)) {
            String monthsStr = request.getParameter("months");
            int months = 1;
            if ("2".equals(monthsStr)) {
                months = 2;
            }
            List<Map<String, Object>> unsoldProducts = reportDAO.getUnsoldProducts(months);
            request.setAttribute("unsoldProducts", unsoldProducts);
            request.setAttribute("months", months);
        }

        request.setAttribute("tab", tab);
        request.setAttribute("activePage", "report");
        request.getRequestDispatcher("admin/manage_reports.jsp").forward(request, response);
    }
}
