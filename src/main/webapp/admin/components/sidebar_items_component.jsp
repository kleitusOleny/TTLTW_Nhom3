<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<link rel="stylesheet" href="${pageContext.request.contextPath}/admin/admin_css/admin_sidebar.css?v=1.0.3">

<div class="group-avatar-new">
    <div class="admin-sidebar-header">

        <div class="admin-logo-box">
            <span class="logo-text-your">Your</span><span class="logo-text-logo">LOGO</span><span class="logo-text-q">?</span>
        </div>

        <div class="admin-name" id="avatar-modal-btn" style="cursor: pointer;" title="Nhấn để cài đặt / đăng xuất">
            <c:out value="${not empty sessionScope.user.fullName ? sessionScope.user.fullName : 'NGUYỄN PHÚ VINH'}" />
        </div>

        <div class="admin-quick-links">
            <a href="${pageContext.request.contextPath}/home" class="quick-link">Xem website</a>
            <span class="quick-link-separator">|</span>
            <a href="#" class="quick-link" id="clear-cache-link">Xóa cache</a>
        </div>
    </div>

    <div class="sidebar-section-title">
        CHỨC NĂNG HỆ THỐNG
    </div>
</div>

<li>
    <a href="${pageContext.request.contextPath}/dashboard"
       class="a-with-icon ${activePage == 'dashboard' ? 'selected' : ''}">
        <span class="sidebar-link-content">
            <ion-icon name="${activePage == 'dashboard' ? 'home' : 'home-outline'}"></ion-icon>
            Trang Chủ
        </span>
    </a>
</li>

<li>
    <a href="${pageContext.request.contextPath}/home" class="a-with-icon">
        <span class="sidebar-link-content">
            <ion-icon name="globe-outline"></ion-icon>
            Xem Website
        </span>
    </a>
</li>

<c:set var="isProductActive" value="${activePage == 'product' || activePage == 'category' || activePage == 'manufacturer'}" />
<li class="sidebar-dropdown ${isProductActive ? 'expanded' : ''}">
    <div class="a-with-icon dropdown-toggle ${isProductActive ? 'selected' : ''}">
        <span class="sidebar-link-content">
            <ion-icon name="cube-outline"></ion-icon>
            Sản phẩm
        </span>
        <ion-icon name="${isProductActive ? 'chevron-down-outline' : 'chevron-back-outline'}" class="item-arrow-icon arrow-icon"></ion-icon>
    </div>
    <ul class="dropdown-menu">
        <li>
            <a href="${pageContext.request.contextPath}/category-manager"
               class="submenu-item ${activePage == 'category' ? 'selected' : ''}">
               Danh mục
            </a>
        </li>
        <li>
            <a href="${pageContext.request.contextPath}/product-manager"
               class="submenu-item ${activePage == 'product' ? 'selected' : ''}">
               Sản phẩm
            </a>
        </li>
        <li>
            <a href="${pageContext.request.contextPath}/manage-manufacturer"
               class="submenu-item ${activePage == 'manufacturer' ? 'selected' : ''}">
               Thương hiệu
            </a>
        </li>
    </ul>
</li>

<c:set var="isOrderActive" value="${activePage == 'order' || activePage == 'review'}" />
<li class="sidebar-dropdown ${isOrderActive ? 'expanded' : ''}">
    <div class="a-with-icon dropdown-toggle ${isOrderActive ? 'selected' : ''}">
        <span class="sidebar-link-content">
            <ion-icon name="cart-outline"></ion-icon>
            Đơn hàng & Đánh giá
        </span>
        <ion-icon name="${isOrderActive ? 'chevron-down-outline' : 'chevron-back-outline'}" class="item-arrow-icon arrow-icon"></ion-icon>
    </div>
    <ul class="dropdown-menu">
        <li>
            <a href="${pageContext.request.contextPath}/admin/manage-orders"
               class="submenu-item ${activePage == 'order' ? 'selected' : ''}">
               Đơn hàng
            </a>
        </li>
        <li>
            <a href="${pageContext.request.contextPath}/admin/manage-reviews"
               class="submenu-item ${activePage == 'review' ? 'selected' : ''}">
               Đánh giá
            </a>
        </li>
    </ul>
</li>

<c:set var="isMediaActive" value="${activePage == 'banner' || activePage == 'blog'}" />
<li class="sidebar-dropdown ${isMediaActive ? 'expanded' : ''}">
    <div class="a-with-icon dropdown-toggle ${isMediaActive ? 'selected' : ''}">
        <span class="sidebar-link-content">
            <ion-icon name="images-outline"></ion-icon>
            Banner & Tin tức
        </span>
        <ion-icon name="${isMediaActive ? 'chevron-down-outline' : 'chevron-back-outline'}" class="item-arrow-icon arrow-icon"></ion-icon>
    </div>
    <ul class="dropdown-menu">
        <li>
            <a href="${pageContext.request.contextPath}/banner-manager"
               class="submenu-item ${activePage == 'banner' ? 'selected' : ''}">
               Banner
            </a>
        </li>
        <li>
            <a href="${pageContext.request.contextPath}/admin/manage-blog"
               class="submenu-item ${activePage == 'blog' ? 'selected' : ''}">
               Tin tức
            </a>
        </li>
    </ul>
</li>

