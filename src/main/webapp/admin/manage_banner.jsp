<!DOCTYPE html>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <title>Quản Lí Banner</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <script type="module" src="https://unpkg.com/ionicons@7.1.0/dist/ionicons/ionicons.esm.js"></script>
    <script nomodule src="https://unpkg.com/ionicons@7.1.0/dist/ionicons/ionicons.js"></script>
    <script src="<%= request.getContextPath() %>/popup.js"></script>
    <link rel="stylesheet" href="https://cdn.datatables.net/2.0.8/css/dataTables.dataTables.css"/>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/admin/admin_css/manage_product_style.css">
    <style>
        .banner-preview {
            width: 120px;
            height: 60px;
            border-radius: var(--radius-md);
            object-fit: cover;
            border: 1px solid var(--border);
            background-color: #ffffff;
            box-shadow: var(--shadow-sm);
        }

        .product-table td a {
            color: var(--primary);
            text-decoration: none;
            font-weight: 500;
        }

        .product-table td a:hover {
            text-decoration: underline;
        }

        .form-grid-3 {
            display: grid;
            grid-template-columns: 1fr 1fr 1fr;
            gap: 16px;
        }

        @media (max-width: 768px) {
            .form-grid-3 {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>

<body>
<div class="dashboard-container">
    <nav class="dashboard-sidebar">
        <ul class="sidebar-items">
            <div class="group-avatar">
                <%@ include file="/admin/components/avatar.jsp" %>
                <%@ include file="/admin/components/notify_icon.jsp" %>
            </div>
            <c:set var="activePage" value="banner" scope="request"/>
            <%@ include file="/admin/components/sidebar_items_component.jsp" %>
        </ul>
    </nav>
    <div class="dashboard-content">
        <main class="dashboard-main-content">

            <div class="main-header">
                <h1>Quản Lí Slideshow Trang Chủ</h1>
                <div class="header-actions">
                    <button class="btn btn-danger remove-banner-btn">
                        <ion-icon name="trash-outline"></ion-icon>
                        Xóa (Đã chọn)
                    </button>
                    <button class="btn btn-primary add-banner-btn" data-target="banner-form-modal">
                        <ion-icon name="add-circle-outline"></ion-icon>
                        Thêm Banner
                    </button>
                </div>
            </div>

            <div class="filter-bar" style="justify-content: flex-end;">
                <div class="filter-item" style="max-width: 300px; flex: initial;">
                    <label>Tìm kiếm chung</label>
                    <input type="text" id="custom-search-input" class="filter-input" placeholder="Tìm kiếm banner...">
                </div>
            </div>

            <div class="table-container">
                <div class="table-scroll-wrapper">
                    <table id="banner-datatable" class="product-table">
                        <thead>
                        <tr>
                            <th style="width: 5%;"><input type="checkbox" id="select-all-checkbox"></th>
                            <th style="width: 5%;">ID</th>
                            <th style="width: 15%;">Tên Banner</th>
                            <th style="width: 15%;">Ảnh Banner</th>
                            <th style="width: 25%;">Link Đích</th>
                            <th style="width: 15%;">Ngày Sự Kiện</th>
                            <th style="width: 10%; text-align: center;">T/g Tồn Tại</th>
                            <th style="width: 10%; text-align: center;">Trạng Thái</th>
                            <th style="width: 10%; text-align: center;">Hành Động</th>
                        </tr>
                        </thead>
                        <tbody>
                        <c:forEach var="b" items="${banners}">
                            <tr>
                                <td><input type="checkbox" class="row-checkbox" value="${b.id}"/></td>
                                <td>${b.id}</td>
                                <td><c:out value="${b.name}"/></td>
                                <td>
                                    <img class="banner-preview"
                                         src="<%= request.getContextPath() %>/${b.urlBanner}"
                                         alt="Banner Preview"
                                         onerror="this.src='<%= request.getContextPath() %>/assets/banners/main_banner.jpg'">
                                </td>
                                <td>
                                    <a href="${b.targetUrl}" target="_blank" title="${b.targetUrl}">${b.targetUrl}</a>
                                </td>
                                <td>
                                    <fmt:formatDate value="${b.eventDate}" pattern="yyyy-MM-dd"/>
                                </td>
                                <td style="text-align: center;">${b.lifeTime}</td>
                                <td style="text-align: center;">
                                    <c:choose>
                                        <c:when test="${b.active}">
                                            <span class="stock-status in-stock">Active</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="stock-status out-of-stock">Inactive</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <div class="cell-action" style="justify-content: center;">
                                        <button type="button" class="btn btn-secondary edit-banner-btn"
                                                data-id="${b.id}"
                                                data-name="<c:out value='${b.name}'/>"
                                                data-url="${b.urlBanner}"
                                                data-target="${b.targetUrl}"
                                                data-date="<fmt:formatDate value='${b.eventDate}' pattern='yyyy-MM-dd'/>"
                                                data-life="${b.lifeTime}"
                                                data-active="${b.active ? 'Active' : 'Inactive'}">
                                            Sửa
                                        </button>

                                        <form action="${pageContext.request.contextPath}/banner-manager/delete"
                                              method="post" style="display:inline; margin:0;"
                                              onsubmit="return confirm('Bạn có chắc chắn muốn xóa banner ID: ${b.id}?');">
                                            <input type="hidden" name="action" value="delete">
                                            <input type="hidden" name="id" value="${b.id}">
                                            <button type="submit" class="btn btn-danger">Xoá</button>
                                        </form>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>
                        </tbody>
                    </table>
                </div>
            </div>
        </main>
    </div>
</div>

<div class="modal-overlay-form product-form-modal" id="banner-form-modal">
    <div class="modal-content-form">
        <button class="modal-close-form" id="close-form-btn">
            <ion-icon name="close-outline"></ion-icon>
        </button>
        <h2>Thêm / Cập Nhật Banner</h2>

        <form id="banner-form" action="${pageContext.request.contextPath}/banner-manager" method="post"
              enctype="multipart/form-data">
            <input type="hidden" id="form-action" name="action" value="add">
            <input type="hidden" id="banner-id" name="id" value="">
            <input type="hidden" id="banner-old-image" name="oldImage" value="">

            <div class="form-group">
                <label for="banner-name">TÊN BANNER</label>
                <input type="text" id="banner-name" name="name"
                       placeholder="VD: Khám Phá Rượu Vang" required>
            </div>

            <div class="form-group">
                <label for="banner-link">LINK ĐÍCH</label>
                <input type="text" id="banner-link" name="targetUrl"
                       placeholder="VD: /store?category=..." required>
            </div>

            <div class="form-grid-3">
                <div class="form-group">
                    <label for="banner-date">NGÀY SỰ KIỆN</label>
                    <input type="date" id="banner-date" name="eventDate" required>
                </div>

                <div class="form-group">
                    <label for="banner-duration">T/G TỒN TẠI (Ngày)</label>
                    <input type="number" id="banner-duration" name="lifeTime" placeholder="VD: 5"
                           min="0" required>
                </div>

                <div class="form-group">
                    <label for="banner-status">TRẠNG THÁI</label>
                    <select id="banner-status" name="status" class="form-control">
                        <option value="Active">Active</option>
                        <option value="Inactive">Inactive</option>
                    </select>
                </div>
            </div>

            <div class="form-group">
                <label for="banner-image">Hình Ảnh Banner</label>
                <input type="file" id="banner-image" name="image" accept="image/*">
            </div>

            <div class="form-actions">
                <button type="button" class="btn btn-secondary cancel-form-btn">Hủy Bỏ</button>
                <button type="submit" class="btn btn-primary" id="ac-form-btn">Lưu Banner</button>
            </div>
        </form>
    </div>
</div>

<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
<script src="https://cdn.datatables.net/2.0.8/js/dataTables.js"></script>

<script>
    document.addEventListener("DOMContentLoaded", function () {
        setupModal('avatar-account-modal', 'avatar-modal-btn', 'close-modal-btn9');
        setupModal('notification-account-modal', 'notification-modal-btn', 'close-modal-btn8');
        setupDynamicModals('add-banner-btn', 'cancel-form-btn');
        setupDynamicModals('btn-open-delete', 'close-delete-btn');
        setupDynamicModals('btn-open-delete', 'cancel-delete-btn');

        if ($.fn.DataTable.isDataTable('#banner-datatable')) {
            $('#banner-datatable').DataTable().destroy();
        }

        var table = $('#banner-datatable').DataTable({
            "columnDefs": [
                {"orderable": false, "targets": [0, 3, 8]}
            ],
            "language": {
                "url": "https://cdn.datatables.net/plug-ins/2.0.8/i18n/vi.json"
            },

            "dom": '<"top"l>rt<"bottom"ip><"clear">'
        });

        // 4. KẾT NỐI THANH TÌM KIẾM CUSTOM
        $('#custom-search-input').on('keyup', function () {
            table.search(this.value).draw();
        });

        // 5. LOGIC MODAL THÊM / SỬA
        const modal = document.getElementById('banner-form-modal');
        const openBtn = document.querySelector('.add-banner-btn');
        const closeBtn = document.getElementById('close-form-btn');
        const cancelBtn = document.querySelector('.cancel-form-btn');

        function toggleModal(show) {
            if (show) modal.classList.add('show');
            else modal.classList.remove('show');
        }

        // Đóng modal
        if (closeBtn) closeBtn.addEventListener('click', () => toggleModal(false));
        if (cancelBtn) cancelBtn.addEventListener('click', () => toggleModal(false));

        // Xử lý nút THÊM MỚI
        if (openBtn) {
            openBtn.addEventListener('click', function () {
                $('#banner-form')[0].reset();
                $('#form-action').val('add');
                $('#banner-form').attr('action', '${pageContext.request.contextPath}/banner-manager/add');
                $('#banner-id').val('');
                $('#banner-old-image').val('');
                $('#banner-image').prop('required', true);

                $('#banner-form-modal h2').text('Thêm Banner Mới');
                $('#ac-form-btn').text('Lưu Banner');

                toggleModal(true);
            });
        }

        $('#banner-datatable').on('click', '.edit-banner-btn', function () {
            let id = $(this).data('id');
            let name = $(this).data('name');
            let url = $(this).data('url');
            let target = $(this).data('target');
            let date = $(this).data('date');
            let life = $(this).data('life');
            let active = $(this).data('active');

            $('#banner-id').val(id);
            $('#banner-name').val(name);
            $('#banner-old-image').val(url);
            $('#banner-image').prop('required', false);
            $('#banner-link').val(target);
            $('#banner-date').val(date);
            $('#banner-duration').val(life);
            $('#banner-status').val(active).change();

            $('#form-action').val('edit');
            $('#banner-form').attr('action', '${pageContext.request.contextPath}/banner-manager/edit');
            $('#banner-form-modal h2').text('Cập Nhật Banner');
            $('#ac-form-btn').text('Lưu Thay Đổi');

            toggleModal(true);
        });

        $('#select-all-checkbox').on('change', function () {
            $('.row-checkbox').prop('checked', this.checked);
        });

        $('.remove-banner-btn').on('click', function () {
            var selectedIds = [];
            $('.row-checkbox:checked').each(function () {
                selectedIds.push($(this).val());
            });

            if (selectedIds.length === 0) {
                alert("Vui lòng chọn ít nhất một banner!");
                return;
            }

            if (confirm("Bạn muốn xóa " + selectedIds.length + " banner đã chọn?")) {
                var idsStr = selectedIds.join(',');
                $.post('${pageContext.request.contextPath}/banner-manager/delete-list', {action: 'delete-list', ids: idsStr})
                    .done(function () {
                        alert("Đã xóa thành công!");
                        location.reload();
                    })
                    .fail(function (err) {
                        console.error(err);
                        alert("Có lỗi xảy ra khi xóa!");
                    });
            }
        });
    });
</script>
</body>

</html>