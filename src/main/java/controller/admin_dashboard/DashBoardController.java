package controller.admin_dashboard;

import dao.FeedbackDAO;
import dao.ProductDAO;
import dao.UserDAO;
import dao.OrderDAO;
import dao.ReportDAO;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import model.Feedback;
import model.Product;

import java.io.IOException;
import java.util.List;
import java.util.Map;

@WebServlet(name = "ViewTodoList", value = "/dashboard")
public class DashBoardController extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        FeedbackDAO feedbackDAO = new FeedbackDAO();
        ProductDAO productDAO = new ProductDAO();
        OrderDAO orderDAO = new OrderDAO();
        ReportDAO reportDAO = new ReportDAO();
        UserDAO userDAO = new UserDAO();

        List<Feedback> doneList = feedbackDAO.getCompletedFeedbacks();
        List<Feedback> pendingList = feedbackDAO.getPendingFeedbacks();
        List<Product> outOfStockList = productDAO.countOutOfStocks();
        int countNewUsers = userDAO.countNewUsersLastWeek();
        int countOrderId = orderDAO.countOrderIdLastWeek();
        double sumTotalPriceOrder = orderDAO.sumTotalPriceLastMonth();

        // Query chart data
        List<Map<String, Object>> dailyRevenue = reportDAO.getRevenueByDay();
        List<Map<String, Object>> bestSellers = reportDAO.getBestSellingProducts(5);
        List<Map<String, Object>> orderStatusList = reportDAO.getOrderStatusStats("all");

        request.setAttribute("outOfStockList", outOfStockList);
        request.setAttribute("doneList", doneList);
        request.setAttribute("pendingList", pendingList);
        request.setAttribute("newUsersLastWeek", countNewUsers);
        request.setAttribute("newOrderLastWeek", countOrderId);
        request.setAttribute("sumTotalPriceLastMonth", sumTotalPriceOrder);
        
        // Pass chart data
        request.setAttribute("dailyRevenue", dailyRevenue);
        request.setAttribute("bestSellers", bestSellers);
        request.setAttribute("orderStatusList", orderStatusList);

        request.getRequestDispatcher("/admin/admin_dashboard.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

    }
}