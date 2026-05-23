<%--
  Created by IntelliJ IDEA.
  User: Admin
  Date: 3/13/2026
  Time: 9:14 PM
  To change this template use File | Settings | File Templates.
--%>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
  <title>OnBoarding</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/auth/auth_css/onboarding.css">
</head>
<body>
<div class="register-page">
  <h2>Tiếp Tục Đăng Kí Với Google</h2>
  <p>(* là trường bắt buộc)</p>
  <form id="register-form" action="${pageContext.request.contextPath}/onboarding" method="POST">
    <div class="fullname-form">
      <div class="lastname form-group">
        <label for="name">Họ *</label>
        <input type="text" id="lastname" name="lastname"
               placeholder="VD: Nguyễn, Ngô,..."
               value="${param.lastname}"
               class="${not empty lastNameError ? 'input-error' : ''}" required>
        <span class="error-msg">${lastNameError}</span>
        <span class="error-msg">${lastNameError2}</span>
        <span class="error-msg">${lastNameError3}</span>
      </div>
      <div class="firstname form-group">
        <label for="name">Tên *</label>
        <input type="text" id="firstname" name="firstname"
               placeholder="VD: Ánh, Vi,..."
               value="${param.firstname}"
               class="${not empty firstNameError ? 'input-error' : ''}" required>
        <span class="error-msg">${firstNameError}</span>
        <span class="error-msg">${firstNameError2}</span>
        <span class="error-msg">${firstNameError3}</span>
      </div>
    </div>
    <div class="username-class form-group">
      <label for="username">Tên Đăng Nhập</label>
      <input type="text" id="username" name="username"
             placeholder="jukisyuri_25, nguyenanh123,..."
             value="${param.username}"
             class="${not empty usernameError ? 'input-error' : ''}">
      <span class="error-msg">${usernameError}</span>
      <span class="error-msg">${usernameExistError}</span>
      <span class="error-msg">${usernameFormatError}</span>
      <div class="reminder">
        <div class="remind-item username-remind">
          <input type="checkbox" id="remind-username" name="remind-username" disabled>
          <label for="remind-username">Tên tài khoản phải từ 4-30 kí tự</label>
        </div>
        <div class="remind-item username-remind">
          <input type="checkbox" id="remind-username-specialCharacters" name="remind-username-specialCharacters" disabled>
          <label for="remind-username-specialCharacters">Tên tài khoản không bao gồm kí tự đặc biệt</label>
        </div>
      </div>
    </div>
    <div class="phone-number form-group">
      <label for="phone-number">Số Điện Thoại *</label>
      <input type="tel" id="phone-number" name="phone-number"
             placeholder="(+84) 0399150382, 0798827263,..."
             value="${param['phone-number']}"
             class="${not empty phoneNumberError ? 'input-error' : ''}" required>
      <span class="error-msg">${phoneNumberError}</span>
      <span class="error-msg">${phoneNumExistError}</span>
      <div class="reminder">
        <div class="remind-item">
          <input type="checkbox" id="remind-phone" name="remind-phone" disabled>
          <label for="remind-phone">Số điện thoại phải bắt đầu bằng số 0 và có 10-11 chữ số</label>
        </div>
      </div>
    </div>
    <div class="birth form-group">
      <label for="birth">Chọn Ngày Sinh *</label>
      <input type="date" id="birth" name="birth" lang="vi"
             value="${param.birth}"
             class="${not empty birthError || not empty ageError ? 'input-error' : ''}" required>
      <span class="error-msg-birth">${birthError}</span>
      <span class="error-msg-birth">${ageError}</span>
      <div class="reminder">
        <div class="remind-item">
          <input type="checkbox" id="remind-birth" name="remind-birth" disabled>
          <label for="remind-birth">Bạn phải đủ 18 tuổi (tính đến hôm nay)</label>
        </div>
      </div>
    </div>
    <div class="group-confirm">
      <div class="confirm-age">
        <input type="checkbox" id="age-confirm" class="checkbox">
        <label for="age-confirm">Xác nhận bạn đã đủ 18 tuổi</label>
      </div>
      <div class="confirm-license">
        <input type="checkbox" id="license-confirm" class="checkbox license">
        <label for="license-confirm">Xác nhận bạn sẽ tuân thủ chính sách</label>
      </div>
    </div>
    <button type="submit">Xác Nhận</button>
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
  const usernameInput = document.getElementById('username');
  const birthInput = document.getElementById('birth');
  const phoneInput = document.getElementById('phone-number');
  const remindUsernameLength = document.getElementById('remind-username');
  const remindUsernameSpecialCharacters = document.getElementById('remind-username-specialCharacters');
  const remindPhoneNumber = document.getElementById('remind-phone');
  const remindBirth = document.getElementById('remind-birth');
  const listFields = ['#username', '#phone-number', '#birth'];
  preventspace(listFields)

  function validateUsernameLength() {
    const usernameValue = usernameInput.value;
    remindUsernameLength.checked = usernameValue.length >= 4 && usernameValue.length <= 30;
  }

  function validateUsernameSpecialCharacters() {
    const usernameValue = usernameInput.value;
    remindUsernameSpecialCharacters.checked = !/[^a-zA-Z0-9_-]/.test(usernameValue) && usernameValue.length > 0;
  }

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

  usernameInput.addEventListener('input', () => {
    validateUsernameLength();
    validateUsernameSpecialCharacters();
  });
  birthInput.addEventListener('input', validateBirth);
  phoneInput.addEventListener('input', validatePhoneNumber);

  const onBoardingForm = document.getElementById('register-form');
  onBoardingForm.addEventListener('submit', function(event) {
    const ageChecked = document.getElementById('age-confirm').checked;
    const licenseChecked = document.getElementById('license-confirm').checked;

    if (!ageChecked || !licenseChecked) {
      event.preventDefault();
      alert("Bạn phải xác nhận đủ 18 tuổi và đồng ý với chính sách để tiếp tục.");
    }
  });
</script>
<script>
  window.addEventListener('DOMContentLoaded', function() {
    if (usernameInput.value) {
      validateUsernameLength();
      validateUsernameSpecialCharacters();
    }
    if (phoneInput.value) validatePhoneNumber();
    if (birthInput.value) validateBirth();
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

