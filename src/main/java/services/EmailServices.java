package services;

import io.github.cdimascio.dotenv.Dotenv;
import jakarta.mail.*;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
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

    private Session baseMailSmtpSetup() {
        Properties props = new Properties();
        props.put("mail.smtp.host", "smtp.gmail.com");
        props.put("mail.smtp.port", "587");
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");

        return Session.getInstance(props, new Authenticator() {
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(username, password);
            }
        });
    }

    public boolean sendOtpEmail(String toEmail, String otp) {
        Session session = baseMailSmtpSetup();

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

    public void sendWarningBruteForcingMail(String toEmail, String clientIp) {
        Session session = baseMailSmtpSetup();
        String currentTime = LocalDateTime.now().format(DateTimeFormatter.ofPattern("dd-MM-yyyy HH:mm:ss"));
        try {
            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(username)); // username của tài khoản cấu hình SMTP Gmail
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));

            message.setSubject("[Cảnh báo Bảo mật] Phát hiện nhiều lần đăng nhập thất bại liên tiếp");
            String htmlContent = """
            <div style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif; line-height: 1.6; max-width: 550px; margin: 40px auto; padding: 32px; border: 1px solid #e2e8f0; border-radius: 12px; box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05); color: #334155;">
               \s
                <h2 style="color: #dc2626; font-size: 20px; font-weight: 600; margin-top: 0; margin-bottom: 24px; letter-spacing: -0.5px;">
                    Cảnh báo bảo mật
                </h2>
               \s
                <p style="margin-top: 0; margin-bottom: 16px;">Xin chào <strong style="color: #0f172a;">%s</strong>,</p>
                <p style="margin-bottom: 24px;">Hệ thống đã ghi nhận <strong style="color: #dc2626; font-weight: 600;">5 lần đăng nhập thất bại liên tiếp</strong> vào tài khoản của bạn.</p>
               \s
                <div style="background-color: #f8fafc; padding: 20px; border-left: 4px solid #dc2626; margin: 24px 0; border-radius: 4px;">
                    <table style="width: 100%%; border-collapse: collapse; font-size: 14px;">
                        <tr>
                            <td style="padding: 4px 0; color: #64748b; width: 100px; vertical-align: top;">Địa chỉ IP</td>
                            <td style="padding: 4px 0; color: #1e293b; font-weight: 500;">%s</td>
                        </tr>
                        <tr>
                            <td style="padding: 4px 0; color: #64748b; width: 100px; vertical-align: top;">Thời gian</td>
                            <td style="padding: 4px 0; color: #1e293b; font-weight: 500;">%s</td>
                        </tr>
                        <tr>
                            <td style="padding: 4px 0; color: #64748b; width: 100px; vertical-align: top;">Trạng thái</td>
                            <td style="padding: 4px 0; color: #b91c1c; font-weight: 500;">Tạm thời chặn kết nối từ IP này trong 15 phút.</td>
                        </tr>
                    </table>
                </div>
               \s
                <h3 style="color: #0f172a; font-size: 16px; font-weight: 600; margin-top: 24px; margin-bottom: 12px;">Hướng dẫn xử lý</h3>
                <ul style="margin: 0; padding-left: 20px; color: #475569;">
                    <li style="margin-bottom: 8px;"><strong style="color: #1e293b;">Nếu là bạn:</strong> Vui lòng đợi hết thời gian khóa để đăng nhập lại.</li>
                    <li style="margin-bottom: 8px;"><strong style="color: #1e293b;">Nếu không phải bạn:</strong> Có hành vi dò tìm mật khẩu. Tài khoản hiện tại vẫn an toàn, nhưng chúng tôi khuyến nghị bạn nên <strong style="color: #0284c7;">đổi mật khẩu ngay lập tức</strong> để đảm bảo an toàn.</li>
                </ul>
               \s
                <hr style="border: 0; border-top: 1px solid #edf2f7; margin: 32px 0;">
                <p style="font-size: 12px; color: #94a3b8; text-align: center; margin: 0;">Đây là email tự động từ hệ thống, vui lòng không phản hồi lại email này.</p>
            </div>
           \s""".formatted(toEmail, clientIp, currentTime);
            message.setContent(htmlContent, "text/html; charset=UTF-8");
            Transport.send(message);
            System.out.println("Đã gửi mail cảnh báo bảo mật tới: " + toEmail);
        } catch (MessagingException ignored) {
        }
    }

    public boolean sendPaymentReminderEmail(String toEmail, int orderId, double amount) {
        Session session = baseMailSmtpSetup();

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
        Session session = baseMailSmtpSetup();

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
