package services;

import io.github.cdimascio.dotenv.Dotenv;
import jakarta.mail.*;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;

import java.util.Properties;

public class EmailServices {
    public static Dotenv loadDotenv() {
        try {
            java.net.URL resource = EmailServices.class.getClassLoader().getResource(".env");
            if (resource != null) {
                String path = new java.io.File(resource.toURI()).getParent();
                return Dotenv.configure()
                        .directory(path)
                        .ignoreIfMissing()
                        .load();
            }
        } catch (Exception ignored) {}
        return Dotenv.configure().ignoreIfMissing().load();
    }

    Dotenv dotenv = loadDotenv();
    String username = dotenv.get("EMAIL", System.getenv("EMAIL"));
    String password = dotenv.get("APP_PASSWORD", System.getenv("APP_PASSWORD"));

    public boolean sendOtpEmail(String toEmail, String otp) {
        Properties props = new Properties();
        props.put("mail.smtp.host", "smtp.gmail.com");
        props.put("mail.smtp.port", "587");
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");

        Session session = Session.getInstance(props, new Authenticator() {
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(username, password);
            }
        });

        try {
            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(username));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
            message.setSubject("Mã xác thực OTP của bạn");
            message.setText("Chào bạn,\n\nMã OTP của bạn là: " + otp +
                    "\n\nMã này có hiệu lực trong 1 phút. Vui lòng không cung cấp mã này cho bất kỳ ai.");
            Transport.send(message);
            return true;
        } catch (MessagingException e) {
            return false;
        }
    }

    public boolean sendPaymentReminderEmail(String toEmail, int orderId, double amount) {
        Properties props = new Properties();
        props.put("mail.smtp.host", "smtp.gmail.com");
        props.put("mail.smtp.port", "587");
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");

        Session session = Session.getInstance(props, new Authenticator() {
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(username, password);
            }
        });

        try {
            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(username));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
            message.setSubject("Nhắc nhở thanh toán đơn hàng #" + orderId);
            message.setContent(
                    "<div style='font-family: Arial, sans-serif; max-width: 600px; margin: auto;'>"
                            + "<div style='background-color: #8c3333; padding: 20px; text-align: center;'>"
                            + "<h1 style='color: #fff; margin: 0;'>Nhắc nhở thanh toán</h1></div>"
                            + "<div style='padding: 30px; background-color: #f9f9f9;'>"
                            + "<p>Chào bạn,</p>"
                            + "<p>Đơn hàng <strong>#" + orderId + "</strong> của bạn chưa được thanh toán.</p>"
                            + "<p>Số tiền: <strong>" + String.format("%,.0f", amount) + "₫</strong></p>"
                            + "<p>Đơn hàng sẽ bị hủy nếu không được thanh toán trong thời gian quy định.</p>"
                            + "<p>Vui lòng liên hệ với chúng tôi nếu bạn gặp vấn đề trong quá trình thanh toán.</p>"
                            + "<p>Trân trọng,<br/>Đội ngũ hỗ trợ</p>"
                            + "</div></div>",
                    "text/html; charset=UTF-8");
            Transport.send(message);
            return true;
        } catch (MessagingException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean sendPaymentFailedEmail(String toEmail, int orderId, double amount) {
        Properties props = new Properties();
        props.put("mail.smtp.host", "smtp.gmail.com");
        props.put("mail.smtp.port", "587");
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");

        Session session = Session.getInstance(props, new Authenticator() {
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(username, password);
            }
        });

        try {
            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(username));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
            message.setSubject("Đơn hàng #" + orderId + " đã bị hủy");
            message.setContent(
                    "<div style='font-family: Arial, sans-serif; max-width: 600px; margin: auto;'>"
                            + "<div style='background-color: #dc3545; padding: 20px; text-align: center;'>"
                            + "<h1 style='color: #fff; margin: 0;'>Đơn hàng đã bị hủy</h1></div>"
                            + "<div style='padding: 30px; background-color: #f9f9f9;'>"
                            + "<p>Chào bạn,</p>"
                            + "<p>Đơn hàng <strong>#" + orderId + "</strong> đã bị hủy do không nhận được thanh toán trong thời gian quy định (12 giờ).</p>"
                            + "<p>Số tiền: <strong>" + String.format("%,.0f", amount) + "₫</strong></p>"
                            + "<p>Nếu bạn muốn đặt lại đơn hàng, vui lòng truy cập website của chúng tôi.</p>"
                            + "<p>Nếu bạn đã thanh toán nhưng vẫn nhận được email này, vui lòng liên hệ với chúng tôi ngay.</p>"
                            + "<p>Trân trọng,<br/>Đội ngũ hỗ trợ</p>"
                            + "</div></div>",
                    "text/html; charset=UTF-8");
            Transport.send(message);
            return true;
        } catch (MessagingException e) {
            e.printStackTrace();
            return false;
        }
    }
}
