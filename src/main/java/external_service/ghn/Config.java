package external_service.ghn;

import io.github.cdimascio.dotenv.Dotenv;

public class Config {
    public static Dotenv dotenv;
    public static  String TOKEN;

    public static  int SHOP_ID ;

    public static  String BASE_URL ="https://dev-online-gateway.ghn.vn/shiip/public-api";
    static{
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
        TOKEN = dotenv.get("GHN", System.getenv("GHN"));
        String shopIdStr = dotenv.get("SHOP_ID_GHN", System.getenv("SHOP_ID_GHN"));
        if (shopIdStr != null && !shopIdStr.isEmpty()) {
            try {
                SHOP_ID = Integer.parseInt(shopIdStr);
            } catch (NumberFormatException e) {
                SHOP_ID = 0;
            }
        } else {
            SHOP_ID = 0;
        }
        if (TOKEN == null || TOKEN.isEmpty()) {
            System.err.println("WARNING: GHN TOKEN is not configured!");
        }
        if (SHOP_ID <= 0) {
            System.err.println("WARNING: GHN SHOP_ID is not configured!");
        }
    }
}
