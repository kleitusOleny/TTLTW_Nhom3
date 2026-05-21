package external_service.paypal;

import io.github.cdimascio.dotenv.Dotenv;

public class Config {
    public static Dotenv dotenv;
    
    public static String CLIENT_ID = "AYt3n-hI-5xWzH7G8Qe-1zJyR2o7t9XW_9eF4h0y-uI7oPqW3nZ6mY8xP2aC"; // Placeholder
    public static String CLIENT_SECRET = "EPr4h0y-uI7oPqW3nZ6mY8xP2aC_AYt3n-hI-5xWzH7G8Qe-1zJyR2o7t9XW"; // Placeholder
    public static String MODE = "sandbox"; 
    public static String ENDPOINT = "https://api-m.sandbox.paypal.com";
    
    public static String REDIRECT_URL = "http://localhost:8080/TTLTW_Nhom3_war/paypalReturn";
    public static String CANCEL_URL = "http://localhost:8080/TTLTW_Nhom3_war/checkout";

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
                String envClientId = dotenv.get("PAYPAL_CLIENT_ID", dotenv.get("PAYPAL_Client_ID", System.getenv("PAYPAL_CLIENT_ID")));
                if (envClientId != null && !envClientId.isEmpty()) CLIENT_ID = envClientId;

                String envSecret = dotenv.get("PAYPAL_CLIENT_SECRET", dotenv.get("PAYPAL_Secret", System.getenv("PAYPAL_CLIENT_SECRET")));
                if (envSecret != null && !envSecret.isEmpty()) CLIENT_SECRET = envSecret;

                String envMode = dotenv.get("PAYPAL_MODE", System.getenv("PAYPAL_MODE"));
                if (envMode != null && !envMode.isEmpty()) {
                    MODE = envMode;
                    if ("live".equalsIgnoreCase(MODE)) {
                        ENDPOINT = "https://api-m.paypal.com";
                    } else {
                        ENDPOINT = "https://api-m.sandbox.paypal.com";
                    }
                }

                String envRedirect = dotenv.get("PAYPAL_REDIRECT_URL", System.getenv("PAYPAL_REDIRECT_URL"));
                if (envRedirect != null && !envRedirect.isEmpty()) REDIRECT_URL = envRedirect;

                String envCancel = dotenv.get("PAYPAL_CANCEL_URL", System.getenv("PAYPAL_CANCEL_URL"));
                if (envCancel != null && !envCancel.isEmpty()) CANCEL_URL = envCancel;
            }
        } catch (Exception e) {
            System.err.println("Error loading .env file in PayPal Config: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
