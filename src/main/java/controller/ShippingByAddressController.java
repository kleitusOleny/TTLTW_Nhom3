package controller;

import com.google.gson.Gson;
import external_service.ghn.Service;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.Map;

@WebServlet("/api/shipping-by-address")
public class ShippingByAddressController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json; charset=UTF-8");
        response.setCharacterEncoding("UTF-8");
        response.setHeader("Cache-Control", "no-cache");

        Gson gson = new Gson();

        String city     = request.getParameter("city");
        String district = request.getParameter("district");
        String ward     = request.getParameter("ward");
        String weightStr = request.getParameter("weight");

        if (city == null || city.trim().isEmpty()
                || district == null || district.trim().isEmpty()
                || ward == null || ward.trim().isEmpty()) {
            response.setStatus(400);
            response.getWriter().print(gson.toJson(Map.of(
                    "status", "error",
                    "message", "Thiếu thông tin địa chỉ (city, district, ward)"
            )));
            return;
        }

        int weight = 500;
        if (weightStr != null && !weightStr.isEmpty()) {
            try { weight = Integer.parseInt(weightStr); } catch (NumberFormatException ignored) {}
        }

        try {
            Map<String, Object> ghnResult = external_service.ghn.Service.calculateFeeByAddress(
                    city.trim(), district.trim(), ward.trim(), weight);
            Map<String, Object> ghtkResult = external_service.ghtk.Service.calculateFeeByAddress(
                    city.trim(), district.trim(), weight);

            response.getWriter().print(gson.toJson(Map.of(
                    "status", "success",
                    "ghn", ghnResult,
                    "ghtk", ghtkResult
            )));
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(500);
            response.getWriter().print(gson.toJson(Map.of(
                    "status", "error",
                    "message", "Lỗi tính phí vận chuyển: " + e.getMessage()
            )));
        }
    }
}
