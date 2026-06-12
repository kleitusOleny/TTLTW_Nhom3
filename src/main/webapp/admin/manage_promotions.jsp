<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
        <%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
            <!DOCTYPE html>
            <html lang="vi">

            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1">
                <title>Quản Lí Khuyến Mãi</title>
                <link rel="stylesheet" href="${pageContext.request.contextPath}/admin/admin_css/manage_promotion_style.css?v=1.1">
                <link rel="stylesheet" href="https://cdn.datatables.net/1.11.5/css/jquery.dataTables.min.css">
                <script type="module" src="https://unpkg.com/ionicons@7.1.0/dist/ionicons/ionicons.esm.js"></script>
                <script nomodule src="https://unpkg.com/ionicons@7.1.0/dist/ionicons/ionicons.js"></script>
                <script src="${pageContext.request.contextPath}/popup.js"></script>
            </head>

            <body>
                <div class="dashboard-container">
                    <nav class="dashboard-sidebar">
                        <ul class="sidebar-items">
                            <div class="group-avatar">
                                <%@ include file="/admin/components/avatar.jsp" %>
                                    <%@ include file="/admin/components/notify_icon.jsp" %>
                            </div>
                            <c:set var="activePage" value="promotion" scope="request" />
                            <%@ include file="/admin/components/sidebar_items_component.jsp" %>
                        </ul>
                        <div class="text">━ Được update tới 2025 ━</div>
                    </nav>
                    <div class="dashboard-content">
                        <main class="dashboard-main-content">
                            <div class="button-group">
                                <h2>Quản Lí Khuyến Mãi</h2>
                                <div class="func-group">
                                    <button class="button apply" id="open-apply-modal-btn">
                                        <ion-icon name="pricetag-outline"></ion-icon>
                                        Áp dụng mã
                                    </button>
                                    <button class="button add" id="open-add-modal-btn">
                                        <ion-icon name="add-circle-outline" class="type-needCss"></ion-icon>
                                        Thêm khuyến mãi
                                    </button>
                                </div>
                            </div>

                            <div class="table-container">
                                <table id="promotion-table-main" class="promotion-table" style="width:100%">
                                    <thead>
                                        <tr class="sample">
                                            <th class="col-id">ID</th>
                                            <th class="col-code">Mã</th>
                                            <th class="col-value">Giá trị</th>
                                            <th class="col-type">Loại</th>
                                            <th class="col-quantity">Số lượng</th>
                                            <th class="col-start">Ngày bắt đầu</th>
                                            <th class="col-end">Ngày kết thúc</th>
                                            <th class="col-status">Trạng Thái</th>
                                            <th class="col-action">Hành động</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach items="${discounts}" var="d">
                                            <tr>
                                                <td class="cell-id">${d.id}</td>
                                                <td class="cell-code">${d.discountCode}</td>
                                                <td class="cell-value">
                                                    <fmt:formatNumber value="${d.discountValue}" type="number"
                                                        maxFractionDigits="0" />
                                                    <c:choose>
                                                        <c:when
                                                            test="${d.discountType == 'PERCENT' || d.discountType == 'percent'}">
                                                            %</c:when>
                                                        <c:otherwise>đ</c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td class="cell-type">${d.discountType}</td>
                                                <td class="cell-quantity">${d.quantity}</td>
                                                <td class="cell-start">
                                                    <fmt:formatDate value="${d.discountFrom}" pattern="dd/MM/yyyy" />
                                                </td>
                                                <td class="cell-end">
                                                    <fmt:formatDate value="${d.discountTo}" pattern="dd/MM/yyyy" />
                                                </td>
                                                <td class="cell-status">
                                                    <span class="status-badge ${d.isDelete ? 'inactive' : 'active'}"
                                                          style="${d.isDelete ? 'background-color: #6c757d; color: white;' : ''}">
                                                            ${d.isDelete ? 'Đã ẩn' : 'Hoạt động'}
                                                    </span>
                                                </td>
                                                <td class="cell-action">
                                                    <c:choose>
                                                        <c:when test="${d.isDelete}">
                                                            <button onclick="openEditModal(${d.id})" class="edit btn"
                                                                title="Sửa">
                                                                <ion-icon name="create-outline"></ion-icon>
                                                            </button>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <button onclick="openEditModal(${d.id})" class="edit btn"
                                                                title="Sửa">
                                                                <ion-icon name="create-outline"></ion-icon>
                                                            </button>
                                                            <button onclick="confirmDelete(${d.id})" class="delete btn"
                                                                title="Xóa">
                                                                <ion-icon name="trash-outline"></ion-icon>
                                                            </button>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </div>
                        </main>
                    </div>
                </div>

                <!-- Apply Discount Modal -->
                <div class="modal-overlay" id="apply-discount-modal">
                    <div class="modal-content">
                        <div class="modal-header-custom">
                            <h2>
                                <ion-icon name="pricetag-outline"></ion-icon>
                                Áp dụng mã giảm giá
                            </h2>
                            <button class="modal-close" id="close-apply-modal-btn">
                                <ion-icon name="close-outline"></ion-icon>
                            </button>
                        </div>
                        <form id="applyDiscountForm" class="apply-form">
                            <label for="discountSelect" class="form-label-custom">Chọn mã giảm giá</label>
                            <select id="discountSelect" class="custom-select" required>
                                <option value="">-- Chọn mã giảm giá --</option>
                                <c:forEach items="${discounts}" var="discount">
                                    <c:if test="${!discount.isDelete && discount.active}">
                                        <option value="${discount.id}">
                                            ${discount.discountCode} -
                                            <fmt:formatNumber value="${discount.discountValue}" type="number"
                                                maxFractionDigits="0" />
                                            <c:choose>
                                                <c:when
                                                    test="${discount.discountType == 'PERCENT' || discount.discountType == 'percent'}">
                                                    %</c:when>
                                                <c:otherwise>đ</c:otherwise>
                                            </c:choose>
                                        </option>
                                    </c:if>
                                </c:forEach>
                            </select>

                            <label class="form-label-custom">Chọn kiểu áp dụng</label>
                            <div class="apply-type-group">
                                <label class="radio-pill">
                                    <input type="radio" name="applyType" value="CATEGORY" checked>
                                    <span>Danh mục</span>
                                </label>
                                <label class="radio-pill">
                                    <input type="radio" name="applyType" value="PRODUCT">
                                    <span>Sản phẩm</span>
                                </label>
                                <label class="radio-pill">
                                    <input type="radio" name="applyType" value="MANUFACTURER">
                                    <span>Nhà sản xuất</span>
                                </label>
                            </div>
                            <div class="apply-search-bar">
                                <ion-icon name="search-outline"></ion-icon>
                                <input type="text" id="applySearchInput" placeholder="Tìm kiếm nhanh..." autocomplete="off">
                            </div>

                            <div class="apply-lists">
                                <div class="apply-list-toolbar">
                                    <button type="button" class="apply-toolbar-btn" id="selectAllBtn">Chọn tất cả</button>
                                    <button type="button" class="apply-toolbar-btn" id="deselectAllBtn">Bỏ chọn</button>
                                    <span class="apply-count" id="applySelectedCount">0 đã chọn</span>
                                </div>

                                <div class="apply-section" data-apply="CATEGORY">
                                    <c:if test="${empty categories}">
                                        <div class="empty-note">Chưa có danh mục khả dụng.</div>
                                    </c:if>
                                    <c:forEach items="${categories}" var="cat">
                                        <label class="checkbox-row" data-search-text="${cat.categoryName}">
                                            <input type="checkbox" name="categoryIds" value="${cat.id}">
                                            <span>${cat.categoryName}</span>
                                        </label>
                                    </c:forEach>
                                </div>
                                <div class="apply-section d-none" data-apply="PRODUCT">
                                    <c:if test="${empty products}">
                                        <div class="empty-note">Chưa có sản phẩm khả dụng.</div>
                                    </c:if>
                                    <c:forEach items="${products}" var="p">
                                        <label class="checkbox-row" data-search-text="${p.productName} ${p.id}">
                                            <input type="checkbox" name="productIds" value="${p.id}">
                                            <span>${p.productName} <small style="color:#888">(${p.id})</small></span>
                                        </label>
                                    </c:forEach>
                                </div>
                                <div class="apply-section d-none" data-apply="MANUFACTURER">
                                    <c:if test="${empty manufacturers}">
                                        <div class="empty-note">Chưa có nhà sản xuất khả dụng.</div>
                                    </c:if>
                                    <c:forEach items="${manufacturers}" var="manu">
                                        <label class="checkbox-row" data-search-text="${manu.manufacturerName}">
                                            <input type="checkbox" name="manufacturerIds" value="${manu.id}">
                                            <span>${manu.manufacturerName}</span>
                                        </label>
                                    </c:forEach>
                                </div>
                            </div>

                            <div id="applyAlert" class="alert-box d-none"></div>

                            <div class="group-button-action section">
                                <button type="button" class="cancel element-button" id="cancel-apply-btn">Huỷ</button>
                                <button type="button" class="fix-btn element-button" id="applyDiscountBtn">
                                    <span class="btn-text">Áp dụng</span>
                                    <span class="btn-loading d-none">Đang xử lý...</span>
                                </button>
                            </div>
                        </form>
                    </div>
                </div>

                <div class="modal-overlay" id="success-modal">
                    <div class="modal-content" style="max-width: 400px; text-align: center; padding: 30px;">
                        <ion-icon name="checkmark-circle" style="font-size: 60px; color: #08c249; margin-bottom: 15px;"></ion-icon>
                        <h2 style="font-size: 1.5rem; margin-bottom: 10px;">Thành công!</h2>
                        <p id="success-modal-message" style="color: #555; margin-bottom: 20px;">Đã thao tác thành công.</p>
                        <button type="button" class="fix-btn element-button" style="width: 100%;" onclick="document.getElementById('success-modal').classList.remove('show');">Xong</button>
                    </div>
                </div>
                <div class="modal-overlay-edit_information" id="edit_information-promotion-modal">
                    <div class="modal-content-edit_information">
                        <h2>Sửa khuyến mãi</h2>
                        <form action="${pageContext.request.contextPath}/admin/update-promotion" method="post">
                            <input type="hidden" id="edit-id" name="id" value="${discountEdit.id}">

                            <div class="form-row">
                                <div class="form-col">
                                    <div class="form-group">
                                        <label for="code_edit">Mã khuyến mãi <span style="color: red">*</span></label>
                                        <input type="text" id="code_edit" name="code_edit" class="form-control" required
                                            value="${discountEdit.discountCode}">
                                    </div>
                                </div>
                                <div class="form-col">
                                    <div class="form-group">
                                        <label for="quantity_edit">Số lượng <span style="color: red">*</span></label>
                                        <input type="number" id="quantity_edit" name="quantity_edit"
                                            class="form-control" required min="1" value="${discountEdit.quantity}">
                                    </div>
                                </div>
                            </div>

                            <div class="form-row">
                                <div class="form-col">
                                    <div class="form-group">
                                        <label for="type_edit">Loại giảm giá <span style="color: red">*</span></label>
                                        <select id="type_edit" name="type_edit" class="form-control" required>
                                            <option value="PERCENT" ${discountEdit.discountType=='PERCENT' ? 'selected'
                                                : '' }>Phần trăm (%)</option>
                                            <option value="FIXED" ${discountEdit.discountType=='FIXED' ? 'selected' : ''
                                                }>Số tiền cố định (VNĐ)</option>
                                            <option value="AMOUNT" ${discountEdit.discountType=='AMOUNT' ? 'selected'
                                                : '' }>Miễn phí vận chuyển</option>
                                        </select>
                                    </div>
                                </div>
                                <div class="form-col">
                                    <div class="form-group">
                                        <label for="value_edit">Giá trị <span style="color: red">*</span></label>
                                        <input type="text" id="value_edit" name="value_edit" class="form-control"
                                            required
                                            value="<fmt:formatNumber value='${discountEdit.discountValue}' pattern='#' />">
                                    </div>
                                </div>
                            </div>

                            <div class="form-row">
                                <div class="form-col">
                                    <div class="form-group">
                                        <label for="start_edit">Ngày bắt đầu <span style="color: red">*</span></label>
                                        <fmt:formatDate value="${discountEdit.discountFrom}" pattern="yyyy-MM-dd"
                                            var="startDate" />
                                        <input type="date" id="start_edit" name="start_edit" class="form-control"
                                            required value="${startDate}">
                                    </div>
                                </div>
                                <div class="form-col">
                                    <div class="form-group">
                                        <label for="end_edit">Ngày kết thúc <span style="color: red">*</span></label>
                                        <fmt:formatDate value="${discountEdit.discountTo}" pattern="yyyy-MM-dd"
                                            var="endDate" />
                                        <input type="date" id="end_edit" name="end_edit" class="form-control" required
                                            value="${endDate}">
                                    </div>
                                </div>
                            </div>

                            <div class="form-group">
                                <label for="status_edit">Trạng thái</label>
                                <select id="status_edit" name="status_edit" class="form-control">
                                    <option value="Hoạt động" ${!discountEdit.isDelete && discountEdit.active ? 'selected' : '' }>Hoạt động</option>
                                    <option value="Đã khóa" ${!discountEdit.isDelete && !discountEdit.active ? 'selected' : '' }>Đã khóa</option>
                                    <option value="Đã ẩn" ${discountEdit.isDelete ? 'selected' : '' }>Đã ẩn</option>
                                </select>
                            </div>

                            <div class="form-group">
                                <label for="apply_type_edit">Áp dụng cho</label>
                                <select id="apply_type_edit" name="apply_type_edit" class="form-control">
                                    <option value="order" ${discountEdit.applyType=='order' ? 'selected' : '' }>Đơn hàng
                                    </option>
                                    <option value="shipping" ${discountEdit.applyType=='shipping' ? 'selected' : '' }>
                                        Vận chuyển</option>
                                </select>
                            </div>

                            <div class="group-button-action section">
                                <button type="button" class="cancel element-button" id="close-modal-btn7">Huỷ</button>
                                <button type="submit" class="fix-btn element-button">Lưu thay đổi</button>
                            </div>
                        </form>
                    </div>
                </div>

                <!-- Add Promotion Modal -->
                <div class="modal-overlay-edit_information" id="add-promotion-modal">
                    <div class="modal-content-edit_information">
                        <h2>Thêm khuyến mãi</h2>
                        <form action="${pageContext.request.contextPath}/admin/add-promotion" method="post">

                            <div class="form-row">
                                <div class="form-col">
                                    <div class="form-group">
                                        <label for="code_add">Mã khuyến mãi <span style="color: red">*</span></label>
                                        <input type="text" id="code_add" name="code_add" class="form-control" required
                                            placeholder="VD: SALE20">
                                    </div>
                                </div>
                                <div class="form-col">
                                    <div class="form-group">
                                        <label for="quantity_add">Số lượng <span style="color: red">*</span></label>
                                        <input type="number" id="quantity_add" name="quantity_add"
                                            class="form-control" required min="1" value="1">
                                    </div>
                                </div>
                            </div>

                            <div class="form-row">
                                <div class="form-col">
                                    <div class="form-group">
                                        <label for="type_add">Loại giảm giá <span style="color: red">*</span></label>
                                        <select id="type_add" name="type_add" class="form-control" required>
                                            <option value="PERCENT">Phần trăm (%)</option>
                                            <option value="FIXED">Số tiền cố định (VNĐ)</option>
                                            <option value="AMOUNT">Miễn phí vận chuyển</option>
                                        </select>
                                    </div>
                                </div>
                                <div class="form-col">
                                    <div class="form-group">
                                        <label for="value_add">Giá trị <span style="color: red">*</span></label>
                                        <input type="text" id="value_add" name="value_add" class="form-control"
                                            required placeholder="VD: 15">
                                    </div>
                                </div>
                            </div>

                            <div class="form-row">
                                <div class="form-col">
                                    <div class="form-group">
                                        <label for="start_add">Ngày bắt đầu <span style="color: red">*</span></label>
                                        <input type="date" id="start_add" name="start_add" class="form-control" required>
                                    </div>
                                </div>
                                <div class="form-col">
                                    <div class="form-group">
                                        <label for="end_add">Ngày kết thúc <span style="color: red">*</span></label>
                                        <input type="date" id="end_add" name="end_add" class="form-control" required>
                                    </div>
                                </div>
                            </div>

                            <div class="form-group">
                                <label for="status_add">Trạng thái</label>
                                <select id="status_add" name="status_add" class="form-control">
                                    <option value="Hoạt động" selected>Hoạt động</option>
                                    <option value="Đã khóa">Đã khóa</option>
                                </select>
                            </div>

                            <div class="form-group">
                                <label for="apply_type_add">Áp dụng cho</label>
                                <select id="apply_type_add" name="apply_type_add" class="form-control">
                                    <option value="order" selected>Đơn hàng</option>
                                    <option value="shipping">Vận chuyển</option>
                                </select>
                            </div>

                            <div class="group-button-action section">
                                <button type="button" class="cancel element-button" id="close-add-modal-btn">Huỷ</button>
                                <button type="submit" class="fix-btn element-button">Thêm mới</button>
                            </div>
                        </form>
                    </div>
                </div>

    <!-- Delete Confirmation Modal -->
    <div class="modal-overlay" id="delete-confirm-modal">
        <div class="modal-content">
            <h2>Xác nhận xóa khuyến mãi</h2>
            <p>Bạn có chắc muốn xóa khuyến mãi này không? Hành động này không thể hoàn tác.</p>
            <div class="group-button-action section">
                <button type="button" class="element-button cancel" id="cancel-delete-btn">Huỷ</button>
                <button type="button" class="element-button del" id="confirm-delete-btn">Xóa</button>
            </div>
        </div>
    </div>

                    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
                    <script src="https://cdn.datatables.net/1.11.5/js/jquery.dataTables.min.js"></script>
                    <script>
                        $(document).ready(function () {
                            $('#promotion-table-main').DataTable({
                                language: {
                                    url: '${pageContext.request.contextPath}/assets/datatables/Vietnamese.json',
                                },
                            });
                        });

