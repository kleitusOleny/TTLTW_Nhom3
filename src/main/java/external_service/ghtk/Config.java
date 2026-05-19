package external_service.ghtk;

import io.github.cdimascio.dotenv.Dotenv;

public class Config {
    public static Dotenv dotenv;
    public static  String TOKEN;
    public static  String BASE_URL ="https://services.giaohangtietkiem.vn";
    public static  String SHOP_PROVINCE;
    public static  String SHOP_DISTRICT;
    static{
        try {
            java.net.URL resource = external_service.ghn.Config.class.getClassLoader().getResource(".env");
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
        
        String shopProv = dotenv.get("SHOP_PROVINCE", System.getenv("SHOP_PROVINCE"));
        SHOP_PROVINCE = shopProv != null ? shopProv.trim() : "Hồ Chí Minh";
        
        String shopDist = dotenv.get("SHOP_DISTRICT", System.getenv("SHOP_DISTRICT"));
        SHOP_DISTRICT = shopDist != null ? shopDist.trim() : "Thành Phố Thủ Đức";
    }
}

