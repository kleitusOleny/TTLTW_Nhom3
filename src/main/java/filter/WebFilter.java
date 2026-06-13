package filter;

import com.google.gson.Gson;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import model.User;

import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@jakarta.servlet.annotation.WebFilter("/*")
public class WebFilter implements Filter {
    // Các biến sẽ được gán giá trị khi server khởi động
    private Map<String, String> urlPermissionMap;
    private List<String> protectedAuthUrls;
    private List<String> protectedAdminUrls;

    // Lớp DTO nội bộ để Gson tự động map dữ liệu từ file JSON vào
    private static class FilterConfigData {
        List<String> protectedAuthUrls;
        List<String> protectedAdminUrls;
        Map<String, String> urlPermissionMap;
    }

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        // Nạp file JSON từ thư mục resources
        try (InputStream is = getClass().getClassLoader().getResourceAsStream("permissions.json")) {
            if (is == null) {
                throw new RuntimeException("Không tìm thấy file permissions.json trong thư mục resources!");
            }
            try (InputStreamReader reader = new InputStreamReader(is, StandardCharsets.UTF_8)) {
                Gson gson = new Gson();
                FilterConfigData configData = gson.fromJson(reader, FilterConfigData.class);

                // Đổ dữ liệu vào biến của Filter
                this.protectedAuthUrls = configData.protectedAuthUrls;
                this.protectedAdminUrls = configData.protectedAdminUrls;
                this.urlPermissionMap = configData.urlPermissionMap;
            }
        } catch (Exception e) {
            throw new ServletException("Lỗi khi đọc file cấu hình phân quyền", e);
        }
    }

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

        // Duyệt qua List lấy từ JSON
        for (String protectedUrl : protectedAuthUrls) {
            if (path.startsWith(protectedUrl)) {
                isProtected = true;
                break;
            }
        }

        // Duyệt qua List lấy từ JSON
        for (String adminUrl : protectedAdminUrls) {
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