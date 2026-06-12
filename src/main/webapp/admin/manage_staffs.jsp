<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Quản Lý Nhân Sự</title>
    <script type="module" src="https://unpkg.com/ionicons@7.1.0/dist/ionicons/ionicons.esm.js"></script>
    <script nomodule src="https://unpkg.com/ionicons@7.1.0/dist/ionicons/ionicons.js"></script>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/admin/admin_css/manage_staff.css">
    <link rel="stylesheet" href="https://cdn.datatables.net/2.0.8/css/dataTables.dataTables.css"/>
</head>

<body>
<div class="dashboard-container">
    <nav class="dashboard-sidebar">
        <ul class="sidebar-items">
            <div class="group-avatar">
                <img src="<%= request.getContextPath() %>/assets/avatar.jpg" class="user-avatar"/>
                <ion-icon name="notifications-outline" class="icon-header"></ion-icon>
            </div>
            <c:set var="activePage" value="staff" scope="request"/>
            <jsp:include page="/admin/components/sidebar_items_component.jsp"/>
        </ul>
        <div class="text">━ Được update tới 2025 ━</div>
    </nav>

    <div class="dashboard-content">
        <main class="dashboard-main-content">
            <div class="main-header">
                <h1>Quản Lý Nhân Sự</h1>
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
                        <th style="width: 1%;" class="col-tick"><input type="checkbox" id="select-all-checkbox"></th>
                        <th style="width: 2%;">ID</th>
                        <th style="width: 15%;">Họ và tên</th>
                        <th style="width: 27%;">Email Tài Khoản</th>
                        <th style="width: 30%;">Chức Danh (Role)</th>
                        <th style="width: 25%;" class="col-action">Hành động quyền lực</th>
                    </tr>
                    </thead>
                    <tbody>
                    <c:forEach items="${listAccountStaffs}" var="staff">
                        <tr>
                            <td class="cell-tick"><input type="checkbox" class="row-checkbox" value="${staff.id}"></td>
                            <td style="text-align: center; font-weight: 600; color: var(--text-muted);">${staff.id}</td>
                            <td style="font-weight: 600; color: var(--text-main);">${staff.fullName}</td>
                            <td style="font-weight: 600; color: var(--text-main);">${staff.email}</td>

                            <td style="display: flex; flex-direction: column; gap: 6px; align-items: flex-start; border-bottom: none;">
                                <c:forEach var="singleRole" items="${fn:split(staff.description, ',')}">
                                    <c:choose>
                                        <c:when test="${singleRole == 'Quản trị viên'}">
                                            <span class="role-badge badge-admin">Quản Trị Viên</span>
                                        </c:when>
                                        <c:when test="${singleRole == 'Quản lí sản phẩm'}">
                                            <span class="role-badge badge-sales">Quản Lí Sản Phẩm</span>
                                        </c:when>
                                        <c:when test="${singleRole == 'Quản lí tài khoản'}">
                                            <span class="role-badge badge-admin" style="background-color: #e0f2fe; color: #0369a1; border-color: #bae6fd;">Quản Lí Tài Khoản</span>
                                        </c:when>
                                        <c:when test="${singleRole == 'Quản lí đơn hàng'}">
                                            <span class="role-badge badge-orders">Quản Lí Đơn Hàng</span>
                                        </c:when>
                                        <c:when test="${singleRole == 'Quản lí blog và tin tức'}">
                                            <span class="role-badge badge-default" style="background-color: #f3e8ff; color: #6b21a8; border-color: #e9d5ff;">Quản Lí Blog</span>
                                        </c:when>
                                        <c:when test="${singleRole == 'Quản lí đánh giá'}">
                                            <span class="role-badge badge-default" style="background-color: #ffedd5; color: #9a3412; border-color: #fed7aa;">Quản Lí Đánh Giá</span>
                                        </c:when>
                                        <c:when test="${singleRole == 'Quản lí kho hàng'}">
                                            <span class="role-badge badge-warehouse">Quản Lí Kho Hàng</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="role-badge badge-default">${singleRole}</span>
                                        </c:otherwise>
                                    </c:choose>
                                </c:forEach>
                            </td>
                            <td>
                                <div class="cell-action">
                                    <c:if test="${staff.description != 'Quản trị viên'}">
                                    <button type="button" class="edit btn edit-staff-button"
                                            data-id="${staff.id}"
                                            data-email="${staff.email}"
                                            data-roles="${staff.description}"> Đổi Chức Vụ
                                    </button>
                                    <button type="button" class="delete btn delete-button"
                                            onclick="revokeStaffRole(${staff.id}, '${staff.email}')">
                                        Cách Chức
                                    </button>
                                    </c:if>
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
    <div class="modal-content-form" style="max-width: 550px;">
        <button class="modal-close-form" id="close-form-btn">
            <ion-icon name="close-outline"></ion-icon>
        </button>
        <h2>Bổ Nhiệm Nhân Sự Mới</h2>

        <c:if test="${not empty sessionScope.userIsNotExist}">
            <div style="background-color: #fee2e2; color: #991b1b; border: 1px solid #fecaca; padding: 10px 12px; border-radius: 6px; margin-bottom: 16px; font-size: 14px; font-weight: 600;">
                ⚠ ${sessionScope.userIsNotExist}
            </div>
            <c:remove var="userIsNotExist" scope="session" />
        </c:if>

        <form id="staff-action-form" action="staffs-manager" method="POST">
            <input type="hidden" id="form-action" name="action" value="add">
            <input type="hidden" id="staff-user-id" name="userId" value="">
            <div class="form-group" id="email-input-group">
                <label for="staff-email">Email nhân viên cần bổ nhiệm</label>
                <input type="email" id="staff-email" name="email" placeholder="Ví dụ: nhanvien@gmail.com" required>
            </div>

            <div class="form-group">
                <label style="display: block; margin-bottom: 12px; font-weight: 700; color: var(--text-main);">
                    Chức danh / Bộ phận đảm nhiệm (Có thể chọn nhiều)
                </label>
                <div class="roles-checkbox-container" style="display: flex; flex-direction: column; gap: 12px; background: var(--bg-body); padding: 16px; border-radius: var(--radius-md); border: 1px solid var(--border);">
                    <c:forEach items="${allRoles}" var="role">
                        <c:if test="${role.roleName != 'ADMIN'}">
                            <label class="role-checkbox-label" style="display: flex; align-items: center; gap: 10px; cursor: pointer; font-weight: 600; color: var(--text-main); font-size: 14px; user-select: none;">
                                <input type="checkbox" name="roleIds" value="${role.id}" class="role-checkbox-item" data-desc="${role.description}" style="width: 18px; height: 18px; cursor: pointer; accent-color: var(--primary);">
                                    ${role.description} <span style="color: var(--text-muted); font-weight: 500; font-size: 12px;">(${role.roleName})</span>
                            </label>
                        </c:if>
                    </c:forEach>
                </div>
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
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

