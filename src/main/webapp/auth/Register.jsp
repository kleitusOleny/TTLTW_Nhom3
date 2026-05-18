<%--
  Created by IntelliJ IDEA.
  User: Admin
  Date: 3/13/2026
  Time: 9:14 PM
  To change this template use File | Settings | File Templates.
--%>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
  <title>Register</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/auth/auth_css/register.css">
  <script src="https://accounts.google.com/gsi/client" async defer></script>
</head>
<body>
<div class="register-page">
  <h2>Đăng Kí</h2>
  <p id="warning">(* là trường bắt buộc)</p>
  <form id="register-form" action="${pageContext.request.contextPath}/register" method="POST">
    <div class="fullname-form">
      <div class="lastname form-group">
        <label for="name">Họ *</label>
        <input type="text" id="lastname" name="lastname"
               placeholder="Nhập đầy đủ họ của bạn"
               value="${param.lastname}"
               class="${not empty lastNameError ? 'input-error' : ''}" required>
        <span class="error-msg">${lastNameError}</span>
        <span class="error-msg">${lastNameError2}</span>
        <span class="error-msg">${lastNameError3}</span>
      </div>
      <div class="firstname form-group">
        <label for="name">Tên *</label>
        <input type="text" id="firstname" name="firstname"
               placeholder="Nhập đầy đủ tên của bạn"
               value="${param.firstname}"
               class="${not empty firstNameError ? 'input-error' : ''}" required>
        <span class="error-msg">${firstNameError}</span>
        <span class="error-msg">${firstNameError2}</span>
        <span class="error-msg">${firstNameError3}</span>
      </div>
    </div>

    <div class="username-full form-row">
      <div class="email-class form-group">
        <label for="email">Email *</label>
        <input type="text" id="email" name="email"
               placeholder="Nhập vào định dạng Email"
               value="${param.email}"
               class="${not empty emailError ? 'input-error' : ''}" required>
        <span class="error-msg">${emailError}</span>
        <span class="error-msg">${emailError2}</span>
        <span class="error-msg">${emailExistError}</span>
        <div class="reminder">
          <div class="remind-item username-remind">
            <input type="checkbox" id="remind-email" name="remind-email" disabled>
            <label for="remind-email">Email phải đúng định dạng abc@domain</label>
          </div>
        </div>
      </div>

      <div class="username-class form-group">
        <label for="username">Tên Đăng Nhập</label>
        <input type="text" id="username" name="username"
               placeholder="Nhập tên đăng nhập (tùy chọn)"
               value="${param.username}"
               class="${not empty usernameError ? 'input-error' : ''}">
        <span class="error-msg">${usernameError}</span>
        <span class="error-msg">${usernameExistError}</span>
        <div class="reminder">
          <div class="remind-item username-remind">
            <input type="checkbox" id="remind-username" name="remind-username" disabled>
            <label for="remind-username">Tên tài khoản phải từ 4-30 kí tự</label>
          </div>
        </div>
      </div>
    </div>

    <div class="password form-group">
      <label for="password">Mật Khẩu *</label>
      <input type="password" id="password" name="password"
             placeholder="Nhập mật khẩu dựa theo quy tắc được nêu"
             class="${not empty passwordError ? 'input-error' : ''}" required>
      <span class="error-msg">${passwordError}</span>
    </div>
    <div class="reminder">
      <div class="remind-item">
        <input type="checkbox" id="remind-words" name="remind-words" disabled>
        <label for="remind-words">Mật khẩu phải ít nhất 8 kí tự</label>
      </div>
      <div class="remind-item">
        <input type="checkbox" id="remind-uppercase" name="remind-uppercase" disabled>
        <label for="remind-uppercase">Mật khẩu phải bao gồm chữ hoa và chữ thường</label>
      </div>
      <div class="remind-item">
        <input type="checkbox" id="remind-special" name="remind-special" disabled>
        <label for="remind-special">Mật khẩu phải bao gồm kí tự đặc biệt</label>
      </div>
    </div>

    <div class="confirm-password form-group">
      <label for="confirm-password">Nhập lại Mật Khẩu *</label>
      <input type="password" id="confirm-password" name="confirm-password"
             placeholder="Nhập lại mật khẩu để xác nhận"
             class="${not empty confirmedPasswordError ? 'input-error' : ''}" required>
      <span class="error-msg">${confirmedPasswordError}</span>
    </div>
    <div class="reminder confirm">
      <div class="remind-item">
        <input type="checkbox" id="remind-confirm" name="remind-lowercase" disabled>
        <label for="remind-confirm">Mật khẩu nhập trùng khớp</label>
      </div>
    </div>

    <div class="phone-number form-group">
      <label for="phone-number">Số Điện Thoại *</label>
      <input type="tel" id="phone-number" name="phone-number"
             placeholder="Nhập số điện thoại của bạn"
             value="${param['phone-number']}"
             class="${not empty phoneNumberError ? 'input-error' : ''}" required>
      <span class="error-msg">${phoneNumberError}</span>
      <span class="error-msg">${phoneNumExistError}</span>
    </div>
    <div class="reminder">
      <div class="remind-item">
        <input type="checkbox" id="remind-phone" name="remind-phone" disabled>
        <label for="remind-phone">Số điện thoại phải bắt đầu bằng số 0 và có 10-11 chữ số</label>
      </div>
    </div>

    <div class="birth form-group">
      <label for="birth">Chọn Ngày Sinh *</label>
      <input type="date" id="birth" name="birth" lang="vi"
             value="${param.birth}"
             class="${not empty birthError || not empty ageError ? 'input-error' : ''}" required>
      <span class="error-msg-birth">${birthError}</span>
      <span class="error-msg-birth">${ageError}</span>
    </div>
    <div class="reminder">
      <div class="remind-item">
        <input type="checkbox" id="remind-birth" name="remind-birth" disabled>
        <label for="remind-birth">Bạn phải đủ 18 tuổi (tính đến hôm nay)</label>
      </div>
    </div>

    <div class="group-license">
      <div class="confirm-age">
        <input type="checkbox" id="age-confirm" class="checkbox">
        <label for="age-confirm">Xác nhận bạn đã đủ 18 tuổi</label>
      </div>
      <div class="confirm-license">
        <input type="checkbox" id="license-confirm" class="checkbox license">
        <label for="license-confirm">Xác nhận bạn sẽ tuân thủ chính sách</label>
      </div>
    </div>
    <button type="submit">Đăng Kí</button>
    <%--         Đăng nhập bằng google --%>
    <div class="social-login">
      <div id="social-remind">Chọn phương thức khác để đăng nhập:</div>
      <div id="g_id_onload"
           data-client_id="561993862196-rspl5j67m79f0857je2sdrv8f75m2ijs.apps.googleusercontent.com"
           data-login_uri="${pageContext.request.contextPath}/LoginGoogle"
           data-scope="https://www.googleapis.com/auth/user.birthday.read"
           data-auto_prompt="false">
      </div>
      <div class="g_id_signin"
           data-type="standard"
           data-size="large"
           data-theme="outline"
           data-text="sign_in_with"
           data-shape="rectangular"
           data-logo_alignment="left">
      </div>
    </div>
    <a href="login" id="backward">Quay Lại Trang Trước</a>
  </form>
