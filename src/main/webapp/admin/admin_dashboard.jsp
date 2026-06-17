<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="vi">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Trang Chủ - Dashboard</title>
    <script src="https://cdn.jsdelivr.net/npm/apexcharts"></script>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/admin/admin_css/manage_product_style.css?v=1.0.4">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/admin/admin_css/admin_dashboard.css?v=1.0.4">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
</head>

<body>
<div class="dashboard-container">
    <nav class="dashboard-sidebar">
        <ul class="sidebar-items">
            <div class="group-avatar">
                <%@ include file="/admin/components/avatar.jsp" %>
                <%@ include file="/admin/components/notify_icon.jsp" %>
            </div>
            <c:set var="activePage" value="dashboard" scope="request" />
            <%@ include file="/admin/components/sidebar_items_component.jsp" %>
        </ul>
    </nav>
    <div class="dashboard-content">
        <main class="dashboard-main-content">
            <h1>Chào mừng quay trở lại, Admin!</h1>
            
            <!-- Statistics Cards -->
            <div class="stat-cards-container">
                <div class="stat-card">
                    <h3>Đơn Hàng Mới</h3>
                    <p class="stat-number"><fmt:formatNumber value="${newOrderLastWeek}" pattern="#,###"/></p>
                    <span class="stat-description">Trong 7 ngày qua</span>
                </div>
                <div class="stat-card">
                    <h3>Doanh Thu Tháng Này</h3>
                    <p class="stat-number"><fmt:formatNumber value="${sumTotalPriceLastMonth}" pattern="#,###"/>đ</p>
                    <span class="stat-description">Tổng giá trị thanh toán</span>
                </div>
                <div class="stat-card">
                    <h3>Tài Khoản Mới</h3>
                    <p class="stat-number"><fmt:formatNumber value="${newUsersLastWeek}" pattern="#,###"/></p>
                    <span class="stat-description">Đăng ký trong 7 ngày qua</span>
                </div>
                <div class="stat-card special" id="out_of_stocks-modal-btn">
                    <div class="group-stat-card" style="display: flex; justify-content: space-between; align-items: center;">
                        <h3>Sản Phẩm Hết Hàng</h3>
                        <ion-icon name="warning-outline" style="font-size: 20px; color: var(--danger);"></ion-icon>
                    </div>
                    <p class="stat-number">${outOfStockList.size()}</p>
                    <span class="stat-description">Sản phẩm có tồn kho &le; 5</span>
                </div>
            </div>

            <!-- Charts Section -->
            <div class="dashboard-charts-container">
                <div class="chart-card">
                    <h2>
                        <ion-icon name="trending-up-outline" style="color: var(--primary); font-size: 20px;"></ion-icon>
                        Biến động doanh thu (30 ngày qua)
                    </h2>
                    <div id="revenue-trend-chart"></div>
                </div>
                <div class="chart-card">
                    <h2>
                        <ion-icon name="pie-chart-outline" style="color: var(--success); font-size: 20px;"></ion-icon>
                        Phân bố trạng thái đơn hàng
                    </h2>
                    <div id="order-status-chart"></div>
                </div>
            </div>

            <!-- Todo Lists Container -->
            <div class="group-todo">
                <div class="todo-list-container not-finish">
                    <h2>
                        <ion-icon name="document-attach-outline" style="color: var(--danger);"></ion-icon> 
                        Danh Sách Cần Làm
                    </h2>
                    <div class="contain-todo">
                        <c:choose>
                            <c:when test="${not empty pendingList}">
                                <c:forEach items="${pendingList}" var="f">
                                    <div class="todo not-finish todo-trigger" data-target="generic-todo-modal"
                                         data-id="${f.id}" data-title="${f.title}" data-content="${f.content}"
                                         data-status="false">${f.title}
                                        <ion-icon name="chevron-forward-outline" class="icon-todo"></ion-icon>
                                    </div>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <p style="color: var(--text-muted); font-style: italic; font-size: 14px; text-align: center; padding: 20px 0;">Không có công việc cần làm</p>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>

                <div class="todo-list-container finished">
                    <h2>
                        <ion-icon name="checkbox-outline" style="color: var(--success);"></ion-icon> 
                        Đã Hoàn Thành
                    </h2>
                    <div class="contain-todo">
                        <c:choose>
                            <c:when test="${not empty doneList}">
                                <c:forEach items="${doneList}" var="f">
                                    <div class="todo finish todo-trigger" data-target="generic-todo-modal" data-id="${f.id}"
                                         data-title="${f.title}" data-content="${f.content}" data-status="true">${f.title}
                                        <ion-icon name="chevron-forward-outline" class="icon-todo"></ion-icon>
                                    </div>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <p style="color: var(--text-muted); font-style: italic; font-size: 14px; text-align: center; padding: 20px 0;">Chưa hoàn thành công việc nào</p>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </div>
            
            <h4 class="text-welcome">© 2026 Khoa Công Nghệ Thông Tin.</h4>
        </main>
    </div>
