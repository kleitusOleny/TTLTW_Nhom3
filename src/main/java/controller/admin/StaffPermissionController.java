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

@WebServlet(name = "StaffPermissionController", urlPatterns = {
        "/staffs-manager",
        "/staffs-manager/add",
        "/staffs-manager/edit",
        "/staffs-manager/delete"
})
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
            response.sendRedirect(request.getContextPath() + "/dashboard");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");
        RolePermissionDAO rolePermissionDAO = new RolePermissionDAO();

        try {
            // thêm mới và cập nhật quyền
            if ("add".equals(action) || "edit".equals(action)) {
                int userId;
                if ("add".equals(action)) {
                    String email = request.getParameter("email");
                    UserDAO userDAO = new UserDAO();
                    User user = userDAO.findByEmail(email);

                    if (user == null) {
                        request.getSession().setAttribute("userIsNotExist", "Không tồn tại email này trong hệ thống!");
                        response.sendRedirect(request.getContextPath() + "/staffs-manager?invalidData");
                        return;
                    }
                    userId = user.getId();
                } else {
                    userId = Integer.parseInt(request.getParameter("userId"));
                }
                String[] selectedRoleIds = request.getParameterValues("roleIds");
                rolePermissionDAO.removeAllRolesFromUser(userId);
                if (selectedRoleIds != null) {
                    for (String roleIdStr : selectedRoleIds) {
                        int roleId = Integer.parseInt(roleIdStr);
                        rolePermissionDAO.assignRoleToUser(userId, roleId);
                    }
                }
                response.sendRedirect(request.getContextPath() + "/staffs-manager?success");
            }
            // cách chức nhân sự
            else if ("delete".equals(action)) {
                int userId = Integer.parseInt(request.getParameter("userId"));
                rolePermissionDAO.removeAllRolesFromUser(userId);
                response.sendRedirect(request.getContextPath() + "/staffs-manager?revokeSuccess");
            }
            else {
                response.sendRedirect(request.getContextPath() + "/staffs-manager");
            }
        } catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/staffs-manager?error");
        }
    }
}