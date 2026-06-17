package external_service.paypal;

import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.util.Base64;
import java.util.HashMap;
import java.util.Locale;
import java.util.Map;

public class Payment {

    public static String getAccessToken() {
        try {
            String auth = Config.CLIENT_ID + ":" + Config.CLIENT_SECRET;
            String encodedAuth = Base64.getEncoder().encodeToString(auth.getBytes(StandardCharsets.UTF_8));

            HttpClient client = HttpClient.newHttpClient();
            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create(Config.ENDPOINT + "/v1/oauth2/token"))
                    .header("Accept", "application/json")
                    .header("Accept-Language", "en_US")
                    .header("Authorization", "Basic " + encodedAuth)
                    .header("Content-Type", "application/x-www-form-urlencoded")
                    .POST(HttpRequest.BodyPublishers.ofString("grant_type=client_credentials"))
                    .build();

            HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());

            if (response.statusCode() == 200) {
                Gson gson = new Gson();
                JsonObject jsonResponse = gson.fromJson(response.body(), JsonObject.class);
                if (jsonResponse.has("access_token")) {
                    return jsonResponse.get("access_token").getAsString();
                }
            } else {
                System.err.println("PayPal OAuth failed with status: " + response.statusCode() + ", body: " + response.body());
            }
        } catch (Exception e) {
            System.err.println("Error obtaining PayPal access token:");
            e.printStackTrace();
        }
        return null;
    }

    public static String createPaymentUrl(String orderId, double amountVnd, String orderInfo) {
        return createPaymentUrl(orderId, amountVnd, orderInfo, Config.REDIRECT_URL, Config.CANCEL_URL);
    }

    public static String createPaymentUrl(String orderId, double amountVnd, String orderInfo, String redirectUrl, String cancelUrl) {
        try {
            String accessToken = getAccessToken();
            if (accessToken == null) {
                System.err.println("PayPal: Cannot create payment URL because Access Token is null.");
                return null;
            }

            double amountUsd = amountVnd / 25000.0;
            String formattedAmount = String.format(Locale.US, "%.2f", amountUsd);
            
            System.out.println("PayPal: Converting " + amountVnd + " VND to " + formattedAmount + " USD for orderId=" + orderId);

            Gson gson = new Gson();
            
            Map<String, Object> payload = new HashMap<>();
            payload.put("intent", "CAPTURE");

            Map<String, Object> purchaseUnit = new HashMap<>();
            purchaseUnit.put("reference_id", orderId + "_" + System.currentTimeMillis());
            purchaseUnit.put("description", orderInfo);

            Map<String, String> amountMap = new HashMap<>();
            amountMap.put("currency_code", "USD");
            amountMap.put("value", formattedAmount);
            purchaseUnit.put("amount", amountMap);

            payload.put("purchase_units", new Object[]{ purchaseUnit });

            Map<String, String> appContext = new HashMap<>();
            appContext.put("brand_name", "TTLTW Nhom3 Shop");
            appContext.put("landing_page", "NO_PREFERENCE");
            appContext.put("user_action", "PAY_NOW");
            appContext.put("return_url", redirectUrl + "?orderId=" + orderId);
            appContext.put("cancel_url", cancelUrl);
            payload.put("application_context", appContext);

            String jsonPayload = gson.toJson(payload);

            HttpClient client = HttpClient.newHttpClient();
            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create(Config.ENDPOINT + "/v2/checkout/orders"))
                    .header("Content-Type", "application/json")
                    .header("Authorization", "Bearer " + accessToken)
                    .POST(HttpRequest.BodyPublishers.ofString(jsonPayload))
                    .build();

            HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());

            System.out.println("PayPal Create Order Status Code: " + response.statusCode());
            
            if (response.statusCode() == 200 || response.statusCode() == 201) {
                JsonObject jsonResponse = gson.fromJson(response.body(), JsonObject.class);
                JsonArray links = jsonResponse.getAsJsonArray("links");
                for (JsonElement linkElem : links) {
                    JsonObject linkObj = linkElem.getAsJsonObject();
                    if ("approve".equalsIgnoreCase(linkObj.get("rel").getAsString())) {
                        return linkObj.get("href").getAsString();
                    }
                }
            } else {
                System.err.println("PayPal Create Order API failed: " + response.body());
            }
        } catch (Exception e) {
            System.err.println("Error creating PayPal payment:");
            e.printStackTrace();
        }
        return null;
    }

    public static boolean capturePayment(String paypalOrderId) {
        try {
            String accessToken = getAccessToken();
            if (accessToken == null) {
                System.err.println("PayPal Capture: Access Token is null.");
                return false;
            }

            HttpClient client = HttpClient.newHttpClient();
            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create(Config.ENDPOINT + "/v2/checkout/orders/" + paypalOrderId + "/capture"))
                    .header("Content-Type", "application/json")
                    .header("Authorization", "Bearer " + accessToken)
                    .POST(HttpRequest.BodyPublishers.ofString("{}"))
                    .build();

            HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());

            System.out.println("PayPal Capture Order Status Code: " + response.statusCode());
            System.out.println("PayPal Capture Response: " + response.body());

            if (response.statusCode() == 200 || response.statusCode() == 201) {
                Gson gson = new Gson();
                JsonObject jsonResponse = gson.fromJson(response.body(), JsonObject.class);
                if (jsonResponse.has("status")) {
                    String status = jsonResponse.get("status").getAsString();
                    return "COMPLETED".equalsIgnoreCase(status);
                }
            }
        } catch (Exception e) {
            System.err.println("Error capturing PayPal payment:");
            e.printStackTrace();
        }
        return false;
    }
}