</div>
<!-- Modal ToS -->
<div id="tos-modal" class="modal-overlay">
  <div class="modal-content">
    <span class="close-btn" id="close-modal">&times;</span>
    <h3>ĐIỀU KHOẢN VÀ ĐIỀU KIỆN DỊCH VỤ</h3>
    <div class="modal-body">
      <p>Chào mừng bạn đến với <strong>[Tên Ứng Dụng]</strong>. Khi tạo tài khoản và sử dụng dịch vụ của chúng tôi, bạn đồng ý tuân thủ các điều khoản dưới đây. Xin vui lòng đọc kỹ trước khi tiến hành đặt hàng.</p>

      <h4 style="margin-top: 15px; margin-bottom: 5px; color: #333;">Điều 1: Yêu cầu về độ tuổi và Tài khoản</h4>
      <p><strong>1.1. Độ tuổi hợp pháp:</strong> Việc mua bán thức uống có cồn chỉ dành cho người từ đủ 18 tuổi trở lên. Bằng việc sử dụng ứng dụng này, bạn cam kết mình đã đủ 18 tuổi.<br>
        <strong>1.2. Xác minh thông tin:</strong> <strong>[Tên Ứng Dụng]</strong> có quyền yêu cầu cung cấp hình ảnh Giấy tờ tùy thân (CCCD/Hộ chiếu) để xác minh độ tuổi khi hệ thống phát hiện rủi ro hoặc khi pháp luật yêu cầu.<br>
        <strong>1.3. Bảo mật:</strong> Bạn có trách nhiệm bảo mật tài khoản và không để người dưới 18 tuổi sử dụng tài khoản của mình để đặt hàng.</p>

      <h4 style="margin-top: 15px; margin-bottom: 5px; color: #333;">Điều 2: Thông tin Sản phẩm và Đơn hàng</h4>
      <p><strong>2.1. Đặc thù sản phẩm:</strong> Rượu vang là nông sản nên hương vị, nhãn mác hoặc nồng độ cồn có thể thay đổi nhỏ tùy theo năm thu hoạch (Vintage). Hình ảnh trên app mang tính chất minh họa.<br>
        <strong>2.2. Tình trạng lưu kho:</strong> Do tính chất khan hiếm của các dòng rượu cao cấp, đơn hàng của bạn chỉ được xác nhận chính thức sau khi chúng tôi kiểm tra tình trạng lưu kho và gửi thông báo xác nhận.<br>
        <strong>2.3. Quyền từ chối:</strong> Chúng tôi có quyền hủy đơn hàng nếu phát hiện hành vi đầu cơ, gian lận thương mại hoặc giao đến các khu vực bị hạn chế bởi luật pháp (trường học, bệnh viện, cơ sở cai nghiện,...).</p>

      <h4 style="margin-top: 15px; margin-bottom: 5px; color: #333;">Điều 3: Chính sách Giao nhận và Nhận hàng</h4>
      <p><strong>3.1. Kiểm tra độ tuổi khi giao:</strong> Nhân viên giao hàng có quyền từ chối bàn giao sản phẩm nếu người nhận không chứng minh được mình trên 18 tuổi hoặc có dấu hiệu không tỉnh táo, không kiểm soát được hành vi.<br>
        <strong>3.2. Kiểm tra đồng kiểm:</strong> Vì rượu cao cấp là hàng hóa nhạy cảm với nhiệt độ và va đập, khách hàng có trách nhiệm đồng kiểm tra ngoại quan (vỏ chai, tem nhãn, lớp bọc nilon/sáp) ngay tại thời điểm nhận hàng cùng nhân viên giao hàng.</p>

      <h4 style="margin-top: 15px; margin-bottom: 5px; color: #333;">Điều 4: Chính sách Đổi trả và Hoàn tiền</h4>
      <p><strong>4.1. Điều kiện đổi trả:</strong> Chỉ chấp nhận đổi trả ngay tại thời điểm giao nhận nếu phát hiện lỗi bể vỡ, rách tem mác do vận chuyển, hoặc giao sai sản phẩm.<br>
        <strong>4.2. Lỗi nhà sản xuất (Hỏng nút bần/Nhiễm nấm cork):</strong> Đối với các lỗi chất lượng phát hiện sau khi mở chai, khách hàng cần giữ lại nguyên trạng chai rượu (còn tối thiểu 80% dung lượng) và nút bần, đồng thời liên hệ CSKH trong vòng 24 giờ để được thẩm định và đổi trả.<br>
        <strong>4.3. Không đổi trả theo cảm tính:</strong> Chúng tôi không áp dụng chính sách hoàn tiền đối với các trường hợp sản phẩm không hợp khẩu vị cá nhân sau khi đã khui niêm phong.</p>

      <h4 style="margin-top: 15px; margin-bottom: 5px; color: #333;">Điều 5: Thưởng thức có trách nhiệm</h4>
      <p><strong>5.1. Cảnh báo sức khỏe:</strong> Uống nhiều rượu bia có thể gây hại cho sức khỏe, ảnh hưởng đến phụ nữ mang thai và khả năng điều khiển máy móc.<br>
        <strong>5.2. Tuân thủ pháp luật:</strong> "Đã uống rượu bia - Không lái xe". <strong>[Tên Ứng Dụng]</strong> hoàn toàn miễn trừ trách nhiệm pháp lý và dân sự đối với bất kỳ hậu quả, tai nạn hoặc tổn thất nào phát sinh từ việc sử dụng đồ uống có cồn của khách hàng.</p>

      <h4 style="margin-top: 15px; margin-bottom: 5px; color: #333;">Điều 6: Giải quyết tranh chấp</h4>
      <p>Mọi tranh chấp phát sinh trong quá trình giao dịch trên <strong>[Tên Ứng Dụng]</strong> sẽ được ưu tiên giải quyết thông qua thương lượng và hòa giải. Nếu không thể thỏa thuận, vụ việc sẽ được đưa ra cơ quan có thẩm quyền tại Việt Nam giải quyết theo luật định.</p>

      <p style="text-align: right; font-style: italic; margin-top: 20px; font-size: 0.85rem;">* Cập nhật lần cuối: 04/05/2026</p>
    </div>
    <button type="button" id="accept-tos-btn" disabled>Tôi chấp nhận điều khoản trên</button>
  </div>
