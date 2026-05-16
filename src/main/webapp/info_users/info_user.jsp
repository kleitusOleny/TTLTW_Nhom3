<%@ page import="model.User" %>
<%@ page import="java.time.LocalDateTime" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.time.ZoneId" %>
<% 
    String birthDayStr = ""; 
    User user = (User) request.getAttribute("user"); 
    if (user != null && user.getBirthDay() != null) { 
        LocalDate localDate = user.getBirthDay().toLocalDateTime().toLocalDate();
        birthDayStr = String.format("%04d-%02d-%02d", localDate.getYear(), localDate.getMonthValue(), localDate.getDayOfMonth()); 
    } 
    request.setAttribute("birthDayStr", birthDayStr);
%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<link rel="stylesheet" href="<%= request.getContextPath() %>/css/info_user_style.css">
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<div class="user-profile-card">
    <h2>Thông tin người dùng</h2>
    <form id="profile-form" action="<%= request.getContextPath() %>/user" method="post">
        <input type="hidden" name="action" value="updateProfile">
        <div class="user-info-fields">
            <div class="field-group">
                <label class="field-label">Họ và tên</label>
                <div class="field">
                    <i class="fa-solid fa-user left-icon"></i>
                    <input class="editable-input" type="text" id="fullName" name="fullName"
                        value="${user.fullName}" disabled>
                </div>
                <span class="error-msg" id="error-fullName">${errors.fullNameError}</span>
            </div>

            <div class="field-group">
                <label class="field-label">Email (Không thể thay đổi)</label>
                <div class="field disabled-field">
                    <i class="fa-solid fa-envelope left-icon"></i>
                    <input class="editable-input" type="email" id="email-display"
                        value="${user.email}" disabled>
                    <input type="hidden" name="email" value="${user.email}">
                </div>
                <span class="error-msg" id="error-email">${errors.emailError}</span>
            </div>

            <div class="field-group">
                <label class="field-label">Số điện thoại</label>
                <div class="field">
                    <i class="fa-solid fa-phone left-icon"></i>
                    <input class="editable-input" type="text" id="phone" name="phone"
                        value="${user.phoneNumber}" disabled>
                </div>
                <span class="error-msg" id="error-phone">${errors.phoneNumberError}</span>
            </div>

            <div class="field-group">
                <label class="field-label">Ngày sinh</label>
                <div class="field">
                    <i class="fa-solid fa-calendar-days left-icon"></i>
                    <input class="editable-input" type="date" id="birthDay" name="birthDay"
                        value="${birthDayStr}" disabled>
                </div>
                <span class="error-msg" id="error-birthDay">${errors.birthError} ${errors.ageError}</span>
            </div>

            <div class="edit-only-section" style="display:none;">
                <h3 class="section-title">Đổi mật khẩu (Tùy chọn)</h3>
                
                <div class="field-group">
                    <label class="field-label">Mật khẩu hiện tại</label>
                    <div class="field">
                        <i class="fa-solid fa-lock left-icon"></i>
                        <input class="editable-input" type="password" id="oldPassword" name="oldPassword"
                            placeholder="Nhập mật khẩu cũ để xác nhận thay đổi">
                    </div>
                    <span class="error-msg" id="error-oldPassword">${errors.errorPass}</span>
                </div>

                <div class="field-group">
                    <label class="field-label">Mật khẩu mới</label>
                    <div class="field">
                        <i class="fa-solid fa-key left-icon"></i>
                        <input class="editable-input" type="password" id="newPassword" name="newPassword"
                            placeholder="Mật khẩu mới (tối thiểu 8 ký tự)">
                    </div>
                    <span class="error-msg" id="error-newPassword">${errors.passwordError}</span>
                </div>

                <div class="field-group">
                    <label class="field-label">Xác nhận mật khẩu mới</label>
                    <div class="field">
                        <i class="fa-solid fa-check-double left-icon"></i>
                        <input class="editable-input" type="password" id="confirmNewPassword" name="confirmNewPassword"
                            placeholder="Nhập lại mật khẩu mới">
                    </div>
                    <span class="error-msg" id="error-confirmNewPassword"></span>
                </div>
            </div>
        </div>

        <div class="buttons">
            <button type="button" id="editBtn" class="btn gray">Chỉnh sửa thông tin</button>
            <button type="submit" id="saveBtn" class="btn" style="display:none;">Lưu thay đổi</button>
            <button type="button" id="cancelBtn" class="btn cancel" style="display:none;">Hủy bỏ</button>
        </div>
    </form>
</div>

<script src="<%= request.getContextPath() %>/preventspace.js"></script>
<!-- SweetAlert2 -->
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