<c:set var="isWarehouseActive" value="${activePage == 'receipt' || activePage == 'issue'}" />
<li class="sidebar-dropdown ${isWarehouseActive ? 'expanded' : ''}">
    <div class="a-with-icon dropdown-toggle ${isWarehouseActive ? 'selected' : ''}">
        <span class="sidebar-link-content">
            <ion-icon name="archive-outline"></ion-icon>
            Quản lý kho hàng
        </span>
        <ion-icon name="${isWarehouseActive ? 'chevron-down-outline' : 'chevron-back-outline'}" class="item-arrow-icon arrow-icon"></ion-icon>
    </div>
    <ul class="dropdown-menu">
        <li>
            <a href="${pageContext.request.contextPath}/product-receipt-manager"
               class="submenu-item ${activePage == 'receipt' ? 'selected' : ''}">
               Nhập kho
            </a>
        </li>
        <li>
            <a href="${pageContext.request.contextPath}/product-issue-manager"
               class="submenu-item ${activePage == 'issue' ? 'selected' : ''}">
               Xuất kho
            </a>
        </li>
    </ul>
</li>

<li>
    <a href="${pageContext.request.contextPath}/account-manager"
       class="a-with-icon ${activePage == 'account' ? 'selected' : ''}">
        <span class="sidebar-link-content">
            <ion-icon name="${activePage == 'account' ? 'people' : 'people-outline'}"></ion-icon>
            Quản Lí Tài Khoản
        </span>
        <ion-icon name="chevron-back-outline" class="item-arrow-icon"></ion-icon>
    </a>
</li>

<li>
    <a href="${pageContext.request.contextPath}/staffs-manager"
       class="a-with-icon ${activePage == 'staff' ? 'selected' : ''}">
        <span class="sidebar-link-content">
            <ion-icon name="${activePage == 'staff' ? 'body' : 'body-outline'}"></ion-icon>
            Quản lí nhân sự
        </span>
        <ion-icon name="chevron-back-outline" class="item-arrow-icon"></ion-icon>
    </a>
</li>

<li>
    <a href="${pageContext.request.contextPath}/admin/manage-promotions"
       class="a-with-icon ${activePage == 'promotion' ? 'selected' : ''}">
        <span class="sidebar-link-content">
            <ion-icon name="ticket-outline"></ion-icon>
            Quản Lí Mã Giảm Giá và Khuyến Mãi
        </span>
        <ion-icon name="chevron-back-outline" class="item-arrow-icon"></ion-icon>
    </a>
</li>

<li>
    <a href="${pageContext.request.contextPath}/admin/manage-files"
       class="a-with-icon ${activePage == 'files' ? 'selected' : ''}">
        <span class="sidebar-link-content">
            <ion-icon name="${activePage == 'files' ? 'folder' : 'folder-outline'}"></ion-icon>
            Quản Lí File & Hình Ảnh
        </span>
        <ion-icon name="chevron-back-outline" class="item-arrow-icon"></ion-icon>
    </a>
</li>

<script>
document.addEventListener("DOMContentLoaded", function() {
    const dropdownToggles = document.querySelectorAll('.sidebar-dropdown .dropdown-toggle');
    dropdownToggles.forEach(toggle => {
        toggle.addEventListener('click', function(e) {
            e.preventDefault();
            const parent = this.closest('.sidebar-dropdown');
            parent.classList.toggle('expanded');

            const arrow = this.querySelector('.arrow-icon');
            if (arrow) {
                if (parent.classList.contains('expanded')) {
                    arrow.setAttribute('name', 'chevron-down-outline');
                } else {
                    arrow.setAttribute('name', 'chevron-back-outline');
                }
            }
        });
    });

    const clearCacheBtn = document.getElementById('clear-cache-link');
    if (clearCacheBtn) {
        clearCacheBtn.addEventListener('click', function(e) {
            e.preventDefault();
            if (typeof Swal !== 'undefined') {
                Swal.fire({
                    toast: true,
                    position: 'top-end',
                    icon: 'success',
                    title: 'Đã xóa cache hệ thống thành công!',
                    showConfirmButton: false,
                    timer: 2000,
                    timerProgressBar: true
                });
            } else {
                const toast = document.createElement('div');
                toast.style.position = 'fixed';
                toast.style.top = '20px';
                toast.style.right = '20px';
                toast.style.backgroundColor = '#10b981';
                toast.style.color = 'white';
                toast.style.padding = '12px 24px';
                toast.style.borderRadius = '6px';
                toast.style.boxShadow = '0 4px 12px rgba(0,0,0,0.15)';
                toast.style.zIndex = '99999';
                toast.style.fontWeight = 'bold';
                toast.style.display = 'flex';
                toast.style.alignItems = 'center';
                toast.style.gap = '8px';
                toast.style.transition = 'all 0.3s ease';
                toast.style.opacity = '0';
                toast.style.transform = 'translateY(-20px)';
                toast.innerHTML = '<ion-icon name="checkmark-circle-outline" style="font-size: 20px;"></ion-icon> Đã xóa cache thành công!';

                document.body.appendChild(toast);

                setTimeout(() => {
                    toast.style.opacity = '1';
                    toast.style.transform = 'translateY(0)';
                }, 50);

                setTimeout(() => {
                    toast.style.opacity = '0';
                    toast.style.transform = 'translateY(-20px)';
                    setTimeout(() => {
                        toast.remove();
                    }, 300);
                }, 2000);
            }
        });
    }
});
</script>