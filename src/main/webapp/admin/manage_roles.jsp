<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Quản Lý Vai Trò & Quyền Hạn</title>
    <script type="module" src="https://unpkg.com/ionicons@7.1.0/dist/ionicons/ionicons.esm.js"></script>
    <script nomodule src="https://unpkg.com/ionicons@7.1.0/dist/ionicons/ionicons.js"></script>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/admin/admin_css/manage_product_style.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/admin/admin_css/manage_staff.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/admin/admin_css/manage_roles.css">
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
            <c:set var="activePage" value="role" scope="request"/>
            <jsp:include page="/admin/components/sidebar_items_component.jsp"/>
        </ul>
        <div class="text">━ Được update tới 2025 ━</div>
    </nav>

    <div class="dashboard-content">
        <main class="dashboard-main-content">
            <div class="main-header">
                <h1>Quản Lý Vai Trò & Quyền Hạn</h1>
                <div class="header-actions">
                    <button class="btn btn-primary add-role-btn">
                        <ion-icon name="add-outline"></ion-icon>
                        Tạo Vai Trò Mới
                    </button>
                </div>
            </div>

            <div class="filter-bar" style="justify-content: flex-end; padding: 10px 0; background: transparent; border: none; box-shadow: none;">
                <div class="filter-item" style="max-width: 300px; min-width: 250px;">
                    <input type="text" id="custom-search-input" placeholder="Tìm kiếm vai trò..." class="filter-input">
                </div>
            </div>

            <div class="table-container">
                <table id="role-datatable" class="product-table">
                    <thead>
                    <tr>
                        <th style="width: 5%;" class="col-tick"><input type="checkbox" id="select-all-checkbox"></th>
                        <th style="width: 15%;">Tên Mã (Role Name)</th>
                        <th style="width: 20%;">Tên Hiển Thị (Mô tả)</th>
                        <th style="width: 40%;">Các Thẻ Quyền Sở Hữu</th>
                        <th style="width: 20%;" class="col-action">Hành động quyền lực</th>
                    </tr>
                    </thead>
                    <tbody>
                    <c:forEach items="${listRolesWithPerms}" var="item">
                        <tr>
                            <td class="cell-tick"><input type="checkbox" class="row-checkbox" value="${item.role_id}"></td>
                            <td style="font-weight: 700; color: var(--primary);">${item.role_name}</td>
                            <td style="font-weight: 600; color: var(--text-main);">${item.role_desc}</td>
                            <td>
                                <div class="permissions-container">
                                    <c:choose>
                                        <c:when test="${not empty item.permission_keys}">
                                            <c:forEach var="key" items="${fn:split(item.permission_keys, ',')}">
                                                <span class="role-badge badge-default" style="text-transform: none; font-family: monospace; min-width: auto; padding: 4px 10px;">${key}</span>
                                            </c:forEach>
                                        </c:when>
                                        <c:otherwise>
                                            <span style="color: var(--text-muted); font-size: 13px; font-style: italic;">Chưa cấu hình quyền</span>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </td>
                            <td>
                                <div class="cell-action">
                                    <c:if test="${item.role_name != 'ADMIN'}">
                                        <button type="button" class="edit btn edit-role-button"
                                                data-id="${item.role_id}"
                                                data-name="${item.role_name}"
                                                data-desc="${item.role_desc}"
                                                data-keys="${item.permission_keys}">
                                            Sửa Quyền
                                        </button>
                                        <button type="button" class="delete btn delete-button" onclick="deleteSystemRole(${item.role_id}, '${item.role_name}')">
                                            Xóa Bỏ
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

