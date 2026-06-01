<%--
  Created by IntelliJ IDEA.
  User: Admin
  Date: 6/1/2026
  Time: 10:01 PM
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="vi">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Quản Lý Nhân Sự</title>
    <script type="module" src="https://unpkg.com/ionicons@7.1.0/dist/ionicons/ionicons.esm.js"></script>
    <script nomodule src="https://unpkg.com/ionicons@7.1.0/dist/ionicons/ionicons.js"></script>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/admin/admin_css/manage_product_style.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/admin/admin_css/manage_staff.css">
    <link rel="stylesheet" href="https://cdn.datatables.net/2.0.8/css/dataTables.dataTables.css"/>
</head>

<body>
<div class="dashboard-container">
    <nav class="dashboard-sidebar">
        <ul class="sidebar-items">
            <div class="group-avatar">
                <img src="<%= request.getContextPath() %>/assets/avatar.jpg" class="user-avatar" id="avatar-modal-btn"/>
                <ion-icon name="notifications-outline" class="icon-header" id="notification-modal-btn"></ion-icon>
            </div>

            <c:set var="activePage" value="staff" scope="request"/>
            <jsp:include page="/admin/components/sidebar_items_component.jsp"/>
        </ul>
        <div class="text">━ Được update tới 2025 ━</div>
    </nav>

    <div class="dashboard-content">
        <main class="dashboard-main-content">
            <div class="main-header">
                <h1>Quản Lý Nhân Sự (Moderators)</h1>
                <div class="header-actions">
                    <button class="btn btn-primary add-staff-btn">
                        <ion-icon name="add-outline"></ion-icon>
                        Thêm Nhân Sự Mới
                    </button>
                </div>
            </div>

            <div class="filter-bar" style="justify-content: flex-end; padding: 10px 0; background: transparent; border: none; box-shadow: none;">
                <div class="filter-item" style="max-width: 300px; min-width: 250px;">
                    <input type="text" id="custom-search-input" placeholder="Tìm kiếm email, chức danh..." class="filter-input">
                </div>
            </div>

            <div class="table-container">
                <table id="staff-datatable" class="product-table">
                    <thead>
                    <tr class="sample">
                        <th style="width: 5%;" class="col-tick"><input type="checkbox" id="select-all-checkbox"></th>
                        <th style="width: 10%;">ID Nhân Sự</th>
                        <th style="width: 35%;">Email Tài Khoản</th>
                        <th style="width: 25%;">Chức Danh (Role)</th>
                        <th style="width: 25%;" class="col-action">Hành động quyền lực</th>
                    </tr>
                    </thead>
                    <tbody>
                    <c:forEach items="${listAccountStaffs}" var="staff">
                        <tr>
                            <td class="cell-tick"><input type="checkbox" class="row-checkbox" value="${staff.id}"></td>
                            <td style="text-align: center; font-weight: 600; color: var(--text-muted);">${staff.id}</td>
                            <td style="font-weight: 600; color: var(--text-main);">${staff.email}</td>
                            <td>
                                <c:choose>
                                    <c:when test="${staff.description == 'Quản trị viên'}">
                                        <span class="role-badge badge-admin">Quản Trị Viên</span>
                                    </c:when>
                                    <c:when test="${staff.description == 'Quản lí sản phẩm'}">
                                        <span class="role-badge badge-sales">Quản Lý Sản Phẩm</span>
                                    </c:when>
                                    <c:when test="${staff.description == 'Quản lí tài khoản'}">
                                        <span class="role-badge badge-admin" style="background-color: #e0f2fe; color: #0369a1; border-color: #bae6fd;">Quản Lý Tài Khoản</span>
                                    </c:when>
                                    <c:when test="${staff.description == 'Quản lí đơn hàng'}">
                                        <span class="role-badge badge-orders">Quản Lý Đơn Hàng</span>
                                    </c:when>
                                    <c:when test="${staff.description == 'Quản lí blog và tin tức'}">
                                        <span class="role-badge badge-default" style="background-color: #f3e8ff; color: #6b21a8; border-color: #e9d5ff;">Quản Lý Blog</span>
                                    </c:when>
                                    <c:when test="${staff.description == 'Quản lí đánh giá'}">
                                        <span class="role-badge badge-default" style="background-color: #ffedd5; color: #9a3412; border-color: #fed7aa;">Quản Lý Đánh Giá</span>
                                    </c:when>
                                    <c:when test="${staff.description == 'Quản lí kho hàng'}">
                                        <span class="role-badge badge-warehouse">Quản Lý Kho Hàng</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="role-badge badge-default">${staff.description}</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td>
                                <div class="cell-action">
                                    <button type="button" class="edit btn edit-staff-button"
                                            data-id="${staff.id}"
                                            data-email="${staff.email}"
                                            data-roleid="${staff.roleId}">
                                        Đổi Chức Vụ
                                    </button>
                                    <button type="button" class="delete btn delete-button"
                                            onclick="revokeStaffRole(${staff.id}, ${staff.roleId}, '${staff.email}')">
                                        Cách Chức
                                    </button>
                                </div>
                            </td>
                        </tr>
                    </c:forEach>
                    </tbody>
                </table>
            </div>
        </main>
    </div>