</div>

<script src="${pageContext.request.contextPath}/preventspace.js"></script>
<script>
  const tosModal = document.getElementById('tos-modal');
  const licenseCheckbox = document.getElementById('license-confirm');
  const closeModalBtn = document.getElementById('close-modal');
  const acceptTosBtn = document.getElementById('accept-tos-btn');

  const modalBody = document.querySelector('.modal-body');

  licenseCheckbox.addEventListener('click', function(event) {
    if (this.checked) {
      event.preventDefault();
      this.checked = false;
      tosModal.classList.add('show');
      // check edge-case
      acceptTosBtn.disabled = modalBody.scrollHeight > modalBody.clientHeight;
    }
  });

  // Sự kiện scroll
  modalBody.addEventListener('scroll', function() {
    if (this.scrollHeight - this.scrollTop <= this.clientHeight + 2) {
      acceptTosBtn.disabled = false;
    }
  });

  // Khi chấp nhận điều khoản trong Popup
  acceptTosBtn.addEventListener('click', function() {
    licenseCheckbox.checked = true;
    tosModal.classList.remove('show');
  });

  // Khi bấm dấu X để thoát
  closeModalBtn.addEventListener('click', function() {
    tosModal.classList.remove('show');
  });

  // Khi bấm click ra ngoài khoảng đen nền của popup
  tosModal.addEventListener('click', function(event) {
    if (event.target === tosModal) {
      tosModal.classList.remove('show');
    }
  });
