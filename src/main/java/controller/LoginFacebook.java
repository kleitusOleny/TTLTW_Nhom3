package controller;

import dao.UserDAO;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import model.FacebookUser;
import model.User;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.slf4j.MDC;
import services.AuthServices;
import utils.FacebookUtils;

import java.io.IOException;

@WebServlet(name = "LoginFacebook", value = "/login-facebook")
public class LoginFacebook extends HttpServlet {
    private static final Logger log = LoggerFactory.getLogger(LoginFacebook.class);
    AuthServices authServices = new AuthServices();
    UserDAO userDao = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        authServices.baseSetupMdc(request, "none");
        try {
            String code = request.getParameter("code");
            String redirectParam = request.getParameter("state");

            if (code == null || code.isEmpty()) {
                log.warn("Facebook trả về mã code rỗng hoặc null");
                response.sendRedirect(request.getContextPath() + "/login?loginError=1");
                return;
            }
            String accessToken = FacebookUtils.getAccessToken(code, request);
            FacebookUser fbUser = FacebookUtils.getUserInfo(accessToken);

            String emailFromFbToken = fbUser.getEmail();
            MDC.put("email", emailFromFbToken);
            User user = userDao.findByEmail(emailFromFbToken);

            if (user != null) {
                if (user.getActive() == 1) {
                    log.info("Đăng nhập bằng Facebook thành công: {}", emailFromFbToken);
                    request.getSession().setAttribute("user", user);
                    if (redirectParam != null && !redirectParam.isEmpty()) {
                        if (redirectParam.contains("checkout")) {
                            if (redirectParam.contains("from=buyNow")) {
                                response.sendRedirect("checkout?from=buyNow&loginSuccess=1");
                            } else {
                                response.sendRedirect("checkout?loginSuccess=1");
                            }
                        } else {
                            if (redirectParam.contains("?")) {
                                response.sendRedirect(redirectParam + "&loginSuccess=1");
                            } else {
                                response.sendRedirect(redirectParam + "?loginSuccess=1");
                            }
                        }
                    } else {
                        response.sendRedirect(request.getContextPath() + "/home?loginSuccess=1");
                    }
                } else {
                    log.warn("Đăng nhập thất bại: Tài khoản bị khoá -> {}", emailFromFbToken);
                    request.setAttribute("loginError", "Tài khoản của bạn đã bị khoá, vui lòng liên hệ Admin để giải quyết");
                    request.getRequestDispatcher("/auth/Login.jsp").forward(request, response);
                }
            } else {
                log.info("Người dùng Facebook mới, chuyển tiếp thông tin sang trang OnBoarding");
                request.getSession().setAttribute("googleEmail", emailFromFbToken);
                response.sendRedirect(request.getContextPath() + "/onboarding");
            }
        } catch (Exception e) {
            log.error("Lỗi xảy ra trong tiến trình Đăng nhập Facebook", e);
            response.sendRedirect(request.getContextPath() + "/login?loginError=1");
        } finally {
            MDC.clear();
        }
    }
}