</div>

<!-- Modal Todo -->
<div class="modal-overlay-todo" id="generic-todo-modal">
    <div class="modal-content-todo">
        <form id="todo-form" action="${pageContext.request.contextPath}/todo_list" method="POST">
            <input type="hidden" name="action" id="modal-action" value="update_status">
            <input type="hidden" name="taskId" id="modal-task-id">
            <div class="todo-container">
                <h2 id="modal-task-title">Tiêu đề task</h2>
                <p id="modal-task-content" style="color: var(--text-muted); line-height: 1.6;"></p>
                <div class="select-todo">
                    <label>Tiến độ:</label>
                    <select name="status" id="modal-task-status">
                        <option value="false">Chưa Hoàn Thành</option>
                        <option value="true">Hoàn Thành</option>
                    </select>
                </div>
            </div>
            <div class="group-button-action section">
                <button type="button" class="btn btn-secondary close-todo-modal" style="min-width: 80px;">Huỷ</button>
                <button type="button" class="btn btn-danger" onclick="submitDelete()" style="min-width: 80px;">Xoá</button>
                <button type="submit" class="btn btn-primary" style="min-width: 100px;">Cập nhật</button>
            </div>
        </form>
    </div>
</div>

<!-- Modal Out of Stock Products -->
<div class="modal-overlay-out_of_stocks" id="out_of_stocks-modal">
    <div class="modal-content-out_of_stocks">
        <div class="text-group-out_of_stocks">
            <h2>
                <ion-icon name="cube-outline"></ion-icon>
                Sản phẩm sắp hết hàng
            </h2>
            <ion-icon name="close-outline" id="close-modal-out_of_stock"></ion-icon>
        </div>
        <div class="out-of-stocks-container">
            <c:choose>
                <c:when test="${not empty outOfStockList}">
                    <c:forEach items="${outOfStockList}" var="p">
                        <div class="text-name">
                            <p>- ${p.productName}</p>
                            <p class="text-b">(SL: ${p.quantity} - ID: ${p.id})</p>
                        </div>
                    </c:forEach>
                </c:when>
                <c:otherwise>
                    <p style="color: var(--text-muted); font-style: italic; font-size: 14px; text-align: center; padding: 10px 0;">Hiện không có sản phẩm nào sắp hết hàng.</p>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</div>

<script type="module" src="https://unpkg.com/ionicons@7.1.0/dist/ionicons/ionicons.esm.js"></script>
<script nomodule src="https://unpkg.com/ionicons@7.1.0/dist/ionicons/ionicons.js"></script>
<link href="https://fonts.googleapis.com/css2?family=Philosopher&display=swap" rel="stylesheet">
<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
<script src="${pageContext.request.contextPath}/popup.js"></script>

<c:if test="${not empty sessionScope.authError}">
    <script>
        document.addEventListener("DOMContentLoaded", function() {
            Swal.fire({
                icon: 'error',
                title: 'Truy cập bị từ chối!',
                text: '${sessionScope.authError}',
                confirmButtonColor: '#3085d6',
                confirmButtonText: 'Đã hiểu'
            });
        });
    </script>
    <c:remove var="authError" scope="session" />
</c:if>

