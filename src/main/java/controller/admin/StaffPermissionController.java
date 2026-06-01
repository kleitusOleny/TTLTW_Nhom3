package controller.admin;

import dao.RolePermissionDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.User;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "StaffPermissionController", value = "/staffs-manager")
public class StaffPermissionController extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        RolePermissionDAO rolePermissionDAO = new RolePermissionDAO();
        List<User> userList = rolePermissionDAO.findAllStaffs();
        if (userList != null) {
            request.setAttribute("listAccountStaffs", userList);
            request.getRequestDispatcher("/admin/manage_staffs.jsp").forward(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/staffs-manager");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

    }
}
