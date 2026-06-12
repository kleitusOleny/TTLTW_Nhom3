import filter.WebFilter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.User;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.util.Arrays;
import java.util.Collections;

import static org.mockito.ArgumentMatchers.anyBoolean;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.*;

public class WebFilterTest {

    private WebFilter filter;
    private HttpServletRequest request;
    private HttpServletResponse response;
    private HttpSession session;
    private FilterChain chain;

    private final String CONTEXT_PATH = "/TTLTW_Nhom3";

    @BeforeEach
    void setUp() {
        filter = new WebFilter();
        request = mock(HttpServletRequest.class);
        response = mock(HttpServletResponse.class);
        session = mock(HttpSession.class);
        chain = mock(FilterChain.class);

        // Mặc định luôn trả về context path chuẩn
        when(request.getContextPath()).thenReturn(CONTEXT_PATH);

        // 🌟 Tuyệt chiêu khắc phục lỗi NullPointerException hôm trước
        when(request.getSession(anyBoolean())).thenReturn(session);
        when(request.getSession()).thenReturn(session);
    }

    // KIỂM THỬ BỎ QUA TỆP TĨNH (STATIC FILES)
    @Test
    @DisplayName("Cho phép tải các tệp tĩnh (CSS, JS, Hình ảnh) không cần check quyền")
    void testStaticFiles_PassesFilter() throws Exception {
        when(request.getRequestURI()).thenReturn(CONTEXT_PATH + "/assets/css/manage_roles.css");

        filter.doFilter(request, response, chain);

        verify(chain, times(1)).doFilter(request, response);
        verify(response, never()).sendRedirect(anyString());
    }

    // KIỂM THỬ TRANG XÁC THỰC (AUTH URLS)
    @Test
    @DisplayName("Chưa đăng nhập -> Cho phép vào trang /login bình thường")
    void testAuthUrl_NotLoggedIn_PassesFilter() throws Exception {
        when(request.getRequestURI()).thenReturn(CONTEXT_PATH + "/login");
        when(session.getAttribute("user")).thenReturn(null); // Chưa login

        filter.doFilter(request, response, chain);

        verify(chain, times(1)).doFilter(request, response);
        verify(response, never()).sendRedirect(anyString());
    }

    @Test
    @DisplayName("Đã đăng nhập -> Cố tình vào lại /login -> Đá về /home")
    void testAuthUrl_AlreadyLoggedIn_RedirectsToHome() throws Exception {
        when(request.getRequestURI()).thenReturn(CONTEXT_PATH + "/login");
        when(session.getAttribute("user")).thenReturn(new User());

        filter.doFilter(request, response, chain);

        verify(response, times(1)).sendRedirect(CONTEXT_PATH + "/home");
        verify(chain, never()).doFilter(request, response);
    }

    // KIỂM THỬ TRANG QUẢN TRỊ (ADMIN URLS) VÀ PHÂN QUYỀN (RBAC)
    @Test
    @DisplayName("Vào Admin nhưng CHƯA đăng nhập -> Đá về /login")
    void testAdminUrl_NotLoggedIn_RedirectsToLogin() throws Exception {
        when(request.getRequestURI()).thenReturn(CONTEXT_PATH + "/roles-manager");
        when(session.getAttribute("user")).thenReturn(null);

        filter.doFilter(request, response, chain);

        verify(response, times(1)).sendRedirect(CONTEXT_PATH + "/login");
    }

    @Test
    @DisplayName("Vào Admin nhưng KHÔNG CÓ quyền dashboard:read -> Đá về /home")
    void testAdminUrl_NoDashboardPermission_RedirectsToHome() throws Exception {
        when(request.getRequestURI()).thenReturn(CONTEXT_PATH + "/roles-manager");
        when(session.getAttribute("user")).thenReturn(new User());

        // mảng quyền rỗng, không có dashboard:read
        when(session.getAttribute("userPermissions")).thenReturn(Collections.emptyList());

        filter.doFilter(request, response, chain);

        verify(response, times(1)).sendRedirect(CONTEXT_PATH + "/home");
    }

    @Test
    @DisplayName("Vào Admin, CÓ dashboard:read, nhưng THIẾU quyền chi tiết của trang -> Đá về /dashboard kèm lỗi")
    void testAdminUrl_MissingSpecificPermission_RedirectsToDashboardWithError() throws Exception {
        // cố tình truy cập trang xóa vai trò (yêu cầu role:delete)
        when(request.getRequestURI()).thenReturn(CONTEXT_PATH + "/roles-manager/delete");
        when(session.getAttribute("user")).thenReturn(new User());

        // chỉ cấp quyền dashboard:read và quyền xem, không cấp quyền xóa
        when(session.getAttribute("userPermissions")).thenReturn(Arrays.asList("dashboard:read", "role:read"));

        filter.doFilter(request, response, chain);

        verify(session, times(1)).setAttribute(eq("authError"), anyString());

        verify(response, times(1)).sendRedirect(CONTEXT_PATH + "/dashboard");
        verify(chain, never()).doFilter(request, response);
    }

    @Test
    @DisplayName("Vào Admin, CÓ ĐỦ quyền chi tiết (Trực tiếp) -> Cho qua")
    void testAdminUrl_HasExactPermission_PassesFilter() throws Exception {
        when(request.getRequestURI()).thenReturn(CONTEXT_PATH + "/roles-manager/add");
        when(session.getAttribute("user")).thenReturn(new User());

        // cấp chuẩn xác quyền dashboard và upsert
        when(session.getAttribute("userPermissions")).thenReturn(Arrays.asList("dashboard:read", "role:upsert"));

        filter.doFilter(request, response, chain);

        verify(chain, times(1)).doFilter(request, response);
        verify(response, never()).sendRedirect(anyString());
    }

    // KIỂM THỬ CƠ CHẾ TÌM KIẾM ĐƯỜNG DẪN THEO TIỀN TỐ
    @Test
    @DisplayName("Đường dẫn lạ nhưng có chung tiền tố (Prefix fallback) -> Bắt đúng quyền")
    void testAdminUrl_PrefixFallback_MatchesCorrectPermission() throws Exception {
        // Một URL lạ không được khai báo trực tiếp trong Map (Ví dụ: /account-manager/export-excel)
        // Theo logic WebFilter, nó sẽ quét Map và thấy bắt đầu bằng /account-manager -> Yêu cầu account:read
        when(request.getRequestURI()).thenReturn(CONTEXT_PATH + "/account-manager/export-excel");
        when(session.getAttribute("user")).thenReturn(new User());

        // Cấp quyền account:read
        when(session.getAttribute("userPermissions")).thenReturn(Arrays.asList("dashboard:read", "account:read"));

        filter.doFilter(request, response, chain);

        // Vì fallback hoạt động tốt và user có quyền read, phải được cho qua!
        verify(chain, times(1)).doFilter(request, response);
    }
}