<script>
    // Extract server data parsed by JSTL
    const revenueLabels = [
        <c:forEach items="${dailyRevenue}" var="item" varStatus="loop">
            "${item.time_label}"${!loop.last ? ',' : ''}
        </c:forEach>
    ];
    const revenueValues = [
        <c:forEach items="${dailyRevenue}" var="item" varStatus="loop">
            ${item.revenue}${!loop.last ? ',' : ''}
        </c:forEach>
    ];

    const statusLabels = [
        <c:forEach items="${orderStatusList}" var="item" varStatus="loop">
            "${item.status}"${!loop.last ? ',' : ''}
        </c:forEach>
    ];
    const statusValues = [
        <c:forEach items="${orderStatusList}" var="item" varStatus="loop">
            ${item.order_count}${!loop.last ? ',' : ''}
        </c:forEach>
    ];

    document.addEventListener("DOMContentLoaded", function () {
        setupModal('notification-account-modal', 'notification-modal-btn', 'close-modal-btn8');
        setupModal('avatar-account-modal', 'avatar-modal-btn', 'close-modal-btn9');
        setupModal('out_of_stocks-modal', 'out_of_stocks-modal-btn', 'close-modal-out_of_stock');

        if (typeof setupDynamicModals === "function") {
            setupDynamicModals('todo-trigger', 'close-todo-modal');
        }

        // Fill task data in modal
        const taskItems = document.querySelectorAll('.todo-trigger');
        taskItems.forEach(item => {
            item.addEventListener('click', function () {
                const id = this.getAttribute('data-id');
                const title = this.getAttribute('data-title');
                const content = this.getAttribute('data-content');
                const status = this.getAttribute('data-status');

                document.getElementById('modal-task-id').value = id;
                document.getElementById('modal-task-title').innerText = title;
                document.getElementById('modal-task-content').innerText = content;
                document.getElementById('modal-task-status').value = status;
            });
        });

        // Initialize Charts
        var isDarkMode = document.body.classList.contains('dark-theme');
        var gridBorderColor = isDarkMode ? '#334155' : '#e2e8f0';

        // 1. Revenue Area Chart
        var revenueOptions = {
            series: [{
                name: 'Doanh Thu',
                data: revenueValues
            }],
            chart: {
                type: 'area',
                height: 300,
                toolbar: { show: false },
                foreColor: 'var(--text-muted)'
            },
            dataLabels: { enabled: false },
            stroke: {
                curve: 'smooth',
                width: 3,
                colors: ['#4f46e5']
            },
            fill: {
                type: 'gradient',
                gradient: {
                    shadeIntensity: 1,
                    opacityFrom: 0.45,
                    opacityTo: 0.05,
                    stops: [0, 100],
                    colorStops: [{
                        offset: 0,
                        color: '#4f46e5',
                        opacity: 0.4
                    }, {
                        offset: 100,
                        color: '#4f46e5',
                        opacity: 0.0
                    }]
                }
            },
            xaxis: {
                categories: revenueLabels,
                axisBorder: { show: false },
                axisTicks: { show: false }
            },
            yaxis: {
                labels: {
                    formatter: function (val) {
                        return val.toLocaleString('vi-VN') + ' đ';
                    }
                }
            },
            tooltip: {
                theme: isDarkMode ? 'dark' : 'light',
                y: {
                    formatter: function (val) {
                        return val.toLocaleString('vi-VN') + ' đ';
                    }
                }
            },
            grid: {
                borderColor: gridBorderColor,
                strokeDashArray: 4
            }
        };

        var revenueChart = new ApexCharts(document.querySelector("#revenue-trend-chart"), revenueOptions);
        revenueChart.render();

        // 2. Order Status Donut Chart
        var statusOptions = {
            series: statusValues,
            labels: statusLabels,
            chart: {
                type: 'donut',
                height: 300,
                foreColor: 'var(--text-muted)'
            },
            dataLabels: { enabled: false },
            colors: ['#10b981', '#ef4444', '#f59e0b', '#3b82f6', '#6366f1', '#64748b'],
            legend: {
                position: 'bottom',
                horizontalAlign: 'center',
                labels: {
                    colors: 'var(--text-main)'
                }
            },
            stroke: {
                show: true,
                width: 2,
                colors: [isDarkMode ? '#1e293b' : '#ffffff']
            },
            tooltip: {
                theme: isDarkMode ? 'dark' : 'light'
            },
            plotOptions: {
                pie: {
                    donut: {
                        size: '70%',
                        labels: {
                            show: true,
                            name: { show: true },
                            value: {
                                show: true,
                                formatter: function (val) {
                                    return val + ' đơn';
                                }
                            },
                            total: {
                                show: true,
                                label: 'Tổng đơn',
                                formatter: function (w) {
                                    return w.globals.seriesTotals.reduce((a, b) => a + b, 0) + ' đơn';
                                }
                            }
                        }
                    }
                }
            }
        };

        var statusChart = new ApexCharts(document.querySelector("#order-status-chart"), statusOptions);
        statusChart.render();

        // Listen for Theme Switcher (Dark Mode Toggle) to dynamically update charts
        document.getElementById('adminDarkModeToggle')?.addEventListener('click', function() {
            setTimeout(function() {
                var isDark = document.body.classList.contains('dark-theme');
                var newBorder = isDark ? '#334155' : '#e2e8f0';
                
                revenueChart.updateOptions({
                    tooltip: { theme: isDark ? 'dark' : 'light' },
                    grid: { borderColor: newBorder }
                });
                
                statusChart.updateOptions({
                    stroke: { colors: [isDark ? '#1e293b' : '#ffffff'] },
                    tooltip: { theme: isDark ? 'dark' : 'light' }
                });
            }, 100);
        });
    });

    function submitDelete() {
        if (confirm("Bạn có chắc chắn muốn xoá phản hồi này không?")) {
            document.getElementById('modal-action').value = 'delete_task';
            document.getElementById('todo-form').submit();
        }
    }
</script>
</body>

</html>
