package services;

import com.google.api.client.googleapis.auth.oauth2.GoogleIdToken;
import com.google.api.client.googleapis.auth.oauth2.GoogleIdTokenVerifier;
import com.google.api.client.http.javanet.NetHttpTransport;
import com.google.api.client.json.gson.GsonFactory;
import dao.SecurityAttemptDAO;
import dao.UserDAO;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import model.AuthTypes;
import model.User;
import org.mindrot.jbcrypt.BCrypt;
import org.slf4j.MDC;

import java.io.IOException;
import java.security.GeneralSecurityException;
import java.sql.Timestamp;
import java.util.Collections;
import java.util.UUID;

public class AuthServices {
    private final UserDAO userDAO = new UserDAO();
    private final UserService userService = new UserService();

    private final SecurityAttemptDAO securityAttemptDAO = new SecurityAttemptDAO();
    private static final String CLIENT_ID = "561993862196-rspl5j67m79f0857je2sdrv8f75m2ijs.apps.googleusercontent.com";

    public String getEmailFromGoogleToken(String idTokenString){
        try {
            GoogleIdTokenVerifier verifier = new GoogleIdTokenVerifier.Builder(new NetHttpTransport(), new GsonFactory())
                    .setAudience(Collections.singletonList(CLIENT_ID))
                    .build();

            GoogleIdToken idToken = verifier.verify(idTokenString);
            if (idToken != null) {
                GoogleIdToken.Payload payload = idToken.getPayload();
                System.out.println(payload.getEmail());
                return payload.getEmail();
            }
        } catch (GeneralSecurityException | IOException e) {
            throw new RuntimeException(e);
        }
        return null;
    }

    public String generateOtp(String email) {
        User user = userDAO.findByEmail(email);
        String otp = null;
        if (user != null) {
            otp = String.valueOf((int) (Math.random() * 900000) + 100000);
            System.out.println("User " + email + " | OTP: " + otp);
        }
        return otp;
    }

    public String generateRandomOtp() {
        String otp = String.valueOf((int) (Math.random() * 900000) + 100000);
        System.out.println("OTP cho mail tam thoi: " + otp);
        return otp;
    }

    public User login(String loginKey, String plainPassword) {
        User user;
        if (loginKey.contains("@")) {
            user = userDAO.findByEmail(loginKey);
        } else {
            user = userDAO.findByUsername(loginKey);
        }
        if (user == null) return null;
        String hashedPass = user.getPasswordHash();
        if (hashedPass == null) {
            System.out.println("Tài khoản này được đăng kí thông qua Google");
            return null;
        }
        if (BCrypt.checkpw(plainPassword, hashedPass)) {
            return user;
        } else {
            return null;
        }
    }

    // Dù user có login bằng username cũng lấy được email
    public String resolveEmail(String loginKey) {
        // loginKey ở đây có thể là username hoặc là email
        // nếu loginKey chứa @ thì là email (vì đặt tên username đã validation chuyện này)
        if (loginKey.contains("@")) {
            return loginKey.toLowerCase();
        }
        User user = userDAO.findByUsername(loginKey);
        if (user != null && user.getEmail() != null) {
            return user.getEmail().toLowerCase();
        }
        return loginKey.toLowerCase();
    }

    // kiểm tra xem cặp IP/Email này có đang bị khóa không
    public boolean isBlocked(String email, String ipAddress, AuthTypes actionType, int attempts, int minuteForFailed) {
        int failedAttempts = securityAttemptDAO.getFailedAttempts(email, ipAddress, actionType, minuteForFailed);
        return failedAttempts >= attempts;
    }

    public User register(String fullName, String email, String username, String plainPassword, String phoneNumber, Timestamp birthday) {
        if (userDAO.countUserId(email) > 0) return null;
        String hashedPass = null;
        if (plainPassword != null && !plainPassword.isEmpty()){
               hashedPass = BCrypt.hashpw(plainPassword, BCrypt.gensalt(12));
        }

        User user = new User();
        user.setEmail(email);
        user.setUsername(username);
        user.setPasswordHash(hashedPass);
        user.setPhoneNumber(phoneNumber);
        user.setFullName(fullName);
        user.setBirthDay(birthday);
        user.setActive(1);
        user.setCreatedAt(new Timestamp(System.currentTimeMillis()));

        userDAO.save(user);
        return user;
    }

    public boolean updatePasswordAfterAuthentication(String email, String newPlainPassword) {
        User user = userDAO.findByEmail(email);
        if (user != null) {
            String hashedPass = BCrypt.hashpw(newPlainPassword, BCrypt.gensalt(12));
            userDAO.updatePassword(email, hashedPass);
            return true;
        }
        return false;
    }

    public void sendAndSaveOtp(String email, String otp, HttpSession session, HttpServletRequest request, EmailServices emailServices) {
        if (emailServices.sendOtpEmail(email, otp)) {
            session.setAttribute("otpCode", otp);
            session.setAttribute("otpEmail", email);
            session.setAttribute("otpTime", System.currentTimeMillis());
            request.setAttribute("message", "Mã OTP đã được gửi tới Google Mail của bạn");
        } else {
            request.setAttribute("emailError", "Lỗi gửi mail hệ thống, vui lòng thử lại sau");
        }
    }

    public void baseSetupMdc(HttpServletRequest request, String email) {
        String clientIp = userService.getClientIp(request);
        String traceId = UUID.randomUUID().toString().substring(0, 8);

        MDC.put("client_ip", clientIp);
        MDC.put("trace_id", traceId);
        MDC.put("email", email);
    }
}
