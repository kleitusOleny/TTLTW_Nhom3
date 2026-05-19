package controller;

import com.google.gson.Gson;
import external_service.ghn.Config;
import utils.HttpUtil;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet("/api/ghn/*")
public class GhnProxyController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        String pathInfo = request.getPathInfo();
        if (pathInfo == null) pathInfo = "";

        try {
            String result;
            switch (pathInfo) {
                case "/provinces":
                    result = HttpUtil.sendPost(
                            Config.BASE_URL + "/master-data/province",
                            Config.TOKEN, "{}");
                    break;

                case "/districts":
                    String provinceId = request.getParameter("province_id");
                    if (provinceId == null) {
                        response.setStatus(400);
                        response.getWriter().print("{\"message\":\"Missing province_id\"}");
                        return;
                    }
                    result = HttpUtil.sendPost(
                            Config.BASE_URL + "/master-data/district",
                            Config.TOKEN,
                            "{\"province_id\":" + Integer.parseInt(provinceId) + "}");
                    break;

                case "/wards":
                    String districtId = request.getParameter("district_id");
                    if (districtId == null) {
                        response.setStatus(400);
                        response.getWriter().print("{\"message\":\"Missing district_id\"}");
                        return;
                    }
                    result = HttpUtil.sendPost(
                            Config.BASE_URL + "/master-data/ward",
                            Config.TOKEN,
                            "{\"district_id\":" + Integer.parseInt(districtId) + "}");
                    break;

                default:
                    response.setStatus(404);
                    response.getWriter().print("{\"message\":\"Not found\"}");
                    return;
            }

            response.getWriter().print(result);

        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(500);
            response.getWriter().print("{\"code\":-1,\"message\":\"" + e.getMessage() + "\"}");
        }
    }
}
