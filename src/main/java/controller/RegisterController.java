package controller;

import dao.SecurityAttemptDAO;
import dao.UserDAO;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import model.AuthTypes;
import model.User;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.slf4j.MDC;
import services.AuthServices;
import services.CaptchaVerifier;
import services.UserService;
import services.UserValidationServices;

import java.io.IOException;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.util.HashMap;
import java.util.Map;

@WebServlet(name = "RegisterController", value = "/register")
public class RegisterController extends HttpServlet {
    UserDAO userDAO = new UserDAO();
    SecurityAttemptDAO securityAttemptDAO = new SecurityAttemptDAO();
    private final AuthTypes actionTypeRegister = AuthTypes.REGISTER;
    UserService userService = new UserService();
    AuthServices authServices = new AuthServices();
    private static final Logger log = LoggerFactory.getLogger(RegisterController.class);
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.getRequestDispatcher("/auth/Register.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String emailInput = request.getParameter("email");
        String email = emailInput.toLowerCase();

        String lastname = request.getParameter("lastname");
        String firstname = request.getParameter("firstname");
        String username = request.getParameter("username");
        String plainPassword = request.getParameter("password");
        String phoneNumber = request.getParameter("phone-number");
        String birth = request.getParameter("birth");
        String confirmPassword = request.getParameter("confirm-password");
        String clientIp = userService.getClientIp(request);

        authServices.baseSetupMdc(request, email);
        String recaptchaResponse = request.getParameter("g-recaptcha-response");
        if (!CaptchaVerifier.verify(recaptchaResponse)) {
            request.setAttribute("registerError", "Vui lòng xác minh bạn không phải là người máy!");
            request.getRequestDispatcher("/auth/Register.jsp").forward(request, response);
            return;
        }
        try {
            int registerCount = securityAttemptDAO.countRegisterAttemptsByIp(clientIp, 24);
            if (registerCount >= 3) {
                log.warn("IP {} đã vượt quá hạn mức tạo tài khoản cho phép trong 1 nga.", clientIp);
                request.setAttribute("registerError", "Địa chỉ mạng của bạn đã gửi quá nhiều yêu cầu đăng ký. Vui lòng thử lại sau 1 ngày.");
                request.getRequestDispatcher("/auth/Register.jsp").forward(request, response);
                return;
            }

            Map<String, String> allErrors = new HashMap<>();
            UserValidationServices userValidationServices = new UserValidationServices();
            allErrors.putAll(userValidationServices.validateEmail(email));
            if (userDAO.isEmailExist(email)) {
                allErrors.put("emailExistError", "Email này đã được dùng. Vui lòng chọn email khác");
            }
            allErrors.putAll(userValidationServices.validateFirstAndLastName(lastname, firstname));
            allErrors.putAll(userValidationServices.validateUsername(username));
            if (userDAO.isUsernameExist(username)) {
                allErrors.put("usernameExistError", "Tên tài khoản này đã được dùng. Vui lòng chọn tên tài khoản khác");
            }
            allErrors.putAll(userValidationServices.validatePassword(plainPassword));
            allErrors.putAll(userValidationServices.validatePhoneNumber(phoneNumber));
            if (userDAO.isPhoneNumExist(phoneNumber)) {
                allErrors.put("phoneNumExistError", "SĐT này đã được sử dụng. Vui lòng chọn sđt khác");
            }
            allErrors.putAll(userValidationServices.validateBirth(birth));
            allErrors.putAll(userValidationServices.isPasswordEqualConfirmed(plainPassword, confirmPassword));

            String registerUrl = "/auth/Register.jsp";
            // Nếu là false thì pass
            if (allErrors.isEmpty()) {
                securityAttemptDAO.increaseAttempt(email, clientIp, actionTypeRegister);
                log.info("Chờ xác thực tài khoản mới");
                String fullName = lastname + " " + firstname;
                LocalDate birthDay = LocalDate.parse(birth);
                Timestamp ts = Timestamp.valueOf(birthDay.atStartOfDay());

                authServices.register(fullName, email, username, plainPassword, phoneNumber, ts);
                HttpSession session = request.getSession();
                session.setAttribute("pendingEmail", email);
                response.sendRedirect("authentication");
            } else {
                log.warn("Lỗi validation khi đăng ký");
                allErrors.forEach(request::setAttribute);
                request.getRequestDispatcher(registerUrl).forward(request, response);
            }
        } finally {
            MDC.clear();
        }
    }
}