</script>
<script>
  const passwordInput = document.getElementById('password');
  const confirmInput = document.getElementById('confirm-password');
  const usernameInput = document.getElementById('username');
  const emailInput = document.getElementById('email');
  const phoneInput = document.getElementById('phone-number');
  const birthInput = document.getElementById('birth');

  // Các checkbox hiển thị trạng thái
  const remindWords = document.getElementById('remind-words');
  const remindUppercase = document.getElementById('remind-uppercase');
  const remindSpecial = document.getElementById('remind-special');
  const remindUsernameLength = document.getElementById('remind-username');
  const remindConfirm = document.getElementById('remind-confirm');
  const remindEmail = document.getElementById('remind-email');
  const remindPhoneNumber = document.getElementById('remind-phone');
  const remindBirth = document.getElementById('remind-birth');

  const listFields = ['#email, #username, #password, #confirm-password, #phone-number, #birth'];
  preventspace(listFields)

  function validateBirth() {
    const birthValue = birthInput.value;
    const birthDate = new Date(birthValue);
    const today = new Date();
    let age = today.getFullYear() - birthDate.getFullYear();
    const monthDiff = today.getMonth() - birthDate.getMonth();
    const dayDiff = today.getDate() - birthDate.getDate();
    if (monthDiff < 0 || (monthDiff === 0 && dayDiff < 0)) {
      age--;
    }
    remindBirth.checked = age >= 18;
  }

  function validatePhoneNumber() {
    const phonePattern = /^0\d{9,10}$/;
    const phoneValue = phoneInput.value;
    remindPhoneNumber.checked = phonePattern.test(phoneValue);
  }

  function validateEmail() {
    const emailPattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    const emailValue = emailInput.value;
    remindEmail.checked = emailPattern.test(emailValue);
  }

  function validatePassword() {
    const value = passwordInput.value;
    remindWords.checked = value.length >= 8;

    const hasUpper = /[A-Z]/.test(value);
    const hasLower = /[a-z]/.test(value);
    remindUppercase.checked = hasUpper && hasLower;

    remindSpecial.checked = /[!@#$%^&*(),.?":{}|<>]/.test(value);
    validateConfirm();
  }

  function validateConfirm() {
    const passValue = passwordInput.value;
    const confirmValue = confirmInput.value;
    remindConfirm.checked = passValue.length > 0 && passValue === confirmValue;
  }

  function validateUsername() {
    const usernameValue = usernameInput.value;
    remindUsernameLength.checked = usernameValue.length >= 4 && usernameValue.length <= 30;
  }
  passwordInput.addEventListener('input', validatePassword);
  confirmInput.addEventListener('input', validateConfirm);
  usernameInput.addEventListener('input', validateUsername);
  emailInput.addEventListener('input', validateEmail);
  phoneInput.addEventListener('input', validatePhoneNumber);
  birthInput.addEventListener('input', validateBirth);

  const registerForm = document.getElementById('register-form');

  registerForm.addEventListener('submit', function(event) {
    const ageChecked = document.getElementById('age-confirm').checked;
    const licenseChecked = document.getElementById('license-confirm').checked;
    const allValid = remindEmail.checked &&
            (usernameInput.value.length === 0 || remindUsernameLength.checked) &&
            remindWords.checked &&
            remindUppercase.checked &&
            remindSpecial.checked &&
            remindConfirm.checked &&
            remindPhoneNumber.checked &&
            remindBirth.checked;

    if (!ageChecked || !licenseChecked) {
      event.preventDefault();
      alert("Bạn phải xác nhận đủ 18 tuổi và đồng ý với chính sách để tiếp tục.");
    } else if (!allValid) {
      alert("Vui lòng hoàn thành đúng các yêu cầu (các ô tích) trước khi đăng ký.");
    }
  });
</script>
<script>
  window.addEventListener('DOMContentLoaded', function() {
    if (emailInput.value) validateEmail();
    if (usernameInput.value) validateUsername();
    if (phoneInput.value) validatePhoneNumber();
    if (birthInput.value) validateBirth();
    if (passwordInput.value) validatePassword();
  });
</script>
<style>
  .error-msg, .error-msg-birth {
    color: red;
    font-size: 0.85em;
    font-style: italic;
    margin-top: -5px;
    display: block;
  }
  .error-msg-birth {
    margin-top: -8px;
  }
  input.input-error {
    border: 1px solid red;
  }
</style>
</body>
</html>
