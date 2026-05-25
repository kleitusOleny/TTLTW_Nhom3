<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="vi">

<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Quản Lý Xuất Kho</title>

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
      <h1>Quản Lý Xuất Kho</h1>
      <button class="btn btn-primary" onclick="openAddIssueModal()">
        <ion-icon name="add-circle-outline"></ion-icon> Tạo Phiếu Xuất
      </button>
    </div>

    <div class="filter-bar">
      <div class="filter-group">
        <label for="filter-reason">Lý do xuất:</label>
        <select id="filter-reason">
          <option value="">Tất cả lý do</option>
          <option value="Xuất kho bán hàng">Xuất kho bán hàng</option>
          <option value="Xuất kho tiêu hủy">Xuất kho tiêu hủy</option>
          <option value="Hàng lỗi / Trả hàng">Hàng lỗi / Trả hàng</option>
        </select>
      </div>
      <button class="btn btn-outline" id="btn-reset-filter">
        <ion-icon name="refresh-outline"></ion-icon> Reset
      </button>
    </div>

    <div class="card">
      <table id="issueTable" class="dataTable display">
        <thead>
        <tr>
          <th>Mã Phiếu</th>
          <th>Người Thực Hiện</th>
          <th>Mã Đơn Hàng</th>
          <th>Lý Do Xuất</th>
          <th>Ngày Xuất</th>
          <th>Ghi Chú</th>
          <th>Thao Tác</th>
        </tr>
        </thead>
        <tbody>
        <c:forEach var="i" items="${issues}">
          <tr>
            <td>#IS-${i.id}</td>
            <td><c:out value="${i.userId}"/></td>
            <td><c:out value="${i.orderId != null ? i.orderId : 'Không có'}"/></td>
            <td><c:out value="${i.reason}"/></td>
            <td>
              <fmt:formatDate value="${i.createAt}" pattern="dd/MM/yyyy HH:mm"/>
            </td>
            <td><c:out value="${i.note}"/></td>
            <td>
              <button class="btn-action btn-view" title="Xem chi tiết" onclick="viewDetail(${i.id})">
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
    // Cấu hình ngôn ngữ tiếng Việt và giao diện phân trang cho bảng dữ liệu
    var table = $('#issueTable').DataTable({
      "language": {
        "url": "https://cdn.datatables.net/plug-ins/1.10.25/i18n/Vietnamese.json"
      },
      "dom": '<"top"f>rt<"bottom"lp><"clear">'
    });

    // Lọc dữ liệu theo cột Lý Do Xuất (Cột index số 3)
    $('#filter-reason').on('change', function () {
      table.column(3).search(this.value).draw();
    });

    // Sự kiện làm mới toàn bộ bộ lọc dữ liệu
    $('#btn-reset-filter').on('click', function () {
      $('#filter-reason').val('');
      table.column(3).search('').draw();
    });
  });

  function viewDetail(id) {
    // Xử lý mở popup xem danh sách các sản phẩm và số lượng đã xuất của phiếu này
  }

  function openAddIssueModal() {
    // Xử lý hiển thị modal thêm mới phiếu xuất kho nội bộ
  }
</script>
</body>
</html>