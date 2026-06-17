<%--
  Created by IntelliJ IDEA.
  User: Admin
  Date: 3/13/2026
  Time: 8:50 PM
  To change this template use File | Settings | File Templates.
--%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta charset="UTF-8">
  <%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
  <title>Authentication</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/auth/auth_css/authentication.css">
</head>
<body>
<div class="forgot-password-container">
  <h2>Xác Thực</h2>
  <c:set var="isBlocked" value="${not empty otpError && fn:contains(otpError, 'quá nhiều')}" />
  <form id="forgot-password-form" action="${pageContext.request.contextPath}/authentication" method="POST">
    <input type="hidden" name="action" id="form-action" value="">
    <div class="email-class form-group">
      <div class="container-mail">
        <label for="email" class="label-with-icon">
          <ion-icon name="mail-outline"></ion-icon>
          Nhập Email để lấy mã xác thực</label>
        <input type="email" id="email" name="email"
               placeholder="nguyenanh24@gmail.com"
               value="${not empty pendingEmail ? pendingEmail : (otpEmail != null ? otpEmail : param.email)}"
        <%-- Khóa ô email nếu đi từ luồng Đăng ký --%>
        ${not empty pendingEmail ? "readonly" : ""}
        ${isBlocked ? "disabled" : ""}
               class="${not empty emailError ? 'input-error' : ''}" required>
      </div>
      <div class="group-message">
        <c:if test="${not empty emailError}">
          <span class="error-msg">${emailError}</span>
        </c:if>
        <c:if test="${not empty message}">
          <span style="color: green; font-size: 0.85em;">${message}</span>
        </c:if>
      </div>
    </div>
    <div class="verify form-group">
      <div class="verify-title">
        <label class="label-with-icon"><ion-icon name="chatbox-ellipses-outline"></ion-icon>Mã xác thực</label>
        <div class="otp-container" id="otp-inputs">
          <input type="text" maxlength="1" pattern="\d*" inputmode="numeric" class="otp-field" ${isBlocked ? 'disabled' : ''}/>
          <input type="text" maxlength="1" pattern="\d*" inputmode="numeric" class="otp-field" ${isBlocked ? 'disabled' : ''}/>
          <input type="text" maxlength="1" pattern="\d*" inputmode="numeric" class="otp-field" ${isBlocked ? 'disabled' : ''}/>
          <input type="text" maxlength="1" pattern="\d*" inputmode="numeric" class="otp-field" ${isBlocked ? 'disabled' : ''}/>
          <input type="text" maxlength="1" pattern="\d*" inputmode="numeric" class="otp-field" ${isBlocked ? 'disabled' : ''}/>
          <input type="text" maxlength="1" pattern="\d*" inputmode="numeric" class="otp-field" ${isBlocked ? 'disabled' : ''}/>
        </div>
        <input type="hidden" id="verify-code" name="otpInput" required>
      </div>
      <c:if test="${not empty otpError}">
        <span class="error-msg">${otpError}</span>
      </c:if>
    </div>
    <div class="group-remind">
      <p id="remind">Bạn phải chờ thêm 1 phút để có thể tiếp tục lấy mã</p>
      <div class="group-button-verify">
        <button class="get-verify-code" onclick="setAction('send-otp')" ${isBlocked ? 'disabled' : ''} formnovalidate>Lấy mã xác thực</button>
        <button class="submit" type="submit" onclick="setAction('finish-otp')" ${isBlocked ? 'disabled' : ''}>Đồng ý</button>
      </div>
    </div>
    <a href="login" id="backward">Quay Lại Trang Trước</a>
  </form>
</div>
<script type="module" src="https://unpkg.com/ionicons@7.1.0/dist/ionicons/ionicons.esm.js"></script>
<script nomodule src="https://unpkg.com/ionicons@7.1.0/dist/ionicons/ionicons.js"></script>
<script src="${pageContext.request.contextPath}/preventspace.js"></script>
<script>
  function setAction(actionName) {
    document.getElementById('form-action').value = actionName;
  }

  const listFields = ['#email', '#verify-code'];
  preventspace(listFields)
</script>
<script>
  const urlParams = new URLSearchParams(window.location.search);
  if (urlParams.has('failResetPassword')) {
    alert("Bạn phải đảm bảo là đã xác thực email trước khi tiến sang bước làm lại mật khẩu")
    window.history.replaceState(null, '', window.location.pathname);
  }
</script>
<style>
  .error-msg {
    color: red;
    font-size: 0.85em;
    font-style: italic;
    margin-top: -5px;
    display: block;
  }
  input.input-error {
    border: 1px solid red;
  }

  input[disabled], button[disabled] {
    background-color: #f1f3f5 !important;
    color: #adb5bd !important;
    border: 1px solid #ced4da !important;
    cursor: not-allowed !important;
    opacity: 0.7;
  }
  button[disabled] {
    box-shadow: none !important;
    pointer-events: none;
  }
</style>
<script>
  document.addEventListener("DOMContentLoaded", () => {
    const inputs = document.querySelectorAll(".otp-field");
    const hiddenInput = document.querySelector("#verify-code");

    inputs.forEach((input, index) => {
      input.addEventListener("input", (e) => {
        if (e.inputType === "deleteContentBackward") return;
        const val = e.target.value;
        if (!/^\d$/.test(val)) {
          e.target.value = "";
          return;
        }
        if (val && index < inputs.length - 1) {
          inputs[index + 1].focus();
        }
        updateHiddenInput();
      });
      input.addEventListener("keydown", (e) => {
        if (e.key === "Backspace" && !e.target.value && index > 0) {
          inputs[index - 1].focus();
        }
      });
      input.addEventListener("paste", (e) => {
        e.preventDefault();
        const data = e.clipboardData.getData("text").trim();
        if (!/^\d{6}$/.test(data)) return;

        const digits = data.split("");
        inputs.forEach((input, i) => {
          input.value = digits[i];
        });
        updateHiddenInput();
        inputs[inputs.length - 1].focus();
      });
    });

    function updateHiddenInput() {
      let otpValue = "";
      inputs.forEach(input => {
        otpValue += input.value;
      });
      hiddenInput.value = otpValue;
    }
  });
</script>
</body>
</html>