<script>
    document.addEventListener("DOMContentLoaded", function () {
        const modal = document.getElementById('modal-staff-form');
        const urlParams = new URLSearchParams(window.location.search);

        if (urlParams.has('invalidData')) {
            if (modal) modal.classList.add('show');
        }

        var table = $('#staff-datatable').DataTable({
            "paging": true,
            "pageLength": 10,
            "language": { "url": 'https://cdn.datatables.net/plug-ins/2.0.8/i18n/vi.json' },
            "columnDefs": [
                {"orderable": false, "targets": [0, 4]},
                {"searchable": false, "targets": [0, 4]}
            ],
            "dom": '<"top"l>rt<"bottom"ip><"clear">'
        });

        $('#custom-search-input').on('keyup', function () {
            table.search(this.value).draw();
        });

        // model thêm mới
        $('.add-staff-btn').on('click', function () {
            $('#staff-action-form')[0].reset();
            $('#form-action').val('add');
            $('#staff-user-id').val('');
            $('.role-checkbox-item').prop('checked', false);

            $('#staff-email').prop('readonly', false);
            $('#email-input-group').show();
            $('.modal-content-form h2').text('Bổ Nhiệm Nhân Sự Mới');
            modal.classList.add('show');
        });

        // model chức vụ
        $('#staff-datatable').on('click', '.edit-staff-button', function () {
            let userId = $(this).data('id');
            let email = $(this).data('email');
            let currentRolesText = $(this).attr('data-roles') || "";

            $('#form-action').val('edit');
            $('#staff-user-id').val(userId);
            $('#staff-email').val(email).prop('readonly', true);
            $('#email-input-group').show();
            $('.modal-content-form h2').text('Thay Đổi Chức Vụ Nhân Sự');

            // Quét và tự động đánh dấu các quyền đang có
            $('.role-checkbox-item').each(function() {
                let roleDesc = $(this).attr('data-desc');
                if (currentRolesText.includes(roleDesc)) {
                    $(this).prop('checked', true);
                } else {
                    $(this).prop('checked', false);
                }
            });
            modal.classList.add('show');
        });

        $('.modal-close-form, .cancel-form-btn').on('click', function() {
            modal.classList.remove('show');
        });
    });

    // hàm cách chức
    function revokeStaffRole(userId, email) {
        Swal.fire({
            title: 'Xác nhận cách chức',
            text: 'Bạn có chắc chắn muốn CÁCH CHỨC tài khoản [' + email + '] không? Họ sẽ mất toàn bộ quyền truy cập vùng quản trị.',
            icon: 'warning',
            showCancelButton: true,
            confirmButtonColor: '#d33',
            cancelButtonColor: '#6c757d',
            confirmButtonText: 'Cách chức ngay',
            cancelButtonText: 'Hủy bỏ'
        }).then((result) => {
            if (result.isConfirmed) {
                Swal.fire({
                    title: 'Đang xử lý...',
                    allowOutsideClick: false,
                    didOpen: () => { Swal.showLoading(); }
                });

                const form = document.createElement('form');
                form.method = 'POST';
                form.action = 'staffs-manager';

                const params = { action: 'delete', userId: userId };
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
        });
    }
</script>
</body>
</html>