<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="vi">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Thống Kê Khuyến Mãi</title>

    <!-- Load styles and icons -->
    <script type="module" src="https://unpkg.com/ionicons@7.1.0/dist/ionicons/ionicons.esm.js"></script>
    <script nomodule src="https://unpkg.com/ionicons@7.1.0/dist/ionicons/ionicons.js"></script>
    <script src="${pageContext.request.contextPath}/popup.js"></script>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/admin/admin_css/manage_product_style.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/admin/admin_css/manage_promotion_style.css">

    <!-- Load DataTables and jQuery -->
    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
    <link rel="stylesheet" href="https://cdn.datatables.net/2.3.4/css/dataTables.dataTables.css" />
    <script src="https://cdn.datatables.net/2.3.4/js/dataTables.js"></script>

    <style>
        .report-sub-filters {
            display: flex;
            gap: 10px;
            margin-bottom: 24px;
            align-items: center;
        }

        .sub-filter-btn {
            padding: 8px 16px;
            font-size: 13px;
            font-weight: 600;
            color: var(--text-muted, #666);
            background-color: var(--bg-surface, #fff);
            border: 1px solid var(--border, #ddd);
            border-radius: var(--radius-md, 6px);
            cursor: pointer;
            transition: all 0.2s;
            text-decoration: none;
        }

        .sub-filter-btn:hover {
            border-color: var(--primary, #0ea5e9);
            color: var(--primary, #0ea5e9);
        }

        .sub-filter-btn.active {
            background-color: var(--primary, #0ea5e9);
            border-color: var(--primary, #0ea5e9);
            color: #ffffff;
        }

        .table-container {
            background: var(--bg-surface, #fff);
            padding: 20px;
            border-radius: var(--radius-lg, 8px);
            border: 1px solid var(--border, #ddd);
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);
            margin-top: 20px;
        }

        table.promotion-table {
            width: 100%;
            border-collapse: collapse;
        }

        table.promotion-table thead th {
            background-color: var(--bg-surface, #fff);
            color: var(--text-muted, #666);
            border-bottom: 2px solid var(--border, #ddd);
            padding: 12px 16px;
            font-weight: 600;
        }

        table.promotion-table tbody td {
            padding: 14px 16px;
            border-bottom: 1px solid var(--border, #ddd);
            color: var(--text-main, #333);
        }
    </style>
</head>

<body>
<div class="dashboard-container">
    <nav class="dashboard-sidebar">
        <ul class="sidebar-items">
            <!-- Include main profile header & navigation -->
            <div class="group-avatar">
                <%@ include file="/admin/components/avatar.jsp" %>
                <%@ include file="/admin/components/notify_icon.jsp" %>
            </div>
            <c:set var="activePage" value="promotion-stats" scope="request" />
            <%@ include file="/admin/components/sidebar_items_component.jsp" %>
        </ul>
        <div class="text">━ Thống Kê Khuyến Mãi ━</div>
    </nav>

    <div class="dashboard-content">
        <main class="dashboard-main-content">

            <div class="main-header">
                <h1>Thống Kê Khuyến Mãi & Flash Sale</h1>
            </div>

            <!-- Period selection sub filters -->
            <div class="report-sub-filters" style="margin-top: 20px;">
                <span style="font-size: 14px; font-weight: 600; color: var(--text-muted, #666);">Khoảng thời gian:</span>
                <a href="${pageContext.request.contextPath}/admin/promotion-stats?period=all"
                   class="sub-filter-btn ${period == 'all' ? 'active' : ''}">Tất cả thời gian</a>
                <a href="${pageContext.request.contextPath}/admin/promotion-stats?period=this_month"
                   class="sub-filter-btn ${period == 'this_month' ? 'active' : ''}">Tháng này</a>
                <a href="${pageContext.request.contextPath}/admin/promotion-stats?period=this_quarter"
                   class="sub-filter-btn ${period == 'this_quarter' ? 'active' : ''}">Quý này</a>
            </div>

            <div class="table-container">
                <div class="chart-header" style="margin-bottom: 15px;">
                    <div class="chart-title" style="color: #8b5cf6; font-size: 1.2rem; font-weight: 600; display: flex; align-items: center; gap: 8px;">
                        <ion-icon name="pricetags-outline"></ion-icon>
                        Hiệu Quả Khuyến Mãi & Flash Sale
                    </div>
                </div>
                <table class="promotion-table" style="width:100%" id="promo-stats-table">
                    <thead>
                        <tr class="sample">
                            <th>Sản Phẩm</th>
                            <th>Mã KM</th>
                            <th style="text-align: right;">Giá Gốc</th>
                            <th style="text-align: right;">Giá KM</th>
                            <th style="text-align: right;">Đã Bán</th>
                            <th style="text-align: right;">Doanh Thu (KM)</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${not empty promoProductStats}">
                                <c:forEach var="promo" items="${promoProductStats}">
                                    <tr>
                                        <td style="font-weight: 500;">
                                            <a href="${pageContext.request.contextPath}/admin/product/detail?id=${promo.product_id}" style="color: #0ea5e9; text-decoration: none;">
                                                ${promo.product_name}
                                            </a>
                                        </td>
                                        <td>
                                            <span style="background: rgba(139, 92, 246, 0.1); color: #8b5cf6; padding: 2px 8px; border-radius: 4px; font-size: 12px; font-weight: 600;">
                                                ${promo.discount_code}
                                            </span>
                                            <div style="font-size: 11px; color: #666; margin-top: 4px;">
                                                <c:choose>
                                                    <c:when test="${promo.discount_type == 'PERCENT' || promo.discount_type == '%'}">Giảm ${promo.discount_value}%</c:when>
                                                    <c:otherwise>Giảm <fmt:formatNumber value="${promo.discount_value}" type="currency" currencySymbol="đ" maxFractionDigits="0"/></c:otherwise>
                                                </c:choose>
                                            </div>
                                        </td>
                                        <td style="text-align: right; text-decoration: line-through; color: #999;">
                                            <fmt:formatNumber value="${promo.original_price}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                                        </td>
                                        <td style="text-align: right; font-weight: 700; color: #ef4444;">
                                            <fmt:formatNumber value="${promo.discounted_price}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                                        </td>
                                        <td style="text-align: right; font-weight: 600;">${promo.total_sold}</td>
                                        <td style="text-align: right; font-weight: 700; color: #10b981;">
                                            <fmt:formatNumber value="${promo.total_revenue}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <tr>
                                    <td colspan="6" style="text-align: center; padding: 30px; color: #888;">
                                        Không có sản phẩm nào đang chạy khuyến mãi trong thời gian này.
                                    </td>
                                </tr>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>
            </div>

        </main>
    </div>
</div>

<script>
document.addEventListener("DOMContentLoaded", function() {
    $('#promo-stats-table').DataTable({
        language: {
            url: '${pageContext.request.contextPath}/assets/datatables/Vietnamese.json',
        },
        pageLength: 10,
        lengthMenu: [[10, 25, 50, -1], [10, 25, 50, "Tất cả"]],
        order: [[4, 'desc']], // Sort by "Đã bán" descending
        searching: true,
        info: true
    });
});
</script>
</body>
</html>
