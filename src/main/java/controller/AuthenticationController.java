package controller;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import model.User;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.slf4j.MDC;
import services.AuthServices;
import services.EmailServices;
import services.UserService;

import java.io.IOException;

@WebServlet(name = "AuthenticationController", value = "/authentication")
public class AuthenticationController extends HttpServlet {
    AuthServices authService = new AuthServices();
    EmailServices emailServices = new EmailServices();
    UserService userService = new UserService();
    private static final Logger log = LoggerFactory.getLogger(AuthenticationController.class);

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.getRequestDispatcher("/auth/Authentication.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String emailInput = request.getParameter("email");
        String action = request.getParameter("action");
        String otpInput = request.getParameter("otpInput");

        HttpSession session = request.getSession();
        User account = (User) session.getAttribute("pendingUser");

        String finalEmail = "GUEST";
        if (account != null && account.getEmail() != null) {
            finalEmail = account.getEmail();
        } else if (emailInput != null && !emailInput.isEmpty()) {
            finalEmail = emailInput.toLowerCase();
        }

        authService.baseSetupMdc(request, finalEmail);

        // ------------------------ Button cho lấy mã OTP ---------------------------------
        try {
            if ("send-otp".equals(action)) {
                if (emailInput == null || emailInput.trim().isEmpty() || !emailInput.matches("^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$")) {
                    log.warn("Email không đúng định dạng: {}", emailInput);
                    request.setAttribute("emailError", "Email không đúng định dạng hoặc bị bỏ trống");
                }
                else {
                    Long lastOtpTime = (Long) session.getAttribute("otpTime");
                    if (lastOtpTime != null && (System.currentTimeMillis() - lastOtpTime < 60000)) {
                        long secondsLeft = (60000 - (System.currentTimeMillis() - lastOtpTime)) / 1000;
                        request.setAttribute("emailError", "Vui lòng đợi " + secondsLeft + " giây nữa để gửi lại mã");
                    }
                    else {
                        if (account != null) {
                            // luồng từ register
                            if (!emailInput.equalsIgnoreCase(account.getEmail())) {
                                log.warn("Người dùng đang cố xác thực với email khác: {}", emailInput);
                                request.setAttribute("emailError", "Email không khớp với thông tin đã đăng ký!");
                            } else {
                                authService.sendAndSaveOtp(emailInput, authService.generateRandomOtp(), session, request, emailServices);
                            }
                        } else {
                            // luồng quên mật khẩu
                            String generatedOtp = authService.generateOtp(emailInput);
                            if (generatedOtp != null) {
                                authService.sendAndSaveOtp(emailInput, generatedOtp, session, request, emailServices);
                            } else {
                                log.warn("Email {} không tồn tại để gửi mã OTP", emailInput);
                                request.setAttribute("emailError", "Email không tồn tại trên hệ thống");
                            }
                        }
                    }
                }
                request.getRequestDispatcher("/auth/Authentication.jsp").forward(request, response);

                // ------------------------ Button cho xác nhận ---------------------------------
            } else if ("finish-otp".equals(action)) {
                String storedOtp = (String) session.getAttribute("otpCode");
                if (otpInput != null && otpInput.equals(storedOtp)) {
                    if (account != null) {
                        // luồng từ register
                        User realAccount = authService.register(
                                account.getFullName(), account.getEmail(), account.getUsername(),
                                account.getPasswordHash(), account.getPhoneNumber(), account.getBirthDay()
                        );
                        if (realAccount != null) {
                            log.info("Xác thực OTP thành công, đã khởi tạo tài khoản hệ thống");
                            session.removeAttribute("pendingUser");
                            session.setAttribute("user", realAccount);
                            session.removeAttribute("otpCode");
                            response.sendRedirect(request.getContextPath() + "/home" + "?registerSuccess");
                        } else {
                            log.error("Lỗi lưu dữ liệu");
                            request.setAttribute("otpError", "Lỗi lưu dữ liệu, vui lòng thử lại!");
                            request.getRequestDispatcher("/auth/Authentication.jsp").forward(request, response);
                        }
                    } else {
                        // Luồng từ quên mật khẩu
                        session.removeAttribute("otpCode");
                        response.sendRedirect(request.getContextPath() + "/forgotpassword");
                    }
                } else {
                    log.info("Xác thực OTP thành công cho luồng Quên mật khẩu");
                    request.setAttribute("otpError", "Mã OTP không chính xác!");
                    request.getRequestDispatcher("/auth/Authentication.jsp").forward(request, response);
                }
            }
        } finally {
           MDC.clear();
        }
    }
}