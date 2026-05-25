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
                        <ion-icon name="trash-outline"></ion-icon> Xóa (Đã chọn)
                    </button>

                    <button class="btn btn-primary add-receipt-btn" id="btn-open-add">
                        <ion-icon name="add-circle-outline"></ion-icon> Tạo Phiếu Nhập
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
                                <td><c:out value="${r.userId}"/></td>
                                <td><c:out value="${r.supplierId != null ? r.supplierId : 'N/A'}"/></td>
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
    <div class="modal-content-form">
        <button class="modal-close-form" id="close-form-btn">X</button>
        <h2>Tạo Phiếu Nhập Kho</h2>

        <form id="add-receipt-form" action="receipt-manager" method="POST">
            <input type="hidden" id="form-action" name="action" value="add">

            <div class="form-group">
                <label>Nhà Cung Cấp</label>
                <select id="r-supplier" name="supplierId" required>
                    <option value="">-- Chọn nhà cung cấp --</option>
                </select>
            </div>

            <div class="form-group">
                <label>Ghi chú</label>
                <textarea id="r-note" name="note" rows="4" placeholder="Nhập ghi chú phiếu nhập..."></textarea>
            </div>

            <div class="form-actions">
                <button type="button" class="btn btn-secondary" id="cancel-form-btn">Hủy Bỏ</button>
                <button type="submit" class="btn btn-primary" id="btn-submit-form">Lưu Phiếu Nhập</button>
            </div>
        </form>
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

        // Tùy biến bộ lọc khoảng giá tiền cho phù hợp với dữ liệu cột Tổng Tiền (Cột index số 4 sau khi thêm checkbox)
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

        // Xử lý logic Modal tương tự product
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
            $('#form-action').val('add');
            $('.modal-content-form h2').text('Tạo Phiếu Nhập Kho');
            $('#btn-submit-form').text('Lưu Phiếu Nhập');
            toggleModal(true);
        });
    });

    function viewDetail(id) {
        console.log("Xem chi tiết phiếu nhập:", id);
    }
</script>
</body>
</html>