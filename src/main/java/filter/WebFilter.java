package filter;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import model.User;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@jakarta.servlet.annotation.WebFilter("/*")
public class WebFilter implements Filter {
    private static final Map<String, String> urlPermissionMap = new HashMap<>();
    static {
        // Cấu hình quyền chi tiết cho từng URL Admin
        urlPermissionMap.put("/account-manager", "account:read");
        urlPermissionMap.put("/product-manager", "product:read");
        urlPermissionMap.put("/banner-manager", "banner:read");
        urlPermissionMap.put("/manage-blog", "blog:read");
        urlPermissionMap.put("/manage-orders", "orders:read");
        urlPermissionMap.put("/manage-promotions", "promotion:read");
        urlPermissionMap.put("/product-receipt-manager", "inventory:read");
        urlPermissionMap.put("/product-issue-manager", "inventory:read");

        urlPermissionMap.put("/account-manager/add", "account:upsert");
        urlPermissionMap.put("/account-manager/edit", "account:upsert");
        urlPermissionMap.put("/account-manager/toggle-status", "account:delete");
        urlPermissionMap.put("/account-manager/lock-multiple", "account:delete");

        urlPermissionMap.put("/product-manager/add", "product:upsert");
        urlPermissionMap.put("/product-manager/edit", "product:upsert");
        urlPermissionMap.put("/product-manager/delete", "product:delete");
        urlPermissionMap.put("/product-manager/delete-list", "product:delete");
        urlPermissionMap.put("/product-manager/importExcel", "product:upsert");
        urlPermissionMap.put("/product-manager/confirmImportExcel", "product:upsert");

        urlPermissionMap.put("/admin/manage-promotions", "promotion:read");
        urlPermissionMap.put("/admin/get-promotion", "promotion:read");
        urlPermissionMap.put("/admin/add-promotion", "promotion:upsert");
        urlPermissionMap.put("/admin/update-promotion", "promotion:upsert");
        urlPermissionMap.put("/admin/delete-promotion", "promotion:delete");
        
        urlPermissionMap.put("/category-manager", "category:read");
        urlPermissionMap.put("/category-manager/add", "category:upsert");
        urlPermissionMap.put("/category-manager/edit", "category:upsert");
        urlPermissionMap.put("/category-manager/delete", "category:delete");

        urlPermissionMap.put("/manage-manufacturer", "manufacturer:read");
        urlPermissionMap.put("/manage-manufacturer/add", "manufacturer:upsert");
        urlPermissionMap.put("/manage-manufacturer/edit", "manufacturer:upsert");
        urlPermissionMap.put("/manage-manufacturer/delete", "manufacturer:delete");

        urlPermissionMap.put("/product-receipt-manager/create", "inventory:upsert");
        urlPermissionMap.put("/product-receipt-manager/get-details", "inventory:read");

        urlPermissionMap.put("/product-issue-manager/create", "inventory:upsert");
        urlPermissionMap.put("/product-issue-manager/get-details", "inventory:read");

        urlPermissionMap.put("/report-manager", "inventory:read");
        urlPermissionMap.put("/admin/order-stats", "orders:read");

        urlPermissionMap.put("/banner-manager/add", "banner:upsert");
        urlPermissionMap.put("/banner-manager/edit", "banner:upsert");
        urlPermissionMap.put("/banner-manager/delete", "banner:delete");
        urlPermissionMap.put("/banner-manager/delete-list", "banner:delete");

        urlPermissionMap.put("/staffs-manager", "staff:upsert");

        urlPermissionMap.put("/roles-manager", "role:read");          // Quét khi load trang (GET)
        urlPermissionMap.put("/roles-manager/add", "role:upsert");    // Quét khi tạo mới (POST)
        urlPermissionMap.put("/roles-manager/edit", "role:upsert");   // Quét khi sửa (POST)
        urlPermissionMap.put("/roles-manager/delete", "role:delete"); // Quét khi xóa (POST)
    }
    private static final String[] PROTECTED_AUTH_URLS = {
            "/login",
            "/register",
            "/authentication",
            "/forgotpassword",
            "/onboarding"
    };
    private static final String[] PROTECTED_ADMIN_URLS = {
            "/dashboard",
            "/account-manager",
            "/product-manager",
            "/banner-manager",
            "/category-manager",
            "/manage-manufacturer",
            "/manage-blog",
            "/manage-orders",
            "/manage-promotions",
            "/product-receipt-manager",
            "/product-issue-manager",
            "/staffs-manager",
            "/admin/",
            "/roles-manager",
            "/report-manager"
    };
    @Override
    public void doFilter(ServletRequest servletRequest, ServletResponse servletResponse, FilterChain filterChain) throws IOException, ServletException {
        HttpServletRequest request = (HttpServletRequest) servletRequest;
        HttpServletResponse response = (HttpServletResponse) servletResponse;

        String uri = request.getRequestURI();
        String contextPath = request.getContextPath();
        String path = uri.substring(contextPath.length());
        if (path.matches(".*\\.(css|js|png|jpg|jpeg|gif|svg|ico|woff|woff2|ttf|eot|mp4|webp)$")) {
            filterChain.doFilter(request, response);
            return;
        }

        HttpSession session = request.getSession(false);

        boolean isAdminPath = false;
        boolean isProtected = false;
        for (String protectedUrl : PROTECTED_AUTH_URLS) {
            if (path.startsWith(protectedUrl)) {
                isProtected = true;
                break;
            }
        }

        for (String adminUrl : PROTECTED_ADMIN_URLS) {
            if (path.startsWith(adminUrl)) {
                isAdminPath = true;
                break;
            }
        }

        boolean loggedIn = (session != null && session.getAttribute("user") != null);
        if (loggedIn && isProtected) {
            // Nếu đã đăng nhập mà còn cố vào trong list PROTECTED_AUTH_URLS
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }
        User user = (session != null) ? (User) session.getAttribute("user") : null;
        if (isAdminPath) {
            if (user == null) {
                response.sendRedirect(request.getContextPath() + "/login");
                return;
            }
            @SuppressWarnings("unchecked")
            List<String> permissions = (List<String>) session.getAttribute("userPermissions");
            if (permissions == null || !permissions.contains("dashboard:read")) {
                response.sendRedirect(request.getContextPath() + "/home");
                return;
            }
            String requiredPermission = urlPermissionMap.get(path);

            // Nếu path này không nằm trực tiếp trong Map, thử tìm theo tiền tố (Ví dụ: /account-manager/add)
            if (requiredPermission == null) {
                for (Map.Entry<String, String> entry : urlPermissionMap.entrySet()) {
                    if (path.startsWith(entry.getKey())) {
                        requiredPermission = entry.getValue();
                        break;
                    }
                }
            }

            // Nếu trang yêu cầu quyền chi tiết
            if (requiredPermission != null && !permissions.contains(requiredPermission)) {
                HttpSession currentSession = request.getSession(true);
                currentSession.setAttribute("authError", "Bạn không có quyền truy cập vào tính năng này!");
                response.sendRedirect(request.getContextPath() + "/dashboard");
                return;
            }
        }
        filterChain.doFilter(request, response);
    }
}