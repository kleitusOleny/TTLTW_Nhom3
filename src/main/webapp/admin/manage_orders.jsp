<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
        <%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
            <!DOCTYPE html>
            <html lang="en">

            <head>
                <meta charset="UTF-8">
                <title>Orders Manage</title>
                <link rel="stylesheet"
                    href="${pageContext.request.contextPath}/admin/admin_css/manage_product_style.css">
                <style>
                    /* Premium status badge styles that blend well with both light and dark mode */
                    .cell-status span {
                        padding: 6px 12px;
                        border-radius: 20px;
                        font-weight: 600;
                        font-size: 13px;
                        display: inline-block;
                    }
                    .status-delivered {
                        background-color: rgba(16, 185, 129, 0.15);
                        color: #10b981;
                    }
                    .status-shipping {
                        background-color: rgba(59, 130, 246, 0.15);
                        color: #3b82f6;
                    }
                    .status-preparing {
                        background-color: rgba(245, 158, 11, 0.15);
                        color: #f59e0b;
                    }
                    .status-cancelled {
                        background-color: rgba(239, 68, 68, 0.15);
                        color: #ef4444;
                    }
                    .status-processing {
                        background-color: rgba(100, 116, 139, 0.15);
                        color: #64748b;
                    }
                    .cell-tick input[type="checkbox"] {
                        width: 18px;
                        height: 18px;
                        cursor: pointer;
                        accent-color: var(--primary);
                    }
                    .cell-action {
                        display: flex;
                        gap: 8px;
                        flex-wrap: nowrap;
                    }
                    .cell-id {
                        font-weight: 600;
                        color: var(--text-main);
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
                            <c:set var="activePage" value="order" scope="request" />
                            <%@ include file="/admin/components/sidebar_items_component.jsp" %>
                        </ul>
                    </nav>
                    <div class="dashboard-content">
                        <main class="dashboard-main-content">
                            <div class="main-header">
                                <h1>Quản lí đơn hàng</h1>
                                <div class="header-actions">
                                    <button class="btn btn-danger" id="deleteAll-modal-btn" data-require-perm="orders:delete">
                                        <ion-icon name="trash-outline"></ion-icon> Xoá (Đã chọn)
                                    </button>
                                    <button class="btn btn-primary" data-require-perm="orders:upsert"
                                        onclick="window.location.href='${pageContext.request.contextPath}/admin/create-order'">
                                        <ion-icon name="add-circle-outline"></ion-icon> Tạo đơn mới
                                    </button>
                                </div>
                            </div>

                            <div class="filter-bar">
                                <div class="filter-item">
                                    <label>Từ ngày</label>
                                    <input type="date" id="filter-from-date" class="filter-input">
                                </div>
                                <div class="filter-item">
                                    <label>Đến ngày</label>
                                    <input type="date" id="filter-to-date" class="filter-input">
                                </div>
                                <div class="filter-item">
                                    <label>Trạng thái</label>
                                    <select id="filter-status" class="filter-input">
                                        <option value="">-- Tất cả --</option>
                                        <option value="Chuẩn bị đơn hàng">Chuẩn bị đơn hàng</option>
                                        <option value="Đang xử lý">Đang xử lý</option>
                                        <option value="Đang giao hàng">Đang giao hàng</option>
                                        <option value="Giao hàng thành công">Giao hàng thành công</option>
                                        <option value="Đã giao">Đã giao</option>
                                        <option value="Đã hủy">Đã hủy</option>
                                        <option value="Thanh toán thất bại">Thanh toán thất bại</option>
                                    </select>
                                </div>
                                <div class="filter-item">
                                    <label>Khách hàng</label>
                                    <input type="text" id="filter-customer" class="filter-input" placeholder="Tên khách hàng...">
                                </div>
                                <button type="button" class="btn-reset" id="btn-reset-filter">
                                    Làm Mới Bộ Lọc
                                </button>
                            </div>

                            <c:if test="${not empty sessionScope.successMessage or not empty requestScope.successMessage}">
                                <script>
                                    document.addEventListener("DOMContentLoaded", function () {
                                        showCustomAlert('${not empty sessionScope.successMessage ? sessionScope.successMessage : requestScope.successMessage}');
                                    });
                                </script>
                                <c:if test="${not empty sessionScope.successMessage}">
                                    <c:remove var="successMessage" scope="session"/>
                                </c:if>
                            </c:if>
                            <c:if test="${not empty sessionScope.errorMessage or not empty requestScope.errorMessage}">
                                <script>
                                    document.addEventListener("DOMContentLoaded", function () {
                                        showCustomAlert('${not empty sessionScope.errorMessage ? sessionScope.errorMessage : requestScope.errorMessage}');
                                    });
                                </script>
                                <c:if test="${not empty sessionScope.errorMessage}">
                                    <c:remove var="errorMessage" scope="session"/>
                                </c:if>
                            </c:if>

                            <div class="table-container">
                                <div class="table-scroll-wrapper">
                                    <table id="order-table-main" class="product-table">
                                        <thead>
                                            <tr>
                                                <th style="width: 5%;"><input type="checkbox" id="select-all-checkbox" /></th>
                                                <th style="width: 10%;">ID Đơn Hàng</th>
                                                <th style="width: 25%;">Khách Hàng</th>
                                                <th style="width: 15%;">Ngày Đặt</th>
                                                <th style="width: 15%;">Tổng Tiền</th>
                                                <th style="width: 10%;">Thanh Toán</th>
                                                <th style="width: 10%;">Trạng Thái</th>
                                                <th style="width: 10%;">Hành Động</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <c:forEach items="${orders}" var="o">
                                                <tr id="order-row-${o.id}">
                                                    <td class="cell-tick">
                                                        <input type="checkbox" class="row-checkbox" value="${o.id}" />
                                                    </td>
                                                    <td class="cell-id">DH${o.id}</td>
                                                    <td class="cell-customer">${o.customerName}</td>
                                                    <td class="cell-date">${o.formattedDate}</td>
                                                    <td class="cell-total">${o.formattedTotal}</td>
                                                    <td class="cell-payment">${o.payStrategy != null ? o.payStrategy : 'ChưaTT'}</td>
                                                    <td class="cell-status">
                                                        <span class="${o.statusClass}">${o.statusText}</span>
                                                    </td>
                                                    <td>
                                                        <div class="cell-action">
                                                            <button class="btn btn-secondary" onclick="openViewModal(${o.id})">Xem</button>
                                                            <button class="btn btn-secondary" data-require-perm="orders:upsert" onclick="openEditModal(${o.id})">Sửa</button>
                                                            <button class="btn btn-danger" data-require-perm="orders:delete" onclick="confirmDelete(${o.id})">Xoá</button>
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

                <div class="modal-overlay-form product-form-modal" id="add-order-modal">
                    <div class="modal-content-form">
                        <button type="button" class="modal-close-form" id="close-modal-btn">X</button>
                        <h2>Thêm Đơn Hàng Nhanh</h2>
                        <form id="add-form">
                            <div class="form-group">
                                <label for="customerEmail">Email Khách Hàng</label>
                                <input type="email" name="customerEmail" id="customerEmail" placeholder="Nhập email khách hàng..." required>
                            </div>
                            <div class="form-grid">
                                <div class="form-group">
                                    <label for="date">Ngày Đặt</label>
                                    <input type="date" name="date" id="date" required>
                                </div>
                                <div class="form-group">
                                    <label for="total">Tổng Tiền (VND)</label>
                                    <input type="number" name="total" id="total" min="0" placeholder="Nhập tổng tiền..." required>
                                </div>
                            </div>
                            <div class="form-group">
                                <label for="status">Trạng Thái</label>
                                <select id="status" name="status" required>
                                    <option value="Đang xử lý">Đang xử lý</option>
                                    <option value="Chuẩn bị đơn hàng">Chuẩn bị đơn hàng</option>
                                    <option value="Đang giao hàng">Đang giao hàng</option>
                                    <option value="Giao hàng thành công">Giao hàng thành công</option>
                                    <option value="Đã hủy">Đã hủy</option>
                                </select>
                            </div>
                            <div class="form-actions">
                                <button type="button" class="btn btn-secondary" id="close-modal-btn-2" onclick="document.getElementById('add-order-modal').classList.remove('show');">Huỷ</button>
                                <button type="submit" class="btn btn-primary">Thêm đơn</button>
                            </div>
                        </form>
                    </div>
                </div>

                <div class="modal-overlay-deleteAll" id="deleteAll-order-modal">
                    <div class="modal-content-deleteAll">
                        <div class="group-text-deleteAll">
                            <p class="p-deleteAll1">Bạn có chắc chắn muốn xoá toàn bộ dữ liệu của các ô được chọn?</p>
                            <p class="p-deleteAll2">
                                <ion-icon name="warning-outline" class="icon-warning"></ion-icon>
                                Hành động này sẽ không thể hoàn tác
                            </p>
                        </div>
                        <div class="group-button-action delete-all">
                            <button type="button" class="element-button" id="close-modal-btn6">Huỷ</button>
                            <button type="submit" class="deleteAll-button">Xoá Tất Cả</button>
                        </div>
                    </div>
                </div>

                <div class="modal-overlay" id="orderDetailModal">
                    <div class="modal-content"
                        style="width: 900px; max-width: 95vw; padding: 0; border-radius: 4px; overflow: hidden; font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif;">
                        <div class="modal-header"
                            style="padding: 20px 30px; background-color: #fff; border-bottom: none; display: flex; justify-content: space-between; align-items: center;">
                            <h2 id="modal-order-id"
                                style="color: #a94442; font-size: 24px; margin: 0; font-weight: bold;">Chi tiết đơn hàng
                                #<span id="order-detail-id-display">${orderInfo.id}</span></h2>
                            <span class="close-modal-btn" id="closeOrderDetailModal"
                                style="font-size: 30px; cursor: pointer; color: #aaa; line-height: 20px;">&times;</span>
                        </div>

                        <div class="modal-body"
                            style="padding: 0 30px 30px 30px; max-height: 60vh; overflow-y: auto; background-color: #fff;">

                            <!-- Customer Info -->
                            <div class="section info" style="margin-bottom: 30px;">
                                <h3
                                    style="color: #a94442; font-size: 16px; margin-bottom: 15px; font-weight: bold; text-transform: uppercase;">
                                    Thông tin khách hàng</h3>
                                <div style="font-size: 14px; color: #333; line-height: 1.6;">
                                    <div style="margin-bottom: 8px;"><strong
                                            style="display: inline-block; width: 180px;">Họ và tên:</strong> <span
                                            id="modal-customer-name">${orderInfo.full_name}</span></div>
                                    <div style="margin-bottom: 8px;"><strong
                                            style="display: inline-block; width: 180px;">Email:</strong> <span
                                            id="modal-customer-email">${orderInfo.email}</span></div>
                                    <div style="margin-bottom: 8px;"><strong
                                            style="display: inline-block; width: 180px;">Điện thoại:</strong> <span
                                            id="modal-customer-phone">${orderInfo.phone_number}</span></div>
                                    <div style="margin-bottom: 8px;"><strong
                                            style="display: inline-block; width: 180px;">Địa chỉ:</strong> <span
                                            id="modal-customer-address">${orderInfo.specific_address},
                                            ${orderInfo.ward}, ${orderInfo.city}</span></div>
                                    <div style="margin-bottom: 8px;"><strong
                                            style="display: inline-block; width: 180px;">Ghi chú:</strong> <span
                                            id="modal-note">${orderInfo.note}</span></div>
                                    <div style="margin-bottom: 8px;"><strong
                                            style="display: inline-block; width: 180px;">Hình thức thanh toán:</strong>
                                        <span id="modal-payment">${orderInfo.pay_strategy}</span>
                                    </div>
                                </div>
                            </div>

                            <!-- Products -->
                            <div class="section" style="margin-bottom: 30px;">
                                <h3
                                    style="color: #a94442; font-size: 16px; margin-bottom: 15px; font-weight: bold; text-transform: uppercase;">
                                    Sản phẩm</h3>
                                <table
                                    style="width: 100%; border-collapse: collapse; font-size: 14px; border: 1px solid #eee;">
                                    <thead>
                                        <tr style="background-color: #f5f5f5; text-align: left;">
                                            <th
                                                style="padding: 12px 15px; border-bottom: 1px solid #ddd; font-weight: bold; color: #333;">
                                                Hình ảnh</th>
                                            <th
                                                style="padding: 12px 15px; border-bottom: 1px solid #ddd; font-weight: bold; color: #333;">
                                                Sản phẩm</th>
                                            <th
                                                style="padding: 12px 15px; border-bottom: 1px solid #ddd; font-weight: bold; color: #333;">
                                                Số lượng</th>
                                            <th
                                                style="padding: 12px 15px; border-bottom: 1px solid #ddd; font-weight: bold; color: #333;">
                                                Đơn giá</th>
                                            <th
                                                style="padding: 12px 15px; border-bottom: 1px solid #ddd; font-weight: bold; color: #333;">
                                                Tổng</th>
                                        </tr>
                                    </thead>
                                    <tbody id="modal-items-body">
                                        <c:if test="${not empty orderItems}">
                                            <c:forEach items="${orderItems}" var="item">
                                                <tr>
                                                    <td style="padding: 10px; border-bottom: 1px solid #eee;">
                                                        <img src="${pageContext.request.contextPath}/${item.url_img}"
                                                            alt="${item.product_name}"
                                                            style="width:60px;height:110px;object-fit:cover;border-radius:4px;">
                                                    </td>
                                                    <td style="padding: 10px; border-bottom: 1px solid #eee;">
                                                        ${item.product_name}</td>
                                                    <td style="padding: 10px; border-bottom: 1px solid #eee;">
                                                        ${item.quantity}</td>
                                                    <td style="padding: 10px; border-bottom: 1px solid #eee;">
                                                        <fmt:formatNumber value="${item.unit_price}" type="currency"
                                                            currencySymbol="₫" />
                                                    </td>
                                                    <td style="padding: 10px; border-bottom: 1px solid #eee;">
                                                        <fmt:formatNumber value="${item.quantity * item.unit_price}"
                                                            type="currency" currencySymbol="₫" />
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                        </c:if>
                                    </tbody>
                                    <tfoot>
                                        <tr>
                                            <td colspan="4"
                                                style="text-align:right; padding: 15px 15px; font-weight: bold; color: #333; border-top: 1px solid #eee;">
                                                Tổng cộng:</td>
                                            <td id="modal-total-price"
                                                style="padding: 15px 15px; font-weight: bold; color: #333; border-top: 1px solid #eee;">
                                                <fmt:formatNumber value="${orderInfo.total_price}" type="currency"
                                                    currencySymbol="₫" />
                                            </td>
                                        </tr>
                                    </tfoot>
                                </table>
                            </div>

                            <!-- Order Status & Progress -->
                            <div class="section">
                                <h3
                                    style="color: #a94442; font-size: 16px; margin-bottom: 15px; font-weight: bold; text-transform: uppercase;">
                                    Trạng thái đơn hàng</h3>

                                <!-- Status Badge -->
                                <div style="margin-bottom: 20px;">
                                    <span id="modal-status-badge"
                                        style="background-color: #28a745; color: white; padding: 5px 10px; border-radius: 4px; font-weight: bold; font-size: 12px; text-transform: uppercase;">Đang
                                        Xử Lý</span>
                                </div>

                                <!-- Progress Bar -->
                                <div class="progress-track"
                                    style="margin-bottom: 40px; position: relative; height: 5px; background-color: #eee; margin-top: 30px; border-radius: 5px;">
                                    <div id="progress-bar-fill"
                                        style="height: 100%; background-color: #28a745; width: 0%; border-radius: 5px; transition: width 0.3s;">
                                    </div>

                                    <div
                                        style="position: absolute; top: -10px; left: 0; width: 100%; display: flex; justify-content: space-between;">
                                        <div class="step-dot" id="dot-processing"
                                            style="width: 25px; height: 25px; background-color: #ddd; border-radius: 50%; display: flex; align-items: center; justify-content: center; color: white; font-size: 12px; position: relative;">
                                            <span
                                                style="position: absolute; bottom: -25px; color: #999; font-size: 12px; white-space: nowrap;">Đang
                                                xử lý</span>
                                        </div>
                                        <div class="step-dot" id="dot-shipping"
                                            style="width: 25px; height: 25px; background-color: #ddd; border-radius: 50%; display: flex; align-items: center; justify-content: center; color: white; font-size: 12px; position: relative;">
                                            <span
                                                style="position: absolute; bottom: -25px; color: #999; font-size: 12px; white-space: nowrap;">Đang
                                                giao</span>
                                        </div>
                                        <div class="step-dot" id="dot-delivered"
                                            style="width: 25px; height: 25px; background-color: #ddd; border-radius: 50%; display: flex; align-items: center; justify-content: center; color: white; font-size: 12px; position: relative;">
                                            <span
                                                style="position: absolute; bottom: -25px; color: #999; font-size: 12px; white-space: nowrap;">Giao thành
                                                công</span>
                                        </div>
                                    </div>
                                </div>
                                <div style="display: flex; justify-content: flex-end; align-items: center; gap: 10px; border-top: 1px solid #eee; padding-top: 20px; flex-wrap: wrap;">
                                    <form id="update-order-form"
                                        action="<%=request.getContextPath()%>/admin/update-order" method="post"
                                        style="display: flex; align-items: center; gap: 10px; margin: 0;"
                                        onsubmit="event.preventDefault(); showCustomConfirm('Bạn có chắc chắn muốn thay đổi trạng thái của đơn hàng này?', () => this.submit());">
                                        <input type="hidden" id="update-order-id" name="id">
                                        <select name="statusSelect" id="modal-status-select"
                                            style="padding: 8px 15px; border-radius: 4px; border: 1px solid #ddd; background-color: #eee; color: #333; cursor: pointer; font-weight: bold; margin-right: 10px;">
                                            <option value="Chuẩn bị đơn hàng">Chuẩn bị đơn hàng</option>
                                            <option value="Đang xử lý">Đang xử lý</option>
                                            <option value="Đang giao hàng">Đang giao hàng</option>
                                            <option value="Giao hàng thành công">Giao hàng thành công</option>
                                            <option value="Đã hủy">Đã hủy</option>
                                            <option value="Thanh toán thất bại">Thanh toán thất bại</option>
                                        </select>
                                        <button type="submit" id="update-order-btn" class="fix-btn element-button"
                                            style="padding: -2px 25px; background-color: #a94442; color: white; border: none; border-radius: 4px; cursor: pointer; font-weight: bold; font-size: 13px; text-transform: uppercase; box-shadow: none;">
                                            Cập nhật
                                        </button>
                                    </form>
                                    <button type="button" id="btn-refund-order"
                                        onclick="openRefundModal()"
                                        style="padding: 10px 20px; background-color: #f1f5f9; color: #334155; border: 1px solid #cbd5e1; border-radius: 4px; cursor: pointer; font-weight: bold; font-size: 13px; text-transform: uppercase; transition: background-color 0.2s;"
                                        onmouseover="this.style.backgroundColor='#e2e8f0'" onmouseout="this.style.backgroundColor='#f1f5f9'">
                                        Hoàn tiền
                                    </button>
                                    <button type="button" id="btn-feedback-order"
                                        onclick="openFeedbackModal()"
                                        style="padding: 10px 20px; background-color: #f1f5f9; color: #334155; border: 1px solid #cbd5e1; border-radius: 4px; cursor: pointer; font-weight: bold; font-size: 13px; text-transform: uppercase; transition: background-color 0.2s;"
                                        onmouseover="this.style.backgroundColor='#e2e8f0'" onmouseout="this.style.backgroundColor='#f1f5f9'">
                                        Phản hồi
                                    </button>
                                    <button type="button"
                                        onclick="window.open('${pageContext.request.contextPath}/admin/print-invoice?id=' + document.getElementById('update-order-id').value, '_blank')"
                                        style="padding: 10px 20px; background-color: #f1f5f9; color: #334155; border: 1px solid #cbd5e1; border-radius: 4px; cursor: pointer; font-weight: bold; font-size: 13px; text-transform: uppercase; transition: background-color 0.2s;"
                                        onmouseover="this.style.backgroundColor='#e2e8f0'" onmouseout="this.style.backgroundColor='#f1f5f9'">
                                        In hóa đơn
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="modal-overlay-notification" id="notification-order-modal">
                    <div class="modal-content-notification">
                        <div class="group-notification">
                            <h2 class="notification-title">Thông báo</h2>
                            <button class="modal-close" id="close-modal-btn8">
                                <ion-icon name="close-outline"></ion-icon>
                            </button>
                        </div>
                        <div class="notification-empty-state">
                            <ion-icon name="notifications-off-outline"></ion-icon>
                            <p>Hiện tại chưa có thông báo mới</p>
                        </div>
                    </div>
                </div>

                <!-- Custom Alert Modal -->
                <div class="modal-overlay" id="custom-alert-modal">
                    <div class="modal-content" style="max-width: 400px; text-align: center; padding: 30px;">
                        <h2 style="color: #dc3545; font-size: 24px; font-weight: bold; margin-bottom: 20px;">Thông báo</h2>
                        <p id="custom-alert-message" style="font-size: 16px; color: #333; margin-bottom: 30px;"></p>
                        <button onclick="closeCustomAlert()" class="button add" style="width: 100%; justify-content: center; background: #28a745; color: white; border: none; border-radius: 8px; padding: 12px 0; font-size: 16px; font-weight: bold; cursor: pointer;">Đóng</button>
                    </div>
                </div>

                <!-- Custom Confirm Modal -->
                <div class="modal-overlay" id="custom-confirm-modal">
                    <div class="modal-content" style="max-width: 400px; text-align: center; padding: 30px;">
                        <h2 style="color: #a94442; font-size: 24px; font-weight: bold; margin-bottom: 20px;">Xác nhận</h2>
                        <p id="custom-confirm-message" style="font-size: 16px; color: #333; margin-bottom: 30px;"></p>
                        <div style="display: flex; gap: 15px; justify-content: center;">
                            <button onclick="closeCustomConfirm()" class="button" style="flex: 1; justify-content: center; background: #6c757d; color: white; border: none; border-radius: 8px; padding: 12px 0; font-size: 16px; font-weight: bold; cursor: pointer;">Hủy</button>
                            <button id="custom-confirm-btn" class="button add" style="flex: 1; justify-content: center; background: #dc3545; color: white; border: none; border-radius: 8px; padding: 12px 0; font-size: 16px; font-weight: bold; cursor: pointer;">Xác nhận</button>
                        </div>
                    </div>
                </div>

                <!-- Edit Order Modal -->
                <div class="modal-overlay" id="editOrderModal">
                    <div class="modal-content" style="width: 600px; max-width: 95vw; padding: 30px;">
                        <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:20px;">
                            <h2 style="color: #a94442; margin: 0;">Chỉnh sửa đơn hàng #<span id="edit-order-id-display"></span></h2>
                            <span onclick="closeEditModal()" style="font-size:28px;cursor:pointer;color:#aaa;">&times;</span>
                        </div>
                        <input type="hidden" id="edit-order-id">
                        <div style="margin-bottom:15px;">
                            <label style="font-weight:bold;display:block;margin-bottom:5px;">Ghi chú đơn hàng</label>
                            <textarea id="edit-note" rows="3" style="width:100%;padding:10px;border:1px solid #ddd;border-radius:6px;font-size:14px;box-sizing:border-box;"></textarea>
                        </div>
                        <div style="margin-bottom:15px;">
                            <label style="font-weight:bold;display:block;margin-bottom:5px;">Đơn vị vận chuyển</label>
                            <input type="text" id="edit-carrier" style="width:100%;padding:10px;border:1px solid #ddd;border-radius:6px;font-size:14px;box-sizing:border-box;">
                        </div>
                        <div style="margin-bottom:20px;">
                            <label style="font-weight:bold;display:block;margin-bottom:5px;">Phí vận chuyển (₫)</label>
                            <input type="number" id="edit-shipping-fee" min="0" style="width:100%;padding:10px;border:1px solid #ddd;border-radius:6px;font-size:14px;box-sizing:border-box;">
                        </div>
                        <div style="display:flex;gap:10px;justify-content:flex-end;">
                            <button onclick="closeEditModal()" style="padding:10px 25px;background:#6c757d;color:#fff;border:none;border-radius:6px;cursor:pointer;font-weight:bold;">Hủy</button>
                            <button onclick="submitEditOrder()" style="padding:10px 25px;background:#28a745;color:#fff;border:none;border-radius:6px;cursor:pointer;font-weight:bold;">Lưu thay đổi</button>
                        </div>
                    </div>
                </div>

                <!-- Refund Modal -->
                <div class="modal-overlay" id="refundModal">
                    <div class="modal-content" style="max-width: 450px; padding: 30px; text-align: center;">
                        <h2 style="color: #17a2b8; font-size: 22px; margin-bottom: 20px;">Hoàn tiền đơn hàng</h2>
                        <p style="font-size:14px;color:#666;margin-bottom:15px;">Đơn hàng #<strong id="refund-order-id-display"></strong></p>
                        <input type="hidden" id="refund-order-id">
                        <div style="text-align:left;margin-bottom:15px;">
                            <label style="font-weight:bold;display:block;margin-bottom:5px;">Lý do hoàn tiền</label>
                            <textarea id="refund-reason" rows="3" placeholder="Nhập lý do hoàn tiền..." style="width:100%;padding:10px;border:1px solid #ddd;border-radius:6px;font-size:14px;box-sizing:border-box;"></textarea>
                        </div>
                        <div style="display:flex;gap:15px;justify-content:center;">
                            <button onclick="closeRefundModal()" style="flex:1;padding:12px;background:#6c757d;color:#fff;border:none;border-radius:8px;cursor:pointer;font-weight:bold;">Hủy</button>
                            <button onclick="submitRefund()" style="flex:1;padding:12px;background:#17a2b8;color:#fff;border:none;border-radius:8px;cursor:pointer;font-weight:bold;">Xác nhận hoàn tiền</button>
                        </div>
                    </div>
                </div>

                <!-- Feedback Modal -->
                <div class="modal-overlay" id="feedbackModal">
                    <div class="modal-content" style="max-width: 500px; padding: 30px;">
                        <h2 style="color: #6f42c1; font-size: 22px; margin-bottom: 20px; text-align: center;">Gửi phản hồi cho khách hàng</h2>
                        <p style="font-size:14px;color:#666;margin-bottom:15px;text-align:center;">Đơn hàng #<strong id="feedback-order-id-display"></strong> — <span id="feedback-customer-email"></span></p>
                        <input type="hidden" id="feedback-order-id">
                        <div style="margin-bottom:15px;">
                            <label style="font-weight:bold;display:block;margin-bottom:5px;">Tiêu đề</label>
                            <input type="text" id="feedback-subject" value="Phản hồi về đơn hàng" style="width:100%;padding:10px;border:1px solid #ddd;border-radius:6px;font-size:14px;box-sizing:border-box;">
                        </div>
                        <div style="margin-bottom:20px;">
                            <label style="font-weight:bold;display:block;margin-bottom:5px;">Nội dung phản hồi <span style="color:red;">*</span></label>
                            <textarea id="feedback-content" rows="5" placeholder="Nhập nội dung phản hồi tới khách hàng..." style="width:100%;padding:10px;border:1px solid #ddd;border-radius:6px;font-size:14px;box-sizing:border-box;"></textarea>
                        </div>
                        <div style="display:flex;gap:15px;justify-content:center;">
                            <button onclick="closeFeedbackModal()" style="flex:1;padding:12px;background:#6c757d;color:#fff;border:none;border-radius:8px;cursor:pointer;font-weight:bold;">Hủy</button>
                            <button onclick="submitFeedback()" style="flex:1;padding:12px;background:#6f42c1;color:#fff;border:none;border-radius:8px;cursor:pointer;font-weight:bold;">Gửi phản hồi</button>
                        </div>
                    </div>
                </div>
                <script type="module" src="https://unpkg.com/ionicons@7.1.0/dist/ionicons/ionicons.esm.js"></script>
                <script nomodule src="https://unpkg.com/ionicons@7.1.0/dist/ionicons/ionicons.js"></script>
                <link href="https://fonts.googleapis.com/css2?family=Philosopher&display=swap" rel="stylesheet">
                <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
                <link rel="stylesheet" href="https://cdn.datatables.net/2.3.4/css/dataTables.dataTables.css" />
                <script src="https://cdn.datatables.net/2.3.4/js/dataTables.js"></script>
                <script src="../popup.js"></script>
                <script>
                    let customAlertCallback = null;
                    function showCustomAlert(message, callback) {
                        document.getElementById('custom-alert-message').textContent = message;
                        document.getElementById('custom-alert-modal').classList.add('show');
                        customAlertCallback = callback;
                    }
                    function closeCustomAlert() {
                        document.getElementById('custom-alert-modal').classList.remove('show');
                        if (customAlertCallback) {
                            customAlertCallback();
                            customAlertCallback = null;
                        }
                    }

                    let customConfirmCallback = null;
                    function showCustomConfirm(message, callback) {
                        document.getElementById('custom-confirm-message').textContent = message;
                        document.getElementById('custom-confirm-modal').classList.add('show');
                        customConfirmCallback = callback;
                    }
                    function closeCustomConfirm() {
                        document.getElementById('custom-confirm-modal').classList.remove('show');
                        customConfirmCallback = null;
                    }
                    document.addEventListener("DOMContentLoaded", function () {
                        document.getElementById('custom-confirm-btn').addEventListener('click', function() {
                            document.getElementById('custom-confirm-modal').classList.remove('show');
                            if (customConfirmCallback) {
                                customConfirmCallback();
                                customConfirmCallback = null;
                            }
                        });
                    });

                    // Initialize DataTable
                    $(document).ready(function () {
                        var table = $('#order-table-main').DataTable({
                            language: {
                                url: 'https://cdn.datatables.net/plug-ins/2.3.5/i18n/vi.json',
                            },
                            order: [[1, 'desc']] // Sort by ID descending by default
                        });

                        // Select all checkbox
                        $('#select-all-checkbox').on('change', function () {
                            table.$('input.row-checkbox').prop('checked', this.checked);
                        });

                        // Date helper to parse dd/MM/yyyy
                        function parseDateDMY(dateStr) {
                            if (!dateStr) return null;
                            var parts = dateStr.trim().split('/');
                            if (parts.length === 3) {
                                return new Date(parts[2], parts[1] - 1, parts[0]);
                            }
                            return null;
                        }

                        // Date helper to parse yyyy-MM-dd
                        function parseDateYMD(dateStr) {
                            if (!dateStr) return null;
                            var parts = dateStr.trim().split('-');
                            if (parts.length === 3) {
                                return new Date(parts[0], parts[1] - 1, parts[2]);
                            }
                            return null;
                        }

                        // Custom DataTables filter logic
                        $.fn.dataTable.ext.search.push(
                            function(settings, data, dataIndex) {
                                // Customer name/email filter (Column 2)
                                var filterCustomer = $('#filter-customer').val().toLowerCase().trim();
                                var customerName = data[2] ? data[2].toLowerCase() : '';
                                if (filterCustomer !== '' && !customerName.includes(filterCustomer)) {
                                    return false;
                                }

                                // Status filter (Column 6)
                                var filterStatus = $('#filter-status').val();
                                var statusText = data[6] ? data[6].trim() : '';
                                if (filterStatus !== '' && statusText.toLowerCase() !== filterStatus.toLowerCase()) {
                                    return false;
                                }

                                // Date range filter (Column 3)
                                var filterFrom = $('#filter-from-date').val();
                                var filterTo = $('#filter-to-date').val();
                                var dateStr = data[3] ? data[3].trim() : '';

                                if (filterFrom || filterTo) {
                                    var orderDate = parseDateDMY(dateStr);
                                    if (!orderDate) return false;

                                    if (filterFrom) {
                                        var fromDate = parseDateYMD(filterFrom);
                                        if (fromDate && orderDate < fromDate) {
                                            return false;
                                        }
                                    }

                                    if (filterTo) {
                                        var toDate = parseDateYMD(filterTo);
                                        if (toDate && orderDate > toDate) {
                                            return false;
                                        }
                                    }
                                }

                                return true;
                            }
                        );

                        // Redraw table when inputs change
                        $('#filter-customer, #filter-status, #filter-from-date, #filter-to-date').on('keyup change', function() {
                            table.draw();
                        });

                        // Reset filter fields
                        $('#btn-reset-filter').on('click', function() {
                            $('#filter-customer').val('');
                            $('#filter-status').val('');
                            $('#filter-from-date').val('');
                            $('#filter-to-date').val('');
                            table.draw();
                        });
                    });

                    // Run Pop-up function
                    document.addEventListener("DOMContentLoaded", function () {
                        setupModal('add-order-modal', 'open-modal-btn', 'close-modal-btn');
                        setupModal('excel-order-modal', 'excel-modal-btn', 'close-modal-btn5');
                        setupModal('deleteAll-order-modal', 'deleteAll-modal-btn', 'close-modal-btn6');
                        setupModal('notification-order-modal', 'notification-modal-btn', 'close-modal-btn8');
                        setupModal('avatar-order-modal', 'avatar-modal-btn', 'close-modal-btn9');

                        const orderDetailModal = document.getElementById('orderDetailModal');
                        const closeOrderDetailBtn = document.getElementById('closeOrderDetailModal');

                        if (closeOrderDetailBtn && orderDetailModal) {
                            closeOrderDetailBtn.addEventListener('click', () => {
                                orderDetailModal.classList.remove('show');
                            });
                        }

                        if (orderDetailModal) {
                            orderDetailModal.addEventListener('click', (e) => {
                                if (e.target === orderDetailModal) {
                                    orderDetailModal.classList.remove('show');
                                }
                            });
                        }

                        document.addEventListener('keydown', (event) => {
                            if (event.key === 'Escape' && orderDetailModal && orderDetailModal.classList.contains('show')) {
                                orderDetailModal.classList.remove('show');
                            }
                        });

                        // Add Order AJAX
                        $('#add-form').submit(function (e) {
                            e.preventDefault();
                            var formData = $(this).serialize();
                            fetch('${pageContext.request.contextPath}/admin/add-order', {
                                method: 'POST',
                                headers: {
                                    'Content-Type': 'application/x-www-form-urlencoded',
                                },
                                body: formData
                            }).then(response => response.json())
                                .then(data => {
                                    if (data.success) {
                                        showCustomAlert(data.message, () => window.location.reload());
                                    } else {
                                        showCustomAlert(data.message);
                                    }
                                }).catch(error => {
                                    console.error('Error:', error);
                                    showCustomAlert('Lỗi kết nối tới server.');
                                });
                        });



                        // Bulk Delete Logic
                        $('.deleteAll-button').click(function (e) {
                            e.preventDefault();
                            var ids = [];
                            // Access DataTable instance safely
                            var table = $('#order-table-main').DataTable();
                            table.$('input.row-checkbox:checked').each(function () {
                                ids.push($(this).val());
                            });

                            if (ids.length === 0) {
                                showCustomAlert("Vui lòng chọn ít nhất một đơn hàng!");
                                document.getElementById('deleteAll-order-modal').classList.remove('show');
                                return;
                            }

                            fetch('${pageContext.request.contextPath}/admin/delete-order', {
                                method: 'POST',
                                headers: {
                                    'Content-Type': 'application/x-www-form-urlencoded',
                                },
                                body: 'ids=' + ids.join(',')
                            }).then(response => response.json())
                                .then(data => {
                                    if (data.success) {
                                        showCustomAlert(data.message, () => window.location.reload());
                                    } else {
                                        showCustomAlert(data.message);
                                    }
                                }).catch(error => {
                                    console.error('Error:', error);
                                    showCustomAlert("Lỗi kết nối tới server.");
                                });
                        });
                    });

                    function confirmDelete(id) {
                        showCustomConfirm('Bạn có chắc chắn muốn xóa đơn hàng này?', () => {
                            // Call delete API
                            fetch('${pageContext.request.contextPath}/admin/delete-order', {
                                method: 'POST',
                                headers: {
                                    'Content-Type': 'application/x-www-form-urlencoded',
                                },
                                body: 'ids=' + id
                            }).then(response => response.json())
                                .then(data => {
                                    if (data.success) {
                                        showCustomAlert(data.message, () => window.location.reload());
                                    } else {
                                        showCustomAlert(data.message);
                                    }
                                }).catch(error => {
                                    console.error('Error:', error);
                                    showCustomAlert("Lỗi kết nối tới server.");
                                });
                        });
                    }

                    function openViewModal(id) {
                        location.href = '${pageContext.request.contextPath}/admin/get-order?id=' + id;
                    }

                    // Phase 1: Edit Order Modal
                    function openEditModal(id) {
                        document.getElementById('edit-order-id').value = id;
                        document.getElementById('edit-order-id-display').textContent = id;
                        document.getElementById('edit-note').value = '';
                        document.getElementById('edit-carrier').value = '';
                        document.getElementById('edit-shipping-fee').value = '0';
                        document.getElementById('editOrderModal').classList.add('show');
                    }
                    function closeEditModal() {
                        document.getElementById('editOrderModal').classList.remove('show');
                    }
                    function submitEditOrder() {
                        const orderId = document.getElementById('edit-order-id').value;
                        const note = document.getElementById('edit-note').value;
                        const carrier = document.getElementById('edit-carrier').value;
                        const shippingFee = document.getElementById('edit-shipping-fee').value;

                        const params = {
                            orderId: orderId,
                            note: note,
                            carrierName: carrier,
                            shippingFee: shippingFee
                        };
                        submitPostForm('${pageContext.request.contextPath}/admin/edit-order', params);
                    }

                    // Phase 3: Refund Modal
                    function openRefundModal() {
                        const orderId = document.getElementById('update-order-id').value;
                        document.getElementById('refund-order-id').value = orderId;
                        document.getElementById('refund-order-id-display').textContent = orderId;
                        document.getElementById('refund-reason').value = '';
                        document.getElementById('refundModal').classList.add('show');
                    }
                    function closeRefundModal() {
                        document.getElementById('refundModal').classList.remove('show');
                    }
                    function submitRefund() {
                        const orderId = document.getElementById('refund-order-id').value;
                        const reason = document.getElementById('refund-reason').value;

                        submitPostForm('${pageContext.request.contextPath}/admin/refund-order', { orderId: orderId, reason: reason });
                    }

                    // Phase 4: Feedback Modal
                    function openFeedbackModal() {
                        const orderId = document.getElementById('update-order-id').value;
                        document.getElementById('feedback-order-id').value = orderId;
                        document.getElementById('feedback-order-id-display').textContent = orderId;
                        const emailEl = document.getElementById('modal-customer-email');
                        document.getElementById('feedback-customer-email').textContent = emailEl ? emailEl.textContent : '';
                        document.getElementById('feedback-subject').value = 'Phản hồi về đơn hàng';
                        document.getElementById('feedback-content').value = '';
                        document.getElementById('feedbackModal').classList.add('show');
                    }
                    function closeFeedbackModal() {
                        document.getElementById('feedbackModal').classList.remove('show');
                    }
                    function submitFeedback() {
                        const orderId = document.getElementById('feedback-order-id').value;
                        const subject = document.getElementById('feedback-subject').value;
                        const content = document.getElementById('feedback-content').value;

                        if (!content.trim()) {
                            showCustomAlert('Nội dung phản hồi không được để trống!');
                            return;
                        }

                        submitPostForm('${pageContext.request.contextPath}/admin/send-feedback', { orderId: orderId, subject: subject, content: content });
                    }

                    function submitPostForm(action, params) {
                        const form = document.createElement('form');
                        form.method = 'POST';
                        form.action = action;
                        for (const key in params) {
                            if (params.hasOwnProperty(key) && params[key] !== null && params[key] !== '') {
                                const input = document.createElement('input');
                                input.type = 'hidden';
                                input.name = key;
                                input.value = params[key];
                                form.appendChild(input);
                            }
                        }
                        document.body.appendChild(form);
                        form.submit();
                    }

                    // Close modals on overlay click
                    ['editOrderModal', 'refundModal', 'feedbackModal'].forEach(function(id) {
                        const el = document.getElementById(id);
                        if (el) {
                            el.addEventListener('click', function(e) {
                                if (e.target === el) el.classList.remove('show');
                            });
                        }
                    });
                </script>

                <c:if test="${not empty orderInfo}">
                    <script>
                        $(document).ready(function () {
                            const updateOrderIdInput = document.getElementById('update-order-id');
                            if (updateOrderIdInput) {
                                updateOrderIdInput.value = '${orderInfo.id}';
                            }

                            const status = '${orderInfo.ship_status}' || 'Đang xử lý';
                            const statusSelect = document.getElementById('modal-status-select');
                            const hasUpsertPerm = ${sessionScope.userPermissions != null && sessionScope.userPermissions.contains('orders:upsert') ? 'true' : 'false'};
                            if (statusSelect) {
                                const matchedOption = Array.from(statusSelect.options).find(option => option.value === status);
                                if (matchedOption) {
                                    statusSelect.value = status;
                                }

                                const statusOrder = ['Đang xử lý', 'Chuẩn bị đơn hàng', 'Đang giao hàng', 'Giao hàng thành công'];
                                const currentIndex = statusOrder.indexOf(status);

                                Array.from(statusSelect.options).forEach(opt => {
                                    if (status === 'Đã hủy') {
                                        opt.disabled = false;
                                        opt.style.color = '#333';
                                    } else {
                                        if (opt.value === 'Đã hủy' || opt.value === 'Thanh toán thất bại') {
                                            if (status === 'Giao hàng thành công' || status === 'Đã giao') {
                                                opt.disabled = true;
                                                opt.style.color = '#aaa';
                                            } else {
                                                opt.disabled = false;
                                                opt.style.color = '#333';
                                            }
                                        } else {
                                            const optIndex = statusOrder.indexOf(opt.value);
                                            if (optIndex >= currentIndex) {
                                                opt.disabled = false;
                                                opt.style.color = '#333';
                                            } else {
                                                opt.disabled = true;
                                                opt.style.color = '#aaa';
                                            }
                                        }
                                    }
                                });
                                statusSelect.options[statusSelect.selectedIndex].style.color = '#333';

                                const updateBtn = document.getElementById('update-order-btn');
                                const isCompleted = (status === 'Đã hủy' || status === 'Thanh toán thất bại' || status === 'Giao hàng thành công' || status === 'Đã giao' || status === 'Đã xóa');

                                if (!hasUpsertPerm || isCompleted) {
                                    if (updateBtn) updateBtn.style.display = 'none';
                                    statusSelect.disabled = true;
                                } else {
                                    if (updateBtn) updateBtn.style.display = 'block';
                                    statusSelect.disabled = false;
                                }
                            }

                            const badge = document.getElementById('modal-status-badge');
                            const progressBar = document.getElementById('progress-bar-fill');
                            const dots = {
                                processing: document.getElementById('dot-processing'),
                                shipping: document.getElementById('dot-shipping'),
                                delivered: document.getElementById('dot-delivered')
                            };

                            const highlightDot = (dot, color) => {
                                if (!dot) return;
                                dot.style.backgroundColor = color;
                                dot.style.color = '#fff';
                            };

                            Object.values(dots).forEach(dot => {
                                if (!dot) return;
                                dot.style.backgroundColor = '#ddd';
                                dot.style.color = '#fff';
                            });

                            badge.textContent = status;
                            badge.style.color = 'white';
                            progressBar.style.width = '0%';

                            if (status === 'Chuẩn bị đơn hàng') {
                                badge.style.backgroundColor = '#fd7e14';
                                progressBar.style.width = '10%';
                                highlightDot(dots.processing, '#fd7e14');
                            } else if (status === 'Đang xử lý') {
                                badge.style.backgroundColor = '#6c757d';
                                progressBar.style.width = '30%';
                                highlightDot(dots.processing, '#6c757d');
                            } else if (status === 'Đang giao hàng') {
                                badge.style.backgroundColor = '#28a745';
                                progressBar.style.width = '70%';
                                highlightDot(dots.processing, '#28a745');
                                highlightDot(dots.shipping, '#28a745');
                            } else if (status === 'Giao hàng thành công' || status === 'Đã giao') {
                                badge.style.backgroundColor = '#28a745';
                                progressBar.style.width = '100%';
                                highlightDot(dots.processing, '#28a745');
                                highlightDot(dots.shipping, '#28a745');
                                highlightDot(dots.delivered, '#28a745');
                            } else if (status === 'Đã hủy' || status === 'Thanh toán thất bại') {
                                badge.style.backgroundColor = '#dc3545';
                            } else {
                                badge.style.backgroundColor = '#6c757d';
                            }

                            const modal = document.getElementById('orderDetailModal');

                            // Hiển thị trạng thái thanh toán
                            const paymentStatusEl = document.getElementById('modal-payment-status');
                            if (paymentStatusEl) {
                                const payStatus = '${orderInfo.payment_status}' || 'N/A';
                                paymentStatusEl.textContent = payStatus;
                                if (payStatus === 'Đã thanh toán' || payStatus === 'Success' || payStatus === 'Completed') {
                                    paymentStatusEl.style.backgroundColor = '#28a745';
                                    paymentStatusEl.style.color = '#fff';
                                } else if (payStatus === 'Đã hoàn tiền') {
                                    paymentStatusEl.style.backgroundColor = '#17a2b8';
                                    paymentStatusEl.style.color = '#fff';
                                } else if (payStatus === 'Pending' || payStatus === 'Chờ thanh toán') {
                                    paymentStatusEl.style.backgroundColor = '#ffc107';
                                    paymentStatusEl.style.color = '#333';
                                } else if (payStatus === 'Expired' || payStatus === 'Failed') {
                                    paymentStatusEl.style.backgroundColor = '#dc3545';
                                    paymentStatusEl.style.color = '#fff';
                                } else {
                                    paymentStatusEl.style.backgroundColor = '#6c757d';
                                    paymentStatusEl.style.color = '#fff';
                                }
                            }

                            if (modal) {
                                modal.classList.add('show');
                            }
                        });
                    </script>
                </c:if>
            </body>

            </html>