</div>

<div class="modal-overlay-form" id="modal-staff-form">
    <div class="modal-content-form" style="max-width: 500px;">
        <button class="modal-close-form" id="close-form-btn">
            <ion-icon name="close-outline"></ion-icon>
        </button>
        <h2>Bổ Nhiệm Nhân Sự Mới</h2>

        <form id="staff-action-form" action="staff-manager" method="POST">
            <input type="hidden" id="form-action" name="action" value="add">
            <input type="hidden" id="staff-user-id" name="userId" value="">
            <input type="hidden" id="old-role-id" name="oldRoleId" value="">

            <div class="form-group" id="email-input-group">
                <label for="staff-email">Email nhân viên cần bổ nhiệm</label>
                <input type="email" id="staff-email" name="email" placeholder="Ví dụ: nhanvien@gmail.com" required>
            </div>

            <div class="form-group">
                <label for="staff-role">Chức danh / Bộ phận đảm nhiệm</label>
                <select id="staff-role" name="roleId" required>
                    <option value="">-- Chọn một chức vụ đảm nhiệm --</option>
                    <c:forEach items="${allRoles}" var="role">
                        <c:if test="${role.roleName != 'ADMIN'}">
                            <option value="${role.id}">${role.description} (${role.roleName})</option>
                        </c:if>
                    </c:forEach>
                </select>
            </div>

            <div class="form-actions">
                <button type="button" class="btn btn-secondary cancel-form-btn">Hủy Bỏ</button>
                <button type="submit" class="btn btn-primary">Xác Nhận Lưu</button>
            </div>
        </form>
    </div>
</div>

<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
<script src="https://cdn.datatables.net/2.0.8/js/dataTables.js"></script>

<script>
    document.addEventListener("DOMContentLoaded", function () {
        const modal = document.getElementById('modal-staff-form');

        var table = $('#staff-datatable').DataTable({
            "paging": true,
            "pageLength": 10,
            "language": {
                "url": 'https://cdn.datatables.net/plug-ins/2.0.8/i18n/vi.json'
            },
            "columnDefs": [
                {"orderable": false, "targets": [0, 4]},
                {"searchable": false, "targets": [0, 4]}
            ],
            "dom": '<"top"l>rt<"bottom"ip><"clear">'
        });

        $('#custom-search-input').on('keyup', function () {
            table.search(this.value).draw();
        });

        $('.add-product-btn, .add-staff-btn').on('click', function () {
            $('#staff-action-form')[0].reset();
            $('#form-action').val('add');
            $('#staff-user-id').val('');
            $('#old-role-id').val('');
            $('#staff-email').prop('readonly', false);
            $('#email-input-group').show();
            $('.modal-content-form h2').text('Bổ Nhiệm Nhân Sự Mới');
            modal.classList.add('show');
        });

        $('#staff-datatable').on('click', '.edit-staff-button', function () {
            let userId = $(this).data('id');
            let email = $(this).data('email');
            let roleId = $(this).data('roleid');
            $('#form-action').val('edit');
            $('#staff-user-id').val(userId);
            $('#old-role-id').val(roleId);
            $('#staff-email').val(email).prop('readonly', true);
            $('#staff-role').val(roleId);
            $('.modal-content-form h2').text('Thay Đổi Chức Vụ Nhân Sự');
            modal.classList.add('show');
        });

        $('.modal-close-form, .cancel-form-btn').on('click', function() {
            modal.classList.remove('show');
        });
    });

    function revokeStaffRole(userId, roleId, email) {
        if (confirm("Bạn có chắc chắn muốn CÁCH CHỨC tài khoản [" + email + "] không? Họ sẽ mất toàn bộ quyền truy cập vùng quản trị.")) {
            const form = document.createElement('form');
            form.method = 'POST';
            form.action = 'staff-manager';

            const params = { action: 'delete', userId: userId, oldRoleId: roleId };
            for (const key in params) {
                if (params.hasOwnProperty(key)) {
                    const hiddenField = document.createElement('input');
                    hiddenField.type = 'hidden';
                    hiddenField.name = key;
                    hiddenField.value = params[key];
                    form.appendChild(hiddenField);
                }
            }
            document.body.appendChild(form);
            form.submit();
        }
    }
</script>
</body>
</html>
