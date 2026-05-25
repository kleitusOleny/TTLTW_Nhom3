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
            <c:set var="activePage" value="product" scope="request"/>
            <%@ include file="/admin/components/sidebar_items_component.jsp" %>
        </ul>
    </nav>

    <div class="dashboard-content">
        <main class="dashboard-main-content">
            <div class="main-header">
                <h1>Quản Lí Sản Phẩm</h1>
                <div class="header-actions">
                    <button class="btn btn-danger remove-product-btn">
                        <ion-icon name="trash-outline"></ion-icon> Xóa (Đã chọn)
                    </button>

                    <form id="form-import-excel" action="<%= request.getContextPath() %>/product-manager?action=importExcel" method="post" enctype="multipart/form-data" style="display: none;">
                        <input type="file" name="excelFile" id="excelFile" accept=".xlsx, .xls" onchange="document.getElementById('form-import-excel').submit();">
                    </form>
                    <button class="btn btn-success" onclick="document.getElementById('excelFile').click();">
                        <ion-icon name="document-text-outline"></ion-icon> Nhập Excel
                    </button>

                    <button class="btn btn-primary add-product-btn" id="btn-open-add">
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
                                        <button type="button" class="btn btn-secondary edit-product-btn"
                                                data-id="${p.id}" data-name="${p.productName}"
                                                data-type-text="${p.typeId}" data-cat-text="${p.categoryId}"
                                                data-manu-text="${p.manufacturerId}"
                                                data-origin="${p.origin}" data-price="${p.price}"
                                                data-stock="${p.quantity}" data-capacity="${p.capacity}"
                                                data-alcohol="${p.alcohol}" data-detail="${p.detail}"
                                                data-img="${p.imageUrl}">
                                            Sửa
                                        </button>

                                        <form action="product-manager" method="POST" style="margin:0;">
                                            <input type="hidden" name="action" value="delete">
                                            <input type="hidden" name="id" value="${p.id}">
                                            <button type="submit" class="btn btn-danger" onclick="return confirm('Xóa sản phẩm này?');">Xoá</button>
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
                let promises = selectedIds.map(id => {
                    return fetch('product-manager?action=delete&id=' + id, {method: 'POST'});
                });

                Promise.all(promises).then(() => {
                    alert("Đã xóa thành công!");
                    location.reload();
                }).catch(err => {
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
            $('#form-action').val('add');
            $('#prod-id').val('');
            $('#prod-old-image').val('');
            $('.modal-content-form h2').text('Thêm Sản Phẩm Mới');
            $('#btn-submit-form').text('Lưu Sản Phẩm');
            toggleModal(true);
        });

        $('#product-datatable').on('click', '.edit-product-btn', function () {
            var btn = $(this);
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
            $(selectId + ' option').each(function () {
                if ($(this).text().trim() === textToFind) {
                    $(this).prop('selected', true);
                    return false;
                }
            });
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
    });
</script>
</body>
</html>