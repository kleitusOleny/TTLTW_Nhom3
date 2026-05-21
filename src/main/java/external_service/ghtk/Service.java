package external_service.ghtk;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import utils.HttpUtil;

import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.HashMap;
import java.util.Map;

public class Service {

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

            System.out.println("[GHTK RESPONSE] " + response);

            Gson gson = new Gson();

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
            Gson gson = new Gson();
            String provResponse = HttpUtil.sendPost(external_service.ghn.Config.BASE_URL + "/master-data/province", external_service.ghn.Config.TOKEN, "{}");
            JsonObject provJson = gson.fromJson(provResponse, JsonObject.class);
            com.google.gson.JsonArray provinces = external_service.ghn.Service.safeGetArray(provJson, "data");

            int provinceId = -1;
            String normProvince = external_service.ghn.Service.stripPrefix(provinceName);
            String noAccentProv = external_service.ghn.Service.normalizeVn(normProvince);

            if (noAccentProv.contains("ha noi") || noAccentProv.contains("h n") || noAccentProv.contains("hanoi")) {
                provinceId = 201;
                cleanProvince = "Hà Nội";
            } else if (noAccentProv.contains("ho chi minh") || noAccentProv.contains("hcm") || noAccentProv.contains("tphcm") || noAccentProv.contains("sai gon")) {
                provinceId = 202;
                cleanProvince = "Hồ Chí Minh";
            } else {
                for (com.google.gson.JsonElement el : provinces) {
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
                String distResponse = HttpUtil.sendPost(external_service.ghn.Config.BASE_URL + "/master-data/district", external_service.ghn.Config.TOKEN, "{\"province_id\":" + provinceId + "}");
                JsonObject distJson = gson.fromJson(distResponse, JsonObject.class);
                com.google.gson.JsonArray districts = external_service.ghn.Service.safeGetArray(distJson, "data");

                String normDistrict = external_service.ghn.Service.stripPrefix(districtName);
                for (com.google.gson.JsonElement el : districts) {
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

    private static String encode(String value) {

        return URLEncoder.encode(

                value,

                StandardCharsets.UTF_8);
    }
}