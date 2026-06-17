<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="vi">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Quản Lý Xuất Kho</title>
    <script src="<%= request.getContextPath() %>/popup.js"></script>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/admin/admin_css/manage_product_style.css">
    <script type="module" src="https://unpkg.com/ionicons@7.1.0/dist/ionicons/ionicons.esm.js"></script>
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
            <c:set var="activePage" value="issue" scope="request"/>
            <%@ include file="/admin/components/sidebar_items_component.jsp" %>
        </ul>
    </nav>

    <div class="dashboard-content">
        <main class="dashboard-main-content">

            <div class="main-header">
                <h1>Quản Lý Xuất Kho</h1>
                <div class="header-actions">
                    <button class="btn btn-primary add-issue-btn" id="btn-open-add">
                        <ion-icon name="add-circle-outline" data-require-perm="inventory:upsert"></ion-icon> Tạo Phiếu Xuất
                    </button>
                </div>
            </div>

            <div class="filter-bar">
                <div class="filter-item">
                    <label for="filter-reason">Lý do xuất</label>
                    <select id="filter-reason" class="filter-input">
                        <option value="">Tất cả lý do</option>
                        <option value="Xuất kho bán hàng">Xuất kho bán hàng</option>
                        <option value="Xuất kho tiêu hủy">Xuất kho tiêu hủy</option>
                        <option value="Hàng lỗi / Trả hàng">Hàng lỗi / Trả hàng</option>
                        <option value="Khác">Khác</option>
                    </select>
                </div>

                <div class="filter-item">
                    <label>Tìm kiếm chung</label>
                    <input type="text" id="custom-search-input" class="filter-input" placeholder="Mã phiếu, Ghi chú...">
                </div>

                <button type="button" class="btn-reset" id="btn-reset-filter">
                    Làm Mới Bộ Lọc
                </button>
            </div>

            <div class="table-container">
                <div class="table-scroll-wrapper">
                    <table id="issueTable" class="product-table">
                        <thead>
                        <tr>
                            <th style="width: 15%;">Mã Phiếu</th>
                            <th style="width: 15%;">Người Thực Hiện</th>
                            <th style="width: 15%;">Mã Đơn Hàng</th>
                            <th style="width: 25%;">Lý Do Xuất</th>
                            <th style="width: 15%;">Ngày Xuất</th>
                            <th style="width: 15%;">Ghi Chú</th>
                            <th style="width: 10%;">Hành động</th>
                        </tr>
                        </thead>
                        <tbody>
                        <c:forEach var="i" items="${issues}">
                            <tr>
                                <td>#IS-${i.id}</td>
                                <td><c:out value="${i.creatorName != null ? i.creatorName : i.userId}"/></td>
                                <td><c:out value="${i.orderId != null ? i.orderId : 'Không có'}"/></td>
                                <td><c:out value="${i.reason}"/></td>
                                <td>
                                    <fmt:formatDate value="${i.createAt}" pattern="dd/MM/yyyy HH:mm"/>
                                </td>
                                <td><c:out value="${i.note}"/></td>
                                <td>
                                    <div class="cell-action">
                                        <button type="button" class="btn btn-secondary view-issue-btn" onclick="viewDetail(${i.id})">
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