<div class="modal-overlay-form" id="modal-role-form">
    <div class="modal-content-form" style="max-width: 600px;">
        <button class="modal-close-form" id="close-form-btn">
            <ion-icon name="close-outline"></ion-icon>
        </button>
        <h2>Cấu Hình Quyền Cho Vai Trò</h2>

        <form id="role-action-form" action="roles-manager" method="POST">
            <input type="hidden" id="form-action" name="action" value="edit">
            <input type="hidden" id="role-id" name="roleId" value="">

            <div class="form-group" id="role-name-group">
                <label for="role-name-input">Mã Vai Trò (ROLE_NAME)</label>
                <input type="text" id="role-name-input" name="roleName" placeholder="Ví dụ: MOD_MARKETING" required>
            </div>

            <div class="form-group" id="role-desc-group">
                <label for="role-desc-input">Tên hiển thị (Mô tả chức danh)</label>
                <input type="text" id="role-desc-input" name="description" placeholder="Ví dụ: Quản lí tin tức khuyến mãi" required>
            </div>

            <div class="form-group" id="permissions-checkbox-group">
                <label style="display: block; margin-bottom: 12px; font-weight: 700; color: var(--text-main);">
                    Hệ thống Thẻ Quyền Hạn (Cấp phát chi tiết)
                </label>
                <div style="display: flex; flex-direction: column; gap: 12px; background: var(--bg-body); padding: 16px; border-radius: var(--radius-md); border: 1px solid var(--border); max-height: 280px; overflow-y: auto;">
                    <c:forEach items="${allPermissions}" var="perm">
                        <label style="display: flex; align-items: center; gap: 10px; cursor: pointer; font-weight: 600; color: var(--text-main); font-size: 14px; user-select: none;">
                            <input type="checkbox" name="permissionIds" value="${perm.id}" class="perm-checkbox-item" data-key="${perm.permissionKey}" style="width: 18px; height: 18px; cursor: pointer; accent-color: var(--primary);">
                                ${perm.description} <span style="color: var(--text-muted); font-weight: 500; font-size: 12px; font-family: monospace;">(${perm.permissionKey})</span>
                        </label>
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
        const modal = document.getElementById('modal-role-form');

        var table = $('#role-datatable').DataTable({
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

        $('.add-role-btn').on('click', function () {
            $('#role-action-form')[0].reset();
            $('#form-action').val('add');
            $('#role-id').val('');

            $('#role-name-input').prop('readonly', false);
            $('#role-desc-input').prop('readonly', false);
            $('#role-name-group, #role-desc-group').show();
            $('#permissions-checkbox-group').hide();

            $('.modal-content-form h2').text('Tạo Mới Vai Trò Gốc');
            modal.classList.add('show');
            $('#role-action-form').attr('action', 'roles-manager/add');
        });

        $('#role-datatable').on('click', '.edit-role-button', function () {
            let roleId = $(this).data('id');
            let roleName = $(this).data('name');
            let roleDesc = $(this).data('desc');
            let currentKeys = String($(this).attr('data-keys') || "");

            $('#form-action').val('edit');
            $('#role-id').val(roleId);

            $('#role-name-input').val(roleName).prop('readonly', true);
            $('#role-desc-input').val(roleDesc).prop('readonly', true);
            $('#permissions-checkbox-group').show();

            // Cắt chuỗi mã quyền thành một mảng để đối chiếu chính xác tuyệt đối
            let keysArray = currentKeys.split(',');
            $('.perm-checkbox-item').each(function() {
                let permKey = $(this).data('key'); // Lấy mã key ví dụ: "product:read"
                $(this).prop('checked', keysArray.includes(permKey));
            });

            $('.modal-content-form h2').text('Cấu Hình Quyền Cho Vai Trò');
            modal.classList.add('show');
            $('#role-action-form').attr('action', 'roles-manager/edit');
        });

        $('.modal-close-form, .cancel-form-btn').on('click', function() {
            modal.classList.remove('show');
        });
    });

    function deleteSystemRole(roleId, roleName) {
        Swal.fire({
            title: 'Cảnh báo nguy hiểm!',
            text: 'XÓA HOÀN TOÀN vai trò [' + roleName + ']? Tất cả nhân viên đang giữ chức này sẽ tự động mất quyền liên quan!',
            icon: 'warning',
            showCancelButton: true,
            confirmButtonColor: '#d33',
            cancelButtonColor: '#6c757d',
            confirmButtonText: 'Đồng ý Xóa',
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
                form.action = 'roles-manager/delete';

                const params = { action: 'delete', roleId: roleId };
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