package utils;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import io.github.cdimascio.dotenv.Dotenv;
import jakarta.servlet.http.HttpServletRequest;
import model.FacebookUser;

import java.net.URI;
import java.net.URLEncoder;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;

import static services.EmailServices.loadDotenv;

public class FacebookUtils {
    public static String getAccessToken(String code, HttpServletRequest request) throws Exception {
        Dotenv dotenv = loadDotenv();
        String appId = dotenv.get("APP_ID_FB", System.getenv("APP_ID_FB"));
        String appSecret = dotenv.get("APP_SECRET_FB", System.getenv("APP_SECRET_FB"));

        String scheme = request.getScheme();
        String serverName = request.getServerName();
        int serverPort = request.getServerPort();
        String contextPath = request.getContextPath();
        String redirectUri = scheme + "://" + serverName + ":" + serverPort + contextPath + "/login-facebook";
        String url = "https://graph.facebook.com/v19.0/oauth/access_token?"
                + "client_id=" + appId
                + "&redirect_uri=" + URLEncoder.encode(redirectUri, StandardCharsets.UTF_8)
                + "&client_secret=" + appSecret
                + "&code=" + code;

        HttpClient client = HttpClient.newHttpClient();
        HttpRequest req = HttpRequest.newBuilder()
                .uri(URI.create(url))
                .GET()
                .build();

        HttpResponse<String> response = client.send(req, HttpResponse.BodyHandlers.ofString());
        JsonObject jsonObject = new Gson().fromJson(response.body(), JsonObject.class);
        return jsonObject.get("access_token").getAsString();
    }

    public static FacebookUser getUserInfo(String accessToken) throws Exception {
        String url = "https://graph.facebook.com/me?fields=id,name,email&access_token=" + accessToken;

        HttpClient client = HttpClient.newHttpClient();
        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(url))
                .GET()
                .build();

        HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());
        return new Gson().fromJson(response.body(), FacebookUser.class);
    }
}
