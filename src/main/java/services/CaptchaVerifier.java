package services;

import io.github.cdimascio.dotenv.Dotenv;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;

import static services.EmailServices.loadDotenv;

public class CaptchaVerifier {
    static Dotenv dotenv = loadDotenv();
    private static final String SECRET_KEY = dotenv.get("CAPTCHA_SECRETKEY", System.getenv("CAPTCHA_SECRETKEY"));

    public static boolean verify(String gRecaptchaResponse) {
        if (gRecaptchaResponse == null || gRecaptchaResponse.trim().isEmpty()) {
            return false;
        }

        try {
            HttpClient client = HttpClient.newHttpClient();
            String postData = "secret=" + SECRET_KEY + "&response=" + gRecaptchaResponse;
            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create("https://www.google.com/recaptcha/api/siteverify"))
                    .header("Content-Type", "application/x-www-form-urlencoded")
                    .POST(HttpRequest.BodyPublishers.ofString(postData))
                    .build();

            // Nhận phản hồi trả về từ Google dạng chuỗi JSON
            HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());
            return response.body().contains("\"success\": true");
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
}
