package external_service.ghtk;

import io.github.cdimascio.dotenv.Dotenv;

public class Config {
    public static Dotenv dotenv;
    public static String TOKEN;
    public static String PARTNER_CODE;
    public static String BASE_URL = "https://services.giaohangtietkiem.vn";
    public static String SHOP_PROVINCE;
    public static String SHOP_DISTRICT;
    public static String SHOP_NAME;
    public static String SHOP_TEL;
    public static String SHOP_ADDRESS;
    public static String SHOP_WARD;
    static {
        try {
            java.net.URL resource = Config.class.getClassLoader().getResource(".env");
            if (resource != null) {
                String path = new java.io.File(resource.toURI()).getParent();
                dotenv = Dotenv.configure()
                        .directory(path)
                        .ignoreIfMissing()
                        .load();
            } else {
                dotenv = Dotenv.configure()
                        .ignoreIfMissing()
                        .load();
            }
        } catch (Exception e) {
            dotenv = Dotenv.configure()
                    .ignoreIfMissing()
                    .load();
        }
        TOKEN = dotenv.get("GHTK_TOKEN", System.getenv("GHTK_TOKEN"));
        if (TOKEN == null || TOKEN.isEmpty()) {
            System.err.println("WARNING: GHTK TOKEN is not configured!");
        }

        PARTNER_CODE = dotenv.get("GHTK_PARTNER_CODE", System.getenv("GHTK_PARTNER_CODE"));
        if (PARTNER_CODE == null) PARTNER_CODE = "";

        String shopProv = dotenv.get("SHOP_PROVINCE", System.getenv("SHOP_PROVINCE"));
        SHOP_PROVINCE = shopProv != null ? shopProv.trim() : "Hồ Chí Minh";

        String shopDist = dotenv.get("SHOP_DISTRICT", System.getenv("SHOP_DISTRICT"));
        SHOP_DISTRICT = shopDist != null ? shopDist.trim() : "Thành Phố Thủ Đức";

        String shopName = dotenv.get("SHOP_NAME", System.getenv("SHOP_NAME"));
        SHOP_NAME = shopName != null ? shopName.trim() : "Shop TTLTW";

        String shopTel = dotenv.get("SHOP_TEL", System.getenv("SHOP_TEL"));
        SHOP_TEL = shopTel != null ? shopTel.trim() : "0900000000";

        String shopAddr = dotenv.get("SHOP_ADDRESS", System.getenv("SHOP_ADDRESS"));
        SHOP_ADDRESS = shopAddr != null ? shopAddr.trim() : "590 CMT8";

        String shopWard = dotenv.get("SHOP_WARD", System.getenv("SHOP_WARD"));
        SHOP_WARD = shopWard != null ? shopWard.trim() : "Phường 11";
    }
}
