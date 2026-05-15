package controller;

import com.google.gson.Gson;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Province;
import services.ProvinceService;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "ProvinceController", value = "/api/provinces")
public class ProvinceController extends HttpServlet {
    private ProvinceService provinceService;
    private Gson gson;

    public ProvinceController() {
        this.provinceService = new ProvinceService();
        this.gson = new Gson();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("application/json;charset=UTF-8");
        List<Province> provinces = provinceService.getAllProvinces();
        response.getWriter().write(gson.toJson(provinces));
    }
}
