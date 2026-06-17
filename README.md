# 🍷 Đồ Án: Website Rượu Vang & Đồ Uống Cao Cấp

> **Thực tập Lập Trình Web - nhóm 38**  
> **Author:** [Oleny](https://github.com/kleitusOleny)  
> **Co-authors:** [Yuri](https://github.com/JukisYuri) & [Nguyễn Quang Minh](https://github.com/NguyenMinh032005)  
> **Cập nhật lần cuối:** 17/06/2026

---

## 🛠 Công Nghệ Sử Dụng

![Java](https://img.shields.io/badge/Java-ED8B00?style=for-the-badge&logo=java&logoColor=white)
![JSP](https://img.shields.io/badge/JSP-007396?style=for-the-badge&logo=java&logoColor=white)
![MySQL](https://img.shields.io/badge/MySQL-4479A1?style=for-the-badge&logo=mysql&logoColor=white)
![Gradle](https://img.shields.io/badge/Gradle-02303A?style=for-the-badge&logo=gradle&logoColor=white)
![HTML5](https://img.shields.io/badge/HTML5-E34F26?style=for-the-badge&logo=html5&logoColor=white)
![CSS3](https://img.shields.io/badge/CSS3-1572B6?style=for-the-badge&logo=css3&logoColor=white)
![JavaScript](https://img.shields.io/badge/JavaScript-F7DF1E?style=for-the-badge&logo=javascript&logoColor=black)
![Bootstrap](https://img.shields.io/badge/Bootstrap-563D7C?style=for-the-badge&logo=bootstrap&logoColor=white)

---

## 📖 Mục Lục

1. [Tổng Quan Tính Năng](#-tổng-quan-tính-năng)
2. [Điểm Nổi Bật Ở Giai Đoạn 2](#-điểm-nổi-bật-ở-giai-đoạn-2-cuối-kì)
3. [Hướng Dẫn Cài Đặt & Sử Dụng](#-hướng-dẫn-cài-đặt--sử-dụng)
4. [Thư Viện & Tài Nguyên](#-thư-viện--tài-nguyên)
5. [Ghi Chú](#-ghi-chú)

---

## 🚀 Tổng Quan Tính Năng

Hệ thống được chia thành 3 nhóm chức năng chính phục vụ cho việc vận hành website thương mại điện tử chuyên nghiệp.

<table>
  <tr>
    <th width="33%">👤 Khách Hàng (User)</th>
    <th width="33%">🛡️ Quản Trị Viên (Admin)</th>
    <th width="33%">🔐 Chung (Auth)</th>
  </tr>
  <tr>
    <td valign="top">
      <ul>
        <li>🏠 Trang Chủ Sản Phẩm</li>
        <li>🛍️ Khám phá & Tìm kiếm sản phẩm</li>
        <li>🛒 Giỏ Hàng & Thanh Toán (Tích hợp phí ship)</li>
        <li>ℹ️ Giới Thiệu & Quản lý Profile cá nhân</li>
        <li>📰 Đọc Blog/Tin Tức</li>
        <li>🔞 <b>Xác minh độ tuổi (18+)</b></li>
      </ul>
    </td>
    <td valign="top">
      <ul>
        <li>🏠 Bảng điều khiển (Dashboard) trực quan</li>
        <li>📦 Quản Lý Tồn Kho (Nhập/Xuất kho)</li>
        <li>👥 Phân Quyền (RBAC) & Quản Lý Tài Khoản</li>
        <li>📦 Duyệt Đơn Hàng & Xử lý vận chuyển</li>
        <li>🖼️ Quản Lý Banner, Thương hiệu, Danh mục</li>
        <li>📝 Quản Lý Blog/Tin Tức</li>
        <li>🎟️ Quản Lý Mã Giảm Giá</li>
        <li>📊 Thống Kê Doanh Thu & Biểu Đồ</li>
        <li>🌙 <b>Hỗ trợ giao diện Dark Mode</b></li>
      </ul>
    </td>
    <td valign="top">
      <ul>
        <li>🔑 Đăng Nhập/Đăng Ký an toàn</li>
        <li>🔄 Quên Mật Khẩu</li>
        <li>✅ Xác Thực Tài Khoản qua Email</li>
      </ul>
    </td>
  </tr>
</table>

---

## ⭐ Điểm Nổi Bật Ở Giai Đoạn 2 (Cuối Kì)

Khác với giai đoạn 1, hệ thống hiện tại đã là một ứng dụng Web Động (Dynamic Web App) hoàn chỉnh:
- **Responsive 100%:** Giao diện đã được nâng cấp tương thích hoàn toàn với mọi thiết bị (Mobile, Tablet, Desktop) từ trang khách hàng cho tới tận trang Admin.
- **Backend Mạnh Mẽ:** Sử dụng kiến trúc `Java Servlets` và `JSP`, quản lý thư viện tự động thông qua `Gradle`.
- **Database:** Kết nối dữ liệu thực tế bằng `MySQL` thay vì dữ liệu cứng (hardcode).
- **Phân Quyền Phức Tạp:** Hệ thống Role-Based Access Control (RBAC) như `orders:read`, `product:upsert` đảm bảo tính bảo mật nội bộ cao.

---

## 💻 Hướng Dẫn Cài Đặt & Sử Dụng

Việc cài đặt giờ đây đã chuyên nghiệp hơn rất nhiều:

> **"Uhm? Không còn là các file HTML click phát chạy luôn đâu bro. Welcome to Backend world!"** 🤣

**Yêu cầu môi trường:**
- **Java:** JDK 17+ (Khuyên dùng Java 21)
- **Database:** MySQL
- **Web Server:** Apache Tomcat 9 hoặc 10+
- **Công cụ build:** Gradle

**Cách chạy:**

1. **Clone mã nguồn:** Tải source code về máy.
2. **Cấu hình Cơ Sở Dữ Liệu:** Import script database (file `web.sql` trong thư mục `src/main/resources/`) vào MySQL. Cấu hình thông tin kết nối MySQL trong file `db.properties` tại thư mục `src/main/resources/db.properties`.
3. **Cấu hình Biến Môi Trường (`.env`):** Tạo file `.env` tại thư mục `src/main/resources/.env` (bạn có thể tham khảo/sao chép từ file mẫu [.env.example](file:///C:/Users/oleny/.gemini/antigravity/worktrees/WEB_Antigravity/audit-inventory-management-progress/.env.example) ở thư mục gốc) và chỉnh sửa các thông số kết nối dịch vụ bên thứ ba:
   * **Thanh toán:** Cấu hình VNPAY, MoMo, PayPal (`VNPAY_TMN_CODE`, `VNPAY_HASH_SECRET`, `PAYPAL_Client_ID`, `PAYPAL_Secret`, v.v.).
   * **Vận chuyển:** Cấu hình Giao Hàng Nhanh (GHN) và Giao Hàng Tiết Kiệm (GHTK) (`GHN`, `SHOP_ID_GHN`, `GHTK_TOKEN`, `GHTK_PARTNER_CODE`, v.v.).
   * **Dịch vụ khác:** Cấu hình Email gửi OTP (`EMAIL`, `APP_PASSWORD`), Captcha (`CAPTCHA_SECRETKEY`), và đăng nhập Facebook (`APP_ID_FB`, `APP_SECRET_FB`).
4. **Build dự án:** Mở terminal tại thư mục gốc và chạy lệnh:
   ```bash
   ./gradlew build
   # (Hoặc gradlew.bat build nếu dùng Windows)
   ```
5. **Deploy:** Deploy thư mục được build (hoặc file `.war` trong `build/libs`) lên Tomcat Server.
6. **Truy cập:**
   - Khách hàng: `http://localhost:8080/`
   - Admin: `http://localhost:8080/admin/dashboard`

---

## 📚 Thư Viện & Tài Nguyên

| Thư Viện                   | Mục Đích Sử Dụng                                |
|:---------------------------|:------------------------------------------------|
| **Java Servlets & JSP**    | Xử lý logic Backend & Render giao diện động     |
| **Gradle**                 | Quản lý thư viện & Build Tool                   |
| **FontAwesome / Ionicons** | Hệ thống Icons giao diện                        |
| **ApexCharts**             | Vẽ biểu đồ thống kê trong Admin                 |
| **DataTables**             | Xử lý dữ liệu bảng nâng cao (Tìm kiếm, sắp xếp) |
| **SweetAlert2**            | Hiển thị thông báo, popup đẹp mắt               |
| **Bootstrap 5**            | Framework UI/UX Responsive Mobile-First         |

---

## 📝 Ghi Chú

* ⭐ **Nếu thấy dự án hữu ích hoặc clone về tham khảo, hãy tặng nhóm một Star nhé!**
* 💡 Hệ thống đã được nâng cấp lên bản Full-Stack hoàn chỉnh theo yêu cầu của đồ án cuối kì.

---
*Thanks You For Reading ❤️️*
*README.md by [oleny](https://github.com/kleitusOleny) (co-authored by [Yuri](https://github.com/JukisYuri) & [Nguyễn Quang Minh](https://github.com/NguyenMinh032005)) & Nhóm 38*
