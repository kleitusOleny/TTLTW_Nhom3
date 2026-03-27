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
  <p>(* là trường bắt buộc)</p>
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
<script src="${pageContext.request.contextPath}/preventspace.js"></script>
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
