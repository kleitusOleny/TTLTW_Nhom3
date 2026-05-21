package external_service.momo;

import io.github.cdimascio.dotenv.Dotenv;

public class Config {
    public static Dotenv dotenv;
    public static String PARTNER_CODE = "MOMOIQA420180417";
    public static String ACCESS_KEY = "mTCKt9W3eU1m39TW";
    public static String SECRET_KEY = "PPuDXq1KowPT1ftR8DvlQTHhC03aul17";

    public static String MOMO_ENDPOINT = "https://test-payment.momo.vn/v2/gateway/api/create";

    public static String REDIRECT_URL = "https://google.com.vn";
    public static String NOTIFY_URL = "https://google.com.vn";

    static {
        try {
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

            if (dotenv != null) {
                String envPartnerCode = dotenv.get("MOMO_PARTNER_CODE", System.getenv("MOMO_PARTNER_CODE"));
                if (envPartnerCode != null && !envPartnerCode.isEmpty()) PARTNER_CODE = envPartnerCode;

                String envAccessKey = dotenv.get("MOMO_ACCESS_KEY", System.getenv("MOMO_ACCESS_KEY"));
                if (envAccessKey != null && !envAccessKey.isEmpty()) ACCESS_KEY = envAccessKey;

                String envSecretKey = dotenv.get("MOMO_SECRET_KEY", System.getenv("MOMO_SECRET_KEY"));
                if (envSecretKey != null && !envSecretKey.isEmpty()) SECRET_KEY = envSecretKey;

                String envEndpoint = dotenv.get("MOMO_ENDPOINT", System.getenv("MOMO_ENDPOINT"));
                if (envEndpoint != null && !envEndpoint.isEmpty()) MOMO_ENDPOINT = envEndpoint;

                String envRedirect = dotenv.get("MOMO_REDIRECT_URL", System.getenv("MOMO_REDIRECT_URL"));
                if (envRedirect != null && !envRedirect.isEmpty()) REDIRECT_URL = envRedirect;

                String envNotify = dotenv.get("MOMO_NOTIFY_URL", System.getenv("MOMO_NOTIFY_URL"));
                if (envNotify != null && !envNotify.isEmpty()) NOTIFY_URL = envNotify;
            }
        } catch (Exception e) {
            System.err.println("Error loading .env file in Momo Config: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
