<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="vi">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Quản Lí Sản Phẩm</title>
    <script src="<%= request.getContextPath() %>/popup.js"></script>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/admin/admin_css/manage_product_style.css">
    <script type="module" src="https://unpkg.com/ionicons@7.1.0/dist/ionicons/ionicons.esm.js"></script>
    <script nomodule src="https://unpkg.com/ionicons@7.1.0/dist/ionicons/ionicons.js"></script>
    <style>
        .error-msg {
            color: #e74c3c;
            font-size: 0.85rem;
            margin-top: 4px;
            display: block;
            font-weight: 500;
        }
        .invalid-field {
            border-color: #e74c3c !important;
            background-color: #fdf2f2 !important;
        }
        .toast-notification {
            position: fixed;
            top: 20px;
            right: 20px;
            background-color: #e74c3c;
            color: white;
            padding: 12px 24px;
            border-radius: 6px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.15);
            z-index: 10000;
            display: flex;
            align-items: center;
            gap: 8px;
            font-weight: 500;
            transform: translateY(-20px);
            opacity: 0;
            transition: all 0.3s ease;
        }
        .toast-notification.show {
            transform: translateY(0);
            opacity: 1;
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
            <c:set var="activePage" value="product" scope="request"/>
            <%@ include file="/admin/components/sidebar_items_component.jsp" %>
        </ul>
    </nav>

    <div class="dashboard-content">
        <main class="dashboard-main-content">
            <div class="main-header">
                <h1>Quản Lí Sản Phẩm</h1>
                <div class="header-actions">
                    <button class="btn btn-danger remove-product-btn" data-require-perm="product:delete">
                        <ion-icon name="trash-outline"></ion-icon> Xóa (Đã chọn)
                    </button>

                    <form id="form-import-excel" action="<%= request.getContextPath() %>/product-manager/importExcel" method="post" enctype="multipart/form-data" style="display: none;">
                        <input type="file" name="excelFile" id="excelFile" accept=".xlsx, .xls">
                    </form>
                    <button class="btn btn-success" data-require-perm="product:upsert" onclick="document.getElementById('excelFile').click();">
                        <ion-icon name="document-text-outline"></ion-icon> Nhập Excel
                    </button>

                    <button class="btn btn-primary add-product-btn" id="btn-open-add" data-require-perm="product:upsert">
                        <ion-icon name="add-circle-outline"></ion-icon> Thêm Sản Phẩm
                    </button>
                </div>
            </div>

            <div class="filter-bar">
                <div class="filter-item">
                    <label>Nhà sản xuất</label>
                    <select id="filter-manufacturer" class="filter-input">
                        <option value="">-- Tất cả --</option>
                        <c:forEach items="${manufacturers}" var="m">
                            <option value="${m.manufacturerName}">${m.manufacturerName}</option>
                        </c:forEach>
                    </select>
                </div>

                <div class="filter-item">
                    <label>Giá từ</label>
                    <input type="number" id="min-price" class="filter-input" placeholder="0">
                </div>
                <div class="filter-item">
                    <label>Đến</label>
                    <input type="number" id="max-price" class="filter-input" placeholder="Tối đa">
                </div>

                <div class="filter-item">
                    <label>Tìm kiếm chung</label>
                    <input type="text" id="custom-search-input" class="filter-input" placeholder="Tên SP, Mã...">
                </div>

                <button type="button" class="btn-reset" id="btn-reset-filter">
                    Làm Mới Bộ Lọc
                </button>
            </div>

            <div class="table-container">
                <div class="table-scroll-wrapper">
                    <table id="product-datatable" class="product-table">
                        <thead>
                        <tr>
                            <th style="width: 5%;"><input type="checkbox" id="select-all-checkbox"></th>
                            <th style="width: 35%;">Sản phẩm</th>
                            <th style="width: 15%;">Mã SP</th>
                            <th style="width: 15%;">Nhà SX</th>
                            <th style="width: 10%;">Giá</th>
                            <th style="width: 10%;">Tồn Kho</th>
                            <th style="width: 10%;">Hành động</th>
                        </tr>
                        </thead>
                        <tbody>
                        <c:forEach items="${products}" var="p">
                            <tr>
                                <td><input type="checkbox" class="row-checkbox" value="${p.id}"></td>
                                <td>
                                    <div class="product-cell">
                                        <img src="${empty p.imageUrl ? 'assets/no-image.png' : pageContext.request.contextPath.concat('/').concat(p.imageUrl)}"
                                             alt="Img" onerror="this.src='<%= request.getContextPath() %>/assets/no-image.png'">
                                        <span>${p.productName}</span>
                                    </div>
                                </td>
                                <td>${p.id}</td>
                                <td>${p.manufacturerId}</td>
                                <td>
                                    <fmt:setLocale value="vi_VN"/>
                                    <fmt:formatNumber value="${p.price}" type="currency" currencySymbol="VND" maxFractionDigits="0"/>
                                </td>
                                <td>
                            <span class="stock-status ${p.quantity > 0 ? 'in-stock' : 'out-of-stock'}">
                                    ${p.quantity > 0 ? p.quantity : 'Hết hàng'}
                            </span>
                                </td>
                                <td>
                                    <div class="cell-action">
                                        <button type="button" class="btn btn-secondary edit-product-btn" data-require-perm="product:upsert"
                                                data-id="${p.id}" data-name="${p.productName}"
                                                data-type-text="${p.typeId}" data-cat-text="${p.categoryId}"
                                                data-manu-text="${p.manufacturerId}"
                                                data-origin="${p.origin}" data-price="${p.price}"
                                                data-stock="${p.quantity}" data-capacity="${p.capacity}"
                                                data-alcohol="${p.alcohol}" data-detail="${p.detail}"
                                                data-img="${p.imageUrl}">
                                            Sửa
                                        </button>

                                        <form action="product-manager/delete" method="POST" style="margin:0;">
                                            <input type="hidden" name="action" value="delete">
                                            <input type="hidden" name="id" value="${p.id}">
                                            <button type="submit" data-require-perm="product:delete" class="btn btn-danger" onclick="return confirm('Xóa sản phẩm này?');">Xoá</button>
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

<div class="modal-overlay-form product-form-modal" id="modal-san-pham">
    <div class="modal-content-form">
        <button class="modal-close-form" id="close-form-btn">X</button>
        <h2>Thêm Sản Phẩm Mới</h2>

        <form id="add-product-form" action="product-manager" method="POST" enctype="multipart/form-data">
            <input type="hidden" id="form-action" name="action" value="add">
            <input type="hidden" id="prod-id" name="id" value="">
            <input type="hidden" id="prod-old-image" name="oldImage" value="">

            <div class="form-group">
                <label>Tên sản phẩm</label>
                <input type="text" id="p-name" name="name" required placeholder="Nhập tên sản phẩm...">
            </div>

            <div class="form-grid">
                <div class="form-group">
                    <label>Loại rượu</label>
                    <select id="p-type" name="type" required>
                        <option value="">-- Chọn loại --</option>
                        <c:forEach items="${types}" var="t">
                            <option value="${t.id}">${t.typeName}</option>
                        </c:forEach>
                    </select>
                </div>
                <div class="form-group">
                    <label>Danh mục</label>
                    <select id="p-category" name="category" required>
                        <option value="">-- Chọn danh mục --</option>
                        <c:forEach items="${categories}" var="c">
                            <option value="${c.id}">${c.categoryName}</option>
                        </c:forEach>
                    </select>
                </div>
            </div>

            <div class="form-grid">
                <div class="form-group">
                    <label>Nhà sản xuất</label>
                    <select id="p-manufacturer" name="manufacturer" required>
                        <option value="">-- Chọn NSX --</option>
                        <c:forEach items="${manufacturers}" var="m">
                            <option value="${m.id}">${m.manufacturerName}</option>
                        </c:forEach>
                    </select>
                </div>
                <div class="form-group">
                    <label>Xuất xứ</label>
                    <input type="text" id="p-origin" name="origin" placeholder="VD: Pháp">
                </div>
            </div>

            <div class="form-grid">
                <div class="form-group">
                    <label>Giá bán</label>
                    <input type="number" id="p-price" name="price" required>
                </div>
                <div class="form-group">
                    <label>Số lượng tồn</label>
                    <input type="number" id="p-stock" name="stock" value="10" required>
                </div>
            </div>

            <div class="form-grid">
                <div class="form-group">
                    <label>Dung tích</label>
                    <input type="text" id="p-capacity" name="capacity" placeholder="VD: 750ml">
                </div>
                <div class="form-group">
                    <label>Nồng độ (%)</label>
                    <input type="text" id="p-alcohol" name="alcohol" placeholder="VD: 14.5">
                </div>
            </div>

            <div class="form-group">
                <label>Hình ảnh</label>
                <input type="file" id="p-image" name="image" accept="image/*" style="padding: 8px;">
            </div>

            <div class="form-group">
                <label>Mô tả chi tiết</label>
                <textarea id="p-detail" name="detail" rows="4"></textarea>
            </div>

            <div class="form-actions">
                <button type="button" class="btn btn-secondary" id="cancel-form-btn">Hủy Bỏ</button>
                <button type="submit" class="btn btn-primary" id="btn-submit-form">Lưu Sản Phẩm</button>
            </div>
        </form>
    </div>
</div>

<!-- Modal Báo Lỗi Tùy Chọn (Không Dùng Alert) -->
<div class="modal-overlay-form product-form-modal" id="modal-error-popup">
    <div class="modal-content-form" style="max-width: 450px; text-align: center; padding: 30px;">
        <div style="font-size: 50px; color: #e74c3c; margin-bottom: 15px;">
            <ion-icon name="alert-circle-outline"></ion-icon>
        </div>
        <h2 style="color: #e74c3c; margin-bottom: 10px;">Lỗi Định Dạng!</h2>
        <p id="error-popup-message" style="font-size: 1rem; color: #555; margin-bottom: 20px; line-height: 1.5;"></p>
        <button type="button" class="btn btn-danger" id="btn-close-error" style="padding: 10px 24px; min-width: 120px;">Đóng</button>
    </div>
</div>

<!-- Modal Xác Nhận Nhập Kho Excel -->
<div class="modal-overlay-form product-form-modal" id="modal-confirm-excel">
    <div class="modal-content-form" style="max-width: 850px; width: 90%; padding: 25px;">
        <button class="modal-close-form" id="close-confirm-excel-btn">X</button>
        <h2 style="margin-bottom: 10px;">Xác Nhận Sản Phẩm Nhập Từ Excel</h2>
        <p style="color: #666; margin-bottom: 20px; font-size: 0.95rem;">Dưới đây là danh sách sản phẩm phân tích được từ file Excel. Số lượng tồn kho của các sản phẩm trùng tên sẽ được tự động cộng dồn.</p>
        
        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 15px; margin-bottom: 15px; background-color: #f8f9fa; padding: 12px; border-radius: 6px; border: 1px solid #e9ecef; font-size: 0.95rem;">
            <div><strong>Người Nhập:</strong> ${sessionScope.user.fullName != null ? sessionScope.user.fullName : (sessionScope.user.username != null ? sessionScope.user.username : 'Admin')}</div>
            <div><strong>Ngày Nhập:</strong> <span id="excel-import-date"></span></div>
        </div>
        
        <div class="table-container" style="max-height: 350px; overflow-y: auto; margin-bottom: 25px; border: 1px solid #e1e8ed; border-radius: 6px;">
            <table class="product-table" style="width: 100%; border-collapse: collapse; margin: 0;">
                <thead>
                    <tr style="background-color: #f5f8fa; border-bottom: 2px solid #e1e8ed; position: sticky; top: 0; z-index: 10;">
                        <th style="padding: 12px; text-align: left; width: 45%; font-weight: 600;">Sản phẩm</th>
                        <th style="padding: 12px; text-align: center; width: 25%; font-weight: 600;">Hành động</th>
                        <th style="padding: 12px; text-align: center; width: 15%; font-weight: 600;">Tồn cũ</th>
                        <th style="padding: 12px; text-align: center; width: 15%; font-weight: 600;">Tồn mới</th>
                    </tr>
                </thead>
                <tbody id="excel-preview-body">
                    <!-- Sẽ được render động bằng Javascript -->
                </tbody>
            </table>
        </div>
        
        <div class="form-actions" style="display: flex; justify-content: flex-end; gap: 12px; border-top: 1px solid #e1e8ed; padding-top: 15px; margin-top: 0;">
            <button type="button" class="btn btn-secondary" id="btn-cancel-import" style="padding: 10px 20px;">Hủy Bỏ</button>
            <button type="button" class="btn btn-primary" id="btn-confirm-import" style="background-color: #2ecc71; border-color: #2ecc71; padding: 10px 24px; display: flex; align-items: center; gap: 6px;">
                <ion-icon name="checkmark-circle-outline" style="font-size: 1.2rem;"></ion-icon> Xác Nhận Nhập Kho
            </button>
        </div>
    </div>
</div>

<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
<script src="https://cdn.datatables.net/2.0.8/js/dataTables.js"></script>

<script>
    document.addEventListener("DOMContentLoaded", function () {
        var table = $('#product-datatable').DataTable({
            "paging": true,
            "pageLength": 10,
            "language": {"url": 'https://cdn.datatables.net/plug-ins/2.0.8/i18n/vi.json'},
            "columnDefs": [
                {"orderable": false, "targets": [0, 6]},
                {"searchable": false, "targets": [0, 6]}
            ],
            "dom": '<"top"l>rt<"bottom"ip><"clear">'
        });

        $('#custom-search-input').on('keyup', function () {
            table.search(this.value).draw();
        });

        $('#select-all-checkbox').on('change', function () {
            $('.row-checkbox').prop('checked', this.checked);
        });

        $('.remove-product-btn').on('click', function () {
            var selectedIds = [];
            $('.row-checkbox:checked').each(function () {
                selectedIds.push($(this).val());
            });

            if (selectedIds.length === 0) {
                alert("Vui lòng chọn ít nhất một sản phẩm!");
                return;
            }

            if (confirm("Bạn muốn xóa " + selectedIds.length + " sản phẩm đã chọn?")) {
                var idsStr = selectedIds.join(',');
                $.post('product-manager/delete-list', { action: 'delete-list', ids: idsStr })
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

        const modal = document.getElementById('modal-san-pham');
        const openBtn = document.getElementById('btn-open-add');
        const closeBtn = document.getElementById('close-form-btn');
        const cancelBtn = document.getElementById('cancel-form-btn');

        function toggleModal(show) {
            if (show) modal.classList.add('show'); else modal.classList.remove('show');
        }

        if (closeBtn) closeBtn.addEventListener('click', () => toggleModal(false));
        if (cancelBtn) cancelBtn.addEventListener('click', () => toggleModal(false));

        if (openBtn) openBtn.addEventListener('click', () => {
            $('#add-product-form')[0].reset();
            $('#add-product-form').attr('action', '<%= request.getContextPath() %>/product-manager/add');
            $('#form-action').val('add');
            $('#prod-id').val('');
            $('#prod-old-image').val('');
            $('.modal-content-form h2').text('Thêm Sản Phẩm Mới');
            $('#btn-submit-form').text('Lưu Sản Phẩm');
            toggleModal(true);
        });

        $('#product-datatable').on('click', '.edit-product-btn', function () {
            var btn = $(this);
            $('#add-product-form').attr('action', '<%= request.getContextPath() %>/product-manager/edit');
            $('#prod-id').val(btn.data('id'));
            $('#p-name').val(btn.data('name'));
            $('#p-origin').val(btn.data('origin'));
            $('#p-price').val(btn.data('price'));
            $('#p-stock').val(btn.data('stock'));
            $('#p-capacity').val(btn.data('capacity'));
            $('#p-alcohol').val(btn.data('alcohol'));
            $('#p-detail').val(btn.data('detail'));
            $('#prod-old-image').val(btn.data('img'));

            setSelectedByText('#p-type', btn.data('type-text'));
            setSelectedByText('#p-category', btn.data('cat-text'));
            setSelectedByText('#p-manufacturer', btn.data('manu-text'));

            $('#form-action').val('edit');
            $('.modal-content-form h2').text('Cập Nhật Sản Phẩm');
            $('#btn-submit-form').text('Lưu Thay Đổi');
            toggleModal(true);
        });

        function setSelectedByText(selectId, textToFind) {
            if (!textToFind) {
                $(selectId).val('');
                return;
            }
            var found = false;
            var cleanTextToFind = String(textToFind).trim().toLowerCase();
            $(selectId + ' option').each(function () {
                var optionText = $(this).text().trim().toLowerCase();
                var optionValue = $(this).val().trim().toLowerCase();
                if (optionText === cleanTextToFind || optionValue === cleanTextToFind) {
                    $(this).prop('selected', true);
                    found = true;
                    return false;
                }
            });
            if (!found) {
                $(selectId).val('');
            }
        }

        $.fn.dataTable.ext.search.push(
            function (settings, data, dataIndex) {
                var min = parseInt($('#min-price').val(), 10);
                var max = parseInt($('#max-price').val(), 10);
                var priceStr = data[4] || "0";
                var price = parseFloat(priceStr.replace(/[^0-9]/g, ''));

                if ((isNaN(min) && isNaN(max)) ||
                    (isNaN(min) && price <= max) ||
                    (min <= price && isNaN(max)) ||
                    (min <= price && price <= max)) {
                    return true;
                }
                return false;
            }
        );

        $('#min-price, #max-price').on('keyup change', function () {
            table.draw();
        });

        $('#filter-manufacturer').on('change', function () {
            table.column(3).search(this.value).draw();
        });

        $('#btn-reset-filter').on('click', function () {
            $('#min-price').val('');
            $('#max-price').val('');
            $('#filter-manufacturer').val('');
            $('#custom-search-input').val('');
            table.search('');
            table.columns().search('');
            table.draw();
        });

        function showToast(message, type = 'error') {
            $('.toast-notification').remove();
            var bgColor = type === 'success' ? '#2ecc71' : '#e74c3c';
            var icon = type === 'success' ? 'checkmark-circle-outline' : 'alert-circle-outline';

            var toast = $('<div class="toast-notification"><ion-icon name="' + icon + '"></ion-icon> ' + message + '</div>');
            toast.css('background-color', bgColor);
            $('body').append(toast);

            setTimeout(function() {
                toast.addClass('show');
            }, 50);

            setTimeout(function() {
                toast.removeClass('show');
                setTimeout(function() {
                    toast.remove();
                }, 300);
            }, 4000);
        }

        // --- Xử lý upload file Excel qua AJAX (Two-step wizard) ---
        $('#excelFile').on('change', function () {
            var fileInput = this;
            if (fileInput.files.length === 0) return;

            var file = fileInput.files[0];
            var formData = new FormData();
            formData.append('excelFile', file);

            // Hiển thị trạng thái đang xử lý (loading)
            var originalText = $('button:has(ion-icon[name="document-text-outline"])').html();
            $('button:has(ion-icon[name="document-text-outline"])')
                .prop('disabled', true)
                .html('<ion-icon name="sync-outline" class="spin" style="animation: spin 1s linear infinite; display: inline-block;"></ion-icon> Đang phân tích...');

            // Thêm style animation spin vào trang
            if ($('#spin-css').length === 0) {
                $('head').append('<style id="spin-css">@keyframes spin { 100% { transform:rotate(360deg); } } .spin { animation: spin 1s linear infinite; }</style>');
            }

            $.ajax({
                url: 'product-manager/importExcel',
                type: 'POST',
                data: formData,
                processData: false,
                contentType: false,
                dataType: 'json',
                success: function (response) {
                    // Reset giá trị để có thể chọn lại cùng file
                    $(fileInput).val('');
                    // Khôi phục nút bấm
                    $('button:has(ion-icon[name="document-text-outline"])')
                        .prop('disabled', false)
                        .html(originalText);

                    if (response.status === 'success') {
                        var products = response.products;
                        var tbody = $('#excel-preview-body');
                        tbody.empty();

                        if (!products || products.length === 0) {
                            $('#error-popup-message').text('File Excel trống hoặc không chứa dòng sản phẩm hợp lệ!');
                            $('#modal-error-popup').addClass('show');
                            return;
                        }

                        // Set current date/time
                        const now = new Date();
                        const dateStr = now.toLocaleDateString('vi-VN') + ' ' + now.toLocaleTimeString('vi-VN', { hour: '2-digit', minute: '2-digit' });
                        $('#excel-import-date').text(dateStr);

                        products.forEach(function (p) {
                            var statusBadge = '';
                            if (p.isExisting) {
                                statusBadge = '<span class="badge" style="background-color: #ffeaa7; color: #d63031; padding: 5px 12px; border-radius: 20px; font-weight: 600; font-size: 0.8rem; display: inline-block;">Cập nhật tồn kho</span>';
                            } else {
                                statusBadge = '<span class="badge" style="background-color: #dff9fb; color: #0984e3; padding: 5px 12px; border-radius: 20px; font-weight: 600; font-size: 0.8rem; display: inline-block;">Thêm mới</span>';
                            }

                            var rowHtml = '<tr style="border-bottom: 1px solid #e1e8ed;">' +
                                '<td style="padding: 12px; text-align: left; font-weight: 500; color: #2c3e50; font-size: 0.95rem;">' + p.productName + '</td>' +
                                '<td style="padding: 12px; text-align: center;">' + statusBadge + '</td>' +
                                '<td style="padding: 12px; text-align: center; font-weight: 600; color: #7f8c8d; font-size: 0.95rem;">' + p.oldQuantity + '</td>' +
                                '<td style="padding: 12px; text-align: center; font-weight: 600; color: #2ecc71; font-size: 1rem;">' + p.newQuantity + '</td>' +
                                '</tr>';
                            tbody.append(rowHtml);
                        });

                        $('#modal-confirm-excel').addClass('show');
                    } else {
                        $('#error-popup-message').text(response.message || 'File không đúng định dạng hoặc không thể phân tích!');
                        $('#modal-error-popup').addClass('show');
                    }
                },
                error: function (xhr, status, error) {
                    $(fileInput).val('');
                    $('button:has(ion-icon[name="document-text-outline"])')
                        .prop('disabled', false)
                        .html(originalText);
                    
                    $('#error-popup-message').text('Không thể gửi tệp tin hoặc kết nối máy chủ bị lỗi! Vui lòng kiểm tra lại định dạng file.');
                    $('#modal-error-popup').addClass('show');
                }
            });
        });

        // Sự kiện đóng các Modal
        $('#btn-close-error').on('click', function () {
            $('#modal-error-popup').removeClass('show');
        });

        $('#btn-cancel-import, #close-confirm-excel-btn').on('click', function () {
            $('#modal-confirm-excel').removeClass('show');
            // Gửi request dọn dẹp session để an toàn
            $.post('product-manager/confirmImportExcel', { action: 'confirmImportExcel' }); // Gọi khống để dọn dẹp hoặc bỏ qua
        });

        // Xác nhận thực sự lưu xuống CSDL
        $('#btn-confirm-import').on('click', function () {
            var confirmBtn = $(this);
            var originalConfirmHtml = confirmBtn.html();

            confirmBtn.prop('disabled', true).html('<ion-icon name="sync-outline" class="spin" style="animation: spin 1s linear infinite; display: inline-block;"></ion-icon> Đang nhập kho...');

            $.ajax({
                url: 'product-manager/confirmImportExcel',
                type: 'POST',
                dataType: 'json',
                success: function (response) {
                    confirmBtn.prop('disabled', false).html(originalConfirmHtml);
                    $('#modal-confirm-excel').removeClass('show');

                    if (response.status === 'success') {
                        showToast("Nhập kho sản phẩm từ Excel thành công!", "success");
                        setTimeout(function () {
                            location.reload();
                        }, 1200);
                    } else {
                        $('#error-popup-message').text(response.message || 'Lỗi khi cập nhật CSDL từ Excel!');
                        $('#modal-error-popup').addClass('show');
                    }
                },
                error: function () {
                    confirmBtn.prop('disabled', false).html(originalConfirmHtml);
                    $('#modal-confirm-excel').removeClass('show');
                    $('#error-popup-message').text('Lỗi hệ thống khi lưu trữ dữ liệu!');
                    $('#modal-error-popup').addClass('show');
                }
            });
        });

        // Show server feedback toasts based on URL query parameters
        const urlParams = new URLSearchParams(window.location.search);
        if (urlParams.has('success')) {
            showToast("Thao tác thực hiện thành công!", "success");
        } else if (urlParams.has('error')) {
            showToast("Đã có lỗi xảy ra! Vui lòng thử lại sau.", "error");
        }

        // Form Validation on Submit
        $('#add-product-form').on('submit', function (e) {
            var isValid = true;

            // Clear existing errors
            $('.error-msg').remove();
            $('.invalid-field').removeClass('invalid-field');

            // 1. Tên sản phẩm
            var name = $('#p-name').val().trim();
            if (name === "") {
                isValid = false;
                $('#p-name').addClass('invalid-field').after('<span class="error-msg">Tên sản phẩm không được để trống hoặc chỉ có khoảng trắng!</span>');
            }

            // 2. Loại rượu
            var type = $('#p-type').val();
            if (type === "") {
                isValid = false;
                $('#p-type').addClass('invalid-field').after('<span class="error-msg">Vui lòng chọn loại rượu!</span>');
            }

            // 3. Danh mục
            var category = $('#p-category').val();
            if (category === "") {
                isValid = false;
                $('#p-category').addClass('invalid-field').after('<span class="error-msg">Vui lòng chọn danh mục!</span>');
            }

            // 4. Nhà sản xuất
            var manufacturer = $('#p-manufacturer').val();
            if (manufacturer === "") {
                isValid = false;
                $('#p-manufacturer').addClass('invalid-field').after('<span class="error-msg">Vui lòng chọn nhà sản xuất!</span>');
            }

            // 5. Giá bán
            var priceVal = $('#p-price').val();
            if (priceVal === "") {
                isValid = false;
                $('#p-price').addClass('invalid-field').after('<span class="error-msg">Vui lòng nhập giá bán!</span>');
            } else {
                var price = parseFloat(priceVal);
                if (isNaN(price) || price <= 0) {
                    isValid = false;
                    $('#p-price').addClass('invalid-field').after('<span class="error-msg">Giá bán phải lớn hơn 0 VND!</span>');
                }
            }

            // 6. Số lượng tồn
            var stockVal = $('#p-stock').val();
            if (stockVal === "") {
                isValid = false;
                $('#p-stock').addClass('invalid-field').after('<span class="error-msg">Vui lòng nhập số lượng tồn kho!</span>');
            } else {
                var stock = parseInt(stockVal, 10);
                if (isNaN(stock) || stock < 0) {
                    isValid = false;
                    $('#p-stock').addClass('invalid-field').after('<span class="error-msg">Số lượng tồn kho không được âm!</span>');
                }
            }

            // 7. Nồng độ cồn (nếu nhập)
            var alcoholVal = $('#p-alcohol').val().trim();
            if (alcoholVal !== "") {
                var alcohol = parseFloat(alcoholVal);
                if (isNaN(alcohol) || alcohol < 0 || alcohol > 100) {
                    isValid = false;
                    $('#p-alcohol').addClass('invalid-field').after('<span class="error-msg">Nồng độ cồn phải là số từ 0 đến 100%!</span>');
                }
            }

            if (!isValid) {
                e.preventDefault();
                showToast("Vui lòng kiểm tra lại thông tin nhập liệu!");

                var firstInvalid = $('.invalid-field').first();
                if (firstInvalid.length > 0) {
                    $('.modal-content-form').animate({
                        scrollTop: firstInvalid.offset().top - $('.modal-content-form').offset().top + $('.modal-content-form').scrollTop() - 40
                    }, 500);
                }
            }
        });
    });
</script>
</body>
</html>