package controller;

import dao.SecurityAttemptDAO;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import model.AuthTypes;
import model.Cart;
import model.User;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.slf4j.MDC;
import services.*;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

@WebServlet(name = "NormalLogin", value = "/login")
public class NormalLogin extends HttpServlet {
    UserValidationServices userValidationServices = new UserValidationServices();
    AuthServices authServices = new AuthServices();
    UserService userService = new UserService();
    SecurityAttemptDAO securityAttemptDAO = new SecurityAttemptDAO();
    private final AuthTypes actionTypeLogin = AuthTypes.LOGIN;
    private static final Logger log = LoggerFactory.getLogger(NormalLogin.class);

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/auth/Login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        authServices.baseSetupMdc(request, "searching for email that doesn't exist");
        try {
            String username = request.getParameter("username");
            String pass = request.getParameter("password");
            String recaptchaResponse = request.getParameter("g-recaptcha-response");
            Map<String, String> allErrors = new HashMap<>(
                    userValidationServices.validateBothUsernameAndEmail(username, pass));

            User account;
            AuthServices authService = new AuthServices();
            if (allErrors.isEmpty()) {
                String loginKey = username.trim();
                String clientIp = userService.getClientIp(request);
                String targetEmail = authService.resolveEmail(loginKey);

                int failedAttempts = securityAttemptDAO.getFailedAttempts(targetEmail, clientIp, actionTypeLogin, 15);
                request.setAttribute("failedAttempts", failedAttempts);

                if (authService.isBlocked(targetEmail, clientIp, actionTypeLogin, 5, 15)) {
                    log.warn("IP {} cố gắng đăng nhập vào {} nhưng đã bị khóa tạm thời.", clientIp, username);
                    request.setAttribute("loginError", "Bạn đã nhập sai quá nhiều. Vui lòng thử lại sau 15 phút.");
                    request.getRequestDispatcher("/auth/Login.jsp").forward(request, response);
                    return;
                }
                if (failedAttempts >= 3 && failedAttempts < 5) {
                    if (!CaptchaVerifier.verify(recaptchaResponse)) {
                        request.setAttribute("loginError", "Vui lòng xác minh bạn không phải là người máy!");
                        request.getRequestDispatcher("/auth/Login.jsp").forward(request, response);
                        return;
                    }
                }
                account = authService.login(username, pass);
                String emailOrUsername;
                if (username.contains("@")) {
                    emailOrUsername = username.toLowerCase();
                } else {
                    emailOrUsername = username + "(username)";
                }
                MDC.put("email", emailOrUsername);
                if (account != null) {
                    if (account.getActive() == 1) {
                        log.info("Đăng nhập thành công");
                        securityAttemptDAO.resetAttempts(targetEmail, clientIp, actionTypeLogin);
                        // ================
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
                    
                    services.CartSyncService cartSyncService = new services.CartSyncService();
                    cartSyncService.syncCart(account, session);
                    
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
                        log.warn("Đăng nhập thất bại: Tài khoản bị khoá");
                        request.setAttribute("loginError",
                                "Tài khoản của bạn đã bị khoá, vui lòng liên hệ Admin để giải quyết");
                        request.getRequestDispatcher("/auth/Login.jsp").forward(request, response);
                    }
                } else {
                    log.warn("Đăng nhập thất bại: Sai thông tin đăng nhập");
                    securityAttemptDAO.increaseAttempt(targetEmail, clientIp, actionTypeLogin);
                    int newAttempts = securityAttemptDAO.getFailedAttempts(targetEmail, clientIp, actionTypeLogin, 15);
                    request.setAttribute("failedAttempts", newAttempts);

                    if (newAttempts >= 5) {
                        EmailServices emailServices = new EmailServices();
                        new Thread(() -> {
                            emailServices.sendWarningBruteForcingMail(targetEmail, clientIp);
                        }).start();
                        request.setAttribute("loginError", "Bạn đã nhập sai quá nhiều. Vui lòng thử lại sau 15 phút.");
                    } else {
                        request.setAttribute("loginError", "Bạn đã nhập sai tên tài khoản hoặc mật khẩu");
                    }
                    request.getRequestDispatcher("/auth/Login.jsp").forward(request, response);
                }
            } else {
                log.info("Đăng nhập thất bại do lỗi validate form cho user");
                allErrors.forEach(request::setAttribute);
                request.getRequestDispatcher("/auth/Login.jsp").forward(request, response);
            }
        } finally {
            // rất quan trọng
            MDC.clear();
        }
    }
}