package external_service.ghtk;

import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import model.Order;
import model.OrderItem;
import model.Address;
import model.Product;
import utils.HttpUtil;

import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class Service {

    private static final Gson gson = new Gson();

    public static Map<String, Object> calculateFee(
            String province, String district, int weight
    ) {
        Map<String, Object> result = new HashMap<>();
        try {
            String api = Config.BASE_URL
                    + "/services/shipment/fee"
                    + "?pick_province=" + encode(Config.SHOP_PROVINCE)
                    + "&pick_district=" + encode(Config.SHOP_DISTRICT)
                    + "&province=" + encode(province)
                    + "&district=" + encode(district)
                    + "&weight=" + weight;

            String response = HttpUtil.sendGet(api, Config.TOKEN);
            System.out.println("[GHTK FEE] " + response);

            JsonObject json = gson.fromJson(response, JsonObject.class);

            boolean success = json.has("success") && json.get("success").getAsBoolean();
            if (!success) {
                result.put("status", "error");
                result.put("message", response);
                return result;
            }
            JsonObject fee = json.getAsJsonObject("fee");
            int totalFee = fee.get("fee").getAsInt();

            result.put("status", "success");
            result.put("carrier", "GHTK");
            result.put("fee", totalFee);
        } catch (Exception e) {
            e.printStackTrace();
            result.put("status", "error");
            result.put("message", e.getMessage());
        }
        return result;
    }

    public static Map<String, Object> calculateFeeByAddress(String provinceName, String districtName, int weight) {
        String cleanProvince = provinceName;
        String cleanDistrict = districtName;
        try {
            String provResponse = HttpUtil.sendPost(external_service.ghn.Config.BASE_URL + "/master-data/province",
                    external_service.ghn.Config.TOKEN, "{}");
            JsonObject provJson = gson.fromJson(provResponse, JsonObject.class);
            JsonArray provinces = external_service.ghn.Service.safeGetArray(provJson, "data");

            int provinceId = -1;
            String normProvince = external_service.ghn.Service.stripPrefix(provinceName);
            String noAccentProv = external_service.ghn.Service.normalizeVn(normProvince);

            if (noAccentProv.contains("ha noi") || noAccentProv.contains("h n") || noAccentProv.contains("hanoi")) {
                provinceId = 201;
                cleanProvince = "Hà Nội";
            } else if (noAccentProv.contains("ho chi minh") || noAccentProv.contains("hcm")
                    || noAccentProv.contains("tphcm") || noAccentProv.contains("sai gon")) {
                provinceId = 202;
                cleanProvince = "Hồ Chí Minh";
            } else {
                for (JsonElement el : provinces) {
                    JsonObject p = el.getAsJsonObject();
                    String name = p.get("ProvinceName").getAsString();
                    if (external_service.ghn.Service.matchName(name, normProvince)) {
                        provinceId = p.get("ProvinceID").getAsInt();
                        cleanProvince = name;
                        break;
                    }
                }
            }

            if (provinceId != -1) {
                String distResponse = HttpUtil.sendPost(external_service.ghn.Config.BASE_URL + "/master-data/district",
                        external_service.ghn.Config.TOKEN, "{\"province_id\":" + provinceId + "}");
                JsonObject distJson = gson.fromJson(distResponse, JsonObject.class);
                JsonArray districts = external_service.ghn.Service.safeGetArray(distJson, "data");

                String normDistrict = external_service.ghn.Service.stripPrefix(districtName);
                for (JsonElement el : districts) {
                    JsonObject d = el.getAsJsonObject();
                    String name = d.get("DistrictName").getAsString();
                    if (external_service.ghn.Service.matchName(name, normDistrict)) {
                        cleanDistrict = name;
                        break;
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return calculateFee(cleanProvince, cleanDistrict, weight);
    }

    public static Map<String, Object> createOrder(
            Order order,
            Address shippingAddress,
            List<OrderItem> items,
            Map<String, Product> productMap,
            double totalWeightKg,
            double pickMoney
    ) {
        Map<String, Object> result = new HashMap<>();
        try {
            JsonArray productsArray = new JsonArray();
            int totalProductValue = 0;

            for (OrderItem item : items) {
                JsonObject product = new JsonObject();
                String productName = "San pham";
                double itemWeightKg = Math.max(0.1, totalWeightKg / Math.max(1, items.size()));

                if (productMap != null && productMap.containsKey(item.getProductId())) {
                    Product p = productMap.get(item.getProductId());
                    productName = p.getProductName();
                }

                product.addProperty("name", productName);
                product.addProperty("weight", itemWeightKg);
                product.addProperty("quantity", item.getQuantity());
                product.addProperty("product_code", item.getProductId());
                productsArray.add(product);

                totalProductValue += (int) (item.getUnitPrice() * item.getQuantity());
            }

            String pickDate = LocalDate.now().plusDays(1)
                    .format(DateTimeFormatter.ofPattern("yyyy/MM/dd"));

            JsonObject orderObj = new JsonObject();
            orderObj.addProperty("id", String.valueOf(order.getId()));
            orderObj.addProperty("pick_name", Config.SHOP_NAME);
            orderObj.addProperty("pick_address", Config.SHOP_ADDRESS);
            orderObj.addProperty("pick_province", Config.SHOP_PROVINCE);
            orderObj.addProperty("pick_district", Config.SHOP_DISTRICT);
            orderObj.addProperty("pick_ward", Config.SHOP_WARD);
            orderObj.addProperty("pick_tel", Config.SHOP_TEL);
            orderObj.addProperty("tel", shippingAddress.getPhoneNumber() != null ? shippingAddress.getPhoneNumber() : "");
            orderObj.addProperty("name", shippingAddress.getFullName() != null ? shippingAddress.getFullName() : "");
            orderObj.addProperty("address", shippingAddress.getAddressLine() != null ? shippingAddress.getAddressLine() : "");
            orderObj.addProperty("province", shippingAddress.getCity() != null ? shippingAddress.getCity() : "");
            orderObj.addProperty("district", shippingAddress.getDistrict() != null ? shippingAddress.getDistrict() : "");
            orderObj.addProperty("ward", shippingAddress.getWard() != null ? shippingAddress.getWard() : "");
            orderObj.addProperty("hamlet", "Khac");
            orderObj.addProperty("is_freeship", pickMoney > 0 ? "0" : "1");
            orderObj.addProperty("pick_date", pickDate);
            orderObj.addProperty("pick_money", (long) pickMoney);
            orderObj.addProperty("note", order.getNote() != null ? order.getNote() : "");
            orderObj.addProperty("value", totalProductValue);
            orderObj.addProperty("transport", "road");
            orderObj.addProperty("pick_option", "cod");

            JsonObject requestBody = new JsonObject();
            requestBody.add("products", productsArray);
            requestBody.add("order", orderObj);

            String jsonBody = gson.toJson(requestBody);
            System.out.println("[GHTK CREATE ORDER] Request: " + jsonBody);

            String response = HttpUtil.sendPost(
                    Config.BASE_URL + "/services/shipment/order/?ver=1.5",
                    Config.TOKEN,
                    jsonBody
            );

            System.out.println("[GHTK CREATE ORDER] Response: " + response);

            JsonObject responseJson = gson.fromJson(response, JsonObject.class);
            boolean success = responseJson.has("success") && responseJson.get("success").getAsBoolean();

            if (success) {
                result.put("status", "success");
                result.put("message", "Tao don hang GHTK thanh cong");

                if (responseJson.has("order")) {
                    JsonObject orderData = responseJson.getAsJsonObject("order");
                    if (orderData.has("label")) {
                        result.put("label", orderData.get("label").getAsString());
                    }
                    if (orderData.has("tracking_id")) {
                        result.put("tracking_id", orderData.get("tracking_id").getAsInt());
                    }
                    if (orderData.has("fee")) {
                        result.put("ghtk_fee", orderData.get("fee").getAsInt());
                    }
                    if (orderData.has("area")) {
                        result.put("area", orderData.get("area").getAsString());
                    }
                }
            } else {
                result.put("status", "error");
                String msg = responseJson.has("message") ? responseJson.get("message").getAsString() : response;
                result.put("message", msg);
                if (responseJson.has("error")) {
                    result.put("error", responseJson.getAsJsonObject("error"));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            result.put("status", "error");
            result.put("message", e.getMessage());
        }
        return result;
    }

    public static Map<String, Object> trackingOrder(String trackingCode) {
        Map<String, Object> result = new HashMap<>();
        try {
            String url = Config.BASE_URL + "/services/shipment/v2/" + encode(trackingCode);
            System.out.println("[GHTK TRACKING] URL: " + url);

            String response = HttpUtil.sendGet(url, Config.TOKEN);
            System.out.println("[GHTK TRACKING] Response: " + response);

            JsonObject json = gson.fromJson(response, JsonObject.class);
            boolean success = json.has("success") && json.get("success").getAsBoolean();

            if (success) {
                result.put("status", "success");
                if (json.has("order")) {
                    JsonObject order = json.getAsJsonObject("order");
                    result.put("label_id", getStr(order, "label_id"));
                    result.put("partner_id", getStr(order, "partner_id"));
                    result.put("order_status", getStr(order, "status"));
                    result.put("status_text", getStr(order, "status_text"));
                    result.put("created", getStr(order, "created"));
                    result.put("modified", getStr(order, "modified"));
                    result.put("message", getStr(order, "message"));
                    result.put("pick_date", getStr(order, "pick_date"));
                    result.put("deliver_date", getStr(order, "deliver_date"));
                    result.put("customer_fullname", getStr(order, "customer_fullname"));
                    result.put("customer_tel", getStr(order, "customer_tel"));
                    result.put("address", getStr(order, "address"));
                    result.put("ship_money", getInt(order, "ship_money"));
                    result.put("insurance", getInt(order, "insurance"));
                    result.put("value", getInt(order, "value"));
                    result.put("weight", getInt(order, "weight"));
                    result.put("pick_money", getInt(order, "pick_money"));
                    result.put("is_freeship", getInt(order, "is_freeship"));
                }
            } else {
                result.put("status", "error");
                result.put("message", json.has("message") ? json.get("message").getAsString() : response);
            }
        } catch (Exception e) {
            e.printStackTrace();
            result.put("status", "error");
            result.put("message", e.getMessage());
        }
        return result;
    }

    public static Map<String, Object> cancelOrder(String trackingCode) {
        Map<String, Object> result = new HashMap<>();
        try {
            String url = Config.BASE_URL + "/services/shipment/cancel/" + encode(trackingCode);
            System.out.println("[GHTK CANCEL] URL: " + url);

            String response = HttpUtil.sendGet(url, Config.TOKEN);
            System.out.println("[GHTK CANCEL] Response: " + response);

            JsonObject json = gson.fromJson(response, JsonObject.class);
            boolean success = json.has("success") && json.get("success").getAsBoolean();

            result.put("status", success ? "success" : "error");
            result.put("message", json.has("message") ? json.get("message").getAsString() : "");
            if (json.has("log_id")) {
                result.put("log_id", json.get("log_id").getAsString());
            }
        } catch (Exception e) {
            e.printStackTrace();
            result.put("status", "error");
            result.put("message", e.getMessage());
        }
        return result;
    }

    private static String getStr(JsonObject obj, String key) {
        return (obj.has(key) && !obj.get(key).isJsonNull()) ? obj.get(key).getAsString() : "";
    }

    private static int getInt(JsonObject obj, String key) {
        return (obj.has(key) && !obj.get(key).isJsonNull()) ? obj.get(key).getAsInt() : 0;
    }

    private static String encode(String value) {
        return URLEncoder.encode(value, StandardCharsets.UTF_8);
    }
}
