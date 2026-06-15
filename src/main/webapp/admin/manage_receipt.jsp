<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="vi">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Quản Lý Nhập Kho</title>
    <script src="<%= request.getContextPath() %>/popup.js"></script>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/admin/admin_css/manage_product_style.css">
    <script nomodule src="https://unpkg.com/ionicons@7.1.0/dist/ionicons/ionicons.js"></script>
</head>

<body>
<div class="dashboard-container">

    <nav class="dashboard-sidebar">
        <ul class="sidebar-items">
            <div class="group-avatar">
                <%@ include file="/admin/components/avatar.jsp" %>
                <%@ include file="/admin/components/notify_icon.jsp" %>
            </div>
            <c:set var="activePage" value="receipt" scope="request"/>
            <%@ include file="/admin/components/sidebar_items_component.jsp" %>
        </ul>
    </nav>

    <div class="dashboard-content">
        <main class="dashboard-main-content">

            <div class="main-header">
                <h1>Quản Lý Nhập Kho</h1>
                <div class="header-actions">
                    <button class="btn btn-danger remove-receipt-btn">
                        <ion-icon name="trash-outline" data-require-perm="inventory:delete"></ion-icon> Xóa (Đã chọn)
                    </button>

                    <button class="btn btn-primary add-receipt-btn" id="btn-open-add">
                        <ion-icon name="add-circle-outline" data-require-perm="inventory:upsert"></ion-icon> Tạo Phiếu Nhập
                    </button>
                </div>
            </div>

            <div class="filter-bar">
                <div class="filter-item">
                    <label>Tổng tiền từ</label>
                    <input type="number" id="min-amount" class="filter-input" placeholder="0">
                </div>
                <div class="filter-item">
                    <label>Đến</label>
                    <input type="number" id="max-amount" class="filter-input" placeholder="Tối đa">
                </div>

                <div class="filter-item">
                    <label>Tìm kiếm chung</label>
                    <input type="text" id="custom-search-input" class="filter-input" placeholder="Mã phiếu, Tên NCC...">
                </div>

                <button type="button" class="btn-reset" id="btn-reset-filter">
                    Làm Mới Bộ Lọc
                </button>
            </div>

            <div class="table-container">
                <div class="table-scroll-wrapper">
                    <table id="receipt-datatable" class="product-table">
                        <thead>
                        <tr>
                            <th style="width: 5%;"><input type="checkbox" id="select-all-checkbox"></th>
                            <th style="width: 15%;">Mã Phiếu</th>
                            <th style="width: 15%;">Người Tạo</th>
                            <th style="width: 15%;">Nhà Cung Cấp</th>
                            <th style="width: 15%;">Tổng Tiền</th>
                            <th style="width: 15%;">Ngày Nhập</th>
                            <th style="width: 10%;">Ghi Chú</th>
                            <th style="width: 10%;">Hành động</th>
                        </tr>
                        </thead>
                        <tbody>
                        <c:forEach items="${receipts}" var="r">
                            <tr>
                                <td><input type="checkbox" class="row-checkbox" value="${r.id}"></td>
                                <td>#RE-${r.id}</td>
                                <td><c:out value="${r.creatorName != null ? r.creatorName : r.userId}"/></td>
                                <td><c:out value="${r.supplierName != null ? r.supplierName : 'N/A'}"/></td>
                                <td>
                                    <fmt:setLocale value="vi_VN"/>
                                    <fmt:formatNumber value="${r.totalAmount}" type="currency" currencySymbol="VND" maxFractionDigits="0"/>
                                </td>
                                <td>
                                    <fmt:formatDate value="${r.createAt}" pattern="dd/MM/yyyy HH:mm"/>
                                </td>
                                <td><c:out value="${r.note}"/></td>
                                <td>
                                    <div class="cell-action">
                                        <button type="button" class="btn btn-secondary view-receipt-btn" onclick="viewDetail(${r.id})">
                                            Xem
                                        </button>
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

