package filter;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import model.User;

import java.io.IOException;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@jakarta.servlet.annotation.WebFilter("/*")
public class WebFilter implements Filter {
    private static final Map<String, String> urlPermissionMap = new LinkedHashMap<>();
    static {
        // Cấu hình quyền chi tiết cho từng URL Admin
        // Quản lý blog & tin tức
        urlPermissionMap.put("/manage-blog", "blog:read");
        urlPermissionMap.put("/admin/manage-blog", "blog:read");
        urlPermissionMap.put("/admin/get-blog", "blog:read");
        urlPermissionMap.put("/fetch-news", "blog:read");

        urlPermissionMap.put("/admin/update-blog", "blog:upsert");
        urlPermissionMap.put("/admin/approve-news", "blog:upsert");

        urlPermissionMap.put("/admin/delete-blog", "blog:delete");
        urlPermissionMap.put("/admin/bulk-delete-blog", "blog:delete");

        // Quản lí tài khoản
        urlPermissionMap.put("/account-manager", "account:read");
        urlPermissionMap.put("/account-manager/add", "account:upsert");
        urlPermissionMap.put("/account-manager/edit", "account:upsert");
        urlPermissionMap.put("/account-manager/toggle-status", "account:delete");
        urlPermissionMap.put("/account-manager/lock-multiple", "account:delete");

        // Quản lí promotion
        urlPermissionMap.put("/manage-promotions", "promotion:read");
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

        // Quản lý đơn hàng
        urlPermissionMap.put("/manage-orders", "orders:read");
        urlPermissionMap.put("/admin/manage-orders", "orders:read");
        urlPermissionMap.put("/admin/get-order", "orders:read");
        urlPermissionMap.put("/admin/api/orders", "orders:read");

        urlPermissionMap.put("/category-manager", "category:read");
        urlPermissionMap.put("/category-manager/add", "category:upsert");
        urlPermissionMap.put("/category-manager/edit", "category:upsert");
        urlPermissionMap.put("/category-manager/delete", "category:delete");

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
        urlPermissionMap.put("/manage-manufacturer", "manufacturer:read");
        urlPermissionMap.put("/admin/add-order", "orders:upsert");
        urlPermissionMap.put("/admin/create-order", "orders:upsert");
        urlPermissionMap.put("/admin/submit-order", "orders:upsert");
        urlPermissionMap.put("/admin/edit-order", "orders:upsert");
        urlPermissionMap.put("/admin/update-order", "orders:upsert");

        urlPermissionMap.put("/admin/verify-user", "orders:upsert");

        urlPermissionMap.put("/admin/delete-order", "orders:delete");
        urlPermissionMap.put("/admin/refund-order", "orders:delete");
        urlPermissionMap.put("/admin/send-feedback", "orders:delete");

        // Quản lí đánh giá
        urlPermissionMap.put("/admin/manage-reviews", "review:read");
        urlPermissionMap.put("/admin/get-review", "review:read");
        urlPermissionMap.put("/admin/update-review", "review:upsert");
        urlPermissionMap.put("/admin/delete-review", "review:delete");
        urlPermissionMap.put("/admin/restore-review", "review:delete");

        // Quản lí nhân sự
        urlPermissionMap.put("/staffs-manager", "staff:read");
        urlPermissionMap.put("/staffs-manager/add", "staff:upsert");
        urlPermissionMap.put("/staffs-manager/edit", "staff:upsert");
        urlPermissionMap.put("/staffs-manager/delete", "staff:upsert");

        // Quản lí roles
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
            if (path.endsWith("/")) {
                path = path.substring(0, path.length() - 1);
            }
            String requiredPermission = urlPermissionMap.get(path);

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