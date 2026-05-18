package external_service.ghn;


import utils.HttpUtil;
import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;

import java.util.HashMap;
import java.util.Map;

public class Service {

    public static Map<String, Object> calculateFee(
            int districtId,
            String wardCode,
            int weight
    ) {
        Map<String, Object> result = new HashMap<>();
        try {
            Gson gson = new Gson();

            // Bước 1: Lấy danh sách dịch vụ khả dụng cho tuyến này
            String serviceBody = """
                    {
                        "shop_id": %d,
                        "from_district": 1454,
                        "to_district": %d
                    }
                    """.formatted(Config.SHOP_ID, districtId);

            int serviceId = 2; // default fallback
            try {
                String serviceResponse = HttpUtil.sendPost(
                        Config.BASE_URL + "/v2/shipping-order/available-services",
                        Config.TOKEN, Config.SHOP_ID, serviceBody);
                JsonObject serviceJson = gson.fromJson(serviceResponse, JsonObject.class);
                JsonArray services = safeGetArray(serviceJson, "data");
                if (services != null && services.size() > 0) {
                    serviceId = services.get(0).getAsJsonObject().get("service_id").getAsInt();
                    for (JsonElement se : services) {
                        JsonObject s = se.getAsJsonObject();
                        if (s.has("service_type_id") && s.get("service_type_id").getAsInt() == 2) {
                            serviceId = s.get("service_id").getAsInt();
                            break;
                        }
                    }
                }
            } catch (Exception ignored) {
            }

            String body = """
                    {
                        "service_id": %d,
                        "from_district_id": 1454,
                        "to_district_id": %d,
                        "to_ward_code": "%s",
                        "height": 10,
                        "length": 20,
                        "weight": %d,
                        "width": 20,
                        "insurance_value": 100000
                    }
                    """.formatted(serviceId, districtId, wardCode, weight);

            String response = HttpUtil.sendPost(
                    Config.BASE_URL + "/v2/shipping-order/fee",
                    Config.TOKEN,
                    Config.SHOP_ID,
                    body
            );

            JsonObject json = gson.fromJson(response, JsonObject.class);
            JsonObject data = json.getAsJsonObject("data");
            if (data == null) {
                String msg = json.has("message") ? json.get("message").getAsString() : "Không nhận được dữ liệu từ GHN";
                result.put("status", "error");
                result.put("message", msg);
                return result;
            }

            int totalFee = data.get("total").getAsInt();
            result.put("status", "success");
            result.put("carrier", "GHN");
            result.put("fee", totalFee);

        } catch (Exception e) {
            e.printStackTrace();
            result.put("status", "error");
            result.put("message", e.getMessage());
        }

        return result;
    }


