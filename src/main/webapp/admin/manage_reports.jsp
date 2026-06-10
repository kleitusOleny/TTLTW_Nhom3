<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="vi">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Báo Cáo & Thống Kê</title>

    <!-- Load styles and icons -->
    <script type="module" src="https://unpkg.com/ionicons@7.1.0/dist/ionicons/ionicons.esm.js"></script>
    <script nomodule src="https://unpkg.com/ionicons@7.1.0/dist/ionicons/ionicons.js"></script>
    <script src="${pageContext.request.contextPath}/popup.js"></script>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/admin/admin_css/manage_product_style.css">

    <!-- Load ApexCharts -->
    <script src="https://cdn.jsdelivr.net/npm/apexcharts"></script>

    <style>
        /* CSS custom for Report Page to make it wow/premium */
        .report-tabs {
            display: flex;
            gap: 8px;
            margin-bottom: 24px;
            border-bottom: 2px solid var(--border);
            padding-bottom: 8px;
        }

        .report-tab-btn {
            padding: 10px 20px;
            font-size: 15px;
            font-weight: 600;
            color: var(--text-muted);
            background: transparent;
            border: none;
            border-bottom: 3px solid transparent;
            cursor: pointer;
            transition: all 0.2s ease;
            text-decoration: none;
        }

        .report-tab-btn:hover {
            color: var(--primary);
        }

        .report-tab-btn.active {
            color: var(--primary);
            border-bottom-color: var(--primary);
        }

        .report-sub-filters {
            display: flex;
            gap: 10px;
            margin-bottom: 24px;
            align-items: center;
        }

        .sub-filter-btn {
            padding: 6px 14px;
            font-size: 13px;
            font-weight: 500;
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

        .chart-card {
            background-color: var(--bg-surface);
            padding: 24px;
            border-radius: var(--radius-lg);
            box-shadow: var(--shadow-md);
            border: 1px solid var(--border);
            margin-bottom: 30px;
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
            font-size: 16px;
            font-weight: 700;
            color: var(--text-main);
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .chart-title ion-icon {
            font-size: 20px;
            color: var(--primary);
        }

        .stats-summary-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 16px;
            margin-bottom: 24px;
        }

        .stats-summary-card {
            background-color: var(--bg-surface);
            padding: 16px 20px;
            border-radius: var(--radius-md);
            border: 1px solid var(--border);
            box-shadow: var(--shadow-sm);
        }

        .stats-summary-card h3 {
            font-size: 13px;
            font-weight: 600;
            color: var(--text-muted);
            margin-bottom: 8px;
            text-transform: uppercase;
        }

        .stats-summary-card p {
            font-size: 22px;
            font-weight: 800;
            color: var(--text-main);
        }

        .info-warning-card {
            background-color: #fef3c7; /* Light yellow */
            border-left: 5px solid #d97706; /* Amber border */
            color: #92400e; /* Dark brown text */
            padding: 16px;
            border-radius: var(--radius-md);
            margin-bottom: 24px;
            display: flex;
            align-items: flex-start;
            gap: 12px;
            font-size: 14px;
            font-weight: 500;
        }

        .info-warning-card ion-icon {
            font-size: 22px;
            color: #d97706;
            flex-shrink: 0;
        }
    </style>
</head>

<body>
<div class="dashboard-container">
    <nav class="dashboard-sidebar">
        <ul class="sidebar-items">
            <!-- Included modular header is automatically inserted via custom class -->
            <c:set var="activePage" value="report" scope="request" />
            <%@ include file="/admin/components/sidebar_items_component.jsp" %>
        </ul>
    </nav>

    <div class="dashboard-content">
        <main class="dashboard-main-content">

            <div class="main-header">
                <h1>Báo Cáo & Thống Kê Kho Hàng</h1>
            </div>

            <!-- Main Report Tabs -->
            <div class="report-tabs">
                <a href="${pageContext.request.contextPath}/report-manager?tab=revenue"
                   class="report-tab-btn ${tab == 'revenue' ? 'active' : ''}">
                   Doanh Thu
                </a>
                <a href="${pageContext.request.contextPath}/report-manager?tab=bestsellers"
                   class="report-tab-btn ${tab == 'bestsellers' ? 'active' : ''}">
                   Sản Phẩm Bán Chạy
                </a>
                <a href="${pageContext.request.contextPath}/report-manager?tab=unsold"
                   class="report-tab-btn ${tab == 'unsold' ? 'active' : ''}">
                   Sản Phẩm Không Bán Được
                </a>
            </div>

            <!-- Tab content: DOANH THU -->
            <c:if test="${tab == 'revenue'}">
                <!-- Sub filter buttons -->
                <div class="report-sub-filters">
                    <span style="font-size: 14px; font-weight: 600; color: var(--text-muted);">Thống kê theo:</span>
                    <a href="${pageContext.request.contextPath}/report-manager?tab=revenue&period=day"
                       class="sub-filter-btn ${period == 'day' ? 'active' : ''}">Ngày (30 ngày qua)</a>
                    <a href="${pageContext.request.contextPath}/report-manager?tab=revenue&period=month"
                       class="sub-filter-btn ${period == 'month' ? 'active' : ''}">Tháng (12 tháng qua)</a>
                    <a href="${pageContext.request.contextPath}/report-manager?tab=revenue&period=quarter"
                       class="sub-filter-btn ${period == 'quarter' ? 'active' : ''}">Quý (4 quý qua)</a>
                    <a href="${pageContext.request.contextPath}/report-manager?tab=revenue&period=year"
                       class="sub-filter-btn ${period == 'year' ? 'active' : ''}">Năm</a>
                </div>

                <!-- Stats summary card block -->
                <c:set var="totalRev" value="0" />
                <c:forEach var="row" items="${revenueData}">
                    <c:set var="totalRev" value="${totalRev + row.revenue}" />
                </c:forEach>

                <div class="stats-summary-grid">
                    <div class="stats-summary-card">
                        <h3>Tổng Doanh Thu Lọc</h3>
                        <p><fmt:formatNumber value="${totalRev}" pattern="#,##0" />đ</p>
                    </div>
                    <div class="stats-summary-card">
                        <h3>Số Giao Dịch Thống Kê</h3>
                        <p>${revenueData.size()} giao dịch</p>
                    </div>
                    <div class="stats-summary-card">
                        <h3>Doanh Thu Trung Bình</h3>
                        <p>
                            <c:choose>
                                <c:when test="${revenueData.size() > 0}">
                                    <fmt:formatNumber value="${totalRev / revenueData.size()}" pattern="#,##0" />đ
                                </c:when>
                                <c:otherwise>0đ</c:otherwise>
                            </c:choose>
                        </p>
                    </div>
                </div>

                <!-- ApexCharts Card -->
                <div class="chart-card">
                    <div class="chart-header">
                        <div class="chart-title">
                            <ion-icon name="trending-up-outline"></ion-icon>
                            Biểu đồ tăng trưởng doanh thu
                        </div>
                    </div>
                    <div id="revenue-chart"></div>
                </div>

                <!-- Detailed Table breakdown -->
                <div class="main-header" style="margin-top: 24px; border-bottom: none; padding-bottom: 0;">
                    <h2 style="font-size: 18px; font-weight: 700; color: var(--text-main);">Chi tiết số liệu doanh thu</h2>
                </div>
                <div class="table-container">
                    <table class="product-table">
                        <thead>
                        <tr>
                            <th style="width: 40%;">Thời Gian</th>
                            <th style="width: 60%; text-align: right; padding-right: 40px;">Doanh Thu (VNĐ)</th>
                        </tr>
                        </thead>
                        <tbody>
                        <c:choose>
                            <c:when test="${not empty revenueData}">
                                <c:forEach var="row" items="${revenueData}">
                                    <tr>
                                        <td><strong>${row.time_label}</strong></td>
                                        <td style="text-align: right; padding-right: 40px; font-weight: 600; color: #10b981;">
                                            +<fmt:formatNumber value="${row.revenue}" pattern="#,##0" />đ
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <tr>
                                    <td colspan="2" style="text-align: center;">Không tìm thấy dữ liệu doanh thu trong khoảng thời gian này.</td>
                                </tr>
                            </c:otherwise>
                        </c:choose>
                        </tbody>
                    </table>
                </div>
            </c:if>

            <!-- Tab content: SAN PHAM BAN CHAY -->
            <c:if test="${tab == 'bestsellers'}">
                <div class="stats-summary-grid">
                    <div class="stats-summary-card">
                        <h3>Tổng số sản phẩm</h3>
                        <p>${bestSellers.size()} Sản phẩm</p>
                    </div>
                    <div class="stats-summary-card">
                        <h3>Sản phẩm bán chạy nhất</h3>
                        <p>
                            <c:choose>
                                <c:when test="${bestSellers.size() > 0}">
                                    <c:out value="${bestSellers[0].product_name}" />
                                </c:when>
                                <c:otherwise>Không có</c:otherwise>
                            </c:choose>
                        </p>
                    </div>
                </div>

                <!-- ApexCharts Card -->
                <div class="chart-card">
                    <div class="chart-header">
                        <div class="chart-title">
                            <ion-icon name="trophy-outline"></ion-icon>
                            Top 10 sản phẩm bán chạy nhất (Số lượng đã bán)
                        </div>
                    </div>
                    <div id="bestsellers-chart"></div>
                </div>

                <!-- Detailed Table breakdown -->
                <div class="main-header" style="margin-top: 24px; border-bottom: none; padding-bottom: 0;">
                    <h2 style="font-size: 18px; font-weight: 700; color: var(--text-main);">Danh sách chi tiết sản phẩm bán chạy</h2>
                </div>
                <div class="table-container">
                    <table class="product-table">
                        <thead>
                        <tr>
                            <th style="width: 10%;">ID</th>
                            <th style="width: 50%;">Tên Sản Phẩm</th>
                            <th style="width: 20%; text-align: center;">Số Lượng Đã Bán</th>
                            <th style="width: 20%; text-align: right; padding-right: 20px;">Doanh Thu Đóng Góp</th>
                        </tr>
                        </thead>
                        <tbody>
                        <c:choose>
                            <c:when test="${not empty bestSellers}">
                                <c:forEach var="p" items="${bestSellers}">
                                    <tr>
                                        <td>${p.id}</td>
                                        <td><strong><c:out value="${p.product_name}"/></strong></td>
                                        <td style="text-align: center; font-weight: bold; color: var(--primary);">${p.total_sold}</td>
                                        <td style="text-align: right; padding-right: 20px; font-weight: 600; color: #10b981;">
                                            <fmt:formatNumber value="${p.total_revenue}" pattern="#,##0" />đ
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <tr>
                                    <td colspan="4" style="text-align: center;">Không tìm thấy sản phẩm nào phát sinh doanh số.</td>
                                </tr>
                            </c:otherwise>
                        </c:choose>
                        </tbody>
                    </table>
                </div>
            </c:if>

            <!-- Tab content: SAN PHAM KHONG BAN DUOC -->
            <c:if test="${tab == 'unsold'}">
                <!-- Sub filter buttons -->
                <div class="report-sub-filters">
                    <span style="font-size: 14px; font-weight: 600; color: var(--text-muted);">Không bán được trong:</span>
                    <a href="${pageContext.request.contextPath}/report-manager?tab=unsold&months=1"
                       class="sub-filter-btn ${months == 1 ? 'active' : ''}">1 Tháng (30 ngày qua)</a>
                    <a href="${pageContext.request.contextPath}/report-manager?tab=unsold&months=2"
                       class="sub-filter-btn ${months == 2 ? 'active' : ''}">2 Tháng (60 ngày qua)</a>
                </div>

                <!-- Call to action warning card -->
                <div class="info-warning-card">
                    <ion-icon name="alert-circle-outline"></ion-icon>
                    <div>
                        <strong style="display: block; font-size: 15px; margin-bottom: 4px;">Khuyến nghị quản lý kho hàng:</strong>
                        Các sản phẩm dưới đây vẫn đang được kích hoạt bày bán nhưng chưa phát sinh bất kỳ lượt bán nào trong vòng ${months} tháng qua.
                        Bạn nên chạy các chương trình khuyến mãi, tặng mã giảm giá hoặc tạo combo quà tặng để kích cầu tiêu dùng, giải phóng hàng tồn kho hiệu quả.
                    </div>
                </div>

                <div class="stats-summary-grid">
                    <div class="stats-summary-card" style="border-left: 4px solid #d97706;">
                        <h3>Tổng sản phẩm tồn đọng</h3>
                        <p>${unsoldProducts.size()} Sản phẩm</p>
                    </div>
                </div>

                <!-- Detailed Table breakdown -->
                <div class="main-header" style="margin-top: 10px; border-bottom: none; padding-bottom: 0;">
                    <h2 style="font-size: 18px; font-weight: 700; color: var(--text-main);">Danh sách sản phẩm không bán được</h2>
                </div>
                <div class="table-container">
                    <table class="product-table">
                        <thead>
                        <tr>
                            <th style="width: 10%;">ID</th>
                            <th style="width: 50%;">Tên Sản Phẩm</th>
                            <th style="width: 20%; text-align: right; padding-right: 20px;">Đơn Giá Bán</th>
                            <th style="width: 20%; text-align: center;">Số Lượng Tồn Kho</th>
                        </tr>
                        </thead>
                        <tbody>
                        <c:choose>
                            <c:when test="${not empty unsoldProducts}">
                                <c:forEach var="p" items="${unsoldProducts}">
                                    <tr>
                                        <td>${p.id}</td>
                                        <td><strong><c:out value="${p.product_name}"/></strong></td>
                                        <td style="text-align: right; padding-right: 20px; font-weight: 600;">
                                            <fmt:formatNumber value="${p.price}" pattern="#,##0" />đ
                                        </td>
                                        <td style="text-align: center; font-weight: bold; color: #ef4444;">${p.quantity}</td>
                                    </tr>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <tr>
                                    <td colspan="4" style="text-align: center; color: #10b981; font-weight: bold;">
                                        Tuyệt vời! Tất cả các sản phẩm đều đã phát sinh giao dịch trong thời gian này.
                                    </td>
                                </tr>
                            </c:otherwise>
                        </c:choose>
                        </tbody>
                    </table>
                </div>
            </c:if>

        </main>
    </div>
</div>

<!-- Scripts for Chart rendering -->
<script>
document.addEventListener("DOMContentLoaded", function() {
    // 1. Render Chart for Revenue Tab
    <c:if test="${tab == 'revenue' and not empty revenueData}">
        const revenueOptions = {
            series: [{
                name: 'Doanh Thu',
                data: ${valuesJson}
            }],
            chart: {
                height: 350,
                type: 'area',
                toolbar: {
                    show: false
                },
                zoom: {
                    enabled: false
                }
            },
            colors: ['#4f46e5'],
            dataLabels: {
                enabled: false
            },
            stroke: {
                curve: 'smooth',
                width: 3
            },
            xaxis: {
                categories: ${labelsJson},
                labels: {
                    style: {
                        colors: '#64748b',
                        fontSize: '12px',
                        fontWeight: 500
                    }
                }
            },
            yaxis: {
                labels: {
                    formatter: function(val) {
                        return val.toLocaleString('vi-VN') + 'đ';
                    },
                    style: {
                        colors: '#64748b',
                        fontSize: '12px'
                    }
                }
            },
            fill: {
                type: 'gradient',
                gradient: {
                    shadeIntensity: 1,
                    opacityFrom: 0.45,
                    opacityTo: 0.05,
                    stops: [0, 90, 100]
                }
            },
            tooltip: {
                y: {
                    formatter: function(val) {
                        return val.toLocaleString('vi-VN') + ' VNĐ';
                    }
                }
            }
        };

        const revenueChart = new ApexCharts(document.querySelector("#revenue-chart"), revenueOptions);
        revenueChart.render();
    </c:if>

    // 2. Render Chart for Bestsellers Tab
    <c:if test="${tab == 'bestsellers' and not empty bestSellers}">
        const bestsellerOptions = {
            series: [{
                name: 'Số lượng đã bán',
                data: ${valuesJson}
            }],
            chart: {
                type: 'bar',
                height: 350,
                toolbar: {
                    show: false
                }
            },
            plotOptions: {
                bar: {
                    borderRadius: 4,
                    horizontal: true,
                    barHeight: '60%',
                    distributed: true
                }
            },
            colors: ['#3b82f6', '#10b981', '#f59e0b', '#ef4444', '#8b5cf6', '#ec4899', '#14b8a6', '#f97316', '#06b6d4', '#64748b'],
            dataLabels: {
                enabled: true,
                textAnchor: 'start',
                style: {
                    colors: ['#fff'],
                    fontWeight: 700
                },
                formatter: function(val, opt) {
                    return val + ' sản phẩm';
                },
                offsetX: 0
            },
            xaxis: {
                categories: ${labelsJson},
                labels: {
                    style: {
                        colors: '#64748b',
                        fontSize: '12px'
                    }
                }
            },
            yaxis: {
                labels: {
                    style: {
                        colors: '#64748b',
                        fontSize: '12px',
                        fontWeight: 600
                    }
                }
            },
            legend: {
                show: false
            },
            tooltip: {
                x: {
                    show: true
                },
                y: {
                    formatter: function(val) {
                        return val + ' chai';
                    }
                }
            }
        };

        const bestsellerChart = new ApexCharts(document.querySelector("#bestsellers-chart"), bestsellerOptions);
        bestsellerChart.render();
    </c:if>
});
</script>
</body>

</html>
