package controller.admin;

import dao.RolePermissionDAO;
import dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Role;
import model.User;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "StaffPermissionController", value = "/staffs-manager")
public class StaffPermissionController extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        RolePermissionDAO rolePermissionDAO = new RolePermissionDAO();
        List<User> userList = rolePermissionDAO.findAllStaffs();
        List<Role> roleList = rolePermissionDAO.getAllRoles();
        if (userList != null && roleList != null) {
            request.setAttribute("allRoles", roleList);
            request.setAttribute("listAccountStaffs", userList);
            request.getRequestDispatcher("/admin/manage_staffs.jsp").forward(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/staffs-manager");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action");
        RolePermissionDAO rolePermissionDAO = new RolePermissionDAO();

        if ("edit".equals(action)) {
            try {
                int userId = Integer.parseInt(request.getParameter("userId"));
                int oldRoleId = Integer.parseInt(request.getParameter("oldRoleId"));
                int newRoleId = Integer.parseInt(request.getParameter("roleId"));

                boolean isSuccess = rolePermissionDAO.updateUserRole(userId, oldRoleId, newRoleId);
                if (isSuccess) {
                    response.sendRedirect(request.getContextPath() + "/staffs-manager?updateSuccess");
                } else {
                    response.sendRedirect(request.getContextPath() + "/staffs-manager?updateError");
                }
            } catch (NumberFormatException e) {
                response.sendRedirect(request.getContextPath() + "/staffs-manager?invalidData");
            }
        } else if ("delete".equals(action)) {
            try {
                int userId = Integer.parseInt(request.getParameter("userId"));
                int oldRoleId = Integer.parseInt(request.getParameter("oldRoleId"));

                boolean isSuccess = rolePermissionDAO.removeRoleFromUser(userId, oldRoleId);
                if (isSuccess) {
                    response.sendRedirect(request.getContextPath() + "/staffs-manager?revokeSuccess");
                } else {
                    response.sendRedirect(request.getContextPath() + "/staffs-manager?revokeError");
                }
            } catch (NumberFormatException e) {
                response.sendRedirect(request.getContextPath() + "/staffs-manager?invalidData");
            }
        } else if ("add".equals(action)) {
            try {
                UserDAO userDAO = new UserDAO();
                String email = request.getParameter("email");
                String roleAssignStr = request.getParameter("roleId");

                if (email == null || roleAssignStr == null || roleAssignStr.isEmpty()) {
                    response.sendRedirect(request.getContextPath() + "/staffs-manager?invalidData");
                    return;
                }
                int newRoleId = Integer.parseInt(roleAssignStr);
                User user = userDAO.findByEmail(email);
                if (user == null) {
                    request.getSession().setAttribute("userIsNotExist", "Không tồn tại người dùng này trong hệ thống!");
                    response.sendRedirect(request.getContextPath() + "/staffs-manager?invalidData");
                    return;
                }
                int userId = user.getId();

                boolean isSuccess = rolePermissionDAO.assignRoleToUser(userId, newRoleId);
                if (isSuccess) {
                    response.sendRedirect(request.getContextPath() + "/staffs-manager?addSuccess");
                } else {
                    response.sendRedirect(request.getContextPath() + "/staffs-manager?addError");
                }
            } catch (NumberFormatException e) {
                response.sendRedirect(request.getContextPath() + "/staffs-manager?invalidData");
            }
        } else {
            response.sendRedirect(request.getContextPath() + "/staffs-manager");
        }
    }
}