<!-- Modal Tạo Phiếu Xuất Kho -->
<div class="modal-overlay-form product-form-modal" id="modal-phieu-xuat">
    <div class="modal-content-form" style="max-width: 750px;">
        <button class="modal-close-form" id="close-form-btn">X</button>
        <h2>Tạo Phiếu Xuất Kho</h2>

        <form id="add-issue-form" action="<%= request.getContextPath() %>/product-issue-manager/create" method="POST">
            <input type="hidden" name="action" value="create">

            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 15px; margin-bottom: 15px;">
                <div class="form-group" style="margin-bottom: 0;">
                    <label style="font-weight: 600; color: #4a5568;">Người Xuất</label>
                    <input type="text" class="filter-input" value="${sessionScope.user.fullName != null ? sessionScope.user.fullName : (sessionScope.user.username != null ? sessionScope.user.username : 'Admin')}" readonly style="background-color: #edf2f7; cursor: not-allowed; width: 100%; border: 1px solid #cbd5e0; padding: 8px; border-radius: 4px; color: #4a5568; font-weight: 500;">
                </div>
                <div class="form-group" style="margin-bottom: 0;">
                    <label style="font-weight: 600; color: #4a5568;">Ngày Xuất</label>
                    <input type="text" id="i-current-date" class="filter-input" readonly style="background-color: #edf2f7; cursor: not-allowed; width: 100%; border: 1px solid #cbd5e0; padding: 8px; border-radius: 4px; color: #4a5568; font-weight: 500;">
                </div>
            </div>

            <div class="form-group">
                <label>Lý do xuất</label>
                <select name="reason" id="i-reason" required>
                    <option value="Xuất kho bán hàng">Xuất kho bán hàng</option>
                    <option value="Xuất kho tiêu hủy">Xuất kho tiêu hủy</option>
                    <option value="Hàng lỗi / Trả hàng">Hàng lỗi / Trả hàng</option>
                    <option value="Khác">Khác</option>
                </select>
            </div>

            <div class="form-group">
                <label>Mã Đơn Hàng (Nếu có)</label>
                <input type="number" name="orderId" id="i-orderId" placeholder="Nhập mã đơn hàng liên kết (nếu có)">
            </div>

            <!-- Chọn sản phẩm xuất động -->
            <div class="form-group" style="border: 1px solid #ddd; padding: 15px; border-radius: 8px; margin-bottom: 15px;">
                <label style="font-weight: bold; margin-bottom: 10px; display: block;">Thêm Sản Phẩm Xuất</label>
                <div style="display: flex; gap: 10px; align-items: flex-end; margin-bottom: 10px;">
                    <div style="flex: 3;">
                        <label style="font-size: 12px; color: #666;">Chọn sản phẩm</label>
                        <select id="select-product" style="width: 100%; padding: 8px; border-radius: 4px; border: 1px solid #ccc;">
                            <option value="">-- Chọn sản phẩm --</option>
                            <c:forEach items="${products}" var="p">
                                <option value="${p.id}" data-name="${p.productName}" data-qty="${p.quantity}">${p.productName} (Tồn: ${p.quantity})</option>
                            </c:forEach>
                        </select>
                    </div>
                    <div style="flex: 1;">
                        <label style="font-size: 12px; color: #666;">Số lượng xuất</label>
                        <input type="number" id="input-qty" min="1" value="1" style="width: 100%; padding: 8px; border-radius: 4px; border: 1px solid #ccc;">
                    </div>
                    <div>
                        <button type="button" id="btn-add-item" class="btn btn-primary" style="padding: 8px 15px; height: 38px;">Thêm</button>
                    </div>
                </div>

                <table class="product-table" style="width: 100%; margin-top: 10px;" id="table-added-items">
                    <thead>
                        <tr>
                            <th>Sản phẩm</th>
                            <th>Số lượng xuất</th>
                            <th>Hành động</th>
                        </tr>
                    </thead>
                    <tbody>
                        <!-- Dòng sản phẩm sẽ được Javascript thêm vào đây -->
                    </tbody>
                </table>
            </div>

            <div class="form-group">
                <label>Ghi chú</label>
                <textarea id="i-note" name="note" rows="3" placeholder="Nhập ghi chú xuất kho..."></textarea>
            </div>

            <div class="form-actions">
                <button type="button" class="btn btn-secondary" id="cancel-form-btn">Hủy Bỏ</button>
                <button type="submit" class="btn btn-primary" id="btn-submit-form">Lưu Phiếu Xuất</button>
            </div>
        </form>
    </div>
</div>

