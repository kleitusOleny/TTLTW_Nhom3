package dao;

import model.Permission;
import model.Role;
import model.User;

import java.util.List;
import java.util.Map;

public class RolePermissionDAO extends ADAO {
    public List<String> getPermissionsByUserId(int userId) {
        String sql = """
            SELECT DISTINCT p.permission_key 
            FROM permissions p
            JOIN role_permissions rp ON p.id = rp.permission_id
            JOIN user_roles ur ON rp.role_id = ur.role_id
            WHERE ur.user_id = :userId
            """;

        return jdbi.withHandle(handle -> handle.createQuery(sql)
                .bind("userId", userId)
                .mapTo(String.class)
                .list());
    }

    public List<User> findAllStaffs() {
        String sql = """
            SELECT 
                u.id, 
                u.email, 
                u.full_name, 
                u.active, 
                MAX(r.id) AS role_id,
                GROUP_CONCAT(r.description SEPARATOR ',') AS description 
            FROM user_roles ur 
            JOIN users u ON ur.user_id = u.id 
            JOIN roles r ON ur.role_id = r.id
            GROUP BY u.id, u.email, u.full_name, u.active
            """;

        return jdbi.withHandle(handle -> handle.createQuery(sql)
                .mapToBean(User.class)
                .list());
    }

    public List<Role> getAllRoles() {
        String sql = "SELECT id, role_name, description FROM roles";

        return jdbi.withHandle(handle -> handle.createQuery(sql)
                .mapToBean(Role.class)
                .list());
    }

    public List<Permission> getAllPermissions() {
        String sql = "SELECT id, permission_key, description FROM permissions";

        return jdbi.withHandle(handle -> handle.createQuery(sql)
                .mapToBean(Permission.class)
                .list());
    }

    public void assignRoleToUser(int userId, int roleId) {
        String sql = "INSERT INTO user_roles (user_id, role_id) VALUES (:userId, :roleId)";

        jdbi.withHandle(handle -> handle.createUpdate(sql)
                .bind("userId", userId)
                .bind("roleId", roleId)
                .execute());
    }

    public void removeAllRolesFromUser(int userId) {
        String sql = "DELETE FROM user_roles WHERE user_id = :userId";
        jdbi.withHandle(handle -> handle.createUpdate(sql)
                .bind("userId", userId)
                .execute());
    }

    public void addPermissionToRole(int roleId, int permissionId) {
        String sql = "INSERT INTO role_permissions (role_id, permission_id) VALUES (:roleId, :permissionId)";

        jdbi.withHandle(handle -> handle.createUpdate(sql)
                .bind("roleId", roleId)
                .bind("permissionId", permissionId)
                .execute());
    }

    public void clearPermissionsFromRole(int roleId) {
        String sql = "DELETE FROM role_permissions WHERE role_id = :roleId";

        jdbi.withHandle(handle -> handle.createUpdate(sql)
                .bind("roleId", roleId)
                .execute());
    }

    public List<Map<String, Object>> findAllRolesWithPermissions() {
        String sql = """
        SELECT 
            r.id AS role_id, 
            r.role_name AS role_name, 
            r.description AS role_desc, 
            GROUP_CONCAT(p.permission_key SEPARATOR ',') AS permission_keys
        FROM roles r
        LEFT JOIN role_permissions rp ON r.id = rp.role_id
        LEFT JOIN permissions p ON rp.permission_id = p.id
        GROUP BY r.id, r.role_name, r.description
        """;
        return jdbi.withHandle(handle -> handle.createQuery(sql).mapToMap().list());
    }

    public void removeRole(int roleId) {
        String sql = "DELETE FROM roles WHERE id = :roleId";

        jdbi.withHandle(handle -> handle.createUpdate(sql)
                .bind("roleId", roleId)
                .execute());
    }

    public boolean createRole(String roleName, String description) {
        String sql = "INSERT INTO roles (role_name, description) VALUES (:roleName, :description)";

        int rows = jdbi.withHandle(handle -> handle.createUpdate(sql)
                .bind("roleName", roleName)
                .bind("description", description)
                .execute());
        return rows > 0;
    }
}
