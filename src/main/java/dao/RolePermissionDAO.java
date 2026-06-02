package dao;

import model.Permission;
import model.Role;
import model.User;

import java.util.List;

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

    public List<Role> getRolesByUserId(int userId) {
        String sql = """
            SELECT r.id, r.role_name, r.description 
            FROM roles r
            JOIN user_roles ur ON r.id = ur.role_id
            WHERE ur.user_id = :userId
            """;

        return jdbi.withHandle(handle -> handle.createQuery(sql)
                .bind("userId", userId)
                .mapToBean(Role.class)
                .list());
    }

    public List<User> findAllStaffs() {
        String sql = """
            SELECT 
                u.id, 
                u.email, 
                u.full_name, 
                u.active, 
                r.id AS role_id,
                r.description AS description 
            FROM user_roles ur 
            JOIN users u ON ur.user_id = u.id 
            JOIN roles r ON ur.role_id = r.id
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

    public boolean assignRoleToUser(int userId, int roleId) {
        String sql = "INSERT INTO user_roles (user_id, role_id) VALUES (:userId, :roleId)";

        int rowsAdded = jdbi.withHandle(handle -> handle.createUpdate(sql)
                .bind("userId", userId)
                .bind("roleId", roleId)
                .execute());
        return rowsAdded > 0;
    }

    public boolean removeRoleFromUser(int userId, int roleId) {
        String sql = "DELETE FROM user_roles WHERE user_id = :userId AND role_id = :roleId";

        int rowsDeleted =  jdbi.withHandle(handle -> handle.createUpdate(sql)
                .bind("userId", userId)
                .bind("roleId", roleId)
                .execute());
        return rowsDeleted > 0;
    }

    public int addPermissionToRole(int roleId, int permissionId) {
        String sql = "INSERT INTO role_permissions (role_id, permission_id) VALUES (:roleId, :permissionId)";

        return jdbi.withHandle(handle -> handle.createUpdate(sql)
                .bind("roleId", roleId)
                .bind("permissionId", permissionId)
                .execute());
    }

    public int clearPermissionsFromRole(int roleId) {
        String sql = "DELETE FROM role_permissions WHERE role_id = :roleId";

        return jdbi.withHandle(handle -> handle.createUpdate(sql)
                .bind("roleId", roleId)
                .execute());
    }

    public boolean updateUserRole(int userId, int oldRoleId, int newRoleId) {
        try {
            jdbi.useTransaction(handle -> {
                String deleteSql = "DELETE FROM user_roles WHERE user_id = :userId AND role_id = :oldRoleId";
                String insertSql = "INSERT INTO user_roles (user_id, role_id) VALUES (:userId, :newRoleId)";
                handle.createUpdate(deleteSql)
                        .bind("userId", userId)
                        .bind("oldRoleId", oldRoleId)
                        .execute();
                handle.createUpdate(insertSql)
                        .bind("userId", userId)
                        .bind("newRoleId", newRoleId)
                        .execute();
            });
            return true;
        } catch (Exception e) {
            return false;
        }
    }
}
