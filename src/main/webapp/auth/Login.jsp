<%--
  Created by IntelliJ IDEA.
  User: Admin
  Date: 3/13/2026
  Time: 7:57 PM
  To change this template use File | Settings | File Templates.
--%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
    <title>Login</title>
    <script src='${pageContext.request.contextPath}/popup.js'></script>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/auth/auth_css/login.css">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <script src="https://accounts.google.com/gsi/client" async defer></script>
</head>
<body>
<div class="main-container">
    <div class="backward-button-container">
        <button class="question" id="btn-question">
            <ion-icon name="help-outline"></ion-icon>
        </button>
    </div>
    <div class="login-page">
        <h2>Đăng Nhập</h2>
        <c:set var="isBlocked" value="${not empty loginError && fn:contains(loginError, '5 lần')}" />
        <form id="login-form" action="${pageContext.request.contextPath}/login" method="POST">
            <input type="hidden" name="redirect" value="${fn:escapeXml(param.redirect)}">
            <div class="username-input">
                <label for="username" class="label-with-icon">
                    <ion-icon name="person-outline"></ion-icon>
                    Nhập tên tài khoản hoặc email hiện có</label>
                <input type="text" id="username" name="username" placeholder="anhnguyen12, anhnguyen25@gmail.com"
                       value="${param.username}"
                       class="${not empty usernameError or not empty inputError or not empty loginError ? 'input-error' : ''}"
                       ${isBlocked ? 'disabled' : ''} required>
                <c:if test="${not empty inputError}">
                    <span class="error-msg">${inputError}</span>
                </c:if>
                <c:if test="${not empty usernameError}">
                    <span class="error-msg">${usernameError}</span>
                </c:if>
                <c:if test="${not empty loginError}">
                    <span class="error-msg">${loginError}</span>
                </c:if>
            </div>

            <div class="password-input">
                <label for="password" class="label-with-icon">
                    <ion-icon name="lock-closed-outline"></ion-icon>Mật Khẩu
                </label>
                <div class="input-wrapper">
                    <input type="password" id="password" name="password"
                           placeholder="Anhnguyen@25"
                           class="${not empty inputError ? 'input-error' : ''}"
                           ${isBlocked ? 'disabled' : ''} required>
                    <span id="eyeIcon">
                        <ion-icon name="eye-off-outline"></ion-icon>
                    </span>
                </div>
                <c:if test="${not empty inputError}">
                    <span class="error-msg">${inputError}</span>
                </c:if>
                <c:if test="${not empty loginError}">
                    <span class="error-msg">${loginError}</span>
                </c:if>
            </div>

            <div class="remember-me-input">
                <a href="authentication">Quên Mật Khẩu</a>
            </div>
            <button ${isBlocked ? 'disabled' : ''}>Đăng Nhập</button>
            <div class="register-account">
                <div id="register-remind">Chưa có tài khoản?</div>
                <a href="register">Đăng Kí</a>
            </div>
            <div class="social-login">
                <div id="social-remind">Chọn phương thức khác để đăng nhập:</div>
                <div class="social-buttons-container">
                    <%-- Đăng nhập bằng Google --%>
                    <div id="g_id_onload"
                         data-client_id="561993862196-rspl5j67m79f0857je2sdrv8f75m2ijs.apps.googleusercontent.com"
                         data-login_uri="${pageContext.request.contextPath}/LoginGoogle?redirect=${param.redirect}"
                         data-scope="https://www.googleapis.com/auth/user.birthday.read"
                         data-auto_prompt="false">
                    </div>
                    <div class="g_id_signin"
                         data-type="standard"
                         data-size="large"
                         data-theme="outline"
                         data-text="signin_with"
                         data-shape="rectangular"
                         data-logo_alignment="left"
                         data-width="280">
                    </div>
                    <%-- Đăng nhập bằng Facebook --%>
                        <c:url var="fbRedirectUri" value="/login-facebook" />
                        <a href="https://www.facebook.com/v19.0/dialog/oauth?client_id=1455204079314019&redirect_uri=${pageContext.request.scheme}://${pageContext.request.serverName}:${pageContext.request.serverPort}${fbRedirectUri}&scope=email,public_profile&state=${not empty param.redirect ? param.redirect : ''}"
                       class="fb-signin-btn">
                        <span class="fb-icon-wrapper">
                            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="18" height="18">
                                <path fill="#1877F2" d="M24 12.073c0-6.627-5.373-12-12-12s-12 5.373-12 12c0 5.99 4.388 10.954 10.125 11.854v-8.385H7.078v-3.47h3.047V9.43c0-3.007 1.792-4.669 4.533-4.669 1.312 0 2.686.235 2.686.235v2.953H15.83c-1.491 0-1.956.925-1.956 1.874v2.25h3.328l-.532 3.47h-2.796v8.385C19.612 23.027 24 18.062 24 12.073z"></path>
                            </svg>
                        </span>
                        <span class="fb-text-wrapper">Đăng nhập bằng Facebook</span>
                    </a>
                </div>
            </div>
            <a href="${not empty param.redirect ? param.redirect : (not empty header.referer ? header.referer : 'index.jsp')}" id="backward">Quay Lại Trang Trước</a>
        </form>
    </div>
</div>
<div class="modal-overlay-question" id="question-account-modal">
    <div class="modal-content-question">
        <h2>Vì sao cần đăng nhập?</h2>
        <div class="group-p">
            <p>
                <ion-icon name="shield-checkmark-outline"></ion-icon>
                Theo quy định về kinh doanh đồ uống có cồn, chúng tôi cần xác minh người mua đã đủ độ tuổi hợp pháp.
            </p>
            <p>
                <ion-icon name="shield-checkmark-outline"></ion-icon>
                Việc đăng nhập cũng giúp bảo mật thông tin đơn hàng, thêm khuyến mãi cho cá nhân và đảm bảo quyền lợi
                tốt nhất cho bạn trong quá trình vận chuyển.
            </p>
        </div>
        <button id="close-btn">Đã rõ</button>
    </div>
</div>
<script src="${pageContext.request.contextPath}/preventspace.js"></script>
<script>
    setupModal('question-account-modal', 'btn-question', 'close-btn')
    let eyeClosed = document.getElementById('eyeIcon').querySelector('ion-icon');
    let passwordReveal = document.getElementById('password');

    eyeClosed.onclick = () => {
        if (passwordReveal.type === 'password') {
            passwordReveal.type = 'text';
            eyeClosed.setAttribute('name', 'eye-outline');
        } else {
            passwordReveal.type = 'password';
            eyeClosed.setAttribute('name', 'eye-off-outline');
        }
    }
</script>
<script type="module" src="https://unpkg.com/ionicons@7.1.0/dist/ionicons/ionicons.esm.js"></script>
<script nomodule src="https://unpkg.com/ionicons@7.1.0/dist/ionicons/ionicons.js"></script>
<script>
    const urlParams = new URLSearchParams(window.location.search);
    const errorCode = urlParams.get('loginError')
    const errorMessages = {
        '1': "Đăng nhập Google thất bại",
    }
    if (errorCode && errorMessages[errorCode]) {
        Swal.fire({
            icon: 'error',
            title: 'Lỗi đăng nhập',
            text: errorMessages[errorCode],
            confirmButtonColor: '#3085d6'
        });
        window.history.replaceState(null, '', window.location.pathname);
    }
    const listFields = ['#username', '#password']
    preventspace(listFields)
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

    /* các thành phần bị khóa (disabled) */
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
</body>
</html>