<!-- Modal Xem Chi Tiết Phiếu Xuất -->
<div class="modal-overlay-form product-form-modal" id="modal-detail-phieu-xuat">
    <div class="modal-content-form" style="max-width: 700px;">
        <button class="modal-close-form" id="close-detail-btn">X</button>
        <h2>Chi Tiết Phiếu Xuất #<span id="detail-issue-id"></span></h2>
        <div style="margin-bottom: 15px; font-size: 14px; line-height: 1.6;">
            <p><strong>Mã Phiếu:</strong> <span id="detail-issue-code"></span></p>
            <p><strong>Người Xuất:</strong> <span id="detail-issue-user"></span></p>
            <p><strong>Liên kết Đơn Hàng:</strong> <span id="detail-issue-order"></span></p>
            <p><strong>Lý Do:</strong> <span id="detail-issue-reason"></span></p>
            <p><strong>Ngày Xuất:</strong> <span id="detail-issue-date"></span></p>
            <p><strong>Ghi Chú:</strong> <span id="detail-issue-note"></span></p>
        </div>
        <table class="product-table" style="width: 100%;" id="table-detail-items">
            <thead>
                <tr>
                    <th>Sản phẩm</th>
                    <th>Số lượng xuất</th>
                </tr>
            </thead>
            <tbody>
                <!-- AJAX details will be rendered here -->
            </tbody>
        </table>
        <div class="form-actions" style="margin-top: 20px;">
            <button type="button" class="btn btn-secondary" id="close-detail-footer-btn">Đóng</button>
        </div>
    </div>
</div>

<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
<script src="https://cdn.datatables.net/2.0.8/js/dataTables.js"></script>