let deletePromotionId = null;
function confirmDelete(id) {
    deletePromotionId = id;
    const modal = document.getElementById('delete-confirm-modal');
    if (modal) modal.classList.add('show');
}

document.addEventListener('DOMContentLoaded', function () {
    const cancelBtn = document.getElementById('cancel-delete-btn');
    const confirmBtn = document.getElementById('confirm-delete-btn');
    if (cancelBtn) {
        cancelBtn.addEventListener('click', function () {
            const modal = document.getElementById('delete-confirm-modal');
            if (modal) modal.classList.remove('show');
            deletePromotionId = null;
        });
    }
    if (confirmBtn) {
        confirmBtn.addEventListener('click', function () {
            if (deletePromotionId) {
                const url = '${pageContext.request.contextPath}/admin/delete-promotion?id=' + deletePromotionId;
                console.log('Sending delete request to', url);
                fetch(url, {
                    method: 'POST',
                    headers: {
                        'Accept': 'application/json'
                    }
                })
                .then(response => response.json().then(data => ({status: response.status, body: data})))
                .then(result => {
                    console.log('Delete response', result);
                    if (result.status === 200 && result.body.success) {
                        window.location.reload();
                    } else {
                        alert(result.body.error || 'Có lỗi xảy ra khi xóa khuyến mãi');
                    }
                })
                .catch(error => {
                    console.error('Fetch error:', error);
                    alert('Có lỗi xảy ra khi xóa khuyến mãi');
                })
                .finally(() => {
                    const modal = document.getElementById('delete-confirm-modal');
                    if (modal) modal.classList.remove('show');
                    deletePromotionId = null;
                });
            }
        });
    }
});

                        function openEditModal(id) {
                            location.href = '${pageContext.request.contextPath}/admin/get-promotion?id=' + id;
                        }

                        // Apply Discount Modal Logic
                        const applyModal = document.getElementById('apply-discount-modal');
                        const openApplyBtn = document.getElementById('open-apply-modal-btn');
                        const closeApplyBtn = document.getElementById('close-apply-modal-btn');
                        const cancelApplyBtn = document.getElementById('cancel-apply-btn');
                        const applyDiscountBtn = document.getElementById('applyDiscountBtn');
                        const applyAlert = document.getElementById('applyAlert');

                        if (openApplyBtn) {
                            openApplyBtn.addEventListener('click', () => {
                                applyModal.classList.add('show');
                            });
                        }

                        function closeApplyModal() {
                            applyModal.classList.remove('show');
                            document.getElementById('applyDiscountForm').reset();
                            if (applyAlert) applyAlert.classList.add('d-none');
                            document.querySelectorAll('.apply-section').forEach(el => el.classList.add('d-none'));
                            const catSection = document.querySelector('.apply-section[data-apply="CATEGORY"]');
                            if (catSection) catSection.classList.remove('d-none');
                        }

                        if (closeApplyBtn) closeApplyBtn.addEventListener('click', closeApplyModal);
                        if (cancelApplyBtn) cancelApplyBtn.addEventListener('click', closeApplyModal);

                        document.querySelectorAll('input[name="applyType"]').forEach(radio => {
                            radio.addEventListener('change', function () {
                                const type = this.value;
                                document.querySelectorAll('.apply-section').forEach(el => {
                                    if (el.getAttribute('data-apply') === type) {
                                        el.classList.remove('d-none');
                                    } else {
                                        el.classList.add('d-none');
                                    }
                                });
                            });
                        });

                        // Filter Search Logic
                        const searchInput = document.getElementById('applySearchInput');
                        if (searchInput) {
                            searchInput.addEventListener('input', function() {
                                const keyword = this.value.toLowerCase().trim();
                                const activeSection = document.querySelector('.apply-section:not(.d-none)');
                                if (activeSection) {
                                    const rows = activeSection.querySelectorAll('.checkbox-row');
                                    rows.forEach(row => {
                                        const text = row.getAttribute('data-search-text') ? row.getAttribute('data-search-text').toLowerCase() : '';
                                        if (text.includes(keyword)) {
                                            row.style.display = 'flex';
                                        } else {
                                            row.style.display = 'none';
                                        }
                                    });
                                }
                            });
                        }
                        const selectAllBtn = document.getElementById('selectAllBtn');
                        const deselectAllBtn = document.getElementById('deselectAllBtn');
                        const countDisplay = document.getElementById('applySelectedCount');

                        function updateSelectedCount() {
                            const activeSection = document.querySelector('.apply-section:not(.d-none)');
                            if (activeSection && countDisplay) {
                                const count = activeSection.querySelectorAll('input[type="checkbox"]:checked').length;
                                countDisplay.textContent = count + ' đã chọn';
                            }
                        }

                        if (selectAllBtn) {
                            selectAllBtn.addEventListener('click', function() {
                                const activeSection = document.querySelector('.apply-section:not(.d-none)');
                                if (activeSection) {
                                    const rows = activeSection.querySelectorAll('.checkbox-row');
                                    rows.forEach(row => {
                                        if (row.style.display !== 'none') {
                                            const cb = row.querySelector('input[type="checkbox"]');
                                            if (cb) cb.checked = true;
                                        }
                                    });
                                    updateSelectedCount();
                                }
                            });
                        }

                        if (deselectAllBtn) {
                            deselectAllBtn.addEventListener('click', function() {
                                const activeSection = document.querySelector('.apply-section:not(.d-none)');
                                if (activeSection) {
                                    const rows = activeSection.querySelectorAll('.checkbox-row');
                                    rows.forEach(row => {
                                        if (row.style.display !== 'none') {
                                            const cb = row.querySelector('input[type="checkbox"]');
                                            if (cb) cb.checked = false;
                                        }
                                    });
                                    updateSelectedCount();
                                }
                            });
                        }

                        // Update count on checkbox change and radio change
                        document.querySelectorAll('.apply-section input[type="checkbox"]').forEach(cb => {
                            cb.addEventListener('change', updateSelectedCount);
                        });
                        document.querySelectorAll('input[name="applyType"]').forEach(radio => {
                            radio.addEventListener('change', function() {
                                if (searchInput) searchInput.value = ''; // clear search on tab change
                                document.querySelectorAll('.checkbox-row').forEach(row => row.style.display = 'flex');
                                updateSelectedCount();
                            });
                        });


                        if (applyDiscountBtn) {
                            applyDiscountBtn.addEventListener('click', function () {
                                const form = document.getElementById('applyDiscountForm');
                                const discountSelect = document.getElementById('discountSelect');
                                const discountId = discountSelect ? discountSelect.value : '';
                                const applyTypeRadio = document.querySelector('input[name="applyType"]:checked');
                                const applyType = applyTypeRadio ? applyTypeRadio.value : '';

                                if (!discountId) {
                                    showAlert('Vui lòng chọn mã giảm giá', 'danger');
                                    return;
                                }

                                let selectedIds = [];
                                if (applyType === 'CATEGORY') {
                                    document.querySelectorAll('input[name="categoryIds"]:checked').forEach(cb => selectedIds.push(cb.value));
                                } else if (applyType === 'PRODUCT') {
                                    document.querySelectorAll('input[name="productIds"]:checked').forEach(cb => selectedIds.push(cb.value));
                                } else if (applyType === 'MANUFACTURER') {
                                    document.querySelectorAll('input[name="manufacturerIds"]:checked').forEach(cb => selectedIds.push(cb.value));
                                }

                                if (selectedIds.length === 0) {
                                    showAlert('Vui lòng chọn ít nhất một mục để áp dụng', 'danger');
                                    return;
                                }

                                const formData = new URLSearchParams();
                                formData.append('discountId', discountId);
                                formData.append('applyType', applyType);

                                if (applyType === 'CATEGORY') {
                                    selectedIds.forEach(id => formData.append('categoryIds', id));
                                } else if (applyType === 'PRODUCT') {
                                    selectedIds.forEach(id => formData.append('productIds', id));
                                } else if (applyType === 'MANUFACTURER') {
                                    selectedIds.forEach(id => formData.append('manufacturerIds', id));
                                }

                                const btnText = applyDiscountBtn.querySelector('.btn-text');
                                const btnLoading = applyDiscountBtn.querySelector('.btn-loading');
                                applyDiscountBtn.disabled = true;
                                if (btnText) btnText.classList.add('d-none');
                                if (btnLoading) btnLoading.classList.remove('d-none');

                                fetch('${pageContext.request.contextPath}/admin/apply-discount', {
                                    method: 'POST',
                                    headers: {
                                        'Content-Type': 'application/x-www-form-urlencoded',
                                    },
                                    body: formData
                                })
                                    .then(response => response.json())
                                    .then(data => {
                                        if (data.success) {
                                            closeApplyModal();
                                            const successModal = document.getElementById('success-modal');
                                            if (successModal) {
                                                document.getElementById('success-modal-message').textContent = data.message;
                                                successModal.classList.add('show');
                                            } else {
                                                alert(data.message);
                                            }
                                        } else {
                                            showAlert(data.message, 'danger');
                                        }
                                    })
                                    .catch(error => {
                                        console.error('Error:', error);
                                        showAlert('Có lỗi xảy ra', 'danger');
                                    })
                                    .finally(() => {
                                        applyDiscountBtn.disabled = false;
                                        if (btnText) btnText.classList.remove('d-none');
                                        if (btnLoading) btnLoading.classList.add('d-none');
                                    });
                            });
                        }

                        function showAlert(message, type) {
                            if (applyAlert) {
                                applyAlert.textContent = message;
                                applyAlert.className = 'alert-box alert-' + type;
                                applyAlert.classList.remove('d-none');
                            } else {
                                alert(message);
                            }
                        }

                        // Add Promotion Modal Logic
                        const addModal = document.getElementById('add-promotion-modal');
                        const openAddBtn = document.getElementById('open-add-modal-btn');
                        const closeAddBtn = document.getElementById('close-add-modal-btn');

                        if (openAddBtn) {
                            openAddBtn.addEventListener('click', function () {
                                addModal.classList.add('show');
                            });
                        }
                        if (closeAddBtn) {
                            closeAddBtn.addEventListener('click', function () {
                                addModal.classList.remove('show');
                            });
                        }

                        <c:if test="${not empty discountEdit}">
                            $(document).ready(function() {
                                document.getElementById('edit_information-promotion-modal').classList.add('show');
             });
                            // Close edit modal
                            document.getElementById('close-modal-btn7').addEventListener('click', function () {
                                document.getElementById('edit_information-promotion-modal').classList.remove('show');
                            location.href = '${pageContext.request.contextPath}/admin/manage-promotions';
            });
                        </c:if>
                    </script>
            </body>

            </html>