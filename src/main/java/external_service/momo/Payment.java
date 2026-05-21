package external_service.momo;

import com.google.gson.Gson;
import com.google.gson.JsonObject;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.UUID;

public class Payment {

    public static String createPaymentUrl(String orderId, double amountValue, String orderInfo) {

        try {

            String requestId = UUID.randomUUID().toString();

            String amount = String.valueOf((long) amountValue);

            String requestType = "captureWallet";

            String extraData = "";

            String momoOrderId = orderId + "_" + System.currentTimeMillis();

            orderInfo = "Thanh_toan_don_hang";

            String rawHash = "accessKey=" + Config.ACCESS_KEY + "&amount=" + amount + "&extraData=" + extraData + "&ipnUrl=" + Config.NOTIFY_URL + "&orderId=" + momoOrderId + "&orderInfo=" + orderInfo + "&partnerCode=" + Config.PARTNER_CODE + "&redirectUrl=" + Config.REDIRECT_URL + "&requestId=" + requestId + "&requestType=" + requestType;

            System.out.println("RAW HASH:");
            System.out.println(rawHash);

            String signature = SignUtils.hmacSHA256(rawHash, Config.SECRET_KEY);

            System.out.println("SIGNATURE:");
            System.out.println(signature);

            Map<String, Object> payload = new LinkedHashMap<>();

            payload.put("partnerCode", Config.PARTNER_CODE);

            payload.put("requestId", requestId);

            payload.put("amount", Long.parseLong(amount));

            payload.put("orderId", momoOrderId);

            payload.put("orderInfo", orderInfo);

            payload.put("redirectUrl", Config.REDIRECT_URL);

            payload.put("ipnUrl", Config.NOTIFY_URL);

            payload.put("lang", "vi");

            payload.put("extraData", extraData);

            payload.put("requestType", requestType);

            payload.put("signature", signature);

            Gson gson = new Gson();

            String jsonPayload = gson.toJson(payload);

            System.out.println("JSON REQUEST:");
            System.out.println(jsonPayload);

            // =========================
            // HTTP REQUEST
            // =========================
            HttpClient client = HttpClient.newHttpClient();

            HttpRequest request = HttpRequest.newBuilder().uri(URI.create(Config.MOMO_ENDPOINT)).header("Content-Type", "application/json").POST(HttpRequest.BodyPublishers.ofString(jsonPayload)).build();

            HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());

            System.out.println("STATUS CODE:");
            System.out.println(response.statusCode());

            System.out.println("RESPONSE:");
            System.out.println(response.body());

            // =========================
            // PARSE RESPONSE
            // =========================
            JsonObject jsonResponse = gson.fromJson(response.body(), JsonObject.class);

            if (jsonResponse.has("payUrl")) {
                return jsonResponse.get("payUrl").getAsString();
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }

    public static void main(String[] args) {

        String payUrl = createPaymentUrl("123", 50000, "Thanh_toan");

        System.out.println("PAY URL:");
        System.out.println(payUrl);
    }
}