<div class="modal-overlay-form product-form-modal" id="modal-phieu-nhap">
    <div class="modal-content-form" style="max-width: 750px;">
        <button class="modal-close-form" id="close-form-btn">X</button>
        <h2>Tạo Phiếu Nhập Kho</h2>

        <form id="add-receipt-form" action="<%= request.getContextPath() %>/product-receipt-manager/create" method="POST">
            <input type="hidden" id="form-action" name="action" value="create">

            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 15px; margin-bottom: 15px;">
                <div class="form-group" style="margin-bottom: 0;">
                    <label style="font-weight: 600; color: #4a5568;">Người Nhập</label>
                    <input type="text" class="filter-input" value="${sessionScope.user.fullName != null ? sessionScope.user.fullName : (sessionScope.user.username != null ? sessionScope.user.username : 'Admin')}" readonly style="background-color: #edf2f7; cursor: not-allowed; width: 100%; border: 1px solid #cbd5e0; padding: 8px; border-radius: 4px; color: #4a5568; font-weight: 500;">
                </div>
                <div class="form-group" style="margin-bottom: 0;">
                    <label style="font-weight: 600; color: #4a5568;">Ngày Nhập</label>
                    <input type="text" id="r-current-date" class="filter-input" readonly style="background-color: #edf2f7; cursor: not-allowed; width: 100%; border: 1px solid #cbd5e0; padding: 8px; border-radius: 4px; color: #4a5568; font-weight: 500;">
                </div>
            </div>

            <div class="form-group">
                <label>Nhà Cung Cấp</label>
                <select id="r-supplier" name="supplierId" required>
                    <option value="">-- Chọn nhà cung cấp --</option>
                    <c:forEach items="${suppliers}" var="s">
                        <option value="${s.id}"><c:out value="${s.manufacturerName}"/></option>
                    </c:forEach>
                </select>
            </div>

            <!-- Chọn sản phẩm động -->
            <div class="form-group" style="border: 1px solid #ddd; padding: 15px; border-radius: 8px; margin-bottom: 15px;">
                <label style="font-weight: bold; margin-bottom: 10px; display: block;">Thêm Sản Phẩm Nhập</label>
                <div style="display: flex; gap: 10px; align-items: flex-end; margin-bottom: 10px;">
                    <div style="flex: 2;">
                        <label style="font-size: 12px; color: #666;">Chọn sản phẩm</label>
                        <select id="select-product" style="width: 100%; padding: 8px; border-radius: 4px; border: 1px solid #ccc;">
                            <option value="">-- Chọn sản phẩm --</option>
                            <c:forEach items="${products}" var="p">
                                <option value="${p.id}" data-name="${p.productName}" data-price="${p.price}">${p.productName} (Tồn: ${p.quantity})</option>
                            </c:forEach>
                        </select>
                    </div>
                    <div style="flex: 1;">
                        <label style="font-size: 12px; color: #666;">Số lượng</label>
                        <input type="number" id="input-qty" min="1" value="1" style="width: 100%; padding: 8px; border-radius: 4px; border: 1px solid #ccc;">
                    </div>
                    <div style="flex: 1;">
                        <label style="font-size: 12px; color: #666;">Đơn giá nhập (VND)</label>
                        <input type="number" id="input-price" min="0" placeholder="Đơn giá" style="width: 100%; padding: 8px; border-radius: 4px; border: 1px solid #ccc;">
                    </div>
                    <div>
                        <button type="button" id="btn-add-item" class="btn btn-primary" style="padding: 8px 15px; height: 38px;">Thêm</button>
                    </div>
                </div>

                <table class="product-table" style="width: 100%; margin-top: 10px;" id="table-added-items">
                    <thead>
                        <tr>
                            <th>Sản phẩm</th>
                            <th>Số lượng</th>
                            <th>Đơn giá</th>
                            <th>Thành tiền</th>
                            <th>Hành động</th>
                        </tr>
                    </thead>
                    <tbody>
                        <!-- Dòng sản phẩm sẽ được Javascript thêm vào đây -->
                    </tbody>
                </table>
                <div style="text-align: right; margin-top: 10px; font-weight: bold; font-size: 15px;">
                    Tổng tiền phiếu: <span id="total-receipt-amount" style="color: #d9534f;">0đ</span>
                </div>
            </div>

            <div class="form-group">
                <label>Ghi chú</label>
                <textarea id="r-note" name="note" rows="3" placeholder="Nhập ghi chú phiếu nhập..."></textarea>
            </div>

            <div class="form-actions">
                <button type="button" class="btn btn-secondary" id="cancel-form-btn">Hủy Bỏ</button>
                <button type="submit" class="btn btn-primary" id="btn-submit-form">Lưu Phiếu Nhập</button>
            </div>
        </form>
    </div>
