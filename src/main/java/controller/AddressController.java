package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Address;
import model.User;
import services.AddressService;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "AddressController", value = "/address")
public class AddressController extends HttpServlet {
    private AddressService addressService;

    public AddressController() {
        addressService = new AddressService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            HttpSession session = request.getSession(false);
            if (session == null) {
                response.sendRedirect(request.getContextPath() + "/login");
                return;
            }
            User user = (User) session.getAttribute("user");
            if (user == null) {
                String requestedWith = request.getHeader("X-Requested-With");
                if ("XMLHttpRequest".equals(requestedWith)) {
                    response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                    response.getWriter().write("{\"error\":\"not_authenticated\"}");
                    return;
                }
                response.sendRedirect(request.getContextPath() + "login");
                return;
            }
            List<Address> addressList = addressService.getByUserID(user.getId());
            request.setAttribute("addressList", addressList);
            request.getRequestDispatcher("/info_users/addresses.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            throw new ServletException("Error loading addresses", e);
        }

    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            String requestedWith = request.getHeader("X-Requested-With");
            if ("XMLHttpRequest".equals(requestedWith)) {
                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                response.setContentType("application/json;charset=UTF-8");
                response.getWriter().write("{\"success\": false, \"error\": \"session_expired\"}");
                return;
            }
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        User user = (User) session.getAttribute("user");
        String action = request.getParameter("action");
        System.out.println("AddressController: action=" + action + ", city=" + request.getParameter("city")
                + ", district=" + request.getParameter("district") + ", ward=" + request.getParameter("ward"));

        try {
            switch (action) {
                case "add": {
                    addressService.handleAdd(request, user);
                    session.setAttribute("success", "Thêm địa chỉ thành công");
                    break;
                }
                case "delete": {
                    addressService.handleDelete(request, user);
                    session.setAttribute("success", "Xóa địa chỉ thành công");

                    break;
                }
                case "edit": {
                    addressService.handleUpdate(request, user);
                    session.setAttribute("success", "Cập nhật địa chỉ thành công");
                    break;
                }
                case "default": {
                    addressService.handleSetDefault(request, user);
                    session.setAttribute("success", "Đặt địa chỉ mặc định thành công");
                    break;
                }
                default:
                    throw new IllegalArgumentException("Action không hợp lệ");
            }

            String requestedWith = request.getHeader("X-Requested-With");
            if ("XMLHttpRequest".equalsIgnoreCase(requestedWith)) {
                response.setContentType("application/json;charset=UTF-8");
                response.getWriter().write("{\"success\": true}");
                return;
            }

        } catch (Exception e) {
            e.printStackTrace();
            String requestedWith = request.getHeader("X-Requested-With");
            if ("XMLHttpRequest".equalsIgnoreCase(requestedWith)) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.setContentType("application/json;charset=UTF-8");
                String detailedMsg = e.getClass().getSimpleName() + ": " + ((e.getMessage() != null) ? e.getMessage().replace("\"", "'") : "No message");
                response.getWriter().write("{\"success\": false, \"error\": \"" + detailedMsg + "\"}");
                return;
            }
            session.setAttribute("error", e.getMessage());
        }

        // Final check for AJAX before redirecting
        String requestedWith = request.getHeader("X-Requested-With");
        if ("XMLHttpRequest".equalsIgnoreCase(requestedWith)) {
            response.setContentType("application/json;charset=UTF-8");
            response.getWriter().write("{\"success\": true}");
            return;
        }
        String view = request.getParameter("view");
        if ("popup".equals(view)) {
            response.sendRedirect(request.getContextPath() + "/address?view=popup");
        } else {
            response.sendRedirect(
                    request.getContextPath() + "/info_users/user_sidebar.jsp#" + request.getContextPath() + "/address");
        }
    }

}
