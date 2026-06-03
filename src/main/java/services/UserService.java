package services;

import dao.CTEvaluateDAO;
import dao.EvaluateDAO;
import dao.ProductDAO;
import dao.FavouriteDAO;
import dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.CTEvaluates;
import model.Evaluates;
import model.Product;
import model.User;
import org.mindrot.jbcrypt.BCrypt;

import java.io.IOException;
import java.sql.Timestamp;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.*;

public class UserService {
    private final UserDAO userDAO = new UserDAO();
    private final FavouriteDAO favouriteDAO = new FavouriteDAO();

    public boolean updateProfile(User newUser) {
        if (newUser == null)
            return false;

        User currentUser = userDAO.findById(newUser.getId()).orElse(null);
        if (currentUser == null)
            return false;

        if (!Objects.equals(currentUser.getEmail(), newUser.getEmail())) {
            if (userDAO.findByEmail(newUser.getEmail()) != null) {
                throw new IllegalArgumentException("Email đã tồn tại");
            }
            currentUser.setEmail(newUser.getEmail());
        }

        if (newUser.getUsername() != null)
            currentUser.setUsername(newUser.getUsername());

        if (newUser.getFullName() != null)
            currentUser.setFullName(newUser.getFullName());

        if (newUser.getBirthDay() != null)
            currentUser.setBirthDay(newUser.getBirthDay());

        if (newUser.getPhoneNumber() != null)
            currentUser.setPhoneNumber(newUser.getPhoneNumber());

        currentUser.setActive(newUser.getActive());

        return userDAO.save(currentUser) != null;
    }

    public void updateProfile(HttpServletRequest request, HttpServletResponse response)
            throws ParseException, ServletException, IOException {

        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;

        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String birthStr = request.getParameter("birthDay");
        String oldPassword = request.getParameter("oldPassword");
        String newPassword = request.getParameter("newPassword");

        UserValidationServices userValidationServices = new UserValidationServices();
        Map<String, String> allErrors = new HashMap<>();
        allErrors.putAll(userValidationServices.validateFullName(fullName));
        allErrors.putAll(userValidationServices.validateEmail(email));
        allErrors.putAll(userValidationServices.validatePhoneNumber(phone));
        allErrors.putAll(userValidationServices.validateBirth(birthStr));

        System.out.println(allErrors);

        if (allErrors.isEmpty()) {
            try {
                LocalDate birthDay = LocalDate.parse(birthStr);
                Timestamp ts = Timestamp.valueOf(birthDay.atStartOfDay());
                if (newPassword != null && !newPassword.isEmpty()) {
                    if (!BCrypt.checkpw(oldPassword, user.getPasswordHash())) {
                        request.setAttribute("errorPass", "Mật khẩu cũ không chính xác");
                        request.setAttribute("user", user);
                        request.getRequestDispatcher("/info_users/user_sidebar.jsp").forward(request,
                                response);
                        return;
                    }
                    allErrors.putAll(userValidationServices.validatePassword(newPassword));
                    if (!allErrors.containsKey("passwordError")) {
                        user.setPasswordHash(BCrypt.hashpw(newPassword, BCrypt.gensalt(12)));
                    }
                }

                user.setFullName(fullName);
                user.setEmail(email);
                user.setPhoneNumber(phone);
                user.setBirthDay(ts);

                boolean isUpdated = this.userDAO.save(user) != null;

                if (isUpdated) {
                    session.setAttribute("user", user);
                    request.setAttribute("success", "Cập nhật thông tin thành công!");
                } else {
                    request.setAttribute("error", "Có lỗi xảy ra khi lưu vào hệ thống.");
                }

            } catch (Exception e) {
                request.setAttribute("error", "Định dạng ngày không hợp lệ.");
            }
        } else {
            // allErrors.forEach(request::setAttribute);
            request.setAttribute("errors", allErrors);
        }
        request.getRequestDispatcher("/info_users/user_sidebar.jsp").forward(request, response);
    }

    public String getFullUrl(HttpServletRequest request, String page) {
        StringBuilder url = new StringBuilder(request.getContextPath() + "/user");
        if (page != null && !"info".equals(page)) {
            url.append("?page=").append(page);
        }
        return url.toString();
    }

    public void dispatchSubPage(String page, User user, HttpServletRequest request, HttpServletResponse response,
            EvaluateService evaluateService)
            throws ServletException, IOException {
        String path = "/info_users/";
        switch (page) {
            case "reviews":
                List<Evaluates> reviewData = evaluateService.getUserReviewHistory(user.getId());
                Map<String, Product> productsMap = new HashMap<>();
                Map<Integer, CTEvaluates> reviewsMap = new HashMap<>();
                ProductDAO pDao = new ProductDAO();
                CTEvaluateDAO ctDao = new CTEvaluateDAO();
                for (Evaluates e : reviewData) {
                    Product p = pDao.getProductById(e.getId());
                    if (p != null) productsMap.put(e.getId(), p);
                    
                    CTEvaluates ct = ctDao.findById(e.getEvaluatesId()).orElse(null);
                    if (ct != null) reviewsMap.put(e.getEvaluatesId(), ct);
                }
                request.setAttribute("evaluates", reviewData);
                request.setAttribute("products", productsMap);
                request.setAttribute("reviews", reviewsMap);
                request.getRequestDispatcher(path + "review_history.jsp").forward(request, response);
                break;
            case "favorites":
                List<Map<String, Object>> favorites = favouriteDAO.getFavouritesWithProductsByUserID(user.getId());
                request.setAttribute("favouritesList", favorites);
                request.getRequestDispatcher(path + "favorites.jsp").forward(request, response);
                break;
            case "settings":
                request.getRequestDispatcher(path + "settings.jsp").forward(request, response);
                break;
            case "support":
                request.getRequestDispatcher(path + "support.jsp").forward(request, response);
                break;
            default:
                request.setAttribute("user", user);
                request.getRequestDispatcher(path + "info_user.jsp").forward(request, response);
                break;
        }
    }

    public String getClientIp(HttpServletRequest request) {
        String[] headerNames = {
                "CF-Connecting-IP", // cloudflare
                "X-Forwarded-For",
                "Proxy-Client-IP",
                "WL-Proxy-Client-IP"
        };
        String ipAddress = null;
        for (String header : headerNames) {
            ipAddress = request.getHeader(header);
            if (ipAddress != null && !ipAddress.isEmpty() && !"unknown".equalsIgnoreCase(ipAddress)) {
                break;
            }
        }
        if (ipAddress == null || ipAddress.isEmpty() || "unknown".equalsIgnoreCase(ipAddress)) {
            ipAddress = request.getRemoteAddr();
            // xử lý chạy trên localhost
            if ("0:0:0:0:0:0:0:1".equals(ipAddress)) {
                ipAddress = "127.0.0.1";
            }
        }
        // nếu qua nhiều proxy thì lấy IP đầu tiên
        if (ipAddress != null && ipAddress.length() > 15 && ipAddress.indexOf(",") > 0) {
            ipAddress = ipAddress.substring(0, ipAddress.indexOf(","));
        }
        return ipAddress;
    }
}
