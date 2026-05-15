package controller;

import com.google.gson.Gson;
import model.Ward;
import services.WardService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.Collections;
import java.util.List;

@WebServlet(name = "WardController", value = "/api/wards")
public class WardController extends HttpServlet {
    private WardService wardService;
    private Gson gson;

    @Override
    public void init() throws ServletException {
        this.wardService = new WardService();
        this.gson = new Gson();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("application/json;charset=UTF-8");
        String provinceIdParam = request.getParameter("provinceId");
        String districtIdParam = request.getParameter("districtId");
        String provinceNameParam = request.getParameter("provinceName");
        String districtNameParam = request.getParameter("districtName");
        
        List<Ward> wards = Collections.emptyList();
        if (provinceIdParam != null && !provinceIdParam.isEmpty() && !"undefined".equals(provinceIdParam) &&
            districtIdParam != null && !districtIdParam.isEmpty() && !"undefined".equals(districtIdParam)) {
            wards = wardService.getWardsByDistrict(provinceIdParam, districtIdParam);
        }
        
        if (wards.isEmpty() && provinceNameParam != null && !provinceNameParam.isEmpty() && 
            districtNameParam != null && !districtNameParam.isEmpty()) {
            wards = wardService.getWardsByNames(provinceNameParam, districtNameParam);
        }
        
        response.getWriter().write(gson.toJson(wards));
    }
}