</div>

<!-- Modal xem chi tiết phiếu nhập -->
<div class="modal-overlay-form product-form-modal" id="modal-detail-phieu-nhap">
    <div class="modal-content-form" style="max-width: 700px;">
        <button class="modal-close-form" id="close-detail-btn">X</button>
        <h2>Chi Tiết Phiếu Nhập #<span id="detail-receipt-id"></span></h2>
        <div style="margin-bottom: 15px; font-size: 14px; line-height: 1.6;">
            <p><strong>Mã Phiếu:</strong> <span id="detail-receipt-code"></span></p>
            <p><strong>Người Tạo:</strong> <span id="detail-receipt-user"></span></p>
            <p><strong>Nhà Cung Cấp:</strong> <span id="detail-receipt-supplier"></span></p>
            <p><strong>Ngày Nhập:</strong> <span id="detail-receipt-date"></span></p>
            <p><strong>Ghi Chú:</strong> <span id="detail-receipt-note"></span></p>
        </div>
        <table class="product-table" style="width: 100%;" id="table-detail-items">
            <thead>
                <tr>
                    <th>Sản phẩm</th>
                    <th>Số lượng</th>
                    <th>Đơn giá nhập</th>
                    <th>Thành tiền</th>
                </tr>
            </thead>
            <tbody>
                <!-- AJAX details will be rendered here -->
            </tbody>
        </table>
        <div style="text-align: right; margin-top: 15px; font-weight: bold; font-size: 16px;">
            Tổng tiền: <span id="detail-receipt-total" style="color: #d9534f;">0đ</span>
        </div>
        <div class="form-actions" style="margin-top: 20px;">
            <button type="button" class="btn btn-secondary" id="close-detail-footer-btn">Đóng</button>
        </div>
    </div>
</div>

<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
<script src="https://cdn.datatables.net/2.0.8/js/dataTables.js"></script>

