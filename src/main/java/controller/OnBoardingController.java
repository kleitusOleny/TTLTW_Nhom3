package controller;

import dao.UserDAO;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import model.User;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import services.AuthServices;
import services.UserValidationServices;

import java.io.IOException;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.util.HashMap;
import java.util.Map;

@WebServlet(name = "OnBoardingController", value = "/onboarding")
public class OnBoardingController extends HttpServlet {
    private static final Logger log = LoggerFactory.getLogger(OnBoardingController.class);
    AuthServices authServices = new AuthServices();
    UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.getRequestDispatcher("/auth/OnBoarding.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String emailToken = (String) request.getSession().getAttribute("googleEmail");
        if (emailToken == null) {
            response.sendRedirect(request.getContextPath() + "login");
        }
        String lastname = request.getParameter("lastname");
        String firstname = request.getParameter("firstname");
        String username = request.getParameter("username");
        String phoneNumber = request.getParameter("phone-number");
        String birth = request.getParameter("birth");

        UserValidationServices userValidationServices = new UserValidationServices();
        Map<String, String> allErrors = new HashMap<>();
        allErrors.putAll(userValidationServices.validateFirstAndLastName(lastname, firstname));
        allErrors.putAll(userValidationServices.validateUsername(username));
        if (userDAO.isUsernameExist(username)) {
            allErrors.put("usernameExistError", "Tên tài khoản này đã được dùng. Vui lòng chọn tên tài khoản khác");
        }
        allErrors.putAll(userValidationServices.validatePhoneNumber(phoneNumber));
        if (userDAO.isPhoneNumExist(phoneNumber)) {
            allErrors.put("phoneNumExistError", "SĐT này đã được sử dụng. Vui lòng chọn sđt khác");
        }
        allErrors.putAll(userValidationServices.validateBirth(birth));

        User account;
        String onBoardingUrl = "/auth/OnBoarding.jsp";
        authServices.baseSetupMdc(request, emailToken);
        AuthServices authService = new AuthServices();
        // Nếu là false thì pass
        if (allErrors.isEmpty()) {
            String fullName = lastname + " " + firstname;
            HttpSession session = request.getSession();
            LocalDate birthDay = LocalDate.parse(birth);
            Timestamp ts = Timestamp.valueOf(birthDay.atStartOfDay());
            account = authService.register(fullName, emailToken, username, null, phoneNumber, ts);
            if (account != null) {
                session.setAttribute("user", account);
                response.sendRedirect(request.getContextPath() + "/home" + "?loginSuccess");
                log.info("Đăng kí thành công từ luồng Google");
            } else {
                response.sendRedirect(request.getContextPath() + "onboarding");
            }
        } else {
            log.error("Lỗi validation");
            allErrors.forEach(request::setAttribute);
            request.getRequestDispatcher(onBoardingUrl).forward(request, response);
        }
    }
}
