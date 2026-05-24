<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="vi">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Quản Lý Nhập Kho</title>

    <script type="module" src="https://unpkg.com/ionicons@7.1.0/dist/ionicons/ionicons.esm.js"></script>
    <script nomodule src="https://unpkg.com/ionicons@7.1.0/dist/ionicons/ionicons.js"></script>
    <script src="<%= request.getContextPath() %>/popup.js"></script>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/admin/admin_css/manage_product_style.css">
    <link rel="stylesheet" href="https://cdn.datatables.net/2.0.8/css/dataTables.dataTables.css"/>
    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
    <script src="https://cdn.datatables.net/2.0.8/js/dataTables.js"></script>
</head>

<body>
<div class="container">
    <div class="main-content">
        <div class="header">
            <h1>Quản Lý Nhập Kho</h1>
            <button class="btn btn-primary" onclick="openAddReceiptModal()">
                <ion-icon name="add-circle-outline"></ion-icon> Tạo Phiếu Nhập
            </button>
        </div>

        <div class="filter-bar">
            <div class="filter-group">
                <label for="min-amount">Tổng tiền từ:</label>
                <input type="number" id="min-amount" placeholder="đ tối thiểu">
            </div>
            <div class="filter-group">
                <label for="max-amount">Đến:</label>
                <input type="number" id="max-amount" placeholder="đ tối đa">
            </div>
            <button class="btn btn-outline" id="btn-reset-filter">
                <ion-icon name="refresh-outline"></ion-icon> Reset
            </button>
        </div>

        <div class="card">
            <table id="receiptTable" class="dataTable display">
                <thead>
                <tr>
                    <th>Mã Phiếu</th>
                    <th>Người Tạo</th>
                    <th>Nhà Cung Cấp</th>
                    <th>Tổng Tiền</th>
                    <th>Ngày Nhập</th>
                    <th>Ghi Chú</th>
                    <th>Thao Tác</th>
                </tr>
                </thead>
                <tbody>
                <c:forEach var="r" items="${receipts}">
                    <tr>
                        <td>#RE-${r.id}</td>
                        <td><c:out value="${r.userId}"/></td>
                        <td><c:out value="${r.supplierId != null ? r.supplierId : 'N/A'}"/></td>
                        <td>
                            <fmt:formatNumber value="${r.totalAmount}" type="currency" currencySymbol="đ"/>
                        </td>
                        <td>
                            <fmt:formatDate value="${r.createAt}" pattern="dd/MM/yyyy HH:mm"/>
                        </td>
                        <td><c:out value="${r.note}"/></td>
                        <td>
                            <button class="btn-action btn-view" title="Xem chi tiết" onclick="viewDetail(${r.id})">
                                <ion-icon name="eye-outline"></ion-icon>
                            </button>
                        </td>
                    </tr>
                </c:forEach>
                </tbody>
            </table>
        </div>
    </div>
</div>

<script>
    $(document).ready(function () {
        var table = $('#receiptTable').DataTable({
            "language": {
                "url": "https://cdn.datatables.net/plug-ins/1.10.25/i18n/Vietnamese.json"
            },
            "dom": '<"top"f>rt<"bottom"lp><"clear">'
        });

        // Tùy biến bộ lọc khoảng giá tiền cho phù hợp với dữ liệu cột Tổng Tiền (Cột index số 3)
        $.fn.dataTable.ext.search.push(
            function (settings, data, dataIndex) {
                var min = parseInt($('#min-amount').val(), 10);
                var max = parseInt($('#max-amount').val(), 10);
                var amountStr = data[3] || "0";
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
            table.draw();
        });
    });

    function viewDetail(id) {

    }

    function openAddReceiptModal() {

    }
</script>
</body>
</html>