<script>
    document.addEventListener("DOMContentLoaded", function () {
        var table = $('#receipt-datatable').DataTable({
            "paging": true,
            "pageLength": 10,
            "language": {"url": 'https://cdn.datatables.net/plug-ins/2.0.8/i18n/vi.json'},
            "columnDefs": [
                {"orderable": false, "targets": [0, 7]},
                {"searchable": false, "targets": [0, 7]}
            ],
            "dom": '<"top"l>rt<"bottom"ip><"clear">'
        });

        $('#custom-search-input').on('keyup', function () {
            table.search(this.value).draw();
        });

        $('#select-all-checkbox').on('change', function () {
            $('.row-checkbox').prop('checked', this.checked);
        });

        $.fn.dataTable.ext.search.push(
            function (settings, data, dataIndex) {
                var min = parseInt($('#min-amount').val(), 10);
                var max = parseInt($('#max-amount').val(), 10);
                var amountStr = data[4] || "0";
                var amount = parseFloat(amountStr.replace(/[^0-9]/g, ''));

                if ((isNaN(min) && isNaN(max)) ||
                    (isNaN(min) && amount <= max) ||
                    (min <= amount && isNaN(max)) ||
                    (min <= amount && amount <= max)) {
                    return true;
                }
                return false;
            }
        );

        $('#min-amount, #max-amount').on('keyup change', function () {
            table.draw();
        });

        $('#btn-reset-filter').on('click', function () {
            $('#min-amount').val('');
            $('#max-amount').val('');
            $('#custom-search-input').val('');
            table.search('');
            table.columns().search('');
            table.draw();
        });

        const modal = document.getElementById('modal-phieu-nhap');
        const openBtn = document.getElementById('btn-open-add');
        const closeBtn = document.getElementById('close-form-btn');
        const cancelBtn = document.getElementById('cancel-form-btn');

        function toggleModal(show) {
            if (show) modal.classList.add('show'); else modal.classList.remove('show');
        }

        if (closeBtn) closeBtn.addEventListener('click', () => toggleModal(false));
        if (cancelBtn) cancelBtn.addEventListener('click', () => toggleModal(false));

        if (openBtn) openBtn.addEventListener('click', () => {
            $('#add-receipt-form')[0].reset();
            $('#table-added-items tbody').empty();
            $('#total-receipt-amount').text('0đ');
            
            // Set current date/time
            const now = new Date();
            const dateStr = now.toLocaleDateString('vi-VN') + ' ' + now.toLocaleTimeString('vi-VN', { hour: '2-digit', minute: '2-digit' });
            $('#r-current-date').val(dateStr);
            
            toggleModal(true);
        });

        // Tự động điền đơn giá gợi ý khi chọn sản phẩm
        $('#select-product').on('change', function () {
            const selectedOpt = $(this).find('option:selected');
            const price = selectedOpt.data('price');
            if (price) {
                $('#input-price').val(Math.round(price * 0.7)); // Giá nhập mặc định bằng 70% giá bán
            } else {
                $('#input-price').val('');
            }
        });

        // Xử lý thêm sản phẩm vào bảng tạm
        $('#btn-add-item').on('click', function () {
            const productSelect = $('#select-product');
            const selectedOpt = productSelect.find('option:selected');
            const productId = productSelect.val();
            const productName = selectedOpt.data('name');
            const qty = parseInt($('#input-qty').val());
            const unitPrice = parseFloat($('#input-price').val());

            if (!productId) {
                alert('Vui lòng chọn sản phẩm.');
                return;
            }
            if (isNaN(qty) || qty <= 0) {
                alert('Số lượng nhập phải lớn hơn 0.');
                return;
            }
            if (isNaN(unitPrice) || unitPrice < 0) {
                alert('Đơn giá nhập không hợp lệ.');
                return;
            }

            // Kiểm tra xem sản phẩm đã có trong bảng chưa
            let exists = false;
            $('#table-added-items tbody tr').each(function () {
                const existingId = $(this).find('input[name="productId[]"]').val();
                if (existingId === productId) {
                    exists = true;
                    // Cộng dồn số lượng
                    const currentQtyInput = $(this).find('input[name="quantity[]"]');
                    const newQty = parseInt(currentQtyInput.val()) + qty;
                    currentQtyInput.val(newQty);
                    $(this).find('.row-qty-display').text(newQty);
                    
                    // Cập nhật thành tiền dòng
                    const subtotal = newQty * unitPrice;
                    $(this).find('.row-subtotal-display').text(new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(subtotal));
                }
            });

            if (!exists) {
                const subtotal = qty * unitPrice;
                const rowHtml = `
                    <tr>
                        <td>
                            \${productName}
                            <input type="hidden" name="productId[]" value="\${productId}">
                        </td>
                        <td>
                            <span class="row-qty-display">\${qty}</span>
                            <input type="hidden" name="quantity[]" value="\${qty}">
                        </td>
                        <td>
                            \${new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(unitPrice)}
                            <input type="hidden" name="unitPrice[]" value="\${unitPrice}">
                        </td>
                        <td class="row-subtotal-display">
                            \${new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(subtotal)}
                        </td>
                        <td>
                            <button type="button" class="btn btn-danger btn-remove-item" style="padding: 3px 8px; font-size: 12px;">Xóa</button>
                        </td>
                    </tr>
                `;
                $('#table-added-items tbody').append(rowHtml);
            }

            // Reset inputs
            productSelect.val('');
            $('#input-qty').val(1);
            $('#input-price').val('');

            calculateReceiptTotal();
        });

        // Xử lý xóa sản phẩm khỏi bảng tạm
        $('#table-added-items').on('click', '.btn-remove-item', function () {
            $(this).closest('tr').remove();
            calculateReceiptTotal();
        });

        function calculateReceiptTotal() {
            let total = 0;
            $('#table-added-items tbody tr').each(function () {
                const qty = parseInt($(this).find('input[name="quantity[]"]').val());
                const price = parseFloat($(this).find('input[name="unitPrice[]"]').val());
                total += qty * price;
            });
            $('#total-receipt-amount').text(new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(total));
        }

        // Kiểm tra form trước khi submit
        $('#add-receipt-form').on('submit', function (e) {
            if ($('#table-added-items tbody tr').length === 0) {
                alert('Vui lòng thêm ít nhất một sản phẩm vào phiếu nhập.');
                e.preventDefault();
            }
        });

        // Logic Modal Chi tiết
        const detailModal = document.getElementById('modal-detail-phieu-nhap');
        const closeDetailBtn = document.getElementById('close-detail-btn');
        const closeDetailFooterBtn = document.getElementById('close-detail-footer-btn');

        function toggleDetailModal(show) {
            if (show) detailModal.classList.add('show'); else detailModal.classList.remove('show');
        }

        if (closeDetailBtn) closeDetailBtn.addEventListener('click', () => toggleDetailModal(false));
        if (closeDetailFooterBtn) closeDetailFooterBtn.addEventListener('click', () => toggleDetailModal(false));
    });

    function viewDetail(id) {
        // Gọi AJAX lấy dữ liệu chi tiết phiếu nhập
        $.ajax({
            url: '<%= request.getContextPath() %>/product-receipt-manager/get-details',
            type: 'GET',
            data: {
                action: 'get-details',
                id: id
            },
            success: function (data) {
                if (!data) {
                    alert('Không tìm thấy thông tin phiếu nhập.');
                    return;
                }
                // Đổ dữ liệu vào Modal chi tiết
                $('#detail-receipt-id').text(id);
                $('#detail-receipt-code').text('#RE-' + id);
                
                // Sử dụng trực tiếp dữ liệu từ Database do Server trả về qua JDBI join
                const user = data.creatorName ? data.creatorName : ('User ID: ' + data.userId);
                const supplier = data.supplierName ? data.supplierName : 'N/A';
                
                // Format Ngày Nhập từ createAt của database
                let dateStr = 'N/A';
                if (data.createAt) {
                    let d = new Date(data.createAt);
                    if (isNaN(d.getTime())) {
                        d = new Date(Date.parse(data.createAt));
                    }
                    if (!isNaN(d.getTime())) {
                        const day = String(d.getDate()).padStart(2, '0');
                        const month = String(d.getMonth() + 1).padStart(2, '0');
                        const year = d.getFullYear();
                        const hours = String(d.getHours()).padStart(2, '0');
                        const minutes = String(d.getMinutes()).padStart(2, '0');
                        dateStr = `\${day}/\${month}/\${year} \${hours}:\${minutes}`;
                    } else {
                        dateStr = data.createAt;
                    }
                }

                $('#detail-receipt-user').text(user);
                $('#detail-receipt-supplier').text(supplier);
                $('#detail-receipt-date').text(dateStr);
                $('#detail-receipt-note').text(data.note ? data.note : 'Không có ghi chú.');

                const tbody = $('#table-detail-items tbody');
                tbody.empty();

                let total = 0;
                const details = data.details || [];
                details.forEach(function (item) {
                    const subtotal = item.quantity * item.unitPrice;
                    total += subtotal;
                    
                    const rowHtml = `
                        <tr>
                            <td>\${item.productName ? item.productName : item.productId}</td>
                            <td>\${item.quantity}</td>
                            <td>\${new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(item.unitPrice)}</td>
                            <td>\${new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(subtotal)}</td>
                        </tr>
                    `;
                    tbody.append(rowHtml);
                });

                $('#detail-receipt-total').text(new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(total));
                
                // Mở Modal
                document.getElementById('modal-detail-phieu-nhap').classList.add('show');
            },
            error: function (xhr, status, error) {
                alert('Không thể tải thông tin chi tiết phiếu nhập: ' + error);
            }
        });
    }
</script>
</body>
</html>