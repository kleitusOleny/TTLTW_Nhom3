<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/index_style.css">
<footer class="site-footer">
    <div class="container">
        <div class="footer-grid">
            <div class="footer-column">
                <h4 class="footer-heading">Về Chúng Tôi</h4>
                <p class="footer-text">
                    Mô tả ngắn gọn về dự án của bạn.
                    Nội dung này giúp người dùng hiểu rõ hơn về mục đích của bạn.
                </p>
                <div class="footer-socials">
                    <a href="#" class="social-link" aria-label="Facebook">
                        <i class="fa-brands fa-facebook-f"></i>
                    </a>
                    <a href="#" class="social-link" aria-label="Instagram">
                        <i class="fa-brands fa-instagram"></i>
                    </a>
                    <a href="#" class="social-link" aria-label="Twitter">
                        <i class="fa-brands fa-x-twitter"></i>
                    </a>
                </div>
            </div>

            <div class="footer-column">
                <h4 class="footer-heading">Liên Kết Nhanh</h4>
                <ul class="footer-links">
                    <li><a href="">Trang chủ</a></li>
                    <li><a href="">Giới thiệu</a></li>
                    <li><a href="">Dịch vụ</a></li>
                    <li><a href="">Liên hệ</a></li>
                    <li><a href="">Chính sách</a></li>
                </ul>
            </div>

            <div class="footer-column">
                <h4 class="footer-heading">Liên Hệ</h4>
                <ul class="footer-contact">
                    <li><strong>Địa chỉ:</strong> Khu Phố 6, P. Linh Trung, Q. Thủ Đức, TP.HCM</li>
                    <li><strong>Email:</strong> Olenydev@gmail.com</li>
                    <li><strong>Điện thoại:</strong> (+84) 1234 5678</li>
                </ul>
            </div>

        </div>
        <div class="footer-bottom">
            <p>&copy; 2025 Khoa Công Nghệ Thông Tin.</p>
        </div>

    </div>
    <div id="age-verification-popup" class="age-popup-overlay" style="display: none;">
        <div class="age-popup-content">
            <h2 class="age-popup-title">Cảnh báo độ tuổi</h2>
            <p>Trang web này chứa nội dung về thức uống có cồn dành cho người trên 18 tuổi. Vui lòng xác nhận bạn đã đủ 18 tuổi để tiếp tục truy cập.</p>
            <div class="age-popup-actions">
                <button id="btn-age-deny" class="btn btn-secondary">Tôi chưa đủ 18 tuổi</button>
                <button id="btn-age-confirm" class="btn btn-primary">Tôi đã đủ 18 tuổi</button>
            </div>
        </div>
    </div>

    <style>
        /* CSS cho Popup 18+ */
        .age-popup-overlay {
            position: fixed;
            top: 0; left: 0; width: 100%; height: 100%;
            background: rgba(0, 0, 0, 0.85); /* Nền tối mờ */
            display: flex; justify-content: center; align-items: center;
            z-index: 10000; /* Z-index rất cao để đè lên mọi thành phần khác bao gồm cả header */
        }
        .age-popup-content {
            background: #fff;
            padding: 30px;
            border-radius: 8px;
            text-align: center;
            max-width: 450px;
            box-shadow: 0 4px 25px rgba(0,0,0,0.5);
        }
        .age-popup-title {
            margin-top: 0;
            color: #8c3333; /* Màu đỏ rượu vang */
            font-size: 24px;
            margin-bottom: 15px;
        }
        .age-popup-content p {
            font-size: 16px;
            color: #333;
            line-height: 1.5;
            margin-bottom: 25px;
        }
        .age-popup-actions {
            display: flex;
            justify-content: center;
            gap: 15px;
        }
        .age-popup-actions button {
            padding: 12px 24px;
            border-radius: 5px;
            cursor: pointer;
            font-weight: bold;
            font-size: 15px;
        }
        /* Nút xác nhận: Màu rượu vang viền đen */
        #btn-age-confirm {
            background: #d9534f;
            color: white;
            border: 2px solid #000000 !important;
        }
        #btn-age-confirm:hover {
            background: #c9302c;
        }
        /* Nút từ chối */
        #btn-age-deny {
            background: #e0e0e0;
            color: #333;
            border: 2px solid #ccc;
        }
        #btn-age-deny:hover {
            background: #ccc;
        }
    </style>
</footer>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"
        integrity="sha384-YvpcrYf0tY3lHB60NNkmXc5s9fDVZLESaAA55NDzOxhy9GkcIdslK1eN7N6jIeHz"
        crossorigin="anonymous"></script>
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
<script>
    document.addEventListener("DOMContentLoaded", function () {
        const urlParams = new URLSearchParams(window.location.search);
        if (urlParams.has('loginSuccess')) {
            Swal.fire({
                icon: 'success',
                title: 'Đăng nhập thành công!',
                text: 'Chào mừng bạn quay trở lại.',
                timer: 3000,
                showConfirmButton: false
            });
            window.history.replaceState({}, document.title, window.location.pathname);
        }
        if (urlParams.has('registerSuccess')) {
            Swal.fire({
                icon: 'success',
                title: 'Đăng ký thành công!',
                text: 'Bạn có thể đăng nhập ngay bây giờ.',
                confirmButtonColor: '#3085d6'
            });
            window.history.replaceState({}, document.title, window.location.pathname);
        }
    });
</script>
<script>
    document.addEventListener('DOMContentLoaded', function () {
        const agePopup = document.getElementById('age-verification-popup');
        const btnConfirm = document.getElementById('btn-age-confirm');
        const btnDeny = document.getElementById('btn-age-deny');

        const isOver18 = localStorage.getItem('isOver18_confirmed');

        if (!isOver18) {

            agePopup.style.display = 'flex';

            document.body.style.overflow = 'hidden';
        }


        btnConfirm.addEventListener('click', function() {

            localStorage.setItem('isOver18_confirmed', 'true');

            agePopup.style.display = 'none';
            document.body.style.overflow = 'auto';
        });

        btnDeny.addEventListener('click', function() {
            window.location.href = 'https://www.google.com';
        });
    });
</script>