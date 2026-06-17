<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta charset="UTF-8">
    <title>Chi Tiết Tài Khoản - ${userDetail.fullName}</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/admin/admin_css/manage_accounts.css">
    <script type="module" src="https://unpkg.com/ionicons@7.1.0/dist/ionicons/ionicons.esm.js"></script>
    <script nomodule src="https://unpkg.com/ionicons@7.1.0/dist/ionicons/ionicons.js"></script>
    <link href="https://fonts.googleapis.com/css2?family=Philosopher&display=swap" rel="stylesheet">
    <style>
        .detail-container {
            background-color: #fff;
            border-radius: 8px;
            padding: 30px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.05);
            margin-bottom: 20px;
        }
        .detail-container h3 {
            color: #8c3333;
            border-bottom: 2px solid #c7a17a;
            padding-bottom: 10px;
            margin-bottom: 20px;
            font-size: 22px;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        .info-grid {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 20px;
        }
        .info-item {
            background: #f9f9f9;
            padding: 15px;
            border-radius: 6px;
            border-left: 4px solid #c7a17a;
        }
        .info-item label {
            font-weight: bold;
            color: #555;
            display: block;
            margin-bottom: 5px;
            font-size: 14px;
        }
        .info-item p {
            margin: 0;
            font-size: 16px;
            color: #333;
        }
        
        .address-card, .order-card {
            background: #f9f9f9;
            border: 1px solid #eee;
            border-radius: 8px;
            padding: 20px;
            margin-bottom: 15px;
            transition: transform 0.2s;
        }
        .address-card:hover, .order-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 10px rgba(0,0,0,0.05);
        }
        .address-card p { margin: 5px 0; }
        .is-default-badge {
            background-color: #c7a17a;
            color: white;
            padding: 3px 8px;
            border-radius: 12px;
            font-size: 12px;
            font-weight: bold;
            display: inline-block;
            margin-bottom: 10px;
        }
        
        .order-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-bottom: 1px solid #ddd;
            padding-bottom: 10px;
            margin-bottom: 15px;
        }
        .order-header h4 { margin: 0; color: #333; font-size: 18px; }
        .order-date { color: #888; font-size: 14px; }
        .order-item-row {
            display: flex;
            align-items: center;
            gap: 15px;
            margin-bottom: 15px;
            border-bottom: 1px dashed #eee;
            padding-bottom: 15px;
        }
        .order-item-row:last-child {
            border-bottom: none;
            padding-bottom: 0;
            margin-bottom: 0;
        }
        .order-img {
            width: 60px;
            height: 60px;
            object-fit: contain;
            border-radius: 4px;
            border: 1px solid #ddd;
        }
        .order-details { flex-grow: 1; }
        .order-details h5 { margin: 0 0 5px 0; font-size: 15px; }
        .order-details p { margin: 0; color: #666; font-size: 14px; }
        .order-total {
            text-align: right;
            font-size: 18px;
            font-weight: bold;
            color: #d8000c;
            margin-top: 15px;
            border-top: 1px solid #ddd;
            padding-top: 15px;
        }
        
        .btn-back {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            background-color: #555;
            color: white;
            padding: 10px 20px;
            border-radius: 6px;
            text-decoration: none;
            font-weight: bold;
            margin-bottom: 20px;
            transition: background 0.3s;
        }
        .btn-back:hover { background-color: #333; }
        
        .empty-state {
            text-align: center;
            padding: 30px;
            color: #888;
            font-style: italic;
            background: #f9f9f9;
            border-radius: 8px;
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
            <c:set var="activePage" value="account" scope="request" />
            <%@ include file="/admin/components/sidebar_items_component.jsp" %>
        </ul>
        <div class="text">━ Được update tới 2025 ━</div>
    </nav>
    
    <div class="dashboard-content">
        <main class="dashboard-main-content">
            <a href="${pageContext.request.contextPath}/account-manager" class="btn-back">
                <ion-icon name="arrow-back-outline"></ion-icon> Quay lại danh sách
            </a>
            
            <div class="detail-container">
                <h3><ion-icon name="person-circle-outline"></ion-icon> Thông Tin Tài Khoản</h3>
                <div class="info-grid">
                    <div class="info-item">
                        <label>ID Khách Hàng</label>
                        <p>#${userDetail.id}</p>
                    </div>
                    <div class="info-item">
                        <label>Họ và Tên</label>
                        <p>${not empty userDetail.fullName ? userDetail.fullName : 'Chưa cập nhật'}</p>
                    </div>
                    <div class="info-item">
                        <label>Tên Đăng Nhập</label>
                        <p>${not empty userDetail.username ? userDetail.username : 'Chưa cập nhật'}</p>
                    </div>
                    <div class="info-item">
                        <label>Email</label>
                        <p>${not empty userDetail.email ? userDetail.email : 'Chưa cập nhật'}</p>
                    </div>
                    <div class="info-item">
                        <label>Số Điện Thoại</label>
                        <p>${not empty userDetail.phoneNumber ? userDetail.phoneNumber : 'Chưa cập nhật'}</p>
                    </div>
                    <div class="info-item">
                        <label>Ngày Sinh</label>
                        <p>
                            <c:choose>
                                <c:when test="${not empty userDetail.birthDay}">
                                    <fmt:formatDate value="${userDetail.birthDay}" pattern="dd/MM/yyyy" />
                                </c:when>
                                <c:otherwise>Chưa cập nhật</c:otherwise>
                            </c:choose>
                        </p>
                    </div>
                    <div class="info-item">
                        <label>Ngày Tạo Tài Khoản</label>
                        <p><fmt:formatDate value="${userDetail.createdAt}" pattern="dd/MM/yyyy HH:mm" /></p>
                    </div>
                    <div class="info-item">
                        <label>Trạng Thái</label>
                        <p>
                            <c:choose>
                                <c:when test="${userDetail.active == 1}">
                                    <span style="color: green; font-weight: bold;">Đang Hoạt Động</span>
                                </c:when>
                                <c:otherwise>
                                    <span style="color: red; font-weight: bold;">Bị Khoá</span>
                                </c:otherwise>
                            </c:choose>
                        </p>
                    </div>
                </div>
            </div>

            <div class="detail-container">
                <h3><ion-icon name="location-outline"></ion-icon> Sổ Địa Chỉ (${userAddresses.size()})</h3>
                <c:choose>
                    <c:when test="${empty userAddresses}">
                        <div class="empty-state">Khách hàng chưa thêm địa chỉ nào.</div>
                    </c:when>
                    <c:otherwise>
                        <div class="info-grid">
                            <c:forEach var="addr" items="${userAddresses}">
                                <div class="address-card">
                                    <c:if test="${addr.isDefault}">
                                        <div class="is-default-badge">Mặc định</div>
                                    </c:if>
                                    <p><strong>Người nhận:</strong> ${addr.fullName}</p>
                                    <p><strong>SĐT:</strong> ${addr.phoneNumber}</p>
                                    <p><strong>Địa chỉ:</strong> ${addr.addressLine}, ${addr.ward}, ${addr.district}, ${addr.city}</p>
                                </div>
                            </c:forEach>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>

            <div class="detail-container">
                <h3><ion-icon name="cart-outline"></ion-icon> Lịch Sử Đơn Hàng </h3>
                <c:choose>
                    <c:when test="${empty userOrders}">
                        <div class="empty-state">Khách hàng chưa có đơn hàng nào.</div>
                    </c:when>
                    <c:otherwise>
                        <c:set var="currentOrderId" value="-1" />
                        <c:set var="orderTotal" value="0" />
                        
                        <c:forEach var="order" items="${userOrders}" varStatus="status">
                            <c:if test="${order.order_id != currentOrderId}">
                                <c:if test="${currentOrderId != -1}">
                                        <div class="order-total">
                                            Tổng Tiền: <fmt:formatNumber value="${orderTotal}" pattern="#,##0" /> đ
                                        </div>
                                    </div>
                                </c:if>
                                
                                <c:set var="currentOrderId" value="${order.order_id}" />
                                <c:set var="orderTotal" value="${order.total_price}" />
                                
                                <div class="order-card">
                                    <div class="order-header">
                                        <h4>Đơn hàng #${order.order_id}</h4>
                                        <div class="order-date">
                                            ${order.create_at_str}
                                        </div>
                                    </div>
                            </c:if>
                            
                            <div class="order-item-row">
                                <c:choose>
                                    <c:when test="${not empty order.image_url}">
                                        <img src="${pageContext.request.contextPath}/${order.image_url}" class="order-img" alt="Product Image">
                                    </c:when>
                                    <c:otherwise>
                                        <img src="${pageContext.request.contextPath}/assets/img/default-product.jpg" class="order-img" alt="Default Image">
                                    </c:otherwise>
                                </c:choose>
                                
                                <div class="order-details">
                                    <h5>${order.product_name}</h5>
                                    <p>SL: ${order.quantity} x <fmt:formatNumber value="${order.unit_price}" pattern="#,##0" /> đ</p>
                                </div>
                            </div>
                            
                            <c:if test="${status.last}">
                                    <div class="order-total">
                                        Tổng Tiền Đơn Hàng: <fmt:formatNumber value="${orderTotal}" pattern="#,##0" /> đ
                                    </div>
                                </div>
                            </c:if>
                        </c:forEach>
                    </c:otherwise>
                </c:choose>
            </div>
        </main>
    </div>
</div>
</body>
</html>