<script>
    $(document).ready(function () {
        var table = $('#issueTable').DataTable({
            "paging": true,
            "pageLength": 10,
            "language": {
                "url": "https://cdn.datatables.net/plug-ins/1.10.25/i18n/Vietnamese.json"
            },
            "columnDefs": [
                {"orderable": false, "targets": [6]},
                {"searchable": false, "targets": [6]}
            ],
            "dom": '<"top"l>rt<"bottom"ip><"clear">'
        });

        $('#custom-search-input').on('keyup', function () {
            table.search(this.value).draw();
        });

        $('#filter-reason').on('change', function () {
            table.column(3).search(this.value).draw();
        });

        $('#btn-reset-filter').on('click', function () {
            $('#filter-reason').val('');
            $('#custom-search-input').val('');
            table.search('');
            table.column(3).search('').draw();
        });

        const modal = document.getElementById('modal-phieu-xuat');
        const openBtn = document.getElementById('btn-open-add');
        const closeBtn = document.getElementById('close-form-btn');
        const cancelBtn = document.getElementById('cancel-form-btn');

        function toggleModal(show) {
            if (show) modal.classList.add('show'); else modal.classList.remove('show');
        }

        if (closeBtn) closeBtn.addEventListener('click', () => toggleModal(false));
        if (cancelBtn) cancelBtn.addEventListener('click', () => toggleModal(false));

        if (openBtn) openBtn.addEventListener('click', () => {
            $('#add-issue-form')[0].reset();
            $('#table-added-items tbody').empty();
            
            // Set current date/time
            const now = new Date();
            const dateStr = now.toLocaleDateString('vi-VN') + ' ' + now.toLocaleTimeString('vi-VN', { hour: '2-digit', minute: '2-digit' });
            $('#i-current-date').val(dateStr);
            
            toggleModal(true);
        });

        // Xử lý thêm sản phẩm vào bảng tạm xuất kho
        $('#btn-add-item').on('click', function () {
            const productSelect = $('#select-product');
            const selectedOpt = productSelect.find('option:selected');
            const productId = productSelect.val();
            const productName = selectedOpt.data('name');
            const maxQty = parseInt(selectedOpt.data('qty'));
            const qty = parseInt($('#input-qty').val());

            if (!productId) {
                alert('Vui lòng chọn sản phẩm.');
                return;
            }
            if (isNaN(qty) || qty <= 0) {
                alert('Số lượng xuất phải lớn hơn 0.');
                return;
            }
            
            // Tìm số lượng đã thêm tạm thời trong bảng
            let addedQty = 0;
            $('#table-added-items tbody tr').each(function () {
                const existingId = $(this).find('input[name="productId[]"]').val();
                if (existingId === productId) {
                    addedQty += parseInt($(this).find('input[name="quantity[]"]').val());
                }
            });

            if (addedQty + qty > maxQty) {
                alert(`Không thể xuất quá số lượng tồn kho (Tồn kho: ${maxQty}, Đã thêm: ${addedQty}, Muốn xuất thêm: ${qty}).`);
                return;
            }

            let exists = false;
            $('#table-added-items tbody tr').each(function () {
                const existingId = $(this).find('input[name="productId[]"]').val();
                if (existingId === productId) {
                    exists = true;
                    const currentQtyInput = $(this).find('input[name="quantity[]"]');
                    const newQty = parseInt(currentQtyInput.val()) + qty;
                    currentQtyInput.val(newQty);
                    $(this).find('.row-qty-display').text(newQty);
                }
            });

            if (!exists) {
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
                            <button type="button" class="btn btn-danger btn-remove-item" style="padding: 3px 8px; font-size: 12px;">Xóa</button>
                        </td>
                    </tr>
                `;
                $('#table-added-items tbody').append(rowHtml);
            }

            productSelect.val('');
            $('#input-qty').val(1);
        });

        $('#table-added-items').on('click', '.btn-remove-item', function () {
            $(this).closest('tr').remove();
        });

        $('#add-issue-form').on('submit', function (e) {
            if ($('#table-added-items tbody tr').length === 0) {
                alert('Vui lòng thêm ít nhất một sản phẩm vào phiếu xuất.');
                e.preventDefault();
            }
        });

        const detailModal = document.getElementById('modal-detail-phieu-xuat');
        const closeDetailBtn = document.getElementById('close-detail-btn');
        const closeDetailFooterBtn = document.getElementById('close-detail-footer-btn');

        function toggleDetailModal(show) {
            if (show) detailModal.classList.add('show'); else detailModal.classList.remove('show');
        }

        if (closeDetailBtn) closeDetailBtn.addEventListener('click', () => toggleDetailModal(false));
        if (closeDetailFooterBtn) closeDetailFooterBtn.addEventListener('click', () => toggleDetailModal(false));
    });

    function viewDetail(id) {
        $.ajax({
            url: '<%= request.getContextPath() %>/product-issue-manager/get-details',
            type: 'GET',
            data: {
                action: 'get-details',
                id: id
            },
            success: function (data) {
                if (!data) {
                    alert('Không tìm thấy thông tin phiếu xuất.');
                    return;
                }
                $('#detail-issue-id').text(id);
                $('#detail-issue-code').text('#IS-' + id);
                
                // Sử dụng trực tiếp dữ liệu từ Database do Server trả về qua JDBI join
                const user = data.creatorName ? data.creatorName : ('User ID: ' + data.userId);
                const order = data.orderId ? data.orderId : 'Không có';
                const reason = data.reason ? data.reason : 'N/A';
                
                // Format Ngày Xuất từ createAt của database
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

                $('#detail-issue-user').text(user);
                $('#detail-issue-order').text(order);
                $('#detail-issue-reason').text(reason);
                $('#detail-issue-date').text(dateStr);
                $('#detail-issue-note').text(data.note ? data.note : 'Không có ghi chú.');

                const tbody = $('#table-detail-items tbody');
                tbody.empty();

                const details = data.details || [];
                details.forEach(function (item) {
                    const rowHtml = `
                        <tr>
                            <td>\${item.productName ? item.productName : item.productId}</td>
                            <td>\${item.quantity}</td>
                        </tr>
                    `;
                    tbody.append(rowHtml);
                });
                
                document.getElementById('modal-detail-phieu-xuat').classList.add('show');
            },
            error: function (xhr, status, error) {
                alert('Không thể tải chi tiết phiếu xuất: ' + error);
            }
        });
    }
</script>
</body>
</html>