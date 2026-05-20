package controller;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import services.AuthServices;
import services.UserValidationServices;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

@WebServlet(name = "ForgotPassword", value = "/forgotpassword")
public class RecoveryController extends HttpServlet {
    private static final Logger log = LoggerFactory.getLogger(RecoveryController.class);
    AuthServices authServices = new AuthServices();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.getRequestDispatcher("/auth/Recover.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        String plainPassword = request.getParameter("password");
        String confirmPassword = request.getParameter("confirm-password");

        UserValidationServices userValidationServices = new UserValidationServices();
        Map<String, String> allErrors = new HashMap<>();
        allErrors.putAll(userValidationServices.isPasswordEqualConfirmed(plainPassword, confirmPassword));
        allErrors.putAll(userValidationServices.validatePassword(plainPassword));

        authServices.baseSetupMdc(request, (String) session.getAttribute("otpEmail"));
        if (allErrors.isEmpty()){
            String emailGetFromSession = (String) session.getAttribute("otpEmail");
            if (emailGetFromSession != null) {
                boolean renewPassword = authServices.updatePasswordAfterAuthentication(emailGetFromSession, plainPassword);
                if (renewPassword) {
                    response.sendRedirect(request.getContextPath() + "/login");
                    log.info("Đã cập nhật mật khẩu mới");
                } else {
                    log.warn("Tài khoản không tồn tại");
                    request.setAttribute("userError", "Tài khoản này không tồn tại");
                }
            } else {
                log.error("Lỗi reset mật khẩu");
                response.sendRedirect(request.getContextPath() + "/authentication" + "?failResetPassword");
            }
        } else {
            log.error("Lỗi validation khi nhập mật khẩu mới");
            allErrors.forEach(request::setAttribute);
            request.getRequestDispatcher("/auth/Recover.jsp").forward(request, response);
        }
    }
}