<script>
    (function () {
        const editBtn = document.getElementById("editBtn");
        const saveBtn = document.getElementById("saveBtn");
        const cancelBtn = document.getElementById("cancelBtn");
        const profileForm = document.getElementById("profile-form");

        const inputs = document.querySelectorAll(".editable-input");
        const editOnlySection = document.querySelector(".edit-only-section");

        const backup = {};

        function setStatus(id, isValid, message = "") {
            const input = document.getElementById(id);
            const errorSpan = document.getElementById("error-" + id);
            if (!input || !errorSpan) return;

            if (isValid) {
                input.classList.remove("input-error");
                input.classList.add("input-valid");
                errorSpan.textContent = "";
            } else {
                input.classList.remove("input-valid");
                input.classList.add("input-error");
                errorSpan.textContent = message;
            }
        }

        const validators = {
            fullName: () => {
                const el = document.getElementById("fullName");
                const val = el.value.trim();
                // Matching backend regex: ^[\p{L}]+( [\p{L}]+)*$
                const namePattern = /^[\p{L}]+( [\p{L}]+)*$/u;
                const isValid = val.length >= 2 && namePattern.test(val);
                setStatus("fullName", isValid, val ? (namePattern.test(val) ? "" : "Họ tên không được chứa số, ký tự đặc biệt hoặc khoảng trắng thừa") : "Họ tên không được để trống");
                return isValid;
            },
            phone: () => {
                const el = document.getElementById("phone");
                const val = el.value.trim();
                const phonePattern = /^0\d{9,10}$/;
                const isValid = phonePattern.test(val);
                setStatus("phone", isValid, "Số điện thoại phải bắt đầu bằng 0 và có 10-11 chữ số");
                return isValid;
            },
            birthDay: () => {
                const el = document.getElementById("birthDay");
                const val = el.value;
                if (!val) {
                    setStatus("birthDay", false, "Vui lòng chọn ngày sinh");
                    return false;
                }
                const birthDate = new Date(val);
                const today = new Date();
                let age = today.getFullYear() - birthDate.getFullYear();
                const m = today.getMonth() - birthDate.getMonth();
                if (m < 0 || (m === 0 && today.getDate() < birthDate.getDate())) age--;
                const isValid = age >= 18;
                setStatus("birthDay", isValid, isValid ? "" : "Bạn phải từ 18 tuổi trở lên");
                return isValid;
            },
            newPassword: () => {
                const el = document.getElementById("newPassword");
                const val = el.value;
                if (!val) {
                    setStatus("newPassword", true);
                    return true;
                }
                // Backend regex: ^(?=.*[a-z])(?=.*[A-Z])(?=.*[^A-Za-z0-9]).{8,}$
                const pwdPattern = /^(?=.*[a-z])(?=.*[A-Z])(?=.*[^A-Za-z0-9]).{8,}$/;
                const isValid = pwdPattern.test(val);
                setStatus("newPassword", isValid, "Mật khẩu mới cần ít nhất 8 ký tự, gồm chữ hoa, chữ thường và ký tự đặc biệt");
                validators.confirmNewPassword();
                return isValid;
            },
            confirmNewPassword: () => {
                const newPass = document.getElementById("newPassword").value;
                const confirmPass = document.getElementById("confirmNewPassword").value;
                if (!newPass && !confirmPass) {
                    setStatus("confirmNewPassword", true);
                    return true;
                }
                const isValid = newPass === confirmPass;
                setStatus("confirmNewPassword", isValid, isValid ? "" : "Xác nhận mật khẩu không khớp");
                return isValid;
            }
        };

        editBtn.onclick = () => {
            inputs.forEach(input => {
                backup[input.id || input.name] = input.value;
                if (input.id !== "email-display") {
                    input.disabled = false;
                }
            });

            editOnlySection.style.display = "block";
            editBtn.style.display = "none";
            saveBtn.style.display = "inline-block";
            cancelBtn.style.display = "inline-block";
            
            if (typeof preventspace === 'function') {
                preventspace(['#phone', '#oldPassword', '#newPassword', '#confirmNewPassword']);
            }
        };

        cancelBtn.onclick = (e) => {
            e.preventDefault();
            inputs.forEach(input => {
                input.value = backup[input.id || input.name] || "";
                input.disabled = true;
                input.classList.remove("input-error", "input-valid");
            });
            
            document.querySelectorAll(".error-msg").forEach(s => s.textContent = "");
            editOnlySection.style.display = "none";
            editBtn.style.display = "inline-block";
            saveBtn.style.display = "none";
            cancelBtn.style.display = "none";
        };

        Object.keys(validators).forEach(key => {
            const el = document.getElementById(key);
            if (el) {
                el.addEventListener("input", validators[key]);
                el.addEventListener("blur", validators[key]);
            }
        });

        profileForm.onsubmit = (e) => {
            const isFullNameValid = validators.fullName();
            const isPhoneValid = validators.phone();
            const isBirthValid = validators.birthDay();
            const isNewPassValid = validators.newPassword();
            const isConfirmValid = validators.confirmNewPassword();

            if (!isFullNameValid || !isPhoneValid || !isBirthValid || !isNewPassValid || !isConfirmValid) {
                e.preventDefault();
                Swal.fire({
                    icon: 'error',
                    title: 'Thông tin không hợp lệ',
                    text: 'Vui lòng kiểm tra lại các trường thông tin và sửa các lỗi hiển thị màu đỏ.',
                    confirmButtonColor: '#8c3333',
                    background: '#fff',
                    borderRadius: '12px'
                });
            }
        };
    })();
</script>

<style>
    .error-msg {
        color: #dc3545;
        font-size: 0.9em;
        font-weight: bold;
        margin-bottom: 10px;
        display: block;
        min-height: 1.2em;
    }
    .field-group {
        margin-bottom: 15px;
    }
    .field-label {
        display: block;
        margin-bottom: 5px;
        font-weight: bold;
        color: #555;
    }
    .disabled-field {
        background-color: #e9ecef !important;
        opacity: 0.8;
    }
    .section-title {
        margin: 25px 0 15px;
        padding-bottom: 10px;
        border-bottom: 2px solid #8c3333;
        color: #8c3333;
        font-size: 1.2em;
    }
    input.input-error {
        border: 2px solid #dc3545 !important;
        background-color: #fff8f8;
    }
    input.input-valid {
        border: 2px solid #28a745 !important;
    }
</style>