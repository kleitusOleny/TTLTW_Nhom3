<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
        <link rel="stylesheet" href="<%=request.getContextPath()%>/css/address_style.css">
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
                    <div class="address-card" style="cursor: pointer;" data-fullname="${addr.fullName}"
                        data-phone="${addr.phoneNumber}" data-address="${addr.addressLine}, ${addr.ward}, ${addr.district} ,${addr.city}">
                        <div class="address-card-details">
                            <p class="name">
                                <strong>Người nhận:</strong> ${addr.fullName}
                                <c:if test="${addr.isDefault}">
                                    <span class="default-badge">Mặc định</span>
                                </c:if>
                            </p>
                            <p class="phone"><strong>Số điện thoại:</strong> ${addr.phoneNumber}</p>
                            <p class="address">
                                <strong>Địa chỉ:</strong> ${addr.addressLine}, ${addr.ward}, ${addr.district} ,${addr.city}
                            </p>
                        </div>

                        <div class="address-card-actions" onclick="event.stopPropagation()"
                            style="display: flex; flex-direction: row; align-items: center; gap: 8px; margin-left: auto;">
                            <c:if test="${!addr.isDefault}">
                                <form action="${pageContext.request.contextPath}/address" method="post"
                                    style="margin: 0;">
                                    <input type="hidden" name="action" value="default">
                                    <input type="hidden" name="id" value="${addr.id}">
                                    <input type="hidden" name="view" value="${view}">
                                    <button class="btn set-default-btn" title="Đặt làm mặc định">Đặt mặc định</button>
                                </form>
                            </c:if>
                            <!-- EDIT -->
                            <button class="btn edit-btn" data-id="${addr.id}" data-name="${addr.fullName}"
                                data-phone="${addr.phoneNumber}" data-city="${addr.city}" data-district="${addr.district}" data-ward="${addr.ward}"
                                data-address="${addr.addressLine}" title="Chỉnh sửa">
                                <i class="fa-solid fa-pen-to-square"></i>
                            </button>

                            <!-- DELETE -->
                            <form action="${pageContext.request.contextPath}/address" method="post"
                                onsubmit="return confirm('Xóa địa chỉ này?')" style="margin: 0;">
                                <input type="hidden" name="action" value="delete">
                                <input type="hidden" name="id" value="${addr.id}">
                                <input type="hidden" name="view" value="${view}">
                                <button class="btn delete-btn" title="Xóa">
                                    <i class="fa-solid fa-trash"></i>
                                </button>
                            </form>
                        </div>
                    </div>
                </c:forEach>
            </div>

            <!-- ADD -->
            <button class="add-address-btn" id="add-address-btn">
                <i class="fa-solid fa-plus"></i> Thêm địa chỉ mới
            </button>
        </div>

        <!-- ===== MODAL ===== -->
        <div id="addressModal" class="modal">
            <div class="modal-content">
                <div class="modal-header">
                    <h3>Địa chỉ mới</h3>
                    <span class="cancel-btn">&times;</span>
                </div>

                <form id="addressForm" action="${pageContext.request.contextPath}/address" method="post">
                    <input type="hidden" name="action" id="formAction" value="add">
                    <input type="hidden" name="id" id="addressId">
                    <input type="hidden" name="view" value="${view}">

                    <div class="form-group">
                        <label>Họ và tên</label>
                        <input type="text" name="fullName" pattern="^[A-Za-zÀ-ỹ\s]+$"
                            title="Họ tên không được chứa số hoặc ký tự đặc biệt" required>
                    </div>

                    <div class="form-group">
                        <label>Số điện thoại</label>
                        <input type="text" name="phone" required inputmode="numeric" pattern="^0[0-9]{9}$"
                            title="Số điện thoại phải bắt đầu bằng 0 và đủ 10 chữ số">
                    </div>

                    <div class="form-group">
                        <label>Tỉnh/Thành phố</label>
                        <select name="city" onchange="this.form.submit()">
                            <option value="">Chọn Tỉnh</option>
                            <c:forEach var="c" items="${cities}">
                                <option value="${c.code}" ${c.code == selectedCity ? "selected" : ""}>
                                        ${c.name}
                                </option>
                            </c:forEach>
                        </select>
                    </div>

                    <div class="form-group">
                        <label>Quận/Huyện</label>
                        <select name="district" onchange="this.form.submit()">
                            <option value="">Chọn Huyện</option>
                            <c:forEach var="d" items="${districts}">
                                <option value="${d.code}" ${d.code == selectedDistrict ? "selected" : ""}>
                                        ${d.name}
                                </option>
                            </c:forEach>
                        </select>
                    </div>

                    <div class="form-group">
                        <label>Phường/Xã</label>
                        <select name="ward">
                            <option value="">Chọn Xã</option>
                            <c:forEach var="w" items="${wards}">
                                <option value="${w.code}">
                                        ${w.name}
                                </option>
                            </c:forEach>
                        </select>
                    </div>

                    <div class="form-group">
                        <label>Địa chỉ chi tiết</label>
                        <input type="text" name="addressLine" required>
                    </div>

                    <button type="submit" class="add-address-btn">
                        <i class="fa-solid fa-save"></i> <span id="submitText">Lưu</span>
                    </button>
                </form>
            </div>
        </div>