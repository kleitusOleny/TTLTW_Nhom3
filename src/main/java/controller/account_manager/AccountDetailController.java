package controller.account_manager;

import dao.AddressDAO;
import dao.OrderDAO;
import dao.UserDAO;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import model.Address;
import model.User;

import java.io.IOException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Map;

@WebServlet(name = "AccountDetailController", value = "/account-manager/detail")
public class AccountDetailController extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String idParam = request.getParameter("id");
        if (idParam == null || idParam.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/account-manager");
            return;
        }

        try {
            int userId = Integer.parseInt(idParam);
            UserDAO userDAO = new UserDAO();
            User user = userDAO.findById(userId).orElse(null);

            if (user == null) {
                response.sendRedirect(request.getContextPath() + "/account-manager");
                return;
            }

            AddressDAO addressDAO = new AddressDAO();
            List<Address> addresses = addressDAO.getByUserID(userId);

            OrderDAO orderDAO = new OrderDAO();
            List<Map<String, Object>> orders = orderDAO.getOrdersWithItemsByUserId(userId);
            
            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
            for (Map<String, Object> order : orders) {
                Object createAtObj = order.get("create_at");
                if (createAtObj instanceof LocalDateTime) {
                    order.put("create_at_str", ((LocalDateTime) createAtObj).format(formatter));
                } else if (createAtObj != null) {
                    order.put("create_at_str", createAtObj.toString());
                } else {
                    order.put("create_at_str", "");
                }
            }

            request.setAttribute("userDetail", user);
            request.setAttribute("userAddresses", addresses);
            request.setAttribute("userOrders", orders);

            request.getRequestDispatcher("/admin/manage_account_detail.jsp").forward(request, response);

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/account-manager");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doGet(request, response);
    }
}
