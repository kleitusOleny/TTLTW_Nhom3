package controller;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import model.Cart;
import model.User;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.slf4j.MDC;
import services.AuthServices;
import services.UserService;
import services.UserValidationServices;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

@WebServlet(name = "NormalLogin", value = "/login")
public class NormalLogin extends HttpServlet {
    private static final Logger log = LoggerFactory.getLogger(NormalLogin.class);

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/auth/Login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        UserValidationServices userValidationServices = new UserValidationServices();
        UserService userService = new UserService();

        // Setup MDC
        String clientIp = userService.getClientIp(request);
        String traceId = UUID.randomUUID().toString().substring(0, 4);

        MDC.put("client_ip", clientIp);
        MDC.put("trace_id", traceId);

        try {
            String username = request.getParameter("username");
            String pass = request.getParameter("password");
            log.info("Xử lí người dùng: {}", username);
            Map<String, String> allErrors = new HashMap<>(
                    userValidationServices.validateBothUsernameAndEmail(username, pass));

            User account;
            AuthServices authService = new AuthServices();
            if (allErrors.isEmpty()) {
                account = authService.login(username, pass);
                if (account != null) {
                    if (account.getActive() == 1) {
                        log.info("Đăng nhập thành công: {}", username);
                        HttpSession oldSession = request.getSession(false);
                        Cart cart = null;
                        Cart buyNowCart = null;
                        String checkoutType = null;

                        if (oldSession != null) {
                            cart = (Cart) oldSession.getAttribute("cart");
                            buyNowCart = (Cart) oldSession.getAttribute("buyNowCart");
                            checkoutType = (String) oldSession.getAttribute("checkoutType");
                            oldSession.invalidate();
                        }
                        HttpSession session = request.getSession(true);
                        session.setAttribute("user", account);

                        if (cart != null)
                            session.setAttribute("cart", cart);
                        if (buyNowCart != null)
                            session.setAttribute("buyNowCart", buyNowCart);
                        if (checkoutType != null)
                            session.setAttribute("checkoutType", checkoutType);

                        String redirect = request.getParameter("redirect");
                        if (account.getAdministrator() == 1) {
                            response.sendRedirect("dashboard");
                        } else if (redirect != null && !redirect.isEmpty()) {
                            if ("checkout".equals(redirect) || redirect.endsWith("/checkout")) {
                                if ("buyNow".equals(checkoutType)) {
                                    response.sendRedirect("checkout?from=buyNow&loginSuccess=1");
                                } else {
                                    response.sendRedirect("checkout?loginSuccess=1");
                                }
                            } else {
                                if (redirect.contains("?")) {
                                    response.sendRedirect(redirect + "&loginSuccess=1");
                                } else {
                                    response.sendRedirect(redirect + "?loginSuccess=1");
                                }
                            }
                        } else {
                            response.sendRedirect(request.getContextPath() + "/home?loginSuccess=1");
                        }
                    } else {
                        log.warn("Đăng nhập thất bại: Tài khoản bị khoá (username: {})", username);
                        request.setAttribute("loginError",
                                "Tài khoản của bạn đã bị khoá, vui lòng liên hệ Admin để giải quyết");
                        request.getRequestDispatcher("/auth/Login.jsp").forward(request, response);
                    }
                } else {
                    log.warn("Đăng nhập thất bại: Sai thông tin đăng nhập (username: {})", username);
                    request.setAttribute("loginError", "Bạn đã nhập sai tên tài khoản hoặc mật khẩu");
                    request.getRequestDispatcher("/auth/Login.jsp").forward(request, response);
                }
            } else {
                log.info("Đăng nhập thất bại do lỗi validate form cho user: {}", username);
                allErrors.forEach(request::setAttribute);
                request.getRequestDispatcher("/auth/Login.jsp").forward(request, response);
            }
        } finally {
            // rất quan trọng
            MDC.clear();
        }
    }
}