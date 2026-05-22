package controller;

import dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Cart;
import model.User;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.slf4j.MDC;
import services.AuthServices;

import java.io.IOException;

@WebServlet("/LoginGoogle")
public class LoginGoogle extends HttpServlet {
    private static final Logger log = LoggerFactory.getLogger(LoginGoogle.class);
    AuthServices authServices = new AuthServices();
    UserDAO userDao = new UserDAO();

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws IOException, ServletException {
        authServices.baseSetupMdc(request, "searching for email that doesn't exist");

        try {
            // Google gửi mã xác thực qua tham số "credential"
            String idTokenString = request.getParameter("credential");
            AuthServices authService = new AuthServices();
            String emailFromGoogleToken = authService.getEmailFromGoogleToken(idTokenString);
            MDC.put("email", emailFromGoogleToken);
            User user = userDao.findByEmail(emailFromGoogleToken);

            if (user != null) {
                if (user.getActive() == 1) {
                    log.info("Đăng nhập thành công");
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
                    session.setAttribute("user", user);

                    if (cart != null)
                        session.setAttribute("cart", cart);
                    if (buyNowCart != null)
                        session.setAttribute("buyNowCart", buyNowCart);
                    if (checkoutType != null)
                        session.setAttribute("checkoutType", checkoutType);

                    String redirect = request.getParameter("redirect");
                    if (user.getAdministrator() == 1) {
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
                log.info("Thông tin người dùng mới từ Google, chuyển về OnBoarding");
                request.getSession().setAttribute("googleEmail", emailFromGoogleToken);
                response.sendRedirect(request.getContextPath() + "/onboarding");
            }
        } finally {
            MDC.clear();
        }
    }
}