    public static int findDistrictId(String provinceName, String districtName) {
        try {
            Gson gson = new Gson();

            String provResponse = HttpUtil.sendPost(
                    Config.BASE_URL + "/master-data/province",
                    Config.TOKEN, "{}");
            JsonObject provJson = gson.fromJson(provResponse, JsonObject.class);
            JsonArray provinces = safeGetArray(provJson, "data");

            int provinceId = -1;
            String normProvince = stripPrefix(provinceName);
            String noAccentProv = normalizeVn(normProvince);

            if (noAccentProv.contains("ha noi") || noAccentProv.contains("h n") || noAccentProv.contains("hanoi")) {
                provinceId = 201;
                System.out.println("[GHN] Forced Province ID 201 for Hà Nội");
            } else {
                for (JsonElement el : provinces) {
                    JsonObject p = el.getAsJsonObject();
                    String name = p.get("ProvinceName").getAsString();
                    if (matchName(name, normProvince)) {
                        provinceId = p.get("ProvinceID").getAsInt();
                        System.out.println("[GHN] Province matched: " + name + " (id=" + provinceId + ")");
                        break;
                    }
                }
            }
            if (provinceId == -1) {
                System.out.println("[GHN] Province not found: " + provinceName + " (stripped: " + normProvince + ")");
                return -1;
            }

            String distResponse = HttpUtil.sendPost(
                    Config.BASE_URL + "/master-data/district",
                    Config.TOKEN,
                    "{\"province_id\":" + provinceId + "}");
            JsonObject distJson = gson.fromJson(distResponse, JsonObject.class);
            JsonArray districts = safeGetArray(distJson, "data");

            if (districts.size() == 0) {
                System.out.println("[GHN] No districts returned for province_id=" + provinceId);
                return -1;
            }

            String normDistrict = stripPrefix(districtName);
            for (JsonElement el : districts) {
                JsonObject d = el.getAsJsonObject();
                String name = d.get("DistrictName").getAsString();
                if (matchName(name, normDistrict)) {
                    int did = d.get("DistrictID").getAsInt();
                    System.out.println("[GHN] District matched: " + name + " (id=" + did + ")");
                    return did;
                }
            }
            System.out.println("[GHN] District not found: " + districtName + " (stripped: " + normDistrict + ") in province_id=" + provinceId);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return -1;
    }

    public static String findWardCode(int districtId, String wardName) {
        try {
            Gson gson = new Gson();
            String wardResponse = HttpUtil.sendPost(
                    Config.BASE_URL + "/master-data/ward",
                    Config.TOKEN,
                    "{\"district_id\":" + districtId + "}");
            JsonObject wardJson = gson.fromJson(wardResponse, JsonObject.class);
            JsonArray wards = safeGetArray(wardJson, "data");

            String normWard = stripPrefix(wardName);
            for (JsonElement el : wards) {
                JsonObject w = el.getAsJsonObject();
                String name = w.get("WardName").getAsString();
                if (matchName(name, normWard)) {
                    String wcode = w.get("WardCode").getAsString();
                    System.out.println("[GHN] Ward matched: " + name + " (code=" + wcode + ")");
                    return wcode;
                }
            }
            System.out.println("[GHN] Ward not found: " + wardName + " (stripped: " + normWard + ") in district_id=" + districtId);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public static Map<String, Object> calculateFeeByAddress(
            String provinceName, String districtName, String wardName, int weight) {
        Map<String, Object> result = new HashMap<>();
        try {
            int districtId = findDistrictId(provinceName, districtName);
            if (districtId == -1) {
                result.put("status", "error");
                result.put("message", "Không tìm thấy quận/huyện: " + districtName);
                return result;
            }

            String wardCode = findWardCode(districtId, wardName);
            if (wardCode == null) {
                result.put("status", "error");
                result.put("message", "Không tìm thấy phường/xã: " + wardName);
                return result;
            }

            return calculateFee(districtId, wardCode, weight);
        } catch (Exception e) {
            e.printStackTrace();
            result.put("status", "error");
            result.put("message", e.getMessage());
            return result;
        }
    }

    // ============================================================
    // Helper: an toàn lấy JsonArray, tránh ClassCastException khi data = null
    // ============================================================
    private static JsonArray safeGetArray(JsonObject obj, String key) {
        if (obj == null || !obj.has(key)) return new JsonArray();
        JsonElement el = obj.get(key);
        if (el == null || el.isJsonNull() || !el.isJsonArray()) return new JsonArray();
        return el.getAsJsonArray();
    }

    // ============================================================
    // Bỏ dấu tiếng Việt để so sánh fuzzy (ví dụ: "Bà Vì" = "Ba Vi")
    // ============================================================
    private static String normalizeVn(String s) {
        if (s == null) return "";
        String result = java.text.Normalizer.normalize(s, java.text.Normalizer.Form.NFD);
        result = result.replaceAll("\\p{InCombiningDiacriticalMarks}+", "");
        // Xử lý đ/Đ riêng vì không phải diacritical mark
        result = result.replace("đ", "d").replace("Đ", "D");
        return result.toLowerCase().replaceAll("\\s+", " ").trim();
    }

    private static final String[] PREFIXES = {
            "thành phố", "thanh pho", "tỉnh", "tinh", "quận", "quan",
            "huyện", "huyen", "thị xã", "thi xa",
            "phường", "phuong", "xã", "xa", "thị trấn", "thi tran",
            "tp", "tp."
    };

    private static String stripPrefix(String s) {
        if (s == null) return "";
        String lower = s.trim().toLowerCase().replaceAll("\\s+", " ");
        for (String prefix : PREFIXES) {
            if (lower.startsWith(prefix + " ")) {
                lower = lower.substring(prefix.length()).trim();
                break;
            }
        }
        // Thử lại với chuỗi đã bỏ dấu
        String noAccent = normalizeVn(s);
        for (String prefix : PREFIXES) {
            if (noAccent.startsWith(prefix + " ")) {
                noAccent = noAccent.substring(prefix.length()).trim();
                break;
            }
        }
        // Trả về cái nào ngắn hơn (đã strip tốt hơn)
        return lower.length() <= noAccent.length() ? lower : noAccent;
    }

    private static boolean matchName(String ghnName, String inputStripped) {
        if (ghnName == null || inputStripped == null || inputStripped.isEmpty()) return false;

        String ghnStripped    = stripPrefix(ghnName);
        String ghnLower       = ghnName.trim().toLowerCase().replaceAll("\\s+", " ");

        // 1. So khớp chính xác sau strip
        if (ghnStripped.equals(inputStripped)) return true;

        // 2. Contains
        if (ghnStripped.contains(inputStripped) || inputStripped.contains(ghnStripped)) return true;
        if (ghnLower.contains(inputStripped)    || inputStripped.contains(ghnLower))    return true;

        // 3. So sánh sau khi bỏ dấu (xử lý trường hợp DB không lưu dấu, hoặc lưu dấu khác)
        String ghnNoAccent    = normalizeVn(ghnStripped);
        String inputNoAccent  = normalizeVn(inputStripped);
        if (ghnNoAccent.equals(inputNoAccent)) return true;
        if (ghnNoAccent.contains(inputNoAccent) || inputNoAccent.contains(ghnNoAccent)) return true;

        // 4. Regex wildcard cho bất kỳ ký tự đặc biệt hoặc ký tự lỗi encoding (ví dụ '?', '', '\uFFFD', v.v.)
        // Thay thế tất cả các ký tự không phải chữ cái Tiếng Anh/Tiếng Việt, số hoặc khoảng trắng thành '?'
        String allowedPattern = "[^a-zA-Z0-9àáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹđÀÁẠẢÃÂẦẤẬẨẪĂẰẮẶẲẴÈÉẸẺẼÊỀẾỆỂỄÌÍỊỈĨÒÓỌỎÕÔỒỐỘỔỖƠỜỚỢỞỠÙÚỤỦŨƯỪỨỰỬỮỲÝỴỶỸĐ\\s]";
        String cleanedInput = inputStripped.replace('\u00A0', ' ').replaceAll(allowedPattern, "?");
        String cleanedGhn   = ghnStripped.replace('\u00A0', ' ').replaceAll(allowedPattern, "?");

        if (cleanedInput.contains("?") || cleanedGhn.contains("?")) {
            try {
                String regexInput = "\\Q" + cleanedInput.replace("?", "\\E.\\Q") + "\\E";
                regexInput = regexInput.replace("\\Q\\E", "");
                java.util.regex.Pattern pattern = java.util.regex.Pattern.compile(
                        regexInput, java.util.regex.Pattern.CASE_INSENSITIVE);
                if (pattern.matcher(ghnStripped).find() || pattern.matcher(ghnLower).find()) return true;

                String regexGhn = "\\Q" + cleanedGhn.replace("?", "\\E.\\Q") + "\\E";
                regexGhn = regexGhn.replace("\\Q\\E", "");
                if (java.util.regex.Pattern.compile(regexGhn, java.util.regex.Pattern.CASE_INSENSITIVE)
                        .matcher(inputStripped).find()) return true;
            } catch (Exception ignored) {}
        }

        return false;
    }
}
