package utils;

import java.io.*;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;

public class HttpUtil {

    public static String sendPost(
            String apiUrl,
            String token,
            String body
    ) throws Exception {
        return sendPost(apiUrl, token, null, body);
    }

    public static String sendPost(
            String apiUrl,
            String token,
            Integer shopId,
            String body
    ) throws Exception {

        URL url = new URL(apiUrl);

        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("POST");
        conn.setRequestProperty("Content-Type", "application/json; charset=UTF-8");
        conn.setRequestProperty("Token", token);

        if (shopId != null && shopId > 0) {
            conn.setRequestProperty("ShopId", String.valueOf(shopId));
        }

        conn.setDoOutput(true);

        try (OutputStream os = conn.getOutputStream()) {
            os.write(body.getBytes(StandardCharsets.UTF_8));
        }

        int status = conn.getResponseCode();
        InputStream is = (status >= 200 && status < 300)
                ? conn.getInputStream()
                : conn.getErrorStream();

        if (is == null) {
            throw new IOException("Server returned HTTP response code: " + status + " for URL: " + apiUrl);
        }

        try (BufferedReader br = new BufferedReader(new InputStreamReader(is, StandardCharsets.UTF_8))) {
            StringBuilder response = new StringBuilder();
            String line;
            while ((line = br.readLine()) != null) {
                response.append(line);
            }
            if (status < 200 || status >= 300) {
                throw new IOException("Server returned HTTP " + status + " for URL: " + apiUrl + " | Response: " + response);
            }
            return response.toString();
        }
    }

    public static String sendGet(String apiUrl, String token) throws Exception {
        URL url = new URL(apiUrl);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("GET");
        conn.setRequestProperty("Token", token);

        int status = conn.getResponseCode();
        InputStream is = (status >= 200 && status < 300)
                ? conn.getInputStream()
                : conn.getErrorStream();

        if (is == null) {
            throw new IOException("Server returned HTTP response code: " + status + " for URL: " + apiUrl);
        }

        try (BufferedReader br = new BufferedReader(new InputStreamReader(is, StandardCharsets.UTF_8))) {
            StringBuilder response = new StringBuilder();
            String line;
            while ((line = br.readLine()) != null) {
                response.append(line);
            }
            if (status < 200 || status >= 300) {
                throw new IOException("Server returned HTTP " + status + " for URL: " + apiUrl + " | Response: " + response);
            }
            return response.toString();
        }
    }
}