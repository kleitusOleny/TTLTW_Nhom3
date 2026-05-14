<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/address_style.css">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css"
            integrity="sha512-SnH5WK+bZxgPHs44uWIX+LLJAJ9/2PkPKZ5QiAj6Ta86w+fsb2TkcmfRyVX3pBnMFcV7oQPJkl9QevSCWr3W6A=="
            crossorigin="anonymous" referrerpolicy="no-referrer" />
        <div id="address-card">
            <h2>Địa chỉ của tôi</h2>
            <c:if test="${not empty sessionScope.error}">
                <div class="alert alert-danger auto-hide">${sessionScope.error}</div>
                <c:remove var="error" scope="session" />
            </c:if>

            <c:if test="${not empty sessionScope.success}">
                <div class="alert alert-success auto-hide">${sessionScope.success}</div>
                <c:remove var="success" scope="session" />
            </c:if>
            <div class="address-list">
                <c:forEach var="addr" items="${addressList}">
                    <div class="address-card" data-fullname="${addr.fullName}" data-phone="${addr.phoneNumber}"
                        data-address="${addr.addressLine}, ${addr.ward}, ${addr.city}">

                        <div class="address-card-info">
                            <div class="info-item">
                                <span class="info-label">Người nhận:</span>
                                <span class="info-value">
                                    <strong>${addr.fullName}</strong>
                                    <c:if test="${addr.isDefault}">
                                        <span class="badge-default" style="margin-left: 8px;">Mặc định</span>
                                    </c:if>
                                </span>
                            </div>
                            <div class="info-item">
                                <span class="info-label">Số điện thoại:</span>
                                <span class="info-value">${addr.phoneNumber}</span>
                            </div>
                            <div class="info-item">
                                <span class="info-label">Địa chỉ:</span>
                                <span class="info-value">${addr.addressLine}, ${addr.ward}, ${addr.district},
                                    ${addr.city}</span>
                            </div>
                        </div>

                        <div class="address-card-actions">
                            <div class="action-row">
                                <c:if test="${not addr.isDefault}">
                                    <form action="${pageContext.request.contextPath}/address" method="post"
                                        style="display:inline;">
                                        <input type="hidden" name="action" value="default">
                                        <input type="hidden" name="id" value="${addr.id}">
                                        <button type="submit" class="btn-default">Đặt mặc định</button>
                                    </form>
                                </c:if>
                                <button class="btn-icon edit-btn" data-id="${addr.id}" data-name="${addr.fullName}"
                                    data-phone="${addr.phoneNumber}" data-city="${addr.city}" data-ward="${addr.ward}"
                                    data-district="${addr.district}" data-address="${addr.addressLine}"
                                    title="Chỉnh sửa">
                                    <i class="fa-solid fa-pen-to-square"></i>
                                </button>
                                <form action="${pageContext.request.contextPath}/address" method="post"
                                    style="display:inline;"
                                    onsubmit="return confirm('Bạn có chắc chắn muốn xóa địa chỉ này?');">
                                    <input type="hidden" name="action" value="delete">
                                    <input type="hidden" name="id" value="${addr.id}">
                                    <button type="submit" class="btn-icon delete-btn" title="Xóa">
                                        <i class="fa-solid fa-trash"></i>
                                    </button>
                                </form>
                            </div>
                        </div>
                    </div>
                </c:forEach>
            </div>

            <!-- ADD -->
            <button class="add-address-btn" id="add-address-btn">
                <i class="fa-solid fa-plus"></i> Thêm địa chỉ mới
            </button>
        </div>

        <div id="addressModal" class="modal">
            <div class="modal-content">
                <div class="modal-header">
                    <h3>Địa chỉ mới</h3>
                    <span class="cancel-btn">&times;</span>
                </div>

                <form id="addressForm" action="${pageContext.request.contextPath}/address" method="post" novalidate>
                    <input type="hidden" name="action" id="formAction" value="add">
                    <input type="hidden" name="id" id="addressId">
                    <input type="hidden" name="view" value="${view}">

                    <div class="form-group" id="addr_group-fullName">
                        <label>Họ và tên</label>
                        <input type="text" id="addr_fullName" name="fullName" class="editable-input"
                            placeholder="VD: Nguyễn Văn A" required>
                        <span id="addr_error-fullName" class="error-msg"></span>
                    </div>

                    <div class="form-group" id="addr_group-phone">
                        <label>Số điện thoại</label>
                        <input type="text" id="addr_phone" name="phone" class="editable-input"
                            placeholder="VD: 0912345678" required>
                        <span id="addr_error-phone" class="error-msg"></span>
                    </div>

                    <div class="form-group" id="addr_group-city">
                        <label>Tỉnh/Thành phố</label>
                        <input type="text" id="addr_city" name="city" class="editable-input" placeholder="Ví dụ: Hà Nội"
                            required>
                        <span id="addr_error-city" class="error-msg"></span>
                    </div>

                    <div class="form-group" id="addr_group-district">
                        <label>Quận/Huyện</label>
                        <input type="text" id="addr_district" name="district" class="editable-input"
                            placeholder="Ví dụ: Cầu Giấy" required>
                        <span id="addr_error-district" class="error-msg"></span>
                    </div>

                    <div class="form-group" id="addr_group-ward">
                        <label>Phường/Xã</label>
                        <input type="text" id="addr_ward" name="ward" class="editable-input"
                            placeholder="Ví dụ: Dịch Vọng" required>
                        <span id="addr_error-ward" class="error-msg"></span>
                    </div>

                    <div class="form-group" id="addr_group-addressLine">
                        <label>Địa chỉ chi tiết</label>
                        <input type="text" id="addr_addressLine" name="addressLine" class="editable-input"
                            placeholder="Số nhà, tên đường..." required>
                        <span id="addr_error-addressLine" class="error-msg"></span>
                    </div>

                    <button type="submit" class="add-address-btn" id="submitBtn">
                        <i class="fa-solid fa-save"></i> <span id="submitText">Lưu địa chỉ</span>
                    </button>
                </form>
            </div>
        </div>

        <script src="<%= request.getContextPath() %>/preventspace.js"></script>
        <script>
            function setStatus(id, isValid, message = "") {
                const input = document.getElementById('addr_' + id) || document.getElementById('addr_' + id + 'Select');
                const errorSpan = document.getElementById('addr_error-' + id);
                if (!input || !errorSpan) return;

                if (isValid) {
                    input.classList.remove("input-error");
                    input.classList.add("input-valid");
                    errorSpan.textContent = "";
                    errorSpan.style.display = 'none';
                } else {
                    input.classList.remove("input-valid");
                    input.classList.add("input-error");
                    errorSpan.textContent = message;
                    errorSpan.style.display = 'block';
                }
            }

            const validators = {
                fullName: () => {
                    const el = document.getElementById("addr_fullName");
                    const val = el.value.trim();
                    const namePattern = /^[\p{L}]+( [\p{L}]+)*$/u;
                    const isValid = val.length >= 2 && namePattern.test(val);
                    setStatus("fullName", isValid, val ? (namePattern.test(val) ? "" : "Họ tên không được chứa số, ký tự đặc biệt hoặc khoảng trắng thừa") : "Họ tên không được để trống");
                    return isValid;
                },
                phone: () => {
                    const el = document.getElementById("addr_phone");
                    const val = el.value.trim();
                    const phonePattern = /^0\d{9,10}$/;
                    const isValid = phonePattern.test(val);
                    setStatus("phone", isValid, "Số điện thoại phải bắt đầu bằng 0 và có 10-11 chữ số");
                    return isValid;
                },
                city: () => {
                    const el = document.getElementById("addr_city");
                    const isValid = el.value.trim().length >= 2;
                    setStatus("city", isValid, "Vui lòng nhập Tỉnh/Thành phố");
                    return isValid;
                },
                district: () => {
                    const el = document.getElementById("addr_district");
                    const isValid = el.value.trim().length >= 2;
                    setStatus("district", isValid, "Vui lòng nhập Quận/Huyện");
                    return isValid;
                },
                ward: () => {
                    const el = document.getElementById("addr_ward");
                    const isValid = el.value.trim().length >= 2;
                    setStatus("ward", isValid, "Vui lòng nhập Phường/Xã");
                    return isValid;
                },
                addressLine: () => {
                    const el = document.getElementById("addr_addressLine");
                    const val = el.value.trim();
                    const isValid = val.length >= 5;
                    setStatus("addressLine", isValid, "Địa chỉ cụ thể phải từ 5 ký tự trở lên");
                    return isValid;
                }
            };

            (function () {
                const modal = document.getElementById('addressModal');
                const addBtn = document.getElementById('add-address-btn');
                const closeBtn = modal.querySelector('.cancel-btn');
                const form = document.getElementById('addressForm');
                const submitText = document.getElementById('submitText');

                // Attach event listeners
                Object.keys(validators).forEach(key => {
                    const el = document.getElementById('addr_' + key);
                    if (el) {
                        el.addEventListener("input", validators[key]);
                        el.addEventListener("blur", validators[key]);
                    }
                });

                if (typeof preventspace === 'function') {
                    preventspace(['#addr_phone']);
                }

                form.onsubmit = (e) => {
                    e.preventDefault();
                    const isValid = Object.keys(validators).every(key => validators[key]());

                    if (!isValid) {
                        const firstError = form.querySelector('.input-error');
                        if (firstError) firstError.scrollIntoView({ behavior: 'smooth', block: 'center' });
                        alert("Vui lòng kiểm tra lại thông tin địa chỉ.");
                        return;
                    }

                    // AJAX Submit
                    const formData = new URLSearchParams(new FormData(form));
                    console.log("Dữ liệu gửi đi:", Object.fromEntries(formData));
                    const submitBtn = form.querySelector('button[type="submit"]');
                    const originalText = submitBtn.innerHTML;
                    submitBtn.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i> Đang lưu...';
                    submitBtn.disabled = true;

                    fetch(form.action, {
                        method: 'POST',
                        body: formData,
                        headers: {
                            'X-Requested-With': 'XMLHttpRequest'
                        }
                    })
                        .then(async res => {
                            const contentType = res.headers.get("content-type");
                            let data;
                            if (contentType && contentType.indexOf("application/json") !== -1) {
                                data = await res.json();
                            } else {
                                const text = await res.text();
                                console.error("Server returned non-JSON:", text);
                                throw new Error("Máy chủ trả về dữ liệu không hợp lệ (HTML thay vì JSON)");
                            }

                            if (res.ok && data.success) {
                                window.location.reload();
                            } else {
                                alert(data.error || 'Lỗi xử lý dữ liệu trên máy chủ');
                                submitBtn.innerHTML = originalText;
                                submitBtn.disabled = false;
                            }
                        })
                        .catch(err => {
                            console.error("Fetch error:", err);
                            alert('Lỗi: ' + err.message);
                            submitBtn.innerHTML = originalText;
                            submitBtn.disabled = false;
                        });
                };

                const open = (isEdit = false) => {
                    modal.style.display = 'flex';
                    if (!isEdit) {
                        form.reset();
                        document.getElementById('formAction').value = 'add';
                        submitText.textContent = 'Lưu địa chỉ';
                        form.querySelectorAll('.editable-input').forEach(input => {
                            input.classList.remove('input-error', 'input-valid');
                        });
                        form.querySelectorAll('.error-msg').forEach(s => s.style.display = 'none');
                    }
                };
                const close = () => {
                    modal.style.display = 'none';
                    setTimeout(() => {
                        form.reset();
                        form.querySelectorAll('.editable-input').forEach(input => {
                            input.classList.remove('input-error', 'input-valid');
                        });
                    }, 300);
                };

                addBtn.onclick = () => open(false);
                closeBtn.onclick = close;
                window.onclick = e => { if (e.target === modal) close(); };

                document.querySelectorAll('.edit-btn').forEach(btn => {
                    btn.onclick = (e) => {
                        e.stopPropagation();
                        const ds = btn.dataset;

                        document.getElementById('formAction').value = 'edit';
                        document.getElementById('addressId').value = ds.id;
                        form.fullName.value = ds.name || '';
                        form.phone.value = ds.phone || '';
                        form.addressLine.value = ds.address || '';
                        form.city.value = ds.city || '';
                        form.district.value = ds.district || '';
                        form.ward.value = ds.ward || '';

                        submitText.textContent = 'Cập nhật địa chỉ';
                        open(true);
                        // Initial validation check
                        Object.keys(validators).forEach(key => validators[key]());
                    };
                });

                document.querySelectorAll('.address-card').forEach(card => {
                    card.onclick = () => {
                        const data = {
                            fullName: card.dataset.fullname,
                            phone: card.dataset.phone,
                            address: card.dataset.address
                        };
                        window.parent.postMessage({ type: 'SELECT_ADDRESS', data: data }, '*');
                    };
                });
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
                    }, 2500);
                });
            })();
        </script>