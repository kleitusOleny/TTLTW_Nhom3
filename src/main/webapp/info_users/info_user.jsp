<%@ page import="model.User" %>
    <%@ page import="java.time.LocalDateTime" %>
        <%@ page import="java.time.LocalDate" %>
            <%@ page import="java.time.ZoneId" %>
                <% String birthDayStr="" ; User user=(User) request.getAttribute("user"); if (user !=null &&
                    user.getBirthDay() !=null) { LocalDate localDate=user.getBirthDay().toLocalDateTime().toLocalDate();
                    birthDayStr=String.format("%04d-%02d-%02d", localDate.getYear(), localDate.getMonthValue(),
                    localDate.getDayOfMonth()); } %>
                    <%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
                        <link rel="stylesheet" href="<%= request.getContextPath() %>/css/info_user_style.css">
                        <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
                            <div class="user-profile-card">
                                <h2>Thông tin người dùng</h2>
                                <form action="<%= request.getContextPath() %>/user" method="post">
                                    <input type="hidden" name="action" value="updateProfile">
                                    <span class="text-danger">${errors.fullNameError}</span>
                                    <div class="user-info-fields">
                                        <div class="field">
                                            <i class="fa-solid fa-user left-icon"></i>
                                            <input class="editable-input" type="text" name="fullName"
                                                value="${user.fullName}" disabled>
                                            <span class="text-danger">${errors.fullNameError}</span>
                                        </div>

                                        <div class="field">
                                            <i class="fa-solid fa-envelope left-icon"></i>
                                            <input class="editable-input" type="email" name="email"
                                                value="${user.email}" disabled>
                                            <span class="text-danger">${errors.emailError}</span>
                                        </div>

                                        <div class="field">
                                            <i class="fa-solid fa-phone left-icon"></i>
                                            <input class="editable-input" type="text" name="phone"
                                                value="${user.phoneNumber}" disabled>
                                            <span class="text-danger">${errors.phoneNumberError}</span>
                                        </div>

                                        <div class="field">
                                            <i class="fa-solid fa-calendar-days left-icon"></i>
                                            <input class="editable-input" type="date" name="birthDay"
                                                value="${birthDayStr}" disabled>
                                            <span class="text-danger">${errors.birthError}</span>
                                            <span class="text-danger">${errors.ageError}</span>
                                        </div>

                                        <div class="field edit-only" style="display:none;">
                                            <i class="fa-solid fa-lock left-icon"></i>
                                            <input class="editable-input" type="password" name="oldPassword"
                                                placeholder="Nhập mật khẩu cũ">
                                            <span class="text-danger">${errors.errorPass}</span>
                                        </div>

                                        <div class="field edit-only" style="display:none;">
                                            <i class="fa-solid fa-lock left-icon"></i>
                                            <input class="editable-input" type="password" name="newPassword"
                                                placeholder="Mật khẩu mới (nếu đổi)">
                                            <span class="text-danger">${errors.passwordError}</span>
                                        </div>

                                    </div>

                                    <div class="buttons">
                                        <button type="button" id="editBtn" class="btn gray">Sửa</button>
                                        <button type="submit" id="saveBtn" class="btn" style="display:none;">Lưu
                                        </button>
                                        <button type="button" id="cancelBtn" class="btn cancel"
                                            style="display:none;">Hủy
                                        </button>
                                    </div>

                                </form>
                            </div>
                            <script>
                                (function () {
                                    const editBtn = document.getElementById("editBtn");
                                    const saveBtn = document.getElementById("saveBtn");
                                    const cancelBtn = document.getElementById("cancelBtn");

                                    const inputs = document.querySelectorAll(".editable-input");
                                    const editOnlyFields = document.querySelectorAll(".edit-only");

                                    const backup = {};

                                    editBtn.onclick = () => {
                                        inputs.forEach(input => {
                                            backup[input.name] = input.value;

                                            input.disabled = false;
                                        });

                                        editOnlyFields.forEach(div => {
                                            div.style.display = "flex";
                                            const pwd = div.querySelector("input");
                                            if (pwd) pwd.disabled = false;
                                        });

                                        editBtn.style.display = "none";
                                        saveBtn.style.display = "inline-block";
                                        cancelBtn.style.display = "inline-block";
                                    };

                                    cancelBtn.onclick = (e) => {
                                        e.preventDefault();

                                        inputs.forEach(input => {
                                            input.value = backup[input.name] || "";
                                            input.disabled = true;
                                        });

                                        editOnlyFields.forEach(div => {
                                            div.style.display = "none";
                                            const pwd = div.querySelector("input");
                                            if (pwd) {
                                                pwd.value = "";
                                                pwd.disabled = true;
                                            }
                                        });

                                        editBtn.style.display = "inline-block";
                                        saveBtn.style.display = "none";
                                        cancelBtn.style.display = "none";
                                    };
                                })();
                            </script>
                            <script>
                                (function () {
                                    const alerts = document.querySelectorAll(".auto-hide");

                                    alerts.forEach(alert => {
                                        setTimeout(() => {
                                            alert.style.transition = "opacity 0.5s ease";
                                            alert.style.opacity = "0";
                                            setTimeout(() => alert.remove(), 500);
                                        }, 2000);
                                    });
                                })();
                            </script>