package controller;

import com.google.gson.Gson;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.District;
import services.DistrictService;

import java.io.IOException;
import java.util.Collections;
import java.util.List;

@WebServlet(name = "DistrictController", value = "/api/districts")
public class DistrictController extends HttpServlet {
    private DistrictService districtService;
    private Gson gson;

    public DistrictController() {
        this.districtService = new DistrictService();
        this.gson = new Gson();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("application/json;charset=UTF-8");
        String provinceIdParam = request.getParameter("provinceId");
        String provinceNameParam = request.getParameter("provinceName");
        
        List<District> districts = Collections.emptyList();
        if (provinceIdParam != null && !provinceIdParam.isEmpty() && !"undefined".equals(provinceIdParam)) {
            districts = districtService.getDistrictsByProvince(provinceIdParam);
        }
        
        if (districts.isEmpty() && provinceNameParam != null && !provinceNameParam.isEmpty()) {
            districts = districtService.getDistrictsByProvinceName(provinceNameParam);
        }
        
        response.getWriter().write(gson.toJson(districts));
    }
}
