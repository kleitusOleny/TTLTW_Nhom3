<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="vi">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Thống Kê Đơn Hàng & Khách Hàng</title>

    <!-- Load styles and icons -->
    <script type="module" src="https://unpkg.com/ionicons@7.1.0/dist/ionicons/ionicons.esm.js"></script>
    <script nomodule src="https://unpkg.com/ionicons@7.1.0/dist/ionicons/ionicons.js"></script>
    <script src="${pageContext.request.contextPath}/popup.js"></script>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/admin/admin_css/manage_product_style.css">

    <!-- Load ApexCharts -->
    <script src="https://cdn.jsdelivr.net/npm/apexcharts"></script>

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
            color: var(--text-muted);
            background-color: var(--bg-surface);
            border: 1px solid var(--border);
            border-radius: var(--radius-md);
            cursor: pointer;
            transition: all 0.2s;
            text-decoration: none;
        }

        .sub-filter-btn:hover {
            border-color: var(--primary);
            color: var(--primary);
        }

        .sub-filter-btn.active {
            background-color: var(--primary);
            border-color: var(--primary);
            color: #ffffff;
        }

        .stats-summary-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
            gap: 16px;
            margin-bottom: 24px;
        }

        .stats-summary-card {
            background-color: var(--bg-surface);
            padding: 18px 22px;
            border-radius: var(--radius-md);
            border: 1px solid var(--border);
            box-shadow: var(--shadow-sm);
            display: flex;
            align-items: center;
            justify-content: space-between;
        }

        .stats-summary-info h3 {
            font-size: 13px;
            font-weight: 600;
            color: var(--text-muted);
            margin-bottom: 6px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        .stats-summary-info p {
            font-size: 22px;
            font-weight: 800;
            color: var(--text-main);
            margin: 0;
        }

        .stats-summary-icon {
            font-size: 32px;
            color: var(--primary);
            background-color: rgba(79, 70, 229, 0.1);
            padding: 10px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .charts-row {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
            margin-bottom: 30px;
        }

        @media (max-width: 992px) {
            .charts-row {
                grid-template-columns: 1fr;
            }
        }

        .chart-card {
            background-color: var(--bg-surface);
            padding: 24px;
            border-radius: var(--radius-lg);
            box-shadow: var(--shadow-md);
            border: 1px solid var(--border);
        }

        .chart-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
            border-bottom: 1px solid var(--border);
            padding-bottom: 12px;
        }

        .chart-title {
            font-size: 15px;
            font-weight: 700;
            color: var(--text-main);
            display: flex;
            align-items: center;
            gap: 8px;
            text-transform: uppercase;
        }

        .chart-title ion-icon {
            font-size: 20px;
            color: var(--primary);
        }

        .badge-loyal {
            background-color: rgba(245, 158, 11, 0.15);
            color: #d97706;
            border: 1px solid rgba(245, 158, 11, 0.3);
            padding: 4px 8px;
            border-radius: 4px;
            font-weight: 700;
            font-size: 12px;
            display: inline-flex;
            align-items: center;
            gap: 4px;
        }

        .badge-new {
            background-color: rgba(59, 130, 246, 0.15);
            color: #2563eb;
            border: 1px solid rgba(59, 130, 246, 0.3);
            padding: 4px 8px;
            border-radius: 4px;
            font-weight: 700;
            font-size: 12px;
            display: inline-flex;
            align-items: center;
            gap: 4px;
        }

        .badge-potential {
            background-color: rgba(100, 116, 139, 0.15);
            color: #475569;
            border: 1px solid rgba(100, 116, 139, 0.3);
            padding: 4px 8px;
            border-radius: 4px;
            font-weight: 700;
            font-size: 12px;
            display: inline-flex;
            align-items: center;
            gap: 4px;
        }

        .user-info-cell {
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .user-avatar {
            width: 36px;
            height: 36px;
            border-radius: 50%;
            background-color: var(--primary);
            color: #ffffff;
            font-weight: 700;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 14px;
            text-transform: uppercase;
        }

        /* Custom spacing and styles for DataTables inside dark theme */
        .table-container {
            background: var(--bg-surface);
            padding: 20px;
            border-radius: var(--radius-lg);
            border: 1px solid var(--border);
            box-shadow: var(--shadow-md);
            margin-top: 20px;
        }

        table.product-table {
            width: 100%;
            border-collapse: collapse;
        }

        table.product-table thead th {
            background-color: var(--bg-surface);
            color: var(--text-muted);
            border-bottom: 2px solid var(--border);
            padding: 12px 16px;
            font-weight: 600;
        }

        table.product-table tbody td {
            padding: 14px 16px;
            border-bottom: 1px solid var(--border);
            color: var(--text-main);
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
            <c:set var="activePage" value="order-stats" scope="request" />
            <%@ include file="/admin/components/sidebar_items_component.jsp" %>
        </ul>
        <div class="text">━ Thống Kê Đơn Hàng & Khách Hàng ━</div>
    </nav>

    <div class="dashboard-content">
        <main class="dashboard-main-content">

            <div class="main-header">
                <h1>Thống Kê Khách Hàng & Doanh Số</h1>
            </div>

            <!-- Period selection sub filters -->
            <div class="report-sub-filters">
                <span style="font-size: 14px; font-weight: 600; color: var(--text-muted);">Khoảng thời gian:</span>
                <a href="${pageContext.request.contextPath}/admin/order-stats?period=all"
                   class="sub-filter-btn ${period == 'all' ? 'active' : ''}">Tất cả thời gian</a>
                <a href="${pageContext.request.contextPath}/admin/order-stats?period=this_month"
                   class="sub-filter-btn ${period == 'this_month' ? 'active' : ''}">Tháng này</a>
                <a href="${pageContext.request.contextPath}/admin/order-stats?period=this_quarter"
                   class="sub-filter-btn ${period == 'this_quarter' ? 'active' : ''}">Quý này</a>
            </div>

            <!-- Metrics Aggregation -->
            <c:set var="totalActiveCustomers" value="0" />
            <c:set var="totalPeriodOrders" value="0" />
            <c:set var="totalPeriodSpend" value="0" />
            <c:forEach var="cust" items="${customerStats}">
                <c:if test="${cust.total_orders > 0}">
                    <c:set var="totalActiveCustomers" value="${totalActiveCustomers + 1}" />
                </c:if>
                <c:set var="totalPeriodOrders" value="${totalPeriodOrders + cust.total_orders}" />
                <c:set var="totalPeriodSpend" value="${totalPeriodSpend + cust.total_spend}" />
            </c:forEach>

            <!-- Summary metrics cards -->
            <div class="stats-summary-grid">
                <div class="stats-summary-card">
                    <div class="stats-summary-info">
                        <h3>Tổng Khách Hàng Đã Mua</h3>
                        <p>${totalActiveCustomers} / ${customerStats.size()}</p>
                    </div>
                    <div class="stats-summary-icon">
                        <ion-icon name="people-outline"></ion-icon>
                    </div>
                </div>
                <div class="stats-summary-card">
                    <div class="stats-summary-info">
                        <h3>Tổng Số Đơn Đặt</h3>
                        <p>${totalPeriodOrders} Đơn</p>
                    </div>
                    <div class="stats-summary-icon" style="color: #f59e0b; background-color: rgba(245, 158, 11, 0.1);">
                        <ion-icon name="cart-outline"></ion-icon>
                    </div>
                </div>
                <div class="stats-summary-card">
                    <div class="stats-summary-info">
                        <h3>Tổng Giá Trị Doanh Số</h3>
                        <p><fmt:formatNumber value="${totalPeriodSpend}" pattern="#,##0" />đ</p>
                    </div>
                    <div class="stats-summary-icon" style="color: #10b981; background-color: rgba(16, 185, 129, 0.1);">
                        <ion-icon name="cash-outline"></ion-icon>
                    </div>
                </div>
                <div class="stats-summary-card">
                    <div class="stats-summary-info">
                        <h3>Giá Trị Đơn Trung Bình</h3>
                        <p>
                            <c:choose>
                                <c:when test="${totalPeriodOrders > 0}">
                                    <fmt:formatNumber value="${totalPeriodSpend / totalPeriodOrders}" pattern="#,##0" />đ
                                </c:when>
                                <c:otherwise>0đ</c:otherwise>
                            </c:choose>
                        </p>
                    </div>
                    <div class="stats-summary-icon" style="color: #3b82f6; background-color: rgba(59, 130, 246, 0.1);">
                        <ion-icon name="wallet-outline"></ion-icon>
                    </div>
                </div>
            </div>

            <!-- Charts Row -->
            <div class="charts-row">
                <!-- Customer Class Donut Chart -->
                <div class="chart-card">
                    <div class="chart-header">
                        <div class="chart-title">
                            <ion-icon name="pie-chart-outline"></ion-icon>
                            Phân bố phân loại khách hàng (Trọn đời)
                        </div>
                    </div>
                    <div id="customer-class-chart"></div>
                </div>

                <!-- Top 5 Spending Customers -->
                <div class="chart-card">
                    <div class="chart-header">
                        <div class="chart-title">
                            <ion-icon name="ribbon-outline"></ion-icon>
                            Top 5 khách hàng chi tiêu nhiều nhất (đ)
                        </div>
                    </div>
                    <div id="top-spending-chart"></div>
                </div>
            </div>

            <!-- Detailed Customers List Table -->
            <div class="main-header" style="margin-top: 24px; border-bottom: none; padding-bottom: 0;">
                <h2 style="font-size: 18px; font-weight: 700; color: var(--text-main); display: flex; align-items: center; gap: 8px;">
                    <ion-icon name="list-outline" style="color: var(--primary);"></ion-icon>
                    Bảng Thống Kê Hành Vi Mua Hàng Của Khách Hàng
                </h2>
            </div>

            <div class="table-container">
                <table id="customer-stats-table" class="product-table">
                    <thead>
                    <tr>
                        <th style="width: 25%;">Khách Hàng</th>
                        <th style="width: 15%; text-align: center;">Đơn Chọn / Trọn Đời</th>
                        <th style="width: 18%; text-align: right;">Chi Tiêu Lọc (đ)</th>
                        <th style="width: 18%; text-align: right;">Chi Tiêu Trọn Đời (đ)</th>
                        <th style="width: 8%; text-align: center;">Đánh Giá</th>
                        <th style="width: 16%; text-align: center;">Phân Loại</th>
                    </tr>
                    </thead>
                    <tbody>
                    <c:forEach var="c" items="${customerStats}">
                        <!-- Classification tags Logic -->
                        <c:set var="classBadge" value="" />
                        <c:choose>
                            <c:when test="${c.all_time_orders >= 5 || c.all_time_spend >= 5000000}">
                                <c:set var="classBadge">
                                    <span class="badge-loyal">
                                        <ion-icon name="shield-checkmark-outline"></ion-icon> Thân thiết (VIP)
                                    </span>
                                </c:set>
                            </c:when>
                            <c:when test="${c.all_time_orders > 0}">
                                <c:set var="classBadge">
                                    <span class="badge-new">
                                        <ion-icon name="sparkles-outline"></ion-icon> Khách hàng mới
                                    </span>
                                </c:set>
                            </c:when>
                            <c:otherwise>
                                <c:set var="classBadge">
                                    <span class="badge-potential">
                                        <ion-icon name="help-circle-outline"></ion-icon> Tiềm năng
                                    </span>
                                </c:set>
                            </c:otherwise>
                        </c:choose>

                        <tr>
                            <td>
                                <div class="user-info-cell">
                                    <div class="user-avatar">
                                        <c:choose>
                                            <c:when test="${not empty c.full_name}">
                                                ${c.full_name.substring(0, 1)}
                                            </c:when>
                                            <c:otherwise>
                                                ${c.email.substring(0, 1)}
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                    <div>
                                        <strong style="display: block; color: var(--text-main);">
                                            <c:out value="${not empty c.full_name ? c.full_name : 'Khách vãng lai'}" />
                                        </strong>
                                        <span style="font-size: 12px; color: var(--text-muted); display: block;">
                                            Email: ${c.email} | SĐT: ${c.phone_number != null ? c.phone_number : 'N/A'}
                                        </span>
                                    </div>
                                </div>
                            </td>
                            <td style="text-align: center; font-weight: 700;">
                                <span style="color: var(--primary);">${c.total_orders}</span> / <span style="color: var(--text-muted);">${c.all_time_orders}</span>
                            </td>
                            <td style="text-align: right; font-weight: 700; color: #10b981;">
                                <fmt:formatNumber value="${c.total_spend}" pattern="#,##0" />đ
                            </td>
                            <td style="text-align: right; font-weight: 600; color: var(--text-main);">
                                <fmt:formatNumber value="${c.all_time_spend}" pattern="#,##0" />đ
                            </td>
                            <td style="text-align: center; font-weight: 600;">
                                <span style="background-color: rgba(111, 66, 193, 0.1); color: #6f42c1; padding: 2px 6px; border-radius: 4px;">
                                    ${c.total_reviews}
                                </span>
                            </td>
                            <td style="text-align: center;">
                                ${classBadge}
                            </td>
                        </tr>
                    </c:forEach>
                    </tbody>
                </table>
            </div>

        </main>
    </div>
</div>

<script>
document.addEventListener("DOMContentLoaded", function() {
    // 1. Initialize jQuery DataTable
    $('#customer-stats-table').DataTable({
        language: {
            url: 'https://cdn.datatables.net/plug-ins/2.3.5/i18n/vi.json',
        },
        order: [[2, 'desc']], // Order by selected period spend by default
        pageLength: 10,
        lengthMenu: [5, 10, 25, 50]
    });

    // 2. Render Donut Chart for Customer Classification
    const donutOptions = {
        series: [
            ${summary.loyal_count != null ? summary.loyal_count : 0}, 
            ${summary.new_count != null ? summary.new_count : 0}, 
            ${summary.potential_count != null ? summary.potential_count : 0}
        ],
        chart: {
            type: 'donut',
            height: 320,
            background: 'transparent'
        },
        labels: ['Khách hàng thân thiết', 'Khách hàng mới', 'Khách hàng tiềm năng'],
        colors: ['#f59e0b', '#3b82f6', '#64748b'],
        dataLabels: {
            enabled: true,
            formatter: function (val, opts) {
                return opts.w.config.series[opts.seriesIndex] + " KH";
            }
        },
        stroke: {
            width: 1,
            colors: ['var(--border)']
        },
        legend: {
            position: 'bottom',
            labels: {
                colors: 'var(--text-main)'
            }
        },
        tooltip: {
            y: {
                formatter: function (val) {
                    return val + " người dùng";
                }
            }
        },
        plotOptions: {
            pie: {
                donut: {
                    labels: {
                        show: true,
                        total: {
                            show: true,
                            label: 'Tổng số KH',
                            color: 'var(--text-muted)',
                            formatter: function (w) {
                                return w.globals.seriesTotals.reduce((a, b) => a + b, 0) + ' KH';
                            }
                        }
                    }
                }
            }
        }
    };

    const donutChart = new ApexCharts(document.querySelector("#customer-class-chart"), donutOptions);
    donutChart.render();

    // 3. Render Horizontal Bar Chart for Top 5 Spending Customers
    const barOptions = {
        series: [{
            name: 'Chi tiêu tích lũy',
            data: ${topSpendJson}
        }],
        chart: {
            type: 'bar',
            height: 320,
            toolbar: {
                show: false
            }
        },
        plotOptions: {
            bar: {
                borderRadius: 4,
                horizontal: true,
                barHeight: '50%',
                distributed: true
            }
        },
        colors: ['#10b981', '#14b8a6', '#06b6d4', '#2563eb', '#3b82f6'],
        dataLabels: {
            enabled: true,
            formatter: function (val) {
                return val.toLocaleString('vi-VN') + 'đ';
            },
            style: {
                fontWeight: 600,
                colors: ['#fff']
            }
        },
        xaxis: {
            categories: ${topNamesJson},
            labels: {
                formatter: function (val) {
                    return (val / 1000000) + 'Mđ';
                },
                style: {
                    colors: 'var(--text-muted)'
                }
            }
        },
        yaxis: {
            labels: {
                style: {
                    colors: 'var(--text-main)',
                    fontWeight: 600
                }
            }
        },
        legend: {
            show: false
        },
        tooltip: {
            y: {
                formatter: function (val) {
                    return val.toLocaleString('vi-VN') + ' VNĐ';
                }
            }
        }
    };

    const barChart = new ApexCharts(document.querySelector("#top-spending-chart"), barOptions);
    barChart.render();
});
</script>
</body>
</html>
