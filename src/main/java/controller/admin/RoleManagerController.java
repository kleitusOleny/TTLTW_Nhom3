package controller.admin;

import dao.RolePermissionDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Permission;

import java.io.IOException;
import java.util.List;
import java.util.Map;

@WebServlet(name = "RoleManagerController", value = "/roles-manager")
public class RoleManagerController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        RolePermissionDAO dao = new RolePermissionDAO();

        // Đổ dữ liệu bảng Vai trò + Quyền hạn và Danh sách tất cả thẻ quyền cho form Checkbox
        List<Map<String, Object>> roleList = dao.findAllRolesWithPermissions();
        List<Permission> permissionList = dao.getAllPermissions();

        request.setAttribute("listRolesWithPerms", roleList);
        request.setAttribute("allPermissions", permissionList);
        request.getRequestDispatcher("/admin/manage_roles.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");
        RolePermissionDAO dao = new RolePermissionDAO();

        try {
            // cấu hình thẻ quyền
            switch (action) {
                case "edit" -> {
                    int roleId = Integer.parseInt(request.getParameter("roleId"));
                    String[] selectedPermIds = request.getParameterValues("permissionIds");

                    dao.clearPermissionsFromRole(roleId);
                    if (selectedPermIds != null) {
                        for (String permIdStr : selectedPermIds) {
                            int permId = Integer.parseInt(permIdStr);
                            dao.addPermissionToRole(roleId, permId);
                        }
                    }
                    response.sendRedirect(request.getContextPath() + "/roles-manager?success");
                }
                case "add" -> {
                    String roleName = request.getParameter("roleName").toUpperCase().trim();
                    String description = request.getParameter("description").trim();

                    boolean isCreated = dao.createRole(roleName, description);
                    if (isCreated) {
                        response.sendRedirect(request.getContextPath() + "/roles-manager?addSuccess");
                    } else {
                        response.sendRedirect(request.getContextPath() + "/roles-manager?addError");
                    }
                }
                case "delete" -> {
                    int roleId = Integer.parseInt(request.getParameter("roleId"));
                    dao.removeRole(roleId);
                    response.sendRedirect(request.getContextPath() + "/roles-manager?deleteSuccess");
                }
                case null, default -> response.sendRedirect(request.getContextPath() + "/roles-manager");
            }
        } catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/roles-manager?error");
        }
    }
}